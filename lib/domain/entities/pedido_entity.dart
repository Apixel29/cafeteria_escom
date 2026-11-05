import 'package:equatable/equatable.dart';
import '../enums/estado_pedido.dart';
import '../enums/metodo_pago.dart';

/// Un ítem dentro de un pedido confirmado.
///
/// A diferencia de [ItemCarrito], guarda el nombre y precio
/// en el momento de la compra, independiente de cambios futuros
/// en el catálogo.
class ItemPedido extends Equatable {
  final String productoId;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;

  const ItemPedido({
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
  });

  /// Subtotal del ítem.
  double get subtotal => precioUnitario * cantidad;

  Map<String, dynamic> toMap() => {
        'productoId': productoId,
        'nombreProducto': nombreProducto,
        'cantidad': cantidad,
        'precioUnitario': precioUnitario,
      };

  factory ItemPedido.fromMap(Map<String, dynamic> map) => ItemPedido(
        productoId: map['productoId'] as String,
        nombreProducto: map['nombreProducto'] as String,
        cantidad: map['cantidad'] as int,
        precioUnitario: (map['precioUnitario'] as num).toDouble(),
      );

  @override
  List<Object?> get props => [productoId, cantidad, precioUnitario];
}

/// Entidad de dominio de un pedido realizado por un usuario.
class PedidoEntity extends Equatable {
  final String id;
  final String usuarioId;
  final List<ItemPedido> items;
  final double total;
  final EstadoPedido estado;
  final MetodoPago metodoPago;
  final DateTime creadoEn;
  final DateTime? actualizadoEn;
  final String? notaGeneral;

  const PedidoEntity({
    required this.id,
    required this.usuarioId,
    required this.items,
    required this.total,
    required this.estado,
    required this.metodoPago,
    required this.creadoEn,
    this.actualizadoEn,
    this.notaGeneral,
  });

  /// Número de ítems totales del pedido.
  int get totalItems => items.fold(0, (sum, item) => sum + item.cantidad);

  PedidoEntity copyWith({
    String? id,
    String? usuarioId,
    List<ItemPedido>? items,
    double? total,
    EstadoPedido? estado,
    MetodoPago? metodoPago,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
    String? notaGeneral,
  }) {
    return PedidoEntity(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      items: items ?? this.items,
      total: total ?? this.total,
      estado: estado ?? this.estado,
      metodoPago: metodoPago ?? this.metodoPago,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      notaGeneral: notaGeneral ?? this.notaGeneral,
    );
  }

  @override
  List<Object?> get props =>
      [id, usuarioId, items, total, estado, metodoPago, creadoEn];
}
