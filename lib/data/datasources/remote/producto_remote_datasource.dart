import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../models/producto_model.dart';
import '../../models/categoria_model.dart';
import '../../../core/errors/failures.dart';

/// Contrato para el DataSource remoto de productos y categorías en Cloud Firestore.
abstract class ProductoRemoteDataSource {
  Future<List<CategoriaModel>> getCategorias();
  Future<List<ProductoModel>> getProductos();
  Future<List<ProductoModel>> getProductosByCategoria(String categoriaId);
  Future<String> crearProducto(ProductoModel producto);
  Future<void> actualizarProducto(ProductoModel producto);
  Future<void> eliminarProducto(String id);
}

/// Implementación remota en Cloud Firestore con fallback seguro.
class ProductoRemoteDataSourceImpl implements ProductoRemoteDataSource {
  final FirebaseFirestore? _firestore;

  ProductoRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore;

  bool get _isFirebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<CategoriaModel>> getCategorias() async {
    if (!_isFirebaseReady) {
      return [];
    }

    try {
      final snapshot = await _db
          .collection('categorias')
          .orderBy('orden', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => CategoriaModel.fromJson(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      throw ServerFailure(message: 'Error al consultar categorías en Firestore: $e');
    }
  }

  @override
  Future<List<ProductoModel>> getProductos() async {
    if (!_isFirebaseReady) {
      return [];
    }

    try {
      final snapshot = await _db.collection('productos').get();
      return snapshot.docs
          .map((doc) => ProductoModel.fromJson(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      throw ServerFailure(message: 'Error al consultar catálogo en Firestore: $e');
    }
  }

  @override
  Future<List<ProductoModel>> getProductosByCategoria(String categoriaId) async {
    if (!_isFirebaseReady) {
      return [];
    }

    try {
      final snapshot = await _db
          .collection('productos')
          .where('categoriaId', isEqualTo: categoriaId)
          .get();

      return snapshot.docs
          .map((doc) => ProductoModel.fromJson(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      throw ServerFailure(message: 'Error al filtrar productos en Firestore: $e');
    }
  }

  @override
  Future<String> crearProducto(ProductoModel producto) async {
    if (!_isFirebaseReady) {
      return producto.id.isNotEmpty
          ? producto.id
          : 'local_${DateTime.now().millisecondsSinceEpoch}';
    }

    try {
      final docRef = await _db.collection('productos').add(producto.toJson());
      return docRef.id;
    } catch (e) {
      throw ServerFailure(message: 'Error al crear producto en Firestore: $e');
    }
  }

  @override
  Future<void> actualizarProducto(ProductoModel producto) async {
    if (!_isFirebaseReady) return;

    try {
      await _db.collection('productos').doc(producto.id).update(producto.toJson());
    } catch (e) {
      throw ServerFailure(message: 'Error al actualizar producto en Firestore: $e');
    }
  }

  @override
  Future<void> eliminarProducto(String id) async {
    if (!_isFirebaseReady) return;

    try {
      await _db.collection('productos').doc(id).delete();
    } catch (e) {
      throw ServerFailure(message: 'Error al eliminar producto en Firestore: $e');
    }
  }
}
