import 'package:url_launcher/url_launcher.dart';

Future<void> launchUrlInBrowser(String url) async {
  Uri correctURL;
  if (url.startsWith('http')) {
    correctURL = Uri.parse(url);
  } else if (url.startsWith("<a")) {
    int beginURL = url.indexOf("\"")+1;
    int endURL = url.indexOf("\"", beginURL + 1);

    correctURL = Uri.parse(url.substring(beginURL, endURL));
  } else {
    int firstPoint = url.indexOf('.');
    String domain = url.substring(firstPoint + 1, url.length);
    correctURL = Uri.parse('https://' + domain);
  }
  print("open: " + correctURL.toString());
  if (await canLaunchUrl(correctURL)) {
    await launchUrl(correctURL, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $correctURL';
  }
}

Future<void> makePhoneCall(String url) async {
  Uri correctURL;
  RegExp exp = RegExp("[0-9]");
  int firstNumber = url.indexOf(exp);
  //print("First Number at: " + firstNumber.toString());
  correctURL = Uri.parse('tel:' + url.substring(firstNumber, url.length));
  print(correctURL.toString());

  if (await canLaunchUrl(correctURL)) {
    await launchUrl(correctURL);
  } else {
    throw 'Could not launch ${correctURL.toString()}';
  }
}

Future<void> launchEmail(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}
