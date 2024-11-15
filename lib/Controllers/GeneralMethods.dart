import 'package:url_launcher/url_launcher.dart';

class GeneralMethods {
  Future<void> sendEmail(String body) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path:
          'tripapp18@gmail.com',
      query:
          'subject=Report User&body=$body',
    );

    final url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
