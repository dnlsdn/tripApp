import 'package:url_launcher/url_launcher.dart';

class GeneralMethods {
  Future<void> sendEmail(String body, String mode, String username) async {
    Uri params = Uri();

    if (mode == 'report') {
      params = Uri(
        scheme: 'mailto',
        path: 'tripapp18@gmail.com',
        query: 'subject=Report User&body=${'$username\n$body'}',
      );
    } else {
      params = Uri(
        scheme: 'mailto',
        path: 'tripapp18@gmail.com',
        query: 'subject=Help & Feedback&body=${'$username\n$body'}',
      );
    }

    final url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
