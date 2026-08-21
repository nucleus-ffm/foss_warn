import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/services/alert_text_parser.dart';
import 'package:foss_warn/services/url_launcher.dart';

/// Renders a free text field of an alert (description, instruction, …) with
/// the formatting the publisher used, see [parseAlertText].
class FormattedAlertText extends ConsumerStatefulWidget {
  const FormattedAlertText({required this.text, super.key});

  final String text;

  @override
  ConsumerState<FormattedAlertText> createState() => _FormattedAlertTextState();
}

class _FormattedAlertTextState extends ConsumerState<FormattedAlertText> {
  /// one recognizer per link, so that they survive a rebuild and can be
  /// disposed properly
  final Map<String, TapGestureRecognizer> _recognizers = {};

  late List<AlertTextBlock> _blocks = parseAlertText(widget.text);

  @override
  void didUpdateWidget(covariant FormattedAlertText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text) {
      _blocks = parseAlertText(widget.text);
    }
  }

  @override
  void dispose() {
    for (final TapGestureRecognizer recognizer in _recognizers.values) {
      recognizer.dispose();
    }
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    var scaffoldMessenger = ScaffoldMessenger.of(context);
    var localizations = context.localizations;

    bool success = await launchUrlInBrowser(url);

    if (!success && mounted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            localizations.failed_to_open_url,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.red[100],
        ),
      );
    }
  }

  TapGestureRecognizer _recognizerFor(String url) => _recognizers.putIfAbsent(
        url,
        () => TapGestureRecognizer()..onTap = () => _openUrl(url),
      );

  TextSpan _buildSpan(AlertTextRun run, ThemeData theme) {
    final String? link = run.link;
    final bool isLink = link != null && link.isNotEmpty;

    return TextSpan(
      text: run.text,
      style: TextStyle(
        fontWeight: run.bold ? FontWeight.bold : null,
        fontStyle: run.italic ? FontStyle.italic : null,
        color: isLink ? theme.colorScheme.tertiary : null,
        decoration: isLink ? TextDecoration.underline : null,
        decorationColor: isLink ? theme.colorScheme.tertiary : null,
      ),
      recognizer: isLink ? _recognizerFor(link) : null,
    );
  }

  Widget _buildText(
    List<AlertTextRun> runs,
    ThemeData theme, {
    required TextStyle style,
  }) {
    return SelectableText.rich(
      TextSpan(
        children: runs.map((run) => _buildSpan(run, theme)).toList(),
        style: style,
      ),
    );
  }

  Widget _buildList(AlertList block, ThemeData theme, TextStyle style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < block.items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: block.ordered ? 28 : 20,
                  child: Text(
                    block.ordered ? "${i + 1}." : "•",
                    style: style,
                  ),
                ),
                Expanded(
                  child: _buildText(block.items[i], theme, style: style),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBlock(AlertTextBlock block, ThemeData theme, TextStyle style) {
    switch (block) {
      case AlertParagraph():
        return _buildText(
          block.runs,
          theme,
          style: block.headingLevel == 0
              ? style
              : style.copyWith(
                  fontSize: style.fontSize! + (block.headingLevel <= 2 ? 4 : 2),
                  fontWeight: FontWeight.bold,
                ),
        );
      case AlertList():
        return _buildList(block, theme, style);
      case AlertImageReference():
        return Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _openUrl(block.url),
            icon: const Icon(Icons.image_outlined),
            label: Text(
              context.localizations.warning_open_image,
              style: style,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var fontSize = ref.watch(
      userPreferencesProvider.select((value) => value.warningFontSize),
    );
    var style = TextStyle(fontSize: fontSize);

    if (_blocks.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _buildBlock(_blocks[i], theme, style),
        ],
      ],
    );
  }
}
