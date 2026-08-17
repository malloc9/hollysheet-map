# CLAUDE.md — HollySheet Map

## Project Overview

**HollySheet Map** is a Flutter web + mobile app that visualizes community members
(often a gaming clan) on an interactive OpenStreetMap. Users register with email/password,
await admin approval, and once approved see other approved members pinned on the map with
their avatars, location, nationality, and bio. Admins manage the member roster through
a tabbed panel.

## Architecture

### State Management
- **`provider`** (v6.1.2) — All app state flows through `ChangeNotifier` providers
  declared in `MultiProvider` at the app root (`lib/app/app.dart`):
  - `AuthProvider` — wraps `AuthService`, tracks Firebase auth state
  - `UserProvider` — wraps `FirestoreService`, holds current user + real-time lists
    (approved, pending, members, admins) via Firestore streams
  - `MapProvider` — placeholder provider (currently unused for state)

### Routing
- **`go_router`** (v14.6.2) — Declarative routing in `lib/app/router.dart`:

  | Route       | Page           | Access                          |
  |-------------|----------------|---------------------------------|
  | `/`         | LoginPage      | Unauthenticated users           |
  | `/waiting`  | WaitingPage    | Authenticated but not approved  |
  | `/map`      | MapPage        | Approved users (main screen)   |
  | `/profile`  | ProfilePage    | Approved users (edit profile)  |
  | `/admin`    | AdminPage      | Admins only                     |

### Backend (Firebase)
- **Authentication** — Email/password via `firebase_auth`
- **Firestore** — `users` collection; real-time streams for all user lists
- **Storage** — Profile images in `profile_images/{userId}` path
- **Security Rules** — In `firestore.rules` and `storage.rules`; users can read/write
  their own profile; approved users can read approved profiles (needed for the map)

### Map & Geocoding
- **`flutter_map`** (v8.1.0) + **OpenStreetMap** tiles — `TileLayer` with
  `https://tile.openstreetmap.org/{z}/{x}/{y}.png`
- **`latlong2`** (v0.9.1) — LatLng for markers and map centering
- **Nominatim** (direct HTTP via `http` package) — No Flutter geocoding package;
  `GeocodingService` calls `nominatim.openstreetmap.org/search` directly with a
  custom User-Agent header (`HolySheet Map App`)

### Image Upload & Cropping
- **`image_picker`** (v1.1.2) — Gallery source for profile pictures
- **`image_cropper`** (v9.0.3) — Square crop; `WebUiSettings` configured for web
  with `presentStyle: dialog`, `modal: true`
- **`firebase_storage`** (v12.4.10) — Uploads to `profile_images/{userId}` with
  JPEG content type
- **`image_compression`** (v1.0.2) — Declared in pubspec but **not yet imported**
  in any Dart file; ready for use to reduce upload sizes
- **`cropper_preloader.dart`** — **Web-only** (`dart:html`) preloader that fixes
  the `image_cropper` initialization race condition by pre-loading the image
  before the cropper dialog opens (see commit `58a610d`)
- **Gravatar** — Fallback when no `avatarUrl` is set; `GravatarService` generates
  an MD5-based identicon URL from the user's email

## Directory Structure

```
lib/
  app/
    app.dart          # Root StatefulWidget, Firebase init, MultiProvider setup
    router.dart       # GoRouter routes
  models/
    user.dart         # User model with Firestore serialization (copyWith, toFirestore, fromFirestore)
    role.dart         # Role enum: admin, member, pending
  pages/
    login/            # LoginPage — email/password sign-in or sign-up
    waiting/          # WaitingPage — "account awaiting approval" screen
    map/              # MapPage — main screen, FlutterMap + markers + user info card
    profile/          # ProfilePage — edit avatar, nationality, bio, location search
    admin/            # AdminPage — tabbed panel (Pending/Members/Admins)
  providers/
    auth_provider.dart   # AuthProvider (ChangeNotifier)
    user_provider.dart   # UserProvider (ChangeNotifier, real-time Firestore streams)
    map_provider.dart    # MapProvider (placeholder)
  services/
    auth_service.dart       # AuthService — FirebaseAuth wrapper
    firestore_service.dart  # FirestoreService — all Firestore CRUD operations
    geocoding_service.dart  # GeocodingService — Nominatim HTTP calls
    gravatar_service.dart   # GravatarService — MD5 URL generation
    image_upload_service.dart # ImageUploadService — Firebase Storage uploads
  widgets/
    avatar.dart               # Avatar widget (Firebase Storage / Gravatar / placeholder)
    map_marker.dart           # Custom map marker (avatar + name label)
    member_card.dart          # Reusable card for admin panel user lists
    profile_image_cropper.dart # ImagePicker + ImageCropper orchestration
    cropper_preloader.dart    # Web-only image preloading (fixes cropper race condition)
```

## Development Workflow

### Prerequisites
- Flutter SDK 3.41.4+
- Dart SDK ^3.11.1
- A Firebase project with:
  - Email/Password authentication enabled
  - Firestore Database created
  - Firebase Storage enabled
  - A web app registered
  - Security rules deployed (`firebase deploy --only firestore,storage`)

### Local Setup
```bash
flutter pub get
cp .env.example .env    # Fill in Firebase config values
```

