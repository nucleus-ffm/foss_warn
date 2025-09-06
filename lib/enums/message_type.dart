import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';

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

  String getLocalizedName(BuildContext context) {
    var localizations = context.localizations;

    return switch (this) {
      alert => localizations.explanation_warning_level_attention,
      update => localizations.explanation_warning_level_update,
      cancel => localizations.explanation_warning_level_all_clear,
      ack => localizations.explanation_warning_level_ack,
      error => localizations.explanation_warning_level_error,
    };
  }

  Color get color => switch (this) {
        update => Colors.blueAccent,
        cancel => Colors.green,
        alert => Colors.red,
        _ => Colors.orangeAccent,
      };
}
