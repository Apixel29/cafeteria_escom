import 'package:equatable/equatable.dart';

/// Clase base para todos los errores de la capa de dominio.
///
/// Usando el patrón [Either<Failure, T>] de `dartz`,
/// los repositorios retornan un [Failure] en lugar de lanzar excepciones,
/// lo que hace el manejo de errores explícito y seguro.
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

// ── Fallas de autenticación ───────────────────────────────

/// Credenciales incorrectas o usuario no encontrado.
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

/// El correo ya está registrado en el sistema.
class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure()
      : super(message: 'Este correo ya está registrado. Intenta iniciar sesión.');
}

/// La contraseña no cumple los requisitos de seguridad.
class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure()
      : super(message: 'La contraseña debe tener al menos 8 caracteres.');
}

/// El token de sesión expiró o es inválido.
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure()
      : super(message: 'Tu sesión ha expirado. Por favor inicia sesión nuevamente.');
}

// ── Fallas de red ─────────────────────────────────────────

/// No hay conexión a internet disponible.
class NetworkFailure extends Failure {
  const NetworkFailure()
      : super(message: 'Sin conexión a internet. Verifica tu red.');
}

/// El servidor respondió con un error (4xx / 5xx).
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// La solicitud tardó demasiado tiempo.
class TimeoutFailure extends Failure {
  const TimeoutFailure()
      : super(message: 'La solicitud tardó demasiado. Intenta de nuevo.');
}

// ── Fallas de base de datos local ─────────────────────────

/// Error al leer o escribir en SQLite.
class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure({required super.message});
}

// ── Fallas de negocio ─────────────────────────────────────

/// El producto solicitado ya no tiene stock disponible.
class OutOfStockFailure extends Failure {
  const OutOfStockFailure({required String productName})
      : super(message: 'El producto "$productName" está agotado.');
}

/// El pedido no puede ser cancelado en su estado actual.
class CannotCancelOrderFailure extends Failure {
  const CannotCancelOrderFailure()
      : super(message: 'Este pedido ya no puede ser cancelado.');
}

/// El pago fue rechazado por la pasarela simulada.
class PaymentDeclinedFailure extends Failure {
  const PaymentDeclinedFailure()
      : super(message: 'Pago rechazado. Verifica los datos de tu tarjeta.');
}

/// El carrito está vacío y no se puede proceder al pago.
class EmptyCartFailure extends Failure {
  const EmptyCartFailure()
      : super(message: 'Agrega productos al carrito antes de continuar.');
}

// ── Falla genérica ────────────────────────────────────────

/// Error desconocido no clasificado.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message = 'Ocurrió un error inesperado.'});
}
