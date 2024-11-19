import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/class/class_ErrorLogger.dart';
import 'package:provider/provider.dart';

import '../class/abstract_Place.dart';
import '../class/class_WarnMessage.dart';
import '../class/class_Area.dart';
import '../main.dart';
import '../services/saveAndLoadSharedPreferences.dart';
import '../views/AlertUpdateThreadView.dart';
import '../views/WarningDetailView.dart';
import '../services/updateProvider.dart';
import '../services/translateAndColorizeWarning.dart';
import '../widgets/dialogs/MessageTypeExplanation.dart';
import 'dialogs/CategoryExplanation.dart';

class WarningWidget extends StatelessWidget {
  final Place? _place;
  final List<WarnMessage>? _updateThread;
  final WarnMessage _warnMessage;
  final bool _isMyPlaceWarning;
  const WarningWidget(
      {Key? key,
      required WarnMessage warnMessage,
      required bool isMyPlaceWarning,
      Place? place,
      List<WarnMessage>? updateThread})
      : _warnMessage = warnMessage,
        _place = place,
        _updateThread = updateThread,
        _isMyPlaceWarning = isMyPlaceWarning,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> areaList = []; //@todo rename

    updatePrevView() {
      final updater = Provider.of<Update>(context, listen: false);
      updater.updateReadStatusInList();
    }

    List<String> generateAreaList() {
      List<String> result = [];
      for (Area myArea in _warnMessage.info[0].area) {
        // sometimes there is a long list of areas separated with ","
        // we split them to only show the first one in the overview
        List<String> listOfAreas = myArea.description.split(",");
        for (int i = 0; i < listOfAreas.length; i++) {
          result.add(listOfAreas[i]);
        }
      }
      return result;
    }

    areaList = generateAreaList();

    return Consumer<Update>(
      builder: (context, counter, child) => Card(
        child: InkWell(
          onTap: () {
            try {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailScreen(
                          warnMessage: _warnMessage,
                          place: _place,
                        )),
              ).then((value) => updatePrevView());
            } catch (e) {
              ErrorLogger.writeErrorLog(
                  "WarningWidget.dart",
                  "Error of Type: ${e.runtimeType} while displaying alert: ${_warnMessage.identifier}",
                  e.toString());
              appState.error = true;
            }
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
                                    _warnMessage.info[0].category.length > 0 ?
                                      _warnMessage.info[0].category[0].name : "",
                                    context), //@todo display more then one category if available
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
                                    _warnMessage.messageType.name, context),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ),
                            color: chooseWarningTypeColor(
                                _warnMessage.messageType.name),
                            padding: EdgeInsets.all(5),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: SizedBox(
                              width: 100,
                              child: Text(
                                areaList.length > 1
                                    ? areaList.first +
                                        " " +
                                        AppLocalizations.of(context)!
                                            .warning_widget_and +
                                        " " +
                                        (areaList.length - 1).toString() +
                                        " " +
                                        AppLocalizations.of(context)!
                                            .warning_widget_other
                                    : areaList.isNotEmpty
                                        ? areaList.first
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
                        _warnMessage.info[0].headline,
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
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                    warnMessage: _warnMessage,
                                    place: _place,
                                  )),
                        ).then((value) => updatePrevView());
                      },
                      icon: Icon(Icons.read_more),
                    ),
                    //_updateThread != null ? _updateThread!.length > 1 ? IconButton(onPressed: () {}, icon: Icon(Icons.account_tree)): SizedBox(): SizedBox(),
                    (_updateThread != null && _updateThread!.length > 1)
                        ? IconButton(
                            tooltip:
                            AppLocalizations.of(context)!.warning_widget_update_thread_tooltip,
                            onPressed: () {
                              print(_updateThread!.length);
                              print(_updateThread);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AlertUpdateThreadView(
                                          latestAlert: _updateThread![0],
                                          previousNowUpdatedAlerts:
                                              _updateThread!.sublist(
                                                  1, _updateThread!.length),
                                        )),
                              );
                            },
                            icon: Icon(Icons.account_tree))
                        : SizedBox(),
                  ],
                ),
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
