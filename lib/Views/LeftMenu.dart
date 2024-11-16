import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/Controllers/UserMethods.dart';
import 'package:travel_app/Controllers/UserProvider.dart';
import 'package:travel_app/Views/Contacts.dart';
import 'package:travel_app/Views/NewFriend.dart';
import 'package:travel_app/models/Utente.dart';

class LeftMenu extends StatelessWidget {
  const LeftMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Utente? user = Provider.of<UserProvider>(context).getUser;
    UserMethods userMethods = UserMethods();

    return Drawer(
      child: Container(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    user != null ? user.username : 'Guest',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user != null
                        ? user.email
                        : 'Sign in to access more features',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            buildMenuItem(
              icon: Icons.home_outlined,
              text: 'Home',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            buildMenuItem(
              icon: Icons.message_outlined,
              text: 'Messages',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => Contacts(
                            mode: 1,
                          )),
                );
              },
            ),
            buildMenuItem(
              icon: Icons.contacts_outlined,
              text: 'Contacts',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => Contacts(
                            mode: 2,
                          )),
                );
              },
            ),
            buildMenuItem(
              icon: Icons.group_outlined,
              text: 'Friends Requests',
              onTap: () async {
                List<Map<String, dynamic>> requests =
                    await userMethods.getReceivedFriendRequests(user!.uid);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewFriend(requests: requests),
                  ),
                );
              },
            ),
            const Divider(),
            buildMenuItem(
              icon: Icons.help_outline,
              text: 'Help & Feedback',
              onTap: () {
                // Add action
              },
            ),
          ],
        ),
      ),
    );
  }
}

ListTile buildMenuItem({
  required IconData icon,
  required String text,
  required VoidCallback onTap,
}) {
  return ListTile(
    splashColor: Colors.black12,
    leading: Icon(
      icon,
      size: 24,
    ),
    title: Text(
      text,
      style: TextStyle(
        fontSize: 16,
      ),
    ),
    onTap: onTap,
  );
}
