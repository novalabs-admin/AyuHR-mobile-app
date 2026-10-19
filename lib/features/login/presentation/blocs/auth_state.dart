import 'package:erp_hr/features/dashboard/domain/entities/branch.dart';
import 'package:erp_hr/features/profile/domain/entities/user_profile.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthChecking extends AuthState {}

/// Emitted immediately after login success, while the profile API is being
/// fetched. The login page shows a full-screen overlay during this phase.
class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  Authenticated({this.userProfile, this.branch});

  final UserProfile? userProfile;

  /// Pre-fetched branch — available immediately when dashboard loads.
  final Branch? branch;
}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  AuthFailure(this.message);
  final String message;
}
