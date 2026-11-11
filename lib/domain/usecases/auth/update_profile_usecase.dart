import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Caso de uso: Actualización de datos del perfil de usuario y avatar (RF1).
class UpdateProfileUseCase {
  final AuthRepository _repository;

  const UpdateProfileUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call({
    required String nombre,
    String? avatarUrl,
  }) {
    return _repository.updateProfile(
      nombre: nombre.trim(),
      avatarUrl: avatarUrl,
    );
  }
}
