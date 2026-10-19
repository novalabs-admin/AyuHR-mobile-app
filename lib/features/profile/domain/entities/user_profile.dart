import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.userId,
    required this.username,
    required this.branchIds,
  });

  final int userId;
  final String username;
  final List<int> branchIds;

  @override
  List<Object?> get props => [userId, username, branchIds];
}
