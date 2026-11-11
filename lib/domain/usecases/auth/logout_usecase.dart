import '../../repositories/auth_repository.dart';

/// Caso de uso: Cierre de sesión y revocación/limpieza de tokens locales.
class LogoutUseCase {
  final AuthRepository _repository;

  const LogoutUseCase(this._repository);

  Future<void> call() {
    return _repository.logout();
  }
}
