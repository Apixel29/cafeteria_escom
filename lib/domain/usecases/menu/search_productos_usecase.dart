import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/producto_entity.dart';
import '../../repositories/producto_repository.dart';

/// Caso de uso: Búsqueda reactiva de productos por nombre o descripción (RF2).
class SearchProductosUseCase {
  final ProductoRepository _repository;

  const SearchProductosUseCase(this._repository);

  Future<Either<Failure, List<ProductoEntity>>> call(String query) {
    if (query.trim().isEmpty) {
      return _repository.getAll();
    }
    return _repository.buscar(query.trim());
  }
}
