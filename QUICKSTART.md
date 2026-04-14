# QUICKSTART: exeOS

Repo: `G:\workspaces\AndroidStudioProjects\exeOS`

## Lokale Entwicklung

```powershell
cd G:\workspaces\AndroidStudioProjects\exeOS
$env:Path = 'C:\tools\flutter\bin;' + $env:Path
flutter pub get
flutter analyze
flutter test
pwsh -ExecutionPolicy Bypass -File .\scripts\sync-hub-feeds.ps1
flutter run -d chrome
```

Hinweis:
- `flutter run` previewt nur den Flutter-App-Shell.
- Die produktive Root-Landingpage kommt aus `G:\workspaces\AndroidStudioProjects\landingpage` und wird erst durch `scripts/build-hosting.ps1` in den Hosting-Output gemischt.
- Die Landing zieht ihre Showcase-Videos bevorzugt aus `/feeds/landing/videos.json` (aus dem Hub gespiegelt) und faellt nur lokal auf `landingpage\landing-videos.json` zurueck.

Auth-Hinweis:
- Die Web-Auth-Shell erwartet fuer einen auth-faehigen Build `EXEOS_FIREBASE_API_KEY`.
- Ohne diesen Build-Define bleibt `exeOS` absichtlich lauffaehig, aber im auth-disabled Modus.
- Beispiel fuer einen auth-faehigen lokalen Start:

```powershell
cd G:\workspaces\AndroidStudioProjects\exeOS
$env:Path = 'C:\tools\flutter\bin;' + $env:Path
$env:EXEOS_FIREBASE_API_KEY = '<firebase-browser-key>'
flutter run -d chrome --dart-define=EXEOS_FIREBASE_API_KEY=$env:EXEOS_FIREBASE_API_KEY
```

## Lokaler Browser-Preview auf festem Port

```powershell
cd G:\workspaces\AndroidStudioProjects\exeOS
$env:Path = 'C:\tools\flutter\bin;' + $env:Path
pwsh -ExecutionPolicy Bypass -File .\scripts\sync-hub-feeds.ps1
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 4111
```

Dann im Browser:
- `http://127.0.0.1:4111/catalog`

Aktuelle Startlogik:
- `/` ist im produktiven Hosting die statische Landingpage
- `/catalog` ist der feed-basierte Vollkatalog im Flutter-Shell
- Datenquelle fuer den Browser-Grid ist `web\feeds\catalog\all.json`
- kanonische Detailseiten liegen unter `/w/:wallpaperRef`
- Rechtsseiten liegen unter `/privacy-policy`, `/terms-of-service`, `/delete-account` und `/impressum`
- alte `/catalog/:wallpaperId`-Links werden dorthin umgeleitet

## Produktionsnahen Hosting-Output bauen

```powershell
cd G:\workspaces\AndroidStudioProjects\exeOS
$env:Path = 'C:\tools\flutter\bin;' + $env:Path
pwsh -ExecutionPolicy Bypass -File .\scripts\build-hosting.ps1
```

Ergebnis:
- `build\hosting\index.html` = statische Root-Landingpage aus `..\landingpage`
- `build\hosting\app.html` = Flutter-Web-Shell fuer `/catalog`, `/w/:ref`, Settings/Auth/Legal
- `build\hosting\feeds\landing\videos.json` = Hub-exportierter Preview-Video-Pool fuer die Landing
- `build\hosting\.well-known\assetlinks.json` wird bewusst mit uebernommen
- Feed-only-Aenderungen koennen danach mit `-SkipFlutterBuild` neu gestaged werden; `build-hosting.ps1` synchronisiert dabei weiter den aktuellen Hub-Feed und ueberspringt nur den Flutter-Web-Compile-Schritt.

Fuer einen auth-faehigen Produktionsbuild:

```powershell
cd G:\workspaces\AndroidStudioProjects\exeOS
$env:Path = 'C:\tools\flutter\bin;' + $env:Path
$env:EXEOS_FIREBASE_API_KEY = '<firebase-browser-key>'
pwsh -ExecutionPolicy Bypass -File .\scripts\build-hosting.ps1
```

## Firebase Hosting

Projekt:
- `wallpaper-management-hub`

Site:
- `dotexe-pro`
- `https://dotexe-pro.web.app`

Einmalig:

```powershell
cd G:\workspaces\AndroidStudioProjects\exeOS
firebase experiments:enable webframeworks
firebase target:apply hosting webapp dotexe-pro --project wallpaper-management-hub
```

Deploy:

```powershell
cd G:\workspaces\AndroidStudioProjects\exeOS
$env:Path = 'C:\tools\flutter\bin;' + $env:Path
pwsh -ExecutionPolicy Bypass -File .\scripts\build-hosting.ps1
firebase deploy --only hosting:webapp --project wallpaper-management-hub
```

## Custom Domain

Aktuell angebunden:
- `www.dotexe.pro`

Ziel:
- `www.dotexe.pro -> dotexe-pro.web.app`
