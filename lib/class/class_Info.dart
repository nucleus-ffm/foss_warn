import 'dart:convert';

import '../enums/Category.dart';
import '../enums/Certainty.dart';
import '../enums/ResponseType.dart';
import '../enums/Severity.dart';
import '../enums/Urgency.dart';
import 'class_Area.dart';

/// Info class - this data structure follows mostly the Common Alerting Protocol Version 1.2
/// See: http://docs.oasis-open.org/emergency/cap/v1.2/CAP-v1.2-os.html
/// Properties:
///   - language (OPTIONAL) The code denoting the language of the info subelement of the alert message
///   - category (REQUIRED) The code denoting the category of the subject event of the alert message
///   - event (REQUIRED) The text denoting the type of the subject event of the alert message
///   - responseType (OPTIONAL) The code denoting the type of action recommended for the target audience
///   - urgency (REQUIRED) The code denoting the urgency of the subject event of the alert message
///   - severity (REQUIRED) The code denoting the severity of the subject event of the alert message
///   - certainty (REQUIRED) The code denoting the certainty of the subject event of the alert message
///   - audience (OPTIONAL) The text describing the intended audience of the alert message
///   - eventCode (OPTIONAL) A system specific code identifying the event type of the alert message
///   - effective (OPTIONAL) The effective time of the information of the alert message
///   - onset (OPTIONAL) The expected time of the beginning of the subjectevent of the alert message
///   - expires (OPTIONAL) The expiry time of the information of the alert message
///   - senderName (OPTIONAL) The text naming the originator of the alert message
///   - headline (OPTIONAL) The text headline of the alert message
///   - description (OPTIONAL) The text describing the subject event of the alert message
///   - instruction (OPTIONAL) The text describing the recommended action to be taken by recipients of the alert message
///   - web (OPTIONAL)  The identifier of the hyperlink associating additional information with the alert message
///   - contact (OPTIONAL)
///   - area (REQUIRED) The area of the alert
class Info {
  String? language;
  final List<Category> category;
  final String event;
  ResponseType? responseType;
  final Urgency urgency;
  final Severity severity;
  final Certainty certainty;
  String? audience;
  Map<String, String>? eventCode;
  String? effective;
  String? onset;
  String? expires;
  String? senderName;
  String headline;
  String description;
  String? instruction;
  String? web;
  String? contact;
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

  factory Info.fromJsonWithAPIData(Map<String, dynamic> json, String geoJson) {
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
      area: Area.areaListFromJsonWithAPIData(json['area'], geoJson),
      contact: json['contact'],
      web: json['web'] ?? "",
    );
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
        'web': web
      };

  /// create a list of Info elements from the json [data]
  static List<Info> infoListFromJson(var data) {
    List<Info> _result = [];
    if (data != null) {
      for (int i = 0; i < data.length; i++) {
        _result.add(Info.fromJson(data[i]));
      }
    }
    return _result;
  }

  /// used for the API calls
  static List<Info> infoListFromJsonWithAPIData(var data, String geoJson) {
    List<Info> _result = [];
    if (data != null) {
      for (int i = 0; i < data.length; i++) {
        _result.add(Info.fromJsonWithAPIData(data[i], geoJson));
      }
    }
    return _result;
  }
}
