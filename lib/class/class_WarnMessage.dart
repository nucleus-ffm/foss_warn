import 'class_Area.dart';
import '../services/createAreaListFromjson.dart';

class WarnMessage {
  String identifier;
  String publisher;
  String source;
  String sender;
  String sent;
  String status;
  String messageTyp;
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
    required this.messageTyp,
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

  WarnMessage.fromJson(Map<String, dynamic> json)
      : identifier = json['identifier'],
        publisher = json['publisher'],
        source = json['source'],
        sender = json['sender'],
        sent = json['sent'],
        status = json['status'],
        messageTyp = json['messageTyp'],
        scope = json['scope'],
        category = json['category'],
        event = json['event'],
        urgency = json['urgency'],
        severity = json['severity'],
        certainty = json['certainty'],
        effective =  json['effective'],
        onset = json['onset'],
        expires = json['expires'],
        headline = json['headline'],
        description = json['description'],
        instruction = json['instruction'],
        areaList = areaListFromJson(json['areaList']),
        contact = json['contact'],
        web = json['web'] ?? "";


  Map<String, dynamic> toJson() => {
    'identifier': identifier,
    'publisher':publisher,
    'source':source,
    'sender':sender,
    'sent':sent,
    'status':status,
    'messageTyp':messageTyp,
    'scope':scope,
    'category':category,
    'event':category,
    'urgency':urgency,
    'severity':severity,
    'certainty':certainty,
    'effective':effective,
    'onset':onset,
    'expires':expires,
    'headline':headline,
    'description':description,
    'instruction':instruction,
    'areaList':areaList,
    'contact':contact,
  };
}
