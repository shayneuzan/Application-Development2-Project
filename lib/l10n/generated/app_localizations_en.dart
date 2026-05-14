// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get searchHint => 'Search for walkers nearby';

  @override
  String get walkersNearby => 'Walkers Nearby';

  @override
  String get discoverWalkers => 'Discover active walkers ready to help';

  @override
  String get viewList => 'View List';

  @override
  String get home => 'Home';

  @override
  String get walkers => 'Walkers';

  @override
  String get bookings => 'Bookings';

  @override
  String get map => 'Map';

  @override
  String get profile => 'Profile';

  @override
  String welcomeBack(String userName) {
    return 'Welcome back, $userName!';
  }

  @override
  String get furryFriendWaiting => 'Your furry friend is waiting for a walk';

  @override
  String get latestBooking => 'Latest Booking';

  @override
  String withPet(String petName) {
    return 'with $petName';
  }

  @override
  String get browseWalkers => 'Browse Walkers';

  @override
  String get myBookings => 'My Bookings';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get noRecentActivity => 'No recent activity';

  @override
  String petWalk(String petName) {
    return '$petName walk';
  }

  @override
  String byWalker(String walkerName) {
    return 'by $walkerName';
  }

  @override
  String get favoriteWalkers => 'Favorite Walkers';

  @override
  String get findWalkers => 'Find Walkers';

  @override
  String countWalkersNearby(int count) {
    return '$count walkers nearby';
  }

  @override
  String get availableWalkers => 'Available Walkers';

  @override
  String get showAll => 'Show All';

  @override
  String get showFavorites => 'Show Favorites';

  @override
  String get noFavoritesYet => 'No favorites yet!';

  @override
  String get noWalkersAvailable => 'No walkers available.';

  @override
  String walksCompletedCount(int count) {
    return '$count walks completed';
  }

  @override
  String get bookNow => 'Book Now';

  @override
  String get professionalWalker => 'Professional Dog Walker';

  @override
  String get rating => 'Rating';

  @override
  String get walks => 'Walks';

  @override
  String get experience => 'Experience';

  @override
  String yearsCount(int count) {
    return '$count years';
  }

  @override
  String get about => 'About';

  @override
  String get reviews => 'Reviews';

  @override
  String get servicesIncluded => 'Services Included';

  @override
  String get recentReviews => 'Recent Reviews';

  @override
  String get seeAll => 'See All';

  @override
  String get noReviewsYet => 'No reviews yet.';

  @override
  String get selectPet => 'Select Pet';

  @override
  String get walkDuration => 'Walk Duration';

  @override
  String get baseRate => 'Base Rate';

  @override
  String get duration => 'Duration';

  @override
  String get totalPrice => 'Total Price';

  @override
  String get selectDateTime => 'Select Date & Time';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String get pleaseLogin => 'Please log in';

  @override
  String get availableTimeSlots => 'Available Time Slots';

  @override
  String get pet => 'Pet';

  @override
  String get date => 'Date';

  @override
  String get bookingSuccessful => 'Booking Successful!';

  @override
  String walkRequested(String walkerName) {
    return 'Your walk with $walkerName has been requested.';
  }

  @override
  String get backToHome => 'Back to Home';

  @override
  String durationMinutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get settings => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get savedAddresses => 'Saved Addresses';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get emailUpdates => 'Email Updates';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get support => 'Support';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get aboutPawWalk => 'About PawWalk';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get logOut => 'Log Out';

  @override
  String get version => 'Version';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmLogOut => 'Are you sure you want to log out?';

  @override
  String get deleteAccountConfirmation =>
      'This action is permanent and cannot be undone. All your data, including saved addresses and payment methods, will be deleted.';

  @override
  String get accountDeleted => 'Account successfully deleted';

  @override
  String get delete => 'Delete';

  @override
  String get english => 'English (US)';

  @override
  String get french => 'French (FR)';

  @override
  String get addPet => 'Add Pet';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get totalWalks => 'Total Walks';

  @override
  String get pets => 'Pets';

  @override
  String get favorites => 'Favorites';

  @override
  String get myPets => 'My Pets';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get addNewPet => 'Add New Pet';

  @override
  String get noPetsFound => 'No pets found. Add your first pet above!';

  @override
  String get deletePet => 'Delete Pet';

  @override
  String deletePetConfirmation(String petName) {
    return 'Are you sure you want to delete $petName?';
  }

  @override
  String get specialInstructions => 'Special instructions';

  @override
  String yearsOld(int count) {
    return '$count years old';
  }

  @override
  String get notLoggedIn => 'Not Logged In';

  @override
  String get loading => 'Loading...';

  @override
  String get trackWalk => 'Track Walk';

  @override
  String get bookAWalk => 'Book a Walk';

  @override
  String get cancelBooking => 'Cancel Booking';

  @override
  String get cancelBookingConfirmation =>
      'Are you sure you want to cancel this booking? This action cannot be undone.';

  @override
  String get noKeepIt => 'No, Keep It';

  @override
  String get yesCancel => 'Yes, Cancel';

  @override
  String get cancellationFeatureSoon => 'Cancellation feature coming soon';

  @override
  String upcomingCount(int count) {
    return 'Upcoming ($count)';
  }

  @override
  String pastCount(int count) {
    return 'Past ($count)';
  }

  @override
  String get noUpcomingWalks => 'No upcoming walks scheduled.';

  @override
  String get noPastWalks => 'No past walks yet.';

  @override
  String get rebook => 'Re-book';

  @override
  String get edit => 'Edit';

  @override
  String get review => 'Review';
}
