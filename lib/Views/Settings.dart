import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:travel_app/Controllers/UserMethods.dart';
import 'package:travel_app/Controllers/UserProvider.dart';
import 'package:travel_app/models/Utente.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final InAppReview _inAppReview = InAppReview.instance;
  final String urlPrivacyPolicy = 'https://www.google.com';
  UserMethods userMethods = UserMethods();

  Future<void> rateApp() async {
    if (await _inAppReview.isAvailable()) {
      try {
        await _inAppReview.requestReview();
      } catch (e) {
        print('Error requesting review: $e');
      }
    } else {
      try {
        await _inAppReview.openStoreListing(
          appStoreId: 'YOUR_APPSTORE_ID',
          microsoftStoreId: 'YOUR_MICROSOFT_STORE_ID',
        );
      } catch (e) {
        print('Error opening store listing: $e');
      }
    }
  }

  Future<void> openLinkPrivacyPolicy() async {
    final Uri uri = Uri.parse(urlPrivacyPolicy);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Non posso aprire il link: $urlPrivacyPolicy';
    }
  }

  Future<void> shareApp() async {
    const String appUrlAndroid =
        'https://play.google.com/store/apps/details?id=com.example.myapp';
    const String appUrlIOS =
        'https://apps.apple.com/us/app/my-app/id1234567890';
    const String message = 'Download Wheely!';

    await Share.share('$message\nAndroid: $appUrlAndroid\niOS: $appUrlIOS');
  }

  void showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteAccount();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void deleteAccount() {
    Utente? user = Provider.of<UserProvider>(context, listen: false).getUser;
    userMethods.deleteUserAccount();
    userMethods.deleteUserData(user!.uid);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account successfully deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              const SizedBox(height: 38),
              Row(
                children: [
                  Icon(Icons.star_border_outlined),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    '5 Stars :)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Spacer(),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(68)),
                    child: IconButton(
                      onPressed: () {
                        rateApp();
                      },
                      icon: Icon(
                        Icons.star_outline,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
              Row(
                children: [
                  Icon(Icons.notifications_active_outlined),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Spacer(),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(68)),
                    child: IconButton(
                      onPressed: () {
                        AppSettings.openAppSettings(
                            type: AppSettingsType.notification);
                      },
                      icon: Icon(
                        Icons.notifications_active_outlined,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
              Row(
                children: [
                  Icon(Icons.privacy_tip_outlined),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Spacer(),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(68)),
                    child: IconButton(
                      onPressed: () {
                        openLinkPrivacyPolicy();
                      },
                      icon: Icon(
                        Icons.privacy_tip_outlined,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
              Row(
                children: [
                  Icon(Icons.ios_share),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Share Wheely',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Spacer(),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(68)),
                    child: IconButton(
                      onPressed: () {
                        shareApp();
                      },
                      icon: Icon(
                        Icons.ios_share,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
              Row(
                children: [
                  Icon(Icons.description_outlined),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Help & Feedback',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Spacer(),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(68)),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.description_outlined,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
              Spacer(),
              InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  showDeleteConfirmationDialog();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    textAlign: TextAlign.center,
                    'Delete the Account',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
