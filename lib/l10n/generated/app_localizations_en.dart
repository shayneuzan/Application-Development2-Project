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
  String get bookingCancelled => 'Booking cancelled successfully';

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

  @override
  String get dashboard => 'Dashboard';

  @override
  String get users => 'Users';

  @override
  String get disputes => 'Disputes';

  @override
  String get more => 'More';

  @override
  String get userManagement => 'User Management';

  @override
  String get approve => 'Approve';

  @override
  String get suspend => 'Suspend';

  @override
  String get restore => 'Restore';

  @override
  String get sendAnnouncement => 'Send Announcement';

  @override
  String get platformSettings => 'Platform Settings';

  @override
  String get viewReports => 'View Reports';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get administrator => 'Administrator';

  @override
  String get admin => 'Admin';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get signOut => 'Sign Out';

  @override
  String get general => 'General';

  @override
  String get appVersion => 'App Version';

  @override
  String get system => 'System';

  @override
  String get maintenanceMode => 'Maintenance Mode';

  @override
  String get contactEmail => 'Contact Email';

  @override
  String get saveEmail => 'Save Email';

  @override
  String get walker => 'Walker';

  @override
  String get owner => 'Owner';

  @override
  String get earnings => 'Earnings';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get weeklyOverview => 'Weekly Overview';

  @override
  String get recentWalks => 'Recent Completed Walks';

  @override
  String get bookingRequests => 'Booking Requests';

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String get requestDeclined => 'Request Declined';

  @override
  String requestDeclinedMessage(String walkerName, String petName) {
    return '$walkerName declined your walk request for $petName.';
  }

  @override
  String requestDeclinedWalkerMessage(String petName, String ownerName) {
    return 'You have declined the walk request for $petName from $ownerName.';
  }

  @override
  String requestDeclinedSnackBar(String petName, String ownerName) {
    return 'Request Declined! Pet: $petName\nOwner: $ownerName';
  }

  @override
  String get walkRequestAccepted => 'Walk Request Accepted!';

  @override
  String walkRequestAcceptedMessage(String walkerName, String petName) {
    return '$walkerName is ready to walk $petName! Go to \"Messages\" in your drawer to coordinate details.';
  }

  @override
  String walkRequestAcceptedWalkerMessage(String petName, String ownerName) {
    return 'You have accepted the walk request for $petName. Open \"View Chat\" to discuss location with $ownerName.';
  }

  @override
  String requestAcceptedSnackBar(String petName, String ownerName) {
    return 'Request Accepted! Pet: $petName\nOwner: $ownerName';
  }

  @override
  String get accountPendingApproval =>
      'Your account is pending admin approval. You cannot accept bookings yet.';

  @override
  String helloUser(String userName) {
    return 'Hello, $userName!';
  }

  @override
  String get activityOverview => 'Here\'s your activity overview';

  @override
  String get todaysEarnings => 'Today\'s Earnings';

  @override
  String get viewAllEarnings => 'View All Earnings';

  @override
  String get upcomingWalks => 'Upcoming Walks';

  @override
  String ownerWithName(String ownerName) {
    return 'Owner: $ownerName';
  }

  @override
  String get newRequests => 'New Requests';

  @override
  String get noUpcomingRequests => 'No Upcoming Requests';

  @override
  String petDurationWalk(String petName, int duration) {
    return '$petName - $duration min walk';
  }

  @override
  String get yourSchedule => 'Your Schedule';

  @override
  String get selectDateToSeeWalks => 'Select a date to see walks';

  @override
  String upcomingWalksForDate(String date) {
    return 'Your Upcoming Walks for $date';
  }

  @override
  String get noWalksScheduledDay => 'No walks scheduled for this day';

  @override
  String noWalksScheduledDate(String date) {
    return 'No walks scheduled on $date';
  }

  @override
  String get fullName => 'Full Name';

  @override
  String get enterNameHint => 'Enter your name';

  @override
  String get fullBio => 'Full Bio';

  @override
  String get bioHint => 'Tell us about you';

  @override
  String get hourlyRate => 'Hourly Rate';

  @override
  String get yearsExperience => 'Years of Experience';

  @override
  String get yearsExperienceHint => 'Years of Experience';

  @override
  String get saveChanges => 'SAVE CHANGES';

  @override
  String get pleaseFillAllFields => 'Please fill all fields.';

  @override
  String get hourlyRateError => 'Hourly rate must be greater than 0 \$.';

  @override
  String get profileUpdated => 'Profile updated!';

  @override
  String get pleaseLogInToAddPet => 'Please log in to add a pet';

  @override
  String get petAddedSuccessfully => 'Pet added successfully!';

  @override
  String errorAddingPet(String error) {
    return 'Error adding pet: $error';
  }

  @override
  String get petName => 'Pet Name';

  @override
  String get nameHint => 'e.g. Max';

  @override
  String get enterPetName => 'Please enter pet name';

  @override
  String get breed => 'Breed';

  @override
  String get breedHint => 'e.g. Golden Retriever';

  @override
  String get enterBreed => 'Please enter breed';

  @override
  String get petAge => 'Pet Age';

  @override
  String get ageHint => 'e.g. 3';

  @override
  String get enterAge => 'Please enter pet age';

  @override
  String get petSize => 'Pet Size';

  @override
  String get small => 'Small';

  @override
  String get medium => 'Medium';

  @override
  String get large => 'Large';

  @override
  String get enterSpecialInstructions => 'e.g. Friendly with other dogs';

  @override
  String get savePet => 'SAVE PET';

  @override
  String get noAddressesFound => 'No addresses found';

  @override
  String setAsDefaultSuccess(String label) {
    return '$label set as default address';
  }

  @override
  String get verifyAddressError =>
      'Could not verify address. Please check your entry.';

  @override
  String get defaultTag => 'DEFAULT';

  @override
  String get addressFallback => 'Address';

  @override
  String get setAsDefault => 'Set as default';

  @override
  String get editAddress => 'Edit address';

  @override
  String get remove => 'Remove';

  @override
  String get yourLocation => 'Your Location';

  @override
  String get noSavedAddresses => 'No saved addresses';

  @override
  String get addNewAddress => 'Add New Address';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get searchAddressHint => 'Search for an address...';

  @override
  String get addressLabel => 'Address Label';

  @override
  String get addressExample => 'e.g. Home, Work';

  @override
  String get manualEntryDetails => 'Manual Entry Details';

  @override
  String get streetAddress => 'Street Address';

  @override
  String get city => 'City';

  @override
  String get postalCode => 'Postal Code';

  @override
  String get verifyAndSaveAddress => 'VERIFY AND SAVE ADDRESS';

  @override
  String reviewsFor(String name) {
    return 'Reviews for $name';
  }

  @override
  String get error => 'Error';

  @override
  String get recent => 'Recent';

  @override
  String get user => 'User';

  @override
  String get nameCardLabel => 'Full Name';

  @override
  String get nameCardHint => 'Enter your name';

  @override
  String get bioCardLabel => 'Full Bio';

  @override
  String get bioCardHint => 'Tell us about you';

  @override
  String get hourlyRateCardLabel => 'Hourly Rate';

  @override
  String get hourlyRateCardSuffix => '/ hr';

  @override
  String get yearsCardLabel => 'Years of Experience';

  @override
  String get yearsCardHint => 'e.g. 5';

  @override
  String get fillAllFields => 'Please fill all fields.';

  @override
  String get hourlyRateZero => 'Hourly rate must be greater than 0.';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get noCards => 'No cards saved';

  @override
  String get enterAddress => 'Enter address';

  @override
  String get rescheduleBooking => 'Reschedule Booking';

  @override
  String get pleaseEnterAllFields => 'Please enter all fields';

  @override
  String get addressUpdatedSuccessfully => 'Address updated successfully!';

  @override
  String get petUpdatedSuccessfully => 'Pet updated successfully!';

  @override
  String get editPet => 'Edit Pet';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get ageYears => 'Age (Years)';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully!';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

  @override
  String get address => 'Address';

  @override
  String get appName => 'PawWalk';

  @override
  String get enterValidCardDetails => 'Please enter valid card details';

  @override
  String get otherMethods => 'Other Methods';

  @override
  String get thankYouForReview => 'Thank you for your review!';

  @override
  String get writeReview => 'Write a Review';

  @override
  String howWasWalk(String walkerName) {
    return 'How was the walk with $walkerName?';
  }

  @override
  String forYourDog(String dogName) {
    return 'for your dog, $dogName';
  }

  @override
  String get tellUsMoreAbout => 'Tell us more about the walk';

  @override
  String get describeWalk => 'Describe your experience (optional)';

  @override
  String get submitReview => 'Submit Review';

  @override
  String get selectDateAndTime => 'Select Date & Time';

  @override
  String get pleaseLoginToBookWalk => 'Please log in to book a walk';

  @override
  String get years => 'years';

  @override
  String get changesSaved => 'Changes saved!';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get clearAll => 'Clear all';

  @override
  String get errorLoadingNotifications => 'Error loading notifications.';

  @override
  String get noNotificationsAvailable =>
      'No notifications available at this time.';

  @override
  String get newNotifications => 'New';

  @override
  String get earlierNotifications => 'Earlier';

  @override
  String get notificationDeleted => 'Notification dismissed';

  @override
  String get justNow => 'Just now';

  @override
  String minsAgo(int count) {
    return '$count mins ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get errorLoadingProfile => 'Error loading profile';

  @override
  String petDeletedSuccessfully(String name) {
    return '$name deleted successfully';
  }

  @override
  String errorDeletingPet(String error) {
    return 'Error deleting pet: $error';
  }

  @override
  String errorWithValue(String error) {
    return 'Error: $error';
  }

  @override
  String get myChats => 'My Chats';

  @override
  String get active => 'Active';

  @override
  String get past => 'Past';

  @override
  String get errorLoadingChats => 'Error loading chats';

  @override
  String get noActiveChats => 'No active chats yet.';

  @override
  String get noPastChats => 'No past chats yet.';

  @override
  String get unknownUser => 'Unknown User';

  @override
  String petLabel(String petName) {
    return 'Pet: $petName';
  }

  @override
  String get completeWalkSessionTitle => 'Complete Walk Session?';

  @override
  String get emergencyCancelWalkTitle => 'Emergency / Cancel Walk?';

  @override
  String get completeWalkSessionMessage =>
      'Are you sure you want to finish this session? This will finalize the walk and close the chat room.';

  @override
  String get emergencyCancelWalkMessage =>
      'Are you reporting an emergency or cancelling the walk? This will end coordination immediately and close the chat.';

  @override
  String get goBack => 'Go Back';

  @override
  String get confirmAndEnd => 'Confirm & End';

  @override
  String get sessionCompleted => 'Session Completed';

  @override
  String get sessionEndedRefunded => 'Session Ended & Refunded';

  @override
  String get sessionCancelled => 'Session Cancelled';

  @override
  String get sessionClosed => 'Session Closed';

  @override
  String get activeCoordination => 'Active Coordination';

  @override
  String get errorLoadingMessages => 'Error loading messages';

  @override
  String get chatEnded =>
      'This chat has ended. You can no longer send messages.';

  @override
  String get completeWalk => 'Complete Walk';

  @override
  String get endEarly => 'End Early';

  @override
  String get cancelWalk => 'Cancel Walk';

  @override
  String get typeAMessage => 'Type a message...';

  @override
  String get refundProcessed => 'Refund Processed';

  @override
  String refundNotification(String amount) {
    return 'The walker ended the session unexpectedly. Your payment of $amount has been refunded.';
  }

  @override
  String get walkCompletedSuccessfully => 'Walk completed successfully.';

  @override
  String get walkEndedEarly => 'Walk ended early.';

  @override
  String get walkCompletedTitle => 'Walk Completed!';

  @override
  String get walkEndedEarlyTitle => 'Walk Ended Early';

  @override
  String closingReasonComplete(String role, String name) {
    return 'Finished: Walk marked complete by $role ($name)';
  }

  @override
  String closingReasonCancelled(String role, String name) {
    return 'Ended: $role ($name) requested to cancel/stop coordination';
  }

  @override
  String priceAmount(String amount) {
    return '\$$amount';
  }

  @override
  String chatStartedFor(String petName) {
    return 'Chat started for $petName';
  }

  @override
  String walkerWelcomeMessage(String userName, String petName) {
    return '👋 $userName has accepted the walk request for $petName. You can now coordinate details here!';
  }

  @override
  String ownerWelcomeMessage(String userName, String petName) {
    return '👋 $userName has started a chat regarding $petName\'s walk.';
  }

  @override
  String get bookingManagement => 'Booking Management';

  @override
  String errorLoadingBookings(String error) {
    return 'Error loading bookings: $error';
  }

  @override
  String get total => 'Total';

  @override
  String get pending => 'Pending';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get completed => 'Completed';

  @override
  String get noBookingsYet => 'No bookings yet.';

  @override
  String get viewDetails => 'View Details';

  @override
  String get bookingDetails => 'Booking Details';

  @override
  String walkerWithName(String walkerName) {
    return 'Walker: $walkerName';
  }

  @override
  String get time => 'Time';

  @override
  String get disputeResolution => 'Dispute Resolution';

  @override
  String openDisputesCount(int count) {
    return '$count open disputes';
  }

  @override
  String get open => 'Open';

  @override
  String get resolved => 'Resolved';

  @override
  String reportedAgainst(String reportedBy, String against) {
    return '$reportedBy reported $against';
  }

  @override
  String get resolve => 'Resolve';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get disputeResolved => 'Dispute resolved.';

  @override
  String get disputeDismissed => 'Dispute dismissed.';

  @override
  String get platformOverview => 'Platform overview';

  @override
  String get platformStats => 'Platform Stats';

  @override
  String get totalUsers => 'Total Users';

  @override
  String get activeWalks => 'Active Walks';

  @override
  String get totalBookings => 'Total Bookings';

  @override
  String get pendingApprovals => 'Pending Approvals';

  @override
  String get sendAnnouncementTitle => 'Send Announcement';

  @override
  String get title => 'Title';

  @override
  String get message => 'Message';

  @override
  String get fillTitleAndMessage => 'Please fill in both title and message.';

  @override
  String get currentBuild => 'Current build';

  @override
  String get appLockedDescription => 'App is currently locked for users';

  @override
  String get appLiveDescription => 'App is live and accessible';

  @override
  String get supportEmailDescription => 'Support address shown to users';

  @override
  String totalUsersCount(int count) {
    return '$count total users';
  }

  @override
  String get searchUsersHint => 'Search by name or email...';

  @override
  String userApproved(String name) {
    return '$name approved!';
  }

  @override
  String userSuspended(String name) {
    return '$name suspended.';
  }

  @override
  String userRestored(String name) {
    return '$name restored.';
  }

  @override
  String errorLoadingUsers(String error) {
    return 'Error loading users: $error';
  }

  @override
  String errorLoadingReviews(String error) {
    return 'Error loading reviews: $error';
  }

  @override
  String errorLoadingPets(String error) {
    return 'Error loading pets: $error';
  }

  @override
  String errorLoadingAddresses(String error) {
    return 'Error loading addresses: $error';
  }

  @override
  String get mySchedule => 'My Schedule';

  @override
  String get viewNotifications => 'View Notifications';

  @override
  String get viewChat => 'View Chat';

  @override
  String get requests => 'Requests';

  @override
  String get schedule => 'Schedule';

  @override
  String hourlyRateValue(String rate) {
    return '\$$rate/hr';
  }

  @override
  String errorCreatingBooking(String error) {
    return 'Error creating booking: $error';
  }

  @override
  String get newWalkerRegistered => 'New walker registered';

  @override
  String get bookingCompleted => 'Booking completed';

  @override
  String get disputeReportedBy => 'Dispute reported by';

  @override
  String get walkerApproved => 'Walker approved';

  @override
  String get newOwnerRegistered => 'New owner registered';

  @override
  String get searchByNameOrEmail => 'Search by name or email...';

  @override
  String get noUsersFound => 'No users found matching your search.';

  @override
  String get reported => 'reported';

  @override
  String get resolveDispute => 'Resolve Dispute';

  @override
  String get bookingsManagement => 'Bookings Management';
}
