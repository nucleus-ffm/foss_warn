import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../main.dart';

class StatusWidget extends StatelessWidget {
  const StatusWidget({Key? key}) : super(key: key);

  SizedBox generateStatusFlag(bool status, bool parseStatus) {
    return SizedBox(
        width: 30,
        child: status
            ? parseStatus
                ? Icon(
                    Icons.check_box,
                    color: Colors.green,
                  )
                : Icon(
                    Icons.speaker_notes_off_outlined,
                    color: Colors.red,
                  )
            : Icon(
                Icons.error,
                color: Colors.red,
              ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).status_headline),
      content: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).status_source_status,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 130, child: Text("Mowas: ")),
                  generateStatusFlag(mowasStatus, mowasParseStatus),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 130, child: Text("Katwarn: ")),
                  generateStatusFlag(katwarnStatus, katwarnParseStatus),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 130, child: Text("Biwapp: ")),
                  generateStatusFlag(biwappStatus, biwappParseStatus),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 130, child: Text("DWD: ")),
                  generateStatusFlag(dwdStatus, dwdParseStatus),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 130, child: Text("LHP: ")),
                  generateStatusFlag(lhpStatus, lhpParseStatus),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 30, child: Icon(Icons.error, color: Colors.red)),
                  SizedBox(
                    width: 140,
                    child: Text(
                      " = " +
                          AppLocalizations.of(context)
                              .status_server_not_reachable,
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 30,
                      child: Icon(Icons.speaker_notes_off_outlined,
                          color: Colors.red)),
                  SizedBox(
                    width: 140,
                    child: Text(
                      " = " + AppLocalizations.of(context).status_everything_ok,
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 30,
                    child: Icon(
                      Icons.check_box,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: Text(
                      " = " + AppLocalizations.of(context).status_everything_ok,
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                AppLocalizations.of(context).status_count_of_message,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 130, child: Text("Mowas:")),
                  SizedBox(
                      width: 30, child: Text(mowasWarningsCount.toString())),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 130, child: Text("Katwarn: ")),
                  SizedBox(
                      width: 30, child: Text(katwarnWarningsCount.toString())),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 130, child: Text("Biwapp:")),
                  SizedBox(
                      width: 30, child: Text(biwappWarningsCount.toString())),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 130, child: Text("DWD:")),
                  SizedBox(width: 30, child: Text(dwdWarningsCount.toString())),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 130, child: Text("LHP:")),
                  SizedBox(width: 30, child: Text(lhpWarningsCount.toString())),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        new TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context).main_dialog_close,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        )
      ],
    );
  }
}
