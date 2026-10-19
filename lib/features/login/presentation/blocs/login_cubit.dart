import 'package:erp_hr/core/domain/failures/failure.dart';
import 'package:erp_hr/core/utils/enums.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:injectable/injectable.dart';
import 'package:erp_hr/core/storages/local_storages.dart';
import 'package:erp_hr/features/login/domain/usecases/login_usecase.dart';
import 'package:erp_hr/features/login/presentation/blocs/login_state.dart';
import 'package:erp_hr/shared/domain/formz/password_input.dart';
import 'package:erp_hr/shared/domain/formz/username_input.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._useCase, this._localStorage) : super(const LoginState()) {
    _loadSavedCredentials();
  }

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
    final isValid = Formz.validate([username, password]);

    emit(
      state.copyWith(
        username: username,
        password: password,
        status: isValid ? SubmitStatus.loading : SubmitStatus.initial,
        clearError: true,
      ),
    );

    if (!isValid) return;

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
        // Save username if "Remember Me" is checked
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
  }
}
