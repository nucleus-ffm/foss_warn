import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_notification_service.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/services/warnings.dart';
import 'package:foss_warn/widgets/map_widget.dart';
import 'package:latlong2/latlong.dart';
import '../class/class_area.dart';
import '../enums/severity.dart';
import '../main.dart';
import '../services/url_launcher.dart';
import '../services/translate_and_colorize_warning.dart';

import 'package:share_plus/share_plus.dart';

import '../widgets/dialogs/warning_severity_explanation.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final String warningIdentifier;

  const DetailScreen({
    required this.warningIdentifier,
    super.key,
  });

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  bool _showMoreRegions = false;
  final MapController mapController = MapController();

  // @todo think about moving code to better place
  String replaceHTMLTags(String text) {
    String replacedText = text;
    replacedText = replacedText.replaceAll("<br/>", "\n");
    replacedText = replacedText.replaceAll("<br>", "\n");
    replacedText = replacedText.replaceAll("br>", "\n");
    replacedText = replacedText.replaceAll("&nbsp;", " ");

    return replacedText;
  }

  /// generate a TextSpan with tappable telephone numbers
  List<TextSpan> generateContactBody(String text) {
    List<TextSpan> result = [];
    List<String?> allPhoneNumbers = extractAllPhoneNumbers(text);

    if (allPhoneNumbers.isEmpty) {
      result.add(TextSpan(text: text));
      return result;
    }

    int pointer = 0;
    for (String? phoneNumber in allPhoneNumbers) {
      if (phoneNumber == null) {
        continue;
      }

      int startPos = text.indexOf(phoneNumber, pointer);
      if (startPos == -1) {
        continue;
      }

      int endPos = startPos + phoneNumber.length;

      // add the text before the telephone number to a TextSpan
      result.add(TextSpan(text: text.substring(pointer, startPos)));
      // add the clickable telephone number
      result.add(
        TextSpan(
          text: phoneNumber,
          style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              // print("phone number tapped");
              makePhoneCall(phoneNumber);
            },
        ),
      );
      pointer = endPos;
    }

    // add remaining text after the last telephone number
    if (pointer < text.length) {
      result.add(TextSpan(text: text.substring(pointer, text.length)));
    }

    return result;
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
        debugPrint("we found an <a>");
        // we have an <a> Tag
        endPos = text.indexOf("</a>", pointer) + 4;
        debugPrint("a endet $endPos");
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
          returnList.add(
            TextSpan(
              text: " $urlDescription ",
              style: const TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  debugPrint("Link tapped");
                  launchUrlInBrowser(url);
                },
            ),
          );
          pointer = endPos;
        } else {
          // maybe it is an E-Mail?
          int eMailStart = text.indexOf("mailto", pointer);
          int eMailEnds =
              eMailStart != -1 ? text.indexOf('"', eMailStart + 1) : -1;
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
            returnList.add(
              TextSpan(
                text: " $urlDescription ",
                style: const TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchEmail(url);
                  },
              ),
            );
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
        debugPrint("startPos $startPos");
        if (startPos == -1) {
          returnList.add(
            TextSpan(
              text: text.substring(pointer, text.length),
              /*recognizer: TapGestureRecognizer()
                ..onTap = () {
                  print("text tapped");
                }*/
            ),
          );
          pointer = text.length;
        } else {
          debugPrint("pointer: $pointer  startPos: $startPos");
          returnList.add(
            TextSpan(
              text: text.substring(pointer, startPos),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  debugPrint("text tapped");
                },
            ),
          );
          pointer = startPos - 1;
        }
      }
      pointer++;
    }
    return returnList;
  }

  /// create a camera to fix the polygon to the camera of the map
  Widget _createMapWidget(List<Area> area) {
    var localizations = context.localizations;
    var warning = ref.watch(
      warningsProvider.select(
        (value) => value.firstWhere(
          (element) => element.identifier == widget.warningIdentifier,
        ),
      ),
    );

    CameraFit createInitCameraFit() {
      List<LatLng> polygonPoints =
          Area.getListWithAllPolygons(warning.info.first.area);

      if (polygonPoints.isNotEmpty) {
        return CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(polygonPoints),
          padding: const EdgeInsets.all(30),
        );
      } else {
        return CameraFit.bounds(
          // set the bounds to the north pol if we don't have any points
          bounds: LatLngBounds.fromPoints(
            [const LatLng(90.0, 0.0), const LatLng(89.9, 0.1)],
          ),
          padding: const EdgeInsets.all(30),
        );
      }
    }

    try {
      return SizedBox(
        height: 200,
        child: MapWidget(
          mapController: mapController,
          initialCameraFit: createInitCameraFit(),
          polygonLayers: [
            //@todo can be null
            PolygonLayer(
              polygons:
                  Area.createListOfPolygonsForAreas(warning.info.first.area),
            ),
          ],
          widgets: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  tooltip: localizations
                      .warning_detail_view_map_center_map_button_tooltip,
                  onPressed: () {
                    mapController.fitCamera(createInitCameraFit());
                  },
                  child: const Icon(Icons.center_focus_strong),
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return SizedBox(
        height: 200,
        child: Text("Error - failed to show map: $e"),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var warning = ref.read(warningsProvider).firstWhere(
            (element) => element.identifier == widget.warningIdentifier,
          );
      ref
          .read(warningsProvider.notifier)
          .updateWarning(warning.copyWith(read: true));

      // cancel the notification
      await NotificationService.cancelOneNotification(
        warning.identifier.hashCode,
      );
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var scaffoldMessenger = ScaffoldMessenger.of(context);

    var warning = ref.watch(
      warningsProvider.select(
        (value) => value.firstWhere(
          (element) => element.identifier == widget.warningIdentifier,
        ),
      ),
    );

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
              debugPrint("URL is: $url");
              pointer = endPosition;

              widgetList.add(
                TextButton(
                  onPressed: () {
                    launchUrlInBrowser(url);
                  },
                  style: TextButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text(
                    localizations.warning_open_picture_with_browser,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
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

    List<String> generateAreaDescList(int length) {
      List<String> result = [];
      int counter = 0;
      bool addAll = false;
      if (length == -1) {
        addAll = true;
      }
      for (Area myArea in warning.info[0].area) {
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

    Widget createTagButton(
      Color color,
      String eventType,
      String info, {
      Function()? action,
    }) {
      return Container(
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.all(7),
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
                  "$eventType: $info",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: userPreferences.warningFontSize,
                  ),
                ),
              )
            : Text(
                "$eventType: $info",
                style: TextStyle(
                  color: color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                  fontSize: userPreferences.warningFontSize,
                ),
              ),
      );
    }

    Future<void> shareWarning(
      BuildContext context,
      String shareText,
      String shareSubject,
    ) async {
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(
        shareText,
        subject: shareSubject,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(warning.info[0].headline),
        actions: [
          IconButton(
            //@todo refactor
            tooltip: localizations.warning_share,
            onPressed: () {
              final String shareText =
                  "${warning.info[0].headline}\n\n${localizations.warning_from}: ${formatSentDate(warning.sent)}\n\nContext information: \n${localizations.warning_type}: ${translateWarningType(warning.messageType, context)}\n ${localizations.warning_severity}: ${translateWarningCertainty(warning.info[0].severity.name, context)}\n\n${localizations.warning_region}: ${generateAreaDescList(-1).toString().substring(1, generateAreaDescList(-1).toString().length - 1)}\n\n${localizations.warning_description}:\n${replaceHTMLTags(warning.info[0].description)} \n\n${localizations.warning_recommended_action}:\n${replaceHTMLTags(warning.info[0].instruction ?? "n.a.")}\n\n${localizations.warning_source}:\n${warning.publisher}\n\n-- ${localizations.warning_shared_by_foss_warn} --";
              final String shareSubject = warning.info[0].headline;
              shareWarning(context, shareText, shareSubject);
            },
            icon: const Icon(Icons.share),
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
                warning.info[0].headline,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 10),
              Text(
                "${localizations.warning_from}: ${formatSentDate(warning.sent)}",
                style: TextStyle(
                  fontSize: userPreferences.warningFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              warning.info[0].effective != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 1),
                      child: Text(
                        "${localizations.warning_effective} ${formatSentDate(warning.info[0].effective ?? "n.a.")}",
                        style: TextStyle(
                          fontSize: userPreferences.warningFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const SizedBox(),
              warning.info[0].onset != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 1, bottom: 1),
                      child: Text(
                        "${localizations.warning_onset} ${formatSentDate(warning.info[0].onset ?? "n.a.")}",
                        style: TextStyle(
                          fontSize: userPreferences.warningFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const SizedBox(),
              warning.info[0].expires != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 1, bottom: 1),
                      child: Text(
                        "${localizations.warning_expires} ${formatSentDate(warning.info[0].expires ?? "n.a.")}",
                        style: TextStyle(
                          fontSize: userPreferences.warningFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.tag),
                  const SizedBox(width: 5),
                  Text(
                    localizations.warning_tags,
                    style: TextStyle(
                      fontSize: userPreferences.warningFontSize + 5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Wrap(
                children: [
                  createTagButton(
                    Colors.deepPurple,
                    localizations.warning_event,
                    translateWarningCategory(
                      warning.info[0].event,
                      context,
                    ),
                  ),
                  createTagButton(
                    chooseWarningTypeColor(
                      warning.messageType,
                    ), //@todo besser machen
                    localizations.warning_type,
                    translateWarningType(
                      warning.messageType,
                      context,
                    ),
                  ),
                  createTagButton(
                    Severity.getColorForSeverity(warning.info[0].severity),
                    localizations.warning_severity,
                    Severity.getLocalizationName(
                      warning.info[0].severity,
                      context,
                    ),
                    action: () => const WarningSeverityExplanation(),
                  ),
                  // display more metadata button if enabled in the settings
                  userPreferences.showExtendedMetaData
                      ? Wrap(
                          children: [
                            createTagButton(
                              Colors.green,
                              localizations.warning_urgency,
                              translateWarningUrgency(
                                warning.info[0].urgency.name,
                                context,
                              ),
                            ),
                            createTagButton(
                              Colors.blueGrey,
                              localizations.warning_certainty,
                              translateWarningCertainty(
                                warning.info[0].certainty.name,
                                context,
                              ),
                            ),
                            createTagButton(
                              Colors.amber,
                              localizations.warning_scope,
                              warning.scope.name,
                            ),
                            createTagButton(
                              Colors.lightBlue[200]!,
                              localizations.warning_identifier,
                              warning.identifier,
                            ),
                            createTagButton(
                              Colors.orangeAccent,
                              localizations.warning_sender,
                              warning.sender,
                            ),
                            createTagButton(
                              Colors.tealAccent,
                              localizations.warning_status,
                              translateWarningStatus(
                                warning.status.name,
                                context,
                              ),
                            ),
                            createTagButton(
                              Colors.purpleAccent,
                              "Referenze",
                              warning.references?.identifier.toString() ??
                                  "None",
                            ),
                          ],
                        )
                      : const SizedBox(),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.map),
                  const SizedBox(width: 5),
                  Text(
                    localizations.warning_region,
                    style: TextStyle(
                      fontSize: userPreferences.warningFontSize + 5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              _showMoreRegions
                  ? SelectableText(
                      generateAreaDescList(-1).toString().substring(
                            1,
                            generateAreaDescList(-1).toString().length - 1,
                          ),
                      style: TextStyle(
                        fontSize: userPreferences.warningFontSize,
                      ),
                    )
                  : SelectableText(
                      generateAreaDescList(10).toString().substring(
                            1,
                            generateAreaDescList(10).toString().length - 1,
                          ),
                      style: TextStyle(
                        fontSize: userPreferences.warningFontSize,
                      ),
                    ),
              generateAreaDescList(-1).length > 10
                  ? InkWell(
                      child: _showMoreRegions
                          ? Text(
                              localizations.warning_show_less,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            )
                          : Text(
                              localizations.warning_show_more,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
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
                  : const SizedBox(),
              const SizedBox(height: 20),
              warning.info.first.area.first.geoJson != "{}"
                  ? _createMapWidget(warning.info.first.area)
                  : const SizedBox(),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.description),
                  const SizedBox(width: 5),
                  Text(
                    localizations.warning_description,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: userPreferences.warningFontSize + 5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              SelectableText.rich(
                TextSpan(
                  children:
                      generateDescriptionBody(warning.info[0].description),
                  style: TextStyle(fontSize: userPreferences.warningFontSize),
                ),
              ),
              const SizedBox(height: 5),
              generateAssets(warning.info[0].description).isNotEmpty
                  ? Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.image),
                            const SizedBox(width: 5),
                            Text(
                              "${localizations.warning_appendix}:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: userPreferences.warningFontSize + 5,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 100,
                          child: GridView.count(
                            primary: false,
                            padding: const EdgeInsets.all(5),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            crossAxisCount: 4,
                            children:
                                generateAssets(warning.info[0].description),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
              warning.info[0].instruction != null
                  ? Column(
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.shield_rounded),
                            const SizedBox(width: 5),
                            Text(
                              localizations.warning_recommended_action,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: userPreferences.warningFontSize + 5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : const SizedBox(),
              const SizedBox(height: 2),
              warning.info[0].instruction != null
                  ? SelectableText.rich(
                      TextSpan(
                        children: generateDescriptionBody(
                          warning.info[0].instruction!,
                        ),
                        style: TextStyle(
                          fontSize: userPreferences.warningFontSize,
                        ),
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 5),
                  Text(
                    localizations.warning_source,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: userPreferences.warningFontSize + 5,
                    ),
                  ),
                ],
              ),
              Text(
                warning.publisher,
                style: TextStyle(fontSize: userPreferences.warningFontSize),
              ),
              const SizedBox(height: 20),
              warning.info[0].contact != null
                  ? Row(
                      children: [
                        const Icon(Icons.web),
                        const SizedBox(width: 5),
                        Text(
                          localizations.warning_contact_website,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: userPreferences.warningFontSize + 5,
                          ),
                        ),
                      ],
                    )
                  : warning.info[0].web != ""
                      ? Row(
                          children: [
                            const Icon(Icons.web),
                            const SizedBox(width: 5),
                            Text(
                              "${localizations.warning_website}:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: userPreferences.warningFontSize + 5,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
              const SizedBox(height: 2),
              warning.info[0].contact != null
                  ? Row(
                      children: [
                        const Icon(Icons.perm_contact_cal),
                        const SizedBox(width: 15),
                        Flexible(
                          child: SelectableText.rich(
                            // key used by unit test
                            key: const Key('contactFieldKey'),
                            TextSpan(
                              children: generateContactBody(
                                replaceHTMLTags(warning.info[0].contact!),
                              ),
                              style: TextStyle(
                                fontSize: userPreferences.warningFontSize,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
              warning.info[0].web != null
                  ? Row(
                      children: [
                        const Icon(Icons.open_in_new),
                        const SizedBox(width: 5),
                        Flexible(
                          fit: FlexFit.loose,
                          child: TextButton(
                            onPressed: () async {
                              bool success = await launchUrlInBrowser(
                                warning.info[0].web!,
                              );

                              if (!success) {
                                final snackBar = SnackBar(
                                  content: const Text(
                                    'Kann URL nicht öffnen',
                                    //@todo translate
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  backgroundColor: Colors.red[100],
                                );

                                scaffoldMessenger.showSnackBar(snackBar);
                              }
                            },
                            child: Text(
                              warning.info[0].web!,
                              style: TextStyle(
                                fontSize: userPreferences.warningFontSize,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
