# Changelog

All notable changes to TaskFlow are documented in this file.

## 1.0.1

- Fixed a crash on startup caused by incompatible/corrupt stored credential
  data not being handled gracefully.
- Added an app launcher icon.

## 1.0.0

- First public release.
- Local, offline-only profile-based task manager.
- Custom task groups with icons, light/dark theme.
- Passwords are now stored as salted SHA-256 hashes instead of plaintext.
- Removed the built-in default `admin` account; accounts are created via
  the in-app registration screen only.
