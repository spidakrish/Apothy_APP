import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/revenue_cat_config.dart';
import 'core/router/app_router.dart';
import 'core/services/local_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/chat/data/models/conversation_model.dart';
import 'features/chat/data/models/message_model.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Register Hive TypeAdapters for chat persistence
  // Must be registered before opening any boxes
  Hive.registerAdapter(MessageSenderHiveAdapter());
  Hive.registerAdapter(MessageModelAdapter());
  Hive.registerAdapter(ConversationModelAdapter());

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize Local Notification Service
  // Note: Permissions are NOT requested here - they are requested during onboarding
  // for better UX (explain value before asking)
  await LocalNotificationService.instance.initialize();

  // Initialize RevenueCat for subscriptions
  // Note: API key should be configured via environment variable for production
  if (RevenueCatConfig.isConfigured) {
    await Purchases.configure(PurchasesConfiguration(RevenueCatConfig.apiKey));
    debugPrint('RevenueCat initialized successfully');
  } else {
    debugPrint(
      'RevenueCat not configured. Set REVENUE_CAT_API_KEY environment variable.',
    );
  }

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        // Override SharedPreferences provider with actual instance
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const ApothyApp(),
    ),
  );
}

/// Root application widget
class ApothyApp extends ConsumerWidget {
  const ApothyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final textScaleFactor = ref.watch(textScaleProvider);

    return MaterialApp.router(
      title: 'Apothy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      // Localization configuration
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
        Locale('fr'), // French
        Locale('zh'), // Chinese
        Locale('pt'), // Portuguese
        Locale('th'), // Thai
        Locale('vi'), // Vietnamese
      ],

      routerConfig: router,
      builder: (context, child) {
        // Apply custom text scaling based on user preference
        final scale = textScaleFactor.valueOrNull ?? 1.0;
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
