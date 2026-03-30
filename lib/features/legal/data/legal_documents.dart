class LegalDocumentData {
  const LegalDocumentData({
    required this.slug,
    required this.title,
    required this.summary,
    required this.updatedAtLabel,
    required this.sections,
    this.notice,
  });

  final String slug;
  final String title;
  final String summary;
  final String updatedAtLabel;
  final String? notice;
  final List<LegalSectionData> sections;
}

class LegalSectionData {
  const LegalSectionData({
    required this.heading,
    this.paragraphs = const <String>[],
    this.bullets = const <String>[],
    this.links = const <LegalLinkData>[],
    this.note,
  });

  final String heading;
  final List<String> paragraphs;
  final List<String> bullets;
  final List<LegalLinkData> links;
  final String? note;
}

class LegalLinkData {
  const LegalLinkData({
    required this.label,
    required this.target,
    this.internal = false,
  });

  final String label;
  final String target;
  final bool internal;
}

const String legalOperatorName = '.exeOS';
const String legalContactEmail = 'exeget@dotexeos.com';
const String legalWebsiteUrl = 'https://www.dotexe.pro';

final Map<String, LegalDocumentData>
legalDocumentsBySlug = <String, LegalDocumentData>{
  'privacy-policy': LegalDocumentData(
    slug: 'privacy-policy',
    title: 'Datenschutzerklaerung',
    summary:
        'Diese Seite beschreibt, welche Daten in LiveWallpaper und im zugehoerigen exeOS-Webkatalog verarbeitet werden, wofuer sie verwendet werden und wie du Loeschung oder Auskunft anfordern kannst.',
    updatedAtLabel: '31. Maerz 2026',
    sections: <LegalSectionData>[
      LegalSectionData(
        heading: '1. Verantwortliche Stelle',
        paragraphs: <String>[
          'LiveWallpaper und der zugehoerige exeOS-Webkatalog werden von .exeOS betrieben.',
          'Kontakt fuer Datenschutzanfragen und allgemeine Rueckfragen: exeget@dotexeos.com.',
        ],
      ),
      LegalSectionData(
        heading: '2. Grundsaetzliche Nutzung',
        paragraphs: <String>[
          'Die App und der Webkatalog koennen weitgehend ohne klassische Registrierung genutzt werden. Fuer den reinen Katalogzugriff sind keine Namen, Postanschriften oder Telefonnummern erforderlich.',
          'Bei der technischen Nutzung koennen jedoch systembedingte Daten verarbeitet werden, etwa Geraetetyp, Betriebssystemversion, App-Version, technische Fehlerzustaende oder anonyme Nutzungsereignisse.',
        ],
      ),
      LegalSectionData(
        heading: '3. Eingesetzte Dienste',
        paragraphs: <String>[
          'Fuer Bereitstellung, Synchronisierung und Betrieb werden Google-Firebase-Dienste eingesetzt.',
        ],
        bullets: <String>[
          'Cloud Firestore fuer Katalog-, Fortschritts- und Statusdaten',
          'Cloud Functions fuer Backendlogik, Kaufpruefung, Restore- und Integrationspfade',
          'Cloud Storage fuer Wallpaper-Assets, Preview-Dateien und zugehoerige Medien',
          'Firebase Analytics fuer anonyme Nutzungs- und Ereignisdaten',
          'Firebase Crashlytics fuer Absturzberichte und technische Fehlerdiagnose',
          'Firebase Authentication fuer optionale Kontoverknuepfung, Restore und signierte Sitzungen',
        ],
        links: const <LegalLinkData>[
          LegalLinkData(
            label: 'Firebase Privacy and Security',
            target: 'https://firebase.google.com/support/privacy',
          ),
        ],
      ),
      LegalSectionData(
        heading: '4. In-App-Kaeufe und Google Play Billing',
        paragraphs: <String>[
          'Fuer Premium-Abos und sonstige storebasierte Kaufvorgaenge nutzt die Android-App Google Play Billing.',
          'Dabei werden kaufbezogene technische Kennungen wie Produkt-IDs, Kauf-Tokens und Statusinformationen verarbeitet, um Entitlements zu pruefen, wiederherzustellen und gegen Missbrauch abzusichern.',
          'Die Zahlungsabwicklung selbst erfolgt ueber Google Play und nicht ueber diese Website.',
        ],
        links: const <LegalLinkData>[
          LegalLinkData(
            label: 'Google Privacy Policy',
            target: 'https://policies.google.com/privacy',
          ),
        ],
      ),
      LegalSectionData(
        heading: '5. Lokale Medien und Nutzerbibliothek',
        paragraphs: <String>[
          'Wenn du eigene Videos importierst oder KI-generierte Ausgaben speicherst, koennen Dateien auf deinem Geraet oder in einer von dir freigegebenen Medienbibliothek abgelegt werden.',
          'Diese Dateien werden nur dann in benutzergewaehlte Ordner geschrieben, wenn du den Zugriff ausdruecklich freigibst. Ohne solche Freigabe bleiben sie lokal oder sind an den jeweiligen App- bzw. Cache-Kontext gebunden.',
        ],
      ),
      LegalSectionData(
        heading: '6. Kontoverknuepfung, Restore und Loeschung',
        paragraphs: <String>[
          'Ein Login ist optional. Wenn du Restore, Abosynchronisierung oder andere accountgebundene Funktionen nutzt, werden die dafuer notwendigen Authentifizierungs- und Zuordnungsdaten verarbeitet.',
          'Du kannst jederzeit die Loeschung deines Kontos oder zuordenbarer Daten beantragen.',
        ],
        links: const <LegalLinkData>[
          LegalLinkData(
            label: 'Konto loeschen',
            target: '/delete-account',
            internal: true,
          ),
        ],
      ),
      LegalSectionData(
        heading: '7. Speicherdauer und Sicherheit',
        bullets: <String>[
          'Uebertragung erfolgt ueber verschluesselte Verbindungen',
          'Der Zugriff auf Backenddaten ist durch projektinterne Sicherheitsregeln und Rollenmodelle begrenzt',
          'Technische Ereignis- und Fehlerdaten werden nur so lange aufbewahrt, wie sie fuer Betrieb, Support und Missbrauchsschutz erforderlich sind',
        ],
      ),
      LegalSectionData(
        heading: '8. Deine Rechte',
        paragraphs: <String>[
          'Du kannst Auskunft, Berichtigung, Loeschung oder Einschraenkung der Verarbeitung anfragen, soweit dies auf die verarbeiteten Daten anwendbar ist.',
          'Anfragen hierzu bitte an exeget@dotexeos.com senden.',
        ],
      ),
    ],
  ),
  'terms-of-service': LegalDocumentData(
    slug: 'terms-of-service',
    title: 'Nutzungsbedingungen',
    summary:
        'Diese Bedingungen regeln die Nutzung der LiveWallpaper-App, des exeOS-Webkatalogs und der damit verbundenen Dienste.',
    updatedAtLabel: '31. Maerz 2026',
    sections: <LegalSectionData>[
      LegalSectionData(
        heading: '1. Geltungsbereich',
        paragraphs: <String>[
          'Diese Nutzungsbedingungen gelten fuer die Android-App LiveWallpaper sowie fuer den exeOS-Webkatalog unter www.dotexe.pro.',
          'Mit Nutzung der Dienste akzeptierst du diese Bedingungen.',
        ],
      ),
      LegalSectionData(
        heading: '2. Zulassige Nutzung',
        bullets: <String>[
          'keine missbraeuchliche oder schaedigende Nutzung der Dienste',
          'keine Umgehung technischer Schutzmechanismen',
          'keine Verwendung von Inhalten, fuer die du keine erforderlichen Rechte besitzt',
          'keine Nutzung entgegen geltendem Recht oder Rechten Dritter',
        ],
      ),
      LegalSectionData(
        heading: '3. Accounts und Freischaltungen',
        paragraphs: <String>[
          'Bestimmte Funktionen koennen an ein optionales Nutzerkonto, Restore-Mechanismen oder storebasierte Entitlements gebunden sein.',
          'Du bist dafuer verantwortlich, dass deine Kontozugaenge und Endgeraete nicht unberechtigt verwendet werden.',
        ],
        links: const <LegalLinkData>[
          LegalLinkData(
            label: 'Datenschutzerklaerung',
            target: '/privacy-policy',
            internal: true,
          ),
        ],
      ),
      LegalSectionData(
        heading: '4. Eigene Inhalte und lokale Medien',
        paragraphs: <String>[
          'Wenn du eigene Videos importierst oder verarbeiten laesst, bestaetigst du, dass du die erforderlichen Nutzungsrechte besitzt.',
          'Du bleibst fuer die von dir bereitgestellten Inhalte verantwortlich.',
        ],
      ),
      LegalSectionData(
        heading: '5. Geistiges Eigentum',
        paragraphs: <String>[
          'Software, Designs, Markenbestandteile und bereitgestellte Medien duerfen nicht ohne ausdrueckliche Erlaubnis vervielfaeltigt, weitergegeben oder in fremde Dienste uebernommen werden, soweit das nicht gesetzlich erlaubt ist.',
        ],
      ),
      LegalSectionData(
        heading: '6. Kaeufe und Store-Regeln',
        paragraphs: <String>[
          'Storebasierte Kauefe werden ueber den jeweiligen Plattformanbieter abgewickelt. Fuer Rueckerstattungen und Abonnementverwaltung gelten zusaetzlich die Richtlinien des jeweiligen Stores.',
        ],
      ),
      LegalSectionData(
        heading: '7. Haftung und Verfuegbarkeit',
        paragraphs: <String>[
          'Die Dienste werden nach bestem Wissen bereitgestellt, jedoch ohne Gewaehr fuer dauerhafte Verfuegbarkeit, Fehlerfreiheit oder Eignung fuer einen bestimmten Zweck.',
          'Eine Haftung fuer technische Ausfaelle, Datenverlust oder aus Nutzerinhalten resultierende Rechtsverletzungen ist im gesetzlich zulaessigen Umfang ausgeschlossen.',
        ],
      ),
      LegalSectionData(
        heading: '8. Aenderungen',
        paragraphs: <String>[
          'Funktionen, Inhalte und diese Nutzungsbedingungen koennen angepasst werden. Die jeweils aktuelle Fassung ist auf dieser Website veroeffentlicht.',
        ],
      ),
      LegalSectionData(
        heading: '9. Kontakt und Loeschung',
        paragraphs: <String>[
          'Fragen zu den Bedingungen oder Antraege zur Kontoloeschung koennen an exeget@dotexeos.com gesendet werden.',
        ],
        links: const <LegalLinkData>[
          LegalLinkData(
            label: 'Konto loeschen',
            target: '/delete-account',
            internal: true,
          ),
        ],
      ),
    ],
  ),
  'delete-account': LegalDocumentData(
    slug: 'delete-account',
    title: 'Konto loeschen',
    summary:
        'So kannst du dein optionales Konto, zuordenbare Backenddaten und lokal verwaltete App-Zustaende entfernen lassen.',
    updatedAtLabel: '31. Maerz 2026',
    sections: <LegalSectionData>[
      LegalSectionData(
        heading: '1. Lokale Daten auf dem Geraet entfernen',
        paragraphs: <String>[
          'Du kannst lokale Fortschritte, Einstellungen und Cache-Daten loeschen, indem du die App-Daten auf dem Geraet entfernst oder die App deinstallierst.',
          'Beachte: Dateien in von dir selbst gewaehlten Medienordnern oder Bibliotheken werden dadurch nicht automatisch aus deinem persoenlichen Speicher geloescht.',
        ],
      ),
      LegalSectionData(
        heading: '2. Kontoloeschung per Support',
        paragraphs: <String>[
          'Wenn du eine serverseitige Zuordnung, ein optionales Konto oder accountgebundene Daten entfernen lassen willst, sende bitte eine Anfrage an exeget@dotexeos.com.',
          'Hilfreich sind vorhandene Kennungen wie Nutzer-ID, Google-Konto-Hinweis oder andere Informationen, mit denen wir deine Anfrage sicher zuordnen koennen.',
        ],
      ),
      LegalSectionData(
        heading: '3. Bearbeitungszeit',
        paragraphs: <String>[
          'Nach verifizierbarer Zuordnung bearbeiten wir Loeschanfragen in der Regel innerhalb von 30 Tagen, sofern keine gesetzlichen Aufbewahrungspflichten entgegenstehen.',
        ],
      ),
      LegalSectionData(
        heading: '4. Rueckfragen',
        paragraphs: <String>[
          'Wenn unklar ist, welche Daten betroffen sind oder ob bestimmte Freischaltungen ausschliesslich storeseitig verwaltet werden, melden wir uns ueber die von dir verwendete Kontaktadresse zur Klaerung.',
        ],
        links: const <LegalLinkData>[
          LegalLinkData(
            label: 'Datenschutzerklaerung',
            target: '/privacy-policy',
            internal: true,
          ),
        ],
      ),
    ],
  ),
  'impressum': LegalDocumentData(
    slug: 'impressum',
    title: 'Impressum',
    summary:
        'Kontakt- und Anbieterangaben fuer LiveWallpaper und den exeOS-Webkatalog.',
    updatedAtLabel: '31. Maerz 2026',
    notice:
        'Die vollstaendige Anbieterkennzeichnung ist hier bereits zentral verankert. Falls Rechtsform oder ladungsfaehige Anschrift intern noch konsolidiert werden, darf nur dieser Datensatz aktualisiert werden und nicht wieder ein externer Seitensplit entstehen.',
    sections: <LegalSectionData>[
      LegalSectionData(
        heading: '1. Betreiber',
        paragraphs: <String>[
          '.exeOS',
          'Projekt: LiveWallpaper / exeOS Web Catalog',
          'Website: https://www.dotexe.pro',
        ],
      ),
      LegalSectionData(
        heading: '2. Kontakt',
        bullets: <String>['E-Mail: exeget@dotexeos.com'],
      ),
      LegalSectionData(
        heading: '3. Inhaltliche Verantwortung',
        paragraphs: <String>[
          'Die inhaltliche Verantwortung fuer diese Website und die zugehoerigen Produktseiten liegt beim Betreiber des exeOS-/LiveWallpaper-Angebots.',
        ],
      ),
      LegalSectionData(
        heading: '4. Wichtiger Hinweis',
        paragraphs: <String>[
          'Wenn fuer bestimmte Stores, Plattformpruefungen oder rechtliche Nachweise eine vollstaendige ladungsfaehige Anschrift oder eine konkrete Rechtsform notwendig ist, muss diese Angabe hier als zentrale Quelle gepflegt werden.',
        ],
      ),
    ],
  ),
};
