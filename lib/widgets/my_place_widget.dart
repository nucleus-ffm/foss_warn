import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/class/class_fpas_place.dart';

import 'dialogs/delete_place_dialog.dart';
import '../views/my_place_detail_view.dart';
import 'dialogs/meta_info_for_place_dialog.dart';

class MyPlaceWidget extends StatelessWidget {
  final Place myPlace;
  const MyPlaceWidget({super.key, required this.myPlace});

  String checkForWarnings(BuildContext context) {
    debugPrint("[MyPlaceWidget] check for warnings");
    if (myPlace.countWarnings > 0) {
      if (myPlace.countWarnings > 1) {
        return "${AppLocalizations.of(context)!.my_place_there_are} ${myPlace.countWarnings} ${AppLocalizations.of(context)!.my_place_warnings_more_then_one}";
      } else {
        return "${AppLocalizations.of(context)!.my_place_there_are} ${myPlace.countWarnings} ${AppLocalizations.of(context)!.my_place_warnings_only_one}";
      }
    } else {
      return AppLocalizations.of(context)!.my_places_no_warning_found;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onLongPress: () {
          debugPrint("DeletePlaceDialog opened");
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return DeletePlaceDialog(myPlace: myPlace);
            },
          );
        },
        onTap: () {
          if (myPlace.countWarnings != 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyPlaceDetailScreen(myPlace: myPlace)),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return MetaInfoForPlaceDialog(myPlace: myPlace);
                          },
                        );
                      },
                      icon: Icon(Icons.location_city)),
                  SizedBox(
                    width: 20,
                    //width: (MediaQuery.of(context).size.width)-150,
                  ),
                  SizedBox(
                    height: 60,
                    //width: 200,
                    width: (MediaQuery.of(context).size.width) * 0.6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            myPlace.name,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        Flexible(child: Text(checkForWarnings(context))),
                      ],
                    ),
                  ),
                ],
              ),
              Flexible(
                child: myPlace.countWarnings ==
                        0 //check the number of warnings and display check or warning
                    ? TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onSecondary,
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(15)),
                        onPressed: () {},
                        child: Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ))
                    : myPlace.checkIfAllWarningsAreRead()
                        ? TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.grey,
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(15)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MyPlaceDetailScreen(myPlace: myPlace)),
                              );
                            },
                            child: Icon(
                              Icons.mark_chat_read,
                              color: Colors.white,
                            ),
                          )
                        : TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(15)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MyPlaceDetailScreen(myPlace: myPlace)),
                              );
                            },
                            child: Icon(
                              Icons.warning,
                              color: Colors.white,
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
