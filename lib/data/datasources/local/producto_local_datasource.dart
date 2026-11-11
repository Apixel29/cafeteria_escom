import 'package:sqflite/sqflite.dart';
import '../../models/producto_model.dart';
import '../../models/categoria_model.dart';
import 'database_helper.dart';

/// Contrato para el DataSource local de productos en SQLite.
abstract class ProductoLocalDataSource {
  Future<List<CategoriaModel>> getCategorias();
  Future<List<ProductoModel>> getProductos();
  Future<List<ProductoModel>> getProductosByCategoria(String categoriaId);
  Future<List<ProductoModel>> buscarProductos(String query);

  Future<void> cacheCategorias(List<CategoriaModel> categorias);
  Future<void> cacheProductos(List<ProductoModel> productos);
  Future<void> saveProducto(ProductoModel producto);
  Future<void> deleteProducto(String id);
}

/// Implementación del DataSource local sobre SQLite mediante [DatabaseHelper].
class ProductoLocalDataSourceImpl implements ProductoLocalDataSource {
  final DatabaseHelper _dbHelper;

  ProductoLocalDataSourceImpl({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<CategoriaModel>> getCategorias() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableCategorias,
      orderBy: 'orden ASC',
    );
    return maps.map((m) => CategoriaModel.fromSqlite(m)).toList();
  }

  @override
  Future<List<ProductoModel>> getProductos() async {
    final db = await _dbHelper.database;
    final maps = await db.query(DatabaseHelper.tableProductos);
    return maps.map((m) => ProductoModel.fromSqlite(m)).toList();
  }

  @override
  Future<List<ProductoModel>> getProductosByCategoria(String categoriaId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableProductos,
      where: 'categoriaId = ?',
      whereArgs: [categoriaId],
    );
    return maps.map((m) => ProductoModel.fromSqlite(m)).toList();
  }

  @override
  Future<List<ProductoModel>> buscarProductos(String query) async {
    final db = await _dbHelper.database;
    final clean = '%${query.trim()}%';
    final maps = await db.query(
      DatabaseHelper.tableProductos,
      where: 'nombre LIKE ? OR descripcion LIKE ?',
      whereArgs: [clean, clean],
    );
    return maps.map((m) => ProductoModel.fromSqlite(m)).toList();
  }

  @override
  Future<void> cacheCategorias(List<CategoriaModel> categorias) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final cat in categorias) {
      batch.insert(
        DatabaseHelper.tableCategorias,
        cat.toSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> cacheProductos(List<ProductoModel> productos) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final prod in productos) {
      batch.insert(
        DatabaseHelper.tableProductos,
        prod.toSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> saveProducto(ProductoModel producto) async {
    final db = await _dbHelper.database;
    await db.insert(
      DatabaseHelper.tableProductos,
      producto.toSqlite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteProducto(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.tableProductos,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
