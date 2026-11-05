/// Enumeración de los posibles estados de un pedido.
enum EstadoPedido {
  /// Recibido, esperando confirmación de la cafetería.
  pendiente,

  /// Cafetería confirmó el pedido, próximo a preparar.
  confirmado,

  /// El pedido se está preparando en la cocina.
  preparando,

  /// Listo para que el cliente lo recoja en la caja.
  listo,

  /// El cliente ya recogió su pedido.
  entregado,

  /// El pedido fue cancelado (por cliente o cafetería).
  cancelado,
}

/// Extensión con utilidades para [EstadoPedido].
extension EstadoPedidoExtension on EstadoPedido {
  /// Nombre legible en español para mostrar en la UI.
  String get displayName {
    switch (this) {
      case EstadoPedido.pendiente:
        return 'Pendiente';
      case EstadoPedido.confirmado:
        return 'Confirmado';
      case EstadoPedido.preparando:
        return 'Preparando';
      case EstadoPedido.listo:
        return 'Listo para recoger';
      case EstadoPedido.entregado:
        return 'Entregado';
      case EstadoPedido.cancelado:
        return 'Cancelado';
    }
  }

  /// Valor string para almacenar en Firestore.
  String get value => name;

  /// Construir desde string de Firestore.
  static EstadoPedido fromString(String value) {
    return EstadoPedido.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EstadoPedido.pendiente,
    );
  }

  /// Indica si el pedido puede ser cancelado por el usuario.
  bool get canBeCancelled =>
      this == EstadoPedido.pendiente || this == EstadoPedido.confirmado;

  /// Indica si el pedido está activo (no finalizado ni cancelado).
  bool get isActive =>
      this != EstadoPedido.entregado && this != EstadoPedido.cancelado;
}
