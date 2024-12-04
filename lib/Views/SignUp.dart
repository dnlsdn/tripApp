import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_app/Controllers/AuthMethods.dart';
import 'package:travel_app/Controllers/UserMethods.dart';
import 'package:travel_app/Utils/ImagePicker.dart';
import 'package:travel_app/Views/HomePage.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUp> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  Uint8List? image;
  bool isLoading = false;
  bool isShow = false;
  bool isError = false;
  String risultato = '';
  UserMethods userMethods = UserMethods();
  AuthMethods authMethods = AuthMethods();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
  }

  void selectImage() async {
    Uint8List? im = await pickImage(ImageSource.gallery);
    setState(() {
      image = im;
    });
  }

  Future<void> register() async {
    try {
      setState(() {
        isLoading = true;
      });

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      CollectionReference collectionRef = firestore.collection('users');

      QuerySnapshot querySnapshot = await collectionRef.get();

      List<dynamic> valoriParametro =
          querySnapshot.docs.map((doc) => doc['username']).toList();

      for (dynamic item in valoriParametro) {
        if (item == usernameController.text) {
          risultato = 'Username already used!';
          setState(() {
            isLoading = false;
          });
          return;
        }
      }

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = userCredential.user;
      String photoUrl = '';

      if (user != null) {
        try {
          if (image != null) {
            Reference storageRef = FirebaseStorage.instance
                .ref()
                .child('profilePics')
                .child('${user.uid}.jpg');

            UploadTask uploadTask = storageRef.putData(image!);
            TaskSnapshot snapshot = await uploadTask;

            photoUrl = await snapshot.ref.getDownloadURL();
          } else {
            try {
              photoUrl = await FirebaseStorage.instance
                  .ref('assets/person.png')
                  .getDownloadURL();
            } catch (e) {
              photoUrl =
                  'https://imagizer.imageshack.com/img924/9726/nAcDaY.png';
              print('Error loading default image: $e');
            }
          }

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'username': usernameController.text,
            'email': emailController.text,
            'photoUrl': photoUrl,
            'uid': user.uid,
          });

          risultato = "Registration Completed";

          await authMethods.updateUserToken(user.uid);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } catch (e) {
          risultato = 'Error while saving data: $e';
        }
      }
    } on FirebaseAuthException catch (e) {
      risultato = 'Error: ${e.message}';
    } catch (e) {
      risultato = 'Generic Error: $e';
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: selectImage,
                      child: image != null
                          ? Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.blue, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 64,
                                backgroundImage: MemoryImage(image!),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.blue, width: 5)),
                              child: const CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 64,
                                child: Icon(
                                  Icons.photo_outlined,
                                  size: 88,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: image != null ? null : Colors.blue,
                        ),
                        child: image != null
                            ? null
                            : const Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 32,
                ),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    hintText: "Enter your Username",
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 38,
                ),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.mail,
                      color: Colors.white,
                    ),
                    hintText: "Enter your Email",
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 38,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: passwordController,
                        obscureText: isShow ? false : true,
                        decoration: const InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                          ),
                          hintText: "Enter your Password",
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            isShow = !isShow;
                          });
                        },
                        child: Icon(isShow
                            ? Icons.remove_red_eye
                            : Icons.visibility_off),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 58,
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => register(),
                  // onTap: () async {
                  //   setState(() {
                  //     isLoading = true;
                  //   });
                  //   ByteData byteImage =
                  //       await rootBundle.load('assets/person.png');
                  //   image ??= byteImage.buffer.asUint8List();
                  //   String res = await signupUser(
                  //     email: emailController.text,
                  //     username: usernameController.text,
                  //     file: image!,
                  //     password: passwordController.text,
                  //   );

                  //   setState(() {
                  //     isLoading = false;
                  //     isError = res != "Success";
                  //   });
                  // },
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        )
                      : Container(
                          height: 38,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.white, width: 1),
                              color: Colors.blue),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                ),
                const SizedBox(
                  height: 18,
                ),
                // Visibility(
                //   visible: isError,
                //   child: Text(isError ? risultato : ''),
                // ),
                Text(risultato),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
