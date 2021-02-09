TODO
Needs a splash screen.
Add nav controller.
Modify permissions to allow CRUD/
Add time limit to scrolling.
Correct unicode in export.
Fix image size duing capture and save.
Localization.
Revise document ids vs auto ids.
Delete old image when a new image is updated.
Resolve release configuration and size issue.
Publish to google play.
Revise error handling and reporting.


Resolved issues.
How i resolved the location issue, error
flutter pub cache repair
flutter clean
flutter run

I also deleted the pub_cashe in /home/.pub_cashe

there is a useful file in project root called packages

I sovled another problem by reading the error text which indicates that profile version need to be created before release version.

Also an error in running release mode application was related to adding som tags to the gradle build file to disallow shrinking, the problem was that the permissions and sensors e.g. amera, location, write to disk was not working and they gave errors.

The maps issue seems to be resolved by upgrading the min SDK to 24
This was working in 
Flutter 1.22.6 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 9b2d32b605 (13 days ago) • 2021-01-22 14:36:39 -0800
Engine • revision 2f0af37152
Tools • Dart 2.10.5




# ufr

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
