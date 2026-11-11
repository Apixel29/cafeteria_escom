import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:cafeteria_escom/core/errors/failures.dart';
import 'package:cafeteria_escom/domain/entities/user_entity.dart';
import 'package:cafeteria_escom/domain/repositories/auth_repository.dart';
import 'package:cafeteria_escom/domain/usecases/auth/login_usecase.dart';
import 'package:cafeteria_escom/domain/usecases/auth/register_usecase.dart';
import 'package:cafeteria_escom/domain/usecases/auth/login_with_google_usecase.dart';
import 'package:cafeteria_escom/domain/usecases/auth/send_password_reset_usecase.dart';
import 'package:cafeteria_escom/domain/usecases/auth/logout_usecase.dart';
import 'package:cafeteria_escom/domain/usecases/auth/update_profile_usecase.dart';
import 'package:cafeteria_escom/domain/usecases/auth/check_auth_status_usecase.dart';
import 'package:cafeteria_escom/presentation/viewmodels/auth_state.dart';
import 'package:cafeteria_escom/presentation/viewmodels/auth_viewmodel.dart';

class MockAuthRepository implements AuthRepository {
  bool shouldFail = false;
  UserEntity? storedUser;

  final UserEntity defaultUser = UserEntity(
    uid: 'mock_uid_123',
    nombre: 'Estudiante Mock',
    email: 'mock@escom.ipn.mx',
    avatarUrl: 'https://example.com/mock.png',
    rol: 'user',
    creadoEn: DateTime(2026, 11, 1),
  );

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    if (shouldFail) {
      return const Left(AuthFailure(message: 'Credenciales inválidas'));
    }
    storedUser = defaultUser.copyWith(email: email);
    return Right(storedUser!);
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    if (shouldFail) {
      return const Left(WeakPasswordFailure());
    }
    storedUser = defaultUser.copyWith(nombre: nombre, email: email);
    return Right(storedUser!);
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle() async {
    if (shouldFail) {
      return const Left(AuthFailure(message: 'Google login cancelado'));
    }
    storedUser = defaultUser;
    return Right(defaultUser);
  }

  @override
  Future<Either<Failure, void>> sendPasswordReset({required String email}) async {
    if (shouldFail) {
      return const Left(AuthFailure(message: 'Error al enviar'));
    }
    return const Right(null);
  }

  @override
  Future<void> logout() async {
    storedUser = null;
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String nombre,
    String? avatarUrl,
  }) async {
    if (shouldFail) {
      return const Left(ServerFailure(message: 'Error al actualizar'));
    }
    storedUser = (storedUser ?? defaultUser).copyWith(
      nombre: nombre,
      avatarUrl: avatarUrl,
    );
    return Right(storedUser!);
  }

  @override
  Future<Either<Failure, UserEntity?>> checkAuthStatus() async {
    return Right(storedUser);
  }

  @override
  UserEntity? getCurrentUser() => storedUser;

  @override
  Stream<UserEntity?> get authStateChanges => Stream.value(storedUser);
}

void main() {
  late MockAuthRepository repo;
  late AuthViewModel viewModel;

  setUp(() {
    repo = MockAuthRepository();
    viewModel = AuthViewModel(
      loginUseCase: LoginUseCase(repo),
      registerUseCase: RegisterUseCase(repo),
      loginWithGoogleUseCase: LoginWithGoogleUseCase(repo),
      sendPasswordResetUseCase: SendPasswordResetUseCase(repo),
      logoutUseCase: LogoutUseCase(repo),
      updateProfileUseCase: UpdateProfileUseCase(repo),
      checkAuthStatusUseCase: CheckAuthStatusUseCase(repo),
    );
  });

  group('AuthViewModel Tests', () {
    test('Estado inicial tras instanciar verifica status unauthenticated cuando no hay sesión previa', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      expect(viewModel.state.isUnauthenticated, true);
    });

    test('login exitoso cambia estado a authenticated con UserEntity', () async {
      final success = await viewModel.login('alumno@ipn.mx', 'password123');

      expect(success, true);
      expect(viewModel.state.isAuthenticated, true);
      expect(viewModel.state.user?.email, 'alumno@ipn.mx');
      expect(viewModel.state.errorMessage, isNull);
    });

    test('login fallido cambia estado a error y contiene mensaje explicativo', () async {
      repo.shouldFail = true;
      final success = await viewModel.login('alumno@ipn.mx', 'wrong');

      expect(success, false);
      expect(viewModel.state.hasError, true);
      expect(viewModel.state.errorMessage, 'Credenciales inválidas');
      expect(viewModel.state.user, isNull);
    });

    test('register exitoso actualiza estado a authenticated', () async {
      final success = await viewModel.register(
        nombre: 'Carlos ESCOM',
        email: 'carlos@ipn.mx',
        password: 'password123',
      );

      expect(success, true);
      expect(viewModel.state.isAuthenticated, true);
      expect(viewModel.state.user?.nombre, 'Carlos ESCOM');
    });

    test('updateProfile actualiza datos del usuario autenticado', () async {
      // Iniciar sesión primero
      await viewModel.login('alumno@ipn.mx', 'pass');

      final success = await viewModel.updateProfile(
        nombre: 'Nombre Nuevo',
        avatarUrl: 'https://new-avatar.png',
      );

      expect(success, true);
      expect(viewModel.state.user?.nombre, 'Nombre Nuevo');
      expect(viewModel.state.user?.avatarUrl, 'https://new-avatar.png');
    });

    test('logout limpia el usuario y cambia estado a unauthenticated', () async {
      await viewModel.login('alumno@ipn.mx', 'pass');
      expect(viewModel.state.isAuthenticated, true);

      await viewModel.logout();
      expect(viewModel.state.isUnauthenticated, true);
      expect(viewModel.state.user, isNull);
    });

    test('clearError limpia cualquier mensaje de error', () {
      repo.shouldFail = true;
      viewModel.login('a@b.com', 'p');
      viewModel.clearError();

      expect(viewModel.state.errorMessage, isNull);
    });
  });
}
