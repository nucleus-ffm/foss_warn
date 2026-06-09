In früheren Versionen von FOSSWarn nutzte die App einen Polling-Dienst, um zu prüfen, ob Warnmeldungen für den Nutzer vorliegen. Dies hatte einige Nachteile, verbrauchte mehr Akku und führte zu einer Verzögerung, bis die Benachrichtigung empfangen wurde. Seit Version 1.0 nutzt FOSSWarn den FOSS Public Alert Server, um Warnungen und Benachrichtigungen zu empfangen. Um diese Benachrichtigungen nahezu in Echtzeit zu erhalten, nutzt sowohl der Server als auch der Client UnifiedPush.

## Was ist UnifiedPush?
[UnifiedPush](https://unifiedpush.org/) ist ein Satz von Werkzeugen für Push-Benachrichtigungen. Anstatt ständig abzufragen (Polling), empfängt der Client eine Push-Benachrichtigung und wacht auf, um eine Aktion auszuführen. FOSSWarn nutzt UnifiedPush, um den Client darüber zu informieren, dass eine Warnung für ein Abonnement aufgetreten ist, woraufhin der Client den Nutzer benachrichtigen kann.

## Was ist der Unterschied zwischen Push und Polling?
Bei Push-Benachrichtigungen hält das System (in diesem Fall die Distributor-App) eine energieeffiziente, konstante Verbindung zum Push-Server. Dies ermöglicht es einem Anwendungsserver, eine Benachrichtigung sofort und ohne große Verzögerung zu senden.

Beim Polling muss die App ständig aufgeweckt werden. Jedes Mal, wenn die App aufwacht, verbindet sie sich mit dem Server und prüft, ob es etwas Neues gibt. Wenn dies der Fall ist, erstellt die App eine Benachrichtigung und zeigt sie an; andernfalls geht die App wieder in den Schlafmodus. Damit ist es unmöglich, Benachrichtigungen in nahezu Echtzeit zuzustellen. Es wird immer eine Verzögerung geben. Zudem kann dies den Akku belasten, da dieser Mechanismus nicht sehr optimiert ist.

## Was ist ein Distributor?
Bei der Verwendung von UnifiedPush sind mehrere Komponenten an der Übermittlung einer Push-Benachrichtigung von unserem Server an das Telefon beteiligt. Kurz gesagt funktioniert es so:

FOSS Public Alert Server -> *sendet Benachrichtigung* -> Push-Server (z. B. ein ntfy-Server) -> *sendet Nachricht an Telefon* -> Distributor-App -> *weckt auf* -> FOSSWarn

Alles, was du tun musst, ist einen Distributor auszuwählen. Der Distributor verwaltet alle Push-Benachrichtigungsverbindungen für jede App, die UnifiedPush verwendet.

## Warum nicht die Push-Infrastruktur von Google nutzen?
Bei dem gesamten Projekt geht es darum, eine freie Open-Source-Infrastruktur ohne proprietäre Komponenten zu implementieren. Wenn du jedoch wirklich möchtest, kannst du einen Distributor auswählen, der Google nutzt.

## Einen Distributor installieren
### Android
Wenn du bereits einen Distributor installiert hast, wähle diesen im Auswahlmenü aus. Wenn du noch keinen Distributor installiert hast, schau dir die Übersicht an, welche Distributoren für deine Plattform verfügbar sind. [Zur Übersicht](https://unifiedpush.org/users/distributors). Wenn du nicht weißt, welchen du wählen sollst, probiere `sunup` oder `ntfy`.

#### Für ntfy: Welchen Standard-Server sollte ich verwenden?
!!! Warning
    **Nutze nicht den Standard-Server (ntfy.sh).** Dieser Server hat ein Limit von 250 Benachrichtigungen pro Tag für jeden Publisher. Wir können daher keine Abonnements mit diesem Push-Server akzeptieren. Bitte ändere den Standard-Server in den Einstellungen der ntfy-App und wähle einen anderen aus.

    Wenn du den Server nicht änderst, wird die Standard-Instanz des FOSS Public Alert Servers keine Abonnements mit diesem Server akzeptieren. Wenn du also die Fehlermeldung `Your UnifiedPush Server ntfy.sh is blocked` erhältst, überprüfe bitte die ntfy-App und ändere den Standard-Server. Du kannst die Push-Konfiguration in FOSSWarn zurücksetzen, indem du zu 'settings' -> 'Push Services' gehst und deinen Push-Dienst erneut auswählst.

Hier ist eine unvollständige Liste von ntfy-Push-Servern, die du wählen könntest: 

- [ntfy.adminforge.de](https://ntfy.adminforge.de/)  🇩🇪 Deutschland

- [ntfy.envs.net](https://ntfy.envs.net/) 	     🇩🇪 Deutschland

- [ntfy.mzte.de](https://ntfy.mzte.de/) 	     🇩🇪 Deutschland

- [ntfy.hostux.net](https://ntfy.hostux.net/) 	     🇫🇷 Frankreich

- [push.tchncs.de/](https://push.tchncs.de/) 	     🇩🇪 Deutschland

Die folgenden Server könnten funktionieren, aber wir könnten sehr schnell in ein Rate-Limit laufen. Nutze sie nur, wenn du weißt, was du tust.

- [ntfy.tedomum.fr](https://ntfy.tedomum.fr)         🇫🇷 Frankreich

- [ntfy.fossman.de](https://ntfy.fossman.de/) 	     🇩🇪 Deutschland

!!! Notice
    Der Server unter `unifiedpush.kde.org` war in der Vergangenheit recht unzuverlässig. Wir können die Nutzung nicht empfehlen. Dies könnte sich in Zukunft ändern.

!!! help
    Wenn du zuverlässigere Push-Server kennst, gib uns bitte einen Hinweis, und wir werden diese Liste erweitern. Oder erstelle einen Merge-Request und hilf mit, diese Seite zu verbessern.

Bitte beachte, dass Serverbetreiber deine Nachrichten protokollieren können. Wir verwenden verschlüsselte Push-Nachrichten, sodass dies kein Problem sein sollte.

### Linux
Für Linux ist nur `kunifiedpush` verfügbar. Das Paket ist für die meisten Plattformen verfügbar. [Hier](https://repology.org/project/kunifiedpush/versions) kannst du prüfen, ob deine Distribution das Paket führt (du benötigst mindestens Version `25.04.0`).

### Besonderer Hinweis zu /e/ OS Telefonen
/e/ OS bringt einen eigenen Fork der ntfy-App mit, die vorinstalliert ist. Obwohl dies eine gute Idee ist, haben sie versäumt, die Benutzeroberfläche zugänglich zu machen. In der vorinstallierten Version ist es unmöglich, die App-Einstellungen zu ändern, was jedoch notwendig ist, um den Standard-Server zu wechseln. Fortgeschrittene Nutzer können diesen [Blog-Post](https://wrily.foad.me.uk/going-google-free-with-unifiedpush-in-e-os) für Details lesen. Allen anderen empfehle ich, die ntfy-Version aus dem F-Droid Store zu installieren und den Anweisungen hier zum Ändern des Standard-Servers zu folgen. Ich hoffe, dass das /e/OS-Team dies in Zukunft verbessert.

## Wähle deinen Push-Dienst aus
![](/assets/push_services/push_service_selection.png){ align=right width="400" }

Wenn du noch keinen Push-Dienst ausgewählt hast, wird FOSSWarn dich fragen, welchen UnifiedPush-Distributor du verwenden möchtest. Wenn du keinen Distributor auf deinem System installiert hast, installiere bitte zuerst einen.

Wenn du deinen Push-Dienst / UnifiedPush-Distributor später ändern oder aktualisieren möchtest, kannst du dies unter `settings` -> `Push service` tun. Wenn du einen auswählst, wird die Konfiguration aktualisiert und deine Abonnements werden aktualisiert. Bitte warte, bis der Vorgang abgeschlossen ist.