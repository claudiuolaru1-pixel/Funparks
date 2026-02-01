# Funparks — Flutter MVP

A playful, map-first *theme park discovery* app (MVP) for Android and iOS.

## What works
- Home map with themed pins (🎢 rollercoaster, 🌊 water, 🏰 fantasy, 🐘 safari, 🤖 tech)
- Tap a park → sheet with picture, price, and button to open the Park Detail screen
- Park Detail with tabs: Overview, Attractions (list), Food (with prices)
- Prices displayed in Euros by default; you can wire a currency API later

## Quick start
1. Install Flutter SDK (3.x).  
2. Add your **Google Maps API key**:
   - **Android**: In `android/app/src/main/AndroidManifest.xml`, inside `<application>`, add:
     ```xml
     <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_API_KEY"/>
     ```
   - **iOS**: In `ios/Runner/AppDelegate.swift`, add:
     ```swift
     GMSServices.provideAPIKey("YOUR_API_KEY")
     ```
     and include Maps SDK for iOS in your CocoaPods.
3. Run:
   ```bash
   flutter pub get
   flutter run
   ```

## Packaging for stores
- **Android (Google Play):**
  - Update app id in `android/app/build.gradle` (e.g., `com.funparks.app`).
  - Create a release keystore and sign the app.
  - `flutter build appbundle` → upload AAB to Play Console.
- **iOS (App Store):**
  - Set a unique bundle identifier in Xcode.
  - Add icons, launch screens, and required privacy usage strings.
  - `flutter build ipa` (or archive via Xcode) → App Store Connect.

## Data
Static JSON is provided for MVP under `assets/data/`. Replace with a backend later (Firebase/Supabase).

## Legal
Provide a Privacy Policy URL, comply with **GDPR**, and ensure third-party data (menus, maps) is licensed or user-contributed.


<!-- Dashboard badge -->
[![Dashboard](https://img.shields.io/badge/Pixel-Dashboard-1f6feb)](https://claudiuolaru1.github.io/pixel/)
[![data.json](https://img.shields.io/badge/API-data.json-0ea5e9)](https://claudiuolaru1.github.io/pixel/data.json)

> Replace `<YOUR_GITHUB_USER>` and `<YOUR_REPO>` after enabling **GitHub Pages** (Source: GitHub Actions).
> The URL appears in the **Dashboard (GitHub Pages)** workflow logs after first publish.

