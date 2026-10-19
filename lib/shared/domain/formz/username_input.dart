import 'package:formz/formz.dart';

enum UsernameValidationError { empty }

class UsernameInput extends FormzInput<String, UsernameValidationError> {
  const UsernameInput.pure([super.value = '']) : super.pure();
  const UsernameInput.dirty([super.value = '']) : super.dirty();

  @override
  UsernameValidationError? validator(String value) {
    return value.trim().isEmpty ? UsernameValidationError.empty : null;
  }
}
