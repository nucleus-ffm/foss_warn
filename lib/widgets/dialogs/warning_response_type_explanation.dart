import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';

import '../../enums/response_type.dart';

class WarningResponseTypeExplanation extends StatefulWidget {
  final List<ResponseType> responseTypes;
  const WarningResponseTypeExplanation({
    super.key,
    required this.responseTypes,
  });

  @override
  State<WarningResponseTypeExplanation> createState() =>
      _WarningResponseTypeExplanationState();
}

class _WarningResponseTypeExplanationState
    extends State<WarningResponseTypeExplanation> {
  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var theme = Theme.of(context);
    var navigator = Navigator.of(context);

    /// Build one explanation entry
    TextSpan buildEntry(ResponseType type) {
      return TextSpan(
        children: <TextSpan>[
          const TextSpan(text: '\n'),
          TextSpan(
            text: type.getLocalizedName(context),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: '\n'),
          TextSpan(
            text: type.getLocalizedExplanation(context),
          ),
          const TextSpan(text: '\n'),
        ],
      );
    }

    return AlertDialog(
      title: Text(localizations.warning_response_type_title),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              text: '',
              style: theme.textTheme.bodyMedium,
              children: <TextSpan>[
                ...widget.responseTypes.map((e) => buildEntry(e)),
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => navigator.pop(),
          child: Text(localizations.main_dialog_close),
        ),
      ],
    );
  }
}
