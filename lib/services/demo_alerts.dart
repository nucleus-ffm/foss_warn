import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_area.dart';
import 'package:foss_warn/class/class_warn_message.dart';
import 'package:foss_warn/enums/category.dart';
import 'package:foss_warn/enums/certainty.dart';
import 'package:foss_warn/enums/message_type.dart';
import 'package:foss_warn/enums/scope.dart';
import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/enums/status.dart';
import 'package:foss_warn/enums/urgency.dart';
import 'package:foss_warn/extensions/list.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/services/warnings.dart';

import '../class/class_info.dart';
import '../class/class_notification_preferences.dart';
import '../class/class_notification_service.dart';
import '../class/class_user_preferences.dart';
import '../constants.dart' as constants;
import '../routes.dart';

// alert severity severe
WarnMessage createBombFoundMessage(String subscriptionId) {
  return WarnMessage(
    fpasId: "-1",
    identifier: "-1",
    placeSubscriptionId:
        subscriptionId, //@TODO add hacky solution to avoid that the alert is deleted again
    publisher: "FOSSWarn_demo_alerts",
    sender: "FOSSWarn - Demo Warnung",
    sent: DateTime.now().toIso8601String(),
    status: Status.actual,
    messageType: MessageType.alert,
    scope: Scope.public,
    info: [
      Info(
        category: [Category.safety],
        event: 'Bombenfund',
        urgency: Urgency.immediate,
        severity: Severity.severe,
        certainty: Certainty.likely,
        headline: 'Weltkriegsbombe in Darmstadt',
        description:
            'Ein möglicher Bombdenfund in der Stadtmitte wird am kommenden Wochenende vom Kampfmittelräumdienst freigelegt und begutachte. Wenn es sich bei dem Objekt tatsächlich um eine Bombe handelt, wird diese – in Abhängigkeit von ihrer Beschaffenheit – entschärft oder kontrolliert gesprengt. Der Evakuierungsbereich um den Freilegungspunkt hat einen Radius von 500 Meter. Das Betretungsverbot tritt gemäß städtischer Allgemeinverfügung am Sonntag (1. Februar) um 7 Uhr in Kraft und gilt vorerst bis 22 Uhr desselben Tages.',
        instruction: 'Meiden Sie das Gebiet und folgen Sie den Anweisungen.',
        contact: "Leitstelle Darmstadt",
        area: [
          Area(
            areaDesc: 'Darmstadt Innenstadt',
            geoJson: """{
              "type": "FeatureCollection",
              "features": [
              {
              "type": "Feature",
              "properties": {},
              "geometry": {
              "coordinates": [
              34.546060738191926,
              42.102042730277276
              ],
              "type": "Point"
              }
              },
              {
                "type": "Feature",
                "properties": {},
                "geometry": {
                  "coordinates": [
                    [
                      [
                        8.652601956301936,
                        49.879183991627855
                      ],
                      [
                        8.652128756719094,
                        49.87812198056673
                      ],
                      [
                        8.652096122265306,
                        49.876975823609854
                      ],
                      [
                        8.652308246216364,
                        49.876292322567025
                      ],
                      [
                        8.652944618068176,
                        49.87538798324158
                      ],
                      [
                        8.654380534042303,
                        49.8745151745768
                      ],
                      [
                        8.65736658657093,
                        49.87424176133476
                      ],
                      [
                        8.65932465380854,
                        49.87465188053619
                      ],
                      [
                        8.661103225080097,
                        49.87587181652211
                      ],
                      [
                        8.66268599609765,
                        49.87690233105809
                      ],
                      [
                        8.662963388956285,
                        49.878195700832265
                      ],
                      [
                        8.662506506600323,
                        49.87929976957105
                      ],
                      [
                        8.661429569619457,
                        49.88029866715203
                      ],
                      [
                        8.659667309106027,
                        49.880929539187264
                      ],
                      [
                        8.657138138925546,
                        49.88089799578145
                      ],
                      [
                        8.654788458239636,
                        49.88071924942494
                      ],
                      [
                        8.653124101088935,
                        49.8801830063849
                      ],
                      [
                        8.652601956301936,
                        49.879183991627855
                      ]
                    ]
                  ],
                  "type": "Polygon"
                }
              }
              ]
          }""",
          ),
        ],
      ),
    ],
  );
}

