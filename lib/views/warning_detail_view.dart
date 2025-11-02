import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_area.dart';
import 'package:foss_warn/class/class_notification_service.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/class/class_warn_message.dart';
import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/services/translate_and_colorize_warning.dart';
import 'package:foss_warn/services/url_launcher.dart';
import 'package:foss_warn/services/warnings.dart';
import 'package:foss_warn/widgets/dialogs/warning_severity_explanation.dart';
import 'package:foss_warn/widgets/map_widget.dart';
import 'package:latlong2/latlong.dart';

import 'package:share_plus/share_plus.dart';

List<String> _generateAreaDescriptionList({
  required WarnMessage alert,
  required int length,
}) {
  List<String> result = [];
  int counter = 0;
  bool addAll = false;
  if (length == -1) {
    addAll = true;
  }
  for (Area area in alert.info[0].area) {
    List<String> splitDescription = area.description.split(",");
    for (int i = 0; i < splitDescription.length; i++) {
      String areaDescritpion = splitDescription[i];
      if ((counter <= length || addAll) &&
          areaDescritpion != "polygonal event area") {
        result.add(areaDescritpion);
        counter++;
      } else {
        break;
      }
    }
  }
  return result;
}

// @TODO(Nucleus) think about moving code to better place and think about replacing this with something better
String _replaceHTMLTags(String text) {
  String replacedText = text;
  replacedText = replacedText.replaceAll("<br/>", "\n");
  replacedText = replacedText.replaceAll("<br />", "\n");
  replacedText = replacedText.replaceAll("<br>", "\n");
  replacedText = replacedText.replaceAll("br>", "\n");
  replacedText = replacedText.replaceAll("&nbsp;", " ");
  replacedText = replacedText.replaceAll("\\n", "\n");
  replacedText = replacedText.replaceAll("\\\n", " ");
  return replacedText;
}

