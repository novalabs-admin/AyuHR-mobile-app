import 'package:erp_hr/features/login/data/models/login_data_model.dart';

class LoginResponseModel {
  final LoginDataModel data;
  final int status;
  final String message;

  LoginResponseModel({
    required this.data,
    required this.status,
    required this.message,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      data: LoginDataModel.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
      status: json['status'] as int,
      message: json['message'] as String,
    );
  }
}