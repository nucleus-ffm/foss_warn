import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_error_logger.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/main.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/services/translate_and_colorize_warning.dart';
import 'package:foss_warn/views/alert_update_thread_view.dart';
import 'package:foss_warn/views/warning_detail_view.dart';
import 'package:foss_warn/widgets/dialogs/category_explanation.dart';
import 'package:foss_warn/widgets/dialogs/message_type_explanation.dart';

import '../class/class_warn_message.dart';
import '../class/class_area.dart';
import '../services/save_and_load_shared_preferences.dart';
import '../services/update_provider.dart';

class WarningWidget extends ConsumerWidget {
  final Place? _place;
  final List<WarnMessage>? _updateThread;
  final WarnMessage _warnMessage;
  final bool _isMyPlaceWarning;
  const WarningWidget({
    super.key,
    required WarnMessage warnMessage,
    required bool isMyPlaceWarning,
    Place? place,
    List<WarnMessage>? updateThread,
  })  : _warnMessage = warnMessage,
        _place = place,
        _updateThread = updateThread,
        _isMyPlaceWarning = isMyPlaceWarning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var localizations = context.localizations;

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
                ),
              ),
            ).then((value) => updatePrevView());
          } catch (e) {
            ErrorLogger.writeErrorLog(
              "WarningWidget.dart",
              "Error of Type: ${e.runtimeType} while displaying alert: ${_warnMessage.identifier}",
              e.toString(),
            );
            appState.error = true;
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildReadStateButton(ref),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          color: Colors.indigo,
                          padding: const EdgeInsets.all(5),
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return const CategoryExplanation();
                                },
                              );
                            },
                            child: Text(
                              translateWarningCategory(
                                _warnMessage.info[0].category.isNotEmpty
                                    ? _warnMessage.info[0].category[0].name
                                    : "",
                                context,
                              ), //@todo display more then one category if available
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          color:
                              chooseWarningTypeColor(_warnMessage.messageType),
                          padding: const EdgeInsets.all(5),
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return const MessageTypeExplanation();
                                },
                              );
                            },
                            child: Text(
                              translateWarningType(
                                _warnMessage.messageType,
                                context,
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: SizedBox(
                            width: 100,
                            child: Text(
                              areaList.length > 1
                                  ? "${areaList.first} ${localizations.warning_widget_and} ${areaList.length - 1} ${localizations.warning_widget_other}"
                                  : areaList.isNotEmpty
                                      ? areaList.first
                                      : localizations.warning_widget_unknown,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _warnMessage.info[0].headline,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            formatSentDate(_warnMessage.sent),
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),
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
                          ),
                        ),
                      ).then((value) => updatePrevView());
                    },
                    icon: const Icon(Icons.read_more),
                  ),
                  (_updateThread != null && _updateThread.length > 1)
                      ? IconButton(
                          tooltip: localizations
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
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.account_tree),
                        )
                      : const SizedBox(),
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
      return const IconButton(
        onPressed: null,
        icon: Icon(
          Icons.warning_amber_outlined,
          color: Colors.grey,
        ),
      );
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
          ? const Icon(
              Icons.mark_chat_read,
              color: Colors.green,
            )
          : const Icon(
              Icons.warning_amber_outlined,
              color: Colors.red,
            ),
    );
  }
}
