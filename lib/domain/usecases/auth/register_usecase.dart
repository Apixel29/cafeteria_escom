import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Caso de uso: Registro de nuevo usuario en el sistema.
class RegisterUseCase {
  final AuthRepository _repository;

  const RegisterUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call({
    required String nombre,
    required String email,
    required String password,
  }) {
    return _repository.register(
      nombre: nombre.trim(),
      email: email.trim(),
      password: password,
    );
  }
}
