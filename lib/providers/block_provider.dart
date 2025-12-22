import 'package:flutter/foundation.dart';
import 'package:worshippro/models/liturgy_block.dart';
import 'package:worshippro/models/song.dart';
import 'package:worshippro/services/liturgy_service.dart';

/// Provider para gestionar bloques de culto
class BlockProvider with ChangeNotifier {
  final LiturgyService _liturgyService = LiturgyService();

  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Crea un nuevo bloque
  Future<String?> createBlock(String liturgyId, LiturgyBlock block) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final blockId = await _liturgyService.createBlock(liturgyId, block);
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _liturgyService.updateBlock(liturgyId, block);
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _liturgyService.deleteBlock(liturgyId, blockId);
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final songId =
          await _liturgyService.createSong(liturgyId, blockId, song);
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _liturgyService.updateSong(liturgyId, blockId, song);
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _liturgyService.deleteSong(liturgyId, blockId, songId);
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
