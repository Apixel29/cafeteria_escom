import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Caso de uso: Autenticación mediante proveedor Google OAuth.
class LoginWithGoogleUseCase {
  final AuthRepository _repository;

  const LoginWithGoogleUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call() {
    return _repository.loginWithGoogle();
  }
}
