import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:worshippro/models/liturgy_block.dart';

/// Modelo para representar un culto completo
class Liturgy {
  final String id;
  final String titulo;
  final DateTime fecha;
  final String? descripcion;
  final List<LiturgyBlock> bloques;
  final DateTime createdAt;
  final DateTime updatedAt;

  Liturgy({
    required this.id,
    required this.titulo,
    required this.fecha,
    this.descripcion,
    this.bloques = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una liturgia desde un mapa de datos
  factory Liturgy.fromMap(Map<String, dynamic> map, String id) {
    return Liturgy(
      id: id,
      titulo: map['titulo'] as String? ?? '',
      fecha: (map['fecha'] as Timestamp).toDate(),
      descripcion: map['descripcion'] as String?,
      bloques: [], // Los bloques se cargan por separado desde la subcolección
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convierte la liturgia a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'fecha': Timestamp.fromDate(fecha),
      'descripcion': descripcion,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Calcula la duración total del culto sumando todos los bloques
  int get duracionTotalMinutos {
    return bloques.fold(0, (sum, block) => sum + block.duracionMinutos);
  }

  /// Formatea la duración total en formato HH:mm
  String get duracionTotalFormateada {
    final horas = duracionTotalMinutos ~/ 60;
    final minutos = duracionTotalMinutos % 60;
    return '${horas}h ${minutos}min';
  }

  /// Crea una copia de la liturgia con valores opcionales actualizados
  Liturgy copyWith({
    String? id,
    String? titulo,
    DateTime? fecha,
    String? descripcion,
    List<LiturgyBlock>? bloques,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Liturgy(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      fecha: fecha ?? this.fecha,
      descripcion: descripcion ?? this.descripcion,
      bloques: bloques ?? this.bloques,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