WarnMessage createWeatherMessage(String subscriptionId) {
  return WarnMessage(
    fpasId: "-1",
    identifier: "-1",
    placeSubscriptionId:
        subscriptionId, //@TODO add hacky solution to avoid that the alert is deleted again
    publisher: "FOSSWarn_demo_alerts",
    sender: "FOSSWarn - Demo Warnung",
    sent: DateTime.now().toIso8601String(),
    status: Status.actual,
    messageType: MessageType.alert,
    scope: Scope.public,
    info: [
      Info(
        category: [Category.met],
        event: 'Frost',
        urgency: Urgency.future,
        severity: Severity.minor,
        certainty: Certainty.likely,
        headline: 'Frost Warnung ',
        description:
            'Es treten Temperaturen von bis zu -2°C auf. Vereinzelnd kann es dadurch zu Forst und Glätte kommen.',
        instruction:
            'Fahren Sie vorsichtig und schützen Sie sich vor Erfrierungen.',
        contact: "Deutscher Wetterdienst",
        area: [
          Area(
            areaDesc: 'Darmstadt Innenstadt',
            geoJson: """{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "coordinates": [
          [
            [
              8.534906618904614,
              50.58714913850048
            ],
            [
              8.25207394114102,
              50.488050484851385
            ],
            [
              7.796898032456397,
              50.17259413005607
            ],
            [
              7.6446035174800215,
              49.95197951164644
            ],
            [
              7.86216711030562,
              49.76496858954522
            ],
            [
              7.7860198528167075,
              49.52783289258022
            ],
            [
              8.083356763010784,
              49.35571824074415
            ],
            [
              8.25015551751045,
              49.3084580876033
            ],
            [
              8.438710625776736,
              49.29190630010061
            ],
            [
              8.661187464162026,
              49.234536875220584
            ],
            [
              8.817108039020582,
              49.210854328271324
            ],
            [
              9.038297691725717,
              49.26294095107406
            ],
            [
              9.16520978754059,
              49.29842306796539
            ],
            [
              9.375521260604614,
              49.35277940388863
            ],
            [
              9.502433356419488,
              49.440096317829585
            ],
            [
              9.60396303307138,
              49.52255055719047
            ],
            [
              9.665606051038395,
              49.67531163764377
            ],
            [
              9.785266027091723,
              49.99105672583923
            ],
            [
              9.698240589961728,
              50.258400193454236
            ],
            [
              9.375521260604614,
              50.49658032916557
            ],
            [
              8.947646194714991,
              50.59105729257294
            ],
            [
              8.534906618904614,
              50.58714913850048
            ]
          ]
        ],
        "type": "Polygon"
      }
    }
  ]
}""",
          ),
        ],
      ),
    ],
  );
}

