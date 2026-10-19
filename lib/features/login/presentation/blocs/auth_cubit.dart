import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_hr/core/domain/failures/failure.dart';
import 'package:erp_hr/core/storages/local_storages.dart';
import 'package:erp_hr/features/dashboard/domain/entities/branch.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_state.dart';
import 'package:erp_hr/features/profile/domain/entities/user_profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:injectable/injectable.dart';

class UserProfileParams extends Equatable {
  const UserProfileParams(this.userId);
  final int userId;
  @override
  List<Object?> get props => [userId];
}

class BranchParams extends Equatable {
  const BranchParams({required this.id});
  final int id;
  @override
  List<Object?> get props => [id];
}

@lazySingleton
class GetUserProfileUseCase {
  Future<Either<Failure, UserProfile>> call(UserProfileParams params) async {
    return Right(UserProfile(userId: params.userId, username: 'Pathum', branchIds: const [3]));
  }
}

@lazySingleton
class GetBranchUseCase {
  Future<Either<Failure, Branch>> call(BranchParams params) async {
    return Right(Branch(id: params.id, name: 'Main Branch'));
  }
}

@lazySingleton
class AuthStatusService {
  final _controller = StreamController<String?>.broadcast();
  Stream<String?> get logoutStream => _controller.stream;
  void triggerLogout(String reason) => _controller.add(reason);
}

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._localStorage,
    this._getUserProfileUseCase,
    this._getBranchUseCase,
    this._authStatusService,
  ) : super(AuthInitial()) {
    _loadToken();
    _listenToAuthStatus();
  }

  final LocalStorage _localStorage;
  final GetUserProfileUseCase _getUserProfileUseCase;
  final GetBranchUseCase _getBranchUseCase;
  final AuthStatusService _authStatusService;
  StreamSubscription<String?>? _authStatusSubscription;

  void _listenToAuthStatus() {
    _authStatusSubscription = _authStatusService.logoutStream.listen((reason) {
      setLoggedOut();
    });
  }

  Future<void> _loadToken() async {
    final token = await _localStorage.getAccessToken();
    final userId = await _localStorage.getUserId();
    if (token != null && token.isNotEmpty) {
      if (userId != null) {
        await _fetchUserProfileAndBranch(userId);
      } else {
        emit(Authenticated());
      }
    } else {
      emit(Unauthenticated());
    }
    // Dismiss the native splash screen once the auth check is complete.
    FlutterNativeSplash.remove();
  }

  Future<void> _fetchUserProfileAndBranch(int userId) async {
    final profileResult =
        await _getUserProfileUseCase(UserProfileParams(userId));

    profileResult.fold(
      (failure) {
        if (!isClosed) {
          final message = switch (failure) {
            LocalFailure(:final message) => message,
            ServerFailure(:final message) => message,
          };
          emit(AuthFailure(message));
          emit(Unauthenticated());
        }
      },
      (profile) {
        if (!isClosed && state is! Unauthenticated) {
          emit(Authenticated(userProfile: profile, branch: null));

          if (profile.branchIds.isNotEmpty) {
            _fetchBranch(profile);
          }
        }
      },
    );
  }

  Future<void> _fetchBranch(UserProfile profile) async {
    final branchResult =
        await _getBranchUseCase(BranchParams(id: profile.branchIds.first));

    branchResult.fold(
      (_) => null,
      (branch) {
        final currentState = state;
        if (!isClosed && currentState is Authenticated) {
          emit(Authenticated(userProfile: profile, branch: branch));
        }
      },
    );
  }

  void setLoggedIn({int? userId}) {
    emit(AuthLoading());
    if (userId != null) {
      _fetchUserProfileAndBranch(userId);
    } else {
      emit(Authenticated());
    }
  }

  void setLoggedOut() {
    emit(Unauthenticated());
  }

  void setUserProfile(UserProfile profile) {
    final currentState = state;
    if (currentState is Authenticated) {
      emit(Authenticated(userProfile: profile, branch: currentState.branch));
    }
  }

  @override
  Future<void> close() {
    _authStatusSubscription?.cancel();
    return super.close();
  }
}
