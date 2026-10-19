import 'package:erp_hr/features/login/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.userProfileId,
    required super.username,
    required super.email,
    required super.contactNo,
    required super.firstname,
    required super.lastname,
    required super.companyId,
    required super.accessToken,
    required super.passwordExpiryDate,
    required super.isPasswordExpiringSoon,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // API returns the user info inside result. Let's parse result.
    final result = json['result'] as Map<String, dynamic>? ?? json;
    final userId = result['userId'] as int? ?? 0;
    
    return UserModel(
      userProfileId: userId,
      username: result['username'] as String? ?? '',
      email: result['email'] as String? ?? '',
      contactNo: result['contactNo'] as String? ?? '',
      firstname: result['firstname'] as String? ?? '',
      lastname: result['lastname'] as String? ?? '',
      companyId: result['companyId'] as int? ?? 0,
      accessToken: 'dummy_access_token_for_$userId',
      passwordExpiryDate: DateTime(2030, 12, 31),
      isPasswordExpiringSoon: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userProfileId,
      'username': username,
      'email': email,
      'contactNo': contactNo,
      'firstname': firstname,
      'lastname': lastname,
      'companyId': companyId,
    };
  }
}
