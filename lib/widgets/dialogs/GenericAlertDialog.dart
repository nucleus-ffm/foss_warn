import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GenericAlertDialog extends StatefulWidget {
  final String title;
  final String content;
  GenericAlertDialog({Key? key, required this.content, required this.title}) : super(key: key);

  @override
  _GenericAlertDialogState createState() => _GenericAlertDialogState();
}

class _GenericAlertDialogState extends State<GenericAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title), //@todo translate
      content: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.content)
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context).main_dialog_understand,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        ),
      ],
    );
  }
}
