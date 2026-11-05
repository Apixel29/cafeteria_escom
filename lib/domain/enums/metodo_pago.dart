/// Métodos de pago disponibles en la aplicación.
/// Todos son simulados (no se integran APIs de pago reales).
enum MetodoPago {
  /// Tarjeta de crédito (simulada con validación de Luhn).
  tarjetaCredito,

  /// Tarjeta de débito (mismo flujo que crédito).
  tarjetaDebito,

  /// Pago en efectivo al momento de recoger el pedido.
  efectivo,

  /// OXXO Pay: referencia simulada de 16 dígitos.
  oxxoPay,
}

extension MetodoPagoExtension on MetodoPago {
  String get displayName {
    switch (this) {
      case MetodoPago.tarjetaCredito:
        return 'Tarjeta de Crédito';
      case MetodoPago.tarjetaDebito:
        return 'Tarjeta de Débito';
      case MetodoPago.efectivo:
        return 'Efectivo';
      case MetodoPago.oxxoPay:
        return 'OXXO Pay';
    }
  }

  String get icon {
    switch (this) {
      case MetodoPago.tarjetaCredito:
        return '💳';
      case MetodoPago.tarjetaDebito:
        return '🏦';
      case MetodoPago.efectivo:
        return '💵';
      case MetodoPago.oxxoPay:
        return '🏪';
    }
  }

  String get value => name;

  static MetodoPago fromString(String value) {
    return MetodoPago.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MetodoPago.efectivo,
    );
  }
}

/// Estados del proceso de pago simulado.
enum EstadoPago {
  /// El pago está siendo procesado.
  pendiente,

  /// Pago aprobado exitosamente.
  aprobado,

  /// Pago rechazado (simulado para demo).
  rechazado,

  /// Pago reembolsado tras cancelación.
  reembolsado,
}

extension EstadoPagoExtension on EstadoPago {
  String get displayName {
    switch (this) {
      case EstadoPago.pendiente:
        return 'Pendiente';
      case EstadoPago.aprobado:
        return 'Aprobado';
      case EstadoPago.rechazado:
        return 'Rechazado';
      case EstadoPago.reembolsado:
        return 'Reembolsado';
    }
  }

  String get value => name;
}
