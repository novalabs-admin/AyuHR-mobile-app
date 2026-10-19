import 'package:equatable/equatable.dart';

enum LogoutStatus { initial, loading, success, failure }

class LogoutState extends Equatable {
  const LogoutState({this.status = LogoutStatus.initial, this.errorMessage});

  final LogoutStatus status;
  final String? errorMessage;

  LogoutState copyWith({
    LogoutStatus? status,
    String? errorMessage,
  }) {
    return LogoutState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
