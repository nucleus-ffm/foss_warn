import 'package:foss_warn/class/class_bounding_box.dart';

class Place {
  final String id; // Unique and unchangeable identifier of this location
  final String _name;
  String eTag;

  BoundingBox boundingBox;
  String subscriptionId;
  bool isExpired;

  Place({
    required this.id,
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
        id: id,
        name: name ?? _name,
        eTag: eTag ?? this.eTag,
        boundingBox: boundingBox ?? this.boundingBox,
        subscriptionId: subscriptionId ?? this.subscriptionId,
        isExpired: isExpired ?? this.isExpired,
      );

  String get name => _name;

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'] as String,
      boundingBox: BoundingBox.fromJson(json['boundingBox']),
      subscriptionId: json['subscriptionId'] as String,
      eTag: (json['eTag'] ?? "") as String,
      isExpired: (json['isExpired'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': _name,
      'boundingBox': boundingBox,
      'subscriptionId': subscriptionId,
      'eTag': eTag,
      'isExpired': isExpired,
    };
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is Place) {
      return id == other.id;
    }
    return false;
  }
}
