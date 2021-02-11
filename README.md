TODO
Essential:
----------
change utility to organization.
add phone number to user profile.
Modify permissions to allow CRUD or not.
Add time limit to scrolling, or a mechanism for long scrolls.
investiagte login using username and password rather than email.
Fix image size during capture and save.
Delete old image when a new image is updated or report is deleted.
Delete old image when a is deleted.
Correct unicode in export.
Publish to google play.
Add download image functionality.
Add loading to save button.
add delete confirmation before deleting report.
add to user profile:
  - String creationDate;
  - bool activated;
  - DateTime activationStatusDate;
  - String activationBy;
Checkup todos

Additional Enhancements:
------------------------
Needs a splash screen.
Add nav controller.
Localization.
Revise document ids vs auto ids.
Resolve release configuration and size issue.
Revise error handling and reporting.
Add map display functionality.

Some restriction was mentioned about image picker and Android 29+, need something in application/manifest.xml


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
