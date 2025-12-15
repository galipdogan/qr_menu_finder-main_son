import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meilisearch/meilisearch.dart';

// Core / Config
import 'core/config/meilisearch_config.dart';
import 'core/services/meilisearch_sync_service.dart';

// Menu cache
import 'features/menu/data/cache/menu_cache_service.dart';

// Features - Analytics
import 'features/analytics/data/datasources/analytics_remote_data_source.dart';
import 'features/analytics/data/repositories/analytics_repository_impl.dart';
import 'features/analytics/domain/repositories/analytics_repository.dart';
import 'features/analytics/domain/usecases/initialize_analytics.dart';
import 'features/analytics/domain/usecases/log_analytics_event.dart';

// Features - Auth
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/sign_in_with_email_password.dart';
import 'features/auth/domain/usecases/sign_up_with_email_password.dart';
import 'features/auth/domain/usecases/sign_out.dart';

// Features - Restaurant
import 'features/menu/domain/usecases/process_menu_link.dart';
import 'features/restaurant/data/datasources/restaurant_remote_data_source.dart';
import 'features/restaurant/data/repositories/restaurant_repository_impl.dart';
import 'features/restaurant/domain/repositories/restaurant_repository.dart';
import 'features/restaurant/domain/usecases/get_nearby_restaurants.dart';
import 'features/restaurant/domain/usecases/search_restaurants.dart';
import 'features/restaurant/domain/usecases/get_restaurant_by_id.dart';
import 'features/restaurant/domain/usecases/create_restaurant.dart';

// Features - Menu
import 'features/menu/data/datasources/menu_remote_data_source.dart';
import 'features/menu/data/datasources/menu_remote_data_source_impl.dart';
import 'features/menu/data/repositories/menu_repository_impl.dart';
import 'features/menu/domain/repositories/menu_repository.dart';
import 'features/menu/domain/usecases/get_menu_items_by_restaurant.dart';
import 'features/menu/domain/usecases/get_menu_item_by_id.dart';
import 'features/menu/domain/usecases/search_menu_items.dart';
import 'features/menu/domain/usecases/get_popular_menu_items.dart';
import 'features/menu/domain/usecases/get_menu_items_by_category.dart';
import 'features/menu/domain/usecases/add_menu_photo.dart';
import 'features/menu/domain/usecases/add_menu_url.dart';

// Features - Review
import 'features/review/data/datasources/review_remote_data_source.dart';
import 'features/review/data/repositories/review_repository_impl.dart';
import 'features/review/domain/repositories/review_repository.dart';
import 'features/review/domain/usecases/get_user_reviews.dart';
import 'features/review/domain/usecases/delete_review.dart';
import 'features/review/domain/usecases/update_review.dart';

// Features - Search
import 'features/search/data/datasources/search_remote_data_source.dart';
import 'features/search/data/datasources/meilisearch_remote_data_source.dart';
import 'features/search/data/repositories/hybrid_search_repository_impl.dart';
import 'features/search/domain/repositories/search_repository.dart';
import 'features/search/domain/usecases/search_items.dart';
import 'features/search/domain/usecases/get_search_suggestions.dart';

// Features - History
import 'features/history/data/datasources/history_remote_data_source.dart';
import 'features/history/data/repositories/history_repository_impl.dart';
import 'features/history/domain/repositories/history_repository.dart';
import 'features/history/domain/usecases/get_user_history.dart';
import 'features/history/domain/usecases/clear_history.dart';
import 'features/history/domain/usecases/delete_history_entry.dart';
import 'features/history/domain/usecases/track_search.dart';

// Features - Favorites
import 'features/favorites/data/datasources/favorites_remote_data_source.dart';
import 'features/favorites/data/repositories/favorites_repository_impl.dart';
import 'features/favorites/domain/repositories/favorites_repository.dart';
import 'features/favorites/domain/usecases/get_user_favorites.dart';
import 'features/favorites/domain/usecases/add_favorite.dart';
import 'features/favorites/domain/usecases/remove_favorite.dart';
import 'features/favorites/domain/usecases/toggle_favorite.dart';

// Features - Profile
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_user_profile.dart' as profile_uc;
import 'features/profile/domain/usecases/update_profile.dart';

// Features - Owner Panel
import 'features/owner_panel/data/datasources/owner_panel_remote_data_source.dart';
import 'features/owner_panel/data/repositories/owner_panel_repository_impl.dart';
import 'features/owner_panel/domain/repositories/owner_panel_repository.dart';
import 'features/owner_panel/domain/usecases/get_owner_stats.dart';
import 'features/owner_panel/domain/usecases/get_owner_restaurants.dart';
import 'features/owner_panel/domain/usecases/request_owner_upgrade.dart';

