# my_stand_clock

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# my_flip_clock
This project is a work-in-progress demo for a customizable stand clock app.

Important notes:

- Notification reading (Now Playing): On Android this app includes a `NotificationListenerService` skeleton that forwards media notifications to Flutter. To enable: open device Settings -> Apps & notifications -> Special app access -> Notification access, and grant access to this app.
- Calendar events: The app requests `READ_CALENDAR` permission and queries upcoming events (Android). Grant permission when prompted.

Running:

```bash
flutter pub get
flutter run
```

Permissions & platform setup instructions are in `android/app/src/main/AndroidManifest.xml` and `android/app/src/main/kotlin/com/example/my_stand_clock/MediaNotificationListener.kt`.

Files added by the scaffold include BLoC classes under `lib/blocs/` and widgets under `lib/widgets/`.
