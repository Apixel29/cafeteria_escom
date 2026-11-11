import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';

/// Modelo de datos para la entidad [UserEntity].
///
/// Encapsula la serialización JSON / Map para persistencia en SQLite
/// y Cloud Firestore, así como el mapeo directo desde [User] de Firebase Auth.
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.nombre,
    required super.email,
    super.avatarUrl = '',
    super.rol = 'user',
    required super.creadoEn,
  });

  /// Factory constructor para crear [UserModel] desde un mapa JSON / Firestore.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      rol: json['rol'] as String? ?? 'user',
      creadoEn: json['creadoEn'] != null
          ? (json['creadoEn'] is String
              ? DateTime.tryParse(json['creadoEn'] as String) ?? DateTime.now()
              : DateTime.fromMillisecondsSinceEpoch(
                  json['creadoEn'] as int? ?? DateTime.now().millisecondsSinceEpoch,
                ))
          : DateTime.now(),
    );
  }

  /// Factory constructor para crear [UserModel] a partir de un [User] de Firebase Auth.
  factory UserModel.fromFirebaseUser(User user, {String rol = 'user'}) {
    return UserModel(
      uid: user.uid,
      nombre: user.displayName?.isNotEmpty == true
          ? user.displayName!
          : (user.email?.split('@').first ?? 'Estudiante ESCOM'),
      email: user.email ?? '',
      avatarUrl: user.photoURL ?? '',
      rol: rol,
      creadoEn: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  /// Factory constructor para crear [UserModel] a partir de una [UserEntity].
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      nombre: entity.nombre,
      email: entity.email,
      avatarUrl: entity.avatarUrl,
      rol: entity.rol,
      creadoEn: entity.creadoEn,
    );
  }

  /// Convierte el modelo a un mapa JSON serializable.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nombre': nombre,
      'email': email,
      'avatarUrl': avatarUrl,
      'rol': rol,
      'creadoEn': creadoEn.toIso8601String(),
    };
  }

  @override
  UserModel copyWith({
    String? uid,
    String? nombre,
    String? email,
    String? avatarUrl,
    String? rol,
    DateTime? creadoEn,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rol: rol ?? this.rol,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}
