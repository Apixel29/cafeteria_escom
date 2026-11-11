import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:cafeteria_escom/core/errors/failures.dart';
import 'package:cafeteria_escom/domain/entities/user_entity.dart';
import 'package:cafeteria_escom/domain/repositories/auth_repository.dart';
import 'package:cafeteria_escom/domain/usecases/auth/login_usecase.dart';
import 'package:cafeteria_escom/domain/usecases/auth/register_usecase.dart';
import 'package:cafeteria_escom/domain/usecases/auth/update_profile_usecase.dart';
import 'package:cafeteria_escom/domain/usecases/auth/send_password_reset_usecase.dart';
import 'package:cafeteria_escom/domain/usecases/auth/logout_usecase.dart';

class FakeAuthRepository implements AuthRepository {
  bool shouldReturnError = false;
  final UserEntity testUser = UserEntity(
    uid: 'user_fake_001',
    nombre: 'Usuario Prueba',
    email: 'prueba@alumno.ipn.mx',
    avatarUrl: 'https://example.com/avatar.png',
    rol: 'user',
    creadoEn: DateTime(2026, 11, 1),
  );

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    if (shouldReturnError) {
      return const Left(AuthFailure(message: 'Credenciales inválidas'));
    }
    return Right(testUser);
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    if (shouldReturnError) {
      return const Left(EmailAlreadyInUseFailure());
    }
    return Right(testUser.copyWith(nombre: nombre, email: email));
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle() async {
    if (shouldReturnError) {
      return const Left(AuthFailure(message: 'Cancelado'));
    }
    return Right(testUser);
  }

  @override
  Future<Either<Failure, void>> sendPasswordReset({required String email}) async {
    if (shouldReturnError) {
      return const Left(AuthFailure(message: 'Email no encontrado'));
    }
    return const Right(null);
  }

  @override
  Future<void> logout() async {}

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String nombre,
    String? avatarUrl,
  }) async {
    if (shouldReturnError) {
      return const Left(ServerFailure(message: 'Error al actualizar'));
    }
    return Right(testUser.copyWith(nombre: nombre, avatarUrl: avatarUrl));
  }

  @override
  Future<Either<Failure, UserEntity?>> checkAuthStatus() async {
    return Right(testUser);
  }

  @override
  UserEntity? getCurrentUser() => testUser;

  @override
  Stream<UserEntity?> get authStateChanges => Stream.value(testUser);
}

void main() {
  late FakeAuthRepository repository;

  setUp(() {
    repository = FakeAuthRepository();
  });

  group('Auth UseCases Tests', () {
    test('LoginUseCase retorna UserEntity en éxito', () async {
      final useCase = LoginUseCase(repository);
      final result = await useCase(email: 'prueba@alumno.ipn.mx', password: 'password123');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('No debería retornar Failure'),
        (user) => expect(user.email, 'prueba@alumno.ipn.mx'),
      );
    });

    test('LoginUseCase retorna Failure cuando las credenciales fallan', () async {
      repository.shouldReturnError = true;
      final useCase = LoginUseCase(repository);
      final result = await useCase(email: 'prueba@alumno.ipn.mx', password: 'wrong');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'Credenciales inválidas'),
        (_) => fail('Debería retornar Failure'),
      );
    });

    test('RegisterUseCase registra usuario y retorna UserEntity', () async {
      final useCase = RegisterUseCase(repository);
      final result = await useCase(
        nombre: 'Nuevo Alumno',
        email: 'nuevo@ipn.mx',
        password: 'password123',
      );

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('No debería retornar Failure'),
        (user) => expect(user.nombre, 'Nuevo Alumno'),
      );
    });

    test('UpdateProfileUseCase actualiza nombre y avatar', () async {
      final useCase = UpdateProfileUseCase(repository);
      final result = await useCase(
        nombre: 'Nombre Editado',
        avatarUrl: 'https://avatar.nuevo.png',
      );

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('No debería retornar Failure'),
        (user) {
          expect(user.nombre, 'Nombre Editado');
          expect(user.avatarUrl, 'https://avatar.nuevo.png');
        },
      );
    });

    test('SendPasswordResetUseCase despacha solicitud de recuperación', () async {
      final useCase = SendPasswordResetUseCase(repository);
      final result = await useCase(email: 'prueba@alumno.ipn.mx');

      expect(result.isRight(), true);
    });

    test('LogoutUseCase completa correctamente', () async {
      final useCase = LogoutUseCase(repository);
      await expectLater(useCase(), completes);
    });
  });
}
