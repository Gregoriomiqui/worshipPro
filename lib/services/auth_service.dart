import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_models;

/// Excepción personalizada para errores de autenticación
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Servicio de Autenticación
/// Maneja autenticación con Email/Password y Google Sign-In
/// Incluye Account Linking automático
class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream del usuario actual de Firebase Auth
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  /// Usuario actual de Firebase Auth
  firebase_auth.User? get currentFirebaseUser => _auth.currentUser;

  /// ID del usuario actual
  String? get currentUserId => _auth.currentUser?.uid;

  /// Email del usuario actual
  String? get currentUserEmail => _auth.currentUser?.email;

  /// Verificar si el usuario está autenticado
  bool get isAuthenticated => _auth.currentUser != null;

  // ============================================================================
  // REGISTRO CON EMAIL Y PASSWORD
  // ============================================================================

  /// Registrar nuevo usuario con email y contraseña
  Future<app_models.User> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // 1. Verificar si ya existe cuenta con este email
      final signInMethods = await _auth.fetchSignInMethodsForEmail(email);

      if (signInMethods.isNotEmpty) {
        // Ya existe una cuenta con este email
        throw AuthException(
          'Ya existe una cuenta con este email. Por favor inicia sesión.',
          code: 'email-already-in-use',
        );
      }

      // 2. Crear usuario en Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user!;

      // 3. Actualizar displayName en Firebase Auth
      await firebaseUser.updateDisplayName(displayName);
      await firebaseUser.reload();

      // 4. Crear documento de usuario en Firestore
      final now = DateTime.now();
      final appUser = app_models.User(
        id: firebaseUser.uid,
        email: email,
        displayName: displayName,
        photoURL: null,
        organizationIds: [],
        activeOrganizationId: null,
        authProviders: ['password'],
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.collection('users').doc(firebaseUser.uid).set(
            appUser.toFirestore(),
          );

      return appUser;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Error al registrar usuario: $e');
    }
  }

  // ============================================================================
  // LOGIN CON EMAIL Y PASSWORD
  // ============================================================================

  /// Iniciar sesión con email y contraseña
  Future<app_models.User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Autenticar con Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user!;

      // 2. Obtener o crear documento de usuario en Firestore
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        // Usuario existe en Auth pero no en Firestore (caso edge)
        final now = DateTime.now();
        final appUser = app_models.User(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          displayName: firebaseUser.displayName ?? email.split('@')[0],
          photoURL: firebaseUser.photoURL,
          organizationIds: [],
          activeOrganizationId: null,
          authProviders: ['password'],
          createdAt: now,
          updatedAt: now,
        );

        await _firestore.collection('users').doc(firebaseUser.uid).set(
              appUser.toFirestore(),
            );

        return appUser;
      }

      return app_models.User.fromFirestore(userDoc);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Error al iniciar sesión: $e');
    }
  }

  // ============================================================================
  // GOOGLE SIGN-IN CON ACCOUNT LINKING
  // ============================================================================

  /// Iniciar sesión con Google
  /// Incluye lógica de Account Linking si el email ya existe
  Future<app_models.User> signInWithGoogle() async {
    try {
      // 1. Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException('Inicio de sesión con Google cancelado');
      }

      // 2. Obtener credenciales de Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Iniciar sesión con credencial de Google en Firebase
      final email = googleUser.email;
      firebase_auth.UserCredential userCredential;

      try {
        userCredential = await _auth.signInWithCredential(credential);
      } on firebase_auth.FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          throw AuthException(
            'Ya existe una cuenta con este email ($email). Por favor inicia sesión con tu contraseña primero, luego podrás vincular tu cuenta de Google desde la configuración.',
            code: 'account-exists-with-different-credential',
          );
        }
        rethrow;
      }

      final firebaseUser = userCredential.user!;

      // 4. Esperar a que el token de auth se propague a Firestore
      // Esto es necesario porque signInWithCredential puede tardar en
      // propagar el token a las reglas de seguridad de Firestore
      await Future.delayed(const Duration(milliseconds: 500));
      // Forzar refresh del token para asegurar que Firestore lo reconozca
      await firebaseUser.getIdToken(true);

      // 5. Obtener o crear documento de usuario en Firestore (con retry)
      DocumentSnapshot userDoc;
      try {
        userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      } catch (e) {
        // Retry una vez más después de un delay adicional
        await Future.delayed(const Duration(seconds: 1));
        userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      }

      if (!userDoc.exists) {
        // Primer inicio de sesión con Google
        final now = DateTime.now();
        final appUser = app_models.User(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          displayName: firebaseUser.displayName ?? email.split('@')[0],
          photoURL: firebaseUser.photoURL,
          organizationIds: [],
          activeOrganizationId: null,
          authProviders: ['google.com'],
          createdAt: now,
          updatedAt: now,
        );

        await _firestore.collection('users').doc(firebaseUser.uid).set(
              appUser.toFirestore(),
            );

        return appUser;
      } else {
        // Usuario ya existe, actualizar authProviders (conservar activeOrganizationId)
        final appUser = app_models.User.fromFirestore(userDoc);
        final Map<String, dynamic> updates = {
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        };

        if (!appUser.authProviders.contains('google.com')) {
          updates['authProviders'] = [...appUser.authProviders, 'google.com'];
        }

        if (updates.containsKey('authProviders')) {
          await _firestore.collection('users').doc(firebaseUser.uid).update(updates);
        }

        return appUser.copyWith(
          authProviders: updates.containsKey('authProviders')
              ? List<String>.from(updates['authProviders'])
              : appUser.authProviders,
          updatedAt: DateTime.now(),
        );
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Error al iniciar sesión con Google: $e');
    }
  }

  // ============================================================================
  // ACCOUNT LINKING (Vincular Google a cuenta existente)
  // ============================================================================

  /// Vincular cuenta de Google a usuario ya autenticado con email/password
  Future<void> linkGoogleAccount() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw AuthException('Debes estar autenticado para vincular cuentas');
      }

      // 1. Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException('Vinculación cancelada');
      }

      // 2. Obtener credenciales de Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Vincular credenciales
      await currentUser.linkWithCredential(credential);

      // 4. Actualizar authProviders en Firestore
      await _firestore.collection('users').doc(currentUser.uid).update({
        'authProviders': FieldValue.arrayUnion(['google.com']),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        throw AuthException(
          'Esta cuenta de Google ya está vinculada a otro usuario',
        );
      }
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Error al vincular cuenta de Google: $e');
    }
  }

  // ============================================================================
  // RECUPERACIÓN DE CONTRASEÑA
  // ============================================================================

  /// Enviar email de recuperación de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Error al enviar email de recuperación: $e');
    }
  }

  // ============================================================================
  // CERRAR SESIÓN
  // ============================================================================

  /// Cerrar sesión del usuario actual
  Future<void> signOut() async {
    try {
      // Desconectar Google completamente para permitir elegir cuenta al re-login
      try {
        await _googleSignIn.disconnect();
      } catch (_) {
        // Si disconnect falla (ej: no estaba logueado con Google), ignorar
        try {
          await _googleSignIn.signOut();
        } catch (_) {}
      }
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Error al cerrar sesión: $e');
    }
  }

  // ============================================================================
  // OBTENER USUARIO ACTUAL
  // ============================================================================

  /// Obtener datos del usuario actual desde Firestore
  Future<app_models.User?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) return null;

      return app_models.User.fromFirestore(userDoc);
    } catch (e) {
      throw AuthException('Error al obtener usuario actual: $e');
    }
  }

  // ============================================================================
  // HELPERS PRIVADOS
  // ============================================================================

  /// Manejar excepciones de Firebase Auth
  AuthException _handleFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
    String message;

    switch (e.code) {
      case 'user-not-found':
        message = 'No existe una cuenta con este email';
        break;
      case 'wrong-password':
        message = 'Contraseña incorrecta';
        break;
      case 'email-already-in-use':
        message = 'Ya existe una cuenta con este email';
        break;
      case 'weak-password':
        message = 'La contraseña debe tener al menos 6 caracteres';
        break;
      case 'invalid-email':
        message = 'Email inválido';
        break;
      case 'user-disabled':
        message = 'Esta cuenta ha sido deshabilitada';
        break;
      case 'too-many-requests':
        message = 'Demasiados intentos. Por favor intenta más tarde';
        break;
      case 'operation-not-allowed':
        message = 'Operación no permitida';
        break;
      case 'account-exists-with-different-credential':
        message = 'Ya existe una cuenta con este email usando otro método de autenticación';
        break;
      default:
        message = e.message ?? 'Error de autenticación: ${e.code}';
    }

    return AuthException(message, code: e.code);
  }
}