WarnMessage createFloodMessage(String subscriptionId) {
  return WarnMessage(
    fpasId: "-1",
    identifier: "-1",
    placeSubscriptionId:
        subscriptionId, //@TODO add hacky solution to avoid that the alert is deleted again
    publisher: "FOSSWarn_demo_alerts",
    sender: "FOSSWarn - Demo Warnung",
    sent: DateTime.now().toIso8601String(),
    status: Status.actual,
    messageType: MessageType.alert,
    scope: Scope.public,
    info: [
      Info(
        category: [Category.met],
        event: 'Hochwasser',
        urgency: Urgency.immediate,
        severity: Severity.extreme,
        certainty: Certainty.likely,
        headline: 'Warnung vor extremem Hochwasser',
        description:
            'Infolge von Dauerregen und zusätzlichen Starkregenereignissen, ist mit einem starken Pegelanstiegs zu rechnen.',
        instruction:
            'Bereiten Sie Sandsäcke vor und gehen Sie nicht in voll gelaufene Keller. ',
        contact: "Landes Hochwasserportal Hessen",
        area: [
          Area(
            areaDesc: 'Darmstadt Innenstadt',
            geoJson: """{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "coordinates": [
          [
            [
              8.534906618904614,
              50.58714913850048
            ],
            [
              8.25207394114102,
              50.488050484851385
            ],
            [
              7.796898032456397,
              50.17259413005607
            ],
            [
              7.6446035174800215,
              49.95197951164644
            ],
            [
              7.86216711030562,
              49.76496858954522
            ],
            [
              7.7860198528167075,
              49.52783289258022
            ],
            [
              8.083356763010784,
              49.35571824074415
            ],
            [
              8.25015551751045,
              49.3084580876033
            ],
            [
              8.438710625776736,
              49.29190630010061
            ],
            [
              8.661187464162026,
              49.234536875220584
            ],
            [
              8.817108039020582,
              49.210854328271324
            ],
            [
              9.038297691725717,
              49.26294095107406
            ],
            [
              9.16520978754059,
              49.29842306796539
            ],
            [
              9.375521260604614,
              49.35277940388863
            ],
            [
              9.502433356419488,
              49.440096317829585
            ],
            [
              9.60396303307138,
              49.52255055719047
            ],
            [
              9.665606051038395,
              49.67531163764377
            ],
            [
              9.785266027091723,
              49.99105672583923
            ],
            [
              9.698240589961728,
              50.258400193454236
            ],
            [
              9.375521260604614,
              50.49658032916557
            ],
            [
              8.947646194714991,
              50.59105729257294
            ],
            [
              8.534906618904614,
              50.58714913850048
            ]
          ]
        ],
        "type": "Polygon"
      }
    }
  ]
}""",
          ),
        ],
      ),
    ],
  );
}

WarnMessage createThunderstormMessage(String subscriptionId) {
  return WarnMessage(
    fpasId: "-1",
    identifier: "-1",
    placeSubscriptionId:
    subscriptionId, //@TODO add hacky solution to avoid that the alert is deleted again
    publisher: "FOSSWarn_demo_alerts",
    sender: "FOSSWarn - Demo Warnung",
    sent: DateTime.now().toIso8601String(),
    status: Status.actual,
    messageType: MessageType.alert,
    scope: Scope.public,
    info: [
      Info(
        category: [Category.met],
        event: 'schweres Gewitter',
        urgency: Urgency.immediate,
        severity: Severity.moderate,
        certainty: Certainty.likely,
        headline: 'Warnung vor schwerem Gewitter',
        description:
        'Es zieht ein schweres Gewitter über Darmstadt mit teilweise starkregen und Hagel.',
        instruction:
        'Bleiben Sie wenn möglich drinnen. Blitzschläge sind Lebensgefährlich.',
        contact: "Deutscher Wetterdienst",
        area: [
          Area(
            areaDesc: 'Darmstadt Innenstadt',
            geoJson: """{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "coordinates": [
          [
            [
              8.677139340505505,
              50.53553397442437
            ],
            [
              8.276241916558433,
              50.136098141831184
            ],
            [
              7.93696081045664,
              49.898340862307464
            ],
            [
              7.238238183140112,
              49.48681119146218
            ],
            [
              7.462505769092445,
              48.985344988752814
            ],
            [
              8.071587205454108,
              48.890979399219816
            ],
            [
              8.675555776237019,
              49.0950171224267
            ],
            [
              8.811681675502285,
              49.23407799781572
            ],
            [
              8.73974997565145,
              49.37478485295554
            ],
            [
              8.680328136821316,
              49.628665897405114
            ],
            [
              8.973311105442008,
              49.98491337047031
            ],
            [
              8.938909018102066,
              50.10742357298716
            ],
            [
              9.285502117760956,
              50.20783241660615
            ],
            [
              9.088471809476431,
              50.439452600494576
            ],
            [
              8.677139340505505,
              50.53553397442437
            ]
          ]
        ],
        "type": "Polygon"
      }
    }
  ]
}""",
          ),
        ],
      ),
    ],
  );
}

