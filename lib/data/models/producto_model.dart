import '../../domain/entities/producto_entity.dart';

/// Modelo de datos para [ProductoEntity].
///
/// Soporta serialización bidireccional para Cloud Firestore y para
/// la base de datos relacional SQLite (`sqflite`) local (Sprint 2 - RF2).
class ProductoModel extends ProductoEntity {
  const ProductoModel({
    required super.id,
    required super.nombre,
    required super.descripcion,
    required super.precio,
    super.imagenUrl = '',
    required super.categoriaId,
    super.disponible = true,
    super.stock = 0,
  });

  /// Factory constructor desde un Map JSON o Cloud Firestore
  factory ProductoModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return ProductoModel(
      id: docId ?? (json['id'] as String? ?? ''),
      nombre: json['nombre'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      imagenUrl: json['imagenUrl'] as String? ?? '',
      categoriaId: json['categoriaId'] as String? ?? '',
      disponible: json['disponible'] is bool
          ? json['disponible'] as bool
          : (json['disponible'] == 1),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
    );
  }

  /// Factory constructor desde una fila de SQLite (donde booleano es 0 o 1)
  factory ProductoModel.fromSqlite(Map<String, dynamic> map) {
    return ProductoModel(
      id: map['id'] as String? ?? '',
      nombre: map['nombre'] as String? ?? '',
      descripcion: map['descripcion'] as String? ?? '',
      precio: (map['precio'] as num?)?.toDouble() ?? 0.0,
      imagenUrl: map['imagenUrl'] as String? ?? '',
      categoriaId: map['categoriaId'] as String? ?? '',
      disponible: (map['disponible'] as int? ?? 1) == 1,
      stock: (map['stock'] as int?) ?? 0,
    );
  }

  /// Factory constructor desde una [ProductoEntity]
  factory ProductoModel.fromEntity(ProductoEntity entity) {
    return ProductoModel(
      id: entity.id,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      precio: entity.precio,
      imagenUrl: entity.imagenUrl,
      categoriaId: entity.categoriaId,
      disponible: entity.disponible,
      stock: entity.stock,
    );
  }

  /// Serialización para Cloud Firestore y APIs JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagenUrl': imagenUrl,
      'categoriaId': categoriaId,
      'disponible': disponible,
      'stock': stock,
    };
  }

  /// Serialización para persistencia en tabla SQLite (`productos_cache`)
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagenUrl': imagenUrl,
      'categoriaId': categoriaId,
      'disponible': disponible ? 1 : 0,
      'stock': stock,
    };
  }

  @override
  ProductoModel copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    double? precio,
    String? imagenUrl,
    String? categoriaId,
    bool? disponible,
    int? stock,
  }) {
    return ProductoModel(
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
}
