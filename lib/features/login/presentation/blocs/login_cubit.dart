// ignore: unused_import
import 'package:erp_hr/core/domain/failures/failure.dart';
import 'package:erp_hr/core/storages/local_storages.dart';
import 'package:erp_hr/core/utils/enums.dart';
import 'package:erp_hr/features/login/data/models/user_model.dart';
import 'package:erp_hr/features/login/domain/usecases/login_usecase.dart';
import 'package:erp_hr/features/login/presentation/blocs/login_state.dart';
import 'package:erp_hr/shared/domain/formz/password_input.dart';
import 'package:erp_hr/shared/domain/formz/username_input.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: unused_import
import 'package:formz/formz.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._useCase, this._localStorage) : super(const LoginState()) {
    _loadSavedCredentials();
  }

  // ignore: unused_field
  final LoginUseCase _useCase;
  final LocalStorage _localStorage;

  Future<void> _loadSavedCredentials() async {
    final rememberMe = await _localStorage.getRememberMe();
    if (isClosed) return;
    if (rememberMe) {
      final savedUsername = await _localStorage.getSavedUsername();
      if (isClosed) return;
      if (savedUsername != null && savedUsername.isNotEmpty) {
        emit(state.copyWith(
          username: UsernameInput.dirty(savedUsername),
          rememberMe: true,
        ));
      }
    }
  }

  void usernameChanged(String value) {
    final username = UsernameInput.dirty(value);
    emit(state.copyWith(username: username, status: SubmitStatus.initial));
  }

  void passwordChanged(String value) {
    final password = PasswordInput.dirty(value);
    emit(state.copyWith(password: password, status: SubmitStatus.initial));
  }

  void rememberMeToggled() {
    final newValue = !state.rememberMe;
    emit(state.copyWith(rememberMe: newValue));
    _localStorage.setRememberMe(newValue);
    if (!newValue) {
      _localStorage.setSavedUsername(null);
    }
  }

  Future<void> submit() async {
    final username = UsernameInput.dirty(state.username.value);
    final password = PasswordInput.dirty(state.password.value);

    emit(
      state.copyWith(
        username: username,
        password: password,
        status: SubmitStatus.loading,
        clearError: true,
      ),
    );

    // ─────────────────────────────────────────────────────────────────────────
    // UI DEVELOPMENT MODE: Bypass remote API call
    // Simulates a quick loading state and emits a mock authenticated user.
    // ─────────────────────────────────────────────────────────────────────────
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (isClosed) return;

    final usernameValue = state.username.value.isNotEmpty
        ? state.username.value
        : 'Pathum';

    final mockUser = UserModel(
      userProfileId: 1,
      username: usernameValue,
      email: 'user@ayulanka.com',
      contactNo: '0771234567',
      firstname: 'Pathum',
      lastname: 'Fernando',
      companyId: 1,
      accessToken: 'mock_access_token',
      passwordExpiryDate: DateTime(2030, 12, 31),
      isPasswordExpiringSoon: false,
    );

    if (state.rememberMe) {
      await _localStorage.setSavedUsername(state.username.value);
    }

    emit(
      state.copyWith(
        status: SubmitStatus.success,
        user: mockUser,
        clearError: true,
      ),
    );

    /*
    // REAL BACKEND API CALL (Uncomment when backend login endpoint is ready):
    final result = await _useCase(
      LoginParams(username: username.value, password: password.value),
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        final message = switch (failure) {
          LocalFailure(:final message) => message,
          ServerFailure(:final message) => message,
        };
        emit(
          state.copyWith(
            status: SubmitStatus.failure,
            errorMessage: message,
          ),
        );
      },
      (user) {
        if (state.rememberMe) {
          _localStorage.setSavedUsername(state.username.value);
        }

        final now = DateTime.now();
        final isActuallyExpired = user.passwordExpiryDate.isBefore(now);

        if (isActuallyExpired) {
          emit(state.copyWith(
            status: SubmitStatus.passwordExpired,
            user: user,
            clearError: true,
          ));
        } else {
          emit(state.copyWith(
            status: SubmitStatus.success,
            user: user,
            clearError: true,
          ));
        }
      },
    );
    */
  }
}
