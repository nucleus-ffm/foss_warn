import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../class/class_WarnMessage.dart';
import '../class/class_Area.dart';
import '../class/class_Geocode.dart';
import '../services/saveAndLoadSharedPreferences.dart';
import '../views/WarningDetailView.dart';
import '../services/updateProvider.dart';
import '../services/translateAndColorizeWarning.dart';
import '../widgets/dialogs/MessageTypeExplanation.dart';
import 'dialogs/CategoryExplanation.dart';

class WarningWidget extends StatelessWidget {
  final WarnMessage _warnMessage;
  final bool _isMyPlaceWarning;
  const WarningWidget(
      {Key? key,
      required WarnMessage warnMessage,
      required bool isMyPlaceWarning})
      : _warnMessage = warnMessage,
        _isMyPlaceWarning = isMyPlaceWarning,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> geocodeNameList = [];
    updatePrevView() {
      final updater = Provider.of<Update>(context, listen: false);
      updater.updateReadStatusInList();
    }

    List<String> generateGeocodeList() {
      List<String> tempList = [];
      for (Area myArea in _warnMessage.areaList) {
        for (Geocode myGeocode in myArea.geocodeList) {
          tempList.add(myGeocode.geocodeName);
        }
      }
      return tempList;
    }

    geocodeNameList = generateGeocodeList();

    return Consumer<Update>(
      builder: (context, counter, child) => Card(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      DetailScreen(warnMessage: _warnMessage)),
            ).then((value) => updatePrevView());
          },
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildReadStateButton(context),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CategoryExplanation();
                                  },
                                );
                              },
                              child: Text(
                                translateWarningCategory(
                                    _warnMessage.category, context),
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                            ),
                            color: Colors.indigo,
                            padding: EdgeInsets.all(5),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return MessageTypeExplanation();
                                  },
                                );
                              },
                              child: Text(
                                translateWarningType(
                                    _warnMessage.messageType, context),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ),
                            color: chooseWarningTypeColor(
                                _warnMessage.messageType),
                            padding: EdgeInsets.all(5),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: SizedBox(
                              width: 100,
                              child: Text(
                                geocodeNameList.length > 1
                                    ? geocodeNameList.first +
                                        " " +
                                        AppLocalizations.of(context)!
                                            .warning_widget_and +
                                        " " +
                                        (geocodeNameList.length - 1)
                                            .toString() +
                                        " " +
                                        AppLocalizations.of(context)!
                                            .warning_widget_other
                                    : geocodeNameList.isNotEmpty
                                        ? geocodeNameList.first
                                        : AppLocalizations.of(context)!
                                            .warning_widget_unknown,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        _warnMessage.headline,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Text(
                              formatSentDate(_warnMessage.sent),
                              style: TextStyle(fontSize: 12),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              _warnMessage.source.name.toUpperCase(),
                              style: TextStyle(fontSize: 12),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DetailScreen(warnMessage: _warnMessage)),
                    ).then((value) => updatePrevView());
                  },
                  icon: Icon(Icons.read_more),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadStateButton(BuildContext context) {
    // do not show a clickable red/green button for non-my-place warnings
    // if _isMyPlaceWarning = true
    // the read state of these warning is not saved anyways

    if (!_isMyPlaceWarning) {
      return IconButton(
          onPressed: null,
          icon: Icon(
            Icons.warning_amber_outlined,
            color: Colors.grey,
          ));
    }

    if (_warnMessage.read) {
      return IconButton(
          onPressed: () {
            _warnMessage.read = false;
            final updater = Provider.of<Update>(context, listen: false);
            updater.updateReadStatusInList();
            // save places list to store new read state
            saveMyPlacesList();
          },
          icon: Icon(
            Icons.mark_chat_read,
            color: Colors.green,
          ));
    } else {
      return IconButton(
          onPressed: () {
            _warnMessage.read = true;
            final updater = Provider.of<Update>(context, listen: false);
            updater.updateReadStatusInList();
            // save places list to store new read state
            saveMyPlacesList();
          },
          icon: Icon(
            Icons.warning_amber_outlined,
            color: Colors.red,
          ));
    }
  }
}
