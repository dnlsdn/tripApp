import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/Controllers/UserProvider.dart';
import 'package:travel_app/models/Utente.dart';

class LeftMenu extends StatelessWidget {
  const LeftMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Utente? user = Provider.of<UserProvider>(context).getUser;
    return Drawer(
      child: Container(
        //color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                  //color: Colors.blue.shade100,
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    user != null ? user.username : 'Guest',
                    style: TextStyle(
                      //color: Colors.blue.shade800,
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
                      //color: Colors.blue.shade600,
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
                // Add action
              },
            ),
            buildMenuItem(
              icon: Icons.explore_outlined,
              text: 'Explore',
              onTap: () {
                // Add action
              },
            ),
            buildMenuItem(
              icon: Icons.favorite_border,
              text: 'Favorites',
              onTap: () {
                // Add action
              },
            ),
            buildMenuItem(
              icon: Icons.settings_outlined,
              text: 'Settings',
              onTap: () {
                // Add action
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
      //color: Colors.blue.shade800,
      size: 24,
    ),
    title: Text(
      text,
      style: TextStyle(
        //color: Colors.blue.shade800,
        fontSize: 16,
      ),
    ),
    onTap: onTap,
  );
}
