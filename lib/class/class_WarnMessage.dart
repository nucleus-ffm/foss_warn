import 'package:foss_warn/enums/WarningSource.dart';

import '../enums/Certainty.dart';
import '../enums/Severity.dart';
import 'class_Area.dart';
import '../services/createAreaListFromJson.dart';

class WarnMessage {
  final String identifier;
  final String publisher;
  final WarningSource source;
  final String sender;
  final String sent;
  final String status;
  final String messageType;
  final String scope;
  final String category;
  final String event;
  final String urgency;
  final Severity severity;
  final Certainty certainty;
  final String headline;
  final String description;
  final String instruction;
  final List<Area> areaList;
  final String contact;
  final String web;
  // specific for warnings from DWD
  final String effective;
  final String onset;
  final String expires;

  bool notified = false;
  bool read = false;

  WarnMessage({
    required this.identifier,
    required this.publisher,
    required this.source,
    required this.sender,
    required this.sent,
    required this.status,
    required this.messageType,
    required this.scope,
    required this.category,
    required this.event,
    required this.urgency,
    required this.severity,
    required this.certainty,
    this.effective = "",
    this.onset = "",
    this.expires = "",
    required this.headline,
    required this.description,
    required this.instruction,
    required this.areaList,
    required this.contact,
    this.web = "",
    required this.notified,
    required this.read,
  });

  factory WarnMessage.fromJson(Map<String, dynamic> json) {
    return WarnMessage(
        identifier: json['identifier'],
        publisher: json['publisher'],
        source: WarningSource.fromString(json['source'].toString()),
        sender: json['sender'],
        sent: json['sent'],
        status: json['status'],
        messageType: json['messageType'],
        scope: json['scope'],
        category: json['category'],
        event: json['event'],
        urgency: json['urgency'],
        severity: Severity.fromJson(json['severity']),
        certainty: Certainty.fromJson(json['certainty']),
        effective: json['effective'],
        onset: json['onset'],
        expires: json['expires'],
        headline: json['headline'],
        description: json['description'],
        instruction: json['instruction'],
        areaList: areaListFromJson(json['areaList']),
        contact: json['contact'],
        web: json['web'] ?? "",
        notified: json['notified'] as bool,
        read: json['read'] as bool
    );
  }

  /// is used to create a new WarnMessage object with data from the API call.
  /// Note that the json structure is different from the structure we use to
  /// cache the warnings.
  factory WarnMessage.fromJsonTemp(Map<String, dynamic> json, String provider,
      String publisher, List<Area> areaList) {
    print("Neue WarnMessage wird angelegt...");
    return WarnMessage(
        source: WarningSource.fromString(provider),
        identifier: json["identifier"] ?? "?",
        sender: json["sender"] ?? "?",
        sent: json["sent"] ?? "?",
        status: json["status"] ?? "?",
        messageType: json["msgType"] ?? "?",
        scope: json["scope"] ?? "?",
        category: json["info"][0]["category"][0] ?? "?",
        event: json["info"][0]["event"] ?? "?",
        urgency: json["info"][0]["urgency"] ?? "?",
        severity: getSeverity(json["info"][0]["severity"].toString().toLowerCase()),
        certainty: getCertainty(json["info"][0]["certainty"].toString().toLowerCase()),
        effective: json["info"][0]["effective"] ?? "",
        onset: json["info"][0]["onset"] ?? "",
        expires: json["info"][0]["expires"] ?? "",
        headline: json["info"][0]["headline"] ?? "?",
        description: json["info"][0]["description"] ?? "",
        instruction: json["info"][0]["instruction"] ?? "",
        publisher: publisher,
        contact: json["info"][0]["contact"] ?? "",
        web: json["info"][0]["web"] ?? "",
        areaList: areaList,
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
        status: "?", // missing for alert swiss
        messageType: "Alert", // missing
        scope: "?", // missing
        category: json["event"] ?? "?", // missing
        event: json["event"] ?? "?",
        urgency: "?",
        severity: getSeverity(json["severity"]),
        certainty: getCertainty(""), // missing
        effective: "", // missing
        onset: json["onset"] ?? "", // m
        expires: json["expires"] ?? "", // m
        headline: json["title"] ?? "?",
        description: json["description"] ?? "",
        instruction: instructions,
        publisher: license,
        contact: json["contact"] ?? "",
        web: json["link"] ?? "",
        areaList: areaList,
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
        'category': category,
        'event': category,
        'urgency': urgency,
        'severity': severity,
        'certainty': certainty,
        'effective': effective,
        'onset': onset,
        'expires': expires,
        'headline': headline,
        'description': description,
        'instruction': instruction,
        'areaList': areaList,
        'contact': contact,
        'notified': notified,
        'read': read
      };
}
