import 'package:equatable/equatable.dart';

/// Entidad de dominio de un producto del menú.
class ProductoEntity extends Equatable {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagenUrl;
  final String categoriaId;
  final bool disponible;
  final int stock;

  const ProductoEntity({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    this.imagenUrl = '',
    required this.categoriaId,
    this.disponible = true,
    this.stock = 0,
  });

  /// Verifica si el producto puede ser agregado al carrito.
  bool get puedeAgregarseAlCarrito => disponible && stock > 0;

  ProductoEntity copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    double? precio,
    String? imagenUrl,
    String? categoriaId,
    bool? disponible,
    int? stock,
  }) {
    return ProductoEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      categoriaId: categoriaId ?? this.categoriaId,
      disponible: disponible ?? this.disponible,
      stock: stock ?? this.stock,
    );
  }

  @override
  List<Object?> get props =>
      [id, nombre, descripcion, precio, imagenUrl, categoriaId, disponible, stock];
}

/// Entidad de dominio de una categoría del menú.
class CategoriaEntity extends Equatable {
  final String id;
  final String nombre;
  final String icono;
  final int orden;

  const CategoriaEntity({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.orden,
  });

  @override
  List<Object?> get props => [id, nombre, icono, orden];
}
