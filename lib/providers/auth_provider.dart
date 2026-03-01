import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../models/user.dart' as app_models;

/// Estados de autenticación
enum AuthStatus {
  initial, // Estado inicial
  authenticated, // Usuario autenticado
  unauthenticated, // Usuario no autenticado
  loading, // Cargando operación de auth
}

/// Provider de Autenticación
/// Gestiona el estado de autenticación de la aplicación
class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    // Escuchar cambios de estado de autenticación
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  // Estado
  AuthStatus _status = AuthStatus.initial;
  app_models.User? _currentUser;
  String? _errorMessage;
  bool _isLoggingIn = false; // Bandera para prevenir race conditions durante login

  // Getters
  AuthStatus get status => _status;
  app_models.User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  String? get currentUserId => _currentUser?.id;

  // ============================================================================
  // INICIALIZACIÓN
  // ============================================================================

  /// Inicializar provider y verificar estado de autenticación
  Future<void> initialize() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      final user = await _authService.getCurrentUser();

      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } else {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
      }

      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  /// Listener de cambios de estado de autenticación de Firebase
  void _onAuthStateChanged(firebase_auth.User? firebaseUser) async {
    print('🔵 AuthProvider._onAuthStateChanged: LLAMADO - firebaseUser: ${firebaseUser?.email}, _isLoggingIn: $_isLoggingIn, _currentUser: ${_currentUser?.email}, activeOrgId: ${_currentUser?.activeOrganizationId}');
    
    // Si estamos en medio de un login, ignorar este callback para evitar sobrescribir el estado
    if (_isLoggingIn) {
      print('🔵 AuthProvider._onAuthStateChanged: ⚠️ IGNORADO - login en progreso');
      return;
    }
    
    // Si ya estamos autenticados y el usuario es el mismo, ignorar para evitar race conditions
    if (firebaseUser != null && _status == AuthStatus.authenticated && _currentUser != null && _currentUser!.id == firebaseUser.uid) {
      print('🔵 AuthProvider._onAuthStateChanged: ⚠️ IGNORADO - usuario ya autenticado con mismo UID');
      return;
    }
    
    if (firebaseUser == null) {
      print('🔵 AuthProvider._onAuthStateChanged: Usuario es null, desautenticando');
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } else {
      // Obtener datos completos del usuario desde Firestore
      try {
        print('🔵 AuthProvider._onAuthStateChanged: Usuario detectado, esperando 500ms para Firestore');
        // Pequeño delay para asegurar que Firestore esté sincronizado
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Re-verificar que no se haya iniciado un login durante el delay
        if (_isLoggingIn || (_status == AuthStatus.authenticated && _currentUser != null && _currentUser!.id == firebaseUser.uid)) {
          print('🔵 AuthProvider._onAuthStateChanged: ⚠️ IGNORADO post-delay - estado cambió durante espera');
          return;
        }
        
        print('🔵 AuthProvider._onAuthStateChanged: Recargando usuario desde Firestore');
        final user = await _authService.getCurrentUser();
        if (user != null) {
          print('🔵 AuthProvider._onAuthStateChanged: Usuario cargado - activeOrganizationId: ${user.activeOrganizationId}');
          _currentUser = user;
          _status = AuthStatus.authenticated;
          _errorMessage = null;
        } else {
          // Si no se encuentra el usuario en Firestore, algo salió mal
          print('🔵 AuthProvider._onAuthStateChanged: Usuario NO encontrado en Firestore');
          _currentUser = null;
          _status = AuthStatus.unauthenticated;
          _errorMessage = 'Error al cargar datos del usuario';
        }
        print('🔵 AuthProvider._onAuthStateChanged: Notificando listeners');
        notifyListeners();
      } catch (e) {
        _errorMessage = 'Error al cargar usuario: $e';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    }
  }

  // ============================================================================
  // REGISTRO
  // ============================================================================

  /// Registrar nuevo usuario con email y contraseña
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoggingIn = true; // Activar bandera
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Asegurar que el nuevo usuario no tenga organización activa
      print('🔵 AuthProvider.registerWithEmail: Usuario registrado, verificando activeOrganizationId');
      if (user.activeOrganizationId != null) {
        print('🔵 AuthProvider.registerWithEmail: Limpiando activeOrganizationId en Firestore');
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .update({'activeOrganizationId': null});
        _currentUser = user.copyWith(activeOrganizationId: null);
      } else {
        _currentUser = user;
      }
      
      _status = AuthStatus.authenticated;
      
      print('🔵 AuthProvider.registerWithEmail: Registro completo, notificando listeners');
      _isLoggingIn = false; // Desactivar bandera ANTES de notificar
      notifyListeners();

      return true;
    } on AuthException catch (e) {
      _isLoggingIn = false;
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      print('🔴 AuthProvider.registerWithEmail: AuthException capturada - $_errorMessage');
      notifyListeners();
      return false;
    } catch (e) {
      _isLoggingIn = false;
      _errorMessage = 'Error inesperado: $e';
      _status = AuthStatus.unauthenticated;
      print('🔴 AuthProvider.registerWithEmail: Error inesperado - $_errorMessage');
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // LOGIN
  // ============================================================================

  /// Iniciar sesión con email y contraseña
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _isLoggingIn = true; // Activar bandera
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      // CRÍTICO: Limpiar organización activa ANTES de notificar
      // Esto asegura que cuando el AuthGuard se reconstruya, vea el valor null
      print('🔵 AuthProvider.signInWithEmail: Limpiando activeOrganizationId en Firestore');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .update({'activeOrganizationId': null});
      
      print('🔵 AuthProvider.signInWithEmail: Firestore actualizado, actualizando estado local');
      // Actualizar el usuario con el cambio
      _currentUser = user.copyWith(activeOrganizationId: null);
      _status = AuthStatus.authenticated;
      
      // Notificar para que el AuthGuard redirija a OrganizationSelectorScreen
      print('🔵 AuthProvider.signInWithEmail: Notificando listeners (activeOrganizationId: ${_currentUser?.activeOrganizationId})');
      _isLoggingIn = false; // Desactivar bandera ANTES de notificar
      notifyListeners();
      
      return true;
    } on AuthException catch (e) {
      _isLoggingIn = false; // Desactivar bandera en caso de error
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      print('🔴 AuthProvider.signInWithEmail: AuthException capturada - $_errorMessage');
      notifyListeners();
      return false;
    } catch (e) {
      _isLoggingIn = false; // Desactivar bandera en caso de error
      _errorMessage = 'Error inesperado: $e';
      _status = AuthStatus.unauthenticated;
      print('🔴 AuthProvider.signInWithEmail: Error inesperado - $_errorMessage');
      notifyListeners();
      return false;
    }
  }

  /// Iniciar sesión con Google
  Future<bool> signInWithGoogle() async {
    try {
      _isLoggingIn = true; // Activar bandera
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.signInWithGoogle();

      // El service ya limpia activeOrganizationId en Firestore
      print('🔵 AuthProvider.signInWithGoogle: Usuario obtenido, actualizando estado local');
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      
      // Notificar para que el AuthGuard redirija a OrganizationSelectorScreen
      print('🔵 AuthProvider.signInWithGoogle: Notificando listeners (activeOrganizationId: ${_currentUser?.activeOrganizationId})');
      _isLoggingIn = false; // Desactivar bandera ANTES de notificar
      print('🔵 AuthProvider.signInWithGoogle: Bandera _isLoggingIn desactivada, _onAuthStateChanged puede ejecutarse ahora');
      notifyListeners();
      
      return true;
    } on AuthException catch (e) {
      _isLoggingIn = false; // Desactivar bandera en caso de error
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      print('🔴 AuthProvider.signInWithGoogle: AuthException capturada - $_errorMessage');
      notifyListeners();
      return false;
    } catch (e) {
      _isLoggingIn = false; // Desactivar bandera en caso de error
      _errorMessage = 'Error inesperado: $e';
      _status = AuthStatus.unauthenticated;
      print('🔴 AuthProvider.signInWithGoogle: Error inesperado - $_errorMessage');
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // ACCOUNT LINKING
  // ============================================================================

  /// Vincular cuenta de Google a usuario actual
  Future<bool> linkGoogleAccount() async {
    try {
      _errorMessage = null;
      notifyListeners();

      await _authService.linkGoogleAccount();

      // Recargar usuario para obtener authProviders actualizados
      final user = await _authService.getCurrentUser();
      _currentUser = user;
      notifyListeners();

      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // RECUPERACIÓN DE CONTRASEÑA
  // ============================================================================

  /// Enviar email de recuperación de contraseña
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _errorMessage = null;
      notifyListeners();

      await _authService.sendPasswordResetEmail(email);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // CERRAR SESIÓN
  // ============================================================================

  /// Cerrar sesión del usuario actual
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión: $e';
      notifyListeners();
    }
  }

  // ============================================================================
  // ACTUALIZAR USUARIO
  // ============================================================================

  /// Actualizar información del usuario actual
  /// Se llama cuando se modifica organizationIds o activeOrganizationId
  Future<void> refreshUser() async {
    try {
      final user = await _authService.getCurrentUser();
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al actualizar usuario: $e';
      notifyListeners();
    }
  }

  /// Actualizar organización activa del usuario
  void updateActiveOrganization(String? organizationId) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        activeOrganizationId: organizationId,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // ============================================================================
  // LIMPIAR ERRORES
  // ============================================================================

  /// Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
