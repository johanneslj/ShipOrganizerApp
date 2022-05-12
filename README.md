# ship_organizer_app

This Application has been developed as part of the bachelor thesis at NTNU Ålesund. It uses a server 
Api which has been published to digital ocean. 

## Versions
The software for this app been developed and tested in the following SDK versions
Dart    2.15.1
Flutter 2.8.1

## Getting Started
#How to Run
1. Import the project into Android Studio, make sure you have the Appropriate FLutter SDK plugin installed
2. To check if you have the appropriate SDK versions of Dart and Flutter run 'flutter --version'
3. Run 'flutter pub get'
4. The app should be ready, either connect a device or emulate one via Android Studio and run the app

## Essential Folders
Some of the folders are essential to run the app:
* *assets* - Contains assets shown in the app, app will not start without it
* *lib*    - Source code of the project

```
├── android
├── assets
├── flutter.yml
├── ios
├── lib
│   ├── api handling
│   ├── config
│   ├── entities
│   ├── l10n <-- Raw translation files, any new translations are entered here
│   ├── offline_queue 
│   ├── views <-- All the views displayed in the app
│   ├── widgets <-- Set of custom widgets used in the app
│   └── main.dart <-- main class for project
├── l10n.yaml
├── pubspec.lock
├── pubspec.yaml 
└── README.md
```


