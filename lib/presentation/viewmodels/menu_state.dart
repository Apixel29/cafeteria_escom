import 'package:equatable/equatable.dart';
import '../../domain/entities/producto_entity.dart';

/// Estado inmutable para el catálogo de la Cafetería ESCOM (Sprint 2).
class MenuState extends Equatable {
  final List<CategoriaEntity> categorias;
  final List<ProductoEntity> productos;
  final String selectedCategoriaId;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  const MenuState({
    this.categorias = const [],
    this.productos = const [],
    this.selectedCategoriaId = 'todos',
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  /// Lista de productos tras aplicar filtro de categoría y consulta de texto
  List<ProductoEntity> get productosFiltrados {
    return productos.where((prod) {
      final matchesCategory = selectedCategoriaId == 'todos' ||
          prod.categoriaId == selectedCategoriaId;

      final query = searchQuery.toLowerCase().trim();
      final matchesQuery = query.isEmpty ||
          prod.nombre.toLowerCase().contains(query) ||
          prod.descripcion.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();
  }

  MenuState copyWith({
    List<CategoriaEntity>? categorias,
    List<ProductoEntity>? productos,
    String? selectedCategoriaId,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MenuState(
      categorias: categorias ?? this.categorias,
      productos: productos ?? this.productos,
      selectedCategoriaId: selectedCategoriaId ?? this.selectedCategoriaId,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        categorias,
        productos,
        selectedCategoriaId,
        searchQuery,
        isLoading,
        errorMessage,
      ];
}
