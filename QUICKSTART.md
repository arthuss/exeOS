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
- `http://127.0.0.1:4111`

Aktuelle Startlogik:
- `/` oeffnet direkt den Vollkatalog
- Datenquelle fuer den Browser-Grid ist `web\feeds\catalog\all.json`
- kanonische Detailseiten liegen unter `/w/:wallpaperRef`
- Rechtsseiten liegen unter `/privacy-policy`, `/terms-of-service`, `/delete-account` und `/impressum`
- alte `/catalog/:wallpaperId`-Links werden dorthin umgeleitet

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
pwsh -ExecutionPolicy Bypass -File .\scripts\sync-hub-feeds.ps1
firebase deploy --only hosting:webapp --project wallpaper-management-hub
```

## Custom Domain

Aktuell angebunden:
- `www.dotexe.pro`

Ziel:
- `www.dotexe.pro -> dotexe-pro.web.app`
