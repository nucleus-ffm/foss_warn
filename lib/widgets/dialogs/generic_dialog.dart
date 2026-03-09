import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';

class GenericDialog extends StatefulWidget {
  final String title;
  final String content;
  const GenericDialog({super.key, required this.title, required this.content});

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
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            localisation.main_dialog_understand,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
      ],
    );
  }
}
