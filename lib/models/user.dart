import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Usuario del sistema
/// Representa un usuario autenticado con Firebase Auth
class User {
  final String id; // Firebase Auth UID
  final String email;
  final String displayName;
  final String? photoURL;
  final List<String> organizationIds; // IDs de organizaciones a las que pertenece
  final String? activeOrganizationId; // Organización actualmente activa
  final List<String> authProviders; // ["password", "google.com"]
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.organizationIds,
    this.activeOrganizationId,
    required this.authProviders,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crear desde documento de Firestore
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      organizationIds: List<String>.from(data['organizationIds'] ?? []),
      activeOrganizationId: data['activeOrganizationId'],
      authProviders: List<String>.from(data['authProviders'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'organizationIds': organizationIds,
      'activeOrganizationId': activeOrganizationId,
      'authProviders': authProviders,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Crear copia con modificaciones
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    List<String>? organizationIds,
    String? activeOrganizationId,
    List<String>? authProviders,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      organizationIds: organizationIds ?? this.organizationIds,
      activeOrganizationId: activeOrganizationId ?? this.activeOrganizationId,
      authProviders: authProviders ?? this.authProviders,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verificar si el usuario pertenece a una organización
  bool belongsToOrganization(String organizationId) {
    return organizationIds.contains(organizationId);
  }

  /// Verificar si tiene múltiples organizaciones
  bool get hasMultipleOrganizations => organizationIds.length > 1;

  /// Verificar si tiene al menos una organización
  bool get hasOrganization => organizationIds.isNotEmpty;
}
