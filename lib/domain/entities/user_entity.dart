import 'package:equatable/equatable.dart';

/// Entidad de dominio que representa a un usuario de la aplicación.
///
/// Extiende [Equatable] para comparación por valor,
/// lo que facilita detectar cambios de estado en Riverpod.
class UserEntity extends Equatable {
  final String uid;
  final String nombre;
  final String email;
  final String avatarUrl;

  /// Rol del usuario: 'user' (cliente) o 'admin' (personal de cafetería).
  final String rol;
  final DateTime creadoEn;

  const UserEntity({
    required this.uid,
    required this.nombre,
    required this.email,
    this.avatarUrl = '',
    this.rol = 'user',
    required this.creadoEn,
  });

  /// Verifica si el usuario tiene permisos de administrador.
  bool get isAdmin => rol == 'admin';

  /// Crea una copia con campos modificados (patrón copyWith).
  UserEntity copyWith({
    String? uid,
    String? nombre,
    String? email,
    String? avatarUrl,
    String? rol,
    DateTime? creadoEn,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rol: rol ?? this.rol,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  List<Object?> get props => [uid, nombre, email, avatarUrl, rol, creadoEn];
}
