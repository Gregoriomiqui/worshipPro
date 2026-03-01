import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organization_provider.dart';
import '../../models/invitation.dart';

/// Pantalla para ver y gestionar invitaciones
class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({super.key});

  @override
  State<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInvitations();
    });
  }

  Future<void> _loadInvitations() async {
    final authProvider = context.read<AuthProvider>();
    final orgProvider = context.read<OrganizationProvider>();

    if (authProvider.currentUser != null) {
      await orgProvider.loadPendingInvitations(
        authProvider.currentUser!.email,
      );
    }
  }

  Future<void> _handleAcceptInvitation(Invitation invitation) async {
    final authProvider = context.read<AuthProvider>();
    final orgProvider = context.read<OrganizationProvider>();

    if (authProvider.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No hay usuario autenticado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aceptar Invitación'),
        content: Text(
          '¿Deseas unirte a ${invitation.organizationName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await orgProvider.acceptInvitation(
        invitationId: invitation.id,
        userId: authProvider.currentUserId!,
        displayName: authProvider.currentUser!.displayName,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Te has unido a la organización exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reload invitations and return to previous screen
        await _loadInvitations();
        if (orgProvider.pendingInvitations.isEmpty && mounted) {
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('No se pudo aceptar la invitación');
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

  Future<void> _handleRejectInvitation(Invitation invitation) async {
    final orgProvider = context.read<OrganizationProvider>();

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar Invitación'),
        content: Text(
          '¿Estás seguro de rechazar la invitación a ${invitation.organizationName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await orgProvider.rejectInvitation(invitation.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitación rechazada'),
            backgroundColor: Colors.orange,
          ),
        );
        
        // Reload invitations
        await _loadInvitations();
        if (orgProvider.pendingInvitations.isEmpty && mounted) {
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('No se pudo rechazar la invitación');
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Invitaciones'),
      ),
      body: orgProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orgProvider.pendingInvitations.isEmpty
              ? _buildEmptyState(theme)
              : _buildInvitationList(orgProvider, theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mail_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes invitaciones pendientes',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando te inviten a una organización, las verás aquí',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationList(
      OrganizationProvider orgProvider, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orgProvider.pendingInvitations.length,
      itemBuilder: (context, index) {
        final invitation = orgProvider.pendingInvitations[index];
        final dateFormat = DateFormat('dd MMM yyyy', 'es');
        final expiresAt = invitation.expiresAt != null
            ? dateFormat.format(invitation.expiresAt!)
            : 'Sin fecha de expiración';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Organization name
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.primaryColor,
                      child: const Icon(Icons.church, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invitation.organizationName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Invitado por: ${invitation.invitedByName}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Role badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: invitation.role == 'admin'
                        ? Colors.purple[50]
                        : Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    invitation.role == 'admin' ? 'Administrador' : 'Miembro',
                    style: TextStyle(
                      color: invitation.role == 'admin'
                          ? Colors.purple[700]
                          : Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Expiration date
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Expira: $expiresAt',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => _handleRejectInvitation(invitation),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Rechazar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _handleAcceptInvitation(invitation),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Aceptar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
