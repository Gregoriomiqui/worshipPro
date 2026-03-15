import 'package:flutter/foundation.dart';
import 'package:worshippro/models/liturgy.dart';
import 'package:worshippro/services/liturgy_service.dart';

/// Provider para gestionar los cultos
/// Versión 1.1: Multi-tenant con organizationId
class LiturgyProvider with ChangeNotifier {
  final LiturgyService _liturgyService = LiturgyService();

  List<Liturgy> _liturgies = [];
  Liturgy? _currentLiturgy;
  bool _isLoading = false;
  String? _error;
  String? _organizationId; // Nueva: ID de la organización activa
  String? _currentUserId; // Nueva: ID del usuario actual

  // Getters
  List<Liturgy> get liturgies => _liturgies;
  Liturgy? get currentLiturgy => _currentLiturgy;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get organizationId => _organizationId;

  /// Establece el contexto de organización y usuario
  void setContext(String organizationId, String userId) {
    _organizationId = organizationId;
    _currentUserId = userId;
    // Reinicializar listener con nueva organización
    initLiturgiesListener();
  }

  /// Inicializa la escucha de liturgias desde Firestore
  void initLiturgiesListener() {
    if (_organizationId == null) {
      _liturgies = [];
      notifyListeners();
      return;
    }

    _liturgyService.getLiturgies(_organizationId!).listen(
      (liturgies) {
        _liturgies = liturgies;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Error al cargar liturgias: $error';
        notifyListeners();
      },
    );
  }

  /// Carga una liturgia específica con todos sus bloques
  Future<void> loadLiturgy(String liturgyId) async {
    if (_organizationId == null) {
      _error = 'No hay organización activa';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentLiturgy = await _liturgyService.getLiturgyById(_organizationId!, liturgyId);
      _error = null;
    } catch (e) {
      _error = 'Error al cargar liturgia: $e';
      _currentLiturgy = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crea una nueva liturgia
  Future<String?> createLiturgy(Liturgy liturgy) async {
    if (_organizationId == null || _currentUserId == null) {
      _error = 'No hay organización activa';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final liturgyId = await _liturgyService.createLiturgy(_organizationId!, liturgy, _currentUserId!);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return liturgyId;
    } catch (e) {
      _error = 'Error al crear liturgia: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Actualiza una liturgia existente
  Future<bool> updateLiturgy(Liturgy liturgy) async {
    if (_organizationId == null) {
      _error = 'No hay organización activa';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _liturgyService.updateLiturgy(_organizationId!, liturgy);
      
      // Actualizar liturgia actual si es la misma
      if (_currentLiturgy?.id == liturgy.id) {
        _currentLiturgy = liturgy;
      }
      
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar liturgia: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Duplica una liturgia existente
  Future<String?> duplicateLiturgy(String liturgyId) async {
    if (_organizationId == null) {
      _error = 'No hay organización activa';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newLiturgyId = await _liturgyService.duplicateLiturgy(_organizationId!, liturgyId);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return newLiturgyId;
    } catch (e) {
      _error = 'Error al duplicar liturgia: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Elimina una liturgia
  Future<bool> deleteLiturgy(String liturgyId) async {
    if (_organizationId == null) {
      _error = 'No hay organización activa';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _liturgyService.deleteLiturgy(_organizationId!, liturgyId);
      
      // Limpiar liturgia actual si es la que se eliminó
      if (_currentLiturgy?.id == liturgyId) {
        _currentLiturgy = null;
      }
      
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al eliminar liturgia: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Recarga la liturgia actual
  Future<void> refreshCurrentLiturgy() async {
    if (_currentLiturgy != null) {
      await loadLiturgy(_currentLiturgy!.id);
    }
  }

  /// Limpia el error actual
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Limpia todos los datos (útil para logout)
  void clear() {
    _liturgies = [];
    _currentLiturgy = null;
    _isLoading = false;
    _error = null;
    _organizationId = null;
    _currentUserId = null;
    notifyListeners();
  }
}