### Running
```bash
make run-web    # Launch in Chrome with Firebase config from .env
make run        # Launch on connected device/emulator
make build-web  # Build release web app (base-href /hollysheet-map/)
make analyze    # Run Flutter analyzer (no-fatal-infos, no-fatal-warnings)
make clean      # Clean build artifacts
```

### VS Code
- Debug config: "Flutter Chrome (Firebase)" in `.vscode/launch.json`
- Automatically loads `.env` and passes dart-defines on launch

### CI/CD
- GitHub Actions (`.github/workflows/main.yml`) — builds and deploys to
  GitHub Pages on every push/PR to `master`
- Required repository secrets:
  `FIREBASE_API_KEY`, `FIREBASE_AUTH_DOMAIN`, `FIREBASE_PROJECT_ID`,
  `FIREBASE_STORAGE_BUCKET`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_APP_ID`

## Key Conventions & Patterns

### Firebase Config via dart-define
Firebase configuration is passed at build/run time via `--dart-define` flags —
**never hardcoded** or committed to the repo. `app.dart` reads these with
`const String.fromEnvironment(...)`. The `Makefile` reads from `.env`;
CI/CD reads from GitHub secrets.

### Approval-Based Access Flow
1. New users are created via `LoginPage` with `Role.pending` and `approved: false`
2. After sign-up/sign-in, `AuthProvider.authStateChanges` fires →
   `WaitingPage` loads the user document to check `approved`
3. If approved, `WaitingPage` redirects to `/map`
4. `MapPage` checks `approved` on the current user; if not approved,
   redirects back to `/waiting`
5. Firestore rules enforce this server-side: users can read their own profile
   regardless of approval status (critical for step 2 — without it, the user
   is stuck on the waiting screen forever)

### Firestore Streams
`UserProvider` subscribes to real-time Firestore streams via `FirestoreService`:
- `getUserStream(uid)` — single user document snapshots
- `getApprovedUsersStream()` / `getPendingUsersStream()` / `getMembersStream()` /
  `getAdminsStream()` — filtered lists using compound `where` clauses

**Known issue:** These streams are not canceled when `UserProvider` is disposed
during navigation, which can cause memory leaks (see `lib/providers/user_provider.dart`).

### Geocoding Results Shape
`GeocodingService.search()` returns `List<Map<String, dynamic>>` with keys:
`displayName`, `latitude`, `longitude`, `country`, `city`. The `_selectLocation`
method in `ProfilePage` maps these to `User` fields (`country`, `city`,
`latitude`, `longitude`).

### Image Upload Flow
1. `ProfilePage._uploadAvatar()` calls `ProfileImageCropper.cropImage()`
2. `ProfileImageCropper` picks from gallery → preloads on web → opens `ImageCropper`
3. Cropped `CroppedFile` → `ImageUploadService.uploadImage()` → uploads bytes to
   Firebase Storage → gets download URL → updates Firestore `avatarUrl`
4. `ProfilePage` then calls `UserProvider.updateUser()` to update the local model

### Null-Safety & Error Handling
- `User.fromFirestore()` uses null-coalescing extensively for backward compatibility
  (e.g., falls back from `userId` to `discordId` to `uid`)
- `FirestoreService.getUserStream()` has error handling via `onError` in `UserProvider`
- Firestore rules are written defensively (see `firestore.rules`)

## Recent Git History (Notable Changes)

| Commit | Summary |
|--------|---------|
| `6c965a8` | Replaced expired default Firestore security rules |
| `58a610d` | Implemented image preloading for web cropper to fix initialization race condition |
| `c195a1f` | Added error handling to Firestore user stream and null-safe `User.fromFirestore` |
| `74bdec2` | Added `context` parameter to image cropper for web support (WebUiSettings) |
| `b6d9c97` | Added `firebase_storage` dependency and updated image upload service |

## Dependencies

### Production
| Package | Version | Purpose |
|---------|---------|---------|
| flutter | SDK | Framework |
| provider | ^6.1.2 | State management |
| go_router | ^14.6.2 | Declarative routing |
| firebase_core | ^3.12.1 | Firebase initialization |
| firebase_auth | ^5.5.1 | Email/password auth |
| cloud_firestore | ^5.6.5 | Firestore database |
| firebase_storage | ^12.4.10 | Profile image storage |
| flutter_map | ^8.1.0 | OpenStreetMap integration |
| latlong2 | ^0.9.1 | LatLng utilities |
| http | ^1.3.0 | Nominatim geocoding HTTP calls |
| crypto | ^3.0.3 | MD5 for Gravatar URLs |
| image_picker | ^1.1.2 | Gallery image selection |
| image_cropper | ^9.0.3 | Image cropping UI |
| image_compression | ^1.0.2 | Image compression (added, not yet integrated) |
| cupertino_icons | ^1.0.8 | iOS-style icons |

### Dev
| Package | Version | Purpose |
|---------|---------|---------|
| flutter_test | SDK | Testing framework |
| flutter_lints | ^6.0.0 | Linting rules |

## Deployment Notes

- Web app is deployed to **GitHub Pages** at `/hollysheet-map/` (base-href)
- The `make build-web` target and CI both use `--base-href /hollysheet-map/`
- Firebase project is managed via the Firebase CLI (`firebase deploy`)
- `.firebaserc` is currently empty (no project alias configured)
