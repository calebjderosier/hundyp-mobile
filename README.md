# Hundy P

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Secrets
You're going to need the ones in the `.gitignore` file, e.g.
```
dotenv
google-services.json
GoogleService-Info.plist
```
## Generating an android SHA-1 for the `google-services.json`
I ran this command
```
keytool -list -v \
-alias androiddebugkey \
-keystore ~/.android/debug.keystore
```

## Steps to build the first time
Essentially, follow the tutorial for:
1. installing flutter
2. installing firebase


## Useful flutter .zsh aliases
### FLUTTER
alias fr='flutter run'
alias fd='flutter doctor -v'
