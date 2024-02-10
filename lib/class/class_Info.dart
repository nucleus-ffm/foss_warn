import 'dart:convert';

import '../enums/Category.dart';
import '../enums/Certainty.dart';
import '../enums/ResponseType.dart';
import '../enums/Severity.dart';
import '../enums/Urgency.dart';
import 'class_Area.dart';

class Info {
  String? language;              // (OPTIONAL) The code denoting the language of the info subelement of the alert message
  final List<Category> category; // (REQUIRED) The code denoting the category of the subject event of the alert message
  final String event;            // (REQUIRED) The text denoting the type of the subject event of the alert message
  ResponseType? responseType;    // (OPTIONAL) The code denoting the type of actionrecommended for the target audience
  final Urgency urgency;         // (REQUIRED) The code denoting the urgency of the subject eventof the alert message
  final Severity severity;       // (REQUIRED) The code denoting the severity of the subject event of the alert message
  final Certainty certainty;     // (REQUIRED) The code denoting the certainty ofthe subject event of the alert message
  String? audience;              // (OPTIONAL) The text describing the intended audience of thealert message
  Map<String,
      String>? eventCode;        // (OPTIONAL) A system specific code identifying theevent type of the alert message
  String? effective;             // (OPTIONAL) The effective time of the information of the alert message
  String? onset;                 // (OPTIONAL) The expected time of the beginning of the subjectevent of the alert message
  String? expires;               // (OPTIONAL) The expiry time of the information of the alert message
  String? senderName;            // (OPTIONAL) The text naming the originator of the alert message
  String headline;               // (OPTIONAL) The text headline of the alert message
  String description;            // (OPTIONAL) The text describing the subject event of the alertmessage
  String? instruction;           // (OPTIONAL) The text describing the recommended action to be taken by recipients of the alert message
  String? web;                   // (OPTIONAL)  The identifier of the hyperlink associating additional information with the alert message
  String? contact;               // (OPTIONAL)
  final List<Area> area;

  Info({
    required this.category,
    required this.event,
    required this.urgency,
    required this.severity,
    required this.certainty,
    this.effective,
    this.onset,
    this.expires,
    required this.headline,
    required this.description,
    required this.instruction,
    this.contact,
    this.web,
    required this.area,
  });


  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(
      category: Category.categoryListFromJson(json['category']),
      event: json['event'],
      urgency: Urgency.fromJson(json['urgency']),
      severity: Severity.fromJson(json['severity']),
      certainty: Certainty.fromJson(json['certainty']),
      effective: json['effective'],
      onset: json['onset'],
      expires: json['expires'],
      headline: json['headline'],
      description: json['description'],
      instruction: json['instruction'],
      area: Area.areaListFromJson(json['area']),
      contact: json['contact'] ?? "",
      web: json['web'] ?? "",
    );
  }

  factory Info.fromJsonTemp(Map<String, dynamic> json, List<dynamic> coordinates) {
    return Info(
      category: Category.categoryListFromJson(json['category']),
      event: json['event'],
      urgency: Urgency.fromJson(json['urgency']),
      severity: Severity.fromJson(json['severity']),
      certainty: Certainty.fromJson(json['certainty']),
      effective: json['effective'],
      onset: json['onset'],
      expires: json['expires'],
      headline: json['headline'],
      description: json['description'],
      instruction: json['instruction'],
      area: Area.areaListFromJsonTemp(json['area'], coordinates),
      contact: json['contact'],
      web: json['web'] ?? "",
    );
  }

  static List<Info> infoListFromJson(var data) {
    List<Info> _result = [];
    if(data != null) {
      for (int i = 0; i < data.length; i++) {
        _result.add(Info.fromJson(data[i] ));
      }
    }
    return _result;
  }

  /// used for the API calls
  static List<Info> infoListFromJsonTemp(var data, List<dynamic> coordinates) {
    List<Info> _result = [];
    if(data != null) {
      for (int i = 0; i < data.length; i++) {
        _result.add(Info.fromJsonTemp(data[i], coordinates ));
      }
    }
    return _result;
  }

  Map<String, dynamic> toJson() => {
    'language': language,
    'event': event,
    'category': category,
    'responseType': responseType,
    'urgency': urgency,
    'severity': severity,
    'certainty': certainty,
    'audience': audience,
    'eventCode': jsonEncode(eventCode), //@TODO nötig?
    'effective': effective,
    'onset': onset,
    'expires': expires,
    'headline': headline,
    'description': description,
    'instruction': instruction,
    'area': area,
    'contact': contact,
    'web' : web
  };
}