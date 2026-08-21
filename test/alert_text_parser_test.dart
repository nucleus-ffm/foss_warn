import 'package:flutter_test/flutter_test.dart';
import 'package:foss_warn/services/alert_text_parser.dart';

import 'helpers/alert_text_fixtures.dart';

/// Convenience access to the runs of a block.
List<AlertTextRun> runsOf(AlertTextBlock block) => switch (block) {
      AlertParagraph() => block.runs,
      AlertList() => block.items.expand((item) => item).toList(),
      AlertImageReference() => const [],
    };

void main() {
  group('HTML formatted descriptions', () {
    test('LU-Alert description is split into its blocks', () {
      final blocks = parseAlertText(luAlertDescription);

      expect(
        blocks.map((block) => block.runtimeType.toString()).toList(),
        [
          'AlertParagraph', // Reason: Presence of Bacillus cereus
          'AlertImageReference',
          'AlertList', // the product details
          'AlertParagraph', // Sale confirmed in Luxembourg by : Lidl
          'AlertParagraph', // More information regarding ...
          'AlertParagraph', // All food safety alerts: ...
          'AlertParagraph', // Note: ...
        ],
      );

      // empty paragraphs (`<p></p>`) are dropped
      expect(
        blocks.whereType<AlertParagraph>().any(
              (paragraph) => paragraph.plainText.trim().isEmpty,
            ),
        isFalse,
      );
    });

    test('<strong> is turned into bold runs', () {
      final blocks = parseAlertText(luAlertDescription);

      expect(
        (blocks.first as AlertParagraph).runs,
        const [
          AlertTextRun('Reason:', bold: true),
          AlertTextRun(' Presence of Bacillus cereus'),
        ],
      );
    });

    test('<em> is turned into an italic run', () {
      final blocks = parseAlertText(luAlertDescription);

      expect(
        blocks.last,
        isA<AlertParagraph>().having(
          (paragraph) => paragraph.runs.first,
          'first run',
          const AlertTextRun('Note: ', italic: true),
        ),
      );
    });

    test('<ul> becomes an unordered list with one entry per <li>', () {
      final list = parseAlertText(luAlertDescription).whereType<AlertList>();

      expect(list, hasLength(1));
      expect(list.first.ordered, isFalse);
      expect(
        list.first.items.map((item) => item.map((run) => run.text).join()),
        [
          'Name: High Protein Pudding Chocolate Flavour',
          'Brand: Milbona',
          'Unit: 200 g',
          'Best before date (BBD): 14/09/2026',
          'Period of sale: 31/07/2026 - 19/08/2026',
        ],
      );
    });

    test('<a> keeps the link target of the anchor, not the link text', () {
      final links = parseAlertText(luAlertDescription)
          .expand(runsOf)
          .where((run) => run.link != null)
          .toList();

      expect(links, hasLength(2));
      expect(
        links.first,
        const AlertTextRun(
          'www.securite-alimentaire.public.lu/fr/danger/en',
          link: 'https://securite-alimentaire.public.lu/fr/danger/en/'
              'bacillus.html',
        ),
      );
    });

    test('<img> is kept as a reference instead of being loaded', () {
      final images =
          parseAlertText(luAlertDescription).whereType<AlertImageReference>();

      expect(images, hasLength(1));
      expect(images.first.url, startsWith('https://securite-alimentaire'));
      expect(images.first.url, endsWith('.png'));
    });

    test('HTML entities that survived the XML unescaping are decoded', () {
      final text = alertTextToPlainText(luAlertDescription);

      expect(text, contains('The "end date" indicates'));
      expect(text, isNot(contains('&quot;')));
      expect(text, isNot(contains('&#39;')));
    });

    test('no markup is left in the parsed text', () {
      expect(alertTextToPlainText(luAlertDescription), isNot(contains('<')));
    });
  });

  group('plain text with <br/> line breaks', () {
    test('MoWaS description becomes one paragraph with line breaks', () {
      final blocks = parseAlertText(mowasDescription);

      expect(blocks, hasLength(1));
      expect(
        blocks.first.plainText,
        'Es folgt eine wichtige Information.\n\n'
        'Aufgrund eines Waldbrandes / Vegetationsbrandes im Kreis Düren und '
        'im Hohen Venn kommt es immer noch, in Teilgebieten des Kreises '
        'Euskirchen (aktuell im Südkreis) zu einer Geruchsbelästigung und '
        'Rauchniederschlag.\n'
        'Bitte halten Sie die Notrufleitungen 110 / 112 für Notfälle frei.',
      );
    });

    test('MoWaS instruction keeps its single line break', () {
      expect(
        parseAlertText(mowasInstruction).single.plainText,
        'Wählen Sie nur in Notfällen den Notruf 110 (Polizei) und 112 '
        '(Feuerwehr).\n'
        'Schließen Sie vorsorglich Fenster und Türen.',
      );
    });

    test('an entity inside a text without tags is decoded as well', () {
      expect(
        parseAlertText(mowasAllClearDescription).first.plainText,
        startsWith(
          'Dies ist die Entwarnung zur Warnung "Geruchsbelästigung durch '
          'Brandrauch',
        ),
      );
    });
  });

  group('hard wrapped plain text', () {
    test('NOAA/NWS bullets are parsed into lists with a bold label', () {
      final blocks = parseAlertText(nwsDescription);

      expect(blocks.every((block) => block is AlertList), isTrue);
      expect(
        blocks.map((block) => block.plainText).toList(),
        [
          '• WHAT...Northwest winds 10 to 20 kt with gusts up to 25 kt '
              'expected.',
          '• WHERE...Waters from Point Reyes to Pigeon Point 10-60 NM.',
          '• WHEN...From 3 PM this afternoon to 3 AM PDT Saturday.',
          '• IMPACTS...Conditions will be hazardous to small craft.',
        ],
      );
      expect(
        (blocks.first as AlertList).items.first.first,
        const AlertTextRun('WHAT...', bold: true),
      );
    });

    test('lines wrapped at a fixed width are joined again', () {
      expect(
        parseAlertText(nwsInstruction).single.plainText,
        'Inexperienced mariners, especially those operating smaller vessels, '
        'should avoid navigating in hazardous conditions.',
      );
    });

    test('short lines are kept as separate lines', () {
      expect(
        parseAlertText(
          'Leitstelle Musterstadt\nMusterweg 1\n12345 Musterstadt',
        ).single.plainText,
        'Leitstelle Musterstadt\nMusterweg 1\n12345 Musterstadt',
      );
    });

    test('a blank line separates two paragraphs', () {
      final blocks = parseAlertText('First paragraph.\n\nSecond paragraph.');

      expect(
        blocks.map((block) => block.plainText).toList(),
        ['First paragraph.', 'Second paragraph.'],
      );
    });

    test('numbered lines become an ordered list', () {
      final blocks = parseAlertText('Do this:\n1. first\n2. second');

      expect(blocks.first, isA<AlertParagraph>());
      expect(
        blocks.last,
        isA<AlertList>()
            .having((list) => list.ordered, 'ordered', isTrue)
            .having((list) => list.items, 'items', hasLength(2)),
      );
    });

    test('escape sequences sent as literal text are turned into line breaks',
        () {
      expect(
        parseAlertText(r'First line.\nSecond line.').single.plainText,
        'First line.\nSecond line.',
      );
    });

    test('bare URLs become links', () {
      final runs = runsOf(
        parseAlertText('More at https://www.example.org/info, or call us.')
            .single,
      );

      expect(
        runs,
        const [
          AlertTextRun('More at '),
          AlertTextRun(
            'https://www.example.org/info',
            link: 'https://www.example.org/info',
          ),
          AlertTextRun(', or call us.'),
        ],
      );
    });
  });

  group('robustness', () {
    test('an empty or missing text results in no blocks', () {
      expect(parseAlertText(null), isEmpty);
      expect(parseAlertText(''), isEmpty);
      expect(parseAlertText('   \n  '), isEmpty);
      expect(alertTextToPlainText(null), '');
    });

    test('unknown tags are dropped but their content is kept', () {
      expect(
        parseAlertText('<p>Wind <span class="x">85</span> km/h</p>')
            .single
            .plainText,
        'Wind 85 km/h',
      );
    });

    test('unclosed and nested tags do not break the parsing', () {
      final runs = runsOf(
        parseAlertText('<p><b>Attention<i>: stay inside</p>').single,
      );

      expect(
        runs,
        const [
          AlertTextRun('Attention', bold: true),
          AlertTextRun(': stay inside', bold: true, italic: true),
        ],
      );
    });

    test('headings are parsed with their level', () {
      expect(
        parseAlertText('<h2>Warning</h2><p>Text</p>').first,
        isA<AlertParagraph>()
            .having((it) => it.headingLevel, 'headingLevel', 2)
            .having((it) => it.plainText, 'plainText', 'Warning'),
      );
    });

    test('doubly escaped HTML is unescaped before parsing', () {
      expect(
        runsOf(
          parseAlertText('&lt;p&gt;Stay &lt;b&gt;inside&lt;/b&gt;&lt;/p&gt;')
              .single,
        ),
        const [
          AlertTextRun('Stay '),
          AlertTextRun('inside', bold: true),
        ],
      );
    });

    test('the line breaks of the source do not add empty paragraphs', () {
      final blocks = parseAlertText(
        '<p>\n  First\n</p>\n\n<p>\n  Second\n</p>\n',
      );

      expect(blocks.map((block) => block.plainText).toList(), [
        'First',
        'Second',
      ]);
    });

    test('plain text is rendered with bullets and blank lines', () {
      expect(
        alertTextToPlainText('<p>Take care:</p><ul><li>one</li><li>two</li>'
            '</ul>'),
        'Take care:\n\n• one\n• two',
      );
    });
  });
}
