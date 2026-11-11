import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/producto_repository.dart';
import '../../domain/usecases/menu/get_categorias_usecase.dart';
import '../../domain/usecases/menu/get_productos_usecase.dart';
import '../../domain/usecases/menu/search_productos_usecase.dart';
import '../../data/datasources/local/producto_local_datasource.dart';
import '../../data/datasources/remote/producto_remote_datasource.dart';
import '../../data/repositories/producto_repository_impl.dart';
import 'menu_state.dart';

// ── Inyección de dependencias (Riverpod Providers) ───────────────

final productoLocalDataSourceProvider = Provider<ProductoLocalDataSource>((ref) {
  return ProductoLocalDataSourceImpl();
});

final productoRemoteDataSourceProvider = Provider<ProductoRemoteDataSource>((ref) {
  return ProductoRemoteDataSourceImpl();
});

final productoRepositoryProvider = Provider<ProductoRepository>((ref) {
  final local = ref.watch(productoLocalDataSourceProvider);
  final remote = ref.watch(productoRemoteDataSourceProvider);
  return ProductoRepositoryImpl(remoteDataSource: remote, localDataSource: local);
});

final getCategoriasUseCaseProvider = Provider<GetCategoriasUseCase>((ref) {
  return GetCategoriasUseCase(ref.watch(productoRepositoryProvider));
});

final getProductosUseCaseProvider = Provider<GetProductosUseCase>((ref) {
  return GetProductosUseCase(ref.watch(productoRepositoryProvider));
});

final searchProductosUseCaseProvider = Provider<SearchProductosUseCase>((ref) {
  return SearchProductosUseCase(ref.watch(productoRepositoryProvider));
});

final menuViewModelProvider =
    StateNotifierProvider<MenuViewModel, MenuState>((ref) {
  return MenuViewModel(
    getCategoriasUseCase: ref.watch(getCategoriasUseCaseProvider),
    getProductosUseCase: ref.watch(getProductosUseCaseProvider),
    searchProductosUseCase: ref.watch(searchProductosUseCaseProvider),
  );
});

// ── ViewModel (StateNotifier) ───────────────────────────────────

class MenuViewModel extends StateNotifier<MenuState> {
  final GetCategoriasUseCase _getCategoriasUseCase;
  final GetProductosUseCase _getProductosUseCase;
  final SearchProductosUseCase _searchProductosUseCase;

  MenuViewModel({
    required GetCategoriasUseCase getCategoriasUseCase,
    required GetProductosUseCase getProductosUseCase,
    required SearchProductosUseCase searchProductosUseCase,
  })  : _getCategoriasUseCase = getCategoriasUseCase,
        _getProductosUseCase = getProductosUseCase,
        _searchProductosUseCase = searchProductosUseCase,
        super(const MenuState()) {
    // Cargar datos al inicializar
    loadMenu();
  }

  /// Carga categorías y productos simultáneamente
  Future<void> loadMenu() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final catResult = await _getCategoriasUseCase();
    final prodResult = await _getProductosUseCase();

    catResult.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (categorias) {
        prodResult.fold(
          (failure) => state = state.copyWith(
            categorias: categorias,
            isLoading: false,
            errorMessage: failure.message,
          ),
          (productos) => state = state.copyWith(
            categorias: categorias,
            productos: productos,
            isLoading: false,
            clearError: true,
          ),
        );
      },
    );
  }

  /// Selecciona una categoría para filtrar productos
  void selectCategory(String categoriaId) {
    state = state.copyWith(selectedCategoriaId: categoriaId);
  }

  /// Actualiza el término de búsqueda y consulta en SQLite mediante [SearchProductosUseCase]
  Future<void> setSearchQuery(String query) async {
    state = state.copyWith(searchQuery: query);
    if (query.trim().isNotEmpty) {
      final searchResult = await _searchProductosUseCase(query);
      searchResult.fold(
        (_) {},
        (encontrados) => state = state.copyWith(productos: encontrados),
      );
    } else {
      await loadMenu();
    }
  }

  /// Refresca los datos desde la nube / base de datos local
  Future<void> refresh() async {
    await loadMenu();
  }
}
