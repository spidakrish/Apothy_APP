import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/mirror/presentation/mirror_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import 'navigation_shell.dart';

/// Route paths as constants to avoid typos
class AppRoutes {
  AppRoutes._();

  // Auth routes
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';

  // Main app routes
  static const String mirror = '/mirror';
  static const String history = '/history';
  static const String chat = '/chat';
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';
}

/// Navigator keys for each shell branch
/// Defined at module level to prevent rebuilds
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _mirrorNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'mirror');
final _historyNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'history');
final _chatNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'chat');
final _dashboardNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final _settingsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'settings');

/// Notifier that listens to auth state and triggers router refresh
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(this._ref) {
    _ref.listen(authProvider, (previous, next) {
      debugPrint('GoRouterRefreshNotifier: auth state changed, notifying listeners');
      debugPrint('  Previous: ${previous?.valueOrNull?.status}');
      debugPrint('  Next: ${next.valueOrNull?.status}');
      notifyListeners();
    });
  }

  final Ref _ref;
}

/// Provider for the router refresh notifier
final goRouterRefreshNotifierProvider = Provider<GoRouterRefreshNotifier>(
  (ref) => GoRouterRefreshNotifier(ref),
);

/// Provider for the app router
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(goRouterRefreshNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.chat,
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);

      debugPrint('Router redirect: currentPath=${state.matchedLocation}, authState=${authState.valueOrNull?.status}, isLoading=${authState.isLoading}');

      // While loading auth state, don't redirect
      if (authState.isLoading) {
        debugPrint('Router redirect: loading, no redirect');
        return null;
      }

      final authData = authState.valueOrNull;
      if (authData == null) {
        debugPrint('Router redirect: no auth data, no redirect');
        return null;
      }

      final isAuthenticated = authData.status == AuthStatus.authenticated;
      final needsOnboarding = authData.status == AuthStatus.needsOnboarding;
      final currentPath = state.matchedLocation;

      // Define login/signup routes (separate from onboarding)
      final loginRoutes = [AppRoutes.login, AppRoutes.signup];
      final isOnLoginRoute = loginRoutes.contains(currentPath);
      final isOnOnboarding = currentPath == AppRoutes.onboarding;

      // If user needs onboarding, redirect to onboarding
      if (needsOnboarding && !isOnOnboarding) {
        debugPrint('Router redirect: needs onboarding -> /onboarding');
        return AppRoutes.onboarding;
      }

      // If user completed onboarding but not authenticated, go to login
      // (This handles the case when user finishes onboarding)
      if (!isAuthenticated && !needsOnboarding && !isOnLoginRoute) {
        debugPrint('Router redirect: unauthenticated -> /login');
        return AppRoutes.login;
      }

      // If user is authenticated and on any auth screen, go to main app
      if (isAuthenticated && (isOnLoginRoute || isOnOnboarding)) {
        debugPrint('Router redirect: authenticated -> /chat');
        return AppRoutes.chat;
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Auth routes (outside shell)
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => const MaterialPage(
          child: OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => const MaterialPage(
          child: LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) => const MaterialPage(
          child: SignUpScreen(),
        ),
      ),

      // Main app shell with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Mirror
          StatefulShellBranch(
            navigatorKey: _mirrorNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.mirror,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: MirrorScreen(),
                ),
              ),
            ],
          ),
          // Branch 1: History
          StatefulShellBranch(
            navigatorKey: _historyNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.history,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HistoryScreen(),
                ),
              ),
            ],
          ),
          // Branch 2: Chat (default/center tab)
          StatefulShellBranch(
            navigatorKey: _chatNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.chat,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ChatScreen(),
                ),
              ),
            ],
          ),
          // Branch 3: Dashboard
          StatefulShellBranch(
            navigatorKey: _dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DashboardScreen(),
                ),
              ),
            ],
          ),
          // Branch 4: Settings
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Legacy router for backward compatibility
/// Use appRouterProvider instead for Riverpod integration
@Deprecated('Use appRouterProvider instead')
final appRouter = GoRouter(
  initialLocation: AppRoutes.chat,
  navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'legacy_root'),
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: AppRoutes.chat,
      builder: (context, state) => const ChatScreen(),
    ),
  ],
);
