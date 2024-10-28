import 'package:url_launcher/url_launcher.dart';

class GeneralMethods {
  Future<void> sendEmail(String body) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path:
          'tripapp18@gmail.com', // inserisci qui l'indirizzo email destinatario
      query:
          'subject=Report User&body=$body', // inserisci qui l'oggetto dell'email
    );

    final url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
