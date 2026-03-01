import 'package:flutter/foundation.dart';
import '../services/organization_service.dart';
import '../models/organization.dart';
import '../models/member.dart';
import '../models/invitation.dart';

/// Provider de Organizaciones
/// Gestiona el estado de organizaciones, miembros e invitaciones
class OrganizationProvider with ChangeNotifier {
  final OrganizationService _organizationService;

  OrganizationProvider({OrganizationService? organizationService})
      : _organizationService = organizationService ?? OrganizationService();

  // Estado
  List<Organization> _userOrganizations = [];
  Organization? _activeOrganization;
  List<Member> _members = [];
  List<Invitation> _pendingInvitations = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Organization> get userOrganizations => _userOrganizations;
  Organization? get activeOrganization => _activeOrganization;
  List<Member> get members => _members;
  List<Invitation> get pendingInvitations => _pendingInvitations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasOrganizations => _userOrganizations.isNotEmpty;
  bool get hasActiveOrganization => _activeOrganization != null;
  String? get activeOrganizationId => _activeOrganization?.id;

  // ============================================================================
  // ORGANIZACIONES
  // ============================================================================

  /// Cargar organizaciones del usuario
  Future<void> loadUserOrganizations(List<String> organizationIds) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _userOrganizations =
          await _organizationService.getUserOrganizations(organizationIds);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crear nueva organización
  Future<Organization?> createOrganization({
    required String nombre,
    required String createdBy,
    required String creatorEmail,
    required String creatorDisplayName,
    String? descripcion,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 1. Crear organización
      final organization = await _organizationService.createOrganization(
        nombre: nombre,
        createdBy: createdBy,
        descripcion: descripcion,
      );

      // 2. Agregar creador como Admin
      await _organizationService.addMember(
        organizationId: organization.id,
        userId: createdBy,
        email: creatorEmail,
        displayName: creatorDisplayName,
        role: MemberRole.admin,
      );

      // 3. Actualizar lista local
      _userOrganizations.add(organization);

      // 4. Establecer como organización activa si es la primera
      if (_userOrganizations.length == 1) {
        _activeOrganization = organization;
        await loadMembers(organization.id);
      }

      _isLoading = false;
      notifyListeners();

      return organization;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Actualizar organización
  Future<bool> updateOrganization(Organization organization) async {
    try {
      _errorMessage = null;
      await _organizationService.updateOrganization(organization);

      // Actualizar lista local
      final index =
          _userOrganizations.indexWhere((org) => org.id == organization.id);
      if (index != -1) {
        _userOrganizations[index] = organization;
      }

      // Actualizar organización activa si es la misma
      if (_activeOrganization?.id == organization.id) {
        _activeOrganization = organization;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Establecer organización activa
  Future<void> setActiveOrganization(String organizationId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Buscar en lista local
      final organization = _userOrganizations.firstWhere(
        (org) => org.id == organizationId,
        orElse: () =>
            throw Exception('Organización no encontrada en la lista local'),
      );

      _activeOrganization = organization;

      // Cargar miembros de la nueva organización activa
      await loadMembers(organizationId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtener organización por ID
  Future<Organization?> getOrganization(String organizationId) async {
    try {
      // Primero buscar en cache local
      final cachedOrg = _userOrganizations.firstWhere(
        (org) => org.id == organizationId,
        orElse: () => _userOrganizations.first, // Fallback temporal
      );

      if (cachedOrg.id == organizationId) {
        return cachedOrg;
      }

      // Si no está en cache, obtener de Firestore
      return await _organizationService.getOrganization(organizationId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ============================================================================
  // MIEMBROS
  // ============================================================================

  /// Cargar miembros de la organización activa
  Future<void> loadMembers(String organizationId) async {
    try {
      _members = await _organizationService.getMembers(organizationId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Agregar miembro a la organización activa
  Future<bool> addMember({
    required String email,
    required String displayName,
    required String userId,
    MemberRole role = MemberRole.member,
  }) async {
    try {
      if (_activeOrganization == null) {
        throw Exception('No hay organización activa');
      }

      _errorMessage = null;
      await _organizationService.addMember(
        organizationId: _activeOrganization!.id,
        userId: userId,
        email: email,
        displayName: displayName,
        role: role,
      );

      // Recargar miembros
      await loadMembers(_activeOrganization!.id);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Actualizar rol de miembro
  Future<bool> updateMemberRole(String userId, MemberRole newRole) async {
    try {
      if (_activeOrganization == null) {
        throw Exception('No hay organización activa');
      }

      _errorMessage = null;
      await _organizationService.updateMemberRole(
        organizationId: _activeOrganization!.id,
        userId: userId,
        newRole: newRole,
      );

      // Recargar miembros
      await loadMembers(_activeOrganization!.id);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Eliminar miembro
  Future<bool> removeMember(String userId) async {
    try {
      if (_activeOrganization == null) {
        throw Exception('No hay organización activa');
      }

      _errorMessage = null;
      await _organizationService.removeMember(
        organizationId: _activeOrganization!.id,
        userId: userId,
      );

      // Recargar miembros
      await loadMembers(_activeOrganization!.id);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Verificar si el usuario actual es admin
  Future<bool> isCurrentUserAdmin(String organizationId, String userId) async {
    try {
      return await _organizationService.isUserAdmin(
        organizationId: organizationId,
        userId: userId,
      );
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // INVITACIONES
  // ============================================================================

  /// Invitar miembro por email
  Future<bool> inviteMember({
    required String email,
    required String invitedBy,
    required String invitedByName,
    MemberRole role = MemberRole.member,
    int expirationDays = 7,
  }) async {
    try {
      if (_activeOrganization == null) {
        throw Exception('No hay organización activa');
      }

      _errorMessage = null;
      await _organizationService.createInvitation(
        organizationId: _activeOrganization!.id,
        organizationName: _activeOrganization!.nombre,
        email: email,
        invitedBy: invitedBy,
        invitedByName: invitedByName,
        role: role,
        expirationDays: expirationDays,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Cargar invitaciones pendientes del usuario
  Future<void> loadPendingInvitations(String email) async {
    try {
      _pendingInvitations =
          await _organizationService.getPendingInvitations(email);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Aceptar invitación
  Future<bool> acceptInvitation({
    required String invitationId,
    required String userId,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _organizationService.acceptInvitation(
        invitationId: invitationId,
        userId: userId,
        displayName: displayName,
      );

      // Remover de lista de pendientes
      _pendingInvitations
          .removeWhere((inv) => inv.id == invitationId);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Rechazar invitación
  Future<bool> rejectInvitation(String invitationId) async {
    try {
      _errorMessage = null;
      await _organizationService.rejectInvitation(invitationId);

      // Remover de lista de pendientes
      _pendingInvitations.removeWhere((inv) => inv.id == invitationId);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Cancelar invitación (solo admins)
  Future<bool> cancelInvitation(String invitationId) async {
    try {
      _errorMessage = null;
      await _organizationService.deleteInvitation(invitationId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  /// Limpiar errores
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpiar estado (útil para logout)
  void clear() {
    _userOrganizations = [];
    _activeOrganization = null;
    _members = [];
    _pendingInvitations = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
