import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/auth/presentation/blocs/auth_event.dart';
import 'features/auth/presentation/blocs/auth_state.dart';
import 'features/notifications/presentation/blocs/notification_bloc.dart';
import 'firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_bloc.dart';
import 'core/theme/theme_state.dart';
import 'core/l10n/locale_cubit.dart';
import 'l10n/app_localizations.dart';
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/favorites/presentation/blocs/favorites_bloc.dart';
import 'features/favorites/presentation/blocs/favorites_event.dart';
import 'features/favorites/domain/entities/favorite_item.dart';
import 'features/home/presentation/blocs/home_bloc.dart';
import 'features/review/presentation/blocs/review_bloc.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/analytics/domain/usecases/initialize_analytics.dart'; // New import for Analytics UseCase
import 'routing/app_router.dart';
import 'injection_container.dart' as di;
import 'core/utils/env_config.dart';
import 'core/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment variables
  await EnvConfig.init();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  AppLogger.i('🚀 App starting...');

  // Initialize Dependency Injection
  await di.init();

  // Initialize Analytics
  await di.sl<InitializeAnalytics>()(
    NoParams(),
  ); // Replaced AnalyticsService.initialize()

  // Initialize Notifications
  // Handled by NotificationBloc

  // OpenStreetMap kullanıldığı için Google Maps API yüklemeye gerek yok
  AppLogger.i('🗺️ Using OpenStreetMap (no API key required)');

  // Initialize Firebase App Check - Temporarily disabled for development
  // Note: App Check integration available after Firebase Functions deployment
  if (!kDebugMode) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
      webProvider: ReCaptchaV3Provider(
        EnvConfig.recaptchaSiteKey.isNotEmpty
            ? EnvConfig.recaptchaSiteKey
            : 'recaptcha-v3-site-key',
      ),
    );
  }

  // Configure Firestore settings - use default (Native mode) database
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<ThemeBloc>()),
        BlocProvider(create: (context) => di.sl<LocaleCubit>()),
        BlocProvider(
          create: (context) {
            final bloc = di.sl<AuthBloc>();
            bloc.add(AuthStatusCheckRequested());
            return bloc;
          },
        ),
        BlocProvider(create: (context) => di.sl<FavoritesBloc>()),
        BlocProvider(create: (context) => di.sl<HomeBloc>()),
        BlocProvider(create: (context) => di.sl<ReviewBloc>()),
        // NotificationBloc - only enabled on mobile platforms (iOS/Android)
        if (!kIsWeb)
          BlocProvider(
            create: (context) {
              final bloc = di.sl<NotificationBloc>();
              bloc.add(const InitializeNotifications());
              return bloc;
            },
          ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          // Load favorites when user logs in
          if (authState is AuthAuthenticated) {
            context.read<FavoritesBloc>().add(
              FavoritesLoadRequested(
                userId: authState.user.id,
                type: FavoriteType.restaurant,
              ),
            );
            // Save FCM token on login - only on mobile platforms
            if (!kIsWeb) {
              context.read<NotificationBloc>().add(
                SaveFCMTokenRequested(userId: authState.user.id),
              );
            }
          } else if (authState is AuthUnauthenticated) {
            // Clear favorites when user logs out
            // No need to explicitly clear, bloc will reset to initial state
            // Remove FCM token on logout - only on mobile platforms
            if (!kIsWeb) {
              context.read<NotificationBloc>().add(
                const RemoveFCMTokenRequested(userId: 'guest'),
              );
            }
          }
        },
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return MaterialApp.router(
                  title: AppConstants.appName,
                  debugShowCheckedModeBanner: false,
                  routerConfig: AppRouter.router,

                  // � Localization System
                  locale: locale,
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,

                  // �🎨 Theme System with dynamic switching
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: state.themeMode,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
