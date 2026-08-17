# Development Guide

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.41.4+)
- A [Firebase project](https://console.firebase.google.com/) with:
  - Email/Password authentication enabled
  - Firestore Database created
  - Firebase Storage enabled (in the Storage section)
  - A web app registered in the project

## Setup

1. **Clone the repository and install dependencies:**

   ```bash
   flutter pub get
   ```

2. **Create a `.env` file from the template:**

   ```bash
   cp .env.example .env
   ```

3. **Fill in your Firebase config values in `.env`:**

   Get the values from your Firebase project's web app settings:
   https://console.firebase.google.com/project/_/settings/general/

4. **Initialize Firebase (optional, for rule deployment):**

   ```bash
   firebase login
   firebase init  # or: firebase deploy --only firestore,storage
   ```

## Running Locally

### Option A: Using Make (recommended)

```bash
make run-web          # Launch in Chrome with Firebase config
make run              # Launch on connected device/emulator
make build-web        # Build release web app
make analyze          # Run Flutter analyzer
```

### Option B: Using VS Code

1. Ensure `.env` exists with your Firebase config (see Setup above)
2. Press `F5` in VS Code and select **"Flutter Chrome (Firebase)"**
3. The launch config automatically loads `.env` and passes all dart-defines

### Option C: Manual (no .env file)

```bash
flutter run -d chrome \
  --dart-define=FIREBASE_API_KEY=<key> \
  --dart-define=FIREBASE_AUTH_DOMAIN=<domain> \
  --dart-define=FIREBASE_PROJECT_ID=<id> \
  --dart-define=FIREBASE_STORAGE_BUCKET=<bucket> \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=<sender-id> \
  --dart-define=FIREBASE_APP_ID=<app-id>
```

## CI/CD

The GitHub Actions workflow (`.github/workflows/main.yml`) passes the same dart-defines from repository secrets. Ensure the following secrets are set in your GitHub repo:

- `FIREBASE_API_KEY`
- `FIREBASE_AUTH_DOMAIN`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_STORAGE_BUCKET`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_APP_ID`

## File Overview

| File | Purpose |
|---|---|
| `.env` | Local Firebase config (gitignored) |
| `.env.example` | Template for `.env` config |
| `Makefile` | Local dev commands (`make run-web`, etc.) |
| `.vscode/launch.json` | VS Code debug launch config |
| `storage.rules` | Firebase Storage security rules |
| `firebase.json` | Firebase CLI configuration |
