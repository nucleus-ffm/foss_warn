import 'package:http/http.dart';
import 'dart:convert';

import '../main.dart';

Future<String> checkForUpdates() async {
  Response _response; //response var for get request
  var _data; //var for response data
  print("Check for updates");
  try {
    var latestGithubReleaseUrl = Uri.parse(
        'https://api.github.com/repos/nucleus-ffm/foss_warn/releases/latest');
    _response = await get(latestGithubReleaseUrl);
    //print("Response status: " + response.statusCode.toString());
    //check response code 200 -> success
    if (_response.statusCode == 200) {
      _data = jsonDecode(utf8.decode(_response.bodyBytes));
      print(_data['tag_name']);

      // Github version
      int firstDotGithub = _data['tag_name'].toString().indexOf(".");
      int secondDotGithub =
          _data['tag_name'].toString().indexOf(".", firstDotGithub + 1);

      int majorReleaseVersionGithub =
          int.parse(_data['tag_name'].toString().substring(0, firstDotGithub));
      int minorReleaseVersionGithub = int.parse(_data['tag_name']
          .toString()
          .substring(firstDotGithub + 1, secondDotGithub));
      int patchLevelGithub = int.parse(_data['tag_name']
          .toString()
          .substring(secondDotGithub + 1, _data['tag_name'].toString().length));

      //installed version
      int firstDot = userPreferences.versionNumber.indexOf(".");
      int secondDot = userPreferences.versionNumber.indexOf(".", firstDot + 1);

      int majorReleaseVersion = int.parse(userPreferences.versionNumber.substring(0, firstDot));
      int minorReleaseVersion =
          int.parse(userPreferences.versionNumber.substring(firstDot + 1, secondDot));
      int patchLevel = int.parse(
          userPreferences.versionNumber.substring(secondDot + 1, userPreferences.versionNumber.length));

      // store github version number for later
      // userPreferences.githubVersionNumber = data['tag_name'];

      if (_data['tag_name'] == userPreferences.versionNumber) {
        print("latest version installed ${userPreferences.versionNumber} -> ${_data['tag_name']}");
        return "latest version installed";
      } else if (majorReleaseVersionGithub > majorReleaseVersion) {
        //new major Release
        print(
            "new major Release available ${userPreferences.versionNumber} -> ${_data['tag_name']}");
        return "new major Release available";
      } else if (majorReleaseVersionGithub < majorReleaseVersion) {
        print("you have an newer version then the latest on Github");
        return "something else";
      } else if (minorReleaseVersionGithub > minorReleaseVersion) {
        // new minor Release
        print(
            "new minor Releaseavailable ${userPreferences.versionNumber} -> ${_data['tag_name']}");
        return "new minor Release available";
      } else if (minorReleaseVersionGithub < minorReleaseVersion) {
        // new minor Release
        print("you have an newer version then the latest on Github");
        return "something else";
      } else if (patchLevelGithub > patchLevel) {
        // new patchLevel version
        print(
            "new patchLevel Release available ${userPreferences.versionNumber} -> ${_data['tag_name']}");
        return "new patchLevel Release available";
      } else {
        print("you have an newer version then the latest on Github");
        return "something else";
      }
    }
    return "Error - server not reachable";
  } catch (e) {
    print("Error while checking for updates: " + e.toString());
    return "Error - server not reachable";
  }
}
