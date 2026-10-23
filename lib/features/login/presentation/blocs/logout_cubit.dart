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
    _authCubit.setLoggedOut();

    // Fire and forget the backend logout with safe timeout for presentation mode
    try {
      await _logoutUseCase(NoParams()).timeout(const Duration(milliseconds: 200));
    } catch (_) {
      // Ignored for presentation mode
    }

    if (isClosed) return;
    emit(state.copyWith(status: LogoutStatus.success));
  }
}
