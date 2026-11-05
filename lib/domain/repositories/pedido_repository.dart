import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/pedido_entity.dart';
import '../enums/estado_pedido.dart';
import '../enums/metodo_pago.dart';

/// Contrato del repositorio de pedidos.
abstract class PedidoRepository {
  /// Crea un nuevo pedido y simula el procesamiento del pago.
  /// Retorna el ID del pedido creado.
  Future<Either<Failure, String>> crear({
    required String usuarioId,
    required List<ItemPedido> items,
    required double total,
    required MetodoPago metodoPago,
    String? notaGeneral,
  });

  /// Obtiene todos los pedidos de un usuario específico.
  Future<Either<Failure, List<PedidoEntity>>> getByUsuario(String usuarioId);

  /// [Admin] Obtiene todos los pedidos del sistema.
  Future<Either<Failure, List<PedidoEntity>>> getAll();

  /// Actualiza el estado de un pedido.
  Future<Either<Failure, void>> actualizarEstado({
    required String pedidoId,
    required EstadoPedido nuevoEstado,
  });

  /// Cancela un pedido (solo si está en estado cancelable).
  Future<Either<Failure, void>> cancelar(String pedidoId);
}
