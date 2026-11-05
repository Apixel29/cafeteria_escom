import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/producto_entity.dart';

/// Contrato del repositorio de productos del menú.
abstract class ProductoRepository {
  /// Obtiene todas las categorías del menú ordenadas.
  Future<Either<Failure, List<CategoriaEntity>>> getCategorias();

  /// Obtiene productos de una categoría específica.
  Future<Either<Failure, List<ProductoEntity>>> getByCategoria(
      String categoriaId);

  /// Obtiene todos los productos disponibles.
  Future<Either<Failure, List<ProductoEntity>>> getAll();

  /// Busca productos por nombre o descripción.
  Future<Either<Failure, List<ProductoEntity>>> buscar(String query);

  /// [Admin] Crea un nuevo producto en el catálogo.
  Future<Either<Failure, String>> crear(ProductoEntity producto);

  /// [Admin] Actualiza los datos de un producto existente.
  Future<Either<Failure, void>> actualizar(ProductoEntity producto);

  /// [Admin] Elimina un producto del catálogo.
  Future<Either<Failure, void>> eliminar(String productoId);
}
