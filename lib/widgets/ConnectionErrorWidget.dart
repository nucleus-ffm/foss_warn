import 'package:flutter/material.dart';
import '../main.dart';
import '../views/SettingsView.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConnectionError extends StatelessWidget {
  const ConnectionError({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if(showAllWarnings && dataFetchStatusOldAPI == 2) {
      return Container(
        padding: EdgeInsets.only(left: 10, bottom: 6, top: 6),
        //margin: EdgeInsets.only(bottom: 10),
        color: Colors.red,
        child: Row (
          children: [
            Icon(Icons.info, color: Colors.white,),
            SizedBox(width: 10,),
            Text(AppLocalizations.of(context).connection_error_no_internet, style: Theme.of(context).textTheme.headline3,)
          ],
        ),
      );
    } else if(areWarningsFromCache) {
      return Container(
        padding: EdgeInsets.only(left: 10, bottom: 6, top: 6),
        color: Colors.orange,
        child: Row (
          children: [
            Icon(Icons.info, color: Colors.white,),
            SizedBox(width: 10,),
            Text(AppLocalizations.of(context).connection_error_no_internet, style: Theme.of(context).textTheme.headline3,
            overflow:  TextOverflow.ellipsis,
            )
          ],
        ),
      );
  } else {
      return SizedBox();
    }
  }
}
