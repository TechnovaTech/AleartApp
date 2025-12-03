@echo off
set PATH=%PATH%;C:\Users\dd621\Downloads\flutter\bin
flutter clean
flutter pub get
flutter run --debug
pause