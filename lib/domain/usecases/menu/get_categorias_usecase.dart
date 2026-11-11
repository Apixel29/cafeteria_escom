import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/producto_entity.dart';
import '../../repositories/producto_repository.dart';

/// Caso de uso: Obtener todas las categorías del menú de la Cafetería ESCOM.
class GetCategoriasUseCase {
  final ProductoRepository _repository;

  const GetCategoriasUseCase(this._repository);

  Future<Either<Failure, List<CategoriaEntity>>> call() {
    return _repository.getCategorias();
  }
}
