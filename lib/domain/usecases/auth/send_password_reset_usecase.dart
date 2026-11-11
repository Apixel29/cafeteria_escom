import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

/// Caso de uso: Envío de correo de recuperación de contraseña olvidada (RF1).
class SendPasswordResetUseCase {
  final AuthRepository _repository;

  const SendPasswordResetUseCase(this._repository);

  Future<Either<Failure, void>> call({required String email}) {
    return _repository.sendPasswordReset(email: email.trim());
  }
}
