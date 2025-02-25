import 'package:foss_warn/class/class_bounding_box.dart';

class Place {
  final String _name;
  String eTag;

  BoundingBox boundingBox;
  String subscriptionId;

  Place({
    required String name,
    required this.boundingBox,
    required this.subscriptionId,
    String? eTag,
  })  : _name = name,
        eTag = eTag ?? "";

  Place copyWith({
    String? name,
    String? eTag,
    BoundingBox? boundingBox,
    String? subscriptionId,
  }) =>
      Place(
        name: name ?? _name,
        eTag: eTag ?? this.eTag,
        boundingBox: boundingBox ?? this.boundingBox,
        subscriptionId: subscriptionId ?? this.subscriptionId,
      );

  String get name => _name;

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'] as String,
      boundingBox: BoundingBox.fromJson(json['boundingBox']),
      subscriptionId: json['subscriptionId'] as String,
      eTag: (json['eTag'] ?? "") as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': _name,
      'boundingBox': boundingBox,
      'subscriptionId': subscriptionId,
      'eTag': eTag,
    };
  }
}
