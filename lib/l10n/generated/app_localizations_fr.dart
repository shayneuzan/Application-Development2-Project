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
  String get totalWalks => 'Nb. Promenades';

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
  String get bookingCancelled => 'Réservation annulée avec succès';

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

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get users => 'Utilisateurs';

  @override
  String get disputes => 'Litiges';

  @override
  String get more => 'Plus';

  @override
  String get userManagement => 'Gestion des utilisateurs';

  @override
  String get approve => 'Approuver';

  @override
  String get suspend => 'Suspendre';

  @override
  String get restore => 'Restaurer';

  @override
  String get sendAnnouncement => 'Envoyer une annonce';

  @override
  String get platformSettings => 'Paramètres de la plateforme';

  @override
  String get viewReports => 'Voir les rapports';

  @override
  String get helpAndSupport => 'Aide et support';

  @override
  String get administrator => 'Administrateur';

  @override
  String get admin => 'Admin';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get general => 'Général';

  @override
  String get appVersion => 'Version de l\'application';

  @override
  String get system => 'Système';

  @override
  String get maintenanceMode => 'Mode maintenance';

  @override
  String get contactEmail => 'E-mail de contact';

  @override
  String get saveEmail => 'Enregistrer l\'e-mail';

  @override
  String get walker => 'Promeneur';

  @override
  String get owner => 'Propriétaire';

  @override
  String get earnings => 'Revenus';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get thisMonth => 'Ce mois-ci';

  @override
  String get weeklyOverview => 'Aperçu hebdomadaire';

  @override
  String get recentWalks => 'Promenades terminées récemment';

  @override
  String get bookingRequests => 'Demandes de réservation';

  @override
  String get decline => 'Décliner';

  @override
  String get accept => 'Accepter';

  @override
  String get requestDeclined => 'Demande déclinée';

  @override
  String requestDeclinedMessage(String walkerName, String petName) {
    return '$walkerName a décliné votre demande de promenade pour $petName.';
  }

  @override
  String requestDeclinedWalkerMessage(String petName, String ownerName) {
    return 'Vous avez décliné la demande de promenade pour $petName de $ownerName.';
  }

  @override
  String requestDeclinedSnackBar(String petName, String ownerName) {
    return 'Demande déclinée ! Animal : $petName\nPropriétaire : $ownerName';
  }

  @override
  String get walkRequestAccepted => 'Demande de promenade acceptée !';

  @override
  String walkRequestAcceptedMessage(String walkerName, String petName) {
    return '$walkerName est prêt à promener $petName ! Allez dans « Messages » pour coordonner les détails.';
  }

  @override
  String walkRequestAcceptedWalkerMessage(String petName, String ownerName) {
    return 'Vous avez accepté la demande de promenade pour $petName. Ouvrez le chat pour discuter du lieu avec $ownerName.';
  }

  @override
  String requestAcceptedSnackBar(String petName, String ownerName) {
    return 'Demande acceptée ! Animal : $petName\nPropriétaire : $ownerName';
  }

  @override
  String get accountPendingApproval =>
      'Votre compte est en attente d\'approbation. Vous ne pouvez pas encore accepter de réservations.';

  @override
  String helloUser(String userName) {
    return 'Bonjour, $userName !';
  }

  @override
  String get activityOverview => 'Voici l\'aperçu de votre activité';

  @override
  String get todaysEarnings => 'Revenus d\'aujourd\'hui';

  @override
  String get viewAllEarnings => 'Voir tous les revenus';

  @override
  String get upcomingWalks => 'Promenades à venir';

  @override
  String ownerWithName(String ownerName) {
    return 'Propriétaire : $ownerName';
  }

  @override
  String get newRequests => 'Nouvelles demandes';

  @override
  String get noUpcomingRequests => 'Aucune demande à venir';

  @override
  String petDurationWalk(String petName, int duration) {
    return '$petName - $duration min de promenade';
  }

  @override
  String get yourSchedule => 'Votre emploi du temps';

  @override
  String get selectDateToSeeWalks =>
      'Sélectionnez une date pour voir les promenades';

  @override
  String upcomingWalksForDate(String date) {
    return 'Vos prochaines promenades pour le $date';
  }

  @override
  String get noWalksScheduledDay =>
      'Aucune promenade prévue pour cette journée';

  @override
  String noWalksScheduledDate(String date) {
    return 'Aucune promenade prévue le $date';
  }

  @override
  String get fullName => 'Nom complet';

  @override
  String get enterNameHint => 'Entrez votre nom';

  @override
  String get fullBio => 'Biographie complète';

  @override
  String get bioHint => 'Parlez-nous de vous';

  @override
  String get hourlyRate => 'Tarif horaire';

  @override
  String get yearsExperience => 'Années d\'expérience';

  @override
  String get yearsExperienceHint => 'Années d\'expérience';

  @override
  String get saveChanges => 'ENREGISTRER LES MODIFICATIONS';

  @override
  String get pleaseFillAllFields => 'Veuillez remplir tous les champs.';

  @override
  String get hourlyRateError => 'Le tarif horaire doit être supérieur à 0 \$.';

  @override
  String get profileUpdated => 'Profil mis à jour !';

  @override
  String get pleaseLogInToAddPet =>
      'Veuillez vous connecter pour ajouter un animal';

  @override
  String get petAddedSuccessfully => 'Animal ajouté avec succès !';

  @override
  String errorAddingPet(String error) {
    return 'Erreur lors de l\'ajout de l\'animal : $error';
  }

  @override
  String get petName => 'Nom de l\'animal';

  @override
  String get nameHint => 'ex : Max';

  @override
  String get enterPetName => 'Veuillez entrer le nom de l\'animal';

  @override
  String get breed => 'Race';

  @override
  String get breedHint => 'ex : Golden Retriever';

  @override
  String get enterBreed => 'Veuillez entrer la race';

  @override
  String get petAge => 'Âge de l\'animal';

  @override
  String get ageHint => 'ex : 3';

  @override
  String get enterAge => 'Veuillez entrer l\'âge';

  @override
  String get petSize => 'Taille de l\'animal';

  @override
  String get small => 'Petit';

  @override
  String get medium => 'Moyen';

  @override
  String get large => 'Grand';

  @override
  String get enterSpecialInstructions => 'ex : Amical avec les autres chiens';

  @override
  String get savePet => 'ENREGISTRER L\'ANIMAL';

  @override
  String get noAddressesFound => 'Aucune adresse trouvée';

  @override
  String setAsDefaultSuccess(String label) {
    return '$label définie comme adresse par défaut';
  }

  @override
  String get verifyAddressError =>
      'Impossible de vérifier l\'adresse. Veuillez vérifier votre saisie.';

  @override
  String get defaultTag => 'PAR DÉFAUT';

  @override
  String get addressFallback => 'Adresse';

  @override
  String get setAsDefault => 'Définir par défaut';

  @override
  String get editAddress => 'Modifier l\'adresse';

  @override
  String get remove => 'Supprimer';

  @override
  String get yourLocation => 'Votre emplacement';

  @override
  String get noSavedAddresses => 'Aucune adresse enregistrée';

  @override
  String get addNewAddress => 'Ajouter une nouvelle adresse';

  @override
  String get errorLoadingData => 'Erreur lors du chargement des données';

  @override
  String get searchAddressHint => 'Rechercher une adresse...';

  @override
  String get addressLabel => 'Libellé de l\'adresse';

  @override
  String get addressExample => 'ex : Maison, Travail';

  @override
  String get manualEntryDetails => 'Détails de saisie manuelle';

  @override
  String get streetAddress => 'Adresse';

  @override
  String get city => 'Ville';

  @override
  String get postalCode => 'Code postal';

  @override
  String get verifyAndSaveAddress => 'VÉRIFIER ET ENREGISTRER L\'ADRESSE';

  @override
  String reviewsFor(String name) {
    return 'Avis pour $name';
  }

  @override
  String get error => 'Erreur';

  @override
  String get recent => 'Récent';

  @override
  String get user => 'Utilisateur';

  @override
  String get nameCardLabel => 'Nom complet';

  @override
  String get nameCardHint => 'Entrez votre nom';

  @override
  String get bioCardLabel => 'Biographie complète';

  @override
  String get bioCardHint => 'Parlez-nous de vous';

  @override
  String get hourlyRateCardLabel => 'Tarif horaire';

  @override
  String get hourlyRateCardSuffix => '/ h';

  @override
  String get yearsCardLabel => 'Années d\'expérience';

  @override
  String get yearsCardHint => 'ex: 5';

  @override
  String get fillAllFields => 'Veuillez remplir tous les champs.';

  @override
  String get hourlyRateZero => 'Le tarif doit être supérieur à 0.';

  @override
  String get somethingWentWrong =>
      'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get noCards => 'Aucune carte enregistrée';

  @override
  String get enterAddress => 'Entrez l\'adresse';

  @override
  String get rescheduleBooking => 'Reporter la réservation';

  @override
  String get pleaseEnterAllFields => 'Veuillez remplir tous les champs';

  @override
  String get addressUpdatedSuccessfully => 'Adresse mise à jour avec succès !';

  @override
  String get petUpdatedSuccessfully => 'Animal mis à jour avec succès !';

  @override
  String get editPet => 'Modifier l\'animal';

  @override
  String get changePhoto => 'Changer la photo';

  @override
  String get ageYears => 'Âge (Années)';

  @override
  String get profileUpdatedSuccessfully => 'Profil mis à jour avec succès !';

  @override
  String get enterFullName => 'Entrez votre nom complet';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get enterEmail => 'Entrez votre e-mail';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get enterPhoneNumber => 'Entrez votre numéro de téléphone';

  @override
  String get address => 'Adresse';

  @override
  String get appName => 'PawWalk';

  @override
  String get enterValidCardDetails =>
      'Veuillez entrer des coordonnées bancaires valides';

  @override
  String get otherMethods => 'Autres méthodes';

  @override
  String get thankYouForReview => 'Merci pour votre avis !';

  @override
  String get writeReview => 'Écrire un avis';

  @override
  String howWasWalk(String walkerName) {
    return 'Comment s\'est passée la promenade avec $walkerName ?';
  }

  @override
  String forYourDog(String dogName) {
    return 'pour votre chien, $dogName';
  }

  @override
  String get tellUsMoreAbout => 'Dites-nous en plus sur la promenade';

  @override
  String get describeWalk => 'Décrivez votre expérience (optionnel)';

  @override
  String get submitReview => 'Envoyer l\'avis';

  @override
  String get selectDateAndTime => 'Sélectionnez une date et une heure';

  @override
  String get pleaseLoginToBookWalk =>
      'Veuillez vous connecter pour réserver une promenade';

  @override
  String get years => 'années';

  @override
  String get changesSaved => 'Modifications enregistrées !';

  @override
  String get weekly => 'Hebdomadaire';

  @override
  String get monthly => 'Mensuel';

  @override
  String get markAllAsRead => 'Tout marquer comme lu';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get errorLoadingNotifications =>
      'Erreur lors du chargement des notifications.';

  @override
  String get noNotificationsAvailable =>
      'Aucune notification disponible pour le moment.';

  @override
  String get newNotifications => 'Nouvelles';

  @override
  String get earlierNotifications => 'Plus anciennes';

  @override
  String get notificationDeleted => 'Notification supprimée';

  @override
  String get justNow => 'À l\'instant';

  @override
  String minsAgo(int count) {
    return '$count min';
  }

  @override
  String hoursAgo(int count) {
    return '$count h';
  }

  @override
  String get yesterday => 'Hier';

  @override
  String daysAgo(int count) {
    return '$count jours';
  }

  @override
  String get errorLoadingProfile => 'Erreur lors du chargement du profil';

  @override
  String petDeletedSuccessfully(String name) {
    return '$name supprimé avec succès';
  }

  @override
  String errorDeletingPet(String error) {
    return 'Erreur lors de la suppression de l\'animal : $error';
  }

  @override
  String errorWithValue(String error) {
    return 'Erreur : $error';
  }

  @override
  String get myChats => 'Mes discussions';

  @override
  String get active => 'Actives';

  @override
  String get past => 'Passées';

  @override
  String get errorLoadingChats => 'Erreur lors du chargement des discussions';

  @override
  String get noActiveChats => 'Pas encore de discussions actives.';

  @override
  String get noPastChats => 'Pas encore de discussions passées.';

  @override
  String get unknownUser => 'Utilisateur inconnu';

  @override
  String petLabel(String petName) {
    return 'Animal : $petName';
  }

  @override
  String get completeWalkSessionTitle => 'Terminer la promenade ?';

  @override
  String get emergencyCancelWalkTitle => 'Urgence / Annuler la promenade ?';

  @override
  String get completeWalkSessionMessage =>
      'Êtes-vous sûr de vouloir terminer cette session ? Cela finalisera la promenade et fermera la discussion.';

  @override
  String get emergencyCancelWalkMessage =>
      'Signalez-vous une urgence ou annulez-vous la promenade ? Cela mettra fin à la coordination immédiatement et fermera la discussion.';

  @override
  String get goBack => 'Retour';

  @override
  String get confirmAndEnd => 'Confirmer et terminer';

  @override
  String get sessionCompleted => 'Session terminée';

  @override
  String get sessionEndedRefunded => 'Session terminée et remboursée';

  @override
  String get sessionCancelled => 'Session annulée';

  @override
  String get sessionClosed => 'Session fermée';

  @override
  String get activeCoordination => 'Coordination active';

  @override
  String get errorLoadingMessages => 'Erreur lors du chargement des messages';

  @override
  String get chatEnded =>
      'Cette discussion est terminée. Vous ne pouvez plus envoyer de messages.';

  @override
  String get completeWalk => 'Terminer la promenade';

  @override
  String get endEarly => 'Arrêter plus tôt';

  @override
  String get cancelWalk => 'Annuler la promenade';

  @override
  String get typeAMessage => 'Écrivez un message...';

  @override
  String get refundProcessed => 'Remboursement traité';

  @override
  String refundNotification(String amount) {
    return 'Le promeneur a terminé la session de manière inattendue. Votre paiement de $amount a été remboursé.';
  }

  @override
  String get walkCompletedSuccessfully => 'Promenade terminée avec succès.';

  @override
  String get walkEndedEarly => 'Promenade terminée plus tôt.';

  @override
  String get walkCompletedTitle => 'Promenade terminée !';

  @override
  String get walkEndedEarlyTitle => 'Promenade interrompue';

  @override
  String closingReasonComplete(String role, String name) {
    return 'Terminé : Promenade marquée comme complétée par $role ($name)';
  }

  @override
  String closingReasonCancelled(String role, String name) {
    return 'Terminé : $role ($name) a demandé l\'annulation de la coordination';
  }

  @override
  String priceAmount(String amount) {
    return '$amount \$';
  }

  @override
  String chatStartedFor(String petName) {
    return 'Discussion commencée pour $petName';
  }

  @override
  String walkerWelcomeMessage(String userName, String petName) {
    return '👋 $userName a accepté la demande de promenade pour $petName. Vous pouvez maintenant coordonner les détails ici !';
  }

  @override
  String ownerWelcomeMessage(String userName, String petName) {
    return '👋 $userName a commencé une discussion concernant la promenade de $petName.';
  }

  @override
  String get bookingManagement => 'Gestion des réservations';

  @override
  String errorLoadingBookings(String error) {
    return 'Erreur lors du chargement des réservations : $error';
  }

  @override
  String get total => 'Total';

  @override
  String get pending => 'En attente';

  @override
  String get confirmed => 'Confirmée';

  @override
  String get completed => 'Terminée';

  @override
  String get noBookingsYet => 'Aucune réservation pour le moment.';

  @override
  String get viewDetails => 'Voir les détails';

  @override
  String get bookingDetails => 'Détails de la réservation';

  @override
  String walkerWithName(String walkerName) {
    return 'Promeneur : $walkerName';
  }

  @override
  String get time => 'Heure';

  @override
  String get disputeResolution => 'Résolution des litiges';

  @override
  String openDisputesCount(int count) {
    return '$count litiges ouverts';
  }

  @override
  String get open => 'Ouvert';

  @override
  String get resolved => 'Résolu';

  @override
  String reportedAgainst(String reportedBy, String against) {
    return '$reportedBy a signalé $against';
  }

  @override
  String get resolve => 'Résoudre';

  @override
  String get dismiss => 'Ignorer';

  @override
  String get disputeResolved => 'Litige résolu.';

  @override
  String get disputeDismissed => 'Litige ignoré.';

  @override
  String get platformOverview => 'Aperçu de la plateforme';

  @override
  String get platformStats => 'Statistiques de la plateforme';

  @override
  String get totalUsers => 'Utilisateurs totaux';

  @override
  String get activeWalks => 'Promenades actives';

  @override
  String get totalBookings => 'Réservations totales';

  @override
  String get pendingApprovals => 'Approbations en attente';

  @override
  String get sendAnnouncementTitle => 'Envoyer une annonce';

  @override
  String get title => 'Titre';

  @override
  String get message => 'Message';

  @override
  String get fillTitleAndMessage => 'Veuillez remplir le titre et le message.';

  @override
  String get currentBuild => 'Version actuelle';

  @override
  String get appLockedDescription =>
      'L\'application est actuellement verrouillée pour les utilisateurs';

  @override
  String get appLiveDescription => 'L\'application est en ligne et accessible';

  @override
  String get supportEmailDescription =>
      'Adresse de support affichée aux utilisateurs';

  @override
  String totalUsersCount(int count) {
    return '$count utilisateurs au total';
  }

  @override
  String get searchUsersHint => 'Rechercher par nom ou e-mail...';

  @override
  String userApproved(String name) {
    return '$name approuvé !';
  }

  @override
  String userSuspended(String name) {
    return '$name suspendu.';
  }

  @override
  String userRestored(String name) {
    return '$name restauré.';
  }

  @override
  String errorLoadingUsers(String error) {
    return 'Erreur lors du chargement des utilisateurs : $error';
  }

  @override
  String errorLoadingReviews(String error) {
    return 'Erreur lors du chargement des avis : $error';
  }

  @override
  String errorLoadingPets(String error) {
    return 'Erreur lors du chargement des animaux : $error';
  }

  @override
  String errorLoadingAddresses(String error) {
    return 'Erreur lors du chargement des adresses : $error';
  }

  @override
  String get mySchedule => 'Mon emploi du temps';

  @override
  String get viewNotifications => 'Voir les notifications';

  @override
  String get viewChat => 'Voir Le Chat';

  @override
  String get requests => 'Demandes';

  @override
  String get schedule => 'Horaire';

  @override
  String hourlyRateValue(String rate) {
    return '$rate \$/h';
  }

  @override
  String errorCreatingBooking(String error) {
    return 'Erreur lors de la création de la réservation : $error';
  }

  @override
  String get newWalkerRegistered => 'Nouveau promeneur inscrit';

  @override
  String get bookingCompleted => 'Réservation terminée';

  @override
  String get disputeReportedBy => 'Litige signalé par';

  @override
  String get walkerApproved => 'Promeneur approuvé';

  @override
  String get newOwnerRegistered => 'Nouveau propriétaire inscrit';

  @override
  String get searchByNameOrEmail => 'Rechercher par nom ou e-mail...';

  @override
  String get noUsersFound => 'Aucun utilisateur trouvé pour votre recherche.';

  @override
  String get reported => 'a signalé';

  @override
  String get resolveDispute => 'Résoudre le litige';

  @override
  String get bookingsManagement => 'Gestion des Réservations';
}
