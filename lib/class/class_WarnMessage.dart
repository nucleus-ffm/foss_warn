import 'class_Area.dart';

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
    //required this.area,
    //required this.geocodeName,
    //required this.geocodeNumber,
    required this.contact,
    required this.web,
  });
}
