import "package:url_launcher/url_launcher.dart";

import "../class/class_ErrorLogger.dart";

String extractWebAddress(String text) {
  if (text.startsWith("<a")) {
    int beginIndex = text.indexOf("href=\"") + 6;
    int endIndex = text.indexOf("\"", beginIndex);
    text= text.substring(beginIndex, endIndex);
  }

  final RegExp webAddressRegEx = RegExp(r"((http|https)://)?(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&/=]*)");
  final RegExpMatch? match = webAddressRegEx.firstMatch(text);
  if(match != null && match.start == 0 && match.end == text.length) {
    return text;
  }

  return "invalid";
}

Future<void> launchUrlInBrowser(String url) async {
  Uri webAddress = Uri.parse(extractWebAddress(url));
  if (await canLaunchUrl(webAddress)) {
    await launchUrl(webAddress, mode: LaunchMode.externalApplication);
  } else {
    throw "Could not launch $webAddress";
  }
}

Future<void> makePhoneCall(String url) async {
  String phoneNumber = extractPhoneNumber(url);
  Uri uri = Uri.parse("tel:$phoneNumber");

  print("Extracted phone number: $phoneNumber");

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw "Could not launch ${uri.toString()}";
  }
}

String extractPhoneNumber(String text) {
  try {
    // remove some chars to detect even weird formatted phone numbers
    RegExp expToRemove = RegExp(r"[\s/-]");
    text = text.replaceAll(expToRemove, "");

    // @todo this regex can certainly be further improved
    /*
    * (+\d{1,3}\s?)? - This part recognizes an optional country code starting with a plus sign (+) followed by 1 to 3 digits and an optional space.
    * ((\d{1,3})\s?)? - This part recognizes an optional prefix in parentheses, starting with an opening parenthesis "(", followed by 1 to 3 digits, a closing parenthesis ")" and an optional space.
    * \d{1,4} - This part recognizes 1 to 4 digits for the main number.
    * [\s.-]? - This part recognizes an optional space, a hyphen "-" or a period "." as a separator.
    * \d{1,4} - This part recognizes 1 to 4 digits for the second number group.
    * [\s.-]? - This part again recognizes an optional space, a hyphen "-" or a period "." as a separator.
    * \d{1,9} - This part recognizes 1 to 9 digits for the third number group.
     */
    RegExp phoneNumberRegex = RegExp(
        r"(\+\d{1,3}\s?)?(\(\d{1,3}\)\s?)?\d{1,4}[\s.-]?\d{1,4}[\s.-]?\d{1,9}");

    List<String> phoneNumbers = text.split(phoneNumberRegex);
    List<String?> result =
        phoneNumberRegex.allMatches(text).map((e) => e.group(0)).toList();

    if (result[0] != null) {
      return result[0]!;
    }

    return phoneNumbers[0];
  } catch (e) {
    print("No valid phone number found: " + e.toString());
    // write to logfile
    ErrorLogger.writeErrorLog(
        "urlLauncher.dart",
        "No valid phone number found",
        e.toString());
    return "invalid";
  }
}

Future<void> launchEmail(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw "Could not launch $url";
  }
}
