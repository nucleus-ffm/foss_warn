import 'dart:math';

import 'package:flutter/foundation.dart';

/// Parser for the free text fields of a CAP alert (`description`,
/// `instruction`, …).
///
/// Those fields are plain text according to the CAP specification, but the
/// publishers use very different conventions:
///
///  * a HTML subset (`<p>`, `<br>`, `<ul>/<li>`, `<strong>`, `<em>`, `<a>`,
///    `<img>`), sometimes with HTML entities on top of the XML escaping
///    (LU-Alert),
///  * plain text where only `<br/>` marks the line breaks (MoWaS/NINA),
///  * hard wrapped plain text with `* LABEL...value` bullets (NOAA/NWS).
///
/// [parseAlertText] normalises all of them into a small list of blocks that
/// can be rendered with plain Flutter widgets, see `FormattedAlertText`.
/// [alertTextToPlainText] renders the same result as plain text, for sharing
/// and notifications.

/// A run of text with a uniform style inside a block.
@immutable
class AlertTextRun {
  const AlertTextRun(
    this.text, {
    this.bold = false,
    this.italic = false,
    this.link,
  });

  final String text;
  final bool bold;
  final bool italic;

  /// The URL this run links to, or `null` if it is not a link.
  final String? link;

  AlertTextRun copyWithText(String text) => AlertTextRun(
        text,
        bold: bold,
        italic: italic,
        link: link,
      );

  bool sameStyle(AlertTextRun other) =>
      bold == other.bold && italic == other.italic && link == other.link;

  @override
  bool operator ==(Object other) =>
      other is AlertTextRun && other.text == text && sameStyle(other);

  @override
  int get hashCode => Object.hash(text, bold, italic, link);

  @override
  String toString() => 'AlertTextRun("$text"'
      '${bold ? ', bold' : ''}'
      '${italic ? ', italic' : ''}'
      '${link != null ? ', link: $link' : ''})';
}

/// One block of an alert text. Blocks are rendered below each other.
@immutable
sealed class AlertTextBlock {
  const AlertTextBlock();

  /// The content of this block without any formatting.
  String get plainText;
}

/// A paragraph of text. [headingLevel] is `0` for normal paragraphs and
/// `1`–`6` for `<h1>`–`<h6>`.
@immutable
class AlertParagraph extends AlertTextBlock {
  const AlertParagraph(this.runs, {this.headingLevel = 0});

  final List<AlertTextRun> runs;
  final int headingLevel;

  @override
  String get plainText => runs.map((run) => run.text).join();

  @override
  bool operator ==(Object other) =>
      other is AlertParagraph &&
      other.headingLevel == headingLevel &&
      listEquals(other.runs, runs);

  @override
  int get hashCode => Object.hash(Object.hashAll(runs), headingLevel);

  @override
  String toString() => 'AlertParagraph($runs, headingLevel: $headingLevel)';
}

/// A bullet point or numbered list.
@immutable
class AlertList extends AlertTextBlock {
  const AlertList(this.items, {this.ordered = false});

  final List<List<AlertTextRun>> items;
  final bool ordered;

  @override
  String get plainText => items
      .map((item) => item.map((run) => run.text).join())
      .mapIndexed((index, item) => ordered ? '${index + 1}. $item' : '• $item')
      .join('\n');

  @override
  bool operator ==(Object other) =>
      other is AlertList &&
      other.ordered == ordered &&
      other.items.length == items.length &&
      Iterable<int>.generate(items.length)
          .every((i) => listEquals(other.items[i], items[i]));

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(items.map(Object.hashAll)), ordered);

  @override
  String toString() => 'AlertList($items, ordered: $ordered)';
}

/// An image referenced by the alert text. The image is not loaded
/// automatically, because that would leak the users IP address to the
/// publisher. The renderer only offers to open [url].
@immutable
class AlertImageReference extends AlertTextBlock {
  const AlertImageReference(this.url);

  final String url;

  /// Images are left out of the plain text version, a URL of this length is
  /// of no use in a notification or in shared text.
  @override
  String get plainText => '';

  @override
  bool operator ==(Object other) =>
      other is AlertImageReference && other.url == url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'AlertImageReference($url)';
}

extension _MapIndexed<T> on Iterable<T> {
  Iterable<R> mapIndexed<R>(R Function(int index, T element) toElement) sync* {
    int index = 0;
    for (final element in this) {
      yield toElement(index++, element);
    }
  }
}

/// Parse the text of an alert field into renderable blocks.
List<AlertTextBlock> parseAlertText(String? input) {
  if (input == null) return const [];

  String text = _unescapeLineBreaks(input).trim();
  if (text.isEmpty) return const [];

  // some publishers escape the HTML twice, so that the XML parser leaves us
  // with `&lt;p&gt;` instead of `<p>`
  if (!_looksLikeHtml(text)) {
    final String decoded = _decodeEntities(text);
    if (_looksLikeHtml(decoded)) {
      text = decoded;
    }
  }

  final List<AlertTextBlock> blocks =
      _looksLikeHtml(text) ? _parseHtml(text) : _parsePlainText(text);

  return blocks.map(_autoLinkBlock).toList();
}

