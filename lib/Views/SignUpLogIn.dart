import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/Controllers/UserProvider.dart';
import 'package:travel_app/Views/LogIn.dart';
import 'package:travel_app/Views/SignUp.dart';

class SignUpLogIn extends StatefulWidget {
  const SignUpLogIn({super.key});

  @override
  State<SignUpLogIn> createState() => _SignUpLogInViewState();
}

class _SignUpLogInViewState extends State<SignUpLogIn> {
  bool isSign = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isSign ? 'Sign Up' : 'Log In',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          if (Provider.of<UserProvider>(context, listen: false)
                                  .getUser !=
                              null) {
                            Navigator.pop(context);
                          }
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 1)),
                          child: Icon(Icons.close),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(168, 255, 255, 255)),
                        borderRadius: BorderRadius.circular(5),
                        color: const Color.fromARGB(118, 158, 158, 158)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //Spacer(),
                        InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              isSign = false;
                            });
                          },
                          child: Text('Log In'),
                        ),
                        const SizedBox(
                          height: 18,
                          child: VerticalDivider(
                            color: Color.fromARGB(118, 158, 158, 158),
                          ),
                        ),
                        InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              isSign = true;
                            });
                          },
                          child: Text('Sign Up'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Expanded(
                    child: isSign ? SignUp() : LogIn(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
