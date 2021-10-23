int generateNotificationID(String warningID) {
 /* return a hash code from input */
 int id;
 id = warningID.hashCode;
 print("Notification id is: $id");
 return id;
}