import "package:url_launcher/url_launcher.dart";

Uri? extractWebAddress(String text) {
  if (text.startsWith("<a")) {
    // extract address from HTML-formatted tag
    int beginIndex = text.indexOf("href=\"") + 6;
    int endIndex = text.indexOf("\"", beginIndex);
    text = text.substring(beginIndex, endIndex);
  }

  // if the url is an email address, try adding a mailto and launch this
  final RegExp emailAddressRegEx = RegExp(
      r"""(?:[a-z0-9!#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+\/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])""");
  if (emailAddressRegEx.firstMatch(text) != null) {
    if (!text.startsWith("mailto:")) {
      text = "mailto:" + text;
    }

    return Uri.parse(text);
  }

  // if the url does not have a protocol, we use http
  // e.g. www.example.de -> http://www.example.de, example.de -> http://example.de
  if (!(text.startsWith("http") || text.startsWith("https"))) {
    text = "http://" + text;
  }

  final RegExp webAddressRegEx = RegExp(
      r"((http|https)://)?(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&/=]*)");

  final RegExpMatch? match = webAddressRegEx.firstMatch(text);
  if (match != null && match.start == 0 && match.end == text.length) {
    return Uri.parse(text);
  }

  return null;
}

Future<bool> launchUrlInBrowser(String url) async {
  Uri? webUri = extractWebAddress(url);

  if (webUri == null) {
    return false;
  }

  if (await canLaunchUrl(webUri)) {
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  } else {
    print("Could not launch ${webUri.toString()}");
    return false;
  }

  return true;
}

List<String?> extractAllPhoneNumbers(String text) {
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

  return phoneNumberRegex
      .allMatches(text)
      .map((regExpMatch) => regExpMatch.group(0))
      .toList();
}

String? extractPhoneNumber(String text) {
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

  final RegExpMatch? match = phoneNumberRegex.firstMatch(text);
  if (match != null && match.start != -1 && match.end != -1) {
    return text.substring(match.start, match.end);
  }

  return null;
}

/// open the telephone app with the extracted phone number
/// returns true if it was successful and
/// false if there is no valid telephone number to launch
Future<bool> makePhoneCall(String url) async {
  String? phoneNumber = extractPhoneNumber(url);

  if (phoneNumber == null) {
    return false;
  }

  Uri uri = Uri.parse("tel:$phoneNumber");
  print("Extracted phone number: $phoneNumber");
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
    return true;
  } else {
    throw "Could not launch ${uri.toString()}";
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
