import 'package:foss_warn/views/SettingsView.dart';
import 'package:http/http.dart';
import 'dart:convert';

Future<String> checkForUpdates() async {
  Response _response; //response var for get request
  var data; //var for response data
  print("Check for updates");
  try {
    var latestGithubReleaseUrl = Uri.parse(
        'https://api.github.com/repos/nucleus-ffm/foss_warn/releases/latest');
    _response = await get(latestGithubReleaseUrl);
    //print("Response status: " + response.statusCode.toString());
    //check response code 200 -> success
    if (_response.statusCode == 200) {
      data = jsonDecode(utf8.decode(_response.bodyBytes));
      print(data['tag_name']);

      // Github version
      int firstDotGithub = data['tag_name'].toString().indexOf(".");
      int secondDotGithub =
          data['tag_name'].toString().indexOf(".", firstDotGithub + 1);

      int majorReleaseVersionGithub =
          int.parse(data['tag_name'].toString().substring(0, firstDotGithub));
      int minorReleaseVersionGithub = int.parse(data['tag_name']
          .toString()
          .substring(firstDotGithub + 1, secondDotGithub));
      int patchLevelGithub = int.parse(data['tag_name']
          .toString()
          .substring(secondDotGithub + 1, data['tag_name'].toString().length));

      //installed version
      int firstDot = versionNumber.indexOf(".");
      int secondDot = versionNumber.indexOf(".", firstDot + 1);

      int majorReleaseVersion = int.parse(versionNumber.substring(0, firstDot));
      int minorReleaseVersion =
          int.parse(versionNumber.substring(firstDot + 1, secondDot));
      int patchLevel = int.parse(
          versionNumber.substring(secondDot + 1, versionNumber.length));

      // store github version number for later
      githubVersionNumber = data['tag_name'];

      if (data['tag_name'] == versionNumber) {
        print("latest version installed $versionNumber -> ${data['tag_name']}");
        return "latest version installed";
      } else if (majorReleaseVersionGithub > majorReleaseVersion) {
        //new major Release
        print(
            "new major Release available $versionNumber -> ${data['tag_name']}");
        return "new major Release available";
      } else if (majorReleaseVersionGithub < majorReleaseVersion) {
        print("you have an newer version then the latest on Github");
        return "something else";
      } else if (minorReleaseVersionGithub > minorReleaseVersion) {
        // new minor Release
        print(
            "new minor Releaseavailable $versionNumber -> ${data['tag_name']}");
        return "new minor Release available";
      } else if (minorReleaseVersionGithub < minorReleaseVersion) {
        // new minor Release
        print("you have an newer version then the latest on Github");
        return "something else";
      } else if (patchLevelGithub > patchLevel) {
        // new patchLevel version
        print(
            "new patchLevel Release available $versionNumber -> ${data['tag_name']}");
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
