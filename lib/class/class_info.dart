import 'dart:convert';

import '../enums/category.dart';
import '../enums/certainty.dart';
import '../enums/response_type.dart';
import '../enums/severity.dart';
import '../enums/urgency.dart';
import 'class_area.dart';

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
      category: Category.categoryListFromJson(
        (json['category'] as List).map((e) => e as String).toList(),
      ),
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
      area: Area.areaListFromJson(
        (json['area'] as List).map((e) => e as Map<String, dynamic>).toList(),
      ),
      contact: json['contact'] ?? "",
      web: json['web'] ?? "",
    );
  }

  factory Info.fromJsonWithCAPData(Map<String, dynamic> json) {
    var categories = <Category>[];
    if (json['category'] is List) {
      categories =
          Category.categoryListFromJson(List<String>.from(json['category']));
    } else if (json["category"] == null) {
      categories = [Category.other];
    } else {
      categories = [Category.fromString(json['category'])];
    }

    var areas = <Area>[];
    if (json['area'] is List) {
      areas = Area.areaListFromJsonWithCAPData(
        (json['area'] as List)
            .map((area) => area as Map<String, dynamic>)
            .toList(),
      );
    } else {
      areas = [Area.areaFromJsonWithCAPData(json['area'])];
    }

    return Info(
      category: categories,
      event: json['event'],
      urgency: Urgency.fromJson(json['urgency']),
      severity: Severity.fromJson(json['severity']),
      certainty: Certainty.fromJson(json['certainty']),
      effective: json['effective'],
      onset: json['onset'],
      expires: json['expires'],
      headline: json['headline'] ?? "",
      description: json['description'] ?? "", //@todo can also be null
      instruction: json['instruction'],
      area: areas,
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
        'web': web,
      };

  /// create a list of Info elements from the json [data]
  static List<Info> infoListFromJson(List<Map<String, dynamic>>? data) {
    List<Info> result = [];
    if (data != null) {
      if (data is Map) {
        // there is just one info section
        result.add(Info.fromJson(data as Map<String, dynamic>));
      } else {
        // there are multiple info sections
        for (int i = 0; i < data.length; i++) {
          result.add(Info.fromJson(data[i]));
        }
      }
    }
    return result;
  }

  /// used for the FPAS data
  static List<Info> infoListFromJsonWithCAPIData(dynamic data) {
    List<Info> result = [];
    if (data != null) {
      if (data is Map<String, dynamic>) {
        // just one entry
        result.add(Info.fromJsonWithCAPData(data));
      } else {
        // multiple entries
        var listData = List<Map<String, dynamic>>.from(data);
        for (int i = 0; i < listData.length; i++) {
          result.add(Info.fromJsonWithCAPData(listData[i]));
        }
      }
    }
    return result;
  }
}
