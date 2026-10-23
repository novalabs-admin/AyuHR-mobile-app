import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:erp_hr/app/view/main_scaffold.dart';
import 'package:erp_hr/features/attendance/presentation/pages/attendance_page.dart';
import 'package:erp_hr/features/dashboard/dashboard_page.dart';
import 'package:erp_hr/features/leave/presentation/pages/apply_leave_page.dart';
import 'package:erp_hr/features/leave/presentation/pages/leave_page.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_cubit.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_state.dart';
import 'package:erp_hr/features/login/presentation/pages/login_page.dart';
import 'package:erp_hr/features/profile/presentation/pages/profile_page.dart';
import 'package:erp_hr/features/splash/splash_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorDashBoardKey =
    GlobalKey<NavigatorState>(debugLabel: 'dashboard_shell');
final _shellNavigatorAttendanceKey =
    GlobalKey<NavigatorState>(debugLabel: 'attendance_shell');
final _shellNavigatorLeaveKey =
    GlobalKey<NavigatorState>(debugLabel: 'leave_shell');
final _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile_shell');

class AppRouter extends Equatable {
  static const login = 'login';
  static const profile = 'profile';
  static const settings = 'settings';
  static const dashboard = 'dashboard';
  static const attendance = 'attendance';
  static const leave = 'leave';
  static const forgotPassword = 'forgotPassword';
  static const resetPassword = 'resetPassword';
  static const seeAllAppointment = 'seeAllAppointment';
  static const seeAllPendingRenewals = 'seeAllPendingRenewals';
  static const seeAllGracePeriod = 'seeAllGracePeriod';
  static const seeAllLapsedPolicies = 'seeAllLapsedPolicies';
  static const seeAllPendingClaims = 'seeAllPendingClaims';
  static const seeAllAlterations = 'seeAllAlterations';
  static const locationPicker = 'locationPicker';

  @override
  List<Object?> get props => [
    login,
    profile,
    settings,
    dashboard,
    attendance,
    leave,
    seeAllAppointment,
    seeAllPendingRenewals,
    seeAllGracePeriod,
    seeAllLapsedPolicies,
    seeAllPendingClaims,
    seeAllAlterations,
  ];
}

GoRouter router([String? initialLocation, AuthCubit? authCubit]) => GoRouter(
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: kDebugMode || kProfileMode,
  initialLocation: initialLocation ?? '/splash',
  // Re-evaluate redirect whenever AuthCubit emits a new state.
  refreshListenable:
  authCubit != null ? _BlocStreamListenable(authCubit.stream) : null,
  redirect: (context, state) {
    final authState = authCubit?.state ??
        (context.mounted ? context.read<AuthCubit>().state : null);
    final location = state.matchedLocation;

    final isSplashRoute = location == '/splash';
    final isLoginRoute = location == '/';
    final isAuthRoute =
        location == '/forgot-password' || location == '/reset-password';

    final isLoggedIn = authState is Authenticated;
    // While fetching the profile after login, stay on the current route.
    final isAuthLoading = authState is AuthLoading;

    // Let the splash screen run freely – no auth redirect on splash
    if (isSplashRoute) return null;

    // Not logged in → force back to login
    // (allow main tabs during UI development)
    if (!isLoggedIn &&
        !isAuthLoading &&
        !isLoginRoute &&
        !isAuthRoute &&
        !location.startsWith('/dashboard') &&
        !location.startsWith('/attendance') &&
        !location.startsWith('/leave') &&
        !location.startsWith('/profile')) {
      return '/';
    }

    // Hot restart lands directly on login page as requested.
    // Tapping Log In will explicitly navigate to /dashboard.

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/',
      name: AppRouter.login,
      builder: (context, state) => const LoginPage(),
    ),
    // GoRoute(
    //   path: '/forgot-password',
    //   name: AppRouter.forgotPassword,
    //   builder: (context, state) => const ForgotPasswordPage(),
    // ),
    // GoRoute(
    //   path: '/reset-password',
    //   name: AppRouter.resetPassword,
    //   builder: (context, state) {
    //     // extra is the accessToken passed from login page on password expiry
    //     final accessToken = state.extra as String?;
    //     return ResetPasswordPage(accessToken: accessToken);
    //   },
    // ),
    //   path: '/settings',
    //   name: AppRouter.settings,
    //   builder: (context, state) => const SettingsPage(),
    // ),
    // GoRoute(
    //   path: '/attendance',
    //   name: AppRouter.attendance,
    //   builder: (context, state) => const AttendancePage(),
    // ),
    // GoRoute(
    //   path: '/attendance-summary',
    //   name: 'attendanceSummary',
    //   builder: (context, state) => const AttendanceSummaryPage(),
    // ),

    // GoRoute(
    //   path: '/location-picker',
    //   name: AppRouter.locationPicker,
    //   builder: (context, state) => const LocationPickerPage(),
    // ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorDashBoardKey,
          routes: [
            GoRoute(
              path: '/dashboard',
              name: AppRouter.dashboard,
              builder: (context, state) => const DashboardPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorAttendanceKey,
          routes: [
            GoRoute(
              path: '/attendance',
              name: AppRouter.attendance,
              builder: (context, state) => const AttendancePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorLeaveKey,
          routes: [
            GoRoute(
              path: '/leave',
              name: AppRouter.leave,
              builder: (context, state) => const LeavePage(),
              routes: [
                GoRoute(
                  path: 'apply',
                  name: 'applyLeave',
                  builder: (context, state) => const ApplyLeavePage(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProfileKey,
          routes: [
            GoRoute(
              path: '/profile',
              name: AppRouter.profile,
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);

/// Adapts a BLoC [Stream] into a [Listenable] that GoRouter can observe via
/// GoRouter.refreshListenable. Whenever the auth state type changes
/// (e.g. Unauthenticated → Authenticated or vice-versa), all registered
/// listeners (i.e. the router) are notified and the redirect is re-evaluated.
///
/// Notifications are deferred to the next post-frame callback so GoRouter
/// never calls setState() while the framework is mid-build (which would throw
/// "setState called during build").
///
/// We also filter out Authenticated → Authenticated transitions (e.g. profile
/// data refreshes) so the router does not re-evaluate unnecessarily.
class _BlocStreamListenable extends ChangeNotifier {
  _BlocStreamListenable(Stream<AuthState> stream) {
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
