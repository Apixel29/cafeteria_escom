import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';

/// Implementación del repositorio de autenticación [AuthRepository].
///
/// Coordina la persistencia en almacenamiento seguro local ([AuthLocalDataSource])
/// y la comunicación remota ([AuthRemoteDataSource]), aplicando principios de
/// Clean Architecture y retorno funcional con [Either].
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      // Persistir token de sesión seguro y caché de usuario
      await _localDataSource.saveToken('token_${user.uid}_${DateTime.now().millisecondsSinceEpoch}');
      await _localDataSource.saveUser(user);

      return Right(user);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Error inesperado al iniciar sesión: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.register(
        nombre: nombre,
        email: email,
        password: password,
      );

      await _localDataSource.saveToken('token_${user.uid}_${DateTime.now().millisecondsSinceEpoch}');
      await _localDataSource.saveUser(user);

      return Right(user);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Error inesperado en el registro: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle() async {
    try {
      final user = await _remoteDataSource.loginWithGoogle();

      await _localDataSource.saveToken('token_google_${user.uid}');
      await _localDataSource.saveUser(user);

      return Right(user);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Error en Google Sign-In: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordReset({required String email}) async {
    try {
      await _remoteDataSource.sendPasswordReset(email: email);
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Error al enviar correo de recuperación: $e'));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } finally {
      await _localDataSource.clearAll();
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String nombre,
    String? avatarUrl,
  }) async {
    try {
      final cached = await _localDataSource.getUser();
      final uid = cached?.uid ?? _remoteDataSource.getCurrentUser()?.uid ?? 'unknown';

      final updated = await _remoteDataSource.updateProfile(
        uid: uid,
        nombre: nombre,
        avatarUrl: avatarUrl,
      );

      await _localDataSource.saveUser(updated);
      return Right(updated);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Error al actualizar perfil: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> checkAuthStatus() async {
    try {
      final token = await _localDataSource.getToken();
      if (token == null || token.isEmpty) {
        return const Right(null);
      }

      final cachedUser = await _localDataSource.getUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }

      final remoteUser = _remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        await _localDataSource.saveUser(remoteUser);
        return Right(remoteUser);
      }

      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Error al verificar sesión: $e'));
    }
  }

  @override
  UserEntity? getCurrentUser() {
    return _remoteDataSource.getCurrentUser();
  }

  @override
  Stream<UserEntity?> get authStateChanges => _remoteDataSource.authStateChanges;
}
