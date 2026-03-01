import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organization_provider.dart';
import '../../models/organization.dart';
import '../../models/member.dart';

/// Pantalla de configuración de la organización (solo admins)
class OrganizationSettingsScreen extends StatefulWidget {
  const OrganizationSettingsScreen({super.key});

  @override
  State<OrganizationSettingsScreen> createState() =>
      _OrganizationSettingsScreenState();
}

class _OrganizationSettingsScreenState
    extends State<OrganizationSettingsScreen> {
  final _inviteEmailController = TextEditingController();
  String _selectedRole = 'member';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMembers();
    });
  }

  @override
  void dispose() {
    _inviteEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    final orgProvider = context.read<OrganizationProvider>();
    if (orgProvider.activeOrganization != null) {
      await orgProvider.loadMembers(
        orgProvider.activeOrganization!.id,
      );
    }
  }

  Future<void> _handleInviteMember() async {
    final email = _inviteEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un email válido'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final orgProvider = context.read<OrganizationProvider>();

    if (orgProvider.activeOrganization == null) {
      return;
    }

    try {
      final success = await orgProvider.inviteMember(
        email: email,
        invitedBy: authProvider.currentUserId!,
        invitedByName: authProvider.currentUser!.displayName,
        role: _selectedRole == 'admin' ? MemberRole.admin : MemberRole.member,
      );

      if (!mounted) return;

      if (success) {
        _inviteEmailController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitación enviada a $email'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('No se pudo enviar la invitación');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRemoveMember(Member member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Miembro'),
        content: Text(
          '¿Estás seguro de eliminar a ${member.displayName} de la organización?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final orgProvider = context.read<OrganizationProvider>();

    try {
      final success = await orgProvider.removeMember(
        member.userId,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Miembro eliminado'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadMembers();
      } else {
        throw Exception('No se pudo eliminar el miembro');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleUpdateRole(Member member, String newRole) async {
    final orgProvider = context.read<OrganizationProvider>();

    try {
      final success = await orgProvider.updateMemberRole(
        member.userId,
        newRole == 'admin' ? MemberRole.admin : MemberRole.member,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rol actualizado'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadMembers();
      } else {
        throw Exception('No se pudo actualizar el rol');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orgProvider = context.watch<OrganizationProvider>();
    final authProvider = context.watch<AuthProvider>();
    final organization = orgProvider.activeOrganization;
    final theme = Theme.of(context);

    if (organization == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Configuración')),
        body: const Center(child: Text('No hay organización seleccionada')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Organization info card
            _buildOrganizationInfo(organization, theme),
            const SizedBox(height: 24),

            // Invite member section
            _buildInviteSection(theme),
            const SizedBox(height: 24),

            // Members list
            _buildMembersSection(
                orgProvider, authProvider, organization, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizationInfo(Organization organization, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.church, color: theme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    organization.nombre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (organization.descripcion != null) ...[
              const SizedBox(height: 8),
              Text(
                organization.descripcion!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ID: ${organization.id}',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: organization.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ID copiado al portapapeles'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invitar Miembro',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _inviteEmailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'correo@ejemplo.com',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: InputDecoration(
                labelText: 'Rol',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'member', child: Text('Miembro')),
                DropdownMenuItem(
                    value: 'admin', child: Text('Administrador')),
              ],
              onChanged: (value) {
                setState(() => _selectedRole = value ?? 'member');
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleInviteMember,
                icon: const Icon(Icons.send),
                label: const Text('Enviar Invitación'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersSection(
    OrganizationProvider orgProvider,
    AuthProvider authProvider,
    Organization organization,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Miembros (${orgProvider.members.length})',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (orgProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (orgProvider.members.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No hay miembros',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orgProvider.members.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final member = orgProvider.members[index];
                  final isCurrentUser =
                      member.userId == authProvider.currentUserId;
                  final isCreator = member.userId == organization.createdBy;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: member.isAdmin
                          ? Colors.purple[100]
                          : Colors.blue[100],
                      child: Icon(
                        member.isAdmin ? Icons.admin_panel_settings : Icons.person,
                        color: member.isAdmin ? Colors.purple : Colors.blue,
                      ),
                    ),
                    title: Text(
                      member.displayName,
                      style: TextStyle(
                        fontWeight: isCurrentUser ? FontWeight.bold : null,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Text(member.isAdmin ? 'Administrador' : 'Miembro'),
                        if (isCreator) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Creador',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: !isCreator && !isCurrentUser
                        ? PopupMenuButton<String>(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: member.isAdmin ? 'demote' : 'promote',
                                child: Row(
                                  children: [
                                    Icon(
                                      member.isAdmin
                                          ? Icons.remove_circle
                                          : Icons.star,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(member.isAdmin
                                        ? 'Cambiar a Miembro'
                                        : 'Promover a Admin'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'remove',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Eliminar',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'remove') {
                                _handleRemoveMember(member);
                              } else if (value == 'promote') {
                                _handleUpdateRole(member, 'admin');
                              } else if (value == 'demote') {
                                _handleUpdateRole(member, 'member');
                              }
                            },
                          )
                        : null,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
