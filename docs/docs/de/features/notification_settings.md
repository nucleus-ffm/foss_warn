FOSSWarn ermöglicht es dir auszuwählen, für welche Ereignisse du eine Benachrichtigung erhalten möchtest. Navigiere dazu zu `settings -> notification settings`. 

FOSSWarn erlaubt es dir, eine Dringlichkeitsstufe (Severity) als globale Einstellung für alle Warnungen und Ereignisse festzulegen, und seit Version 1.1.0 auch pro Warnkategorie. 

## Globale Einstellung
![](/assets/notification_settings/global_settings.png){ align=right width="400" }

Mit dem ersten Schieberegler definierst du die globale Dringlichkeitsstufe, ab der du eine Benachrichtigung erhalten möchtest. Der Regler ist invertiert. Wenn du den Regler auf `moderate` stellst, erhältst du Benachrichtigungen für Warnungen mit den Stufen `extreme`, `severe` und `moderate`, aber keine Benachrichtigungen für `minor`. Die globale Einstellung überschreibt immer die Kategorie-Einstellungen. 


## Einstellung pro Kategorie

Seit Version 1.1.0 kannst du die Dringlichkeitsstufe auch für jede Warnkategorie einzeln auswählen. Jede Warnung kann eine oder mehrere Kategorien haben. Hier kannst du die Dringlichkeitsstufe auswählen, ab der du für die jeweilige Kategorie Benachrichtigungen erhalten möchtest. Wenn eine Warnung mehrere Kategorien hat, wird die maximal eingestellte Stufe angewendet. Die globale Einstellung überschreibt immer die Kategorie-Einstellung. Du wirst bemerken, dass sich alle Regler auf die maximal zulässige Einstellung bewegen, sobald du die globale Einstellung änderst. 

### Beispiel:
![](/assets/notification_settings/advanced_settings.png){ align=right width="400" }

Du hast `minor` als globale Einstellung gewählt, `extreme` für Umweltwarnungen (Environmental) und `moderate` für Wetterwarnungen (Weather). Du erhältst nun Benachrichtigungen für die folgenden Warnungen: 

```
- Kategorie: Umwelt
- Schweregrad: Extrem
- => Du erhältst eine Benachrichtigung
```

```
- Kategorie: Umwelt
- Schweregrad: Gering 
=> Du erhältst keine Benachrichtigung
```

```
- Kategorie: Wetter
- Schweregrad: Gering 
=> Du erhältstk eine Benachrichtigung
```

```
- Kategorie: Wetter
- Schweregrad: Moderat 
=> Du erhältst eine Benachrichtigung
```

```
- Kategorie: Sicherheit (oder auch jede andere Kategorie)
- Schweregrad: Gering 
=> Du erhältst eine Benachrichtigung
```