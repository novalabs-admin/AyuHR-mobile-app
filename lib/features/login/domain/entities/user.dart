import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.userProfileId,
    required this.username,
    required this.email,
    required this.contactNo,
    required this.firstname,
    required this.lastname,
    required this.companyId,
    required this.accessToken,
    required this.passwordExpiryDate,
    required this.isPasswordExpiringSoon,
  });

  final int userProfileId;
  final String username;
  final String email;
  final String contactNo;
  final String firstname;
  final String lastname;
  final int companyId;
  final String accessToken;
  final DateTime passwordExpiryDate;
  final bool isPasswordExpiringSoon;

  @override
  List<Object?> get props => [
        userProfileId,
        username,
        email,
        contactNo,
        firstname,
        lastname,
        companyId,
        accessToken,
        passwordExpiryDate,
        isPasswordExpiringSoon,
      ];
}
