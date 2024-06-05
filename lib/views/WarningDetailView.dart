import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:foss_warn/class/class_NinaPlace.dart';
import 'package:foss_warn/class/class_NotificationService.dart';
import 'package:foss_warn/widgets/MapWidget.dart';
import 'package:latlong2/latlong.dart';
import '../class/abstract_Place.dart';
import '../class/class_WarnMessage.dart';
import '../class/class_Area.dart';
import '../enums/Severity.dart';
import '../main.dart';
import '../services/saveAndLoadSharedPreferences.dart';
import '../services/urlLauncher.dart';
import '../services/translateAndColorizeWarning.dart';

import 'package:share_plus/share_plus.dart';

import '../widgets/dialogs/WarningSeverityExplanation.dart';

class DetailScreen extends StatefulWidget {
  final WarnMessage _warnMessage;
  Place? _place;
  DetailScreen({Key? key, required WarnMessage warnMessage, Place? place})
      : _warnMessage = warnMessage,
        _place = place,
        super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _showMoreRegions = false;
  bool _showMorePlaces = false;

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

        // add url only if there is an url (urlStart != -1)
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

  /// extract hex color value from string and return Color widget
  /// accepts colors in format `#FB8C00`
  /*
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "90" + hexColor;
    } else {
      hexColor = "A0" + "FB8C00";
    }
    return Color(int.parse(hexColor, radix: 16));
  }
  */

  LatLng? _calculatePlaceMarker() {
    if (widget._place != null) {
      if (widget._place is NinaPlace) {
        NinaPlace ninaPlace = widget._place as NinaPlace;
        return ninaPlace.geocode.latLng;
      }
    }
    return null;
  }

  /// create a camera to fix the polygon to the camera of the map
  Widget _createMapWidget(List<Area> area) {
    final MapController mapController = MapController();

    CameraFit createInitCameraFit() {
      List<LatLng> polygonPoints =
          widget._warnMessage.info.first.area.first.getListWithAllPolygons();

      return CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(polygonPoints),
          padding: EdgeInsets.all(30));
    }

