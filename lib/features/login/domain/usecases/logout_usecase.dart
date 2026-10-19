import 'package:dartz/dartz.dart';
import 'package:erp_hr/core/domain/failures/failure.dart';
import 'package:erp_hr/core/domain/usecases/use_case.dart';
import 'package:erp_hr/features/login/domain/repositories/login_repository.dart';
import 'package:injectable/injectable.dart';


@injectable
class LogoutUseCase implements UseCase<void, NoParams> {
  LogoutUseCase(this.repository);

  final LoginRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return repository.logout();
  }
}
