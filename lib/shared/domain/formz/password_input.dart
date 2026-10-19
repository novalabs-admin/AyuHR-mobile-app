import 'package:formz/formz.dart';

enum PasswordValidationError { empty, invalid }

class PasswordInput extends FormzInput<String, PasswordValidationError> {
  const PasswordInput.pure([super.value = '']) : super.pure();
  const PasswordInput.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    return value.trim().isEmpty ? PasswordValidationError.invalid : null;
  }
}
