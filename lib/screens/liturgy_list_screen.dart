import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:worshippro/l10n/app_localizations.dart';
import 'package:worshippro/models/liturgy.dart';
import 'package:worshippro/providers/auth_provider.dart';
import 'package:worshippro/providers/block_provider.dart';
import 'package:worshippro/providers/liturgy_provider.dart';
import 'package:worshippro/providers/organization_provider.dart';
import 'package:worshippro/screens/liturgy_editor_screen.dart';
import 'package:worshippro/screens/organization/organization_selector_screen.dart';
import 'package:worshippro/screens/organization/organization_settings_screen.dart';
import 'package:worshippro/services/pdf_service.dart';
import 'package:worshippro/utils/responsive_utils.dart';
import 'package:worshippro/widgets/common_widgets.dart';
import 'package:worshippro/widgets/language_selector.dart';

/// Pantalla principal que muestra la lista de liturgias
class LiturgyListScreen extends StatefulWidget {
  const LiturgyListScreen({super.key});

  @override
  State<LiturgyListScreen> createState() => _LiturgyListScreenState();
}

class _LiturgyListScreenState extends State<LiturgyListScreen> {
  @override
  void initState() {
    super.initState();
    // Iniciar listener de liturgias
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LiturgyProvider>().initLiturgiesListener();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final orgProvider = context.watch<OrganizationProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.appTitle),
            if (orgProvider.activeOrganization != null)
              Text(
                orgProvider.activeOrganization!.nombre,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          // Switch organization button
          if ((authProvider.currentUser?.organizationIds.length ?? 0) > 1)
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrganizationSelectorScreen(),
                  ),
                );
              },
              tooltip: 'Cambiar Iglesia',
            ),
          
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OrganizationSettingsScreen(),
                ),
              );
            },
            tooltip: 'Configuración',
          ),
          
          const LanguageSelector(),
          
          // About button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
            tooltip: l10n.settings,
          ),
          
          // Logout button
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Usuario',
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'user',
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authProvider.currentUser?.displayName ?? 'Usuario',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      authProvider.currentUser?.email ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 12),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<LiturgyProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return ErrorStateWidget(
              message: provider.error!,
              onRetry: () => provider.initLiturgiesListener(),
            );
          }

          if (provider.liturgies.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.event_note,
              title: l10n.noLiturgies,
              subtitle: l10n.noLiturgiesDesc,
              action: ElevatedButton.icon(
                onPressed: () => _createNewLiturgy(context),
                icon: const Icon(Icons.add),
                label: Text(l10n.createLiturgy),
              ),
            );
          }

          // Stack para mostrar loading overlay cuando el provider está procesando
          return Stack(
            children: [
              _buildLiturgyList(context, provider, l10n),
              if (provider.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Procesando...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<LiturgyProvider>(
        builder: (context, provider, child) {
          // Solo mostrar el FAB si hay cultos en la lista
          if (provider.liturgies.isEmpty) {
            return const SizedBox.shrink();
          }
          
          final l10n = AppLocalizations.of(context);
          return FloatingActionButton.extended(
            onPressed: () => _createNewLiturgy(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.createLiturgy),
          );
        },
      ),
    );
  }

  void _createNewLiturgy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LiturgyEditorScreen(),
      ),
    );
  }

  void _openLiturgyEditor(BuildContext context, Liturgy liturgy) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiturgyEditorScreen(liturgyId: liturgy.id),
      ),
    );
  }

  /// Elimina una liturgia con o sin confirmación previa
  Future<void> _deleteLiturgy(
    BuildContext context, 
    Liturgy liturgy, {
    bool requireConfirmation = true,
  }) async {
    final l10n = AppLocalizations.of(context);
    
    // Si se requiere confirmación, mostrar diálogo
    if (requireConfirmation) {
      final confirmed = await ConfirmDialog.show(
        context,
        title: l10n.confirmDelete,
        message: l10n.confirmDeleteLiturgy,
        confirmText: l10n.delete,
        cancelText: l10n.cancel,
        isDestructive: true,
      );
      
      if (!confirmed || !context.mounted) return;
    }

    // Ejecutar eliminación (el loading se muestra automáticamente por el Stack)
    final success = await context.read<LiturgyProvider>().deleteLiturgy(liturgy.id);

    // Mostrar resultado solo si el widget sigue montado
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? l10n.translate('liturgyDeletedSuccess')
                : l10n.errorDeletingLiturgy,
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: Duration(seconds: success ? 2 : 3),
        ),
      );
    }
  }

  /// Construye la lista de liturgias (ListView o GridView según el dispositivo)
  Widget _buildLiturgyList(
    BuildContext context, 
    LiturgyProvider provider, 
    AppLocalizations l10n,
  ) {
    return ResponsiveBuilder(
      builder: (context, info) {
        // Para móviles, usar ListView simple con dismissible
        if (info.isMobile || (info.isTablet && info.isPortrait)) {
          return ListView.builder(
            padding: info.adaptivePadding,
            itemCount: provider.liturgies.length,
            itemBuilder: (context, index) {
              final liturgy = provider.liturgies[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: Key(liturgy.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await ConfirmDialog.show(
                      context,
                      title: l10n.confirmDelete,
                      message: l10n.confirmDeleteLiturgy,
                      confirmText: l10n.delete,
                      cancelText: l10n.cancel,
                      isDestructive: true,
                    );
                  },
                  onDismissed: (direction) {
                    _deleteLiturgy(context, liturgy, requireConfirmation: false);
                  },
                  child: _LiturgyCard(
                    liturgy: liturgy,
                    onTap: () => _openLiturgyEditor(context, liturgy),
                    onDelete: () => _deleteLiturgy(context, liturgy),
                    isCompact: info.isMobile,
                  ),
                ),
              );
            },
          );
        }

        // Para tablets en landscape o desktop, usar grid
        return GridView.builder(
          padding: info.adaptivePadding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: info.isDesktop ? 3 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: info.isDesktop ? 1.5 : 1.3,
          ),
          itemCount: provider.liturgies.length,
          itemBuilder: (context, index) {
            final liturgy = provider.liturgies[index];
            return _LiturgyCard(
              liturgy: liturgy,
              onTap: () => _openLiturgyEditor(context, liturgy),
              onDelete: () => _deleteLiturgy(context, liturgy),
              isCompact: false,
            );
          },
        );
      },
    );
  }

  void _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Limpiar providers antes de cerrar sesión
      context.read<OrganizationProvider>().clear();
      context.read<LiturgyProvider>().clear();
      context.read<BlockProvider>().clear();
      
      // Cerrar sesión
      await context.read<AuthProvider>().signOut();
    }
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'WorshipPro',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.church,
        size: 48,
        color: Color(0xFF6366F1),
      ),
      children: [
        const Text(
          'Aplicación para crear, organizar y presentar liturgias de cultos cristianos.',
        ),
      ],
    );
  }
}