/// This is build for creating simulated alerts for a controlled lab study.
/// This injected alerts are for demo purpose only and contain no real
/// alert. This is just for demonstrating the reaction of the system
/// in case of a real alert.
///
/// 1. Add the alert to the list of alerts for the frist subscription
Future<void> injectWarning(
    WidgetRef ref, BuildContext context, WarnMessage alert) async {
  // remove old alert first before creating a new one
  removeDemoAlert(ref);
  ref.read(processedAlertsProvider.notifier).updateAlert(alert);
  triggerNotificationForDemoAlert(alert, ref, context);
}

Future<void> injectBombWarning(WidgetRef ref, BuildContext context) async {
  var places = await ref.read(cachedPlacesProvider.future);
  WarnMessage alert = createBombFoundMessage(places.first.subscriptionId);
  if (!context.mounted) return;
  injectWarning(ref, context, alert);
}

Future<void> injectWeatherWarning(WidgetRef ref, BuildContext context) async {
  var places = await ref.read(cachedPlacesProvider.future);
  WarnMessage alert = createWeatherMessage(places.first.subscriptionId);
  if (!context.mounted) return;
  injectWarning(ref, context, alert);
}

Future<void> injectFloodWarning(WidgetRef ref, BuildContext context) async {
  var places = await ref.read(cachedPlacesProvider.future);
  WarnMessage alert = createFloodMessage(places.first.subscriptionId);
  if (!context.mounted) return;
  injectWarning(ref, context, alert);
}

Future<void> injectThunderstormWarning(WidgetRef ref, BuildContext context) async {
  var places = await ref.read(cachedPlacesProvider.future);
  WarnMessage alert = createThunderstormMessage(places.first.subscriptionId);
  if (!context.mounted) return;
  injectWarning(ref, context, alert);
}



/// remove the current demo alert again
void removeDemoAlert(WidgetRef ref) {
  var alerts = ref.read(processedAlertsProvider);
  WarnMessage? alert = alerts.firstWhereOrNull((alert) => alert.fpasId == "-1");
  if (alert != null) {
    ref.read(processedAlertsProvider.notifier).deleteAlert(alert);
  }
}

/// trigger the same methods as if the alert would come as push notification
void triggerNotificationForDemoAlert(
    WarnMessage alert,
    WidgetRef ref,
    BuildContext context) {
  if (NotificationPreferences.checkIfEventShouldBeNotified(
    alert.info[0].severity,
    alert.info[0].category,
    ref.read(userPreferencesProvider),
  )) {
    // push app to the screen with the alert
    var routes = ref.read(routesProvider);
    routes.go("/alerts/${alert.fpasId}/${alert.placeSubscriptionId}");

    List<String> categories = [];
    if (!context.mounted) {
      return;
    }
    for (var cat in alert.info.first.category) {
      categories.add(cat.getLocalizedName(context));
    }
    NotificationService.showNotification(
      id: alert.fpasId.hashCode,
      title: alert.info.first.headline,
      body: alert.info.first.description,
      severity: alert.info.first.severity.getLocalizedName(context),
      instructions: alert.info.first.instruction,
      categories: categories,
      sender: alert.sender,
      alert: alert,
      payload: "",
      channelId:
          "de.nucleus.foss_warn.notifications_${alert.info[0].severity.name}",
      channelName: "",
      userPreferences: ref.read(userPreferencesProvider),
      alertID: alert.fpasId,
    );
  }
}
