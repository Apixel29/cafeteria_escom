import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/login_with_google_usecase.dart';
import '../../domain/usecases/auth/send_password_reset_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/update_profile_usecase.dart';
import '../../domain/usecases/auth/check_auth_status_usecase.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'auth_state.dart';

// ── Inyección de dependencias (Riverpod Providers) ───────────────

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return const AuthLocalDataSourceImpl();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final local = ref.watch(authLocalDataSourceProvider);
  final remote = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: remote, localDataSource: local);
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final loginWithGoogleUseCaseProvider = Provider<LoginWithGoogleUseCase>((ref) {
  return LoginWithGoogleUseCase(ref.watch(authRepositoryProvider));
});

final sendPasswordResetUseCaseProvider = Provider<SendPasswordResetUseCase>((ref) {
  return SendPasswordResetUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(authRepositoryProvider));
});

final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>((ref) {
  return CheckAuthStatusUseCase(ref.watch(authRepositoryProvider));
});

// ── StateNotifierProvider ───────────────────────────────────────

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(
    loginUseCase: ref.watch(loginUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    loginWithGoogleUseCase: ref.watch(loginWithGoogleUseCaseProvider),
    sendPasswordResetUseCase: ref.watch(sendPasswordResetUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    updateProfileUseCase: ref.watch(updateProfileUseCaseProvider),
    checkAuthStatusUseCase: ref.watch(checkAuthStatusUseCaseProvider),
  );
});

// ── ViewModel (StateNotifier) ───────────────────────────────────

class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;
  final SendPasswordResetUseCase _sendPasswordResetUseCase;
  final LogoutUseCase _logoutUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;

  AuthViewModel({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LoginWithGoogleUseCase loginWithGoogleUseCase,
    required SendPasswordResetUseCase sendPasswordResetUseCase,
    required LogoutUseCase logoutUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _loginWithGoogleUseCase = loginWithGoogleUseCase,
        _sendPasswordResetUseCase = sendPasswordResetUseCase,
        _logoutUseCase = logoutUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _checkAuthStatusUseCase = checkAuthStatusUseCase,
        super(const AuthState()) {
    // Al instanciar, verifica si existe sesión previa persistida
    checkStatus();
  }

  /// Verifica si hay un usuario autenticado previamente con token activo
  Future<void> checkStatus() async {
    final result = await _checkAuthStatusUseCase();
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.unauthenticated),
      (user) {
        if (user != null) {
          state = state.copyWith(status: AuthStatus.authenticated, user: user);
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      },
    );
  }

  /// Inicia sesión con correo y contraseña
  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    final result = await _loginUseCase(email: email, password: password);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        );
        return true;
      },
    );
  }

  /// Registra un nuevo usuario
  Future<bool> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    final result = await _registerUseCase(
      nombre: nombre,
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        );
        return true;
      },
    );
  }

  /// Inicia sesión con Google OAuth
  Future<bool> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    final result = await _loginWithGoogleUseCase();

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        );
        return true;
      },
    );
  }

  /// Solicita el restablecimiento de contraseña
  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    final result = await _sendPasswordResetUseCase(email: email);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          status: state.user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
          clearError: true,
        );
        return true;
      },
    );
  }

  /// Actualiza los datos del perfil (nombre y/o foto avatar)
  Future<bool> updateProfile({
    required String nombre,
    String? avatarUrl,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    final result = await _updateProfileUseCase(
      nombre: nombre,
      avatarUrl: avatarUrl,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedUser) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: updatedUser,
          clearError: true,
        );
        return true;
      },
    );
  }

  /// Cierra la sesión activa y borra credenciales de almacenamiento seguro
  Future<void> logout() async {
    await _logoutUseCase();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Limpia cualquier mensaje de error presente en el estado
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
