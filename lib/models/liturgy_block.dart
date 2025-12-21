import 'package:worshippro/models/block_type.dart';
import 'package:worshippro/models/song.dart';

/// Modelo para representar un bloque dentro de una liturgia
class LiturgyBlock {
  final String id;
  final BlockType tipo;
  final String descripcion;
  final List<String> responsables;
  final String? comentarios;
  final int duracionMinutos;
  final int orden;
  final List<Song> canciones; // Solo para bloques de tipo adoración

  LiturgyBlock({
    required this.id,
    required this.tipo,
    required this.descripcion,
    required this.responsables,
    this.comentarios,
    required this.duracionMinutos,
    required this.orden,
    this.canciones = const [],
  });

  /// Crea un bloque desde un mapa de datos
  factory LiturgyBlock.fromMap(Map<String, dynamic> map, String id) {
    return LiturgyBlock(
      id: id,
      tipo: BlockType.values.firstWhere(
        (e) => e.name == map['tipo'],
        orElse: () => BlockType.otros,
      ),
      descripcion: map['descripcion'] as String? ?? '',
      responsables: List<String>.from(map['responsables'] ?? []),
      comentarios: map['comentarios'] as String?,
      duracionMinutos: map['duracionMinutos'] as int? ?? 0,
      orden: map['orden'] as int? ?? 0,
      canciones: [], // Las canciones se cargan por separado desde la subcolección
    );
  }

  /// Convierte el bloque a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo.name,
      'descripcion': descripcion,
      'responsables': responsables,
      'comentarios': comentarios,
      'duracionMinutos': duracionMinutos,
      'orden': orden,
    };
  }

  /// Crea una copia del bloque con valores opcionales actualizados
  LiturgyBlock copyWith({
    String? id,
    BlockType? tipo,
    String? descripcion,
    List<String>? responsables,
    String? comentarios,
    int? duracionMinutos,
    int? orden,
    List<Song>? canciones,
  }) {
    return LiturgyBlock(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      responsables: responsables ?? this.responsables,
      comentarios: comentarios ?? this.comentarios,
      duracionMinutos: duracionMinutos ?? this.duracionMinutos,
      orden: orden ?? this.orden,
      canciones: canciones ?? this.canciones,
    );
  }

  /// Verifica si el bloque es de tipo adoración
  bool get isAdoracion => tipo == BlockType.adoracionAlabanza;
}
