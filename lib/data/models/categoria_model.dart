import '../../domain/entities/producto_entity.dart';

/// Modelo de datos para [CategoriaEntity].
///
/// Encapsula categorías del menú de la Cafetería ESCOM (ej. Desayunos, Comidas, Bebidas).
class CategoriaModel extends CategoriaEntity {
  const CategoriaModel({
    required super.id,
    required super.nombre,
    required super.icono,
    required super.orden,
  });

  /// Factory constructor desde un Map JSON o Firestore
  factory CategoriaModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return CategoriaModel(
      id: docId ?? (json['id'] as String? ?? ''),
      nombre: json['nombre'] as String? ?? '',
      icono: json['icono'] as String? ?? '🍽️',
      orden: (json['orden'] as num?)?.toInt() ?? 0,
    );
  }

  /// Factory constructor desde una fila de SQLite
  factory CategoriaModel.fromSqlite(Map<String, dynamic> map) {
    return CategoriaModel(
      id: map['id'] as String? ?? '',
      nombre: map['nombre'] as String? ?? '',
      icono: map['icono'] as String? ?? '🍽️',
      orden: (map['orden'] as int?) ?? 0,
    );
  }

  /// Factory constructor desde una [CategoriaEntity]
  factory CategoriaModel.fromEntity(CategoriaEntity entity) {
    return CategoriaModel(
      id: entity.id,
      nombre: entity.nombre,
      icono: entity.icono,
      orden: entity.orden,
    );
  }

  /// Serialización a Map JSON / Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'icono': icono,
      'orden': orden,
    };
  }

  /// Serialización a Map para tabla SQLite (`categorias_cache`)
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'nombre': nombre,
      'icono': icono,
      'orden': orden,
    };
  }
}
