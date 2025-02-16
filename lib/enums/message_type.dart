enum MessageType {
  alert, // Initial information requiring attention by targeted recipients
  update, // Updates and supercedes the earlier message(s) identified in <references>
  cancel, // Cancels the earlier message(s) identified in <references>
  ack, // Acknowledges receipt and acceptance of the message(s) identified in <references>
  error; // Indicates rejection of the message(s) identified in <references>; explanation SHOULD appear in <note>

  String toJson() => name;
  static MessageType fromJson(String json) => values.byName(json.toLowerCase());

  /// extract the severity from the string and return the corresponding enum
  static MessageType fromString(String messageType) {
    for (MessageType msgT in MessageType.values) {
      if (msgT.name == messageType.toLowerCase()) {
        return msgT;
      }
    }
    return MessageType.alert; //@todo what should be the default value?
  }
}
