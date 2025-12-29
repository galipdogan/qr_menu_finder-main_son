import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('en'),
    Locale('tr'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'QR Menu Finder'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @restaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurants;

  /// No description provided for @menus.
  ///
  /// In en, this message translates to:
  /// **'Menus'**
  String get menus;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @signupPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get signupPrompt;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @mustLogin.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get mustLogin;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequired;

  /// No description provided for @mustLoginForProfile.
  ///
  /// In en, this message translates to:
  /// **'You need to login to view your profile.'**
  String get mustLoginForProfile;

  /// No description provided for @mustLoginForHistory.
  ///
  /// In en, this message translates to:
  /// **'Please login to view your history.'**
  String get mustLoginForHistory;

  /// No description provided for @mustLoginForFavorites.
  ///
  /// In en, this message translates to:
  /// **'Please login to view your favorites.'**
  String get mustLoginForFavorites;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// No description provided for @rescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get rescan;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @menuTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTitle;

  /// No description provided for @showMenuButton.
  ///
  /// In en, this message translates to:
  /// **'Show Menu'**
  String get showMenuButton;

  /// No description provided for @addMenuButton.
  ///
  /// In en, this message translates to:
  /// **'Add Menu'**
  String get addMenuButton;

  /// No description provided for @menuAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Menu'**
  String get menuAddTitle;

  /// No description provided for @menuUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu Upload'**
  String get menuUploadTitle;

  /// No description provided for @uploadAndProcess.
  ///
  /// In en, this message translates to:
  /// **'Upload and Process Menu'**
  String get uploadAndProcess;

  /// No description provided for @menuItems.
  ///
  /// In en, this message translates to:
  /// **'Menu Items'**
  String get menuItems;

  /// No description provided for @menuLabel.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuLabel;

  /// No description provided for @addReview.
  ///
  /// In en, this message translates to:
  /// **'Add Review'**
  String get addReview;

  /// No description provided for @editReview.
  ///
  /// In en, this message translates to:
  /// **'Edit Review'**
  String get editReview;

  /// No description provided for @deleteReview.
  ///
  /// In en, this message translates to:
  /// **'Delete Review'**
  String get deleteReview;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @editReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Review'**
  String get editReviewTitle;

  /// No description provided for @addRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Add Restaurant'**
  String get addRestaurant;

  /// No description provided for @addRestaurantTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Restaurant'**
  String get addRestaurantTitle;

  /// No description provided for @saveRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Save Restaurant'**
  String get saveRestaurant;

  /// No description provided for @exploreRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Explore Restaurants'**
  String get exploreRestaurants;

  /// No description provided for @restaurantDetail.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Detail'**
  String get restaurantDetail;

  /// No description provided for @restaurantLabel.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurantLabel;

  /// No description provided for @restaurantSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Restaurant'**
  String get restaurantSelectTitle;

  /// No description provided for @myRestaurants.
  ///
  /// In en, this message translates to:
  /// **'My Restaurants'**
  String get myRestaurants;

  /// No description provided for @nearbyRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Nearby Restaurants'**
  String get nearbyRestaurants;

  /// No description provided for @restaurantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurantsTitle;

  /// No description provided for @takeCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Get Current Location'**
  String get takeCurrentLocation;

  /// No description provided for @updateLocation.
  ///
  /// In en, this message translates to:
  /// **'Update Location'**
  String get updateLocation;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select location'**
  String get selectLocation;

  /// No description provided for @retryLocationPermission.
  ///
  /// In en, this message translates to:
  /// **'Retry Location Permission'**
  String get retryLocationPermission;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @profileInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get profileInfoTitle;

  /// No description provided for @profileInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, email'**
  String get profileInfoSubtitle;

  /// No description provided for @myComments.
  ///
  /// In en, this message translates to:
  /// **'My Comments'**
  String get myComments;

  /// No description provided for @myCommentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'My reviews'**
  String get myCommentsSubtitle;

  /// No description provided for @myHistory.
  ///
  /// In en, this message translates to:
  /// **'My History'**
  String get myHistory;

  /// No description provided for @myFavorites.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get myFavorites;

  /// No description provided for @visitedPlacesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visited places'**
  String get visitedPlacesSubtitle;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get accountSection;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// No description provided for @emailCannotChange.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be changed'**
  String get emailCannotChange;

  /// No description provided for @accountTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountTypeLabel;

  /// No description provided for @saveChangesLabel.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesLabel;

  /// No description provided for @roleUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get roleUser;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Business Owner'**
  String get roleOwner;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get roleAdmin;

  /// No description provided for @rolePendingOwner.
  ///
  /// In en, this message translates to:
  /// **'Pending Business Application'**
  String get rolePendingOwner;

  /// No description provided for @ownerPanel.
  ///
  /// In en, this message translates to:
  /// **'Owner Panel'**
  String get ownerPanel;

  /// No description provided for @ownerPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Owner Panel'**
  String get ownerPanelTitle;

  /// No description provided for @upgradeToOwner.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Business Account'**
  String get upgradeToOwner;

  /// No description provided for @accessOwnerPanel.
  ///
  /// In en, this message translates to:
  /// **'Access Owner Panel'**
  String get accessOwnerPanel;

  /// No description provided for @openBusinessAccount.
  ///
  /// In en, this message translates to:
  /// **'Open Business Account'**
  String get openBusinessAccount;

  /// No description provided for @businessAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Business Account'**
  String get businessAccountTitle;

  /// No description provided for @businessAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your restaurant, manage your menus'**
  String get businessAccountSubtitle;

  /// No description provided for @manageRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Manage Restaurants'**
  String get manageRestaurants;

  /// No description provided for @manageMenus.
  ///
  /// In en, this message translates to:
  /// **'Manage Menus'**
  String get manageMenus;

  /// No description provided for @manageReviews.
  ///
  /// In en, this message translates to:
  /// **'Manage Reviews'**
  String get manageReviews;

  /// No description provided for @viewStatistics.
  ///
  /// In en, this message translates to:
  /// **'View Statistics'**
  String get viewStatistics;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @recentActivities.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities'**
  String get recentActivities;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get nameLabel;

  /// No description provided for @restaurantNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Name *'**
  String get restaurantNameLabel;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City *'**
  String get cityLabel;

  /// No description provided for @districtLabel.
  ///
  /// In en, this message translates to:
  /// **'District *'**
  String get districtLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address *'**
  String get addressLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @locationInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'Location Info *'**
  String get locationInfoLabel;

  /// No description provided for @latitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitudeLabel;

  /// No description provided for @longitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitudeLabel;

  /// No description provided for @ratingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingLabel;

  /// No description provided for @reviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Review'**
  String get reviewLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @uploadMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Upload Method'**
  String get uploadMethodLabel;

  /// No description provided for @selectedPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected Photo'**
  String get selectedPhotoLabel;

  /// No description provided for @sortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortLabel;

  /// No description provided for @minRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum Rating'**
  String get minRatingLabel;

  /// No description provided for @categoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesLabel;

  /// No description provided for @priceRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRangeLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'555 555 5555'**
  String get phoneHint;

  /// No description provided for @urlHint.
  ///
  /// In en, this message translates to:
  /// **'https://example.com/menu.jpg'**
  String get urlHint;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search food or restaurant...'**
  String get searchHint;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @locationLoading.
  ///
  /// In en, this message translates to:
  /// **'Getting location...'**
  String get locationLoading;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @historyLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading history...'**
  String get historyLoading;

  /// No description provided for @favoritesLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading favorites...'**
  String get favoritesLoading;

  /// No description provided for @reviewsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading reviews...'**
  String get reviewsLoading;

  /// No description provided for @restaurantInfoLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading restaurant info...'**
  String get restaurantInfoLoading;

  /// No description provided for @itemLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading item...'**
  String get itemLoading;

  /// No description provided for @ownerPanelLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading owner panel...'**
  String get ownerPanelLoading;

  /// No description provided for @priceSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching prices...'**
  String get priceSearching;

  /// No description provided for @historyClearing.
  ///
  /// In en, this message translates to:
  /// **'Clearing history...'**
  String get historyClearing;

  /// No description provided for @locationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Location retrieved successfully!'**
  String get locationSuccess;

  /// No description provided for @historyCleared.
  ///
  /// In en, this message translates to:
  /// **'History cleared'**
  String get historyCleared;

  /// No description provided for @favoriteAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get favoriteAdded;

  /// No description provided for @favoriteRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get favoriteRemoved;

  /// No description provided for @sessionClosed.
  ///
  /// In en, this message translates to:
  /// **'Session closed'**
  String get sessionClosed;

  /// No description provided for @addRestaurantSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restaurant added successfully!'**
  String get addRestaurantSuccess;

  /// No description provided for @menuAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'✅ Menu added successfully!'**
  String get menuAddedSuccess;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccess;

  /// No description provided for @reviewDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Review deleted successfully'**
  String get reviewDeleteSuccess;

  /// No description provided for @reviewUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Review updated successfully'**
  String get reviewUpdateSuccess;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get noInternet;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'A problem occurred while connecting to the server. Please try again later.'**
  String get serverError;

  /// No description provided for @timeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get timeout;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unknownError;

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed. Please try again.'**
  String get operationFailed;

  /// No description provided for @restaurantNotFound.
  ///
  /// In en, this message translates to:
  /// **'Restaurant not found. It may have been removed.'**
  String get restaurantNotFound;

  /// No description provided for @menuNotFound.
  ///
  /// In en, this message translates to:
  /// **'Menu Not Found'**
  String get menuNotFound;

  /// No description provided for @noMenuAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No menu has been added for this restaurant yet'**
  String get noMenuAddedYet;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission required. You can enable it in settings.'**
  String get locationPermissionDenied;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location service is disabled. Please enable it.'**
  String get locationServiceDisabled;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect. Please check.'**
  String get invalidCredentials;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This email address is already in use.'**
  String get emailAlreadyInUse;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Use at least 6 characters.'**
  String get weakPassword;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @restaurantNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Restaurant name is required'**
  String get restaurantNameRequired;

  /// No description provided for @cityRequired.
  ///
  /// In en, this message translates to:
  /// **'City is required'**
  String get cityRequired;

  /// No description provided for @districtRequired.
  ///
  /// In en, this message translates to:
  /// **'District is required'**
  String get districtRequired;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get addressRequired;

  /// No description provided for @urlRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter URL'**
  String get urlRequired;

  /// No description provided for @urlInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL (http:// or https://)'**
  String get urlInvalid;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get noData;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No History Yet'**
  String get historyEmptyTitle;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Favorites Yet'**
  String get favoritesEmptyTitle;

  /// No description provided for @reviewsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Reviews Yet'**
  String get reviewsEmptyTitle;

  /// No description provided for @searchNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get searchNoResultsTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notifications about promotions and updates'**
  String get notificationsSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @generalSection.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSection;

  /// No description provided for @notificationsSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationsSettings;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @allNotifications.
  ///
  /// In en, this message translates to:
  /// **'All notifications'**
  String get allNotifications;

  /// No description provided for @menuUpdates.
  ///
  /// In en, this message translates to:
  /// **'Menu Updates'**
  String get menuUpdates;

  /// No description provided for @menuUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'New menu notifications from favorite restaurants'**
  String get menuUpdatesDesc;

  /// No description provided for @priceChanges.
  ///
  /// In en, this message translates to:
  /// **'Price Changes'**
  String get priceChanges;

  /// No description provided for @priceChangesDesc.
  ///
  /// In en, this message translates to:
  /// **'Price changes for products you follow'**
  String get priceChangesDesc;

  /// No description provided for @newComments.
  ///
  /// In en, this message translates to:
  /// **'New Comments'**
  String get newComments;

  /// No description provided for @newCommentsDesc.
  ///
  /// In en, this message translates to:
  /// **'New reviews for my favorite restaurants'**
  String get newCommentsDesc;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @confirmClearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get confirmClearHistoryTitle;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'All your history will be deleted. Are you sure?'**
  String get clearHistoryConfirm;

  /// No description provided for @confirmClearHistoryContent.
  ///
  /// In en, this message translates to:
  /// **'All your history will be deleted. Are you sure?'**
  String get confirmClearHistoryContent;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get favoritesTitle;

  /// No description provided for @reviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Reviews'**
  String get reviewsTitle;

  /// No description provided for @reviewsLabel.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsLabel;

  /// No description provided for @reviewCount.
  ///
  /// In en, this message translates to:
  /// **'Review Count'**
  String get reviewCount;

  /// No description provided for @confirmDeleteReview.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this review?'**
  String get confirmDeleteReview;

  /// No description provided for @searchStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Searching'**
  String get searchStartTitle;

  /// No description provided for @searchStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the search bar above to search for food or restaurants'**
  String get searchStartSubtitle;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @filterSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter & Sort'**
  String get filterSortTitle;

  /// No description provided for @sortDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get sortDistance;

  /// No description provided for @sortRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get sortRating;

  /// No description provided for @sortReviewCount.
  ///
  /// In en, this message translates to:
  /// **'Review Count'**
  String get sortReviewCount;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @otherCategory.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherCategory;

  /// No description provided for @citySimple.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get citySimple;

  /// No description provided for @priceHistory.
  ///
  /// In en, this message translates to:
  /// **'Price History'**
  String get priceHistory;

  /// No description provided for @priceHistoryLabel.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get priceHistoryLabel;

  /// No description provided for @viewCount.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get viewCount;

  /// No description provided for @viewsLabel.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get viewsLabel;

  /// No description provided for @urlCouldNotBeLaunched.
  ///
  /// In en, this message translates to:
  /// **'URL could not be launched'**
  String get urlCouldNotBeLaunched;

  /// No description provided for @loginRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'You need to log in for this action. Do you want to log in now?'**
  String get loginRequiredMessage;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get getDirections;

  /// No description provided for @loadingMoreRecentData.
  ///
  /// In en, this message translates to:
  /// **'Loading more recent data...'**
  String get loadingMoreRecentData;

  /// No description provided for @osmAttribution.
  ///
  /// In en, this message translates to:
  /// **'This restaurant is sourced from OpenStreetMap.'**
  String get osmAttribution;

  /// No description provided for @googleRating.
  ///
  /// In en, this message translates to:
  /// **'Google Rating'**
  String get googleRating;

  /// No description provided for @couldNotFetchRecentData.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch recent data'**
  String get couldNotFetchRecentData;

  /// No description provided for @mapView.
  ///
  /// In en, this message translates to:
  /// **'Map View'**
  String get mapView;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @scanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get scanQr;

  /// No description provided for @menuProducts.
  ///
  /// In en, this message translates to:
  /// **'Menu Products'**
  String get menuProducts;

  /// No description provided for @pendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingLabel;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @editedSuffix.
  ///
  /// In en, this message translates to:
  /// **'(edited)'**
  String get editedSuffix;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @businessAccountSoon.
  ///
  /// In en, this message translates to:
  /// **'Business account registration coming soon!'**
  String get businessAccountSoon;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @welcomePrefix.
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get welcomePrefix;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
