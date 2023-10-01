import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String description;
  final String actionText;
  final Function onConfirmed;

  const ConfirmDialog(
      {Key? key,
      required this.title,
      required this.description,
      required this.actionText,
      required this.onConfirmed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: <Widget>[
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              // @todo: translations
              "Cancel",
              style: TextStyle(color: Colors.green),
            )),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirmed();
          },
          child: Text(
            actionText,
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
    );
  }
}
