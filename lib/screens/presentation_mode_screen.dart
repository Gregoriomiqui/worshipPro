import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:worshippro/models/block_type.dart';
import 'package:worshippro/models/liturgy.dart';
import 'package:worshippro/models/liturgy_block.dart';

/// Pantalla de modo presentación para el culto
class PresentationModeScreen extends StatefulWidget {
  final Liturgy liturgy;

  const PresentationModeScreen({super.key, required this.liturgy});

  @override
  State<PresentationModeScreen> createState() => _PresentationModeScreenState();
}

class _PresentationModeScreenState extends State<PresentationModeScreen> {
  int _currentBlockIndex = 0;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    // Ocultar la barra de estado en modo presentación
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    // Restaurar la barra de estado al salir
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.liturgy.bloques.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Modo presentación'),
        ),
        body: const Center(
          child: Text('No hay bloques en esta liturgia'),
        ),
      );
    }

    final currentBlock = widget.liturgy.bloques[_currentBlockIndex];
    final nextBlock = _currentBlockIndex < widget.liturgy.bloques.length - 1
        ? widget.liturgy.bloques[_currentBlockIndex + 1]
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF1F2937), // Fondo oscuro
      body: GestureDetector(
        onTap: () {
          setState(() => _showControls = !_showControls);
        },
        child: Stack(
          children: [
            // Contenido principal
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con título de la liturgia
                    _buildHeader(),
                    
                    const SizedBox(height: 48),
                    
                    // Bloque actual (principal)
                    Expanded(
                      flex: 3,
                      child: _buildCurrentBlock(currentBlock),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Bloque siguiente (vista previa)
                    if (nextBlock != null)
                      Expanded(
                        flex: 1,
                        child: _buildNextBlock(nextBlock),
                      ),
                  ],
                ),
              ),
            ),
            
            // Controles de navegación
            if (_showControls) _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_currentBlockIndex + 1} / ${widget.liturgy.bloques.length}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.liturgy.duracionTotalFormateada,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.liturgy.titulo,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 28,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentBlock(LiturgyBlock block) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF6366F1),
          width: 4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiqueta de tipo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getBlockIcon(block.tipo),
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Text(
                  block.tipo.displayName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Descripción
          Text(
            block.descripcion,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          
          const Spacer(),
          
          // Información adicional
          Row(
            children: [
              // Duración
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.orange,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${block.duracionMinutos} minutos',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 24),
              
              // Responsables
              if (block.responsables.isNotEmpty)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person,
                          color: Colors.white70,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            block.responsables.join(', '),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 24,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          
          // Canciones (si es adoración)
          if (block.isAdoracion && block.canciones.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CANCIONES',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...block.canciones.map((song) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.music_note,
                              color: Colors.white70,
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                song.nombre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                ),
                              ),
                            ),
                            if (song.tono != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  song.tono!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
          
          // Comentarios
          if (block.comentarios != null && block.comentarios!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.yellow, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.yellow,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      block.comentarios!,
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNextBlock(LiturgyBlock block) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SIGUIENTE',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _getBlockIcon(block.tipo),
                color: Colors.white54,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${block.tipo.displayName}: ${block.descripcion}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 22,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${block.duracionMinutos} min',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 48,
      left: 48,
      right: 48,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botón anterior
            IconButton(
              onPressed: _currentBlockIndex > 0 ? _previousBlock : null,
              icon: const Icon(Icons.arrow_back),
              iconSize: 48,
              color: _currentBlockIndex > 0 ? Colors.white : Colors.white38,
              tooltip: 'Anterior',
            ),
            
            const SizedBox(width: 48),
            
            // Botón salir
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text('Salir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(width: 48),
            
            // Botón siguiente
            IconButton(
              onPressed: _currentBlockIndex < widget.liturgy.bloques.length - 1
                  ? _nextBlock
                  : null,
              icon: const Icon(Icons.arrow_forward),
              iconSize: 48,
              color: _currentBlockIndex < widget.liturgy.bloques.length - 1
                  ? Colors.white
                  : Colors.white38,
              tooltip: 'Siguiente',
            ),
          ],
        ),
      ),
    );
  }

  void _previousBlock() {
    if (_currentBlockIndex > 0) {
      setState(() => _currentBlockIndex--);
    }
  }

  void _nextBlock() {
    if (_currentBlockIndex < widget.liturgy.bloques.length - 1) {
      setState(() => _currentBlockIndex++);
    }
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
