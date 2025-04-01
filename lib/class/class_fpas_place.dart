import 'package:foss_warn/class/class_bounding_box.dart';

class Place {
  final String _name;
  String eTag;

  BoundingBox boundingBox;
  String subscriptionId;
  bool isExpired;

  Place({
    required String name,
    required this.boundingBox,
    required this.subscriptionId,
    String? eTag,
    bool? isExpired,
  })  : _name = name,
        eTag = eTag ?? "",
        isExpired = isExpired ?? false;

  Place copyWith({
    String? name,
    String? eTag,
    BoundingBox? boundingBox,
    String? subscriptionId,
    bool? isExpired,
  }) =>
      Place(
        name: name ?? _name,
        eTag: eTag ?? this.eTag,
        boundingBox: boundingBox ?? this.boundingBox,
        subscriptionId: subscriptionId ?? this.subscriptionId,
        isExpired: isExpired ?? this.isExpired,
      );

  String get name => _name;

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'] as String,
      boundingBox: BoundingBox.fromJson(json['boundingBox']),
      subscriptionId: json['subscriptionId'] as String,
      eTag: (json['eTag'] ?? "") as String,
      isExpired: (json['isExpired'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': _name,
      'boundingBox': boundingBox,
      'subscriptionId': subscriptionId,
      'eTag': eTag,
      'isExpired': isExpired,
    };
  }
}
