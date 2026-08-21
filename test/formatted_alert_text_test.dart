import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/l10n/app_localizations.dart';
import 'package:foss_warn/widgets/formatted_alert_text.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'helpers/alert_text_fixtures.dart';

Future<void> pumpAlertText(WidgetTester tester, String text) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(child: FormattedAlertText(text: text)),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// All spans of the rendered text, together with their style.
List<TextSpan> renderedSpans(WidgetTester tester) {
  final List<TextSpan> spans = [];

  for (final SelectableText widget
      in tester.widgetList<SelectableText>(find.byType(SelectableText))) {
    widget.textSpan?.visitChildren((span) {
      if (span is TextSpan && span.text != null) spans.add(span);
      return true;
    });
  }

  return spans;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    await SharedPreferencesState.initialize();
  });

  testWidgets('renders the text of an HTML description without markup',
      (tester) async {
    await pumpAlertText(tester, luAlertDescription);

    final texts = renderedSpans(tester).map((span) => span.text!).toList();

    expect(texts.any((text) => text.contains('<')), isFalse);
    expect(
      texts,
      contains('Reason:'),
    );
    expect(
      texts.firstWhere((text) => text.contains('end date')),
      contains('The "end date"'),
    );
  });

  testWidgets('bold, italic and links are styled', (tester) async {
    await pumpAlertText(tester, luAlertDescription);

    final spans = renderedSpans(tester);

    expect(
      spans.firstWhere((span) => span.text == 'Reason:').style?.fontWeight,
      FontWeight.bold,
    );
    expect(
      spans.firstWhere((span) => span.text == 'Note: ').style?.fontStyle,
      FontStyle.italic,
    );

    final link = spans.firstWhere(
      (span) => span.text!.startsWith('www.securite-alimentaire.public.lu'),
    );
    expect(link.style?.decoration, TextDecoration.underline);
    expect(link.recognizer, isNotNull);
  });

  testWidgets('list items are rendered with a bullet', (tester) async {
    await pumpAlertText(tester, luAlertDescription);

    expect(find.text('•'), findsNWidgets(5));
  });

  testWidgets('an embedded image is offered as a button and not loaded',
      (tester) async {
    await pumpAlertText(tester, luAlertDescription);

    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });

  testWidgets('the NOAA/NWS bullets are rendered as a list', (tester) async {
    await pumpAlertText(tester, nwsDescription);

    expect(find.text('•'), findsNWidgets(4));
    expect(
      renderedSpans(tester).map((span) => span.text).toList(),
      containsAll(<String>['WHAT...', 'WHERE...', 'WHEN...', 'IMPACTS...']),
    );
  });

  testWidgets('an empty text renders nothing', (tester) async {
    await pumpAlertText(tester, '');

    expect(find.byType(SelectableText), findsNothing);
  });
}
