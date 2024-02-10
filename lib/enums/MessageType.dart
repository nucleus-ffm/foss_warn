enum MessageType {
  Alert,  // Initial information requiring attention by targeted recipients
  Update, // Updates and supercedes the earlier message(s) identified in <references>
  Cancel, // Cancels the earlier message(s) identified in <references>
  Ack,    // Acknowledges receipt and acceptance of the message(s) identified in <references>
  Error;  // Indicates rejection of the message(s) identified in <references>; explanation SHOULD appear in <note>

  String toJson() => name;
  static MessageType fromJson(String json) => values.byName(json);

  /// extract the severity from the string and return the corresponding enum
  static MessageType fromString(String messageType) {
    for (MessageType msgT in MessageType.values) {
      if (msgT.name == messageType) {
        return msgT;
      }
    }
    return MessageType.Alert; //@todo what should be the default value?
  }
}




