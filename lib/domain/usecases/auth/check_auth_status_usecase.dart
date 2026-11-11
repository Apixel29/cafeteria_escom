import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Caso de uso: Verificación de sesión persistida al iniciar la app.
class CheckAuthStatusUseCase {
  final AuthRepository _repository;

  const CheckAuthStatusUseCase(this._repository);

  Future<Either<Failure, UserEntity?>> call() {
    return _repository.checkAuthStatus();
  }
}
