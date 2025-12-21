import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:worshippro/models/block_type.dart';
import 'package:worshippro/models/liturgy.dart';
import 'package:worshippro/models/liturgy_block.dart';
import 'package:worshippro/models/song.dart';
import 'package:worshippro/providers/block_provider.dart';
import 'package:worshippro/providers/liturgy_provider.dart';
import 'package:worshippro/screens/presentation_mode_screen.dart';
import 'package:worshippro/widgets/common_widgets.dart';

/// Pantalla para editar o crear una liturgia
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
  bool _isLoading = false;
  bool _isNewLiturgy = true;

  @override
  void initState() {
    super.initState();
    _isNewLiturgy = widget.liturgyId == null;
    if (!_isNewLiturgy) {
      _loadLiturgy();
    }
  }

  Future<void> _loadLiturgy() async {
    setState(() => _isLoading = true);
    await context.read<LiturgyProvider>().loadLiturgy(widget.liturgyId!);
    
    final liturgy = context.read<LiturgyProvider>().currentLiturgy;
    if (liturgy != null) {
      _tituloController.text = liturgy.titulo;
      _descripcionController.text = liturgy.descripcion ?? '';
      _selectedDate = liturgy.fecha;
    }
    
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNewLiturgy ? 'Nueva liturgia' : 'Editar liturgia'),
        actions: [
          if (!_isNewLiturgy)
            IconButton(
              icon: const Icon(Icons.present_to_all),
              onPressed: _openPresentationMode,
              tooltip: 'Modo presentación',
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveLiturgy,
            tooltip: 'Guardar',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Cargando liturgia...')
          : Consumer<LiturgyProvider>(
              builder: (context, provider, child) {
                if (provider.error != null) {
                  return ErrorStateWidget(
                    message: provider.error!,
                    onRetry: _loadLiturgy,
                  );
                }

                final liturgy = provider.currentLiturgy;
                
                return Row(
                  children: [
                    // Panel izquierdo: Información de la liturgia
                    Expanded(
                      flex: 2,
                      child: _buildInfoPanel(liturgy),
                    ),
                    
                    // Panel derecho: Bloques
                    Expanded(
                      flex: 3,
                      child: _buildBlocksPanel(liturgy),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildInfoPanel(Liturgy? liturgy) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Información del culto',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              
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
              const SizedBox(height: 20),
              
              // Fecha
              InkWell(
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
              const SizedBox(height: 20),
              
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
              const SizedBox(height: 32),
              
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
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Duración total',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        liturgy.duracionTotalFormateada,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
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

  Widget _buildBlocksPanel(Liturgy? liturgy) {
    if (liturgy == null) {
      return const EmptyStateWidget(
        icon: Icons.event_note,
        title: 'Guarda la liturgia',
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
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Text(
                'Bloques del culto',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _addBlock(liturgy.id),
                icon: const Icon(Icons.add),
                label: const Text('Agregar bloque'),
              ),
            ],
          ),
        ),
        
        // Lista de bloques
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
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
    }
  }

  Future<void> _saveLiturgy() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<LiturgyProvider>();
    
    if (_isNewLiturgy) {
      // Crear nueva liturgia
      final liturgy = Liturgy(
        id: const Uuid().v4(),
        titulo: _tituloController.text,
        fecha: _selectedDate,
        descripcion: _descripcionController.text.isEmpty
            ? null
            : _descripcionController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final liturgyId = await provider.createLiturgy(liturgy);
      
      if (liturgyId != null && mounted) {
        setState(() => _isNewLiturgy = false);
        await provider.loadLiturgy(liturgyId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Liturgia creada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } else {
      // Actualizar liturgia existente
      final currentLiturgy = provider.currentLiturgy!;
      final updatedLiturgy = currentLiturgy.copyWith(
        titulo: _tituloController.text,
        fecha: _selectedDate,
        descripcion: _descripcionController.text.isEmpty
            ? null
            : _descripcionController.text,
        updatedAt: DateTime.now(),
      );

      final success = await provider.updateLiturgy(updatedLiturgy);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Liturgia actualizada correctamente'),
            backgroundColor: Colors.green,
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
      final provider = context.read<LiturgyProvider>();
      final currentBlocks = provider.currentLiturgy?.bloques ?? [];
      
      final blockWithOrder = block.copyWith(orden: currentBlocks.length);
      
      final blockId = await context.read<BlockProvider>().createBlock(
            liturgyId,
            blockWithOrder,
          );

      if (blockId != null && mounted) {
        await provider.refreshCurrentLiturgy();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bloque agregado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
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

      if (success && mounted) {
        await context.read<LiturgyProvider>().refreshCurrentLiturgy();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bloque actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteBlock(String liturgyId, String blockId) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Eliminar bloque',
      message: '¿Estás seguro de que deseas eliminar este bloque?',
      confirmText: 'Eliminar',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      final success = await context.read<BlockProvider>().deleteBlock(
            liturgyId,
            blockId,
          );

      if (success && mounted) {
        await context.read<LiturgyProvider>().refreshCurrentLiturgy();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bloque eliminado correctamente'),
              backgroundColor: Colors.green,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icono de tipo
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getBlockIcon(block.tipo),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Tipo y descripción
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          block.tipo.displayName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (block.descripcion.isNotEmpty)
                          Text(
                            block.descripcion,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                      ],
                    ),
                  ),
                  
                  // Duración
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${block.duracionMinutos} min',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  
                  // Botones
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const Icon(Icons.drag_handle),
                ],
              ),
              
              // Responsables
              if (block.responsables.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: block.responsables
                      .map((r) => Chip(
                            label: Text(r),
                            avatar: const Icon(Icons.person, size: 16),
                          ))
                      .toList(),
                ),
              ],
              
              // Canciones (si es adoración)
              if (block.isAdoracion && block.canciones.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...block.canciones.map((song) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.music_note, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            song.nombre,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (song.tono != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '(${song.tono})',
                              style: Theme.of(context).textTheme.bodySmall,
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
  }

  IconData _getBlockIcon(BlockType type) {
    switch (type) {
      case BlockType.adoracionAlabanza:
        return Icons.music_note;
      case BlockType.oracion:
        return Icons.favorite;
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
      _descripcionController.text = widget.block!.descripcion;
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
    return AlertDialog(
      title: Text(widget.block == null ? 'Nuevo bloque' : 'Editar bloque'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tipo
                DropdownButtonFormField<BlockType>(
                  value: _selectedType,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La descripción es requerida';
                    }
                    return null;
                  },
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
                    children: [
                      Text(
                        'Canciones',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _addSong,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar canción'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._canciones.map((song) => ListTile(
                        leading: const Icon(Icons.music_note),
                        title: Text(song.nombre),
                        subtitle: song.tono != null
                            ? Text('Tono: ${song.tono}')
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() => _canciones.remove(song));
                          },
                        ),
                      )),
                ],
              ],
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
          onPressed: _saveBlock,
          child: const Text('Guardar'),
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

    final responsables = _responsablesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final block = LiturgyBlock(
      id: widget.block?.id ?? const Uuid().v4(),
      tipo: _selectedType,
      descripcion: _descripcionController.text,
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
  final _tonoController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _autorController.dispose();
    _tonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva canción'),
      content: Form(
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
            TextFormField(
              controller: _tonoController,
              decoration: const InputDecoration(
                labelText: 'Tono (opcional)',
                hintText: 'Ej: Re, Mi, Fa',
                prefixIcon: Icon(Icons.key),
              ),
            ),
          ],
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
                tono: _tonoController.text.isEmpty
                    ? null
                    : _tonoController.text,
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
