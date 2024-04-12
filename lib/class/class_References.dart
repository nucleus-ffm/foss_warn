/// Class to store one or more warnings that are referenced by another warning
class References {
  String sender;
  List<String> identifier;
  String send;

  References ({
    required this.sender,
    required this.identifier,
    required this.send
});

  /// create References object by extracting the data
  /// from a String in format "<sender>,<identifier>,<sent>"
  factory References.fromString(String references) {
    // Example data: trinet@caltech.edu,TRI13970876.1,2003-06-11T20:30:00-07:00
    // if more then one alert is referred, the identifiers are separated by spaces
    List<String> temp = references.split(',');
    return References(
        sender: temp[0],
        identifier: temp[1].split(' '),
        send: temp[2]);
  }

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'identifier': identifier,
    'send': send,
  };
}