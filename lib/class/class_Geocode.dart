class Geocode {
  String geocodeName;
  String geocodeNumber;

  Geocode({required this.geocodeName, required this.geocodeNumber});

  Geocode.fromJson(Map<String, dynamic> json)
      : geocodeName = json['geocodeName'],
        geocodeNumber = json['geocodeNumber'];

  Map<String, dynamic> toJson() => {
    'geocodeName': geocodeName,
    'geocodeNumber': geocodeNumber,
  };
}