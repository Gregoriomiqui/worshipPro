import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:worshippro/l10n/app_localizations.dart';
import 'package:worshippro/models/block_type.dart';
import 'package:worshippro/models/liturgy.dart';
import 'package:worshippro/models/liturgy_block.dart';
import 'package:worshippro/models/song.dart';
import 'package:worshippro/providers/block_provider.dart';
import 'package:worshippro/providers/liturgy_provider.dart';
import 'package:worshippro/screens/presentation_mode_screen.dart';
import 'package:worshippro/utils/responsive_utils.dart';
import 'package:worshippro/widgets/common_widgets.dart';

/// Pantalla para editar o crear un culto
class LiturgyEditorScreen extends StatefulWidget {
  final String? liturgyId;

  const LiturgyEditorScreen({super.key, this.liturgyId});

  @override
  State<LiturgyEditorScreen> createState() => _LiturgyEditorScreenState();
}

class _LiturgyEditorScreenState extends State<LiturgyEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  bool _isNewLiturgy = true;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _isNewLiturgy = widget.liturgyId == null;
    if (!_isNewLiturgy) {
      _loadLiturgy();
      
      // Agregar listeners para auto-guardado
      _tituloController.addListener(_onTextChanged);
      _descripcionController.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    // Cancelar el timer anterior si existe
    _autoSaveTimer?.cancel();
    
    // Crear un nuevo timer que se ejecutará después de 2 segundos de inactividad
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      if (!_isNewLiturgy && mounted) {
        _saveLiturgy(showSuccessMessage: false);
      }
    });
  }

  Future<void> _loadLiturgy() async {
    setState(() => _isLoading = true);
    
    // Obtener el provider antes del await
    final provider = context.read<LiturgyProvider>();
    await provider.loadLiturgy(widget.liturgyId!);
    
    // Verificar que el widget aún esté montado
    if (!mounted) return;
    
    final liturgy = provider.currentLiturgy;
    if (liturgy != null) {
      _tituloController.text = liturgy.titulo;
      _descripcionController.text = liturgy.descripcion ?? '';
      _selectedDate = liturgy.fecha;
      if (liturgy.hora != null) {
        final parts = liturgy.hora!.split(':');
        if (parts.length == 2) {
          _selectedTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0,
          );
        }
      }
    }
    
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNewLiturgy ? 'Nuevo culto' : 'Editar culto'),
        actions: [
          // Mostrar botón de guardar solo cuando es nueva liturgia
          if (_isNewLiturgy)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveLiturgy,
              tooltip: l10n.save,
            ),
          if (!_isNewLiturgy)
            IconButton(
              icon: const Icon(Icons.present_to_all),
              onPressed: _openPresentationMode,
              tooltip: l10n.presentationMode,
            ),
        ],
      ),
      body: _isLoading
          ? LoadingWidget(message: l10n.translate('loadingLiturgy'))
          : Consumer<LiturgyProvider>(
              builder: (context, provider, child) {
                if (provider.error != null) {
                  return ErrorStateWidget(
                    message: provider.error!,
                    onRetry: _loadLiturgy,
                  );
                }

                final liturgy = provider.currentLiturgy;
                
                return ResponsiveBuilder(
                  builder: (context, info) {
                    // En móvil o tablet portrait: usar tabs
                    if (info.isMobile || (info.isTablet && info.isPortrait)) {
                      return _MobileLayout(
                        liturgy: liturgy,
                        infoPanel: _buildInfoPanel(liturgy, info),
                        blocksPanel: _buildBlocksPanel(liturgy, info),
                      );
                    }
                    
                    // En tablet landscape o desktop: usar panel dual
                    return Row(
                      children: [
                        // Panel izquierdo: Información de la liturgia
                        Expanded(
                          flex: 2,
                          child: _buildInfoPanel(liturgy, info),
                        ),
                        
                        // Panel derecho: Bloques
                        Expanded(
                          flex: 3,
                          child: _buildBlocksPanel(liturgy, info),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildInfoPanel(Liturgy? liturgy, ResponsiveInfo info) {
    return Container(
      color: Colors.grey[50],
      padding: info.adaptivePadding,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Información del culto',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: info.fontSizeFor(20),
                ),
              ),
              SizedBox(height: info.adaptiveSpacing * 2),
              
              // Título
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ej: Culto dominical',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El título es requerido';
                  }
                  return null;
                },
              ),
              SizedBox(height: info.adaptiveSpacing),
              
              // Fecha y Hora
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('EEEE, d MMMM yyyy', 'es_ES')
                              .format(_selectedDate),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: info.adaptiveSpacing),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: _selectTime,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Hora',
                          prefixIcon: const Icon(Icons.access_time),
                          suffixIcon: _selectedTime != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    setState(() => _selectedTime = null);
                                    if (!_isNewLiturgy) {
                                      _saveLiturgy(showSuccessMessage: false);
                                    }
                                  },
                                )
                              : null,
                        ),
                        child: Text(
                          _selectedTime != null
                              ? _selectedTime!.format(context)
                              : 'Sin hora',
                          style: _selectedTime == null
                              ? TextStyle(
                                  color: Theme.of(context).hintColor,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: info.adaptiveSpacing),
              
              // Descripción
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  hintText: 'Añade notas sobre este culto',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: info.adaptiveSpacing * 2),
              
              // Duración total
              if (liturgy != null && liturgy.bloques.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Theme.of(context).colorScheme.primary,
                            size: info.valueByDevice(mobile: 24, tablet: 28, desktop: 28),
                          ),
                          SizedBox(width: info.adaptiveSpacing),
                          Text(
                            'Duración total',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: info.fontSizeFor(18),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: info.adaptiveSpacing),
                      Text(
                        liturgy.duracionTotalFormateada,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: info.fontSizeFor(32),
                            ),
                      ),
                      SizedBox(height: info.adaptiveSpacing / 2),
                      Text(
                        '${liturgy.duracionTotalMinutos} minutos',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlocksPanel(Liturgy? liturgy, ResponsiveInfo info) {
    final l10n = AppLocalizations.of(context);
    
    if (liturgy == null) {
      return const EmptyStateWidget(
        icon: Icons.event_note,
        title: 'Guarda el culto',
        subtitle: 'Primero guarda la información básica para agregar bloques',
      );
    }

    if (liturgy.bloques.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.view_list,
        title: 'Sin bloques',
        subtitle: 'Agrega bloques para estructurar el culto',
        action: ElevatedButton.icon(
          onPressed: () => _addBlock(liturgy.id),
          icon: const Icon(Icons.add),
          label: const Text('Agregar bloque'),
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: info.adaptivePadding,
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Bloques del culto',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: info.fontSizeFor(20),
                  ),
                ),
              ),
              SizedBox(width: info.adaptiveSpacing),
              ElevatedButton.icon(
                onPressed: () => _addBlock(liturgy.id),
                icon: const Icon(Icons.add),
                label: Text(info.isMobile ? l10n.add : l10n.translate('addBlockShort')),
              ),
            ],
          ),
        ),
        
        // Lista de bloques
        Expanded(
          child: ReorderableListView.builder(
            padding: info.adaptivePadding,
            itemCount: liturgy.bloques.length,
            onReorder: (oldIndex, newIndex) =>
                _reorderBlocks(liturgy, oldIndex, newIndex),
            itemBuilder: (context, index) {
              final block = liturgy.bloques[index];
              return _BlockCard(
                key: ValueKey(block.id),
                block: block,
                liturgyId: liturgy.id,
                onEdit: () => _editBlock(liturgy.id, block),
                onDelete: () => _deleteBlock(liturgy.id, block.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      // Auto-guardar cambio de fecha
      if (!_isNewLiturgy) {
        _saveLiturgy(showSuccessMessage: false);
      }
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('es', 'ES'),
          child: child,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
      if (!_isNewLiturgy) {
        _saveLiturgy(showSuccessMessage: false);
      }
    }
  }

  Future<void> _saveLiturgy({bool showSuccessMessage = true}) async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final provider = context.read<LiturgyProvider>();
    
    if (_isNewLiturgy) {
      // Crear nueva liturgia
      final liturgy = Liturgy(
        id: const Uuid().v4(),
        titulo: _tituloController.text,
        fecha: _selectedDate,
        hora: _selectedTime != null
            ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
            : null,
        descripcion: _descripcionController.text.isEmpty
            ? null
            : _descripcionController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final liturgyId = await provider.createLiturgy(liturgy);
      
      if (!mounted) return;
      
      if (liturgyId != null && liturgyId.isNotEmpty) {
        setState(() => _isNewLiturgy = false);
        await provider.loadLiturgy(liturgyId);
        
        // Agregar listeners para auto-guardado ahora que ya no es nueva
        _tituloController.addListener(_onTextChanged);
        _descripcionController.addListener(_onTextChanged);
        
        if (mounted && showSuccessMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.translate('liturgyCreatedSuccess')),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Error al crear
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSavingLiturgy),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      // Actualizar liturgia existente
      final currentLiturgy = provider.currentLiturgy;
      
      if (currentLiturgy == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errorSavingLiturgy),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      
      final updatedLiturgy = currentLiturgy.copyWith(
        titulo: _tituloController.text,
        fecha: _selectedDate,
        hora: _selectedTime != null
            ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
            : null,
        clearHora: _selectedTime == null,
        descripcion: _descripcionController.text.isEmpty
            ? null
            : _descripcionController.text,
        updatedAt: DateTime.now(),
      );

      final success = await provider.updateLiturgy(updatedLiturgy);
      
      if (mounted && showSuccessMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                ? l10n.translate('liturgyUpdatedSuccess') 
                : l10n.errorSavingLiturgy
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: Duration(seconds: success ? 2 : 3),
          ),
        );
      }
    }
  }

  Future<void> _addBlock(String liturgyId) async {
    final block = await showDialog<LiturgyBlock>(
      context: context,
      builder: (context) => const _BlockDialog(),
    );

    if (block != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Agregando bloque...'),
            ],
          ),
          duration: Duration(seconds: 15),
        ),
      );
      
      try {
        final provider = context.read<LiturgyProvider>();
        final currentBlocks = provider.currentLiturgy?.bloques ?? [];
        
        final blockWithOrder = block.copyWith(orden: currentBlocks.length);
        
        final blockId = await context.read<BlockProvider>().createBlock(
              liturgyId,
              blockWithOrder,
            );

        if (blockId != null && mounted) {
          // Forzar recarga completa de la liturgia
          await provider.loadLiturgy(liturgyId);
          
          // Auto-guardar la liturgia después de agregar el bloque (sin mensaje)
          await _saveLiturgy(showSuccessMessage: false);
          
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bloque agregado'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al agregar bloque'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
        }
      }
    }
  }

  Future<void> _editBlock(String liturgyId, LiturgyBlock block) async {
    final updatedBlock = await showDialog<LiturgyBlock>(
      context: context,
      builder: (context) => _BlockDialog(block: block),
    );

    if (updatedBlock != null && mounted) {
      final success = await context.read<BlockProvider>().updateBlock(
            liturgyId,
            updatedBlock,
          );

      if (mounted) {
        if (success) {
          // Forzar recarga completa de la liturgia
          await context.read<LiturgyProvider>().loadLiturgy(liturgyId);
          
          // Auto-guardar la liturgia después de editar el bloque (sin mensaje)
          await _saveLiturgy(showSuccessMessage: false);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bloque actualizado y culto guardado'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al actualizar bloque'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteBlock(String liturgyId, String blockId) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.translate('confirmDeleteBlock'),
      message: l10n.confirmDeleteBlock,
      confirmText: l10n.delete,
      cancelText: l10n.cancel,
      isDestructive: true,
    );

    if (confirmed && mounted) {
      final success = await context.read<BlockProvider>().deleteBlock(
            liturgyId,
            blockId,
          );

      if (mounted) {
        if (success) {
          // Forzar recarga completa de la liturgia
          await context.read<LiturgyProvider>().loadLiturgy(liturgyId);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bloque eliminado correctamente'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar bloque'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _reorderBlocks(
      Liturgy liturgy, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final blocks = List<LiturgyBlock>.from(liturgy.bloques);
    final block = blocks.removeAt(oldIndex);
    blocks.insert(newIndex, block);

    // Actualizar orden de todos los bloques
    for (var i = 0; i < blocks.length; i++) {
      final updatedBlock = blocks[i].copyWith(orden: i);
      await context.read<BlockProvider>().updateBlock(
            liturgy.id,
            updatedBlock,
          );
    }

    if (mounted) {
      await context.read<LiturgyProvider>().refreshCurrentLiturgy();
      
      // Auto-guardar la liturgia después de reordenar (sin mensaje)
      await _saveLiturgy(showSuccessMessage: false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Orden actualizado y culto guardado'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _openPresentationMode() {
    final liturgy = context.read<LiturgyProvider>().currentLiturgy;
    if (liturgy != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PresentationModeScreen(liturgy: liturgy),
        ),
      );
    }
  }
}

/// Layout para móviles que usa tabs en lugar de panel dual
class _MobileLayout extends StatelessWidget {
  final Liturgy? liturgy;
  final Widget infoPanel;
  final Widget blocksPanel;

  const _MobileLayout({
    required this.liturgy,
    required this.infoPanel,
    required this.blocksPanel,
  });

  @override
  Widget build(BuildContext context) {
    if (liturgy == null) {
      return infoPanel;
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.info_outline), text: 'Información'),
                Tab(icon: Icon(Icons.list), text: 'Bloques'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                infoPanel,
                blocksPanel,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card para mostrar un bloque
class _BlockCard extends StatelessWidget {
  final LiturgyBlock block;
  final String liturgyId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BlockCard({
    super.key,
    required this.block,
    required this.liturgyId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, info) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: info.valueByDevice(
                mobile: const EdgeInsets.all(12),
                tablet: const EdgeInsets.all(16),
                desktop: const EdgeInsets.all(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icono de tipo
                      Container(
                        padding: EdgeInsets.all(info.isMobile ? 6 : 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getBlockIcon(block.tipo),
                          color: Theme.of(context).colorScheme.primary,
                          size: info.isMobile ? 20 : 24,
                        ),
                      ),
                      SizedBox(width: info.adaptiveSpacing),
                      
                      // Tipo y descripción
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              block.tipo.displayName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: info.fontSizeFor(16),
                                  ),
                            ),
                            if (block.descripcion != null && block.descripcion!.isNotEmpty)
                              Text(
                                block.descripcion!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: info.fontSizeFor(14),
                                ),
                                maxLines: info.isMobile ? 1 : 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      
                      // Duración
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: info.isMobile ? 8 : 12,
                          vertical: info.isMobile ? 4 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${block.duracionMinutos} min',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            fontSize: info.fontSizeFor(12),
                          ),
                        ),
                      ),
                      
                      // Botones
                      if (!info.isMobile) ...[
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: onDelete,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const Icon(Icons.drag_handle),
                      ],
                    ],
                  ),
                  
                  // Fila de acciones en móvil
                  if (info.isMobile) ...[
                    SizedBox(height: info.adaptiveSpacing / 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: onDelete,
                          color: Theme.of(context).colorScheme.error,
                          iconSize: 20,
                        ),
                        const Icon(Icons.drag_handle, size: 20),
                      ],
                    ),
                  ],
                  
                  // Responsables
                  if (block.responsables.isNotEmpty) ...[
                    SizedBox(height: info.adaptiveSpacing),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: block.responsables
                          .map((r) => Chip(
                                label: Text(
                                  r,
                                  style: TextStyle(
                                    fontSize: info.fontSizeFor(12),
                                  ),
                                ),
                                avatar: Icon(
                                  Icons.person,
                                  size: info.isMobile ? 14 : 16,
                                ),
                                visualDensity: info.isMobile
                                    ? VisualDensity.compact
                                    : VisualDensity.standard,
                              ))
                          .toList(),
                    ),
                  ],
                  
                  // Canciones (si es adoración)
                  if (block.isAdoracion) ...[
                    SizedBox(height: info.adaptiveSpacing),
                    if (block.canciones.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.music_note,
                              size: info.isMobile ? 14 : 16,
                              color: Colors.grey,
                            ),
                            SizedBox(width: info.adaptiveSpacing / 2),
                            Text(
                              'Sin canciones',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: info.fontSizeFor(14),
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...block.canciones.map((song) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.music_note,
                                  size: info.isMobile ? 14 : 16,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: info.adaptiveSpacing / 2),
                                Expanded(
                                  child: Text(
                                    song.nombre,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: info.fontSizeFor(14),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (song.tono != null) ...[
                                  SizedBox(width: info.adaptiveSpacing / 2),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: info.isMobile ? 6 : 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.blue),
                                    ),
                                    child: Text(
                                      song.tono!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                        fontSize: info.fontSizeFor(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getBlockIcon(BlockType type) {
    switch (type) {
      case BlockType.adoracionAlabanza:
        return Icons.music_note;
      case BlockType.oracion:
        return Icons.favorite;
      case BlockType.lecturaBiblica:
        return Icons.book;
      case BlockType.reflexion:
        return Icons.menu_book;
      case BlockType.accionGracias:
        return Icons.volunteer_activism;
      case BlockType.ofrendas:
        return Icons.card_giftcard;
      case BlockType.anuncios:
        return Icons.campaign;
      case BlockType.saludos:
        return Icons.waving_hand;
      case BlockType.despedida:
        return Icons.exit_to_app;
      case BlockType.otros:
        return Icons.more_horiz;
    }
  }
}

/// Diálogo para crear/editar un bloque
class _BlockDialog extends StatefulWidget {
  final LiturgyBlock? block;

  const _BlockDialog({this.block});

  @override
  State<_BlockDialog> createState() => _BlockDialogState();
}

class _BlockDialogState extends State<_BlockDialog> {
  final _formKey = GlobalKey<FormState>();
  late BlockType _selectedType;
  final _descripcionController = TextEditingController();
  final _responsablesController = TextEditingController();
  final _comentariosController = TextEditingController();
  final _duracionController = TextEditingController();
  final List<Song> _canciones = [];

  @override
  void initState() {
    super.initState();
    if (widget.block != null) {
      _selectedType = widget.block!.tipo;
      _descripcionController.text = widget.block!.descripcion ?? '';
      _responsablesController.text = widget.block!.responsables.join(', ');
      _comentariosController.text = widget.block!.comentarios ?? '';
      _duracionController.text = widget.block!.duracionMinutos.toString();
      _canciones.addAll(widget.block!.canciones);
    } else {
      _selectedType = BlockType.adoracionAlabanza;
      _duracionController.text = '10';
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _responsablesController.dispose();
    _comentariosController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 900 ? 900.0 : screenWidth * 0.9;
    
    return AlertDialog(
      title: Text(widget.block == null ? 'Nuevo bloque' : 'Editar bloque'),
      content: SizedBox(
        width: dialogWidth,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tipo
                DropdownButtonFormField<BlockType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de bloque',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: BlockType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.displayName),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedType = value!);
                  },
                ),
                const SizedBox(height: 16),
                
                // Descripción
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Ej: Tiempo de alabanza congregacional',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Duración
                TextFormField(
                  controller: _duracionController,
                  decoration: const InputDecoration(
                    labelText: 'Duración (minutos)',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La duración es requerida';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Debe ser un número';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Responsables
                TextFormField(
                  controller: _responsablesController,
                  decoration: const InputDecoration(
                    labelText: 'Responsables (separados por coma)',
                    hintText: 'Ej: Juan Pérez, María González',
                    prefixIcon: Icon(Icons.people),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Comentarios
                TextFormField(
                  controller: _comentariosController,
                  decoration: const InputDecoration(
                    labelText: 'Comentarios (opcional)',
                    prefixIcon: Icon(Icons.comment),
                  ),
                  maxLines: 2,
                ),
                
                // Canciones (solo para adoración)
                if (_selectedType == BlockType.adoracionAlabanza) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.songs,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Flexible(
                        child: TextButton.icon(
                          onPressed: _addSong,
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar canción'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_canciones.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: const Center(
                        child: Text(
                          'No hay canciones. Agrega al menos una.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 600;
                        return Container(
                          constraints: BoxConstraints(
                            maxHeight: isNarrow ? 200 : 250,
                          ),
                          child: ReorderableListView.builder(
                            shrinkWrap: true,
                            itemCount: _canciones.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (oldIndex < newIndex) {
                                  newIndex -= 1;
                                }
                                final song = _canciones.removeAt(oldIndex);
                                _canciones.insert(newIndex, song);
                              });
                            },
                            itemBuilder: (context, index) {
                              final song = _canciones[index];
                              return Card(
                                key: ValueKey(song.id),
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  dense: isNarrow,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: isNarrow ? 8 : 12,
                                    vertical: isNarrow ? 4 : 8,
                                  ),
                                  leading: SizedBox(
                                    width: isNarrow ? 40 : 50,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${index + 1}.',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                            fontSize: isNarrow ? 12 : 14,
                                          ),
                                        ),
                                        SizedBox(width: isNarrow ? 4 : 8),
                                        Icon(
                                          Icons.music_note,
                                          size: isNarrow ? 18 : 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              song.nombre,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: isNarrow ? 13 : 15,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          if (song.tono != null) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isNarrow ? 6 : 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: Colors.blue),
                                              ),
                                              child: Text(
                                                song.tono!,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue,
                                                  fontSize: isNarrow ? 10 : 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (song.autor != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Autor: ${song.autor}',
                                          style: TextStyle(
                                            fontSize: isNarrow ? 11 : 13,
                                            color: Colors.grey[600],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ],
                                  ),
                                  trailing: SizedBox(
                                    width: isNarrow ? 60 : 70,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() => _canciones.remove(song));
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(isNarrow ? 4 : 8),
                                            child: Icon(
                                              Icons.delete,
                                              size: isNarrow ? 20 : 24,
                                              color: Colors.red[400],
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.drag_handle,
                                          size: isNarrow ? 18 : 24,
                                          color: Colors.grey[400],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _saveBlock,
          child: Text(l10n.save),
        ),
      ],
    );
  }

  Future<void> _addSong() async {
    final song = await showDialog<Song>(
      context: context,
      builder: (context) => const _SongDialog(),
    );

    if (song != null) {
      setState(() => _canciones.add(song));
    }
  }

  void _saveBlock() {
    if (!_formKey.currentState!.validate()) return;

    // Validar que los bloques de adoración tengan al menos una canción
    if (_selectedType == BlockType.adoracionAlabanza && _canciones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes agregar al menos una canción para bloques de adoración'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final responsables = _responsablesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final block = LiturgyBlock(
      id: widget.block?.id ?? const Uuid().v4(),
      tipo: _selectedType,
      descripcion: _descripcionController.text.isEmpty
          ? null
          : _descripcionController.text,
      responsables: responsables,
      comentarios: _comentariosController.text.isEmpty
          ? null
          : _comentariosController.text,
      duracionMinutos: int.parse(_duracionController.text),
      orden: widget.block?.orden ?? 0,
      canciones: _canciones,
    );

    Navigator.pop(context, block);
  }
}

/// Diálogo para agregar una canción
class _SongDialog extends StatefulWidget {
  const _SongDialog();

  @override
  State<_SongDialog> createState() => _SongDialogState();
}

class _SongDialogState extends State<_SongDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _autorController = TextEditingController();
  String? _selectedTono;
  
  // Lista de notas en nomenclatura americana
  static const List<String> _notasAmericanas = [
    'C', 'C#', 'Db', 'D', 'D#', 'Eb', 'E', 'F', 
    'F#', 'Gb', 'G', 'G#', 'Ab', 'A', 'A#', 'Bb', 'B',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _autorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    
    // Calcular altura disponible restando el teclado
    final availableHeight = screenHeight - keyboardHeight;
    final maxDialogHeight = isLandscape 
        ? availableHeight * 0.6  // 60% de altura disponible en horizontal
        : availableHeight * 0.7; // 70% de altura disponible en vertical
    
    return AlertDialog(
      title: const Text('Nueva canción'),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxDialogHeight,
          minWidth: 300,
          maxWidth: 400,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLandscape ? 8.0 : 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.music_note),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El nombre es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _autorController,
                    decoration: const InputDecoration(
                      labelText: 'Autor (opcional)',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedTono,
                    decoration: const InputDecoration(
                      labelText: 'Tono (opcional)',
                      hintText: 'Selecciona el tono',
                      prefixIcon: Icon(Icons.music_note),
                    ),
                    items: _notasAmericanas
                        .map((nota) => DropdownMenuItem(
                              value: nota,
                              child: Text(nota),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedTono = value);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final song = Song(
                id: const Uuid().v4(),
                nombre: _nombreController.text,
                autor: _autorController.text.isEmpty
                    ? null
                    : _autorController.text,
                tono: _selectedTono,
              );
              Navigator.pop(context, song);
            }
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
