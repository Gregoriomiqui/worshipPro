import 'package:cloud_firestore/cloud_firestore.dart';
import 'member.dart';

/// Estados de una invitación
enum InvitationStatus {
  pending, // Pendiente de aceptar
  accepted, // Aceptada por el usuario
  rejected, // Rechazada por el usuario
}

extension InvitationStatusExtension on InvitationStatus {
  String get value {
    switch (this) {
      case InvitationStatus.pending:
        return 'pending';
      case InvitationStatus.accepted:
        return 'accepted';
      case InvitationStatus.rejected:
        return 'rejected';
    }
  }

  static InvitationStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return InvitationStatus.pending;
      case 'accepted':
        return InvitationStatus.accepted;
      case 'rejected':
        return InvitationStatus.rejected;
      default:
        return InvitationStatus.pending;
    }
  }
}

/// Modelo de Invitación
/// Representa una invitación a un usuario para unirse a una organización
class Invitation {
  final String id;
  final String organizationId;
  final String organizationName;
  final String email; // Email del invitado
  final MemberRole role; // Rol que tendrá al aceptar
  final String invitedBy; // userId del invitador
  final String invitedByName; // Nombre del invitador
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;

  Invitation({
    required this.id,
    required this.organizationId,
    required this.organizationName,
    required this.email,
    required this.role,
    required this.invitedBy,
    required this.invitedByName,
    required this.status,
    required this.createdAt,
    this.expiresAt,
  });

  /// Crear desde documento de Firestore
  factory Invitation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Invitation(
      id: doc.id,
      organizationId: data['organizationId'] ?? '',
      organizationName: data['organizationName'] ?? '',
      email: data['email'] ?? '',
      role: MemberRoleExtension.fromString(data['role'] ?? 'member'),
      invitedBy: data['invitedBy'] ?? '',
      invitedByName: data['invitedByName'] ?? '',
      status: InvitationStatusExtension.fromString(data['status'] ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: data['expiresAt'] != null
          ? (data['expiresAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'organizationId': organizationId,
      'organizationName': organizationName,
      'email': email,
      'role': role.value,
      'invitedBy': invitedBy,
      'invitedByName': invitedByName,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }

  /// Crear copia con modificaciones
  Invitation copyWith({
    String? id,
    String? organizationId,
    String? organizationName,
    String? email,
    MemberRole? role,
    String? invitedBy,
    String? invitedByName,
    InvitationStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return Invitation(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      email: email ?? this.email,
      role: role ?? this.role,
      invitedBy: invitedBy ?? this.invitedBy,
      invitedByName: invitedByName ?? this.invitedByName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Verificar si la invitación está pendiente
  bool get isPending => status == InvitationStatus.pending;

  /// Verificar si la invitación fue aceptada
  bool get isAccepted => status == InvitationStatus.accepted;

  /// Verificar si la invitación fue rechazada
  bool get isRejected => status == InvitationStatus.rejected;

  /// Verificar si la invitación ha expirado
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Verificar si la invitación es válida (pendiente y no expirada)
  bool get isValid => isPending && !isExpired;
}
