import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchUrlInBrowser(String url) async {
  String correctURL = "";
  if(url.startsWith('http')) {
    correctURL = url;
  } else {
    int firstPoint = url.indexOf('.');
    String domain = url.substring(firstPoint+1, url.length);
    correctURL = 'https://' + domain;
  }
  print("open: " + correctURL);
  if (await canLaunch(correctURL)) {
    await launch(
      correctURL,
      forceSafariVC: false,
      forceWebView: false,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    );
  } else {
    throw 'Could not launch $correctURL';
  }
}


Future<void> makePhoneCall(String url) async {
  String correctURL = "";
  RegExp exp = RegExp("[0-9]");
  int firstNumber = url.indexOf(exp);
  //print("First Number at: " + firstNumber.toString());
  correctURL = 'tel:' + url.substring(firstNumber, url.length);
  print(correctURL);

  if (await canLaunch(correctURL)) {
    await launch(correctURL);
  } else {
    throw 'Could not launch $correctURL';
  }
}

Future<void> launchEmail(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceSafariVC: false,
      forceWebView: false,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    );
  } else {
    throw 'Could not launch $url';
  }
}