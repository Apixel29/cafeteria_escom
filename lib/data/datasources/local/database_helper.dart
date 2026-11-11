import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Administrador central de la base de datos relacional SQLite local (`sqflite`).
///
/// Cumple con el requerimiento **RF2 (Persistencia Local)** y **RNF1 (Soporte Offline)**.
/// Proporciona almacenamiento en caché para productos y categorías, permitiendo
/// que los estudiantes consulten el menú y precios incluso sin conexión a internet.
class DatabaseHelper {
  static const String _databaseName = 'cafeteria_escom.db';
  static const int _databaseVersion = 1;

  // Nombres de tablas
  static const String tableProductos = 'productos_cache';
  static const String tableCategorias = 'categorias_cache';

  // Instancia singleton
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Tabla de Categorías
    await db.execute('''
      CREATE TABLE $tableCategorias (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        icono TEXT NOT NULL,
        orden INTEGER NOT NULL
      )
    ''');

    // 2. Tabla de Productos del Menú
    await db.execute('''
      CREATE TABLE $tableProductos (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        precio REAL NOT NULL,
        imagenUrl TEXT,
        categoriaId TEXT NOT NULL,
        disponible INTEGER NOT NULL DEFAULT 1,
        stock INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (categoriaId) REFERENCES $tableCategorias (id)
      )
    ''');

    // Carga inicial de datos offline de cortesía (Seed de la Cafetería ESCOM)
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    final categorias = [
      {'id': 'cat_desayunos', 'nombre': 'Desayunos', 'icono': '🍳', 'orden': 1},
      {'id': 'cat_comidas', 'nombre': 'Comidas Corridas', 'icono': '🍲', 'orden': 2},
      {'id': 'cat_tortas', 'nombre': 'Tortas y Baguettes', 'icono': '🥪', 'orden': 3},
      {'id': 'cat_bebidas', 'nombre': 'Bebidas y Jugos', 'icono': '🥤', 'orden': 4},
      {'id': 'cat_cafe', 'nombre': 'Cafetería', 'icono': '☕', 'orden': 5},
      {'id': 'cat_snacks', 'nombre': 'Snacks y Postres', 'icono': '🧁', 'orden': 6},
    ];

    for (final cat in categorias) {
      await db.insert(tableCategorias, cat, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    final productos = [
      {
        'id': 'prod_001',
        'nombre': 'Chilaquiles Verdes con Pollo',
        'descripcion': 'Totopos crujientes bañados en salsa verde tradicional con crema, queso cotija y pechuga deshebrada.',
        'precio': 48.0,
        'imagenUrl': 'https://images.unsplash.com/photo-1599974579688-8dbdd335c77f?w=400',
        'categoriaId': 'cat_desayunos',
        'disponible': 1,
        'stock': 25,
      },
      {
        'id': 'prod_002',
        'nombre': 'Molletes con Jamón (Orden de 2)',
        'descripcion': 'Bolillo artesanal con frijoles refritos de la casa, queso manchego gratinado y jamón de pavo con pico de gallo.',
        'precio': 38.0,
        'imagenUrl': 'https://images.unsplash.com/photo-1588137378633-dea1336ce1e2?w=400',
        'categoriaId': 'cat_desayunos',
        'disponible': 1,
        'stock': 30,
      },
      {
        'id': 'prod_003',
        'nombre': 'Torta de Milanesa Especial ESCOM',
        'descripcion': 'Milanesa empanizada, quesillo Oaxaca, aguacate, jitomate, frijoles y mayonesa en telera caliente.',
        'precio': 52.0,
        'imagenUrl': 'https://images.unsplash.com/photo-1553909489-cd47e0907980?w=400',
        'categoriaId': 'cat_tortas',
        'disponible': 1,
        'stock': 20,
      },
      {
        'id': 'prod_004',
        'nombre': 'Baguette de Pechuga y Manchego',
        'descripcion': 'Pan baguette rústico con pechuga asada a las finas hierbas, aderezo chipotle y lechuga hidropónica.',
        'precio': 55.0,
        'imagenUrl': 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=400',
        'categoriaId': 'cat_tortas',
        'disponible': 1,
        'stock': 15,
      },
      {
        'id': 'prod_005',
        'nombre': 'Comida Corrida Completa del Día',
        'descripcion': 'Incluye: Sopa de fideo o consomé, arroz con verduras, guisado fuerte a elegir, frijoles y agua fresca 500ml.',
        'precio': 68.0,
        'imagenUrl': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
        'categoriaId': 'cat_comidas',
        'disponible': 1,
        'stock': 40,
      },
      {
        'id': 'prod_006',
        'nombre': 'Café Americano Gourmet 12oz',
        'descripcion': 'Café veracruzano recién molido de tueste medio alto.',
        'precio': 24.0,
        'imagenUrl': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400',
        'categoriaId': 'cat_cafe',
        'disponible': 1,
        'stock': 50,
      },
      {
        'id': 'prod_007',
        'nombre': 'Capuchino con Vainilla Francesa',
        'descripcion': 'Espresso doble con leche espumada y jarabe artesanal de vainilla.',
        'precio': 35.0,
        'imagenUrl': 'https://images.unsplash.com/photo-1534778101976-62847782c213?w=400',
        'categoriaId': 'cat_cafe',
        'disponible': 1,
        'stock': 35,
      },
      {
        'id': 'prod_008',
        'nombre': 'Agua Fresca Natural de Jamaica 600ml',
        'descripcion': 'Elaborada con flor de jamaica natural, endulzada ligeramente.',
        'precio': 20.0,
        'imagenUrl': 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=400',
        'categoriaId': 'cat_bebidas',
        'disponible': 1,
        'stock': 60,
      },
      {
        'id': 'prod_009',
        'nombre': 'Muffin de Chocolate Politécnico',
        'descripcion': 'Muffin esponjoso horneado diario con chispas de chocolate semiamargo.',
        'precio': 22.0,
        'imagenUrl': 'https://images.unsplash.com/photo-1607958996333-41aef7caefaa?w=400',
        'categoriaId': 'cat_snacks',
        'disponible': 1,
        'stock': 18,
      },
    ];

    for (final prod in productos) {
      await db.insert(tableProductos, prod, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  /// Limpia la caché local (para pruebas o sincronización forzada)
  Future<void> clearAll() async {
    final db = await database;
    await db.delete(tableProductos);
    await db.delete(tableCategorias);
  }
}
