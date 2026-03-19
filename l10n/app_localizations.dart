// lib/l10n/app_localizations.dart
// ✅ COMPLETE — all getters used by park_detail_screen.dart are declared here.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('nl'),
    Locale('pt'),
    Locale('ru'),
  ];

  // ── App ──────────────────────────────────────────────────────────
  String get appTitle;
  String get viewPark;

  // ── Tabs ─────────────────────────────────────────────────────────
  String get overview;
  String get attractions;
  String get foodAndPrices;
  String get hotels;

  // ── Overview chips ───────────────────────────────────────────────
  String get entryFrom;
  String get hours;
  String get location;
  String get adult;
  String get child;
  String get website;
  String get highlights;

  // ── Sections ─────────────────────────────────────────────────────
  String get directions;
  String get share;
  String get comingSoon;
  String get parkMap;

  // ── Settings ─────────────────────────────────────────────────────
  String get settings;
  String get language;
  String get currency;
  String get nearbyParks;

  // ── Attraction categories ────────────────────────────────────────
  String get thrill;
  String get family;
  String get water;
  String get simulator;

  // ── Sorting ──────────────────────────────────────────────────────
  String get topPick;
  String get recommended;
  String get lowestWait;
  String get highestRated;

  // ── My Day / Food ────────────────────────────────────────────────
  String get addToMyDay;
  String get removeFromMyDay;
  String get addToMyFood;
  String get removeFromMyFood;

  // ── Live wait ────────────────────────────────────────────────────
  String get liveWait;
  String get setMyWait;

  // ── Detail screens ───────────────────────────────────────────────
  String get yourRating;
  String get yourComment;
  String get commentHint;
  String get commentHintFood;
  String get myWaitTimeOptional;
  String get minutesHint;
  String get menuAndPrices;
  String get save;
  String get saved;

  // ── Hotels ───────────────────────────────────────────────────────
  String get rooms;
  String get night;
  String get price;
  String get rating;
  String get breakfastIncluded;
  String get breakfastNotIncluded;
  String get addToMyStay;
  String get removeFromMyStay;
  String get lowestPrice;

  // ── Misc ─────────────────────────────────────────────────────────
  String get tapCardForDetails;
  String get translate;

  // ── Favorites ────────────────────────────────────────────────────
  String get favoritesTitle;
  String get noFavoritesYet;
  String get removeFromFavorites;
}

// ─────────────────────────────────────────────────────────────────────────────
// Delegate
// ─────────────────────────────────────────────────────────────────────────────

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'it',
        'nl',
        'pt',
        'ru',
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale".',
  );
}
