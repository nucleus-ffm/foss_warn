import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';

class GenericDialog extends StatefulWidget {
  final String title;
  final String content;
  final bool? confirmation;
  const GenericDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmation,
  });

  @override
  State<GenericDialog> createState() => _GenericDialogState();
}

class _GenericDialogState extends State<GenericDialog> {
  @override
  Widget build(BuildContext context) {
    var localisation = context.localizations;
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Text(widget.content)],
        ),
      ),
      actions: <Widget>[
        (widget.confirmation ?? false)
            ? TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  localisation.main_dialog_abort,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              )
            : const SizedBox(),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(
            localisation.main_dialog_ok,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
      ],
    );
  }
}
