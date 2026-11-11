import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Caso de uso: Obtener el usuario autenticado en la sesión actual.
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  const GetCurrentUserUseCase(this._repository);

  UserEntity? call() {
    return _repository.getCurrentUser();
  }
}
