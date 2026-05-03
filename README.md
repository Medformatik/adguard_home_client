<p align="center">
  <img src="assets/images/play-store/app_icon.png" alt="AdGuard Home Client" width="128" />
</p>

<h1 align="center">AdGuard Home Client</h1>

<p align="center">
  An Android remote for monitoring and controlling your AdGuard Home instances.
</p>

<p align="center">
  <a href="https://github.com/Medformatik/adguard_home_client/releases/latest"><img alt="Latest release" src="https://img.shields.io/github/v/release/Medformatik/adguard_home_client?label=APK&color=blue" /></a>
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/github/license/Medformatik/adguard_home_client" /></a>
</p>

<p align="center">
  <a href="https://play.google.com/store/apps/details?id=de.medformatik.adguard_home_client"><img alt="Get it on Google Play" height="88" align="middle" src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" /></a>
  &nbsp;
  <a href="https://apps.obtainium.imranr.dev/redirect.html?r=obtainium://add/https://github.com/Medformatik/adguard_home_client"><img alt="Add to Obtainium" height="60" align="middle" src="https://raw.githubusercontent.com/ImranR98/Obtainium/main/assets/graphics/badge_obtainium.png" /></a>
</p>

## Features

- **Multi-instance support.** Configure as many AdGuard Home instances as you like and switch between them with a tap on the AppBar title.
- **Unified view** that aggregates stats, top-N tables, and the query log across every instance. Toggles control all instances at once when they agree, and show "Mixed" (disabled) when they don't.
- **Live statistics** for DNS queries, blocked traffic, malware/phishing, parental control, and Safe Search — with 90-day trend charts and Top queried domains, Top blocked domains, and Top clients tables.
- **Query log** with searchable, time-stamped entries, blocked/allowed indicators, human-readable reasons, and a details sheet. In Unified mode each entry is tagged with its source instance.
- **Protection toggles.** One-tap on/off for the master Protection, plus Safe Browsing, Parental Control, and Safe Search.
- **HTTPS / TLS** with an optional `Verify TLS certificate` toggle for self-signed certificates.
- **Material 3 UI** with system-following dark mode, pull-to-refresh, and humanized numbers.

## Install

- **Google Play:** [play.google.com/store/apps/details?id=de.medformatik.adguard_home_client](https://play.google.com/store/apps/details?id=de.medformatik.adguard_home_client)
- **APK from GitHub:** every tagged release ships a signed `app-release.apk`. Grab it from the [latest release](https://github.com/Medformatik/adguard_home_client/releases/latest).
- **[Obtainium](https://github.com/ImranR98/Obtainium):** tap the badge above, or paste this into Obtainium's "Add App" → "App source URL" field:
  ```
  https://github.com/Medformatik/adguard_home_client
  ```

## Screenshots

<p>
  <img src="assets/images/play-store/screenshots/Google%20Pixel%204%20XL%20%281520x3040%29/Google%20Pixel%204%20XL%20Screenshot%200.png" height="400" alt="Home screen with stats" />
  <img src="assets/images/play-store/screenshots/Google%20Pixel%204%20XL%20%281520x3040%29/Google%20Pixel%204%20XL%20Screenshot%201.png" height="400" alt="Top domains and clients" />
</p>

## Setup

1. Open the app and tap **Add instance**.
2. Enter the AdGuard Home host (IPv4, IPv6, or domain), port (default `3000`), username and password.
3. Toggle **Use HTTPS** if your instance is reachable over TLS. For self-signed certificates, also disable **Verify TLS certificate**.
4. Save. The home screen reconnects and starts streaming stats.
5. Add more instances any time and switch between them via the AppBar title — or pick **Unified** to aggregate them all.

## Build from source

```bash
git clone https://github.com/Medformatik/adguard_home_client.git
cd adguard_home_client
flutter pub get
flutter run
```

Build a release APK with:

```bash
flutter build apk --release
```

For signed builds you'll need an `android/key.properties` pointing at your keystore (see [Flutter's signing guide](https://docs.flutter.dev/deployment/android#signing-the-app)). The repo's `android/.gitignore` excludes `key.properties` and `*.jks` so credentials never reach the repo.

## ⚠️ DISCLAIMER ⚠️

This is an unofficial app. The development of the AdGuard Home software is not related with this application in any way.
