import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:erp_hr/app/view/main_scaffold.dart';
import 'package:erp_hr/features/dashboard/dashboard_page.dart';
import 'package:erp_hr/features/leads/presentation/create_lead_page.dart';
import 'package:erp_hr/features/leads/presentation/lead_list_card.dart';
import 'package:erp_hr/features/leads/presentation/leads_page.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_cubit.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_state.dart';
import 'package:erp_hr/features/login/presentation/pages/login_page.dart';
import 'package:erp_hr/features/profile/presentation/pages/profile_page.dart';
import 'package:erp_hr/features/quotations/create_quotation.dart';
import 'package:erp_hr/features/quotations/quotations_page.dart';
import 'package:erp_hr/features/splash/splash_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorDashBoardKey =
GlobalKey<NavigatorState>(debugLabel: 'dashboard_shell');
final _shellNavigatorLeadsKey =
GlobalKey<NavigatorState>(debugLabel: 'leads_shell');
final _shellNavigatorQuotationsKey =
GlobalKey<NavigatorState>(debugLabel: 'quotations_shell');


class AppRouter extends Equatable {
  static const login = 'login';
  static const profile = 'profile';
  static const settings = 'settings';
  static const dashboard = 'dashboard';
  static const leads = 'leads';
  static const quotations = 'quotations';
  static const proposals = 'proposals';
  static const myList = 'myList';
  static const createLead = 'createLead';
  static const createQuotation = 'createQuotation';
  static const quotationVersions = 'quotationVersions';
  static const forgotPassword = 'forgotPassword';
  static const resetPassword = 'resetPassword';
  static const attendance = 'attendance';
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
    leads,
    quotations,
    proposals,
    myList,
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
    final authState = context.read<AuthCubit>().state;
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
    if (!isLoggedIn && !isAuthLoading && !isLoginRoute && !isAuthRoute) {
      return '/';
    }

    // Logged in → redirect away from login page to dashboard
    if (isLoggedIn && isLoginRoute) {
      return '/dashboard';
    }

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
    GoRoute(
      path: '/profile',
      name: AppRouter.profile,
      builder: (context, state) => const ProfilePage(),
    ),
    // GoRoute(
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
          navigatorKey: _shellNavigatorLeadsKey,
          routes: [
            GoRoute(
              path: '/leads',
              name: AppRouter.leads,
              builder: (context, state) => const LeadsPage(),
              routes: [
                GoRoute(
                  path: 'create',
                  name: AppRouter.createLead,
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>?;
                    return CreateLeadPage(initialData: extra);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorQuotationsKey,
          routes: [
            GoRoute(
              path: '/quotations',
              name: AppRouter.quotations,
              builder: (context, state) => const QuotationsPage(),
              routes: [
                GoRoute(
                  path: 'create',
                  name: AppRouter.createQuotation,
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>?;
                    final lead = extra?['lead'] as MockLead?;
                    return QuotationFormPage();
                  },
                ),
              ],
            ),
          ],
        ),
        // StatefulShellBranch(
        //   navigatorKey: _shellNavigatorProposalsKey,
        //   routes: [
        //     GoRoute(
        //       path: '/proposals',
        //       name: AppRouter.proposals,
        //       builder: (context, state) => const ProposalsPage(),
        //     ),
        //   ],
        // ),
        // StatefulShellBranch(
        //   navigatorKey: _shellNavigatorMyListKey,
        //   routes: [
        //     GoRoute(
        //       path: '/mylist',
        //       name: AppRouter.myList,
        //       builder: (context, state) => const MyListPage(),
        //     ),
        //   ],
        // ),
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
