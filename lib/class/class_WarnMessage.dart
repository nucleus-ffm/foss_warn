import 'package:foss_warn/class/class_References.dart';
import 'package:foss_warn/enums/Certainty.dart';
import 'package:foss_warn/enums/Urgency.dart';
import 'package:foss_warn/enums/WarningSource.dart';
import '../enums/MessageType.dart';
import '../enums/Scope.dart';
import '../enums/Severity.dart';
import '../enums/Status.dart';
import 'class_Area.dart';
import 'class_Info.dart';

class WarnMessage {
  final String identifier;
  final String publisher;
  final String
      sender; // (REQUIRED) The identifier  of the sender of the alertmessage
  final String
      sent; // (REQUIRED) The time and date of the origination of the alert   message
  final Status
      status; // (REQUIRED) The code denoting the appropriate handling of the alert message
  final MessageType
      messageType; // (REQUIRED) The code denoting the nature of the alert message
  final WarningSource
      source; // (OPTIONAL) The text identifying the source of the alert message
  final Scope
      scope; // (REQUIRED) The code denoting the intended distribution ofthe alert message
  String? restriction; // (CONDITIONAL) Used when <scope> value is "Restricted".
  String?
      addresses; // (CONDITIONAL) Required when <scope> is “Private”, optional when <scope> isPublic” or “Restricted”.
  String?
      code; // (OPTIONAL) Any user-defined flag or special code used to flag the alert message for special handling.
  String?
      note; // (OPTIONAL) The message note is primarily intended for  use with <status> “Exercise” and<msgType> “Error”.
  References?
      references; // (OPTIONAL)  The message note is primarily intended for use with <status> “Exercise” and <msgType> “Error”.
  String?
      incidents; // (OPTIONAL) Used to collate multiple messages referring to different aspects of the same incident.
  final List<Info>
      info; //  (OPTIONAL) The containerfor all component parts of the info sub-element of the alertmessage

  bool notified = false;
  bool read = false;
  bool isUpdateOfAlreadyNotifiedWarning = false;

  WarnMessage({
    required this.identifier,
    required this.publisher,
    required this.source,
    required this.sender,
    required this.sent,
    required this.status,
    required this.messageType,
    required this.scope,
    restriction,
    addresses,
    code,
    note,
    references,
    incidents,
    required this.info,
    required this.notified,
    required this.read,
    isUpdateOfAlreadyNotifiedWarning,
  });

  factory WarnMessage.fromJson(Map<String, dynamic> json) {
    return WarnMessage(
      identifier: json['identifier'] ?? '?',
      publisher: json['publisher'] ?? "?",
      source: WarningSource.fromString(json['source'].toString()),
      sender: json['sender'] ?? "?",
      sent: json['sent'] ?? "?",
      status: Status.fromJson(json['status']),
      messageType: MessageType.fromJson(json['messageType']),
      scope: Scope.fromJson(json['scope']),
      info: Info.infoListFromJson(json['info']),
      notified: json['notified'] ?? false, //@todo check
      read: json['read'] ?? false,
      references: json['references'] != null
          ? References.fromString(json['references'])
          : null,
      isUpdateOfAlreadyNotifiedWarning:
          json['isUpdateOfAlreadyNotifiedWarning'] ?? false,
    );
  }

  /// is used to create a new WarnMessage object with data from the API call.
  /// Note that the json structure is different from the structure we use to
  /// cache the warnings.
  factory WarnMessage.fromJsonTemp(Map<String, dynamic> json, String provider,
      String publisher, List<dynamic> coordinates) {
    // print("Neue WarnMessage wird angelegt...");
    return WarnMessage(
        source: WarningSource.fromString(provider),
        identifier: json["identifier"] ?? "?",
        sender: json["sender"] ?? "?",
        sent: json["sent"] ?? "?",
        status: Status.fromJson(json["status"]),
        messageType: MessageType.fromJson(json["msgType"]),
        scope: Scope.fromJson(json["scope"]),
        publisher: publisher,
        info: Info.infoListFromJsonTemp(json['info'], coordinates),
        references: json['references'] != null
            ? References.fromString(json['references'])
            : null,
        notified: false,
        read: false);
  }

  /// is used to create a new WarnMessage object with data from the API call.
  /// Note that the json structure is different from the structure we use to
  /// cache the warnings.
  factory WarnMessage.fromJsonAlertSwiss(Map<String, dynamic> json,
      List<Area> areaList, String instructions, String license) {
    return WarnMessage(
        source: WarningSource.alertSwiss,
        identifier: json["identifier"] ?? "?",
        sender: json["sender"] ?? "?",
        sent: json["sent"] ?? "?",
        status: Status.Actual, // missing for alert swiss
        messageType: MessageType.Alert, // missing
        scope: Scope.Public, // missing
        publisher: license,
        info: [
          Info(
              category: [],
              event: json["event"] ?? "",
              urgency: Urgency.Unknown,
              severity: Severity.fromString(json["severity"]),
              certainty: Certainty.Unknown,
              headline: json["title"]["title"] ?? "?",
              description: json["description"]["description"] ?? "",
              instruction: instructions,
              area: areaList)
        ],
        notified: false,
        read: false);
  }

  Map<String, dynamic> toJson() => {
        'identifier': identifier,
        'publisher': publisher,
        'source': source,
        'sender': sender,
        'sent': sent,
        'status': status,
        'messageType': messageType,
        'scope': scope,
        'notified': notified,
        'read': read,
        'info': info,
        'references': references,
        'isUpdateOfAlreadyNotifiedWarning': isUpdateOfAlreadyNotifiedWarning
      };
}
