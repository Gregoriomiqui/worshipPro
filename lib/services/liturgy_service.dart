import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:worshippro/models/liturgy.dart';
import 'package:worshippro/models/liturgy_block.dart';
import 'package:worshippro/models/song.dart';

/// Servicio para gestionar los cultos en Firebase Firestore
/// Versión 1.1: Multi-tenant con organizationId
class LiturgyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtener colección de liturgias para una organización específica
  CollectionReference _liturgiesCollection(String organizationId) =>
      _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('liturgias');

  // ==================== LITURGIAS ====================

  /// Obtiene todas las liturgias de una organización ordenadas por fecha descendente
  Stream<List<Liturgy>> getLiturgies(String organizationId) {
    return _liturgiesCollection(organizationId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final liturgies = <Liturgy>[];
      
      for (var doc in snapshot.docs) {
        final liturgy = Liturgy.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        
        // Cargar solo la información básica de los bloques (sin canciones)
        final blocksSnapshot = await doc.reference
            .collection('bloques')
            .orderBy('orden')
            .get();
        
        final blocks = blocksSnapshot.docs.map((blockDoc) {
          return LiturgyBlock.fromMap(blockDoc.data(), blockDoc.id);
        }).toList();
        
        liturgies.add(liturgy.copyWith(bloques: blocks));
      }
      
      return liturgies;
    });
  }

  /// Obtiene una liturgia específica con todos sus bloques y canciones
  Future<Liturgy?> getLiturgyById(String organizationId, String liturgyId) async {
    try {
      final liturgyDoc = await _liturgiesCollection(organizationId).doc(liturgyId).get();
      if (!liturgyDoc.exists) return null;

      final liturgy =
          Liturgy.fromMap(liturgyDoc.data() as Map<String, dynamic>, liturgyDoc.id);

      // Cargar bloques
      final blocks = await getBlocks(organizationId, liturgyId);

      return liturgy.copyWith(bloques: blocks);
    } catch (e) {
      print('Error al obtener liturgia: $e');
      return null;
    }
  }

  /// Crea una nueva liturgia en una organización
  Future<String> createLiturgy(String organizationId, Liturgy liturgy, String createdBy) async {
    try {
      final now = DateTime.now();
      final liturgyData = liturgy.toMap();
      liturgyData['createdBy'] = createdBy;
      liturgyData['createdAt'] = Timestamp.fromDate(now);
      liturgyData['updatedAt'] = Timestamp.fromDate(now);

      final docRef = await _liturgiesCollection(organizationId).add(liturgyData);
      return docRef.id;
    } catch (e) {
      print('Error al crear liturgia: $e');
      rethrow;
    }
  }

  /// Actualiza una liturgia existente
  Future<void> updateLiturgy(String organizationId, Liturgy liturgy) async {
    try {
      final liturgyData = liturgy.toMap();
      liturgyData['updatedAt'] = Timestamp.fromDate(DateTime.now());

      await _liturgiesCollection(organizationId).doc(liturgy.id).update(liturgyData);
    } catch (e) {
      print('Error al actualizar liturgia: $e');
      rethrow;
    }
  }

  /// Duplica una liturgia con todos sus bloques y canciones
  Future<String> duplicateLiturgy(String organizationId, String liturgyId) async {
    try {
      // Obtener la liturgia original con todos sus bloques
      final originalLiturgy = await getLiturgyById(organizationId, liturgyId);
      
      if (originalLiturgy == null) {
        throw Exception('Liturgia no encontrada');
      }
      
      // Calcular el número de duplicado
      final allLiturgies = await _liturgiesCollection(organizationId).get();
      int duplicateNumber = 1;
      String baseTitle = originalLiturgy.titulo;
      
      // Buscar cuántas copias existen
      for (var doc in allLiturgies.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final title = data['titulo'] as String?;
          if (title != null && title.startsWith(baseTitle)) {
            final match = RegExp(r'duplicated_(\d+)$').firstMatch(title);
            if (match != null) {
              final num = int.parse(match.group(1)!);
              if (num >= duplicateNumber) {
                duplicateNumber = num + 1;
              }
            }
          }
        }
      }
      
      // Crear nueva liturgia con sufijo
      final newLiturgyId = const Uuid().v4();
      final newLiturgy = originalLiturgy.copyWith(
        id: newLiturgyId,
        titulo: '${baseTitle}_duplicated_$duplicateNumber',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Crear la liturgia
      final liturgyData = newLiturgy.toMap();
      liturgyData['createdBy'] = liturgyData['createdBy'] ?? '';
      await _liturgiesCollection(organizationId).doc(newLiturgyId).set(liturgyData);
      
      // Duplicar todos los bloques
      for (var block in originalLiturgy.bloques) {
        final newBlockId = const Uuid().v4();
        final blockData = block.toMap();
        
        await _liturgiesCollection(organizationId)
            .doc(newLiturgyId)
            .collection('bloques')
            .doc(newBlockId)
            .set(blockData);
        
        // Duplicar canciones si el bloque es de adoración
        if (block.isAdoracion && block.canciones.isNotEmpty) {
          for (var song in block.canciones) {
            await _liturgiesCollection(organizationId)
                .doc(newLiturgyId)
                .collection('bloques')
                .doc(newBlockId)
                .collection('canciones')
                .add(song.toMap());
          }
        }
      }
      
      return newLiturgyId;
    } catch (e) {
      print('Error al duplicar liturgia: $e');
      rethrow;
    }
  }

  /// Elimina una liturgia y todos sus bloques y canciones
  Future<void> deleteLiturgy(String organizationId, String liturgyId) async {
    try {
      // Eliminar todos los bloques y sus canciones
      final blocks = await _liturgiesCollection(organizationId)
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
      await _liturgiesCollection(organizationId).doc(liturgyId).delete();
    } catch (e) {
      print('Error al eliminar liturgia: $e');
      rethrow;
    }
  }

  // ==================== BLOQUES ====================

  /// Obtiene todos los bloques de una liturgia ordenados por orden
  Future<List<LiturgyBlock>> getBlocks(String organizationId, String liturgyId) async {
    try {
      final snapshot = await _liturgiesCollection(organizationId)
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
          final songs = await getSongs(organizationId, liturgyId, block.id);
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
  Future<String> createBlock(String organizationId, String liturgyId, LiturgyBlock block) async {
    try {
      final docRef = await _liturgiesCollection(organizationId)
          .doc(liturgyId)
          .collection('bloques')
          .add(block.toMap());

      // Guardar canciones si es un bloque de adoración
      if (block.isAdoracion && block.canciones.isNotEmpty) {
        for (var song in block.canciones) {
          await docRef.collection('canciones').add(song.toMap());
        }
      }

      // Actualizar timestamp de la liturgia
      await _liturgiesCollection(organizationId).doc(liturgyId).update({
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
      String organizationId, String liturgyId, LiturgyBlock block) async {
    try {
      final blockRef = _liturgiesCollection(organizationId)
          .doc(liturgyId)
          .collection('bloques')
          .doc(block.id);
      
      await blockRef.update(block.toMap());

      // Si es un bloque de adoración, actualizar las canciones
      if (block.isAdoracion) {
        // Eliminar todas las canciones existentes
        final existingSongs = await blockRef.collection('canciones').get();
        for (var songDoc in existingSongs.docs) {
          await songDoc.reference.delete();
        }
        
        // Agregar las nuevas canciones
        for (var song in block.canciones) {
          await blockRef.collection('canciones').add(song.toMap());
        }
      }

      // Actualizar timestamp de la liturgia
      await _liturgiesCollection(organizationId).doc(liturgyId).update({
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error al actualizar bloque: $e');
      rethrow;
    }
  }

  /// Elimina un bloque y todas sus canciones
  Future<void> deleteBlock(String organizationId, String liturgyId, String blockId) async {
    try {
      // Eliminar canciones del bloque
      final songs = await _liturgiesCollection(organizationId)
          .doc(liturgyId)
          .collection('bloques')
          .doc(blockId)
          .collection('canciones')
          .get();

      for (var songDoc in songs.docs) {
        await songDoc.reference.delete();
      }

      // Eliminar bloque
      await _liturgiesCollection(organizationId)
          .doc(liturgyId)
          .collection('bloques')
          .doc(blockId)
          .delete();

      // Actualizar timestamp de la liturgia
      await _liturgiesCollection(organizationId).doc(liturgyId).update({
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error al eliminar bloque: $e');
      rethrow;
    }
  }

  // ==================== CANCIONES ====================

  /// Obtiene todas las canciones de un bloque
  Future<List<Song>> getSongs(String organizationId, String liturgyId, String blockId) async {
    try {
      final snapshot = await _liturgiesCollection(organizationId)
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
      String organizationId, String liturgyId, String blockId, Song song) async {
    try {
      final docRef = await _liturgiesCollection(organizationId)
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
      String organizationId, String liturgyId, String blockId, Song song) async {
    try {
      await _liturgiesCollection(organizationId)
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
      String organizationId, String liturgyId, String blockId, String songId) async {
    try {
      await _liturgiesCollection(organizationId)
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
