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

  /// No description provided for @bookingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled successfully'**
  String get bookingCancelled;

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

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @disputes.
  ///
  /// In en, this message translates to:
  /// **'Disputes'**
  String get disputes;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @suspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get suspend;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @sendAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Send Announcement'**
  String get sendAnnouncement;

  /// No description provided for @platformSettings.
  ///
  /// In en, this message translates to:
  /// **'Platform Settings'**
  String get platformSettings;

  /// No description provided for @viewReports.
  ///
  /// In en, this message translates to:
  /// **'View Reports'**
  String get viewReports;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @administrator.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get administrator;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @maintenanceMode.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Mode'**
  String get maintenanceMode;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'Contact Email'**
  String get contactEmail;

  /// No description provided for @saveEmail.
  ///
  /// In en, this message translates to:
  /// **'Save Email'**
  String get saveEmail;

  /// No description provided for @walker.
  ///
  /// In en, this message translates to:
  /// **'Walker'**
  String get walker;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @weeklyOverview.
  ///
  /// In en, this message translates to:
  /// **'Weekly Overview'**
  String get weeklyOverview;

  /// No description provided for @recentWalks.
  ///
  /// In en, this message translates to:
  /// **'Recent Completed Walks'**
  String get recentWalks;

  /// No description provided for @bookingRequests.
  ///
  /// In en, this message translates to:
  /// **'Booking Requests'**
  String get bookingRequests;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @requestDeclined.
  ///
  /// In en, this message translates to:
  /// **'Request Declined'**
  String get requestDeclined;

  /// No description provided for @requestDeclinedMessage.
  ///
  /// In en, this message translates to:
  /// **'{walkerName} declined your walk request for {petName}.'**
  String requestDeclinedMessage(String walkerName, String petName);

  /// No description provided for @requestDeclinedWalkerMessage.
  ///
  /// In en, this message translates to:
  /// **'You have declined the walk request for {petName} from {ownerName}.'**
  String requestDeclinedWalkerMessage(String petName, String ownerName);

  /// No description provided for @requestDeclinedSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Request Declined! Pet: {petName}\nOwner: {ownerName}'**
  String requestDeclinedSnackBar(String petName, String ownerName);

  /// No description provided for @walkRequestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Walk Request Accepted!'**
  String get walkRequestAccepted;

  /// No description provided for @walkRequestAcceptedMessage.
  ///
  /// In en, this message translates to:
  /// **'{walkerName} is ready to walk {petName}! Go to \"Messages\" in your drawer to coordinate details.'**
  String walkRequestAcceptedMessage(String walkerName, String petName);

  /// No description provided for @walkRequestAcceptedWalkerMessage.
  ///
  /// In en, this message translates to:
  /// **'You have accepted the walk request for {petName}. Open \"View Chat\" to discuss location with {ownerName}.'**
  String walkRequestAcceptedWalkerMessage(String petName, String ownerName);

  /// No description provided for @requestAcceptedSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Request Accepted! Pet: {petName}\nOwner: {ownerName}'**
  String requestAcceptedSnackBar(String petName, String ownerName);

  /// No description provided for @accountPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Your account is pending admin approval. You cannot accept bookings yet.'**
  String get accountPendingApproval;

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {userName}!'**
  String helloUser(String userName);

  /// No description provided for @activityOverview.
  ///
  /// In en, this message translates to:
  /// **'Here\'s your activity overview'**
  String get activityOverview;

  /// No description provided for @todaysEarnings.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Earnings'**
  String get todaysEarnings;

  /// No description provided for @viewAllEarnings.
  ///
  /// In en, this message translates to:
  /// **'View All Earnings'**
  String get viewAllEarnings;

  /// No description provided for @upcomingWalks.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Walks'**
  String get upcomingWalks;

  /// No description provided for @ownerWithName.
  ///
  /// In en, this message translates to:
  /// **'Owner: {ownerName}'**
  String ownerWithName(String ownerName);

  /// No description provided for @newRequests.
  ///
  /// In en, this message translates to:
  /// **'New Requests'**
  String get newRequests;

  /// No description provided for @noUpcomingRequests.
  ///
  /// In en, this message translates to:
  /// **'No Upcoming Requests'**
  String get noUpcomingRequests;

  /// No description provided for @petDurationWalk.
  ///
  /// In en, this message translates to:
  /// **'{petName} - {duration} min walk'**
  String petDurationWalk(String petName, int duration);

  /// No description provided for @yourSchedule.
  ///
  /// In en, this message translates to:
  /// **'Your Schedule'**
  String get yourSchedule;

  /// No description provided for @selectDateToSeeWalks.
  ///
  /// In en, this message translates to:
  /// **'Select a date to see walks'**
  String get selectDateToSeeWalks;

  /// No description provided for @upcomingWalksForDate.
  ///
  /// In en, this message translates to:
  /// **'Your Upcoming Walks for {date}'**
  String upcomingWalksForDate(String date);

  /// No description provided for @noWalksScheduledDay.
  ///
  /// In en, this message translates to:
  /// **'No walks scheduled for this day'**
  String get noWalksScheduledDay;

  /// No description provided for @noWalksScheduledDate.
  ///
  /// In en, this message translates to:
  /// **'No walks scheduled on {date}'**
  String noWalksScheduledDate(String date);

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterNameHint;

  /// No description provided for @fullBio.
  ///
  /// In en, this message translates to:
  /// **'Full Bio'**
  String get fullBio;

  /// No description provided for @bioHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us about you'**
  String get bioHint;

  /// No description provided for @hourlyRate.
  ///
  /// In en, this message translates to:
  /// **'Hourly Rate'**
  String get hourlyRate;

  /// No description provided for @yearsExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get yearsExperience;

  /// No description provided for @yearsExperienceHint.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get yearsExperienceHint;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveChanges;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields.'**
  String get pleaseFillAllFields;

  /// No description provided for @hourlyRateError.
  ///
  /// In en, this message translates to:
  /// **'Hourly rate must be greater than 0 \$.'**
  String get hourlyRateError;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get profileUpdated;

  /// No description provided for @pleaseLogInToAddPet.
  ///
  /// In en, this message translates to:
  /// **'Please log in to add a pet'**
  String get pleaseLogInToAddPet;

  /// No description provided for @petAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Pet added successfully!'**
  String get petAddedSuccessfully;

  /// No description provided for @errorAddingPet.
  ///
  /// In en, this message translates to:
  /// **'Error adding pet: {error}'**
  String errorAddingPet(String error);

  /// No description provided for @petName.
  ///
  /// In en, this message translates to:
  /// **'Pet Name'**
  String get petName;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Max'**
  String get nameHint;

  /// No description provided for @enterPetName.
  ///
  /// In en, this message translates to:
  /// **'Please enter pet name'**
  String get enterPetName;

  /// No description provided for @breed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get breed;

  /// No description provided for @breedHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Golden Retriever'**
  String get breedHint;

  /// No description provided for @enterBreed.
  ///
  /// In en, this message translates to:
  /// **'Please enter breed'**
  String get enterBreed;

  /// No description provided for @petAge.
  ///
  /// In en, this message translates to:
  /// **'Pet Age'**
  String get petAge;

  /// No description provided for @ageHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 3'**
  String get ageHint;

  /// No description provided for @enterAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter pet age'**
  String get enterAge;

  /// No description provided for @petSize.
  ///
  /// In en, this message translates to:
  /// **'Pet Size'**
  String get petSize;

  /// No description provided for @small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// No description provided for @enterSpecialInstructions.
  ///
  /// In en, this message translates to:
  /// **'e.g. Friendly with other dogs'**
  String get enterSpecialInstructions;

  /// No description provided for @savePet.
  ///
  /// In en, this message translates to:
  /// **'SAVE PET'**
  String get savePet;

  /// No description provided for @noAddressesFound.
  ///
  /// In en, this message translates to:
  /// **'No addresses found'**
  String get noAddressesFound;

  /// No description provided for @setAsDefaultSuccess.
  ///
  /// In en, this message translates to:
  /// **'{label} set as default address'**
  String setAsDefaultSuccess(String label);

  /// No description provided for @verifyAddressError.
  ///
  /// In en, this message translates to:
  /// **'Could not verify address. Please check your entry.'**
  String get verifyAddressError;

  /// No description provided for @defaultTag.
  ///
  /// In en, this message translates to:
  /// **'DEFAULT'**
  String get defaultTag;

  /// No description provided for @addressFallback.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressFallback;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get setAsDefault;

  /// No description provided for @editAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit address'**
  String get editAddress;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get yourLocation;

  /// No description provided for @noSavedAddresses.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses'**
  String get noSavedAddresses;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addNewAddress;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @searchAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Search for an address...'**
  String get searchAddressHint;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address Label'**
  String get addressLabel;

  /// No description provided for @addressExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Home, Work'**
  String get addressExample;

  /// No description provided for @manualEntryDetails.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry Details'**
  String get manualEntryDetails;

  /// No description provided for @streetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street Address'**
  String get streetAddress;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get postalCode;

  /// No description provided for @verifyAndSaveAddress.
  ///
  /// In en, this message translates to:
  /// **'VERIFY AND SAVE ADDRESS'**
  String get verifyAndSaveAddress;

  /// No description provided for @reviewsFor.
  ///
  /// In en, this message translates to:
  /// **'Reviews for {name}'**
  String reviewsFor(String name);

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @nameCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get nameCardLabel;

  /// No description provided for @nameCardHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get nameCardHint;

  /// No description provided for @bioCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Bio'**
  String get bioCardLabel;

  /// No description provided for @bioCardHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us about you'**
  String get bioCardHint;

  /// No description provided for @hourlyRateCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Hourly Rate'**
  String get hourlyRateCardLabel;

  /// No description provided for @hourlyRateCardSuffix.
  ///
  /// In en, this message translates to:
  /// **'/ hr'**
  String get hourlyRateCardSuffix;

  /// No description provided for @yearsCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get yearsCardLabel;

  /// No description provided for @yearsCardHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 5'**
  String get yearsCardHint;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields.'**
  String get fillAllFields;

  /// No description provided for @hourlyRateZero.
  ///
  /// In en, this message translates to:
  /// **'Hourly rate must be greater than 0.'**
  String get hourlyRateZero;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @noCards.
  ///
  /// In en, this message translates to:
  /// **'No cards saved'**
  String get noCards;

  /// No description provided for @enterAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter address'**
  String get enterAddress;

  /// No description provided for @rescheduleBooking.
  ///
  /// In en, this message translates to:
  /// **'Reschedule Booking'**
  String get rescheduleBooking;

  /// No description provided for @pleaseEnterAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please enter all fields'**
  String get pleaseEnterAllFields;

  /// No description provided for @addressUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Address updated successfully!'**
  String get addressUpdatedSuccessfully;

  /// No description provided for @petUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Pet updated successfully!'**
  String get petUpdatedSuccessfully;

  /// No description provided for @editPet.
  ///
  /// In en, this message translates to:
  /// **'Edit Pet'**
  String get editPet;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'Age (Years)'**
  String get ageYears;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'PawWalk'**
  String get appName;

  /// No description provided for @enterValidCardDetails.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid card details'**
  String get enterValidCardDetails;

  /// No description provided for @otherMethods.
  ///
  /// In en, this message translates to:
  /// **'Other Methods'**
  String get otherMethods;

  /// No description provided for @thankYouForReview.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your review!'**
  String get thankYouForReview;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeReview;

  /// No description provided for @howWasWalk.
  ///
  /// In en, this message translates to:
  /// **'How was the walk with {walkerName}?'**
  String howWasWalk(String walkerName);

  /// No description provided for @forYourDog.
  ///
  /// In en, this message translates to:
  /// **'for your dog, {dogName}'**
  String forYourDog(String dogName);

  /// No description provided for @tellUsMoreAbout.
  ///
  /// In en, this message translates to:
  /// **'Tell us more about the walk'**
  String get tellUsMoreAbout;

  /// No description provided for @describeWalk.
  ///
  /// In en, this message translates to:
  /// **'Describe your experience (optional)'**
  String get describeWalk;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @selectDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Select Date & Time'**
  String get selectDateAndTime;

  /// No description provided for @pleaseLoginToBookWalk.
  ///
  /// In en, this message translates to:
  /// **'Please log in to book a walk'**
  String get pleaseLoginToBookWalk;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved!'**
  String get changesSaved;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @errorLoadingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Error loading notifications.'**
  String get errorLoadingNotifications;

  /// No description provided for @noNotificationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No notifications available at this time.'**
  String get noNotificationsAvailable;

  /// No description provided for @newNotifications.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newNotifications;

  /// No description provided for @earlierNotifications.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlierNotifications;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification dismissed'**
  String get notificationDeleted;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} mins ago'**
  String minsAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(int count);

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @errorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error loading profile'**
  String get errorLoadingProfile;

  /// No description provided for @petDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted successfully'**
  String petDeletedSuccessfully(String name);

  /// No description provided for @errorDeletingPet.
  ///
  /// In en, this message translates to:
  /// **'Error deleting pet: {error}'**
  String errorDeletingPet(String error);

  /// No description provided for @errorWithValue.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithValue(String error);

  /// No description provided for @myChats.
  ///
  /// In en, this message translates to:
  /// **'My Chats'**
  String get myChats;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @errorLoadingChats.
  ///
  /// In en, this message translates to:
  /// **'Error loading chats'**
  String get errorLoadingChats;

  /// No description provided for @noActiveChats.
  ///
  /// In en, this message translates to:
  /// **'No active chats yet.'**
  String get noActiveChats;

  /// No description provided for @noPastChats.
  ///
  /// In en, this message translates to:
  /// **'No past chats yet.'**
  String get noPastChats;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// No description provided for @petLabel.
  ///
  /// In en, this message translates to:
  /// **'Pet: {petName}'**
  String petLabel(String petName);

  /// No description provided for @completeWalkSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Walk Session?'**
  String get completeWalkSessionTitle;

  /// No description provided for @emergencyCancelWalkTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency / Cancel Walk?'**
  String get emergencyCancelWalkTitle;

  /// No description provided for @completeWalkSessionMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to finish this session? This will finalize the walk and close the chat room.'**
  String get completeWalkSessionMessage;

  /// No description provided for @emergencyCancelWalkMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you reporting an emergency or cancelling the walk? This will end coordination immediately and close the chat.'**
  String get emergencyCancelWalkMessage;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @confirmAndEnd.
  ///
  /// In en, this message translates to:
  /// **'Confirm & End'**
  String get confirmAndEnd;

  /// No description provided for @sessionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Session Completed'**
  String get sessionCompleted;

  /// No description provided for @sessionEndedRefunded.
  ///
  /// In en, this message translates to:
  /// **'Session Ended & Refunded'**
  String get sessionEndedRefunded;

  /// No description provided for @sessionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Session Cancelled'**
  String get sessionCancelled;

  /// No description provided for @sessionClosed.
  ///
  /// In en, this message translates to:
  /// **'Session Closed'**
  String get sessionClosed;

  /// No description provided for @activeCoordination.
  ///
  /// In en, this message translates to:
  /// **'Active Coordination'**
  String get activeCoordination;

  /// No description provided for @errorLoadingMessages.
  ///
  /// In en, this message translates to:
  /// **'Error loading messages'**
  String get errorLoadingMessages;

  /// No description provided for @chatEnded.
  ///
  /// In en, this message translates to:
  /// **'This chat has ended. You can no longer send messages.'**
  String get chatEnded;

  /// No description provided for @completeWalk.
  ///
  /// In en, this message translates to:
  /// **'Complete Walk'**
  String get completeWalk;

  /// No description provided for @endEarly.
  ///
  /// In en, this message translates to:
  /// **'End Early'**
  String get endEarly;

  /// No description provided for @cancelWalk.
  ///
  /// In en, this message translates to:
  /// **'Cancel Walk'**
  String get cancelWalk;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// No description provided for @refundProcessed.
  ///
  /// In en, this message translates to:
  /// **'Refund Processed'**
  String get refundProcessed;

  /// No description provided for @refundNotification.
  ///
  /// In en, this message translates to:
  /// **'The walker ended the session unexpectedly. Your payment of {amount} has been refunded.'**
  String refundNotification(String amount);

  /// No description provided for @walkCompletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Walk completed successfully.'**
  String get walkCompletedSuccessfully;

  /// No description provided for @walkEndedEarly.
  ///
  /// In en, this message translates to:
  /// **'Walk ended early.'**
  String get walkEndedEarly;

  /// No description provided for @walkCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Walk Completed!'**
  String get walkCompletedTitle;

  /// No description provided for @walkEndedEarlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Walk Ended Early'**
  String get walkEndedEarlyTitle;

  /// No description provided for @closingReasonComplete.
  ///
  /// In en, this message translates to:
  /// **'Finished: Walk marked complete by {role} ({name})'**
  String closingReasonComplete(String role, String name);

  /// No description provided for @closingReasonCancelled.
  ///
  /// In en, this message translates to:
  /// **'Ended: {role} ({name}) requested to cancel/stop coordination'**
  String closingReasonCancelled(String role, String name);

  /// No description provided for @priceAmount.
  ///
  /// In en, this message translates to:
  /// **'\${amount}'**
  String priceAmount(String amount);

  /// No description provided for @chatStartedFor.
  ///
  /// In en, this message translates to:
  /// **'Chat started for {petName}'**
  String chatStartedFor(String petName);

  /// No description provided for @walkerWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'👋 {userName} has accepted the walk request for {petName}. You can now coordinate details here!'**
  String walkerWelcomeMessage(String userName, String petName);

  /// No description provided for @ownerWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'👋 {userName} has started a chat regarding {petName}\'s walk.'**
  String ownerWelcomeMessage(String userName, String petName);

  /// No description provided for @bookingManagement.
  ///
  /// In en, this message translates to:
  /// **'Booking Management'**
  String get bookingManagement;

  /// No description provided for @errorLoadingBookings.
  ///
  /// In en, this message translates to:
  /// **'Error loading bookings: {error}'**
  String errorLoadingBookings(String error);

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @noBookingsYet.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet.'**
  String get noBookingsYet;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @bookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetails;

  /// No description provided for @walkerWithName.
  ///
  /// In en, this message translates to:
  /// **'Walker: {walkerName}'**
  String walkerWithName(String walkerName);

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @disputeResolution.
  ///
  /// In en, this message translates to:
  /// **'Dispute Resolution'**
  String get disputeResolution;

  /// No description provided for @openDisputesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} open disputes'**
  String openDisputesCount(int count);

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @reportedAgainst.
  ///
  /// In en, this message translates to:
  /// **'{reportedBy} reported {against}'**
  String reportedAgainst(String reportedBy, String against);

  /// No description provided for @resolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get resolve;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @disputeResolved.
  ///
  /// In en, this message translates to:
  /// **'Dispute resolved.'**
  String get disputeResolved;

  /// No description provided for @disputeDismissed.
  ///
  /// In en, this message translates to:
  /// **'Dispute dismissed.'**
  String get disputeDismissed;

  /// No description provided for @platformOverview.
  ///
  /// In en, this message translates to:
  /// **'Platform overview'**
  String get platformOverview;

  /// No description provided for @platformStats.
  ///
  /// In en, this message translates to:
  /// **'Platform Stats'**
  String get platformStats;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// No description provided for @activeWalks.
  ///
  /// In en, this message translates to:
  /// **'Active Walks'**
  String get activeWalks;

  /// No description provided for @totalBookings.
  ///
  /// In en, this message translates to:
  /// **'Total Bookings'**
  String get totalBookings;

  /// No description provided for @pendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'Pending Approvals'**
  String get pendingApprovals;

  /// No description provided for @sendAnnouncementTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Announcement'**
  String get sendAnnouncementTitle;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @fillTitleAndMessage.
  ///
  /// In en, this message translates to:
  /// **'Please fill in both title and message.'**
  String get fillTitleAndMessage;

  /// No description provided for @currentBuild.
  ///
  /// In en, this message translates to:
  /// **'Current build'**
  String get currentBuild;

  /// No description provided for @appLockedDescription.
  ///
  /// In en, this message translates to:
  /// **'App is currently locked for users'**
  String get appLockedDescription;

  /// No description provided for @appLiveDescription.
  ///
  /// In en, this message translates to:
  /// **'App is live and accessible'**
  String get appLiveDescription;

  /// No description provided for @supportEmailDescription.
  ///
  /// In en, this message translates to:
  /// **'Support address shown to users'**
  String get supportEmailDescription;

  /// No description provided for @totalUsersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} total users'**
  String totalUsersCount(int count);

  /// No description provided for @searchUsersHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email...'**
  String get searchUsersHint;

  /// No description provided for @userApproved.
  ///
  /// In en, this message translates to:
  /// **'{name} approved!'**
  String userApproved(String name);

  /// No description provided for @userSuspended.
  ///
  /// In en, this message translates to:
  /// **'{name} suspended.'**
  String userSuspended(String name);

  /// No description provided for @userRestored.
  ///
  /// In en, this message translates to:
  /// **'{name} restored.'**
  String userRestored(String name);

  /// No description provided for @errorLoadingUsers.
  ///
  /// In en, this message translates to:
  /// **'Error loading users: {error}'**
  String errorLoadingUsers(String error);

  /// No description provided for @errorLoadingReviews.
  ///
  /// In en, this message translates to:
  /// **'Error loading reviews: {error}'**
  String errorLoadingReviews(String error);

  /// No description provided for @errorLoadingPets.
  ///
  /// In en, this message translates to:
  /// **'Error loading pets: {error}'**
  String errorLoadingPets(String error);

  /// No description provided for @errorLoadingAddresses.
  ///
  /// In en, this message translates to:
  /// **'Error loading addresses: {error}'**
  String errorLoadingAddresses(String error);

  /// No description provided for @mySchedule.
  ///
  /// In en, this message translates to:
  /// **'My Schedule'**
  String get mySchedule;

  /// No description provided for @viewNotifications.
  ///
  /// In en, this message translates to:
  /// **'View Notifications'**
  String get viewNotifications;

  /// No description provided for @viewChat.
  ///
  /// In en, this message translates to:
  /// **'View Chat'**
  String get viewChat;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @hourlyRateValue.
  ///
  /// In en, this message translates to:
  /// **'\${rate}/hr'**
  String hourlyRateValue(String rate);

  /// Error message shown when a booking fails
  ///
  /// In en, this message translates to:
  /// **'Error creating booking: {error}'**
  String errorCreatingBooking(String error);

  /// No description provided for @newWalkerRegistered.
  ///
  /// In en, this message translates to:
  /// **'New walker registered'**
  String get newWalkerRegistered;

  /// No description provided for @bookingCompleted.
  ///
  /// In en, this message translates to:
  /// **'Booking completed'**
  String get bookingCompleted;

  /// No description provided for @disputeReportedBy.
  ///
  /// In en, this message translates to:
  /// **'Dispute reported by'**
  String get disputeReportedBy;

  /// No description provided for @walkerApproved.
  ///
  /// In en, this message translates to:
  /// **'Walker approved'**
  String get walkerApproved;

  /// No description provided for @newOwnerRegistered.
  ///
  /// In en, this message translates to:
  /// **'New owner registered'**
  String get newOwnerRegistered;

  /// No description provided for @searchByNameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email...'**
  String get searchByNameOrEmail;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found matching your search.'**
  String get noUsersFound;

  /// No description provided for @reported.
  ///
  /// In en, this message translates to:
  /// **'reported'**
  String get reported;

  /// No description provided for @resolveDispute.
  ///
  /// In en, this message translates to:
  /// **'Resolve Dispute'**
  String get resolveDispute;

  /// No description provided for @bookingsManagement.
  ///
  /// In en, this message translates to:
  /// **'Bookings Management'**
  String get bookingsManagement;
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
