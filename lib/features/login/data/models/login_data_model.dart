import 'package:erp_hr/features/login/data/models/user_model.dart';

class LoginDataModel {

  LoginDataModel({
    required this.result,
    required this.handShake,
  });

  factory LoginDataModel.fromJson(Map<String, dynamic> json) {
    return LoginDataModel(
      result: UserModel.fromJson(
        json['result'] as Map<String, dynamic>,
      ),
      handShake: json['handShake'] as bool,
    );
  }
  final UserModel result;
  final bool handShake;
}