/// Render an alert text without any formatting, e.g. to share it or to use it
/// as the body of a notification.
String alertTextToPlainText(String? input) => parseAlertText(input)
    .map((block) => block.plainText)
    .where((text) => text.isNotEmpty)
    .join('\n\n');

// ---------------------------------------------------------------------------
// HTML
// ---------------------------------------------------------------------------

final RegExp _htmlTagPattern = RegExp(
  r'<\s*(/?)\s*([a-zA-Z][a-zA-Z0-9]*)([^>]*)>',
);

final RegExp _knownHtmlTagPattern = RegExp(
  r'<\s*/?\s*(p|br|ul|ol|li|strong|em|b|i|u|a|img|div|span|h[1-6]|table|tr|td|th)\b[^>]*>',
  caseSensitive: false,
);

final RegExp _attributePattern = RegExp(
  '''([a-zA-Z-]+)\\s*=\\s*("([^"]*)"|'([^']*)')''',
);

bool _looksLikeHtml(String text) => _knownHtmlTagPattern.hasMatch(text);

List<AlertTextBlock> _parseHtml(String html) {
  final _BlockBuilder builder = _BlockBuilder();

  int bold = 0;
  int italic = 0;
  final List<String> links = [];
  int cursor = 0;

  void addText(String raw) {
    if (raw.isEmpty) return;
    // in HTML only the line breaks the source explicitly asks for count, but
    // some publishers mix `\n` and `<br/>`, so we keep the newlines and only
    // collapse the horizontal whitespace
    final String text =
        _decodeEntities(raw).replaceAll(RegExp('[ \\t\u00A0]+'), ' ');
    builder.addRun(
      AlertTextRun(
        text,
        bold: bold > 0,
        italic: italic > 0,
        link: links.isNotEmpty ? links.last : null,
      ),
    );
  }

  for (final RegExpMatch match in _htmlTagPattern.allMatches(html)) {
    addText(html.substring(cursor, match.start));
    cursor = match.end;

    final bool isClosing = match.group(1) == '/';
    final String tag = match.group(2)!.toLowerCase();
    final String attributes = match.group(3) ?? '';

    switch (tag) {
      case 'br':
        builder.addRun(const AlertTextRun('\n'));
      case 'p':
      case 'div':
      case 'tr':
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        builder.flush();
        if (!isClosing && tag.startsWith('h')) {
          builder.headingLevel = int.parse(tag.substring(1));
        }
      case 'ul':
      case 'ol':
        builder.flush();
        if (isClosing) {
          builder.endList();
        } else {
          builder.startList(ordered: tag == 'ol');
        }
      case 'li':
        builder.flush();
      case 'td':
      case 'th':
        // keep the cells of a row apart
        builder.addRun(const AlertTextRun(' '));
      case 'strong':
      case 'b':
        isClosing ? bold = max(0, bold - 1) : bold++;
      case 'em':
      case 'i':
        isClosing ? italic = max(0, italic - 1) : italic++;
      case 'a':
        if (isClosing) {
          if (links.isNotEmpty) links.removeLast();
        } else {
          final String? href = _attribute(attributes, 'href');
          links.add(href ?? '');
        }
      case 'img':
        final String? source = _attribute(attributes, 'src');
        if (source != null && source.isNotEmpty) {
          builder.flush();
          builder.addBlock(AlertImageReference(source));
        }
    }
  }
  addText(html.substring(cursor));

  builder.flush();
  builder.endList();

  return builder.blocks;
}

String? _attribute(String attributes, String name) {
  for (final RegExpMatch match in _attributePattern.allMatches(attributes)) {
    if (match.group(1)!.toLowerCase() == name) {
      return _decodeEntities(match.group(3) ?? match.group(4) ?? '');
    }
  }
  return null;
}

/// Collects runs into paragraphs and lists.
class _BlockBuilder {
  final List<AlertTextBlock> blocks = [];

  final List<AlertTextRun> _runs = [];
  List<List<AlertTextRun>>? _listItems;
  bool _listIsOrdered = false;

  /// heading level of the paragraph that is currently being built
  int headingLevel = 0;

  void addRun(AlertTextRun run) {
    if (run.text.isEmpty) return;

    // merge consecutive runs with the same style, to keep the result small
    if (_runs.isNotEmpty && _runs.last.sameStyle(run)) {
      _runs[_runs.length - 1] =
          _runs.last.copyWithText(_runs.last.text + run.text);
    } else {
      _runs.add(run);
    }
  }

