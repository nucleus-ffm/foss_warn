<div align="center">
  <img src="https://raw.githubusercontent.com/nucleus-ffm/foss_warn/main/assets/app_icon.png" height=120 width=120/>
  <h1>FOSS Warn</h1>

</div>

<a href="https://apt.izzysoft.de/fdroid/index/apk/de.nucleus.foss_warn" > <img src="https://raw.githubusercontent.com/nucleus-ffm/foss_warn/main/docs/IzzyOnDroid.png" height="60"/></a> 

An unofficial open source application written in Flutter to get emergency alerts from https://warnung.bund.de/meldungen. This app has nothing to do with the official APP *Nina* from BBK.

## Current state of development
The app is currently in a BETA status. A group of nice people is currently putting the app through its paces. 

## TODO: 
 - [ ] do some code cleanup

## Known problems:
- the background service is sometimes stopped by the system. To start it again, just open FOSS Warn once. 
- the layout could be improved for small devices
- not every warning shown on https://warnung.bund.de/meldungen is available through the APIs used. (more research needed)

## FAQ
<details>
<summary>How to change the notification sound?</summary>
Go to the app settings and press „Einstellungen öffnen” -> "Benachrichtigungen" -> "Expand" -> "Sound". 
</details>
<details>
<summary>How do I receive notifications?</summary>
FOSS Warn does not use push services. But a background service pulls the latest warnings at a certain frequency and when there is a warning for you, you get a notification. This mechanism only works when the background service is running. When it is stopped, you will not receive any notification. With the status notification you can always see when the last update took place.
</details>

## Similar inoffical projects for other platforms
* [**FediNINA (Fediverse)**](https://meta.prepedia.org/wiki/FediNINA) Project to bring NINA warnings into the Fediverse.
* [**MINA (Matrix)**](https://github.com/djmaze/nina-matrix-bot) MINA is a matrix bot that can be used to subscribe to alerts from the NINA API.
* [**Apocalypse (Sailfish OS)**](https://github.com/black-sheep-dev/harbour-apocalypse) Apocalypse is an application for showing of messages from NINA API.
* [**NINA XMPP bot**](https://github.com/jplitza/nina_xmpp) XMPP bot that sends messages from the German NINA official warning app.

## Haftungsausschluss 
Diese App wurde in der Hoffnung erstellt, dass sie nützlich ist, kommt aber OHNE JEGLICHE GEWÄHRLEISTUNG. Der Entwickler kann zu keinem Zeitpunkt garantieren, dass die App fehlerfrei funktioniert und alle Warnungen jederzeit anzeigt. Die verwendeten Schnittstellen könnten sich jederzeit verändern, wodurch die App vorerst nicht mehr funktioniert. Verlassen Sie sich deshalb zu KEINEM ZEITPUNKT auf diese App. Auch werden die Warnungen immer mit einer gewissen Verzögerung im Hintergrund empfangen. Diese App benutzt keinen Push-Services, sondern lädt in einem gewissen Zeitabstand die neusten Meldungen und benachrichtigt dann, wenn nötig. Durch Android technisch bedingt, kann die App minimal alle 15 Minuten die neusten Warnmeldungen im Hintergrund herunterladen. Je häufiger die App im Hintergrund Daten lädt, desto mehr Akku verbraucht sie allerdings auch. Entscheiden Sie selbst, was Sie für sich brauchen. Es könnte sein, dass Sie die Akkuoptimierung für FOSS Warn deaktivieren müssen, damit diese richtig funktioniert.



![GitHub](https://img.shields.io/github/license/CodingTarik/2048Python) [![Github All Releases](https://img.shields.io/github/downloads/nucleus-ffm/foss_warn/total.svg)]() [![Github latest Releases](https://img.shields.io/github/downloads/nucleus-ffm/foss_warn/latest/total.svg)]()
