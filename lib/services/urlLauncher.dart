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
  url = extractPhoneNumber(url);

  correctURL = Uri.parse('tel:' + url);
  print(correctURL.toString());

  if (await canLaunchUrl(correctURL)) {
    await launchUrl(correctURL);
  } else {
    throw 'Could not launch ${correctURL.toString()}';
  }
}

String extractPhoneNumber(String url) {
  //@todo this regex can certainly be further improved
  try {
    // remove some chars to detect even wierd formatted phone numbers
    RegExp expToRemove = RegExp(r'[\s/-]');
    url = url.replaceAll(expToRemove, "");
    /* The regExpForTelephoneNumbers explained:
    * (+\d{1,3}\s?)? - This part recognizes an optional country code starting with a plus sign (+) followed by 1 to 3 digits and an optional space.
    * ((\d{1,3})\s?)? - This part recognizes an optional prefix in parentheses, starting with an opening parenthesis "(", followed by 1 to 3 digits, a closing parenthesis ")" and an optional space.
    * \d{1,4} - This part recognizes 1 to 4 digits for the main number.
    * [\s.-]? - This part recognizes an optional space, a hyphen "-" or a period "." as a separator.
    * \d{1,4} - This part recognizes 1 to 4 digits for the second number group.
    * [\s.-]? - This part again recognizes an optional space, a hyphen "-" or a period "." as a separator.
    * \d{1,9} - This part recognizes 1 to 9 digits for the third number group.
     */
    RegExp regExpForTelephoneNumbers = RegExp(
        r'(\+\d{1,3}\s?)?(\(\d{1,3}\)\s?)?\d{1,4}[\s.-]?\d{1,4}[\s.-]?\d{1,9}');
    List<String> phoneNumbers = url.split(regExpForTelephoneNumbers);
    List<String?> result = regExpForTelephoneNumbers
        .allMatches(url)
        .map((e) => e.group(0))
        .toList();
    if (result[0] != null) {
      return result[0]!;
    }
    return phoneNumbers[0];
  } catch (e) {
    print("no valid phone number found. ${e.toString()}");
    return "no valid phone number";
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
