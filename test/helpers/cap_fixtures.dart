/// CAP fixtures shaped exactly like the payloads the FOSS Public Alert Server
/// returns for `/alert/<id>`.
library;

/// A complete CAP alert including the optional fields that used to break
/// parsing (`responseType`, `references`, `web`, `contact`).
const String capAlertXml = '''<?xml version="1.0" encoding="UTF-8"?>
<alert xmlns="urn:oasis:names:tc:emergency:cap:1.2">
  <identifier>2.49.0.0.276.0.DWD.PVW.1234</identifier>
  <sender>opendata@dwd.de</sender>
  <sent>2026-08-19T10:00:00+02:00</sent>
  <status>Actual</status>
  <msgType>Update</msgType>
  <scope>Public</scope>
  <references>opendata@dwd.de,2.49.0.0.276.0.DWD.PVW.1111 2.49.0.0.276.0.DWD.PVW.2222,2026-08-19T09:00:00+02:00</references>
  <info>
    <language>de-DE</language>
    <category>Met</category>
    <event>GEWITTER</event>
    <responseType>Monitor</responseType>
    <urgency>Immediate</urgency>
    <severity>Severe</severity>
    <certainty>Likely</certainty>
    <effective>2026-08-19T10:00:00+02:00</effective>
    <expires>2026-08-19T18:00:00+02:00</expires>
    <senderName>DWD</senderName>
    <headline>Amtliche WARNUNG vor GEWITTER</headline>
    <description>Es treten Gewitter auf.</description>
    <instruction>Vorsicht.</instruction>
    <web>https://www.wettergefahren.de</web>
    <contact>+49 69 8062 0</contact>
    <area>
      <areaDesc>Kreis Musterstadt</areaDesc>
      <polygon>50.0,8.0 50.0,9.0 51.0,9.0 51.0,8.0 50.0,8.0</polygon>
    </area>
  </info>
</alert>''';

/// A minimal CAP alert: only the elements CAP marks as required, so every
/// optional field is absent.
const String capMinimalAlertXml = '''<?xml version="1.0" encoding="UTF-8"?>
<alert xmlns="urn:oasis:names:tc:emergency:cap:1.2">
  <identifier>minimal-1</identifier>
  <sender>sender@example.org</sender>
  <sent>2026-08-19T10:00:00+02:00</sent>
  <status>Actual</status>
  <msgType>Alert</msgType>
  <scope>Public</scope>
  <info>
    <category>Safety</category>
    <event>Test</event>
    <urgency>Expected</urgency>
    <severity>Minor</severity>
    <certainty>Possible</certainty>
    <headline>Minimal alert</headline>
    <description>Nothing else is set.</description>
    <area>
      <areaDesc>Somewhere</areaDesc>
      <polygon>1.0,2.0 1.0,3.0 2.0,3.0 1.0,2.0</polygon>
    </area>
  </info>
</alert>''';

/// A CAP alert whose `responseType` is `AllClear` — the value whose enum name
/// does not survive a plain `values.byName(lowercased)` lookup.
const String capAllClearAlertXml = '''<?xml version="1.0" encoding="UTF-8"?>
<alert xmlns="urn:oasis:names:tc:emergency:cap:1.2">
  <identifier>all-clear-1</identifier>
  <sender>sender@example.org</sender>
  <sent>2026-08-19T12:00:00+02:00</sent>
  <status>Actual</status>
  <msgType>Cancel</msgType>
  <scope>Public</scope>
  <info>
    <category>Met</category>
    <event>GEWITTER</event>
    <responseType>AllClear</responseType>
    <urgency>Past</urgency>
    <severity>Minor</severity>
    <certainty>Observed</certainty>
    <headline>Entwarnung</headline>
    <description>Die Warnung wurde aufgehoben.</description>
    <area>
      <areaDesc>Kreis Musterstadt</areaDesc>
      <polygon>50.0,8.0 50.0,9.0 51.0,9.0 50.0,8.0</polygon>
    </area>
  </info>
</alert>''';
