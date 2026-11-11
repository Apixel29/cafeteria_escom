import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/producto_entity.dart';
import '../../repositories/producto_repository.dart';

/// Caso de uso: Obtener productos del menú (todos o filtrados por categoría).
class GetProductosUseCase {
  final ProductoRepository _repository;

  const GetProductosUseCase(this._repository);

  Future<Either<Failure, List<ProductoEntity>>> call({String? categoriaId}) {
    if (categoriaId != null && categoriaId.isNotEmpty && categoriaId != 'todos') {
      return _repository.getByCategoria(categoriaId);
    }
    return _repository.getAll();
  }
}
