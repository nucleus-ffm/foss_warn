import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../class/class_WarnMessage.dart';
import '../class/class_Area.dart';
import '../class/class_Geocode.dart';
import '../services/urlLauncher.dart';
import '../services/translateAndColorizeWarning.dart';
import '../views/SettingsView.dart';

import 'package:share_plus/share_plus.dart';

class DetailScreen extends StatefulWidget {
  final WarnMessage warnMessage;
  const DetailScreen({Key? key, required this.warnMessage}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool showMoreRegions = false;
  bool showMorePlaces = false;

  // @todo think about moving code to better place
  String replaceHTMLTags(String text) {
    String replacedText = text;
    replacedText = replacedText.replaceAll("<br/>", "\n");
    replacedText = replacedText.replaceAll("<br>", "\n");
    replacedText = replacedText.replaceAll("br>", "\n");
    replacedText = replacedText.replaceAll("&nbsp;", " ");

    return replacedText;
  }

  String generateURL(String url) {
    String correctURL = "";
    if (url.startsWith('http')) {
      correctURL = url;
    } else if (url.startsWith("<a")) {
      int beginURL = url.indexOf("\"") + 1;
      int endURL = url.indexOf("\"", beginURL + 1);
      correctURL = url.substring(beginURL, endURL);
    } else {
      int firstPoint = url.indexOf('.');
      String domain = url.substring(firstPoint + 1, url.length);
      correctURL = 'https://' + domain;
    }
    print("correct URL: " + correctURL);
    return correctURL;
  }

  /// returns the given text as List of TextSpans with clickable links and
  /// and removed/replaced HTML Tags
  List<TextSpan> generateDescriptionBody(String text) {
    text = replaceHTMLTags(text);
    List<TextSpan> returnList = [];
    int pointer = 0;
    int startPos = 0;
    int endPos = 0;
    // replace all tags
    while (pointer < text.length) {
      if (text[pointer] == "<" && text[pointer + 1] == "a") {
        print("we found an <a>");
        // we have an <a> Tag
        endPos = text.indexOf("</a>", pointer) + 4;
        print("a endet $endPos");
        int urlStart = text.indexOf("http", pointer);
        int urlEnds = text.indexOf("\"", urlStart + 1);
        String url = "";
        String urlDescription = "";

        //add url only if there is an url (urlStart != -1)
        if (urlStart != -1 && urlEnds != -1) {
          url = text.substring(urlStart, urlEnds);
          int desStart = text.indexOf(">", urlStart) + 1;
          int desEnd = text.indexOf("<", urlStart + 1);
          if (desEnd == -1) {
            urlDescription = url;
          } else {
            urlDescription = text.substring(desStart, desEnd);
          }

          // generate TextSpan with clickable link
          returnList.add(TextSpan(
              text: " $urlDescription ",
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  print("Link tapped");
                  launchUrlInBrowser(url);
                }));
          pointer = endPos;
        } else {
          // maybe it is an E-Mail?
          int eMailStart = text.indexOf("mailto", pointer);
          int eMailEnds =
              eMailStart != -1 ? text.indexOf('\"', eMailStart + 1) : -1;
          String url = "";
          String urlDescription = "";
          if (eMailStart != -1 && eMailEnds != -1) {
            url = text.substring(eMailStart, eMailEnds);
            int desStart = text.indexOf(">", eMailStart) + 1;
            int desEnd = text.indexOf("<", eMailStart + 1);
            if (desEnd == -1) {
              urlDescription = url;
            } else {
              urlDescription = text.substring(desStart, desEnd);
            }

            // generate TextSpan with clickable link
            returnList.add(TextSpan(
                text: " $urlDescription ",
                style: TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchEmail(url);
                  }));
            pointer = endPos;
          }
        }
        pointer = endPos;
      } else {
        // it is not an <a>
        // search for the next html tag
        int prevStartPos = startPos;
        startPos = text.indexOf("<", pointer);
        if (startPos == prevStartPos) {
          pointer++;
        }
        print("startPos $startPos");
        if (startPos == -1) {
          returnList.add(TextSpan(
              text: text.substring(pointer, text.length),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  print("text tapped");
                }));
          pointer = text.length;
        } else {
          print("pointer: $pointer  startPos: $startPos");
          returnList.add(TextSpan(
              text: text.substring(pointer, startPos),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  print("text tapped");
                }));
          pointer = startPos - 1;
        }
      }
      pointer++;
    }
    return returnList;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// returns a List of Buttons with links to embedded pictures
    List<Widget> generateAssets(String text) {
      List<Widget> widgetList = [];
      bool searching = true;
      int pointer = 0;

      while (searching) {
        int startPosition = text.indexOf("<img", pointer);
        if (startPosition != -1) {
          int beginImgSource = text.indexOf('src="', startPosition);
          if (beginImgSource != -1) {
            int endImgSource = text.indexOf('"', beginImgSource);
            int endPosition = text.indexOf(">", startPosition + 1);

            if (startPosition != -1 &&
                endPosition != -1 &&
                beginImgSource != -1 &&
                endImgSource != -1) {
              String url = text.substring(beginImgSource, endImgSource);
              print("URL is: $url");
              pointer = endPosition;

              widgetList.add(TextButton(
                  onPressed: () {
                    launchUrlInBrowser(url);
                  },
                  child: Text(
                    AppLocalizations.of(context)
                        .warning_open_picture_with_browser,
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(backgroundColor: Colors.blue)));
            } else {
              searching = false;
            }
          } else {
            searching = false;
          }
        } else {
          // there are no more images
          searching = false;
        }
      }
      return widgetList;
    }

    widget.warnMessage.read = true;

    List<String> generateAreaDescList(int length) {
      List<String> tempList = [];
      int counter = 0;
      bool addAll = false;
      if (length == -1) {
        addAll = true;
      }
      for (Area myArea in widget.warnMessage.areaList) {
        if (counter <= length || addAll) {
          tempList.add(myArea.areaDesc);
          counter++;
        } else {
          break;
        }
      }
      return tempList;
    }

    /// returns a list of GeocodeNames
    /// @length -1 = all
    ///
    List<String> generateGeocodeNameList(int length) {
      List<String> tempList = [];
      int counter = 0;
      bool addAll = false;
      if (length == -1) {
        addAll = true;
      }
      for (Area myArea in widget.warnMessage.areaList) {
        for (Geocode myGeocode in myArea.geocodeList) {
          if (counter <= length || addAll) {
            tempList.add(myGeocode.geocodeName);
            counter++;
          } else {
            break;
          }
        }
      }
      return tempList;
    }

    void shareWarning(
        BuildContext context, String shareText, String shareSubject) async {
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(shareText,
          subject: shareSubject,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.warnMessage.headline),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
              tooltip: AppLocalizations.of(context).warning_share,
              onPressed: () {
                final String shareText = widget.warnMessage.headline +
                    "\n\n" +
                    AppLocalizations.of(context).warning_from +
                    ": " +
                    formatSentDate(widget.warnMessage.sent) +
                    "\n\n" +
                    AppLocalizations.of(context).warning_region +
                    ": " +
                    generateAreaDescList(-1).toString().substring(
                        1, generateAreaDescList(-1).toString().length - 1) +
                    "\n\n" +
                    AppLocalizations.of(context).warning_description +
                    ":\n" +
                    replaceHTMLTags(widget.warnMessage.description) +
                    " \n\n" +
                    AppLocalizations.of(context).warning_recommended_action +
                    ":\n" +
                    replaceHTMLTags(widget.warnMessage.instruction) +
                    "\n\n" +
                    AppLocalizations.of(context).warning_source +
                    ":\n" +
                    widget.warnMessage.publisher +
                    "\n\n-- " +
                    AppLocalizations.of(context).warning_shared_by_foss_warn +
                    " --";
                final String shareSubject = widget.warnMessage.headline;
                shareWarning(context, shareText, shareSubject);
              },
              icon: Icon(Icons.share))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.warnMessage.headline,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                AppLocalizations.of(context).warning_from +
                    ": " +
                    formatSentDate(widget.warnMessage.sent),
                style: TextStyle(
                    fontSize: warningFontSize, fontWeight: FontWeight.bold),
              ),
              widget.warnMessage.effective != ""
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 1),
                      child: Text(
                        AppLocalizations.of(context).warning_effective +
                            " " +
                            formatSentDate(widget.warnMessage.effective),
                        style: TextStyle(
                            fontSize: warningFontSize,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  : SizedBox(),
              widget.warnMessage.onset != ""
                  ? Padding(
                      padding: const EdgeInsets.only(top: 1, bottom: 1),
                      child: Text(
                        AppLocalizations.of(context).warning_onset +
                            " " +
                            formatSentDate(widget.warnMessage.onset),
                        style: TextStyle(
                            fontSize: warningFontSize,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  : SizedBox(),
              widget.warnMessage.expires != ""
                  ? Padding(
                      padding: const EdgeInsets.only(top: 1, bottom: 1),
                      child: Text(
                        AppLocalizations.of(context).warning_expires +
                            " " +
                            formatSentDate(widget.warnMessage.expires),
                        style: TextStyle(
                            fontSize: warningFontSize,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  : SizedBox(),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Icon(Icons.tag),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    AppLocalizations.of(context).warning_tags + ":",
                    style: TextStyle(
                        fontSize: warningFontSize + 5,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 2,
              ),
              Wrap(
                children: [
                  Container(
                    margin: EdgeInsets.all(3),
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.deepPurple,
                    ),
                    child: Text(
                      AppLocalizations.of(context).warning_event +
                          ": " +
                          widget.warnMessage.event,
                      style: TextStyle(
                          color: Colors.white, fontSize: warningFontSize),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(3),
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: chooseWarningTypeColor(
                          widget.warnMessage.messageType),
                    ),
                    child: Text(
                      AppLocalizations.of(context).warning_type +
                          ": " +
                          translateWarningType(
                              widget.warnMessage.messageType, context),
                      style: TextStyle(
                          color: Colors.white, fontSize: warningFontSize),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(3),
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: chooseWarningSeverityColor(
                          widget.warnMessage.severity),
                    ),
                    child: Text(
                      AppLocalizations.of(context).warning_severity +
                          ": " +
                          translateWarningSeverity(widget.warnMessage.severity),
                      style: TextStyle(
                          color: Colors.white, fontSize: warningFontSize),
                    ),
                  ),
                  showExtendedMetaData
                      ? Wrap(children: [
                          Container(
                            margin: EdgeInsets.all(3),
                            padding: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.green,
                            ),
                            child: Text(
                              AppLocalizations.of(context).warning_urgency +
                                  ": " +
                                  translateWarningUrgency(
                                      widget.warnMessage.urgency),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: warningFontSize),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            margin: EdgeInsets.all(3),
                            padding: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.blueGrey,
                            ),
                            child: Text(
                              AppLocalizations.of(context).warning_certainty +
                                  ": " +
                                  translateWarningCertainty(
                                      widget.warnMessage.certainty),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: warningFontSize),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            margin: EdgeInsets.all(3),
                            padding: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.amber,
                            ),
                            child: Text(
                              AppLocalizations.of(context).warning_scope +
                                  ": " +
                                  widget.warnMessage.scope,
                              style: TextStyle(fontSize: warningFontSize),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: EdgeInsets.all(3),
                            padding: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.lightBlue[200],
                            ),
                            child: Text(
                              AppLocalizations.of(context).warning_identifier +
                                  ": " +
                                  widget.warnMessage.identifier,
                              style: TextStyle(fontSize: warningFontSize),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            margin: EdgeInsets.all(3),
                            padding: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.orangeAccent,
                            ),
                            child: Text(
                              AppLocalizations.of(context).warning_sender +
                                  ": " +
                                  widget.warnMessage.sender,
                              style: TextStyle(fontSize: warningFontSize),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: EdgeInsets.all(3),
                            padding: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.greenAccent,
                            ),
                            child: Text(
                              AppLocalizations.of(context).warning_status +
                                  ": " +
                                  translateWarningStatus(
                                      widget.warnMessage.status),
                              style: TextStyle(fontSize: warningFontSize),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ])
                      : SizedBox(),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Icon(Icons.map),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    AppLocalizations.of(context).warning_region + ":",
                    style: TextStyle(
                        fontSize: warningFontSize + 5,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 2,
              ),
              showMoreRegions
                  ? SelectableText(
                      generateAreaDescList(-1).toString().substring(
                          1, generateAreaDescList(-1).toString().length - 1),
                      style: TextStyle(
                        fontSize: warningFontSize,
                      ))
                  : SelectableText(
                      generateAreaDescList(10).toString().substring(
                          1, generateAreaDescList(10).toString().length - 1),
                      style: TextStyle(
                        fontSize: warningFontSize,
                      )),
              generateAreaDescList(-1).length > 10
                  ? InkWell(
                      child: showMoreRegions
                          ? Text(
                              AppLocalizations.of(context).warning_show_less,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            )
                          : Text(AppLocalizations.of(context).warning_show_more,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                      onTap: () {
                        setState(
                          () {
                            if (showMoreRegions) {
                              showMoreRegions = false;
                            } else {
                              showMoreRegions = true;
                            }
                          },
                        );
                      },
                    )
                  : SizedBox(),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Icon(Icons.location_city),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    AppLocalizations.of(context).warning_places + ":",
                    style: TextStyle(
                        fontSize: warningFontSize + 5,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 2,
              ),
              showMorePlaces
                  ? SelectableText(
                      generateGeocodeNameList(-1).toString().substring(
                          1, generateGeocodeNameList(-1).toString().length - 1),
                      style: TextStyle(fontSize: warningFontSize),
                    )
                  : SelectableText(
                      generateGeocodeNameList(10).toString().substring(
                          1, generateGeocodeNameList(10).toString().length - 1),
                      style: TextStyle(fontSize: warningFontSize),
                    ),
              generateGeocodeNameList(-1).length > 10
                  ? InkWell(
                      child: showMorePlaces
                          ? Text(
                              AppLocalizations.of(context).warning_show_less,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            )
                          : Text(AppLocalizations.of(context).warning_show_more,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                      onTap: () {
                        setState(() {
                          if (showMorePlaces) {
                            showMorePlaces = false;
                          } else {
                            showMorePlaces = true;
                          }
                        });
                      },
                    )
                  : SizedBox(),
              SizedBox(
                height: 20,
              ),
              Row(children: [
                Icon(Icons.description),
                SizedBox(
                  width: 5,
                ),
                Text(
                  AppLocalizations.of(context).warning_description + ":",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: warningFontSize + 5),
                ),
              ]),
              SizedBox(
                height: 2,
              ),
              SelectableText.rich(
                TextSpan(
                    children:
                        generateDescriptionBody(widget.warnMessage.description),
                    style: TextStyle(fontSize: warningFontSize)),
              ),
              SizedBox(
                height: 5,
              ),
              generateAssets(widget.warnMessage.description).isNotEmpty
                  ? Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.image),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              AppLocalizations.of(context).warning_appendix +
                                  ":",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: warningFontSize + 5),
                            ),
                          ],
                        ),
                        Container(
                          height: 100,
                          child: GridView.count(
                            primary: false,
                            padding: const EdgeInsets.all(5),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            crossAxisCount: 4,
                            children:
                                generateAssets(widget.warnMessage.description),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
              widget.warnMessage.instruction != ""
                  ? Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Icon(Icons.shield_rounded),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              AppLocalizations.of(context)
                                      .warning_recommended_action +
                                  ":",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: warningFontSize + 5),
                            ),
                          ],
                        ),
                      ],
                    )
                  : SizedBox(),
              SizedBox(
                height: 2,
              ),
              widget.warnMessage.instruction != ""
                  ? SelectableText.rich(
                      TextSpan(
                          children: generateDescriptionBody(
                              widget.warnMessage.instruction),
                          style: TextStyle(fontSize: warningFontSize)),
                    )
                  : SizedBox(),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    AppLocalizations.of(context).warning_source + ":",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: warningFontSize + 5),
                  )
                ],
              ),
              Text(
                widget.warnMessage.publisher,
                style: TextStyle(fontSize: warningFontSize),
              ),
              SizedBox(
                height: 20,
              ),
              widget.warnMessage.contact != ""
                  ? Row(
                      children: [
                        Icon(Icons.web),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          AppLocalizations.of(context).warning_contact_website +
                              ":",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: warningFontSize + 5),
                        ),
                      ],
                    )
                  : widget.warnMessage.web != ""
                      ? Row(
                          children: [
                            Icon(Icons.web),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              AppLocalizations.of(context).warning_website +
                                  ":",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: warningFontSize + 5),
                            ),
                          ],
                        )
                      : SizedBox(),
              SizedBox(
                height: 2,
              ),
              widget.warnMessage.contact != ""
                  ? Row(
                      children: [
                        Icon(Icons.call),
                        SizedBox(
                          width: 5,
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: TextButton(
                            onPressed: () =>
                                makePhoneCall(widget.warnMessage.contact),
                            child: Text(
                              replaceHTMLTags(widget.warnMessage.contact),
                              style: TextStyle(
                                  fontSize: warningFontSize,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                        )
                      ],
                    )
                  : SizedBox(),
              widget.warnMessage.web != ""
                  ? Row(
                      children: [
                        Icon(Icons.open_in_new),
                        SizedBox(
                          width: 5,
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: TextButton(
                            onPressed: () =>
                                launchUrlInBrowser(widget.warnMessage.web),
                            child: Text(
                              generateURL(widget.warnMessage.web),
                              style: TextStyle(
                                  fontSize: warningFontSize,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                        )
                      ],
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
