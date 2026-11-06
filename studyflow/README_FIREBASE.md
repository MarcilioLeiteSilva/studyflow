# Firebase Setup Instructions

To enable Cloud Sync and Backup features, you need to connect this app to your Firebase project.

## Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** and follow the setup steps.
3. Enable **Google Analytics** (optional).

## Step 2: Add Android App
1. In your Firebase Project Overview, click the **Android** icon.
2. Enter the package name: `com.example.flutter_code` (or check `android/app/build.gradle` -> `applicationId`).
3. Click **Register app**.
4. **Download `google-services.json`**.
5. Move this file to: `D:\project\Study Planner\flutter_code\android\app\google-services.json`.

## Step 3: Enable Authentication
1. In Firebase Console, go to **Authentication** > **Sign-in method**.
2. Enable **Google**.
3. Enable **Email/Password** (if needed).

## Step 4: Enable Firestore Database
1. Go to **Firestore Database**.
2. Click **Create database**.
3. Start in **Test mode** (for development) or **Production mode**.

## Step 5: Add SHA-1 Fingerprint (Required for Google Sign-In)
1. Run this command in your project terminal:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   (On Windows: `gradlew signingReport`)
2. Copy the `SHA1` key from the output.
3. Go to Firebase Console > Project Settings > General > Your Apps > Add fingerprint.
4. Paste the SHA-1 key.

## Step 6: Build & Run
Run the app:
```bash
flutter run
```