/// returns the given text as List of TextSpans with clickable links and
/// and removed/replaced HTML Tags
List<TextSpan> _htmlTextToTextSpans(String text) {
  text = _replaceHTMLTags(text);
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

/// returns a List of Buttons with links to embedded pictures
List<Widget> _generateAssets(String text, {required BuildContext context}) {
  var localizations = context.localizations;

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

class DetailScreen extends ConsumerStatefulWidget {
  final String warningIdentifier;
  final String subscriptionId;

  const DetailScreen({
    required this.warningIdentifier,
    required this.subscriptionId,
    super.key,
  });

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var warning = ref.read(processedAlertsProvider).firstWhere(
            (alert) =>
                alert.identifier == widget.warningIdentifier &&
                alert.placeSubscriptionId == widget.subscriptionId,
          );

      // update the read state of the alert
      var alertsService = ref.read(processedAlertsProvider.notifier);
      alertsService.updateAlert(warning.copyWith(read: true));
      ref.invalidate(alertsFutureProvider);

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
    var theme = Theme.of(context);
    var localizations = context.localizations;

    var userPreferences = ref.watch(userPreferencesProvider);

    WarnMessage warning = ref.watch(
      processedAlertsProvider.select(
        (value) => value.firstWhere(
          (element) => element.identifier == widget.warningIdentifier,
        ),
      ),
    );

    List<String> areaDescriptionList = _generateAreaDescriptionList(
      alert: warning,
      length: -1,
    );

    List<Widget> assets = _generateAssets(
      warning.info[0].description,
      context: context,
    );

    Future<void> onSharePressed() async {
      var shareText = warning.info[0].headline;
      shareText +=
          "\n\n${localizations.warning_from(formatSentDate(warning.sent))}";
      shareText += "\n\n${localizations.warning_context_information}";
      shareText +=
          "\n${localizations.warning_type(warning.messageType.getLocalizedName(context))}";
      shareText +=
          "\n${localizations.warning_severity(warning.info[0].severity.getLocalizedName(context))}";
      shareText +=
          "\n\n${localizations.warning_region(areaDescriptionList.toString().substring(1, areaDescriptionList.toString().length - 1))}";
      shareText +=
          "\n\n${localizations.warning_description(_replaceHTMLTags(warning.info[0].description))}";
      shareText +=
          "\n\n${localizations.warning_recommended_action(_replaceHTMLTags(warning.info[0].instruction ?? "n.a."))}";
      shareText += "\n\n${localizations.warning_source(warning.publisher)}";
      shareText += "\n\n-- ${localizations.warning_shared_by_foss_warn} --";
      String shareSubject = warning.info[0].headline;

      var box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          subject: shareSubject,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(warning.info[0].headline),
        actions: [
          IconButton(
            tooltip: localizations.warning_share,
            onPressed: onSharePressed,
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
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: 10),
              Text(
                "${localizations.warning_from_title}: ${formatSentDate(warning.sent)}",
                style: TextStyle(
                  fontSize: userPreferences.warningFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (warning.info[0].effective != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 1),
                  child: Text(
                    "${localizations.warning_effective} ${formatSentDate(warning.info[0].effective ?? "n.a.")}",
                    style: TextStyle(
                      fontSize: userPreferences.warningFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              if (warning.info[0].onset != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 1, bottom: 1),
                  child: Text(
                    "${localizations.warning_onset} ${formatSentDate(warning.info[0].onset ?? "n.a.")}",
                    style: TextStyle(
                      fontSize: userPreferences.warningFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              if (warning.info[0].expires != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 1, bottom: 1),
                  child: Text(
                    "${localizations.warning_expires} ${formatSentDate(warning.info[0].expires ?? "n.a.")}",
                    style: TextStyle(
                      fontSize: userPreferences.warningFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _Tags(alert: warning),
              const SizedBox(height: 20),
              _Region(alert: warning),
              const SizedBox(height: 20),
              if (warning.info.first.area.first.geoJson != "{}") ...[
                _Map(
                  mapController: mapController,
                  alert: warning,
                ),
                const SizedBox(height: 20),
              ],
              _Description(alert: warning),
              if (assets.isNotEmpty) ...[
                const SizedBox(height: 5),
                _WarningAppendix(assets: assets),
              ],
              if (warning.info[0].instruction != null) ...[
                _Instruction(instruction: warning.info[0].instruction!),
              ],
              const SizedBox(height: 20),
              _Source(alert: warning),
              const SizedBox(height: 20),
              if (warning.info[0].contact != null) ...[
                _Contact(alert: warning),
                const SizedBox(height: 20),
              ],
              if (warning.info[0].web != "") ...[
                _Web(alert: warning),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Region extends ConsumerStatefulWidget {
  const _Region({required this.alert});

  final WarnMessage alert;

  @override
  ConsumerState<_Region> createState() => _RegionState();
}

class _RegionState extends ConsumerState<_Region> {
  bool showMore = false;

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;

    var userPreferences = ref.watch(userPreferencesProvider);

    var areaDescriptionList = _generateAreaDescriptionList(
      alert: widget.alert,
      length: -1,
    );

    var regionsString =
        _generateAreaDescriptionList(alert: widget.alert, length: 10)
            .toString()
            .substring(
              1,
              _generateAreaDescriptionList(alert: widget.alert, length: 10)
                      .toString()
                      .length -
                  1,
            );
    if (showMore) {
      regionsString = areaDescriptionList.toString().substring(
            1,
            areaDescriptionList.toString().length - 1,
          );
    }

    void onShowMorePressed() {
      showMore = !showMore;
      setState(() {});
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.map),
            const SizedBox(width: 5),
            Text(
              localizations.warning_region_title,
              style: TextStyle(
                fontSize: userPreferences.warningFontSize + 5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        SelectableText(
          regionsString,
          style: TextStyle(fontSize: userPreferences.warningFontSize),
        ),
        if (areaDescriptionList.length > 10) ...[
          InkWell(
            onTap: onShowMorePressed,
            child: showMore
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
          ),
        ],
      ],
    );
  }
}

class _Tags extends ConsumerWidget {
  const _Tags({required this.alert});

  final WarnMessage alert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var localizations = context.localizations;

    var userPreferences = ref.watch(userPreferencesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            _TagButton(
              color: Colors.deepPurple,
              eventType: localizations.warning_event,
              info: alert.info[0].event,
            ),
            _TagButton(
              color: alert.messageType.color,
              eventType: localizations.warning_type_title,
              info: alert.messageType.getLocalizedName(context),
            ),
            _TagButton(
              color: Severity.getColorForSeverity(alert.info[0].severity),
              eventType: localizations.warning_severity_title,
              info: alert.info[0].severity.getLocalizedName(context),
              action: () => const WarningSeverityExplanation(),
            ),
            // display more metadata button if enabled in the settings
            if (userPreferences.showExtendedMetadata) ...[
              Wrap(
                children: [
                  _TagButton(
                    color: Colors.green,
                    eventType: localizations.warning_urgency,
                    info: alert.info[0].urgency.getLocalizedName(context),
                  ),
                  _TagButton(
                    color: Colors.blueGrey,
                    eventType: localizations.warning_certainty,
                    info: alert.info[0].certainty.getLocalizedName(context),
                  ),
                  _TagButton(
                    color: Colors.amber,
                    eventType: localizations.warning_scope,
                    info: alert.scope.getLocalizedName(context),
                  ),
                  _TagButton(
                    color: Colors.lightBlue[200]!,
                    eventType: localizations.warning_identifier,
                    info: alert.identifier,
                  ),
                  _TagButton(
                    color: Colors.orangeAccent,
                    eventType: localizations.warning_sender,
                    info: alert.sender,
                  ),
                  _TagButton(
                    color: Colors.tealAccent,
                    eventType: localizations.warning_status,
                    info: alert.status.getLocalizedName(context),
                  ),
                  _TagButton(
                    color: Colors.purpleAccent,
                    eventType: "Referenze",
                    info: alert.references?.identifier.toString() ?? "None",
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _TagButton extends ConsumerWidget {
  const _TagButton({
    required this.color,
    required this.eventType,
    required this.info,
    this.action,
  });

  final Color color;
  final Widget Function()? action;
  final String eventType;
  final String info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var userPreferences = ref.watch(userPreferencesProvider);

    Future<void> onPressed() async {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return action!();
        },
      );
    }

    Widget body = Text(
      "$eventType: $info",
      style: TextStyle(
        color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
        fontSize: userPreferences.warningFontSize,
      ),
    );

    if (action != null) {
      body = InkWell(
        onTap: onPressed,
        child: Text(
          "$eventType: $info",
          style: TextStyle(
            color: Colors.white,
            fontSize: userPreferences.warningFontSize,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(3),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
      child: body,
    );
  }
}

class _Map extends StatelessWidget {
  const _Map({
    required this.mapController,
    required this.alert,
  });

  final MapController mapController;
  final WarnMessage alert;

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;

    CameraFit createInitCameraFit() {
      List<LatLng> polygonPoints =
          Area.getListWithAllPolygons(alert.info.first.area);

      if (polygonPoints.isNotEmpty) {
        return CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(polygonPoints),
          padding: const EdgeInsets.all(30),
        );
      } else {
        return CameraFit.bounds(
          // set the bounds to the northpol if we don't have any points
          bounds: LatLngBounds.fromPoints([const LatLng(90.0, 0.0)]),
          padding: const EdgeInsets.all(30),
        );
      }
    }

    return SizedBox(
      height: 200,
      child: MapWidget(
        mapController: mapController,
        initialCameraFit: createInitCameraFit(),
        polygonLayers: [
          //@todo can be null
          PolygonLayer(
            polygons: Area.createListOfPolygonsForAreas(alert.info.first.area),
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
  }
}

class _Description extends ConsumerWidget {
  const _Description({required this.alert});

  final WarnMessage alert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var localizations = context.localizations;

    var userPreferences = ref.watch(userPreferencesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.description),
            const SizedBox(width: 5),
            Text(
              localizations.warning_description_title,
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
            children: _htmlTextToTextSpans(alert.info[0].description),
            style: TextStyle(fontSize: userPreferences.warningFontSize),
          ),
        ),
      ],
    );
  }
}

class _WarningAppendix extends ConsumerWidget {
  const _WarningAppendix({required this.assets});

  final List<Widget> assets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var localizations = context.localizations;

    var userPreferences = ref.watch(userPreferencesProvider);

    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.image),
            const SizedBox(width: 5),
            Text(
              localizations.warning_appendix,
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
            children: assets,
          ),
        ),
      ],
    );
  }
}

class _Instruction extends ConsumerWidget {
  const _Instruction({required this.instruction});

  final String instruction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var localizations = context.localizations;

    var userPreferences = ref.watch(userPreferencesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.shield_rounded),
                const SizedBox(width: 5),
                Text(
                  localizations.warning_recommended_action_title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: userPreferences.warningFontSize + 5,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 2),
        SelectableText.rich(
          TextSpan(
            children: _htmlTextToTextSpans(instruction),
            style: TextStyle(
              fontSize: userPreferences.warningFontSize,
            ),
          ),
        ),
      ],
    );
  }
}

class _Source extends ConsumerWidget {
  const _Source({required this.alert});

  final WarnMessage alert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var localizations = context.localizations;

    var userPreferences = ref.watch(userPreferencesProvider);

    var publisher = alert.publisher.isNotEmpty
        ? alert.publisher
        : localizations.alert_publisher_unknown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 5),
            Text(
              localizations.warning_source_title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: userPreferences.warningFontSize + 5,
              ),
            ),
          ],
        ),
        Text(
          publisher,
          style: TextStyle(fontSize: userPreferences.warningFontSize),
        ),
      ],
    );
  }
}

class _Contact extends ConsumerWidget {
  const _Contact({required this.alert});

  final WarnMessage alert;

  /// generate a TextSpan with tappable telephone numbers
  List<TextSpan> _generateContactBody(
    String text, {
    required BuildContext context,
  }) {
    var theme = Theme.of(context);

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
          style: TextStyle(color: theme.colorScheme.tertiary),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var localizations = context.localizations;

    var userPreferences = ref.watch(userPreferencesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.web),
            const SizedBox(width: 5),
            Text(
              localizations.warning_contact,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: userPreferences.warningFontSize + 5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.perm_contact_cal),
            const SizedBox(width: 15),
            Flexible(
              child: SelectableText.rich(
                // key used by unit test
                key: const Key('contactFieldKey'),
                TextSpan(
                  children: _generateContactBody(
                    _replaceHTMLTags(alert.info[0].contact!),
                    context: context,
                  ),
                  style: TextStyle(
                    fontSize: userPreferences.warningFontSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Web extends ConsumerWidget {
  const _Web({required this.alert});

  final WarnMessage alert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var scaffoldMessenger = ScaffoldMessenger.of(context);
    var localizations = context.localizations;

    var userPreferences = ref.watch(userPreferencesProvider);

    Future<void> onPressed() async {
      bool success = await launchUrlInBrowser(alert.info[0].web!);

      if (!success) {
        final snackBar = SnackBar(
          content: Text(
            localizations.failed_to_open_url,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.red[100],
        );

        scaffoldMessenger.showSnackBar(snackBar);
      }
    }

    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.web),
            const SizedBox(width: 5),
            Text(
              localizations.warning_website,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: userPreferences.warningFontSize + 5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.open_in_new),
            const SizedBox(width: 5),
            Flexible(
              fit: FlexFit.loose,
              child: TextButton(
                onPressed: onPressed,
                child: Text(
                  alert.info[0].web!,
                  style: TextStyle(
                    fontSize: userPreferences.warningFontSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
