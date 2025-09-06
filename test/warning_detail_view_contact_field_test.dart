import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:foss_warn/class/class_area.dart';
import 'package:foss_warn/class/class_info.dart';
import 'package:foss_warn/class/class_warn_message.dart';
import 'package:foss_warn/enums/certainty.dart';
import 'package:foss_warn/enums/message_type.dart';
import 'package:foss_warn/enums/scope.dart';
import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/enums/category.dart' as cap_category;
import 'package:foss_warn/enums/status.dart';
import 'package:foss_warn/enums/urgency.dart';
import 'package:foss_warn/enums/warning_source.dart';
import 'package:foss_warn/views/warning_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  // Overrides the test client for every test, so network call will work.
  // @todo use mock API calls instead
  setUpAll(() => HttpOverrides.global = null);

  String contactFieldText = "Test +49 123 567 call";
  String contactFieldExpectedText = "Test +49 123 567 call";

  testWidget("Simple text + telephone number test", contactFieldText,
      contactFieldExpectedText);

  String contactFieldText_2 = "Test +49 123 567 call +49987 6543 hello world";
  String contactFieldExpectedText_2 =
      "Test +49 123 567 call +49987 6543 hello world";

  testWidget("Simple text + 2 telephone number test", contactFieldText_2,
      contactFieldExpectedText_2);

  String contactFieldText_3 =
      "contact us: Hauptstraße 35 62394 or per telephone 627351514";
  String contactFieldExpectedText_3 =
      "contact us: Hauptstraße 35 62394 or per telephone 627351514";

  testWidget("text with PLZ and address + telephone number test",
      contactFieldText_3, contactFieldExpectedText_3);

  String contactFieldText_4 =
      "contact us: Hauptstraße 35 62394 or per telephone 627351514 or 62778-51-514";
  String contactFieldExpectedText_4 =
      "contact us: Hauptstraße 35 62394 or per telephone 627351514 or 62778-51-514";

  testWidget("text with PLZ and address + 2 telephone number test",
      contactFieldText_4, contactFieldExpectedText_4);

  String contactFieldText_5 =
      "contact us: Hauptstraße 35 62394 or per telephone 35-62394";
  String contactFieldExpectedText_5 =
      "contact us: Hauptstraße 35 62394 or per telephone 35-62394";

  testWidget(
      "text with PLZ and address + telephone number identically to the PLZ test",
      contactFieldText_5,
      contactFieldExpectedText_5);

  String contactFieldText_6 = "hallo World call\n06152787878";
  String contactFieldExpectedText_6 = "hallo World call\n06152787878";

  testWidget("telephone number with repeating parts test", contactFieldText_6,
      contactFieldExpectedText_6);

  String contactFieldText_7 = "Testcall 0615-298-56 56";
  String contactFieldExpectedText_7 = "Testcall 0615-298-56 56";

  testWidget("telephone number with repeating parts and spaces test",
      contactFieldText_7, contactFieldExpectedText_7);

  String contactFieldText_8 = "Testcall 0615-298-56b";
  String contactFieldExpectedText_8 = "Testcall 0615-298-56b";

  testWidget("telephone number and one char", contactFieldText_8,
      contactFieldExpectedText_8);
}

/// create a widget with localizations (en)
Widget makeTestableWidget({required Widget myWidget}) {
  return MediaQuery(
    data: MediaQueryData(),
    child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Localizations(
          delegates: AppLocalizations.localizationsDelegates,
          locale: Locale('en'),
          child: myWidget,
        )),
  );
}

/// test the DetailScreen widget and check if the contact field is as expected
void testWidget(String testCaseName, String contactFieldText,
    String contactFieldExpectedText) {
  WarnMessage wm = createDummyWarnMessage(contactFieldText);
  Widget testWidget =
      makeTestableWidget(myWidget: DetailScreen(warnMessage: wm));

  testWidgets(testCaseName, (tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();
    // search the contact field in the widget tree
    final contactField = find.byKey(Key("contactFieldKey"));
    expect(contactField, findsOneWidget);

    // find the list of text spans in the widget tree
    List<InlineSpan>? contactTextSpans =
        tester.widget<SelectableText>(contactField).textSpan?.children;

    // concatenate all inline text spans to one string
    String actuallyField = "";
    for (InlineSpan tp in contactTextSpans!) {
      actuallyField += tp.toPlainText();
    }

    // check if field is as expected
    expect(actuallyField, contactFieldExpectedText);
  });
}

/// create a dummy warn message with the given contact text
WarnMessage createDummyWarnMessage(String contact) {
  return WarnMessage(
      identifier: "01",
      publisher: "FOSSWarn",
      source: WarningSource.other,
      sender: "FOSS Warn dummy sender",
      sent: "2023-03-09T11:05:04+01:00",
      info: createDummyInfo(contact),
      status: Status.actual,
      notified: false,
      read: false,
      messageType: MessageType.alert,
      scope: Scope.public);
}

List<Info> createDummyInfo(String contact) {
  return [
    Info(
      category: [cap_category.Category.safety],
      event: "Test Event",
      urgency: Urgency.immediate,
      severity: Severity.extreme,
      certainty: Certainty.observed,
      headline: "Test alert for FOSSWarn",
      description: "This is a test alert for FOSSWarn",
      instruction: "Nothing to do",
      contact: contact,
      area: [
        Area(
          geoJson: '''
                    {
                      "type": "FeatureCollection",
                      "features": [
                        {
                          "type": "Feature",
                          "geometry": {
                            "type": "Polygon",
                            "coordinates": [
                              [
                                [13.4050, 52.5200],
                                [13.4500, 52.5200],
                                [13.4500, 52.5300],
                                [13.4050, 52.5300],
                                [13.4050, 52.5200]
                              ]
                            ]
                          },
                          "properties": {
                            "name": "Dummy Polygon in germany"
                          }
                        }
                      ]
                    }
                    ''',
          areaDesc: "123",
        ),
      ],
    )
  ];
}
