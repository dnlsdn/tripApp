import 'dart:io'; // Per File

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Per selezionare l'immagine
import 'package:provider/provider.dart';
import 'package:travel_app/Controllers/GoogleMapsMethods.dart';
import 'package:travel_app/Controllers/UserProvider.dart';
import 'package:travel_app/Views/SignUpLogIn.dart';
import 'package:travel_app/models/Utente.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String username = "";
  bool isEditing = false;
  TextEditingController usernameController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool imageUpdated = false;
  bool errorImage = false;
  late GoogleMapsMethods googleMapsMethods;
  String nTravels = 'err';

  @override
  void initState() {
    super.initState();
    googleMapsMethods =
        GoogleMapsMethods(setState, CustomInfoWindowController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false).getUser;
      if (user == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignUpLogIn()),
        );
      }
    });
    loadNTravels();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1080,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile != null) {
        // Controlla il formato dell'immagine
        final imageFile = File(pickedFile.path);
        print(
            'Image picked: ${pickedFile.path}'); // Log del percorso dell'immagine
        print(
            'Image type: ${pickedFile.mimeType}'); // Log del tipo dell'immagine

        // Verifica se l'immagine è un JPEG o PNG
        if (pickedFile.mimeType == 'image/jpeg' ||
            pickedFile.mimeType == 'image/png' ||
            pickedFile.mimeType == 'image/jpg') {
          setState(() {
            _image = imageFile;
          });

          // Carica l'immagine su Firebase o nel server
          await Provider.of<UserProvider>(context, listen: false)
              .uploadProfilePicture(_image!); // Aggiungi await qui
          imageUpdated = true;
          Future.delayed(const Duration(seconds: 8), () {
            setState(() {
              imageUpdated = false;
            });
          });
        } else {
          print('Invalid image format: ${pickedFile.mimeType}');
          errorImage = true;
          setState(() {});
          Future.delayed(const Duration(seconds: 8), () {
            setState(() {
              errorImage = false;
            });
          });
        }
      }
    } catch (e) {
      print('Error: ${e}');
      errorImage = true;
      setState(() {});
      Future.delayed(const Duration(seconds: 8), () {
        setState(() {
          errorImage = false;
        });
      });
    }
  }

  Future<void> loadNTravels() async {
    final result = await googleMapsMethods.loadNumbersPolylines();
    setState(() {
      nTravels = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    Utente? user = Provider.of<UserProvider>(context).getUser;
    usernameController.text = user?.username ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            onPressed: () async {
              Provider.of<UserProvider>(context, listen: false).logout();

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const SignUpLogIn()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage, // Funzione per selezionare l'immagine
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _image != null
                        ? FileImage(_image!) // Mostra l'immagine selezionata
                        : NetworkImage(user?.photoUrl ?? '') as ImageProvider,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 38),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.grey),
                const SizedBox(width: 10),
                if (!isEditing)
                  Text(
                    user?.username ?? 'Guest',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  )
                else
                  SizedBox(
                    width: 150,
                    child: TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter new username',
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(isEditing ? Icons.check : Icons.edit),
                  onPressed: () {
                    setState(() {
                      if (isEditing) {
                        final newUsername = usernameController.text;
                        if (newUsername.isNotEmpty) {
                          Provider.of<UserProvider>(context, listen: false)
                              .updateUsername(user?.uid ?? '', newUsername);
                        }
                      }
                      isEditing = !isEditing;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.email, color: Colors.grey),
                const SizedBox(width: 10),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.travel_explore, color: Colors.grey),
                const SizedBox(width: 10),
                Text(
                  'n° Travels: $nTravels',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            Visibility(
              visible: imageUpdated,
              child: const Padding(
                padding: EdgeInsets.only(bottom: 18),
                child: Text(
                  textAlign: TextAlign.center,
                  'Image Updated',
                  style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                ),
              ),
            ),
            Visibility(
              visible: errorImage,
              child: const Padding(
                padding: EdgeInsets.only(bottom: 38),
                child: Text(
                  textAlign: TextAlign.center,
                  'Image not Updated! Check dimension and type!',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
