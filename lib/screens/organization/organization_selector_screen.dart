import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/block_provider.dart';
import '../../providers/liturgy_provider.dart';
import '../../providers/organization_provider.dart';
import '../liturgy_list_screen.dart';
import 'create_organization_screen.dart';
import 'invitations_screen.dart';

/// Pantalla para seleccionar o crear organización
class OrganizationSelectorScreen extends StatefulWidget {
  const OrganizationSelectorScreen({super.key});

  @override
  State<OrganizationSelectorScreen> createState() =>
      _OrganizationSelectorScreenState();
}

class _OrganizationSelectorScreenState
    extends State<OrganizationSelectorScreen> {
  @override
  void initState() {
    super.initState();
    print('🔵 OrganizationSelector: initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserOrganizations();
      _checkPendingInvitations();
    });
  }

  Future<void> _loadUserOrganizations() async {
    print('🔵 OrganizationSelector: Cargando organizaciones del usuario');
    final authProvider = context.read<AuthProvider>();
    final orgProvider = context.read<OrganizationProvider>();

    if (authProvider.currentUser != null) {
      print('🔵 OrganizationSelector: OrganizationIds = ${authProvider.currentUser!.organizationIds}');
      await orgProvider.loadUserOrganizations(
        authProvider.currentUser!.organizationIds,
      );
      print('🔵 OrganizationSelector: Organizaciones cargadas = ${orgProvider.userOrganizations.length}');
    }
  }

  Future<void> _checkPendingInvitations() async {
    final authProvider = context.read<AuthProvider>();
    final orgProvider = context.read<OrganizationProvider>();

    if (authProvider.currentUser != null) {
      await orgProvider.loadPendingInvitations(
        authProvider.currentUser!.email,
      );
    }
  }

  Future<void> _handleSelectOrganization(String organizationId) async {
    print('🔵 OrganizationSelector: Seleccionando organización $organizationId');
    final authProvider = context.read<AuthProvider>();
    final orgProvider = context.read<OrganizationProvider>();

    await orgProvider.setActiveOrganization(organizationId);

    // Actualizar usuario con organización activa en Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(authProvider.currentUserId)
        .update({
      'activeOrganizationId': organizationId,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Actualizar el usuario local en AuthProvider
    authProvider.updateActiveOrganization(organizationId);

    // Configurar contexto de LiturgyProvider y BlockProvider
    if (mounted) {
      final liturgyProvider = context.read<LiturgyProvider>();
      final blockProvider = context.read<BlockProvider>();
      
      liturgyProvider.setContext(
        organizationId,
        authProvider.currentUserId!,
      );
      blockProvider.setOrganizationId(organizationId);
    }

    print('🔵 OrganizationSelector: Navegando a LiturgyListScreen');
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LiturgyListScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final orgProvider = context.watch<OrganizationProvider>();
    final theme = Theme.of(context);

    // Si no hay organizaciones, mostrar pantalla de bienvenida
    if (orgProvider.userOrganizations.isEmpty) {
      return _buildWelcomeScreen(theme, orgProvider);
    }

    // Si hay organizaciones, mostrar lista
    return _buildOrganizationList(theme, orgProvider, authProvider);
  }

  Widget _buildWelcomeScreen(
      ThemeData theme, OrganizationProvider orgProvider) {
    final hasPendingInvitations =
        orgProvider.pendingInvitations.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Icon(
                    Icons.church_outlined,
                    size: 100,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    '¡Bienvenido a WorshipPro!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Para comenzar, crea tu iglesia o acepta una invitación para unirte a una organización existente.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Create organization button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateOrganizationScreen(),
                          ),
                        );
                        if (result == true && mounted) {
                          await _loadUserOrganizations();
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Crear Mi Iglesia'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  if (hasPendingInvitations) ...[
                    const SizedBox(height: 16),

                    // View invitations button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InvitationsScreen(),
                            ),
                          );
                          if (result == true && mounted) {
                            await _loadUserOrganizations();
                          }
                        },
                        icon: const Icon(Icons.mail_outline),
                        label: Text(
                          'Ver Invitaciones (${orgProvider.pendingInvitations.length})',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Logout button
                  TextButton.icon(
                    onPressed: () {
                      context.read<OrganizationProvider>().clear();
                      context.read<LiturgyProvider>().clear();
                      context.read<BlockProvider>().clear();
                      context.read<AuthProvider>().signOut();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar Sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizationList(
    ThemeData theme,
    OrganizationProvider orgProvider,
    AuthProvider authProvider,
  ) {
    final hasPendingInvitations = orgProvider.pendingInvitations.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Mis Iglesias'),
        actions: [
          // Botón de invitaciones
          if (hasPendingInvitations)
            IconButton(
              icon: Badge(
                label: Text('${orgProvider.pendingInvitations.length}'),
                child: const Icon(Icons.mail),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InvitationsScreen(),
                  ),
                );
                if (result == true && mounted) {
                  await _loadUserOrganizations();
                  await _checkPendingInvitations();
                }
              },
              tooltip: 'Ver Invitaciones',
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<OrganizationProvider>().clear();
              context.read<LiturgyProvider>().clear();
              context.read<BlockProvider>().clear();
              context.read<AuthProvider>().signOut();
            },
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: orgProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orgProvider.userOrganizations.length,
              itemBuilder: (context, index) {
                final org = orgProvider.userOrganizations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: theme.primaryColor,
                      child: const Icon(Icons.church, color: Colors.white),
                    ),
                    title: Text(
                      org.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: org.descripcion != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(org.descripcion!),
                          )
                        : null,
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _handleSelectOrganization(org.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateOrganizationScreen(),
            ),
          );
          if (result == true && mounted) {
            await _loadUserOrganizations();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Iglesia'),
      ),
    );
  }
}
