enum NotificationMessageType {
  subscribe, // confirmation notification about a successfully subscription
  added, // new added alert
  update, // updated alert
  unsubscribe, // expired subscription notification
  unknown; // this notification type is unknown

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
