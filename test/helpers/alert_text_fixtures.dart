/// Real `description` and `instruction` values of alerts published by
/// different sources, exactly as `FPASApi.getAlertDetail` hands them to
/// `WarnMessage.fromJson`: the XML is unescaped, but the Parker transform of
/// `xml2json` has escaped the text of every element a second time.
library;

/// Description of a LU-Alert food recall: a HTML subset with paragraphs,
/// bold text, a bullet list, an image and links. The HTML entities survived
/// the XML unescaping (`&amp;#39;` -> `&#39;`).
const String luAlertDescription =
    r'''<p><strong>Reason:</strong> Presence of Bacillus cereus</p><p></p><p><img src="https://securite-alimentaire.public.lu/fr/actualites/alertes/2026/08/rappel-high-protein-pudding-chocolate-flavour-de-la-marque-milbona/_jcr_content/root/root-responsivegrid/content-responsivegrid/sections-responsivegrid/section/col1/image.coreimg.82.1280.png/1787147340489/screenshot-2026-08-19-152453.png" width="200" alt=""></p><ul><li><strong>Name:</strong> <strong>High Protein Pudding Chocolate Flavour</strong></li><li><strong>Brand:</strong> <strong>Milbona</strong></li><li>Unit: 200 g</li><li>Best before date (BBD): 14/09/2026</li><li>Period of sale: 31/07/2026 - 19/08/2026</li></ul><p></p><p>Sale confirmed in Luxembourg by : Lidl</p><p></p><p>More information regarding this non-compliance: <a href="https://securite-alimentaire.public.lu/fr/danger/en/bacillus.html" rel="noopener noreferrer" target="_blank">www.securite-alimentaire.public.lu/fr/danger/en</a></p><p>All food safety alerts: <a href="https://securite-alimentaire.public.lu/fr/actualites/alertes.html" rel="noopener noreferrer" target="_blank">www.securite-alimentaire.lu/fr/actualites/alertes</a></p><p><em>Note: </em>The &quot;end date&quot; indicates only the period during which the alert is displayed. The product concerned remains non-compliant after this date.</p>''';

/// Description of a MoWaS/NINA alert: plain text where only `<br/>` marks
/// the line breaks.
const String mowasDescription =
    r'''Es folgt eine wichtige Information.<br/><br/>Aufgrund eines Waldbrandes / Vegetationsbrandes im Kreis Düren und im Hohen Venn kommt es immer noch, in Teilgebieten des Kreises Euskirchen (aktuell im Südkreis) zu einer Geruchsbelästigung und Rauchniederschlag.<br/>Bitte halten Sie die Notrufleitungen 110 / 112 für Notfälle frei.''';

/// Instruction of the same MoWaS alert.
const String mowasInstruction =
    r'''Wählen Sie nur in Notfällen den Notruf 110 (Polizei) und 112 (Feuerwehr).<br/>Schließen Sie vorsorglich Fenster und Türen.''';

/// Description of a MoWaS all-clear message, still containing an HTML
/// entity after the XML unescaping.
const String mowasAllClearDescription =
    r'''Dies ist die Entwarnung zur Warnung &quot;Geruchsbelästigung durch Brandrauch - Kreis Siegen-Wittgenstein - Kreis Siegen-Wittgenstein&quot; vom 18.08.2026 14:11:39 gesendet durch Integrierte Leitstelle Kreis Siegen-Wittgenstein. Die Warnung ist aufgehoben.<br/><br/>Aufgrund eines Waldbrandes im Grenzgebiet Deutschland / Belgien (Hohes Venn) kann es derzeit witterungsbedingt auch in unserer Region zu Rauch- und Brandgeruch kommen. Ursache sind Rauchgase, die durch die aktuellen Wind- und Wetterverhältnisse in unser Gebiet getragen werden und sich bodennah niederschlagen können.''';

/// A line break as it survives the conversion of the CAP XML: `xml2json`
/// escapes it twice, so the app receives the three characters `\`, `\`, `n`
/// instead of the newline itself.
const String escapedLineBreak = r'\\n';

/// Description of a NOAA/NWS alert: hard wrapped plain text with
/// `* LABEL...value` bullets, all line breaks escaped.
const String nwsDescription =
    '* WHAT...Northwest winds 10 to 20 kt with gusts up to 25 kt'
    '${escapedLineBreak}expected.'
    '$escapedLineBreak$escapedLineBreak'
    '* WHERE...Waters from Point Reyes to Pigeon Point 10-60 NM.'
    '$escapedLineBreak$escapedLineBreak'
    '* WHEN...From 3 PM this afternoon to 3 AM PDT Saturday.'
    '$escapedLineBreak$escapedLineBreak'
    '* IMPACTS...Conditions will be hazardous to small craft.';

/// Instruction of the same NOAA/NWS alert: two hard wrapped lines.
const String nwsInstruction =
    'Inexperienced mariners, especially those operating smaller'
    '${escapedLineBreak}vessels, should avoid navigating in hazardous '
    'conditions.';
