import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:cafeteria_escom/domain/entities/producto_entity.dart';
import 'package:cafeteria_escom/domain/repositories/producto_repository.dart';
import 'package:cafeteria_escom/domain/usecases/menu/get_categorias_usecase.dart';
import 'package:cafeteria_escom/domain/usecases/menu/get_productos_usecase.dart';
import 'package:cafeteria_escom/domain/usecases/menu/search_productos_usecase.dart';
import 'package:cafeteria_escom/presentation/viewmodels/menu_viewmodel.dart';
import 'package:cafeteria_escom/core/errors/failures.dart';

class MockProductoRepository implements ProductoRepository {
  final List<CategoriaEntity> testCategorias = [
    const CategoriaEntity(id: 'cat_desayunos', nombre: 'Desayunos', icono: '🍳', orden: 1),
    const CategoriaEntity(id: 'cat_bebidas', nombre: 'Bebidas', icono: '🥤', orden: 2),
  ];

  final List<ProductoEntity> testProductos = [
    const ProductoEntity(
      id: 'prod_1',
      nombre: 'Chilaquiles Verdes',
      descripcion: 'Con crema y queso',
      precio: 45.0,
      categoriaId: 'cat_desayunos',
      stock: 10,
    ),
    const ProductoEntity(
      id: 'prod_2',
      nombre: 'Jugo de Naranja',
      descripcion: 'Natural 500ml',
      precio: 25.0,
      categoriaId: 'cat_bebidas',
      stock: 5,
    ),
  ];

  @override
  Future<Either<Failure, List<CategoriaEntity>>> getCategorias() async {
    return Right(testCategorias);
  }

  @override
  Future<Either<Failure, List<ProductoEntity>>> getAll() async {
    return Right(testProductos);
  }

  @override
  Future<Either<Failure, List<ProductoEntity>>> getByCategoria(String categoriaId) async {
    return Right(testProductos.where((p) => p.categoriaId == categoriaId).toList());
  }

  @override
  Future<Either<Failure, List<ProductoEntity>>> buscar(String query) async {
    return Right(testProductos
        .where((p) => p.nombre.toLowerCase().contains(query.toLowerCase()))
        .toList());
  }

  @override
  Future<Either<Failure, String>> crear(ProductoEntity producto) async => const Right('new_id');

  @override
  Future<Either<Failure, void>> actualizar(ProductoEntity producto) async => const Right(null);

  @override
  Future<Either<Failure, void>> eliminar(String productoId) async => const Right(null);
}

void main() {
  late MockProductoRepository repo;
  late MenuViewModel viewModel;

  setUp(() {
    repo = MockProductoRepository();
    viewModel = MenuViewModel(
      getCategoriasUseCase: GetCategoriasUseCase(repo),
      getProductosUseCase: GetProductosUseCase(repo),
      searchProductosUseCase: SearchProductosUseCase(repo),
    );
  });

  group('MenuViewModel Tests', () {
    test('loadMenu inicial carga categorias y productos', () async {
      await Future.delayed(const Duration(milliseconds: 50));

      expect(viewModel.state.categorias.length, 2);
      expect(viewModel.state.productos.length, 2);
      expect(viewModel.state.productosFiltrados.length, 2);
    });

    test('selectCategory filtra productos por categoria seleccionada', () async {
      await Future.delayed(const Duration(milliseconds: 50));

      viewModel.selectCategory('cat_bebidas');
      expect(viewModel.state.selectedCategoriaId, 'cat_bebidas');
      expect(viewModel.state.productosFiltrados.length, 1);
      expect(viewModel.state.productosFiltrados.first.nombre, 'Jugo de Naranja');
    });

    test('setSearchQuery filtra productos coincidentes por texto', () async {
      await Future.delayed(const Duration(milliseconds: 50));

      viewModel.setSearchQuery('chilaquiles');
      expect(viewModel.state.productosFiltrados.length, 1);
      expect(viewModel.state.productosFiltrados.first.id, 'prod_1');

      viewModel.setSearchQuery('inexistente');
      expect(viewModel.state.productosFiltrados.isEmpty, true);
    });
  });
}
