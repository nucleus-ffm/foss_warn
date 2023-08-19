import 'package:url_launcher/url_launcher.dart';

Future<void> launchUrlInBrowser(String url) async {
  Uri correctURL;
  if (url.startsWith('http')) {
    correctURL = Uri.parse(url);
  } else if (url.startsWith("<a")) {
    int beginURL = url.indexOf("\"") + 1;
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
  // replace every space in the url
  url = url.replaceAll(" ", "");
  RegExp exp = RegExp("\\+|[0-9]|\s");
  int firstNumber = 0;

  // this loop will be executed only if `continue` is called.
  // otherwise it will be executed once
  while (firstNumber != -1) {
    // search for valid next numbers.
    firstNumber = url.indexOf(exp, firstNumber + 1);
    // we can not find a valid telephone number. stop searching
    if(firstNumber == -1) break;

    int lastNumber = firstNumber;
    // find the end of the telephone number
    while (lastNumber < url.length && exp.hasMatch(url[lastNumber])) {
      lastNumber++;
    }
    // check if it es just one oder two numbers, which can not be a valid telephone number
    // start search again
    if (lastNumber - firstNumber < 4) continue;

    correctURL = Uri.parse(
        'tel:' + url.substring(firstNumber, lastNumber).replaceAll(" ", ""));
    print(correctURL.toString());

    if (await canLaunchUrl(correctURL)) {
      await launchUrl(correctURL);
      break;
    } else {
      throw 'Could not launch ${correctURL.toString()}';
    }
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
