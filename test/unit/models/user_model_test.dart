import 'package:flutter_test/flutter_test.dart';
import 'package:cafeteria_escom/data/models/user_model.dart';
import 'package:cafeteria_escom/domain/entities/user_entity.dart';

void main() {
  group('UserModel Tests', () {
    final tDateTime = DateTime(2026, 11, 11, 12, 0, 0);
    final tUserModel = UserModel(
      uid: 'user_escom_123',
      nombre: 'Alumno Politécnico',
      email: 'alumno@alumno.ipn.mx',
      avatarUrl: 'https://example.com/avatar.png',
      rol: 'user',
      creadoEn: tDateTime,
    );

    test('debe ser un subtipo de UserEntity', () {
      expect(tUserModel, isA<UserEntity>());
    });

    test('toJson debe serializar correctamente a Map<String, dynamic>', () {
      final jsonMap = tUserModel.toJson();

      expect(jsonMap['uid'], 'user_escom_123');
      expect(jsonMap['nombre'], 'Alumno Politécnico');
      expect(jsonMap['email'], 'alumno@alumno.ipn.mx');
      expect(jsonMap['avatarUrl'], 'https://example.com/avatar.png');
      expect(jsonMap['rol'], 'user');
      expect(jsonMap['creadoEn'], tDateTime.toIso8601String());
    });

    test('fromJson debe deserializar correctamente desde Map<String, dynamic>', () {
      final jsonMap = {
        'uid': 'user_escom_456',
        'nombre': 'Profesor ESCOM',
        'email': 'profesor@ipn.mx',
        'avatarUrl': 'https://example.com/prof.png',
        'rol': 'admin',
        'creadoEn': tDateTime.toIso8601String(),
      };

      final result = UserModel.fromJson(jsonMap);

      expect(result.uid, 'user_escom_456');
      expect(result.nombre, 'Profesor ESCOM');
      expect(result.email, 'profesor@ipn.mx');
      expect(result.avatarUrl, 'https://example.com/prof.png');
      expect(result.rol, 'admin');
      expect(result.creadoEn, tDateTime);
    });

    test('copyWith debe retornar una nueva instancia con valores modificados', () {
      final updated = tUserModel.copyWith(
        nombre: 'Ingeniero Graduado',
        avatarUrl: 'https://example.com/new.png',
      );

      expect(updated.nombre, 'Ingeniero Graduado');
      expect(updated.avatarUrl, 'https://example.com/new.png');
      expect(updated.email, tUserModel.email); // Se preserva
      expect(updated.uid, tUserModel.uid);     // Se preserva
    });
  });
}
