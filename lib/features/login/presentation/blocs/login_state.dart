import 'package:equatable/equatable.dart';
import 'package:erp_hr/core/utils/enums.dart';
import 'package:formz/formz.dart';
import 'package:erp_hr/features/login/domain/entities/user.dart';
import 'package:erp_hr/shared/domain/formz/password_input.dart';
import 'package:erp_hr/shared/domain/formz/username_input.dart';

class LoginState extends Equatable {
  const LoginState({
    this.username = const UsernameInput.pure(),
    this.password = const PasswordInput.pure(),
    this.rememberMe = false,
    this.status = SubmitStatus.initial,
    this.errorMessage,
    this.user,
  });

  final UsernameInput username;
  final PasswordInput password;
  final bool rememberMe;
  final SubmitStatus status;
  final String? errorMessage;
  final User? user;

  bool get isValid => Formz.validate([username, password]);

  LoginState copyWith({
    User? user,
    UsernameInput? username,
    PasswordInput? password,
    bool? rememberMe,
    SubmitStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
        username,
        password,
        rememberMe,
        status,
        errorMessage,
        user,
      ];
}