  void addBlock(AlertTextBlock block) => blocks.add(block);

  void startList({required bool ordered}) {
    endList();
    _listItems = [];
    _listIsOrdered = ordered;
  }

  void endList() {
    final List<List<AlertTextRun>>? items = _listItems;
    _listItems = null;
    if (items != null && items.isNotEmpty) {
      blocks.add(AlertList(items, ordered: _listIsOrdered));
    }
  }

  /// Close the current paragraph or list item.
  void flush() {
    final List<AlertTextRun> runs = _trimRuns(_runs);
    _runs.clear();

    final int heading = headingLevel;
    headingLevel = 0;

    if (runs.isEmpty) return;

    if (_listItems != null) {
      _listItems!.add(runs);
    } else {
      blocks.add(AlertParagraph(runs, headingLevel: heading));
    }
  }
}

/// Remove the whitespace at the beginning and the end of a block and around
/// its line breaks.
List<AlertTextRun> _trimRuns(List<AlertTextRun> runs) {
  final List<AlertTextRun> result = [];

  for (final AlertTextRun run in runs) {
    String text = run.text.replaceAll(RegExp(r'[ \t]*\n[ \t]*'), '\n');
    if (result.isEmpty) {
      text = text.replaceFirst(RegExp(r'^\s+'), '');
    }
    if (text.isEmpty) continue;
    result.add(run.copyWithText(text));
  }

  while (result.isNotEmpty) {
    final String text = result.last.text.replaceFirst(RegExp(r'\s+$'), '');
    if (text.isEmpty) {
      result.removeLast();
    } else {
      result[result.length - 1] = result.last.copyWithText(text);
      break;
    }
  }

  // at most one empty line inside a block
  return result
      .map(
        (run) => run.copyWithText(
          run.text.replaceAll(RegExp(r'\n{3,}'), '\n\n'),
        ),
      )
      .toList();
}

// ---------------------------------------------------------------------------
// plain text
// ---------------------------------------------------------------------------

/// `* `, `- `, `• ` or `1. ` at the beginning of a line
final RegExp _bulletPattern = RegExp(r'^(?:([*•‣●-])|(\d{1,2})[.)])[ \t]+');

/// A label as used by the NOAA/NWS alerts: `* WHAT...Northwest winds`
final RegExp _labelPattern = RegExp(r"^([A-Z][A-Z0-9 /'’-]{1,30}\.\.\.)");

List<AlertTextBlock> _parsePlainText(String input) {
  final String text = _decodeEntities(input)
      .replaceAll('\t', ' ')
      // non-breaking space
      .replaceAll('\u00A0', ' ');

  final List<AlertTextBlock> blocks = [];

  for (final String paragraph in text.split(RegExp(r'\n[ \t]*\n'))) {
    final List<String> lines = paragraph
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty) continue;

    // group the lines into a leading paragraph and the list items following it
    final List<String> intro = [];
    final List<List<String>> items = [];
    bool ordered = false;

    for (final String line in lines) {
      final RegExpMatch? bullet = _bulletPattern.firstMatch(line);
      if (bullet != null) {
        ordered = bullet.group(2) != null;
        items.add([line.substring(bullet.end)]);
      } else if (items.isNotEmpty) {
        items.last.add(line);
      } else {
        intro.add(line);
      }
    }

    if (intro.isNotEmpty) {
      blocks.add(AlertParagraph(_plainTextRuns(_joinWrappedLines(intro))));
    }
    if (items.isNotEmpty) {
      blocks.add(
        AlertList(
          items.map((item) => _plainTextRuns(_joinWrappedLines(item))).toList(),
          ordered: ordered,
        ),
      );
    }
  }

  return blocks;
}

/// Join the lines of a paragraph.
///
/// Some sources wrap their text at a fixed width, others only break the line
/// where they want a line break. We assume the text is hard wrapped if all
/// lines are short enough for that and the lines are filled up to a similar
/// length.
String _joinWrappedLines(List<String> lines) {
  if (lines.length < 2) return lines.join();

  final List<String> allButLast = lines.sublist(0, lines.length - 1);
  final int longest = lines.map((line) => line.length).reduce(max);
  final double averageLength =
      allButLast.fold<int>(0, (sum, line) => sum + line.length) /
          allButLast.length;

  final bool hardWrapped = longest <= 90 && averageLength >= 45;

  return lines.join(hardWrapped ? ' ' : '\n');
}

/// Build the runs for a line of plain text, highlighting a leading label.
List<AlertTextRun> _plainTextRuns(String text) {
  final RegExpMatch? label = _labelPattern.firstMatch(text);
  if (label == null) {
    return text.isEmpty ? const [] : [AlertTextRun(text)];
  }

  return [
    AlertTextRun(label.group(1)!, bold: true),
    if (label.end < text.length) AlertTextRun(text.substring(label.end)),
  ];
}

