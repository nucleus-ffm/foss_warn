enum NotificationMessageType {
  /// confirmation notification about a successfully subscription
  subscribe,

  /// new added alert
  added,

  /// updated alert
  update,

  /// expired subscription notification
  unsubscribe,

  /// this notification type is unknown
  unknown;

  // extract the notification message type from the given String
  static NotificationMessageType fromString(String messageType) {
    for (NotificationMessageType msgT in NotificationMessageType.values) {
      if (msgT.name == messageType.toLowerCase()) {
        return msgT;
      }
    }
    return NotificationMessageType.unknown;
  }
}
