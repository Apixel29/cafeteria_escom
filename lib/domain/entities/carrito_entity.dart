import 'package:equatable/equatable.dart';
import 'producto_entity.dart';

/// Un ítem dentro del carrito de compras.
class ItemCarrito extends Equatable {
  final ProductoEntity producto;
  final int cantidad;
  final String? notaEspecial;

  const ItemCarrito({
    required this.producto,
    required this.cantidad,
    this.notaEspecial,
  });

  /// Subtotal calculado: precio × cantidad.
  double get subtotal => producto.precio * cantidad;

  ItemCarrito copyWith({
    ProductoEntity? producto,
    int? cantidad,
    String? notaEspecial,
  }) {
    return ItemCarrito(
      producto: producto ?? this.producto,
      cantidad: cantidad ?? this.cantidad,
      notaEspecial: notaEspecial ?? this.notaEspecial,
    );
  }

  @override
  List<Object?> get props => [producto.id, cantidad, notaEspecial];
}

/// Entidad que representa el carrito de compras completo.
class CarritoEntity extends Equatable {
  final String usuarioId;
  final List<ItemCarrito> items;

  const CarritoEntity({
    required this.usuarioId,
    this.items = const [],
  });

  /// Número total de ítems (suma de todas las cantidades).
  int get totalItems => items.fold(0, (sum, item) => sum + item.cantidad);

  /// Subtotal sin impuestos.
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);

  /// IVA del 16%.
  double get iva => subtotal * 0.16;

  /// Total final con IVA.
  double get total => subtotal + iva;

  /// Verifica si el carrito está vacío.
  bool get isEmpty => items.isEmpty;

  /// Agrega un producto. Si ya existe, incrementa la cantidad.
  CarritoEntity agregarItem(ProductoEntity producto, int cantidad) {
    final index = items.indexWhere((i) => i.producto.id == producto.id);
    final nuevosItems = List<ItemCarrito>.from(items);

    if (index >= 0) {
      final itemExistente = nuevosItems[index];
      nuevosItems[index] = itemExistente.copyWith(
        cantidad: itemExistente.cantidad + cantidad,
      );
    } else {
      nuevosItems.add(ItemCarrito(producto: producto, cantidad: cantidad));
    }

    return copyWith(items: nuevosItems);
  }

  /// Quita un ítem completamente del carrito.
  CarritoEntity quitarItem(String productoId) {
    return copyWith(
      items: items.where((i) => i.producto.id != productoId).toList(),
    );
  }

  /// Actualiza la cantidad de un ítem específico.
  CarritoEntity actualizarCantidad(String productoId, int cantidad) {
    if (cantidad <= 0) return quitarItem(productoId);
    return copyWith(
      items: items.map((i) {
        return i.producto.id == productoId ? i.copyWith(cantidad: cantidad) : i;
      }).toList(),
    );
  }

  /// Devuelve un carrito vacío manteniendo el usuarioId.
  CarritoEntity limpiar() => copyWith(items: []);

  CarritoEntity copyWith({String? usuarioId, List<ItemCarrito>? items}) {
    return CarritoEntity(
      usuarioId: usuarioId ?? this.usuarioId,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [usuarioId, items];
}
