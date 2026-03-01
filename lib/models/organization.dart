import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Organización (Iglesia)
/// Representa una iglesia o entidad que agrupa liturgias
class Organization {
  final String id;
  final String nombre;
  final String? descripcion;
  final String createdBy; // userId del creador
  final DateTime createdAt;
  final DateTime updatedAt;

  Organization({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crear desde documento de Firestore
  factory Organization.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Organization(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'],
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Crear copia con modificaciones
  Organization copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Organization(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
