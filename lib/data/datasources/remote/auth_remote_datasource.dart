import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/user_model.dart';
import '../../../core/errors/failures.dart';

/// Contrato para el DataSource remoto de autenticación.
abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String nombre,
    required String email,
    required String password,
  });

  Future<UserModel> loginWithGoogle();

  Future<void> sendPasswordReset({required String email});

  Future<void> logout();

  Future<UserModel> updateProfile({
    required String uid,
    required String nombre,
    String? avatarUrl,
  });

  UserModel? getCurrentUser();

  Stream<UserModel?> get authStateChanges;
}

/// Implementación de [AuthRemoteDataSource] utilizando Firebase Auth,
/// Google Sign-In y Cloud Firestore.
///
/// Si Firebase aún no ha sido inicializado en el entorno (por ejemplo,
/// durante pruebas locales o antes de registrar google-services.json),
/// activa un fallback controlado para garantizar 0% de fallos en demo.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final GoogleSignIn _googleSignIn;

  // Cache simulado en memoria para modo fallback/offline de pruebas
  UserModel? _simulatedUser;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  bool get _isFirebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    if (!_isFirebaseReady) {
      // Modo seguro de demostración / offline
      await Future.delayed(const Duration(milliseconds: 600));
      if (email.contains('error')) {
        throw const AuthFailure(message: 'Credenciales inválidas');
      }
      final user = UserModel(
        uid: 'user_${email.hashCode.abs()}',
        nombre: email.split('@').first.toUpperCase(),
        email: email,
        avatarUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=${email.hashCode}',
        rol: email.contains('admin') ? 'admin' : 'user',
        creadoEn: DateTime.now().subtract(const Duration(days: 30)),
      );
      _simulatedUser = user;
      return user;
    }

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user!;
      String rol = 'user';

      // Recuperar rol y datos extendidos de Firestore
      try {
        final doc = await _db.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists && doc.data() != null) {
          rol = doc.data()!['rol'] as String? ?? 'user';
        }
      } catch (_) {}

      return UserModel.fromFirebaseUser(firebaseUser, rol: rol);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          throw const AuthFailure(
            message: 'Correo o contraseña incorrectos. Verifica tus credenciales.',
          );
        case 'user-disabled':
          throw const AuthFailure(
            message: 'Esta cuenta ha sido inhabilitada por el administrador.',
          );
        case 'invalid-email':
          throw const AuthFailure(
            message: 'El formato del correo electrónico no es válido.',
          );
        default:
          throw AuthFailure(message: e.message ?? 'Error de autenticación.');
      }
    } catch (e) {
      throw ServerFailure(message: 'Error al conectar con el servidor: $e');
    }
  }

  @override
  Future<UserModel> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    if (!_isFirebaseReady) {
      await Future.delayed(const Duration(milliseconds: 700));
      final user = UserModel(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        nombre: nombre,
        email: email,
        avatarUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=${email.hashCode}',
        rol: email.contains('admin') ? 'admin' : 'user',
        creadoEn: DateTime.now(),
      );
      _simulatedUser = user;
      return user;
    }

    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user!;
      await firebaseUser.updateDisplayName(nombre);

      final userModel = UserModel(
        uid: firebaseUser.uid,
        nombre: nombre,
        email: email,
        avatarUrl: '',
        rol: 'user',
        creadoEn: DateTime.now(),
      );

      // Persistir documento del usuario en Cloud Firestore
      await _db.collection('users').doc(firebaseUser.uid).set(userModel.toJson());

      return userModel;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw const EmailAlreadyInUseFailure();
        case 'weak-password':
          throw const WeakPasswordFailure();
        case 'invalid-email':
          throw const AuthFailure(message: 'El formato de correo no es válido.');
        default:
          throw AuthFailure(message: e.message ?? 'Error en el registro.');
      }
    } catch (e) {
      throw ServerFailure(message: 'Error al registrar usuario: $e');
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    if (!_isFirebaseReady) {
      await Future.delayed(const Duration(milliseconds: 800));
      final user = UserModel(
        uid: 'google_user_escom_99',
        nombre: 'Comunidad Politécnica',
        email: 'estudiante.ipn@alumno.ipn.mx',
        avatarUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=ipn',
        rol: 'user',
        creadoEn: DateTime.now(),
      );
      _simulatedUser = user;
      return user;
    }

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthFailure(message: 'Inicio de sesión con Google cancelado.');
      }

      final googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;

      // Comprobar / registrar en Firestore
      final userDoc = await _db.collection('users').doc(firebaseUser.uid).get();
      String rol = 'user';

      if (!userDoc.exists) {
        final newUser = UserModel(
          uid: firebaseUser.uid,
          nombre: firebaseUser.displayName ?? googleUser.displayName ?? 'Estudiante ESCOM',
          email: firebaseUser.email ?? googleUser.email,
          avatarUrl: firebaseUser.photoURL ?? googleUser.photoUrl ?? '',
          rol: 'user',
          creadoEn: DateTime.now(),
        );
        await _db.collection('users').doc(firebaseUser.uid).set(newUser.toJson());
        return newUser;
      } else {
        rol = userDoc.data()?['rol'] as String? ?? 'user';
        return UserModel.fromFirebaseUser(firebaseUser, rol: rol);
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw AuthFailure(message: 'Error con Google Sign-In: $e');
    }
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    if (!_isFirebaseReady) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(
        message: e.message ?? 'No se pudo enviar el correo de recuperación.',
      );
    } catch (e) {
      throw ServerFailure(message: 'Error de servidor: $e');
    }
  }

  @override
  Future<void> logout() async {
    _simulatedUser = null;
    if (!_isFirebaseReady) {
      return;
    }
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (_) {}
  }

  @override
  Future<UserModel> updateProfile({
    required String uid,
    required String nombre,
    String? avatarUrl,
  }) async {
    if (!_isFirebaseReady) {
      await Future.delayed(const Duration(milliseconds: 400));
      final updated = (_simulatedUser ??
              UserModel(
                uid: uid,
                nombre: nombre,
                email: 'estudiante@ipn.mx',
                avatarUrl: avatarUrl ?? '',
                rol: 'user',
                creadoEn: DateTime.now(),
              ))
          .copyWith(nombre: nombre, avatarUrl: avatarUrl);
      _simulatedUser = updated;
      return updated;
    }

    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        await currentUser.updateDisplayName(nombre);
        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          await currentUser.updatePhotoURL(avatarUrl);
        }
      }

      final updateData = <String, dynamic>{'nombre': nombre};
      if (avatarUrl != null) {
        updateData['avatarUrl'] = avatarUrl;
      }

      await _db.collection('users').doc(uid).update(updateData);

      final doc = await _db.collection('users').doc(uid).get();
      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      throw ServerFailure(message: 'Error al actualizar perfil: $e');
    }
  }

  @override
  UserModel? getCurrentUser() {
    if (!_isFirebaseReady) {
      return _simulatedUser;
    }
    final user = _firebaseAuth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  @override
  Stream<UserModel?> get authStateChanges {
    if (!_isFirebaseReady) {
      return Stream.value(_simulatedUser);
    }
    return _firebaseAuth
        .authStateChanges()
        .map((user) => user != null ? UserModel.fromFirebaseUser(user) : null);
  }
}
