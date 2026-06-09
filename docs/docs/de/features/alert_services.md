

!!! note
    Die verschiedenen Warnmeldungsdienste sind seit Version 1.1.0 verfügbar.


FOSSWarn bietet mehrere Möglichkeiten, Warnmeldungen zu empfangen. Um deine bevorzugte Art des Empfangs auszuwählen, navigiere zu `Settings` -> `Alert Services`.

![](/assets/alert_services/alert_services.png){ align=right width="400" }


Hier kannst du zwischen den folgenden Optionen wählen: 

- **Push-Benachrichtigungen** <br>
Dies ist die Standardeinstellung für Neuinstallationen. Dies ermöglicht es dir, Benachrichtigungen mit geringerer Verzögerung zu erhalten, da der Server eine neue Nachricht direkt an dein Gerät pushen kann. Als Push-Dienst verwendet FOSSWarn UnifiedPush, da dies ein Open-Source- und datenschutzfreundlicher Weg ist, Push-Benachrichtigungen zu empfangen. Diese Option erfordert die Einrichtung eines zusätzlichen UnifiedPush-Distributors. Weitere Informationen dazu findest du [hier](/features/push_services).

- **Legacy Polling** (noch experimentell) <br>
Frühere Versionen von FOSSWarn stützten sich auf einen Polling-Mechanismus, anstatt Push-Benachrichtigungen zu verwenden. Seit Version 1.1.0 kann dieser wieder genutzt werden. Bei Verwendung dieser Option wird dein Gerät in Intervallen von 15 Minuten aufgeweckt, um den Server auf neue Warnmeldungen zu prüfen. Dies erfordert die Android-Berechtigung zum Planen exakter Alarme sowie die Deaktivierung der Akku-Optimierung für diese App. Diese neue Implementierung dieser alten Funktion ist noch experimentell und erfordert weitere Tests. Feedback ist willkommen. 

- **Push-Benachrichtigungen verwenden, aber auch Polling aktivieren** (noch experimentell) <br>
Wenn man beides haben kann, warum nicht beides nutzen? Mit dieser Option erhältst du Push-Benachrichtigungen, aber FOSSWarn wird zusätzlich in Intervallen aufgeweckt, um nach Warnmeldungen zu prüfen. Dies kann nützlich sein, wenn der Server mit einer riesigen Menge an Push-Benachrichtigungen zu kämpfen hat oder wenn dein Push-Benachrichtigungsserver unzuverlässig ist. Dies ist eine neue Funktion, die ebenfalls weitere Tests benötigt.

- **Ich benötige überhaupt keine Hintergrundbenachrichtigungen** <br>
Dies deaktiviert sowohl die Push-Benachrichtigungen als auch das Polling. Dies erfordert keine zusätzliche Einrichtung und kann nützlich sein, wenn du die Warnmeldungen nur sehen möchtest, wenn du die App öffnest. Dies schränkt den Nutzen von FOSSWarn ein, da du keine Benachrichtigungen über neue Warnmeldungen erhältst, wenn die App geschlossen ist.