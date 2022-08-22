import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../views/SettingsView.dart';

class ConnectionError extends StatelessWidget {
  const ConnectionError({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if(showAllWarnings && (!mowasStatus || !biwappStatus || !dwdStatus || !katwarnStatus)) {
      return Container(
        padding: EdgeInsets.only(left: 10, bottom: 6, top: 6),
        //margin: EdgeInsets.only(bottom: 10),
        color: Colors.red,
        child: Row (
          children: [
            Icon(Icons.info, color: Colors.white,),
            SizedBox(width: 10,),
            Text("Keine Internetverbindung", style: Theme.of(context).textTheme.headline3,)
          ],
        ),
      );
    } else if(areWarningsFromCache) {
      return Container(
        padding: EdgeInsets.only(left: 10, bottom: 6, top: 6),
        //margin: EdgeInsets.only(bottom: 10),
        color: Colors.orange,
        child: Row (
          children: [
            Icon(Icons.info, color: Colors.white,),
            SizedBox(width: 10,),
            Text("Kein Internet - Warnugen könnten veraltet sein", style: Theme.of(context).textTheme.headline3,
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
