import 'package:erp_hr/core/domain/usecases/use_case.dart';
import 'package:erp_hr/features/login/domain/usecases/logout_usecase.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_cubit.dart';
import 'package:erp_hr/features/login/presentation/blocs/logout_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';


@injectable
class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit(this._logoutUseCase, this._authCubit) : super(const LogoutState());

  final LogoutUseCase _logoutUseCase;
  final AuthCubit _authCubit;

  Future<void> logout() async {
    emit(state.copyWith(status: LogoutStatus.loading));

    // Forceful Logout: Clear local state and navigate away immediately.
    // We don't wait for the API because it might fail if the token is already expired.
    _authCubit.setLoggedOut();

    // Fire and forget the backend logout
    await _logoutUseCase(NoParams());

    if (isClosed) return;
    emit(state.copyWith(status: LogoutStatus.success));
  }
}
