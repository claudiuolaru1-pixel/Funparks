# CI/CD Notes

This project includes GitHub Actions workflows under `.github/workflows/`:

- `ci.yml` — builds Android **AAB** (Ubuntu) and iOS **IPA (unsigned)** (macOS).
- `lint_test.yml` — runs formatting and tests on PRs.

## Android signing (optional, release signing)

Add these GitHub secrets in your repository for a signed AAB:

- `ANDROID_KEYSTORE_BASE64` — base64 of your `keystore.jks`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

Then add steps before the build to decode and configure Gradle signing.

## iOS signing

The workflow currently builds an **unsigned IPA**. To sign and upload to TestFlight:

- Add Apple credentials/secrets (App Store Connect API key) or use **fastlane**.
- Set up automatic code signing with a Developer/Distribution certificate and provisioning profile.

## Store assets generation

The project already contains configs for:
- `flutter_launcher_icons` (app icons)
- `flutter_native_splash` (splash)

CI runs these generators before building.



## Android Auto Screenshots workflow

Workflow: `.github/workflows/android_auto_screenshots.yml`

- Spins up an Android emulator (API 34), runs the integration test for each locale, and
  saves images from `build/integration_test/`.
- Copies the images to `android/fastlane/metadata/android/<locale>/phoneScreenshots/`.
- Optionally uploads Play listing (+ AAB) if you set `upload_to_play=true`.

Run manually with inputs:
- `locales`: e.g., `en fr nl de es it pt ru`
- `upload_to_play`: `true` or `false`

Secrets required for upload: `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` (base64).


## iOS Auto Screenshots workflow

Workflow: `.github/workflows/ios_auto_screenshots.yml`

- Boots an iOS Simulator (defaults to **iPhone 14 Pro**).
- Runs integration tests per locale (`--dart-define=APP_LOCALE=<code>`) and captures images from `build/integration_test/`.
- Injects images into `ios/fastlane/screenshots/<locale>/` using App Store locale codes.
- Optionally uploads **metadata + screenshots** to App Store Connect with `fastlane deliver_upload`.

Inputs:
- `locales`: e.g., `en fr nl de es it pt ru`
- `device_name`: Simulator profile (e.g., `iPhone 14 Pro`)
- `upload_to_appstore`: `true` or `false`

Secrets required for upload:
- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_KEY` (base64 of .p8)


### Upload modes

**Android Auto Screenshots**
- `upload_mode`: `none` | `screenshots-only` | `full`
  - `screenshots-only`: uploads screenshots + listing, no AAB
  - `full`: builds AAB and uploads along with screenshots + listing

**iOS Auto Screenshots**
- `upload_mode`: `none` | `screenshots-only` | `metadata+screens`
  - `screenshots-only`: uploads screenshots only (skips metadata)
  - `metadata+screens`: uploads both

### Nightly schedule timing

- Android: `0 1 * * *` (≈ 03:00 Europe/Brussels during CEST; 02:00 during CET)
- iOS: `30 1 * * *` (≈ 03:30 Europe/Brussels during CEST; 02:30 during CET)


### Release guard for Android `full` uploads
- The **Android Auto Screenshots** workflow enforces a guard:
  - If `upload_mode = full` **and** the workflow is not running on a **tagged** ref, it will fail before uploading.
  - Create a tag (e.g., `v1.0.0`) and run the workflow from that tag to permit a FULL upload.


### Release guard for Android `screenshots-only` uploads
- The workflow now also **requires a tag** for `upload_mode = screenshots-only`.
- To upload screenshots/listing without AAB: create a tag (e.g., `v1.0.1`) and run the workflow from that tag.


## Notifications

Both **Android Auto Screenshots** and **iOS Auto Screenshots** workflows send optional notifications:

### Slack (optional)
- Secret: `SLACK_WEBHOOK_URL` (Incoming Webhook).
- The step runs **always()** and posts success/failure with run links.

### Email (optional)
Uses `dawidd6/action-send-mail@v3`. Required repo secrets:
- `SMTP_SERVER` (e.g., `smtp.sendgrid.net`)
- `SMTP_PORT` (e.g., `587`)
- `SMTP_USERNAME`
- `SMTP_PASSWORD`
- `NOTIFY_EMAIL_TO` (comma-separated list or a single email)

If these secrets aren’t set, the respective step is skipped/logs a note.


## Dashboard (GitHub Pages)
- Script: `scripts/generate_dashboard.py` scans Fastlane folders and builds `dashboard/index.html` with coverage by locale/device.
- Workflow: `.github/workflows/dashboard.yml` publishes the page to **GitHub Pages** (nightly + manual).
- Enable **Pages** in your repo settings (Source: GitHub Actions). After the first run, the URL will be shown in the workflow logs.


### Dashboard badges
Add these links to your README once Pages is enabled:
- Dashboard: `https://claudiuolaru1.github.io/pixel/`
- JSON API: `https://claudiuolaru1.github.io/pixel/data.json`
