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
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('nl'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Funparks'**
  String get appTitle;

  /// No description provided for @viewPark.
  ///
  /// In en, this message translates to:
  /// **'View Park'**
  String get viewPark;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @attractions.
  ///
  /// In en, this message translates to:
  /// **'Attractions'**
  String get attractions;

  /// No description provided for @foodAndPrices.
  ///
  /// In en, this message translates to:
  /// **'Food & Prices'**
  String get foodAndPrices;

  /// No description provided for @hotels.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get hotels;

  /// No description provided for @entryFrom.
  ///
  /// In en, this message translates to:
  /// **'Entry from'**
  String get entryFrom;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @parkMap.
  ///
  /// In en, this message translates to:
  /// **'Park map'**
  String get parkMap;

  /// No description provided for @highlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get highlights;

  /// No description provided for @translate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translate;

  /// No description provided for @adult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get adult;

  /// No description provided for @child.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get child;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @nearbyParks.
  ///
  /// In en, this message translates to:
  /// **'Nearby Parks'**
  String get nearbyParks;

  /// No description provided for @thrill.
  ///
  /// In en, this message translates to:
  /// **'Thrill'**
  String get thrill;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @simulator.
  ///
  /// In en, this message translates to:
  /// **'Simulator'**
  String get simulator;

  /// No description provided for @topPick.
  ///
  /// In en, this message translates to:
  /// **'Top pick'**
  String get topPick;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @lowestWait.
  ///
  /// In en, this message translates to:
  /// **'Lowest wait'**
  String get lowestWait;

  /// No description provided for @highestRated.
  ///
  /// In en, this message translates to:
  /// **'Highest rated'**
  String get highestRated;

  /// No description provided for @tapCardForDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap a card for full details'**
  String get tapCardForDetails;

  /// No description provided for @addToMyDay.
  ///
  /// In en, this message translates to:
  /// **'Add to My Day'**
  String get addToMyDay;

  /// No description provided for @removeFromMyDay.
  ///
  /// In en, this message translates to:
  /// **'Remove from My Day'**
  String get removeFromMyDay;

  /// No description provided for @addToMyFood.
  ///
  /// In en, this message translates to:
  /// **'Add to My Food'**
  String get addToMyFood;

  /// No description provided for @removeFromMyFood.
  ///
  /// In en, this message translates to:
  /// **'Remove from My Food'**
  String get removeFromMyFood;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @liveWait.
  ///
  /// In en, this message translates to:
  /// **'Live wait'**
  String get liveWait;

  /// No description provided for @setMyWait.
  ///
  /// In en, this message translates to:
  /// **'Set my wait'**
  String get setMyWait;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get yourRating;

  /// No description provided for @yourComment.
  ///
  /// In en, this message translates to:
  /// **'Your comment'**
  String get yourComment;

  /// No description provided for @commentHint.
  ///
  /// In en, this message translates to:
  /// **'Share tips, what to expect, best seats, etc…'**
  String get commentHint;

  /// No description provided for @commentHintFood.
  ///
  /// In en, this message translates to:
  /// **'Share tips (best value, favorite dishes, good spots)…'**
  String get commentHintFood;

  /// No description provided for @myWaitTimeOptional.
  ///
  /// In en, this message translates to:
  /// **'My wait time (optional)'**
  String get myWaitTimeOptional;

  /// No description provided for @minutesHint.
  ///
  /// In en, this message translates to:
  /// **'Minutes (e.g. 25)'**
  String get minutesHint;

  /// No description provided for @menuAndPrices.
  ///
  /// In en, this message translates to:
  /// **'Menu & prices'**
  String get menuAndPrices;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved!'**
  String get saved;

  /// No description provided for @rooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get rooms;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'night'**
  String get night;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @breakfastIncluded.
  ///
  /// In en, this message translates to:
  /// **'Breakfast included'**
  String get breakfastIncluded;

  /// No description provided for @breakfastNotIncluded.
  ///
  /// In en, this message translates to:
  /// **'Breakfast not included'**
  String get breakfastNotIncluded;

  /// No description provided for @addToMyStay.
  ///
  /// In en, this message translates to:
  /// **'Add to My Stay'**
  String get addToMyStay;

  /// No description provided for @removeFromMyStay.
  ///
  /// In en, this message translates to:
  /// **'Remove from My Stay'**
  String get removeFromMyStay;

  /// No description provided for @lowestPrice.
  ///
  /// In en, this message translates to:
  /// **'Lowest price'**
  String get lowestPrice;
}

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
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
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
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
