import 'package:flutter/material.dart';
import 'package:travel_app/Controllers/GeneralMethods.dart';

class ReportUser extends StatefulWidget {
  const ReportUser({super.key});

  @override
  State<ReportUser> createState() => _ReportUserState();
}

class _ReportUserState extends State<ReportUser> {
  TextEditingController emailController = TextEditingController();
  GeneralMethods generalMethods = GeneralMethods();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      highlightColor: Colors.transparent,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 18),
                  const Text(
                    'Report User',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 27,
                        color: Colors.white),
                  ),
                ],
              ),
              SizedBox(
                height: 32,
              ),
              TextField(
                controller: emailController,
                cursorColor: Colors.white,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email Body',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(18)),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                maxLines: 5,
              ),
              Spacer(),
              Center(
                child: InkWell(
                  onTap: () async {
                    if (emailController.text.isNotEmpty) {
                      generalMethods.sendEmail(emailController.text);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Report User',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