    return Container(
        height: 200,
        child: MapWidget(
          mapController: mapController,
          initialCameraFit: createInitCameraFit(),
          polygonLayers: [
            PolygonLayer(
                polygons: MapWidget.createAllPolygons(
                    widget._warnMessage.info.first.area)),
          ],
          markerLayers: _calculatePlaceMarker() != null
              ? [
                  MarkerLayer(markers: [
                    Marker(
                        point: _calculatePlaceMarker()!,
                        child: Icon(
                          Icons.place,
                          size: 40,
                        ))
                  ])
                ]
              : [],
          widgets: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  tooltip: "center map", //@todo translate
                  onPressed: () {
                    mapController.fitCamera(createInitCameraFit());
                  },
                  child: Icon(Icons.center_focus_strong),
                ),
              ),
            )
          ],
        ));
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
                    AppLocalizations.of(context)!
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

    setState(() {
      widget._warnMessage.read = true;
    });
    // save places List to store new read state
    saveMyPlacesList();
    // cancel the notification
    NotificationService.cancelOneNotification(
        widget._warnMessage.identifier.hashCode);

    /// returns a list of the first @length element of the region
    /// returns the entire list for length = -1
    List<String> generateAreaDescList(int length) {
      List<String> result = [];
      int counter = 0;
      bool addAll = false;
      if (length == -1) {
        addAll = true;
      }
      for (Area myArea in widget._warnMessage.info[0].area) {
        List<String> splitDescription = myArea.description.split(",");
        for (int i = 0; i < splitDescription.length; i++) {
          if (counter <= length || addAll) {
            result.add(splitDescription[i]);
            counter++;
          } else {
            break;
          }
        }
      }
      return result;
    }

    Widget createTagButton(Color color, String eventType, String info,
        {Function()? action = null}) {
      return Container(
        margin: EdgeInsets.all(3),
        padding: EdgeInsets.all(7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color,
        ),
        child: action != null
            ? InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return action();
                    },
                  );
                },
                child: Text(
                  eventType + ": " + info,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: userPreferences.warningFontSize),
                ),
              )
            : Text(
                eventType + ": " + info,
                style: TextStyle(
                  color: color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                  fontSize: userPreferences.warningFontSize,
                ),
              ),
      );
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
        title: Text(widget._warnMessage.info[0].headline),
        actions: [
          IconButton(
            //@todo refactor
            tooltip: AppLocalizations.of(context)!.warning_share,
            onPressed: () {
              final String shareText = widget._warnMessage.info[0].headline +
                  "\n\n" +
                  AppLocalizations.of(context)!.warning_from +
                  ": " +
                  formatSentDate(widget._warnMessage.sent) +
                  "\n\n" +
                  "Context information: \n" +
                  AppLocalizations.of(context)!.warning_type +
                  ": " +
                  translateWarningType(
                      widget._warnMessage.messageType.name, context) +
                  "\n " +
                  AppLocalizations.of(context)!.warning_severity +
                  ": " +
                  translateWarningCertainty(
                      widget._warnMessage.info[0].severity.name) +
                  "\n\n" +
                  AppLocalizations.of(context)!.warning_region +
                  ": " +
                  generateAreaDescList(-1).toString().substring(
                      1, generateAreaDescList(-1).toString().length - 1) +
                  "\n\n" +
                  AppLocalizations.of(context)!.warning_description +
                  ":\n" +
                  replaceHTMLTags(widget._warnMessage.info[0].description) +
                  " \n\n" +
                  AppLocalizations.of(context)!.warning_recommended_action +
                  ":\n" +
                  replaceHTMLTags(
                      widget._warnMessage.info[0].instruction ?? "n.a.") +
                  "\n\n" +
                  AppLocalizations.of(context)!.warning_source +
                  ":\n" +
                  widget._warnMessage.publisher +
                  "\n\n-- " +
                  AppLocalizations.of(context)!.warning_shared_by_foss_warn +
                  " --";
              final String shareSubject = widget._warnMessage.info[0].headline;
              shareWarning(context, shareText, shareSubject);
            },
            icon: Icon(Icons.share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget._warnMessage.info[0].headline,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                AppLocalizations.of(context)!.warning_from +
                    ": " +
                    formatSentDate(widget._warnMessage.sent),
                style: TextStyle(
                    fontSize: userPreferences.warningFontSize,
                    fontWeight: FontWeight.bold),
              ),
              widget._warnMessage.info[0].effective != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 1),
                      child: Text(
                        AppLocalizations.of(context)!.warning_effective +
                            " " +
                            formatSentDate(
                                widget._warnMessage.info[0].effective ??
                                    "n.a."),
                        style: TextStyle(
                            fontSize: userPreferences.warningFontSize,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  : SizedBox(),
              widget._warnMessage.info[0].onset != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 1, bottom: 1),
                      child: Text(
                        AppLocalizations.of(context)!.warning_onset +
                            " " +
                            formatSentDate(
                                widget._warnMessage.info[0].onset ?? "n.a."),
                        style: TextStyle(
                            fontSize: userPreferences.warningFontSize,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  : SizedBox(),
              widget._warnMessage.info[0].expires != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 1, bottom: 1),
                      child: Text(
                        AppLocalizations.of(context)!.warning_expires +
                            " " +
                            formatSentDate(
                                widget._warnMessage.info[0].expires ?? "n.a."),
                        style: TextStyle(
                            fontSize: userPreferences.warningFontSize,
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
                    AppLocalizations.of(context)!.warning_tags,
                    style: TextStyle(
                        fontSize: userPreferences.warningFontSize + 5,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 2,
              ),
              Wrap(
                children: [
                  createTagButton(
                      Colors.deepPurple,
                      AppLocalizations.of(context)!.warning_event,
                      translateWarningCategory(
                          widget._warnMessage.info[0].event, context)),
                  createTagButton(
                      chooseWarningTypeColor(widget
                          ._warnMessage.messageType.name), //@todo besser machen
                      AppLocalizations.of(context)!.warning_type,
                      translateWarningType(
                          widget._warnMessage.messageType.name, context)),
                  createTagButton(
                      Severity.getColorForSeverity(
                          widget._warnMessage.info[0].severity),
                      AppLocalizations.of(context)!.warning_severity,
                      Severity.getLocalizationName(
                          widget._warnMessage.info[0].severity, context),
                      action: () => WarningSeverityExplanation()),
                  // display more metadata button if enabled in the settings
                  userPreferences.showExtendedMetaData
                      ? Wrap(children: [
                          createTagButton(
                              Colors.green,
                              AppLocalizations.of(context)!.warning_urgency,
                              translateWarningUrgency(
                                  widget._warnMessage.info[0].urgency.name)),
                          createTagButton(
                              Colors.blueGrey,
                              AppLocalizations.of(context)!.warning_certainty,
                              translateWarningCertainty(
                                  widget._warnMessage.info[0].certainty.name)),
                          createTagButton(
                              Colors.amber,
                              AppLocalizations.of(context)!.warning_scope,
                              widget._warnMessage.scope.name),
                          createTagButton(
                              Colors.lightBlue[200]!,
                              AppLocalizations.of(context)!.warning_identifier,
                              widget._warnMessage.identifier),
                          createTagButton(
                              Colors.orangeAccent,
                              AppLocalizations.of(context)!.warning_sender,
                              widget._warnMessage.sender),
                          createTagButton(
                              Colors.tealAccent,
                              AppLocalizations.of(context)!.warning_status,
                              translateWarningStatus(
                                  widget._warnMessage.status.name)),
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
                    AppLocalizations.of(context)!.warning_region,
                    style: TextStyle(
                        fontSize: userPreferences.warningFontSize + 5,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 2,
              ),
              _showMoreRegions
                  ? SelectableText(
                      generateAreaDescList(-1).toString().substring(
                          1, generateAreaDescList(-1).toString().length - 1),
                      style: TextStyle(
                        fontSize: userPreferences.warningFontSize,
                      ))
                  : SelectableText(
                      generateAreaDescList(10).toString().substring(
                          1, generateAreaDescList(10).toString().length - 1),
                      style: TextStyle(
                        fontSize: userPreferences.warningFontSize,
                      )),
              generateAreaDescList(-1).length > 10
                  ? InkWell(
                      child: _showMoreRegions
                          ? Text(
                              AppLocalizations.of(context)!.warning_show_less,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            )
                          : Text(
                              AppLocalizations.of(context)!.warning_show_more,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                      onTap: () {
                        setState(
                          () {
                            if (_showMoreRegions) {
                              _showMoreRegions = false;
                            } else {
                              _showMoreRegions = true;
                            }
                          },
                        );
                      },
                    )
                  : SizedBox(),
              SizedBox(
                height: 20,
              ),
              _createMapWidget(widget._warnMessage.info.first.area),
              SizedBox(
                height: 20,
              ),
              Row(children: [
                Icon(Icons.description),
                SizedBox(
                  width: 5,
                ),
                Text(
                  AppLocalizations.of(context)!.warning_description,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: userPreferences.warningFontSize + 5),
                ),
              ]),
              SizedBox(
                height: 2,
              ),
              SelectableText.rich(
                TextSpan(
                    children: generateDescriptionBody(
                        widget._warnMessage.info[0].description),
                    style:
                        TextStyle(fontSize: userPreferences.warningFontSize)),
              ),
              SizedBox(
                height: 5,
              ),
              generateAssets(widget._warnMessage.info[0].description).isNotEmpty
                  ? Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.image),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              AppLocalizations.of(context)!.warning_appendix +
                                  ":",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      userPreferences.warningFontSize + 5),
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
                            children: generateAssets(
                                widget._warnMessage.info[0].description),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
              widget._warnMessage.info[0].instruction != null
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
                              AppLocalizations.of(context)!
                                  .warning_recommended_action,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      userPreferences.warningFontSize + 5),
                            ),
                          ],
                        ),
                      ],
                    )
                  : SizedBox(),
              SizedBox(
                height: 2,
              ),
              widget._warnMessage.info[0].instruction != null
                  ? SelectableText.rich(
                      TextSpan(
                          children: generateDescriptionBody(
                              widget._warnMessage.info[0].instruction!),
                          style: TextStyle(
                              fontSize: userPreferences.warningFontSize)),
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
                    AppLocalizations.of(context)!.warning_source,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: userPreferences.warningFontSize + 5),
                  )
                ],
              ),
              Text(
                widget._warnMessage.publisher,
                style: TextStyle(fontSize: userPreferences.warningFontSize),
              ),
              SizedBox(
                height: 20,
              ),
              widget._warnMessage.info[0].contact != null
                  ? Row(
                      children: [
                        Icon(Icons.web),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          AppLocalizations.of(context)!.warning_contact_website,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: userPreferences.warningFontSize + 5),
                        ),
                      ],
                    )
                  : widget._warnMessage.info[0].web != ""
                      ? Row(
                          children: [
                            Icon(Icons.web),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              AppLocalizations.of(context)!.warning_website +
                                  ":",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      userPreferences.warningFontSize + 5),
                            ),
                          ],
                        )
                      : SizedBox(),
              SizedBox(
                height: 2,
              ),
              widget._warnMessage.info[0].contact != null
                  ? Row(
                      children: [
                        Icon(Icons.call),
                        SizedBox(
                          width: 5,
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: TextButton(
                            onPressed: () => makePhoneCall(
                                widget._warnMessage.info[0].contact!),
                            child: Text(
                              replaceHTMLTags(
                                  widget._warnMessage.info[0].contact!),
                              style: TextStyle(
                                  fontSize: userPreferences.warningFontSize),
                            ),
                          ),
                        )
                      ],
                    )
                  : SizedBox(),
              widget._warnMessage.info[0].web != null
                  ? Row(
                      children: [
                        Icon(Icons.open_in_new),
                        SizedBox(
                          width: 5,
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: TextButton(
                            onPressed: () => launchUrlInBrowser(
                                widget._warnMessage.info[0].web!),
                            child: Text(
                              generateURL(widget._warnMessage.info[0].web!),
                              style: TextStyle(
                                  fontSize: userPreferences.warningFontSize),
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