// Features - Home
import 'features/home/data/datasources/location_remote_data_source.dart';
import 'features/home/data/repositories/location_repository_impl.dart';
import 'features/home/domain/repositories/location_repository.dart';
import 'features/home/domain/usecases/get_current_location.dart';
import 'features/home/domain/usecases/get_location_name.dart';
import 'features/home/domain/usecases/search_places.dart';
import 'features/home/domain/usecases/get_turkey_locations.dart';

// Features - Item Moderation
import 'features/item_moderation/data/datasources/item_moderation_remote_data_source.dart';
import 'features/item_moderation/data/repositories/item_moderation_repository_impl.dart';
import 'features/item_moderation/domain/repositories/item_moderation_repository.dart';
import 'features/item_moderation/domain/usecases/promote_to_live_usecase.dart';
import 'features/item_moderation/domain/usecases/approve_item_usecase.dart';
import 'features/item_moderation/domain/usecases/reject_item_usecase.dart';
import 'features/item_moderation/domain/usecases/report_item_usecase.dart';
import 'features/item_moderation/presentation/blocs/item_moderation_bloc.dart';

// Features - Settings
import 'core/theme/theme_bloc.dart';
import 'features/settings/presentation/blocs/settings_bloc.dart';
import 'features/settings/domain/usecases/get_language.dart';
import 'features/settings/domain/usecases/set_language.dart';
import 'features/settings/domain/usecases/get_notifications_status.dart';
import 'features/settings/domain/usecases/set_notifications_status.dart';
import 'features/settings/domain/usecases/get_theme_mode.dart';
import 'features/settings/domain/usecases/set_theme_mode.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/data/datasources/settings_local_data_source.dart';

// Features - Notifications
import 'features/notifications/presentation/blocs/notification_bloc.dart';
import 'features/notifications/domain/usecases/request_notification_permission.dart';
import 'features/notifications/domain/usecases/get_fcm_token.dart';
import 'features/notifications/domain/usecases/get_notification_settings.dart';
import 'features/notifications/domain/usecases/listen_to_foreground_messages.dart';
import 'features/notifications/domain/usecases/listen_to_opened_app_messages.dart';
import 'features/notifications/domain/usecases/listen_to_token_refresh.dart';
import 'features/notifications/domain/usecases/save_fcm_token_for_user.dart';
import 'features/notifications/domain/usecases/remove_fcm_token_for_user.dart';
import 'features/notifications/domain/repositories/notification_repository.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/data/datasources/notification_remote_data_source.dart';

// Features - OCR
import 'features/ocr/domain/usecases/recognize_text_from_image.dart';
import 'features/ocr/domain/usecases/parse_text_to_menu_items.dart';
import 'features/ocr/domain/usecases/extract_and_parse_menu_items_from_image.dart';
import 'features/ocr/domain/repositories/ocr_repository.dart';
import 'features/ocr/data/repositories/ocr_repository_impl.dart';
import 'features/ocr/data/datasources/ocr_remote_data_source.dart';

// Features - Storage
import 'features/storage/domain/repositories/storage_repository.dart';
import 'features/storage/data/repositories/storage_repository_impl.dart';
import 'features/storage/data/datasources/storage_remote_data_source.dart';
import 'features/storage/domain/usecases/upload_file.dart';
import 'features/storage/domain/usecases/delete_file.dart';

// Features - Price Comparison
import 'features/price_comparison/data/datasources/price_comparison_remote_data_source.dart';
import 'features/price_comparison/data/repositories/price_comparison_repository_impl.dart';
import 'features/price_comparison/domain/repositories/price_comparison_repository.dart';
import 'features/price_comparison/domain/usecases/get_compared_prices.dart';
import 'features/price_comparison/presentation/blocs/price_comparison_bloc.dart';

// Presentation - Blocs
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/restaurant/presentation/blocs/restaurant_bloc.dart';
import 'features/menu/presentation/blocs/menu_bloc.dart';
import 'features/menu/presentation/blocs/item_detail/item_detail_bloc.dart';
import 'features/review/presentation/blocs/review_bloc.dart';
import 'features/search/presentation/blocs/search_bloc.dart';
import 'features/history/presentation/blocs/history_bloc.dart';
import 'features/favorites/presentation/blocs/favorites_bloc.dart';
import 'features/profile/presentation/blocs/profile_bloc.dart';
import 'features/owner_panel/presentation/blocs/owner_panel_bloc.dart';
import 'features/home/presentation/blocs/home_bloc.dart';
import 'features/home/presentation/blocs/search/search_bloc.dart'
    as home_search;
