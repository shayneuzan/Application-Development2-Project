import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for walkers nearby'**
  String get searchHint;

  /// No description provided for @walkersNearby.
  ///
  /// In en, this message translates to:
  /// **'Walkers Nearby'**
  String get walkersNearby;

  /// No description provided for @discoverWalkers.
  ///
  /// In en, this message translates to:
  /// **'Discover active walkers ready to help'**
  String get discoverWalkers;

  /// No description provided for @viewList.
  ///
  /// In en, this message translates to:
  /// **'View List'**
  String get viewList;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @walkers.
  ///
  /// In en, this message translates to:
  /// **'Walkers'**
  String get walkers;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {userName}!'**
  String welcomeBack(String userName);

  /// No description provided for @furryFriendWaiting.
  ///
  /// In en, this message translates to:
  /// **'Your furry friend is waiting for a walk'**
  String get furryFriendWaiting;

  /// No description provided for @latestBooking.
  ///
  /// In en, this message translates to:
  /// **'Latest Booking'**
  String get latestBooking;

  /// No description provided for @withPet.
  ///
  /// In en, this message translates to:
  /// **'with {petName}'**
  String withPet(String petName);

  /// No description provided for @browseWalkers.
  ///
  /// In en, this message translates to:
  /// **'Browse Walkers'**
  String get browseWalkers;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noRecentActivity;

  /// No description provided for @petWalk.
  ///
  /// In en, this message translates to:
  /// **'{petName} walk'**
  String petWalk(String petName);

  /// No description provided for @byWalker.
  ///
  /// In en, this message translates to:
  /// **'by {walkerName}'**
  String byWalker(String walkerName);

  /// No description provided for @favoriteWalkers.
  ///
  /// In en, this message translates to:
  /// **'Favorite Walkers'**
  String get favoriteWalkers;

  /// No description provided for @findWalkers.
  ///
  /// In en, this message translates to:
  /// **'Find Walkers'**
  String get findWalkers;

  /// No description provided for @countWalkersNearby.
  ///
  /// In en, this message translates to:
  /// **'{count} walkers nearby'**
  String countWalkersNearby(int count);

  /// No description provided for @availableWalkers.
  ///
  /// In en, this message translates to:
  /// **'Available Walkers'**
  String get availableWalkers;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get showAll;

  /// No description provided for @showFavorites.
  ///
  /// In en, this message translates to:
  /// **'Show Favorites'**
  String get showFavorites;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet!'**
  String get noFavoritesYet;

  /// No description provided for @noWalkersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No walkers available.'**
  String get noWalkersAvailable;

  /// No description provided for @walksCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} walks completed'**
  String walksCompletedCount(int count);

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @professionalWalker.
  ///
  /// In en, this message translates to:
  /// **'Professional Dog Walker'**
  String get professionalWalker;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @walks.
  ///
  /// In en, this message translates to:
  /// **'Walks'**
  String get walks;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @yearsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} years'**
  String yearsCount(int count);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @servicesIncluded.
  ///
  /// In en, this message translates to:
  /// **'Services Included'**
  String get servicesIncluded;

  /// No description provided for @recentReviews.
  ///
  /// In en, this message translates to:
  /// **'Recent Reviews'**
  String get recentReviews;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get noReviewsYet;

  /// No description provided for @selectPet.
  ///
  /// In en, this message translates to:
  /// **'Select Pet'**
  String get selectPet;

  /// No description provided for @walkDuration.
  ///
  /// In en, this message translates to:
  /// **'Walk Duration'**
  String get walkDuration;

  /// No description provided for @baseRate.
  ///
  /// In en, this message translates to:
  /// **'Base Rate'**
  String get baseRate;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get totalPrice;

  /// No description provided for @selectDateTime.
  ///
  /// In en, this message translates to:
  /// **'Select Date & Time'**
  String get selectDateTime;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @pleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please log in'**
  String get pleaseLogin;

  /// No description provided for @availableTimeSlots.
  ///
  /// In en, this message translates to:
  /// **'Available Time Slots'**
  String get availableTimeSlots;

  /// No description provided for @pet.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get pet;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @bookingSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Booking Successful!'**
  String get bookingSuccessful;

  /// No description provided for @walkRequested.
  ///
  /// In en, this message translates to:
  /// **'Your walk with {walkerName} has been requested.'**
  String walkRequested(String walkerName);

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String durationMinutes(int minutes);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @savedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Saved Addresses'**
  String get savedAddresses;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @emailUpdates.
  ///
  /// In en, this message translates to:
  /// **'Email Updates'**
  String get emailUpdates;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @aboutPawWalk.
  ///
  /// In en, this message translates to:
  /// **'About PawWalk'**
  String get aboutPawWalk;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirmLogOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get confirmLogOut;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone. All your data, including saved addresses and payment methods, will be deleted.'**
  String get deleteAccountConfirmation;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account successfully deleted'**
  String get accountDeleted;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English (US)'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French (FR)'**
  String get french;

  /// No description provided for @addPet.
  ///
  /// In en, this message translates to:
  /// **'Add Pet'**
  String get addPet;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @totalWalks.
  ///
  /// In en, this message translates to:
  /// **'Total Walks'**
  String get totalWalks;

  /// No description provided for @pets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get pets;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @myPets.
  ///
  /// In en, this message translates to:
  /// **'My Pets'**
  String get myPets;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @addNewPet.
  ///
  /// In en, this message translates to:
  /// **'Add New Pet'**
  String get addNewPet;

  /// No description provided for @noPetsFound.
  ///
  /// In en, this message translates to:
  /// **'No pets found. Add your first pet above!'**
  String get noPetsFound;

  /// No description provided for @deletePet.
  ///
  /// In en, this message translates to:
  /// **'Delete Pet'**
  String get deletePet;

  /// No description provided for @deletePetConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {petName}?'**
  String deletePetConfirmation(String petName);

  /// No description provided for @specialInstructions.
  ///
  /// In en, this message translates to:
  /// **'Special instructions'**
  String get specialInstructions;

  /// No description provided for @yearsOld.
  ///
  /// In en, this message translates to:
  /// **'{count} years old'**
  String yearsOld(int count);

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not Logged In'**
  String get notLoggedIn;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @trackWalk.
  ///
  /// In en, this message translates to:
  /// **'Track Walk'**
  String get trackWalk;

  /// No description provided for @bookAWalk.
  ///
  /// In en, this message translates to:
  /// **'Book a Walk'**
  String get bookAWalk;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// No description provided for @cancelBookingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this booking? This action cannot be undone.'**
  String get cancelBookingConfirmation;

  /// No description provided for @noKeepIt.
  ///
  /// In en, this message translates to:
  /// **'No, Keep It'**
  String get noKeepIt;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @cancellationFeatureSoon.
  ///
  /// In en, this message translates to:
  /// **'Cancellation feature coming soon'**
  String get cancellationFeatureSoon;

  /// No description provided for @upcomingCount.
  ///
  /// In en, this message translates to:
  /// **'Upcoming ({count})'**
  String upcomingCount(int count);

  /// No description provided for @pastCount.
  ///
  /// In en, this message translates to:
  /// **'Past ({count})'**
  String pastCount(int count);

  /// No description provided for @noUpcomingWalks.
  ///
  /// In en, this message translates to:
  /// **'No upcoming walks scheduled.'**
  String get noUpcomingWalks;

  /// No description provided for @noPastWalks.
  ///
  /// In en, this message translates to:
  /// **'No past walks yet.'**
  String get noPastWalks;

  /// No description provided for @rebook.
  ///
  /// In en, this message translates to:
  /// **'Re-book'**
  String get rebook;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
