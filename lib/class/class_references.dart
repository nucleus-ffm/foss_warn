/// Class to store one or more warnings that are referenced by another warning
class References {
  final String sender;
  final List<String> identifier;
  final String send;

  References({
    required this.sender,
    required this.identifier,
    required this.send,
  });

  /// construct a References either from String or from json
  /// we are using this method as the references data in CAP alerts from the API are
  /// Strings, but after we stored these alerts on disk, they are Maps
  factory References.fromStringOrJson(var references) {
    if (references is Map<String, dynamic>) {
      return References.fromJson(references);
    }
    return References.fromString(references);
  }

  /// create References object by extracting the data
  /// from a String in format `<sender>,<identifier>,<sent>`
  factory References.fromString(String references) {
    // Example data: trinet@caltech.edu,TRI13970876.1,2003-06-11T20:30:00-07:00
    // if more then one alert is referred, the identifiers are separated by spaces
    List<String> rawReferencesData = references.split(',');
    // Check if the data has the right format. If not, just try to read
    // the IDs. This is a workaround for the wrong data format used by BIWAPP.
    // biw.BIWAPP-91770_ODc4ZGQ0Y2VlOGRiNmQxMg biw.BIWAPP-91770_YzVlMWQyN2NmNjU0MWY3Mg
    // </references>
    if (rawReferencesData.length < 3) {
      return References(
        sender: "NA",
        identifier: rawReferencesData[0].split(' '),
        send: "NA",
      );
    }
    return References(
      sender: rawReferencesData[0],
      identifier: rawReferencesData[1].split(' '),
      send: rawReferencesData[2],
    );
  }

  References.fromJson(Map<String, dynamic> json)
      : sender = json['sender'],
        identifier = (json['identifier'] as List<dynamic>)
            .map((e) => e.toString())
            .toList(),
        send = json['send'];

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'identifier': identifier,
        'send': send,
      };
}
