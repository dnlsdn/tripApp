//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/Controllers/AuthMethods.dart';
import 'package:travel_app/Views/BottomBar.dart';
import 'package:travel_app/models/Utente.dart';

import '../Controllers/UserProvider.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isShow = false;
  bool isError = false;
  bool isLoading = false;

  void loginUser() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthMethods().loginUser(
        email: emailController.text, password: passwordController.text);

    if (res == "success") {
      Utente loggedInUser = await AuthMethods().getUserDetails();

      // Verifica cosa contiene loggedInUser
      print("Logged in user email: ${loggedInUser.email}");
      print("Logged in user: ${loggedInUser.username}");

      if (mounted) {
        Provider.of<UserProvider>(context, listen: false).setUser(loggedInUser);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BottomBar()),
        );
      }
    } else {
      setState(() {
        isError = true;
        isLoading = false;
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          isError = false;
        });
      });
    }
  }

  void showAlertNoEmail(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Insert an Email'),
          content: const Text('Insert an Email to reset password'),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showAlertEmailSent(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Email Sent'),
          content: const Text('Email sent to reset password'),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 5)),
                child: const CircleAvatar(
                  backgroundColor: Color.fromARGB(238, 255, 255, 255),
                  radius: 64,
                  child: Icon(
                    Icons.person,
                    size: 88,
                    color: Colors.black,
                  ),
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
                      child: Icon(
                          isShow ? Icons.remove_red_eye : Icons.visibility_off),
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
                onTap: loginUser,
                child: isLoading
                    ? const Center(
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
                          'Log In',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
              const SizedBox(
                height: 18,
              ),
              Container(
                alignment: AlignmentDirectional.centerEnd,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    if (emailController.text.isEmpty) {
                      showAlertNoEmail(context);
                    } else {
                      UserProvider().resetPassword(emailController.text);
                      showAlertEmailSent(context);
                    }
                  },
                  child: const Text('Reset Password'),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Visibility(
                  visible: isError,
                  child: Text(isError
                      ? 'Registration Failed:\nUse a real email address and the right password'
                      : '')),
            ],
          ),
        ),
      ),
    );
  }
}
