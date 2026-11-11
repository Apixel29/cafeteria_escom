import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Contrato que define todas las operaciones de autenticación.
///
/// La capa de dominio depende de esta abstracción, no de la
/// implementación concreta (Firebase), respetando el principio
/// de inversión de dependencias (DIP de SOLID).
abstract class AuthRepository {
  /// Inicia sesión con correo y contraseña.
  ///
  /// Retorna [UserEntity] si es exitoso, o un [Failure] tipado si falla.
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario.
  Future<Either<Failure, UserEntity>> register({
    required String nombre,
    required String email,
    required String password,
  });

  /// Inicia sesión con la cuenta de Google del dispositivo.
  Future<Either<Failure, UserEntity>> loginWithGoogle();

  /// Envía un correo de recuperación de contraseña.
  Future<Either<Failure, void>> sendPasswordReset({required String email});

  /// Cierra la sesión del usuario actual.
  Future<void> logout();

  /// Actualiza los datos del perfil del usuario (nombre y/o avatarUrl).
  Future<Either<Failure, UserEntity>> updateProfile({
    required String nombre,
    String? avatarUrl,
  });

  /// Verifica el estado de autenticación actual consultando el almacenamiento seguro.
  Future<Either<Failure, UserEntity?>> checkAuthStatus();

  /// Retorna el usuario actualmente autenticado, o null si no hay sesión.
  UserEntity? getCurrentUser();

  /// Stream que emite cambios en el estado de autenticación.
  Stream<UserEntity?> get authStateChanges;
}
