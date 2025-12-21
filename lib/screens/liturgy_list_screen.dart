import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:worshippro/models/liturgy.dart';
import 'package:worshippro/providers/liturgy_provider.dart';
import 'package:worshippro/screens/liturgy_editor_screen.dart';
import 'package:worshippro/widgets/common_widgets.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('WorshipPro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
            tooltip: 'Acerca de',
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
              title: 'No hay liturgias',
              subtitle: 'Crea tu primera liturgia para comenzar',
              action: ElevatedButton.icon(
                onPressed: () => _createNewLiturgy(context),
                icon: const Icon(Icons.add),
                label: const Text('Crear liturgia'),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.liturgies.length,
            itemBuilder: (context, index) {
              final liturgy = provider.liturgies[index];
              return _LiturgyCard(
                liturgy: liturgy,
                onTap: () => _openLiturgyEditor(context, liturgy),
                onDelete: () => _deleteLiturgy(context, liturgy),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewLiturgy(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva liturgia'),
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

  Future<void> _deleteLiturgy(BuildContext context, Liturgy liturgy) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Eliminar liturgia',
      message: '¿Estás seguro de que deseas eliminar "${liturgy.titulo}"?',
      confirmText: 'Eliminar',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      final success =
          await context.read<LiturgyProvider>().deleteLiturgy(liturgy.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Liturgia eliminada correctamente'
                  : 'Error al eliminar liturgia',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
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

  const _LiturgyCard({
    required this.liturgy,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'es_ES');
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          liturgy.titulo,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(liturgy.fecha),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    color: Theme.of(context).colorScheme.error,
                    tooltip: 'Eliminar',
                  ),
                ],
              ),
              if (liturgy.descripcion != null &&
                  liturgy.descripcion!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  liturgy.descripcion!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.access_time,
                    label: liturgy.duracionTotalFormateada,
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.list,
                    label: '${liturgy.bloques.length} bloques',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip informativo pequeño
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
