# Upgrades added

## Localization (EN, FR, NL, DE, ES)
- ARB files under `/l10n` and `l10n.yaml`
- App uses `AppLocalizations` with `flutter gen-l10n`
- **Language switcher** in Settings (gear icon on Home)

## Currency conversion
- `lib/currency_service.dart` with offline EUR-based rates (EUR/USD/GBP)
- Uses chosen currency from Settings to display prices
- Replace with a real API call and cache results daily for production

## Firebase (optional)
- Added `firebase_core` and `cloud_firestore` dependencies
- Home screen `_loadParks()` shows where to fetch from `parks` collection
- Falls back to local assets if Firebase not configured

## Next
- Add real Google Maps key (Android/iOS)
- For Firebase: run `flutterfire configure` and initialize in `main()`
- Add more strings to ARB as you expand UI
