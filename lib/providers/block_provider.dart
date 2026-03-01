import 'package:flutter/foundation.dart';
import 'package:worshippro/models/liturgy_block.dart';
import 'package:worshippro/models/song.dart';
import 'package:worshippro/services/liturgy_service.dart';

/// Provider para gestionar bloques de culto
/// Versión 1.1: Multi-tenant con organizationId
class BlockProvider with ChangeNotifier {
  final LiturgyService _liturgyService = LiturgyService();

  bool _isLoading = false;
  String? _error;
  String? _organizationId; // Nueva: ID de la organización activa

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Establece el ID de la organización activa
  void setOrganizationId(String organizationId) {
    _organizationId = organizationId;
  }

  /// Crea un nuevo bloque
  Future<String?> createBlock(String liturgyId, LiturgyBlock block) async {
    if (_organizationId == null) {
      _error = 'No hay organización activa';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final blockId = await _liturgyService.createBlock(_organizationId!, liturgyId, block);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return blockId;
    } catch (e) {
      _error = 'Error al crear bloque: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Actualiza un bloque existente
  Future<bool> updateBlock(String liturgyId, LiturgyBlock block) async {
    if (_organizationId == null) {
      _error = 'No hay organización activa';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _liturgyService.updateBlock(_organizationId!, liturgyId, block);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar bloque: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Elimina un bloque
  Future<bool> deleteBlock(String liturgyId, String blockId) async {
    if (_organizationId == null) {
      _error = 'No hay organización activa';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _liturgyService.deleteBlock(_organizationId!, liturgyId, blockId);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al eliminar bloque: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Crea una nueva canción en un bloque
  Future<String?> createSong(
      String liturgyId, String blockId, Song song) async {
    if (_organizationId == null) {
      _error = 'No hay organización activa';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final songId =
          await _liturgyService.createSong(_organizationId!, liturgyId, blockId, song);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return songId;
    } catch (e) {
      _error = 'Error al crear canción: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Actualiza una canción existente
  Future<bool> updateSong(
      String liturgyId, String blockId, Song song) async {
    if (_organizationId == null) {
      _error = 'No hay organización activa';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _liturgyService.updateSong(_organizationId!, liturgyId, blockId, song);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar canción: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Elimina una canción
  Future<bool> deleteSong(
      String liturgyId, String blockId, String songId) async {
    if (_organizationId == null) {
      _error = 'No hay organización activa';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _liturgyService.deleteSong(_organizationId!, liturgyId, blockId, songId);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al eliminar canción: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Limpia el error actual
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
