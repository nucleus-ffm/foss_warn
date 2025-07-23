import 'package:foss_warn/class/class_references.dart';
import '../enums/message_type.dart';
import '../enums/scope.dart';
import '../enums/status.dart';
import 'class_info.dart';

/// WarnMessage class this data structure follows mostly the Common Alerting Protocol Version 1.2
///
/// See: http://docs.oasis-open.org/emergency/cap/v1.2/CAP-v1.2-os.html
/// Properties:
///   - identifier
///   - publisher
///   - sender (REQUIRED) The identifier  of the sender of the alert message
///   - sent (REQUIRED) The time and date of the origination of the alert   message
///   - status (REQUIRED) The code denoting the appropriate handling of the alert message
///   - messageType (REQUIRED) The code denoting the nature of the alert message
///   - source (OPTIONAL) The text identifying the source of the alert message
///   - scope (REQUIRED) The code denoting the intended distribution of the alert message
///   - restriction (CONDITIONAL) Used when `<scope>` value is "Restricted".
///   - addresses (CONDITIONAL) Required when `<scope>` is “Private”, optional when `<scope>` isPublic” or “Restricted”.
///   - code (OPTIONAL) Any user-defined flag or special code used to flag the alert message for special handling.
///   - note (OPTIONAL) The message note is primarily intended for  use with `<status>` “Exercise” and `<msgType>` “Error”.
///   - references (OPTIONAL)  The message note is primarily intended for use with `<status>` “Exercise” and `<msgType>` “Error”.
///   - incidents (OPTIONAL) Used to collate multiple messages referring to different aspects of the same incident.
///   - info  (OPTIONAL) The container for all component parts of the info sub-element of the alert message
class WarnMessage {
  final String fpasId;
  final String identifier;
  final String placeSubscriptionId;
  final String publisher;
  final String sender;
  final String sent;
  final Status status;
  final MessageType messageType;
  final Scope scope;
  final String? restriction;
  final String? addresses;
  final String? code;
  final String? note;
  final References? references;
  final String? incidents;
  final List<Info> info;

  final bool notified;
  final bool read;
  final bool isUpdateOfAlreadyNotifiedWarning;
  final bool hideWarningBecauseThereIsANewerVersion;

  WarnMessage({
    required this.fpasId,
    required this.identifier,
    required this.placeSubscriptionId,
    required this.publisher,
    required this.sender,
    required this.sent,
    required this.status,
    required this.messageType,
    required this.scope,
    required this.info,
    this.restriction,
    this.addresses,
    this.code,
    this.note,
    this.references,
    this.incidents,
    this.notified = false,
    this.read = false,
    this.isUpdateOfAlreadyNotifiedWarning = false,
    this.hideWarningBecauseThereIsANewerVersion = false,
  });

  WarnMessage copyWith({
    String? identifier,
    String? publisher,
    String? sender,
    String? sent,
    Status? status,
    MessageType? messageType,
    Scope? scope,
    List<Info>? info,
    bool? notified,
    bool? read,
    bool? isUpdateOfAlreadyNotifiedWarning,
    bool? hideWarningBecauseThereIsANewerVersion,
  }) =>
      WarnMessage(
        fpasId: fpasId,
        identifier: identifier ?? this.identifier,
        placeSubscriptionId: placeSubscriptionId,
        publisher: publisher ?? this.publisher,
        sender: sender ?? this.sender,
        sent: sent ?? this.sent,
        status: status ?? this.status,
        messageType: messageType ?? this.messageType,
        scope: scope ?? this.scope,
        info: info ?? this.info,
        notified: notified ?? this.notified,
        read: read ?? this.read,
        isUpdateOfAlreadyNotifiedWarning: isUpdateOfAlreadyNotifiedWarning ??
            this.isUpdateOfAlreadyNotifiedWarning,
        hideWarningBecauseThereIsANewerVersion:
            hideWarningBecauseThereIsANewerVersion ??
                this.hideWarningBecauseThereIsANewerVersion,
      );

  factory WarnMessage.fromJson(
    Map<String, dynamic> json, {
    required String fpasId,
    required String placeSubscriptionId,
  }) =>
      WarnMessage(
        fpasId: fpasId,
        identifier: json["identifier"] ?? "?",
        placeSubscriptionId: placeSubscriptionId,
        sender: json["sender"] ?? "?",
        sent: json["sent"] ?? "?",
        status: Status.fromJson(json["status"]),
        messageType: json["msgType"] != null
            ? MessageType.fromJson(json["msgType"])
            : MessageType.alert,
        scope: Scope.fromJson(json["scope"]),
        publisher: "", //@todo
        info: Info.infoListFromJsonWithCAPIData(json['info']),
        references: json["references"] == null
            ? null
            : References.fromStringOrJson(json['references']),
        notified: json['notified'] ?? false,
        read: json['read'] ?? false,
      );

  factory WarnMessage.fromJsonFromStorage(
    Map<String, dynamic> json,
  ) =>
      WarnMessage.fromJson(
        json,
        fpasId: json['fpasId'],
        placeSubscriptionId: json['placeSubscriptionId'],
      );

  Map<String, dynamic> toJson() => {
        'fpasId': fpasId,
        'placeSubscriptionId': placeSubscriptionId,
        'identifier': identifier,
        'publisher': publisher,
        'sender': sender,
        'sent': sent,
        'status': status,
        'msgType':
            messageType, // we are using the msgType here to be compatibel with CAP
        'scope': scope,
        'notified': notified,
        'read': read,
        'info': info,
        'references': references,
        'isUpdateOfAlreadyNotifiedWarning': isUpdateOfAlreadyNotifiedWarning,
        'hideWarningBecauseThereIsANewerVersion':
            hideWarningBecauseThereIsANewerVersion,
      };

  @override
  bool operator ==(Object other) {
    if (other is! WarnMessage) return false;

    return other.identifier == identifier;
  }

  @override
  int get hashCode => identifier.hashCode;
}
