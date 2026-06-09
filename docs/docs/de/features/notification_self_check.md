!!! Version note
    Diese Funktion wurde in Version 1.0.1 hinzugefügt. 

Der Benachrichtigungs-Selbsttest hilft dir dabei, Probleme mit deiner Push-Benachrichtigungs-Einrichtung zu erkennen und zu lösen. Navigiere zum Selbsttest über `settings -> Notification Self Check`.

Basierend auf Nutzerfeedback prüfen wir die wichtigsten Aspekte deiner Benachrichtigungskette. Wenn jedes Feld grün ist, sollte alles in Ordnung sein und du solltest in der Lage sein, Benachrichtigungen zu empfangen. 

## Einige der Prüfungen sind fehlgeschlagen. Was bedeutet das und was soll ich tun?

![](/assets/notification_self_check/notification_self_check.png){ align=right width="400" }

### Benachrichtigungsberechtigung
FOSSWarn benötigt deine Erlaubnis, um dir Benachrichtigungen zu senden. Wenn die Prüfung fehlgeschlagen ist, kannst du auf die entsprechende Kachel drücken, und FOSSWarn wird die Benachrichtigungsberechtigung erneut anfordern.

### UnifiedPush Distributor
FOSSWarn verwendet UnifiedPush, um Push-Benachrichtigungen zu senden. Dafür musst du einen UnifiedPush-Distributor auf deinem Gerät installieren. Weitere Informationen findest du auf [dieser Hilfeseite](/de/features/push_services/).

### Ausgewählter Distributor
Wenn du einen Distributor installiert hast und diese Prüfung fehlgeschlagen ist, gehe in die FOSSWarn-Einstellungen, drücke auf "Push Service" und wähle dort deinen Distributor aus. 

### Aktueller Endpunkt
Dies ist die URL, die unser Server verwendet, um dir Benachrichtigungen zu senden. Sobald du einen Distributor auswählst, sollte auch diese Prüfung bestanden werden. Falls die Prüfung fehlschlägt, versuche bitte erneut, einen Distributor auszuwählen. 

### Server-Prüfung
Hier wird geprüft, ob dein ausgewählter Server für Probleme bekannt ist. Diese Prüfung dient hauptsächlich dazu, Probleme mit dem unveränderten Standard-Server in der ntfy-App zu vermeiden. Wenn diese Prüfung mit der Meldung "This server has been unreliable in the past or has had other issues" fehlschlägt, musst du deinen ausgewählten Server z. B. in der ntfy-App überprüfen. Bitte lies [diese Hilfeseite](/de/features/push_services/) für weitere Informationen. Wenn diese Prüfung fehlschlägt und du den Push-Server (z. B. in der ntfy-App) geändert hast, musst du deine Push-Registrierung aktualisieren. Gehe dazu in die `push service` Einstellungen und wähle den zu verwendenden Dienst aus. Dies aktualisiert die Push-Registrierung, und der Selbsttest sollte bestanden werden.

Aktuell erhältst du folgende Prüfergebnisse: 

- ntfy.sh: "This server has been unreliable in the past or has had other issues." Dies liegt an deren Rate-Limit für Push-Benachrichtigungen. Du kannst diesen Server nicht mit dem FOSS Public Alert Server verwenden.
- unifiedpush.kde.org: "This server may be okay." Dies liegt an einigen Problemen in der Vergangenheit mit diesem Server. Du kannst diesen Server verwenden, aber sei dir bewusst, dass erneut Probleme auftreten können. 

### Test-Abonnement und Benachrichtigung
Diese Prüfung versucht, ein Abonnement beim FOSS Public Alert Server abzuschließen, um zu prüfen, ob der Server deine Einrichtung akzeptiert und in der Lage ist, dir Push-Benachrichtigungen zu senden. Das Abonnement wird nach der Prüfung wieder entfernt. Wenn eine der vorherigen Prüfungen fehlgeschlagen ist, wird auch diese Prüfung fehlschlagen. Als Ergebnis dieses Tests solltest du eine Benachrichtigung mit "Successfully subscribed" sehen. 

### Benachrichtigungs-Prüfung
Hier wird geprüft, ob die gesendete Benachrichtigung aus dem Test-Abonnement tatsächlich auf dem Gerät ankommt. Wenn diese Prüfung fehlgeschlagen ist, aber die Abonnement-Prüfung bestanden wurde, prüfe bitte, ob du einige Benachrichtigungskanäle deaktiviert hast (FOSSWarn-Einstellungen -> open Android notification settings), oder ob die Distributor-App akku-optimiert ist oder Berechtigungen fehlen. Wenn auch diese Prüfung erfolgreich war, funktioniert die gesamte Benachrichtigungskette von unserem Server bis zu deinem Gerät.