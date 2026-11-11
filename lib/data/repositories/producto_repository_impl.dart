import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/producto_entity.dart';
import '../../domain/repositories/producto_repository.dart';
import '../datasources/local/producto_local_datasource.dart';
import '../datasources/remote/producto_remote_datasource.dart';
import '../models/producto_model.dart';

/// Implementación del repositorio de productos [ProductoRepository] con
/// estrategia Offline-First y sincronización transparente (Sprint 2 - RF2).
class ProductoRepositoryImpl implements ProductoRepository {
  final ProductoRemoteDataSource _remoteDataSource;
  final ProductoLocalDataSource _localDataSource;

  ProductoRepositoryImpl({
    required ProductoRemoteDataSource remoteDataSource,
    required ProductoLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<CategoriaEntity>>> getCategorias() async {
    try {
      // 1. Intentar sincronización remota desde Firestore
      final remoteCategorias = await _remoteDataSource.getCategorias();
      if (remoteCategorias.isNotEmpty) {
        await _localDataSource.cacheCategorias(remoteCategorias);
        return Right(remoteCategorias);
      }
    } catch (_) {
      // Si falla conexión o Firebase no está disponible, cae a caché SQLite
    }

    // 2. Consulta en base de datos local SQLite (Offline fallback)
    try {
      final localCategorias = await _localDataSource.getCategorias();
      return Right(localCategorias);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Error al consultar categorías locales: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProductoEntity>>> getAll() async {
    try {
      final remoteProductos = await _remoteDataSource.getProductos();
      if (remoteProductos.isNotEmpty) {
        await _localDataSource.cacheProductos(remoteProductos);
        return Right(remoteProductos);
      }
    } catch (_) {}

    try {
      final localProductos = await _localDataSource.getProductos();
      return Right(localProductos);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Error al consultar productos locales: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProductoEntity>>> getByCategoria(String categoriaId) async {
    try {
      final remoteProductos =
          await _remoteDataSource.getProductosByCategoria(categoriaId);
      if (remoteProductos.isNotEmpty) {
        return Right(remoteProductos);
      }
    } catch (_) {}

    try {
      final localProductos =
          await _localDataSource.getProductosByCategoria(categoriaId);
      return Right(localProductos);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Error al filtrar productos locales: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProductoEntity>>> buscar(String query) async {
    try {
      // Búsqueda ultra-rápida indexada en SQLite
      final resultados = await _localDataSource.buscarProductos(query);
      return Right(resultados);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Error al buscar productos: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> crear(ProductoEntity producto) async {
    try {
      final model = ProductoModel.fromEntity(producto);
      final id = await _remoteDataSource.crearProducto(model);
      final savedModel = model.copyWith(id: id);
      await _localDataSource.saveProducto(savedModel);
      return Right(id);
    } catch (e) {
      return Left(ServerFailure(message: 'Error al crear producto: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> actualizar(ProductoEntity producto) async {
    try {
      final model = ProductoModel.fromEntity(producto);
      await _remoteDataSource.actualizarProducto(model);
      await _localDataSource.saveProducto(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Error al actualizar producto: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> eliminar(String productoId) async {
    try {
      await _remoteDataSource.eliminarProducto(productoId);
      await _localDataSource.deleteProducto(productoId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Error al eliminar producto: $e'));
    }
  }
}
