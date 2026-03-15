import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/organization.dart';
import '../models/member.dart';
import '../models/invitation.dart';

/// Excepción personalizada para errores de organización
class OrganizationException implements Exception {
  final String message;

  OrganizationException(this.message);

  @override
  String toString() => message;
}

/// Servicio de Organizaciones
/// Maneja CRUD de organizaciones, miembros e invitaciones
class OrganizationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // ============================================================================
  // ORGANIZACIONES - CRUD
  // ============================================================================

  /// Crear nueva organización
  /// El usuario que la crea automáticamente es Admin
  Future<Organization> createOrganization({
    required String nombre,
    required String createdBy,
    String? descripcion,
  }) async {
    try {
      final now = DateTime.now();
      final organizationId = _uuid.v4();

      final organization = Organization(
        id: organizationId,
        nombre: nombre,
        descripcion: descripcion,
        createdBy: createdBy,
        createdAt: now,
        updatedAt: now,
      );

      // Crear documento de organización
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .set(organization.toFirestore());

      return organization;
    } catch (e) {
      throw OrganizationException('Error al crear organización: $e');
    }
  }

  /// Obtener organización por ID
  Future<Organization?> getOrganization(String organizationId) async {
    try {
      final doc = await _firestore
          .collection('organizations')
          .doc(organizationId)
          .get();

      if (!doc.exists) return null;

      return Organization.fromFirestore(doc);
    } catch (e) {
      throw OrganizationException('Error al obtener organización: $e');
    }
  }

  /// Obtener todas las organizaciones del usuario
  Future<List<Organization>> getUserOrganizations(
      List<String> organizationIds) async {
    try {
      if (organizationIds.isEmpty) return [];

      final organizations = <Organization>[];

      // Firestore no soporta queries "in" con más de 10 elementos
      // Dividir en chunks de 10
      for (int i = 0; i < organizationIds.length; i += 10) {
        final chunk = organizationIds.skip(i).take(10).toList();

        final snapshot = await _firestore
            .collection('organizations')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        organizations.addAll(
          snapshot.docs.map((doc) => Organization.fromFirestore(doc)),
        );
      }

      return organizations;
    } catch (e) {
      throw OrganizationException(
          'Error al obtener organizaciones del usuario: $e');
    }
  }

  /// Actualizar organización
  Future<void> updateOrganization(Organization organization) async {
    try {
      await _firestore
          .collection('organizations')
          .doc(organization.id)
          .update(organization.copyWith(updatedAt: DateTime.now()).toFirestore());
    } catch (e) {
      throw OrganizationException('Error al actualizar organización: $e');
    }
  }

  /// Eliminar organización
  Future<void> deleteOrganization(String organizationId) async {
    try {
      // TODO: Implementar eliminación en cascada de miembros y liturgias
      // Por seguridad, solo admins pueden eliminar organizaciones
      await _firestore.collection('organizations').doc(organizationId).delete();
    } catch (e) {
      throw OrganizationException('Error al eliminar organización: $e');
    }
  }

  // ============================================================================
  // MIEMBROS - CRUD
  // ============================================================================

  /// Agregar miembro a organización (usado por creador o al aceptar invitación)
  Future<void> addMember({
    required String organizationId,
    required String userId,
    required String email,
    required String displayName,
    required MemberRole role,
    String? invitedBy,
    String? invitationId,
  }) async {
    try {
      final member = Member(
        userId: userId,
        email: email,
        displayName: displayName,
        role: role,
        joinedAt: DateTime.now(),
        invitedBy: invitedBy,
      );

      final memberData = member.toFirestore();
      if (invitationId != null && invitationId.isNotEmpty) {
        memberData['invitationId'] = invitationId;
      }

      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('members')
          .doc(userId)
          .set(memberData);

      // Actualizar users/{userId}.organizationIds
      await _firestore.collection('users').doc(userId).update({
        'organizationIds': FieldValue.arrayUnion([organizationId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw OrganizationException('Error al agregar miembro: $e');
    }
  }

  /// Obtener todos los miembros de una organización
  Future<List<Member>> getMembers(String organizationId) async {
    try {
      final snapshot = await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('members')
          .orderBy('joinedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Member.fromFirestore(doc)).toList();
    } catch (e) {
      throw OrganizationException('Error al obtener miembros: $e');
    }
  }

  /// Stream de miembros de una organización
  Stream<List<Member>> membersStream(String organizationId) {
    return _firestore
        .collection('organizations')
        .doc(organizationId)
        .collection('members')
        .orderBy('joinedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Member.fromFirestore(doc)).toList());
  }

  /// Obtener miembro específico
  Future<Member?> getMember({
    required String organizationId,
    required String userId,
  }) async {
    try {
      final doc = await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('members')
          .doc(userId)
          .get();

      if (!doc.exists) return null;

      return Member.fromFirestore(doc);
    } catch (e) {
      throw OrganizationException('Error al obtener miembro: $e');
    }
  }

  /// Actualizar rol de miembro
  Future<void> updateMemberRole({
    required String organizationId,
    required String userId,
    required MemberRole newRole,
  }) async {
    try {
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('members')
          .doc(userId)
          .update({'role': newRole.value});
    } catch (e) {
      throw OrganizationException('Error al actualizar rol de miembro: $e');
    }
  }

  /// Eliminar miembro de organización
  Future<void> removeMember({
    required String organizationId,
    required String userId,
  }) async {
    try {
      // Eliminar de members
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('members')
          .doc(userId)
          .delete();

      // Actualizar users/{userId}.organizationIds
      await _firestore.collection('users').doc(userId).update({
        'organizationIds': FieldValue.arrayRemove([organizationId]),
        'updatedAt': FieldValue.serverTimestamp(),
        'removeOrganizationId': organizationId,
        'removeOrganizationAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw OrganizationException('Error al eliminar miembro: $e');
    }
  }

  // ============================================================================
  // INVITACIONES - CRUD
  // ============================================================================

  /// Crear invitación para nuevo miembro
  Future<Invitation> createInvitation({
    required String organizationId,
    required String organizationName,
    required String email,
    required String invitedBy,
    required String invitedByName,
    MemberRole role = MemberRole.member,
    int? expirationDays,
  }) async {
    try {
      final invitationId = _uuid.v4();
      final now = DateTime.now();
      final expiresAt = expirationDays != null
          ? now.add(Duration(days: expirationDays))
          : null;

      final invitation = Invitation(
        id: invitationId,
        organizationId: organizationId,
        organizationName: organizationName,
        email: email.toLowerCase().trim(),
        role: role,
        invitedBy: invitedBy,
        invitedByName: invitedByName,
        status: InvitationStatus.pending,
        createdAt: now,
        expiresAt: expiresAt,
      );

      await _firestore
          .collection('invitations')
          .doc(invitationId)
          .set(invitation.toFirestore());

      return invitation;
    } catch (e) {
      throw OrganizationException('Error al crear invitación: $e');
    }
  }

  /// Obtener invitaciones pendientes para un email
  Future<List<Invitation>> getPendingInvitations(String email) async {
    try {
      final snapshot = await _firestore
          .collection('invitations')
          .where('email', isEqualTo: email.toLowerCase().trim())
          .where('status', isEqualTo: 'pending')
          .get();

      final invitations = snapshot.docs
          .map((doc) => Invitation.fromFirestore(doc))
          .where((inv) => !inv.isExpired) // Filtrar expiradas
          .toList();

      return invitations;
    } catch (e) {
      throw OrganizationException(
          'Error al obtener invitaciones pendientes: $e');
    }
  }

  /// Stream de invitaciones de una organización
  Stream<List<Invitation>> organizationInvitationsStream(
      String organizationId) {
    return _firestore
        .collection('invitations')
        .where('organizationId', isEqualTo: organizationId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Invitation.fromFirestore(doc)).toList());
  }

  /// Aceptar invitación
  Future<void> acceptInvitation({
    required String invitationId,
    required String userId,
    required String displayName,
  }) async {
    try {
      // 1. Obtener invitación
      final invDoc =
          await _firestore.collection('invitations').doc(invitationId).get();

      if (!invDoc.exists) {
        throw OrganizationException('Invitación no encontrada');
      }

      final invitation = Invitation.fromFirestore(invDoc);

      if (!invitation.isValid) {
        throw OrganizationException('Invitación inválida o expirada');
      }

      // 2. Agregar como miembro
      await addMember(
        organizationId: invitation.organizationId,
        userId: userId,
        email: invitation.email,
        displayName: displayName,
        role: invitation.role,
        invitedBy: invitation.invitedBy,
        invitationId: invitationId,
      );

      // 3. Actualizar estado de invitación
      await _firestore.collection('invitations').doc(invitationId).update({
        'status': InvitationStatus.accepted.value,
      });
    } catch (e) {
      if (e is OrganizationException) rethrow;
      throw OrganizationException('Error al aceptar invitación: $e');
    }
  }

  /// Rechazar invitación
  Future<void> rejectInvitation(String invitationId) async {
    try {
      await _firestore.collection('invitations').doc(invitationId).update({
        'status': InvitationStatus.rejected.value,
      });
    } catch (e) {
      throw OrganizationException('Error al rechazar invitación: $e');
    }
  }

  /// Cancelar/Eliminar invitación (solo admins)
  Future<void> deleteInvitation(String invitationId) async {
    try {
      await _firestore.collection('invitations').doc(invitationId).delete();
    } catch (e) {
      throw OrganizationException('Error al eliminar invitación: $e');
    }
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  /// Verificar si un usuario es admin de una organización
  Future<bool> isUserAdmin({
    required String organizationId,
    required String userId,
  }) async {
    try {
      final member = await getMember(
        organizationId: organizationId,
        userId: userId,
      );

      return member?.isAdmin ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Obtener cantidad de miembros de una organización
  Future<int> getMembersCount(String organizationId) async {
    try {
      final snapshot = await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('members')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
