import 'package:flutter_test/flutter_test.dart';
import 'package:foss_warn/class/class_Area.dart';
import 'package:foss_warn/class/class_Geocode.dart';
import 'package:foss_warn/class/class_WarnMessage.dart';
import 'package:foss_warn/enums/Certainty.dart';
import 'package:foss_warn/enums/Severity.dart';
import 'package:foss_warn/enums/WarningSource.dart';
import 'package:foss_warn/views/WarningDetailView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  String contactFieldText = "Test +49 123 567 call";
  String contactFieldExpectedText = "Test +49123567 call";

  testWidget("Simple text + telephone number test", contactFieldText,
      contactFieldExpectedText);

  String contactFieldText_2 = "Test +49 123 567 call +49987 6543 hello world";
  String contactFieldExpectedText_2 =
      "Test +49123567 call +499876543 hello world";

  testWidget("Simple text + 2 telephone number test", contactFieldText_2,
      contactFieldExpectedText_2);

  String contactFieldText_3 =
      "contact us: Hauptstraße 35 62394 or per telephone 627351514";
  String contactFieldExpectedText_3 =
      "contact us: Hauptstraße 3562394 or per telephone 627351514";

  testWidget("text with PLZ and address + telephone number test",
      contactFieldText_3, contactFieldExpectedText_3);

  String contactFieldText_4 =
      "contact us: Hauptstraße 35 62394 or per telephone 627351514 or 62778-51-514";
  String contactFieldExpectedText_4 =
      "contact us: Hauptstraße 3562394 or per telephone 627351514 or 6277851514";

  testWidget("text with PLZ and address + 2 telephone number test",
      contactFieldText_4, contactFieldExpectedText_4);

  String contactFieldText_5 =
      "contact us: Hauptstraße 35 62394 or per telephone 35-62394";
  String contactFieldExpectedText_5 =
      "contact us: Hauptstraße 3562394 or per telephone 3562394";

  testWidget("text with PLZ and address + telephone number identically to the PLZ test",
      contactFieldText_4, contactFieldExpectedText_4);
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
        )
    ),
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
      status: "testing",
      messageType: "dummy",
      scope: "dummy",
      category: "dummy",
      event: "dummy",
      urgency: "dummy",
      severity: Severity.minor,
      certainty: Certainty.other,
      headline: "FOSS Warn dummy alert",
      description: "dummy description",
      instruction: "dummy instruction",
      areaList: [
        Area(
            areaDesc: "123",
            geocodeList: [Geocode(geocodeName: "123", geocodeNumber: "123")]),
      ],
      contact: contact,
      notified: false,
      read: false);
}
