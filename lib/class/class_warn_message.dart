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
///   - restriction (CONDITIONAL) Used when <scope> value is "Restricted".
///   - addresses (CONDITIONAL) Required when <scope> is “Private”, optional when <scope> isPublic” or “Restricted”.
///   - code (OPTIONAL) Any user-defined flag or special code used to flag the alert message for special handling.
///   - note (OPTIONAL) The message note is primarily intended for  use with <status> “Exercise” and<msgType> “Error”.
///   - references (OPTIONAL)  The message note is primarily intended for use with <status> “Exercise” and <msgType> “Error”.
///   - incidents (OPTIONAL) Used to collate multiple messages referring to different aspects of the same incident.
///   - info  (OPTIONAL) The container for all component parts of the info sub-element of the alert message
class WarnMessage {
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
    required String placeSubscriptionId,
  }) =>
      WarnMessage(
        identifier: json['identifier'] ?? '?',
        placeSubscriptionId: placeSubscriptionId,
        publisher: json['publisher'] ?? "?",
        sender: json['sender'] ?? "?",
        sent: json['sent'] ?? "?",
        status: Status.fromJson(json['status']),
        messageType: MessageType.fromJson(json['messageType']),
        scope: Scope.fromJson(json['scope']),
        info: Info.infoListFromJson(
          (json['info'] as List<dynamic>)
              .map((e) => e as Map<String, dynamic>)
              .toList(),
        ),
        notified: json['notified'] ?? false, //@todo check
        read: json['read'] ?? false,
        references: json['references'] != null
            ? References.fromJson(json['references'])
            : null,
        isUpdateOfAlreadyNotifiedWarning:
            json['isUpdateOfAlreadyNotifiedWarning'] ?? false,
        hideWarningBecauseThereIsANewerVersion:
            json['hideWarningBecauseThereIsANewerVersion'] ?? false,
      );

  /// is used to create a new WarnMessage object with data from the API call.
  /// Note that the json structure is different from the structure we use to
  /// cache the warnings.
  factory WarnMessage.fromJsonFPAS(
    Map<String, dynamic> json, {
    required String placeSubscriptionId,
  }) =>
      WarnMessage(
        identifier: json["identifier"] ?? "?",
        placeSubscriptionId: placeSubscriptionId,
        sender: json["sender"] ?? "?",
        sent: json["sent"] ?? "?",
        status: Status.fromJson(json["status"]),
        messageType: MessageType.fromJson(json["msgType"]),
        scope: Scope.fromJson(json["scope"]),
        publisher: "", //@todo
        info: Info.infoListFromJsonWithCAPIData(json['info']),
        references: json["references"] == null
            ? null
            : References.fromString(json['references']),
        notified: false,
        read: false,
      );

  Map<String, dynamic> toJson() => {
        'identifier': identifier,
        'publisher': publisher,
        'sender': sender,
        'sent': sent,
        'status': status,
        'messageType': messageType,
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
