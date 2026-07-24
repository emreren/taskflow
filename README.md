# TaskFlow

A lightweight, local-first Flutter task manager with profile-based task lists,
custom groups, and light or dark themes. TaskFlow works fully offline: it
requests no network permissions and does not collect, store, or transmit any
data off your device.

## Requirements

- Flutter SDK 3.38 or newer
- Dart SDK 3.12 or newer

## Run

```bash
flutter pub get
flutter run
```

## Quality checks

```bash
flutter analyze
flutter test
```

## Project structure

- `lib/models`: persisted application data
- `lib/services`: local storage and application services
- `lib/screens`: application views
- `lib/widgets`: reusable presentation components
- `test`: focused automated tests
- `metadata`: F-Droid/fastlane store listing metadata

Task and profile data are stored on-device with `shared_preferences`.
Passwords are never stored in plaintext: only a per-user salted SHA-256 hash
is persisted.

## License

TaskFlow is free software, licensed under the
[GNU General Public License v3.0 or later](LICENSE).

## Third-party assets

The app icon is based on the "task_alt" symbol from
[Google Material Symbols](https://github.com/google/material-design-icons),
licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).
