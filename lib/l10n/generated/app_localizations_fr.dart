// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get searchHint => 'Rechercher des promeneurs à proximité';

  @override
  String get walkersNearby => 'Promeneurs à proximité';

  @override
  String get discoverWalkers => 'Découvrez des promeneurs actifs prêts à aider';

  @override
  String get viewList => 'Voir la liste';

  @override
  String get home => 'Accueil';

  @override
  String get walkers => 'Promeneurs';

  @override
  String get bookings => 'Réservations';

  @override
  String get map => 'Carte';

  @override
  String get profile => 'Profil';

  @override
  String welcomeBack(String userName) {
    return 'Bon retour, $userName !';
  }

  @override
  String get furryFriendWaiting => 'Votre compagnon attend sa promenade';

  @override
  String get latestBooking => 'Dernière réservation';

  @override
  String withPet(String petName) {
    return 'avec $petName';
  }

  @override
  String get browseWalkers => 'Parcourir les promeneurs';

  @override
  String get myBookings => 'Mes réservations';

  @override
  String get recentActivity => 'Activité récente';

  @override
  String get noRecentActivity => 'Aucune activité récente';

  @override
  String petWalk(String petName) {
    return 'Promenade de $petName';
  }

  @override
  String byWalker(String walkerName) {
    return 'par $walkerName';
  }

  @override
  String get favoriteWalkers => 'Promeneurs favoris';

  @override
  String get findWalkers => 'Trouver des promeneurs';

  @override
  String countWalkersNearby(int count) {
    return '$count promeneurs à proximité';
  }

  @override
  String get availableWalkers => 'Promeneurs disponibles';

  @override
  String get showAll => 'Tout afficher';

  @override
  String get showFavorites => 'Afficher favoris';

  @override
  String get noFavoritesYet => 'Pas encore de favoris !';

  @override
  String get noWalkersAvailable => 'Aucun promeneur disponible.';

  @override
  String walksCompletedCount(int count) {
    return '$count promenades effectuées';
  }

  @override
  String get bookNow => 'Réserver';

  @override
  String get professionalWalker => 'Promeneur de chiens professionnel';

  @override
  String get rating => 'Évaluation';

  @override
  String get walks => 'Promenades';

  @override
  String get experience => 'Expérience';

  @override
  String yearsCount(int count) {
    return '$count ans';
  }

  @override
  String get about => 'À propos';

  @override
  String get reviews => 'Avis';

  @override
  String get servicesIncluded => 'Services inclus';

  @override
  String get recentReviews => 'Avis récents';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get noReviewsYet => 'Pas encore d\'avis.';

  @override
  String get selectPet => 'Sélectionner un animal';

  @override
  String get walkDuration => 'Durée de la promenade';

  @override
  String get baseRate => 'Tarif de base';

  @override
  String get duration => 'Durée';

  @override
  String get totalPrice => 'Prix total';

  @override
  String get selectDateTime => 'Choisir date et heure';

  @override
  String get confirmBooking => 'Confirmer la réservation';

  @override
  String get pleaseLogin => 'Veuillez vous connecter';

  @override
  String get availableTimeSlots => 'Créneaux horaires disponibles';

  @override
  String get pet => 'Animal';

  @override
  String get date => 'Date';

  @override
  String get bookingSuccessful => 'Réservation réussie !';

  @override
  String walkRequested(String walkerName) {
    return 'Votre promenade avec $walkerName a été demandée.';
  }

  @override
  String get backToHome => 'Retour à l\'accueil';

  @override
  String durationMinutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get settings => 'Paramètres';

  @override
  String get account => 'Compte';

  @override
  String get paymentMethods => 'Modes de paiement';

  @override
  String get savedAddresses => 'Adresses enregistrées';

  @override
  String get language => 'Langue';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Notifications push';

  @override
  String get emailUpdates => 'Mises à jour par e-mail';

  @override
  String get appearance => 'Apparence';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get support => 'Assistance';

  @override
  String get helpCenter => 'Centre d\'aide';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get aboutPawWalk => 'À propos de PawWalk';

  @override
  String get dangerZone => 'Zone de danger';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get logOut => 'Déconnexion';

  @override
  String get version => 'Version';

  @override
  String get selectLanguage => 'Choisir la langue';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirmLogOut => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get deleteAccountConfirmation =>
      'Cette action est permanente et ne peut être annulée. Toutes vos données seront supprimées.';

  @override
  String get accountDeleted => 'Compte supprimé avec succès';

  @override
  String get delete => 'Supprimer';

  @override
  String get english => 'Anglais (US)';

  @override
  String get french => 'Français (FR)';

  @override
  String get addPet => 'Ajouter un animal';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get totalWalks => 'Total des promenades';

  @override
  String get pets => 'Animaux';

  @override
  String get favorites => 'Favoris';

  @override
  String get myPets => 'Mes animaux';

  @override
  String get privacySecurity => 'Confidentialité et sécurité';

  @override
  String get contactSupport => 'Contacter le support';

  @override
  String get addNewPet => 'Ajouter un nouvel animal';

  @override
  String get noPetsFound =>
      'Aucun animal trouvé. Ajoutez votre premier animal ci-dessus !';

  @override
  String get deletePet => 'Supprimer l\'animal';

  @override
  String deletePetConfirmation(String petName) {
    return 'Êtes-vous sûr de vouloir supprimer $petName ?';
  }

  @override
  String get specialInstructions => 'Instructions spéciales';

  @override
  String yearsOld(int count) {
    return '$count ans';
  }

  @override
  String get notLoggedIn => 'Non connecté';

  @override
  String get loading => 'Chargement...';

  @override
  String get trackWalk => 'Suivre la promenade';

  @override
  String get bookAWalk => 'Réserver une promenade';

  @override
  String get cancelBooking => 'Annuler la réservation';

  @override
  String get cancelBookingConfirmation =>
      'Êtes-vous sûr de vouloir annuler cette réservation ? Cette action est irréversible.';

  @override
  String get noKeepIt => 'Non, la garder';

  @override
  String get yesCancel => 'Oui, annuler';

  @override
  String get cancellationFeatureSoon =>
      'La fonction d\'annulation sera bientôt disponible';

  @override
  String upcomingCount(int count) {
    return 'À venir ($count)';
  }

  @override
  String pastCount(int count) {
    return 'Passées ($count)';
  }

  @override
  String get noUpcomingWalks => 'Aucune promenade prévue.';

  @override
  String get noPastWalks => 'Aucune promenade passée pour le moment.';

  @override
  String get rebook => 'Réserver à nouveau';

  @override
  String get edit => 'Modifier';

  @override
  String get review => 'Avis';
}
