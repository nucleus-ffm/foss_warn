import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_error_logger.dart';
import 'package:foss_warn/services/list_handler.dart';

import '../class/abstract_place.dart';
import '../class/class_warn_message.dart';
import '../class/class_area.dart';
import '../main.dart';
import '../services/save_and_load_shared_preferences.dart';
import '../views/alert_update_thread_view.dart';
import '../views/warning_detail_view.dart';
import '../services/update_provider.dart';
import '../services/translate_and_colorize_warning.dart';
import 'dialogs/message_type_explanation.dart';
import 'dialogs/category_explanation.dart';

class WarningWidget extends ConsumerWidget {
  final Place? _place;
  final List<WarnMessage>? _updateThread;
  final WarnMessage _warnMessage;
  final bool _isMyPlaceWarning;
  const WarningWidget(
      {super.key,
      required WarnMessage warnMessage,
      required bool isMyPlaceWarning,
      Place? place,
      List<WarnMessage>? updateThread})
      : _warnMessage = warnMessage,
        _place = place,
        _updateThread = updateThread,
        _isMyPlaceWarning = isMyPlaceWarning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var updater = ref.watch(updaterProvider);

    List<String> areaList = []; //@todo rename

    updatePrevView() {
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

    return Card(
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
              _buildReadStateButton(ref),
              SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          color: Colors.indigo,
                          padding: EdgeInsets.all(5),
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
                                  _warnMessage.info[0].category.isNotEmpty
                                      ? _warnMessage.info[0].category[0].name
                                      : "",
                                  context), //@todo display more then one category if available
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          color: chooseWarningTypeColor(
                              _warnMessage.messageType.name),
                          padding: EdgeInsets.all(5),
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
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: SizedBox(
                            width: 100,
                            child: Text(
                              areaList.length > 1
                                  ? "${areaList.first} ${AppLocalizations.of(context)!.warning_widget_and} ${areaList.length - 1} ${AppLocalizations.of(context)!.warning_widget_other}"
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
                    SizedBox(height: 5),
                    Text(
                      _warnMessage.info[0].headline,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
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
                  (_updateThread != null && _updateThread.length > 1)
                      ? IconButton(
                          tooltip: AppLocalizations.of(context)!
                              .warning_widget_update_thread_tooltip,
                          onPressed: () {
                            debugPrint("${_updateThread.length}");
                            debugPrint("$_updateThread");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AlertUpdateThreadView(
                                        latestAlert: _updateThread[0],
                                        previousNowUpdatedAlerts: _updateThread
                                            .sublist(1, _updateThread.length),
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
    );
  }

  Widget _buildReadStateButton(WidgetRef ref) {
    var updater = ref.read(updaterProvider);

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

    return IconButton(
      onPressed: () async {
        _warnMessage.read = !_warnMessage.read;
        // @todo this fixes the issue with the not stored read state
        // this is just a hacky solution to ensure the right data is in the
        // myPlacesList. We should try to find a cleaner solution in the future
        if (_place != null) {
          myPlaceList
              .firstWhere((e) => e.name == _place.name)
              .warnings
              .firstWhere((e) => e.identifier == _warnMessage.identifier)
              .read = _warnMessage.read;
        }
        updater.updateReadStatusInList();
        // save places list to store new read state
        await saveMyPlacesList();
      },
      icon: _warnMessage.read
          ? Icon(
              Icons.mark_chat_read,
              color: Colors.green,
            )
          : Icon(
              Icons.warning_amber_outlined,
              color: Colors.red,
            ),
    );
  }
}