import 'features/home/presentation/blocs/location_selection/location_selection_bloc.dart';

// Legacy / Maps
import 'features/maps/data/datasources/photon_remote_data_source.dart';
import 'features/maps/data/datasources/turkey_location_remote_data_source.dart';
import 'features/maps/data/datasources/nominatim_remote_data_source.dart';
import 'features/maps/data/datasources/openstreetmap_details_remote_data_source.dart';

final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> init() async {
  _initAuth();
  _initRestaurant();
  _initMenu();
  _initAnalytics();
  _initReview();
  _initSearch();
  _initHistory();
  _initFavorites();
  _initProfile();
  _initOwnerPanel();
  _initHome();
  _initItemModeration();
  _initSettings();
  _initNotifications();
  _initOcr();
  _initStorage();
  _initPriceComparison();
  _initCore();
  await _initExternal();
}

/// Analytics
void _initAnalytics() {
  sl.registerLazySingleton(() => InitializeAnalytics(sl()));
  sl.registerLazySingleton(() => LogAnalyticsEvent(sl()));

  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AnalyticsRemoteDataSource>(
    () => FirebaseAnalyticsDataSourceImpl(firebaseAnalytics: sl()),
  );
}

/// Auth
void _initAuth() {
  sl.registerFactory(
    () => AuthBloc(
      getCurrentUser: sl(),
      signInWithEmailPassword: sl(),
      signUpWithEmailPassword: sl(),
      signOut: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => SignInWithEmailPassword(sl()));
  sl.registerLazySingleton(() => SignUpWithEmailPassword(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );
}

/// Restaurant
void _initRestaurant() {
  sl.registerFactory(
    () => RestaurantBloc(
      getNearbyRestaurants: sl(),
      searchRestaurants: sl(),
      getRestaurantById: sl(),
      createRestaurant: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetNearbyRestaurants(sl()));
  sl.registerLazySingleton(() => SearchRestaurants(sl()));
  sl.registerLazySingleton(() => GetRestaurantById(sl()));
  sl.registerLazySingleton(() => CreateRestaurant(sl()));

  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(
      firestore: sl(),
      nominatimRemoteDataSource: sl(),
      osmDetailsService: sl<OpenStreetMapDetailsRemoteDataSource>(),
    ),
  );
}

/// Menu (YENİ VE DOĞRU HALİ)
void _initMenu() {
  // Cache
  sl.registerLazySingleton<MenuCacheService>(() => MenuCacheService());

  // Data source
  sl.registerLazySingleton<MenuRemoteDataSource>(
    () => MenuRemoteDataSourceImpl(firestore: sl(), cache: sl()),
  );

  // Repository
  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(remoteDataSource: sl(), ocrRemoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetMenuItemsByRestaurant(sl()));
  sl.registerLazySingleton(() => GetMenuItemById(sl()));
  sl.registerLazySingleton(() => SearchMenuItems(sl()));
  sl.registerLazySingleton(() => GetPopularMenuItems(sl()));
  sl.registerLazySingleton(() => GetMenuItemsByCategory(sl()));
  sl.registerLazySingleton(() => AddMenuPhoto(sl(), sl()));
  sl.registerLazySingleton(() => AddMenuUrl(sl()));
  sl.registerLazySingleton(() => ProcessMenuLink(sl()));

  // Blocs
  sl.registerFactory(
    () => MenuBloc(
      getMenuItemsByRestaurant: sl(),
      searchMenuItems: sl(),
      getPopularMenuItems: sl(),
      getMenuItemsByCategory: sl(),
      addMenuPhoto: sl(),
      addMenuUrl: sl(),
      processMenuLinkUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ItemDetailBloc(getMenuItemById: sl(), getRestaurantById: sl()),
  );
}

/// Review
void _initReview() {
  sl.registerFactory(
    () => ReviewBloc(
      getUserReviews: sl(),
      deleteReview: sl(),
      updateReview: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetUserReviews(sl()));
  sl.registerLazySingleton(() => DeleteReview(sl()));
  sl.registerLazySingleton(() => UpdateReview(sl()));

  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(firestore: sl()),
  );
}

/// Search
void _initSearch() {
  sl.registerFactory(
    () => SearchBloc(searchItems: sl(), getSearchSuggestions: sl()),
  );

  sl.registerLazySingleton(() => SearchItems(sl()));
  sl.registerLazySingleton(() => GetSearchSuggestions(sl()));

  sl.registerLazySingleton<SearchRepository>(
    () => HybridSearchRepositoryImpl(
      firestoreDataSource: sl(),
      meilisearchDataSource: MeiliSearchConfig.isEnabled ? sl() : null,
    ),
  );

  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(firestore: sl()),
  );

  if (MeiliSearchConfig.isEnabled) {
    sl.registerLazySingleton<MeiliSearchRemoteDataSource>(
      () => MeiliSearchRemoteDataSourceImpl(client: sl()),
    );

    sl.registerLazySingleton(
      () =>
          MeiliSearchSyncService(firestore: sl(), meilisearchDataSource: sl()),
    );
  }
}

/// History
void _initHistory() {
  sl.registerFactory(
    () => HistoryBloc(
      getUserHistory: sl(),
      clearHistory: sl(),
      deleteHistoryEntry: sl(),
      trackSearch: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetUserHistory(sl()));
  sl.registerLazySingleton(() => ClearHistory(sl()));
  sl.registerLazySingleton(() => DeleteHistoryEntry(sl()));
  sl.registerLazySingleton(() => TrackSearch(sl()));

  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<HistoryRemoteDataSource>(
    () => HistoryRemoteDataSourceImpl(firestore: sl()),
  );
}

/// Favorites
void _initFavorites() {
  sl.registerFactory(
    () => FavoritesBloc(
      getUserFavorites: sl(),
      addFavorite: sl(),
      removeFavorite: sl(),
      toggleFavorite: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetUserFavorites(sl()));
  sl.registerLazySingleton(() => AddFavorite(sl()));
  sl.registerLazySingleton(() => RemoveFavorite(sl()));
  sl.registerLazySingleton(() => ToggleFavorite(sl()));

  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<FavoritesRemoteDataSource>(
    () => FavoritesRemoteDataSourceImpl(firestore: sl()),
  );
}

/// Profile
void _initProfile() {
  sl.registerFactory(
    () => ProfileBloc(getUserProfile: sl(), updateProfile: sl()),
  );

  sl.registerLazySingleton(() => profile_uc.GetUserProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(firestore: sl()),
  );
}

/// Owner Panel
void _initOwnerPanel() {
  sl.registerFactory(
    () => OwnerPanelBloc(
      getOwnerStats: sl(),
      getOwnerRestaurants: sl(),
      requestOwnerUpgrade: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetOwnerStats(sl()));
  sl.registerLazySingleton(() => GetOwnerRestaurants(sl()));
  sl.registerLazySingleton(() => RequestOwnerUpgrade(sl()));

  sl.registerLazySingleton<OwnerPanelRepository>(
    () => OwnerPanelRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<OwnerPanelRemoteDataSource>(
    () => OwnerPanelRemoteDataSourceImpl(firestore: sl()),
  );
}

/// Home
void _initHome() {
  sl.registerFactory(
    () => HomeBloc(
      getCurrentLocation: sl(),
      getLocationName: sl(),
      getNearbyRestaurants: sl(),
      getUserFavorites: sl(),
      toggleFavorite: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetCurrentLocation(sl()));
  sl.registerLazySingleton(() => GetLocationName(sl()));
  sl.registerLazySingleton(() => SearchPlaces(sl()));
  sl.registerLazySingleton(() => GetTurkeyLocations(sl()));

  sl.registerFactory(() => home_search.SearchBloc(searchPlaces: sl()));

  sl.registerFactory(() => LocationSelectionBloc(getTurkeyLocations: sl()));

  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(
      nominatimRemoteDataSource: sl(),
      turkeyLocationRemoteDataSource: sl(),
      photonRemoteDataSource: sl(),
      restaurantRemoteDataSource: sl(),
    ),
  );
}

/// Item Moderation
void _initItemModeration() {
  sl.registerFactory(
    () => ItemModerationBloc(
      promoteToLiveUseCase: sl(),
      approveItemUseCase: sl(),
      rejectItemUseCase: sl(),
      reportItemUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => PromoteToLiveUseCase(sl()));
  sl.registerLazySingleton(() => ApproveItemUseCase(sl()));
  sl.registerLazySingleton(() => RejectItemUseCase(sl()));
  sl.registerLazySingleton(() => ReportItemUseCase(sl()));

  sl.registerLazySingleton<ItemModerationRepository>(
    () => ItemModerationRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ItemModerationRemoteDataSource>(
    () => ItemModerationRemoteDataSourceImpl(firestore: sl(), auth: sl()),
  );
}

/// Settings
void _initSettings() {
  sl.registerFactory(
    () => SettingsBloc(
      getLanguage: sl(),
      setLanguage: sl(),
      getNotificationsStatus: sl(),
      setNotificationsStatus: sl(),
      getThemeMode: sl(),
      setThemeMode: sl(),
    ),
  );

  sl.registerFactory(() => ThemeBloc(getThemeMode: sl(), setThemeMode: sl()));

  sl.registerLazySingleton(() => GetLanguage(sl()));
  sl.registerLazySingleton(() => SetLanguage(sl()));
  sl.registerLazySingleton(() => GetNotificationsStatus(sl()));
  sl.registerLazySingleton(() => SetNotificationsStatus(sl()));
  sl.registerLazySingleton(() => GetThemeMode(sl()));
  sl.registerLazySingleton(() => SetThemeMode(sl()));

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(sharedPreferences: sl()),
  );
}

/// Notifications
void _initNotifications() {
  sl.registerFactory(
    () => NotificationBloc(
      requestNotificationPermission: sl(),
      getFCMToken: sl(),
      getNotificationSettings: sl(),
      listenToForegroundMessages: sl(),
      listenToOpenedAppMessages: sl(),
      listenToTokenRefresh: sl(),
      saveFCMTokenForUser: sl(),
      removeFCMTokenForUser: sl(),
    ),
  );

  sl.registerLazySingleton(() => RequestNotificationPermission(sl()));
  sl.registerLazySingleton(() => GetFCMToken(sl()));
  sl.registerLazySingleton(() => GetNotificationSettings(sl()));
  sl.registerLazySingleton(() => ListenToForegroundMessages(sl()));
  sl.registerLazySingleton(() => ListenToOpenedAppMessages(sl()));
  sl.registerLazySingleton(() => ListenToTokenRefresh(sl()));
  sl.registerLazySingleton(() => SaveFCMTokenForUser(sl()));
  sl.registerLazySingleton(() => RemoveFCMTokenForUser(sl()));

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => FirebaseNotificationDataSourceImpl(
      firebaseMessaging: sl(),
      firestore: sl(),
    ),
  );
}

/// OCR
void _initOcr() {
  sl.registerLazySingleton(() => RecognizeTextFromImage(sl()));
  sl.registerLazySingleton(() => ParseTextToMenuItems(sl()));
  sl.registerLazySingleton(() => ExtractAndParseMenuItemsFromImage(sl()));

  sl.registerLazySingleton<OcrRepository>(
    () => OcrRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<OcrRemoteDataSource>(() => MLKitOcrDataSourceImpl());
}

/// Storage
void _initStorage() {
  sl.registerLazySingleton(() => UploadFile(sl()));
  sl.registerLazySingleton(() => DeleteFile(sl()));

  sl.registerLazySingleton<StorageRepository>(
    () => StorageRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<StorageRemoteDataSource>(
    () => FirebaseStorageDataSourceImpl(firebaseStorage: sl<FirebaseStorage>()),
  );
}

/// Price Comparison
void _initPriceComparison() {
  sl.registerFactory(() => PriceComparisonBloc(getComparedPrices: sl()));

  sl.registerLazySingleton(() => GetComparedPrices(sl()));

  sl.registerLazySingleton<PriceComparisonRepository>(
    () => PriceComparisonRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<PriceComparisonRemoteDataSource>(
    () => PriceComparisonRemoteDataSourceImpl(firestore: sl()),
  );
}

/// Core
void _initCore() {
  // Şimdilik core servislerin yok, sabit util'ler statik.
}

/// External
Future<void> _initExternal() async {
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAnalytics.instance);
  sl.registerLazySingleton(() => FirebaseMessaging.instance);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => FirebaseStorage.instance);

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  if (MeiliSearchConfig.isEnabled) {
    sl.registerLazySingleton(
      () => MeiliSearchClient(MeiliSearchConfig.host, MeiliSearchConfig.apiKey),
    );
  }

  sl.registerLazySingleton<NominatimRemoteDataSource>(
    () => NominatimRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<PhotonRemoteDataSource>(
    () => PhotonRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<OpenStreetMapDetailsRemoteDataSource>(
    () => OpenStreetMapDetailsRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<TurkeyLocationRemoteDataSource>(
    () => TurkeyLocationRemoteDataSourceImpl(),
  );
}
