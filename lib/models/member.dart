import 'package:cloud_firestore/cloud_firestore.dart';

/// Roles de miembro en una organización
enum MemberRole {
  admin, // Administrador con permisos completos
  member, // Miembro regular con acceso a liturgias
}

extension MemberRoleExtension on MemberRole {
  String get value {
    switch (this) {
      case MemberRole.admin:
        return 'admin';
      case MemberRole.member:
        return 'member';
    }
  }

  static MemberRole fromString(String value) {
    switch (value) {
      case 'admin':
        return MemberRole.admin;
      case 'member':
        return MemberRole.member;
      default:
        return MemberRole.member;
    }
  }
}

/// Modelo de Miembro de Organización
/// Representa un usuario que pertenece a una organización específica
class Member {
  final String userId; // ID del usuario (coincide con auth UID)
  final String email;
  final String displayName;
  final MemberRole role;
  final DateTime joinedAt;
  final String? invitedBy; // userId del invitador

  Member({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.role,
    required this.joinedAt,
    this.invitedBy,
  });

  /// Crear desde documento de Firestore
  factory Member.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Member(
      userId: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: MemberRoleExtension.fromString(data['role'] ?? 'member'),
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      invitedBy: data['invitedBy'],
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role.value,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'invitedBy': invitedBy,
    };
  }

  /// Crear copia con modificaciones
  Member copyWith({
    String? userId,
    String? email,
    String? displayName,
    MemberRole? role,
    DateTime? joinedAt,
    String? invitedBy,
  }) {
    return Member(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      invitedBy: invitedBy ?? this.invitedBy,
    );
  }

  /// Verificar si es administrador
  bool get isAdmin => role == MemberRole.admin;

  /// Verificar si es miembro regular
  bool get isMember => role == MemberRole.member;
}
