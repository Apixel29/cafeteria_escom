import 'package:flutter_test/flutter_test.dart';
import 'package:cafeteria_escom/data/models/producto_model.dart';
import 'package:cafeteria_escom/data/models/categoria_model.dart';
import 'package:cafeteria_escom/domain/entities/producto_entity.dart';

void main() {
  group('ProductoModel Tests', () {
    const tProducto = ProductoModel(
      id: 'prod_test_01',
      nombre: 'Chilaquiles Especiales',
      descripcion: 'Chilaquiles verdes con pollo',
      precio: 45.0,
      imagenUrl: 'https://example.com/chilaquiles.png',
      categoriaId: 'cat_desayunos',
      disponible: true,
      stock: 12,
    );

    test('debe ser un subtipo de ProductoEntity', () {
      expect(tProducto, isA<ProductoEntity>());
    });

    test('toJson y fromJson deben serializar y deserializar fielmente', () {
      final json = tProducto.toJson();
      final model = ProductoModel.fromJson(json);

      expect(model.id, tProducto.id);
      expect(model.nombre, tProducto.nombre);
      expect(model.precio, tProducto.precio);
      expect(model.stock, tProducto.stock);
      expect(model.disponible, true);
    });

    test('toSqlite y fromSqlite deben mapear booleano a entero (0/1)', () {
      final sqliteMap = tProducto.toSqlite();
      expect(sqliteMap['disponible'], 1);

      final fromDb = ProductoModel.fromSqlite(sqliteMap);
      expect(fromDb.disponible, true);
      expect(fromDb.id, 'prod_test_01');
    });

    test('puedeAgregarseAlCarrito retorna true solo si disponible y stock > 0', () {
      expect(tProducto.puedeAgregarseAlCarrito, true);

      final agotado = tProducto.copyWith(stock: 0);
      expect(agotado.puedeAgregarseAlCarrito, false);

      final noDisponible = tProducto.copyWith(disponible: false);
      expect(noDisponible.puedeAgregarseAlCarrito, false);
    });
  });

  group('CategoriaModel Tests', () {
    const tCategoria = CategoriaModel(
      id: 'cat_bebidas',
      nombre: 'Bebidas Naturales',
      icono: '🥤',
      orden: 3,
    );

    test('debe ser subtipo de CategoriaEntity', () {
      expect(tCategoria, isA<CategoriaEntity>());
    });

    test('toSqlite y fromSqlite persisten orden e icono correctamente', () {
      final map = tCategoria.toSqlite();
      final fromDb = CategoriaModel.fromSqlite(map);

      expect(fromDb.id, 'cat_bebidas');
      expect(fromDb.nombre, 'Bebidas Naturales');
      expect(fromDb.icono, '🥤');
      expect(fromDb.orden, 3);
    });
  });
}
