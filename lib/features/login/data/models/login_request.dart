class LoginRequest {
  LoginRequest({
    required this.userName,
    required this.password,
    required this.permissionId
  });
  final String userName;
  final String password;
  final int permissionId;

  Map<String, dynamic> toJson() {
    return {
      'UserName': userName,
      'password': password,
      'permissionId':permissionId
    };
  }
}