/// Card para mostrar una liturgia en la lista
class _LiturgyCard extends StatelessWidget {
  final Liturgy liturgy;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isCompact;

  const _LiturgyCard({
    required this.liturgy,
    required this.onTap,
    required this.onDelete,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', languageCode == 'es' ? 'es_ES' : 'en_US');
    
    return ResponsiveBuilder(
      builder: (context, info) {
        return Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: onTap,
            onLongPress: () => _showContextMenu(context),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: info.valueByDevice(
                mobile: const EdgeInsets.all(16),
                tablet: const EdgeInsets.all(20),
                desktop: const EdgeInsets.all(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              liturgy.titulo,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: info.fontSizeFor(20),
                              ),
                              maxLines: isCompact ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: info.isMobile ? 2 : 4),
                            Text(
                              liturgy.hora != null
                                  ? '${dateFormat.format(liturgy.fecha)} · ${liturgy.hora}'
                                  : dateFormat.format(liturgy.fecha),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: info.fontSizeFor(14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: () => _sharePdf(context),
                        tooltip: 'Compartir PDF',
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_outlined),
                        onPressed: () => _duplicateLiturgy(context),
                        tooltip: 'Duplicar',
                      ),
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        onPressed: () => _downloadPdf(context),
                        tooltip: 'Descargar PDF',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: onDelete,
                        color: Theme.of(context).colorScheme.error,
                        tooltip: AppLocalizations.of(context).delete,
                      ),
                    ],
                  ),
                  if (liturgy.descripcion != null &&
                      liturgy.descripcion!.isNotEmpty &&
                      !isCompact) ...[
                    SizedBox(height: info.adaptiveSpacing),
                    Text(
                      liturgy.descripcion!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: info.fontSizeFor(14),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: info.adaptiveSpacing),
                  Wrap(
                    spacing: info.adaptiveSpacing,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.access_time,
                        label: liturgy.duracionTotalFormateada,
                        isCompact: isCompact,
                      ),
                      _InfoChip(
                        icon: Icons.list,
                        label: '${liturgy.bloques.length} ${l10n.blocks}',
                        isCompact: isCompact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Generando PDF...'),
            ],
          ),
          duration: Duration(seconds: 10),
        ),
      );
      await PdfService.sharePdf(liturgy);
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    } catch (e) {
      debugPrint('Error al compartir PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir el PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Generando PDF...'),
            ],
          ),
          duration: Duration(seconds: 10),
        ),
      );
      final filePath = await PdfService.savePdf(liturgy);
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        if (filePath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF guardado con éxito'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error al guardar PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _duplicateLiturgy(BuildContext context) async {
    final provider = context.read<LiturgyProvider>();
    final newLiturgyId = await provider.duplicateLiturgy(liturgy.id);
    
    if (context.mounted && newLiturgyId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Culto duplicado correctamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al duplicar el culto'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showContextMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.edit),
              onTap: () {
                Navigator.pop(context);
                onTap();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Compartir PDF'),
              onTap: () {
                Navigator.pop(context);
                _sharePdf(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('Descargar PDF'),
              onTap: () {
                Navigator.pop(context);
                _downloadPdf(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(l10n.translate('duplicate')),
              onTap: () {
                Navigator.pop(context);
                _duplicateLiturgy(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                l10n.delete,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip informativo pequeño
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isCompact;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, info) {
        final fontSize = info.fontSizeFor(isCompact ? 12 : 14);
        final iconSize = info.valueByDevice(
          mobile: isCompact ? 14.0 : 16.0,
          tablet: 16.0,
          desktop: 18.0,
        );
        
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: info.isMobile ? 8 : 12,
            vertical: info.isMobile ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: info.isMobile ? 4 : 6),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
