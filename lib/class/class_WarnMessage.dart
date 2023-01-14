import 'class_Area.dart';
import '../services/createAreaListFromjson.dart';

class WarnMessage {
  String identifier;
  String publisher;
  String source;
  String sender;
  String sent;
  String status;
  String messageType;
  String scope;
  String category;
  String event;
  String urgency;
  String severity;
  String certainty;
  String effective; // just for DWD
  String onset; // just for DWD
  String expires; // just for DWD
  String headline;
  String description;
  String instruction;
  List<Area> areaList;
  //String area;
  //List<String> geocodeName;
  //String geocodeNumber;
  String contact;
  String web;

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
    //required this.area,
    //required this.geocodeName,
    //required this.geocodeNumber,
  });

  factory WarnMessage.fromJson(Map<String, dynamic> json) {
    return WarnMessage(
        identifier: json['identifier'],
        publisher: json['publisher'],
        source: json['source'],
        sender: json['sender'],
        sent: json['sent'],
        status: json['status'],
        messageType: json['messageType'],
        scope: json['scope'],
        category: json['category'],
        event: json['event'],
        urgency: json['urgency'],
        severity: json['severity'],
        certainty: json['certainty'],
        effective: json['effective'],
        onset: json['onset'],
        expires: json['expires'],
        headline: json['headline'],
        description: json['description'],
        instruction: json['instruction'],
        areaList: areaListFromJson(json['areaList']),
        contact: json['contact'],
        web: json['web'] ?? "");
  }

  /// is used to create a new WarnMessage object with data from the API call.
  /// Note that the json structure is different from the structure we use to
  /// cache the warnings.
  factory WarnMessage.fromJsonTemp(Map<String, dynamic> json, String provider,
      String publisher, List<Area> areaList) {
    return WarnMessage(
        source: provider,
        identifier: json["identifier"] ?? "?",
        sender: json["sender"] ?? "?",
        sent: json["sent"] ?? "?",
        status: json["status"] ?? "?",
        messageType: json["msgType"] ?? "?",
        scope: json["scope"] ?? "?",
        category: json["info"][0]["category"][0] ?? "?",
        event: json["info"][0]["event"] ?? "?",
        urgency: json["info"][0]["urgency"] ?? "?",
        severity: json["info"][0]["severity"].toString().toLowerCase(),
        certainty: json["info"][0]["certainty"] ?? "?",
        effective: json["info"][0]["effective"] ?? "",
        onset: json["info"][0]["onset"] ?? "",
        expires: json["info"][0]["expires"] ?? "",
        headline: json["info"][0]["headline"] ?? "?",
        description: json["info"][0]["description"] ?? "",
        instruction: json["info"][0]["instruction"] ?? "",
        publisher: publisher,
        contact: json["info"][0]["contact"] ?? "",
        web: json["info"][0]["web"] ?? "",
        areaList: areaList);
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
      };
}
