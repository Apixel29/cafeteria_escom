import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/producto_entity.dart';
import '../../viewmodels/menu_viewmodel.dart';

/// Pantalla del Menú Digital y Catálogo de la Cafetería ESCOM (Sprint 2 - RF2).
///
/// Soporta persistencia offline en SQLite (`sqflite`), búsqueda instantánea,
/// filtrado por categorías y vista detallada del producto.
class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showProductDetail(BuildContext context, ProductoEntity producto) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProductDetailModal(producto: producto),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menuViewModelProvider);
    final productos = menuState.productosFiltrados;

    return RefreshIndicator(
      onRefresh: () => ref.read(menuViewModelProvider.notifier).refresh(),
      color: AppColors.primary,
      child: Column(
        children: [
          // Barra de Búsqueda instantánea
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                ref.read(menuViewModelProvider.notifier).setSearchQuery(query);
              },
              decoration: InputDecoration(
                hintText: 'Buscar chilaquiles, tortas, café...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(menuViewModelProvider.notifier)
                              .setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Selector horizontal de Categorías
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip(
                  id: 'todos',
                  label: 'Todos',
                  icon: '🍽️',
                  isSelected: menuState.selectedCategoriaId == 'todos',
                ),
                ...menuState.categorias.map(
                  (cat) => _buildCategoryChip(
                    id: cat.id,
                    label: cat.nombre,
                    icon: cat.icono,
                    isSelected: menuState.selectedCategoriaId == cat.id,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Lista de Productos
          Expanded(
            child: menuState.isLoading && productos.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : productos.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: productos.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final prod = productos[index];
                          return _buildProductCard(context, prod);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String id,
    required String label,
    required String icon,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: Text(icon, style: const TextStyle(fontSize: 14)),
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        backgroundColor: Colors.grey.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        onSelected: (_) {
          ref.read(menuViewModelProvider.notifier).selectCategory(id);
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductoEntity prod) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showProductDetail(context, prod),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del producto con fallback
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 90,
                  height: 90,
                  color: AppColors.primary.withValues(alpha: 0.08),
                  child: prod.imagenUrl.isNotEmpty
                      ? Image.network(
                          prod.imagenUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Text('🍲', style: TextStyle(fontSize: 36)),
                          ),
                        )
                      : const Center(
                          child: Text('🍲', style: TextStyle(fontSize: 36)),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Información del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prod.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prod.descripcion,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Precio y botón
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${prod.precio.toStringAsFixed(2)} MXN',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: prod.stock > 0
                                ? AppColors.success.withValues(alpha: 0.1)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            prod.stock > 0
                                ? 'Stock: ${prod.stock}'
                                : 'Agotado',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: prod.stock > 0
                                  ? AppColors.success
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 54)),
            const SizedBox(height: 16),
            const Text(
              'No encontramos productos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Prueba con otra palabra o selecciona una categoría diferente en el menú.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                ref.read(menuViewModelProvider.notifier).setSearchQuery('');
                ref.read(menuViewModelProvider.notifier).selectCategory('todos');
              },
              child: const Text('Ver todo el menú'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal detallado del producto para consultar especificaciones y ordenar (RF2).
class _ProductDetailModal extends StatefulWidget {
  final ProductoEntity producto;

  const _ProductDetailModal({required this.producto});

  @override
  State<_ProductDetailModal> createState() => _ProductDetailModalState();
}

class _ProductDetailModalState extends State<_ProductDetailModal> {
  int _cantidad = 1;

  @override
  Widget build(BuildContext context) {
    final prod = widget.producto;
    final total = prod.precio * _cantidad;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tirador superior del modal
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Imagen grande
          if (prod.imagenUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: double.infinity,
                height: 180,
                child: Image.network(
                  prod.imagenUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: const Center(
                      child: Text('🍽️', style: TextStyle(fontSize: 60)),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Nombre y precio unitario
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  prod.nombre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '\$${prod.precio.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Descripción completa
          Text(
            prod.descripcion,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Selector de cantidad
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cantidad:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  IconButton.filledTonal(
                    icon: const Icon(Icons.remove),
                    onPressed: _cantidad > 1
                        ? () => setState(() => _cantidad--)
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_cantidad',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add),
                    onPressed: _cantidad < prod.stock
                        ? () => setState(() => _cantidad++)
                        : null,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Botón para agregar al carrito
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: Text(
                'Agregar $_cantidad por \$${total.toStringAsFixed(2)} MXN',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: prod.stock > 0
                  ? () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '¡$_cantidad x ${prod.nombre} agregado al carrito!',
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