// ---------------------------------------------------------------------------
// links
// ---------------------------------------------------------------------------

final RegExp _urlPattern = RegExp(
  r'((?:https?://|www\.)[^\s<>()\[\]{}"«»]+)',
  caseSensitive: false,
);

/// Trailing characters that are usually punctuation and not part of the URL.
final RegExp _urlTrailingPattern = RegExp(r'''[.,;:!?'"]+$''');

AlertTextBlock _autoLinkBlock(AlertTextBlock block) => switch (block) {
      AlertParagraph() => AlertParagraph(
          _autoLinkRuns(block.runs),
          headingLevel: block.headingLevel,
        ),
      AlertList() => AlertList(
          block.items.map(_autoLinkRuns).toList(),
          ordered: block.ordered,
        ),
      AlertImageReference() => block,
    };

/// Turn the URLs inside plain runs into links.
List<AlertTextRun> _autoLinkRuns(List<AlertTextRun> runs) {
  final List<AlertTextRun> result = [];

  for (final AlertTextRun run in runs) {
    if (run.link != null) {
      result.add(run);
      continue;
    }

    int cursor = 0;
    for (final RegExpMatch match in _urlPattern.allMatches(run.text)) {
      final String url = match.group(1)!.replaceFirst(_urlTrailingPattern, '');
      if (url.isEmpty) continue;

      if (match.start > cursor) {
        result.add(run.copyWithText(run.text.substring(cursor, match.start)));
      }
      result.add(
        AlertTextRun(url, bold: run.bold, italic: run.italic, link: url),
      );
      cursor = match.start + url.length;
    }

    if (cursor < run.text.length) {
      result.add(run.copyWithText(run.text.substring(cursor)));
    }
  }

  return result;
}

// ---------------------------------------------------------------------------
// escape sequences
// ---------------------------------------------------------------------------

/// A line break that reached us as an escape sequence instead of as the
/// character itself: `\n`, `\r\n` or, because the Parker transform of
/// `xml2json` escapes the text of every element a second time, `\\n` and
/// `\\r\\n`.
final RegExp _escapedLineBreakPattern = RegExp(r'(\\{1,2}r)?\\{1,2}n');

/// A tabulator that reached us as an escape sequence, see
/// [_escapedLineBreakPattern].
final RegExp _escapedTabPattern = RegExp(r'\\{1,2}t');

/// Turn the escape sequences of [text] back into the characters they stand
/// for.
///
/// Without this a NOAA/NWS alert, whose line breaks all arrive escaped, would
/// keep a stray backslash at the end of every line.
String _unescapeLineBreaks(String text) {
  if (!text.contains(r'\')) return text;

  return text
      .replaceAll(_escapedLineBreakPattern, '\n')
      .replaceAll(_escapedTabPattern, ' ');
}

// ---------------------------------------------------------------------------
// entities
// ---------------------------------------------------------------------------

final RegExp _entityPattern = RegExp(
  r'&(#[xX][0-9a-fA-F]+|#[0-9]+|[a-zA-Z][a-zA-Z0-9]{1,10});',
);

const Map<String, String> _namedEntities = {
  'amp': '&',
  'lt': '<',
  'gt': '>',
  'quot': '"',
  'apos': "'",
  'nbsp': ' ',
  'shy': '',
  'hellip': '…',
  'ndash': '–',
  'mdash': '—',
  'laquo': '«',
  'raquo': '»',
  'ldquo': '“',
  'rdquo': '”',
  'lsquo': '‘',
  'rsquo': '’',
  'bdquo': '„',
  'sbquo': '‚',
  'deg': '°',
  'euro': '€',
  'pound': '£',
  'middot': '·',
  'bull': '•',
  'copy': '©',
  'reg': '®',
  'trade': '™',
  'auml': 'ä',
  'ouml': 'ö',
  'uuml': 'ü',
  'Auml': 'Ä',
  'Ouml': 'Ö',
  'Uuml': 'Ü',
  'szlig': 'ß',
};

/// Decode the HTML entities of [text]. Unknown entities are kept as they are.
String _decodeEntities(String text) {
  if (!text.contains('&')) return text;

  return text.replaceAllMapped(_entityPattern, (Match match) {
    final String entity = match.group(1)!;

    if (entity.startsWith('#')) {
      final bool hexadecimal = entity[1] == 'x' || entity[1] == 'X';
      final int? code = int.tryParse(
        hexadecimal ? entity.substring(2) : entity.substring(1),
        radix: hexadecimal ? 16 : 10,
      );
      if (code == null || code < 0x9 || code > 0x10FFFF) return match.group(0)!;
      return String.fromCharCode(code);
    }

    return _namedEntities[entity] ?? match.group(0)!;
  });
}
