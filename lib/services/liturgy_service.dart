import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:worshippro/models/liturgy.dart';
import 'package:worshippro/models/liturgy_block.dart';
import 'package:worshippro/models/song.dart';

/// Servicio para gestionar las liturgias en Firebase Firestore
class LiturgyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Colección principal de liturgias
  CollectionReference get _liturgiesCollection =>
      _firestore.collection('liturgias');

  // ==================== LITURGIAS ====================

  /// Obtiene todas las liturgias ordenadas por fecha descendente
  Stream<List<Liturgy>> getLiturgies() {
    return _liturgiesCollection
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Liturgy.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// Obtiene una liturgia específica con todos sus bloques y canciones
  Future<Liturgy?> getLiturgyById(String liturgyId) async {
    try {
      final liturgyDoc = await _liturgiesCollection.doc(liturgyId).get();
      if (!liturgyDoc.exists) return null;

      final liturgy =
          Liturgy.fromMap(liturgyDoc.data() as Map<String, dynamic>, liturgyDoc.id);

      // Cargar bloques
      final blocks = await getBlocks(liturgyId);

      return liturgy.copyWith(bloques: blocks);
    } catch (e) {
      print('Error al obtener liturgia: $e');
      return null;
    }
  }

  /// Crea una nueva liturgia
  Future<String> createLiturgy(Liturgy liturgy) async {
    try {
      final now = DateTime.now();
      final liturgyData = liturgy.toMap();
      liturgyData['createdAt'] = Timestamp.fromDate(now);
      liturgyData['updatedAt'] = Timestamp.fromDate(now);

      final docRef = await _liturgiesCollection.add(liturgyData);
      return docRef.id;
    } catch (e) {
      print('Error al crear liturgia: $e');
      rethrow;
    }
  }

  /// Actualiza una liturgia existente
  Future<void> updateLiturgy(Liturgy liturgy) async {
    try {
      final liturgyData = liturgy.toMap();
      liturgyData['updatedAt'] = Timestamp.fromDate(DateTime.now());

      await _liturgiesCollection.doc(liturgy.id).update(liturgyData);
    } catch (e) {
      print('Error al actualizar liturgia: $e');
      rethrow;
    }
  }

  /// Elimina una liturgia y todos sus bloques y canciones
  Future<void> deleteLiturgy(String liturgyId) async {
    try {
      // Eliminar todos los bloques y sus canciones
      final blocks = await _liturgiesCollection
          .doc(liturgyId)
          .collection('bloques')
          .get();

      for (var blockDoc in blocks.docs) {
        // Eliminar canciones del bloque
        final songs = await blockDoc.reference.collection('canciones').get();
        for (var songDoc in songs.docs) {
          await songDoc.reference.delete();
        }
        // Eliminar bloque
        await blockDoc.reference.delete();
      }

      // Eliminar liturgia
      await _liturgiesCollection.doc(liturgyId).delete();
    } catch (e) {
      print('Error al eliminar liturgia: $e');
      rethrow;
    }
  }

  // ==================== BLOQUES ====================

  /// Obtiene todos los bloques de una liturgia ordenados por orden
  Future<List<LiturgyBlock>> getBlocks(String liturgyId) async {
    try {
      final snapshot = await _liturgiesCollection
          .doc(liturgyId)
          .collection('bloques')
          .orderBy('orden')
          .get();

      final blocks = <LiturgyBlock>[];

      for (var doc in snapshot.docs) {
        final block =
            LiturgyBlock.fromMap(doc.data(), doc.id);

        // Si es adoración, cargar canciones
        if (block.isAdoracion) {
          final songs = await getSongs(liturgyId, block.id);
          blocks.add(block.copyWith(canciones: songs));
        } else {
          blocks.add(block);
        }
      }

      return blocks;
    } catch (e) {
      print('Error al obtener bloques: $e');
      return [];
    }
  }

  /// Crea un nuevo bloque en una liturgia
  Future<String> createBlock(String liturgyId, LiturgyBlock block) async {
    try {
      final docRef = await _liturgiesCollection
          .doc(liturgyId)
          .collection('bloques')
          .add(block.toMap());

      // Actualizar timestamp de la liturgia
      await _liturgiesCollection.doc(liturgyId).update({
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return docRef.id;
    } catch (e) {
      print('Error al crear bloque: $e');
      rethrow;
    }
  }

  /// Actualiza un bloque existente
  Future<void> updateBlock(
      String liturgyId, LiturgyBlock block) async {
    try {
      await _liturgiesCollection
          .doc(liturgyId)
          .collection('bloques')
          .doc(block.id)
          .update(block.toMap());

      // Actualizar timestamp de la liturgia
      await _liturgiesCollection.doc(liturgyId).update({
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error al actualizar bloque: $e');
      rethrow;
    }
  }

  /// Elimina un bloque y todas sus canciones
  Future<void> deleteBlock(String liturgyId, String blockId) async {
    try {
      // Eliminar canciones del bloque
      final songs = await _liturgiesCollection
          .doc(liturgyId)
          .collection('bloques')
          .doc(blockId)
          .collection('canciones')
          .get();

      for (var songDoc in songs.docs) {
        await songDoc.reference.delete();
      }

      // Eliminar bloque
      await _liturgiesCollection
          .doc(liturgyId)
          .collection('bloques')
          .doc(blockId)
          .delete();

      // Actualizar timestamp de la liturgia
      await _liturgiesCollection.doc(liturgyId).update({
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error al eliminar bloque: $e');
      rethrow;
    }
  }

  // ==================== CANCIONES ====================

  /// Obtiene todas las canciones de un bloque
  Future<List<Song>> getSongs(String liturgyId, String blockId) async {
    try {
      final snapshot = await _liturgiesCollection
          .doc(liturgyId)
          .collection('bloques')
          .doc(blockId)
          .collection('canciones')
          .get();

      return snapshot.docs
          .map((doc) => Song.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error al obtener canciones: $e');
      return [];
    }
  }

  /// Crea una nueva canción en un bloque
  Future<String> createSong(
      String liturgyId, String blockId, Song song) async {
    try {
      final docRef = await _liturgiesCollection
          .doc(liturgyId)
          .collection('bloques')
          .doc(blockId)
          .collection('canciones')
          .add(song.toMap());

      return docRef.id;
    } catch (e) {
      print('Error al crear canción: $e');
      rethrow;
    }
  }

  /// Actualiza una canción existente
  Future<void> updateSong(
      String liturgyId, String blockId, Song song) async {
    try {
      await _liturgiesCollection
          .doc(liturgyId)
          .collection('bloques')
          .doc(blockId)
          .collection('canciones')
          .doc(song.id)
          .update(song.toMap());
    } catch (e) {
      print('Error al actualizar canción: $e');
      rethrow;
    }
  }

  /// Elimina una canción
  Future<void> deleteSong(
      String liturgyId, String blockId, String songId) async {
    try {
      await _liturgiesCollection
          .doc(liturgyId)
          .collection('bloques')
          .doc(blockId)
          .collection('canciones')
          .doc(songId)
          .delete();
    } catch (e) {
      print('Error al eliminar canción: $e');
      rethrow;
    }
  }
}
