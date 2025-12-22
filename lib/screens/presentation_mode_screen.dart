import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:worshippro/models/block_type.dart';
import 'package:worshippro/models/liturgy.dart';
import 'package:worshippro/models/liturgy_block.dart';
import 'package:worshippro/utils/responsive_utils.dart';

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
          child: Text('No hay bloques en este culto'),
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
            ResponsiveBuilder(
              builder: (context, info) {
                return SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(info.paddingValue * 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header con título de la liturgia
                        _buildHeader(info),
                        
                        SizedBox(height: info.adaptiveSpacing * 3),
                        
                        // Bloque actual (principal)
                        Expanded(
                          flex: info.isMobile ? 4 : 3,
                          child: _buildCurrentBlock(currentBlock, info),
                        ),
                        
                        SizedBox(height: info.adaptiveSpacing * 2),
                        
                        // Bloque siguiente (vista previa) - ocultar en móvil portrait
                        if (nextBlock != null && (!info.isMobile || info.isLandscape))
                          Expanded(
                            flex: 1,
                            child: _buildNextBlock(nextBlock, info),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            // Controles de navegación
            if (_showControls)
              ResponsiveBuilder(
                builder: (context, info) => _buildControls(info),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ResponsiveInfo info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: info.fontSizeFor(20),
                vertical: info.fontSizeFor(10),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_currentBlockIndex + 1} / ${widget.liturgy.bloques.length}',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: info.fontSizeFor(24),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: info.fontSizeFor(20),
                vertical: info.fontSizeFor(10),
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.orange,
                    size: info.iconSizeFor(28),
                  ),
                  SizedBox(width: info.adaptiveSpacing),
                  Text(
                    widget.liturgy.duracionTotalFormateada,
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: info.fontSizeFor(24),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: info.adaptiveSpacing),
        Text(
          widget.liturgy.titulo,
          style: TextStyle(
            color: Colors.white70,
            fontSize: info.fontSizeFor(28),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentBlock(LiturgyBlock block, ResponsiveInfo info) {
    return Container(
      padding: EdgeInsets.all(info.paddingValue * 2),
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(info.isMobile ? 16 : 24),
        border: Border.all(
          color: const Color(0xFF6366F1),
          width: info.isMobile ? 2 : 4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiqueta de tipo
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: info.paddingValue,
              vertical: info.paddingValue * 0.5,
            ),
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
                  size: info.iconSizeFor(32),
                ),
                SizedBox(width: info.adaptiveSpacing),
                Text(
                  block.tipo.displayName.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: info.fontSizeFor(24),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: info.adaptiveSpacing * 2),
          
          // Descripción o tipo de bloque
          Text(
            block.descripcion ?? block.tipo.displayName,
            style: TextStyle(
              color: Colors.white,
              fontSize: info.fontSizeFor(48),
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            maxLines: info.isMobile ? 3 : null,
            overflow: info.isMobile ? TextOverflow.ellipsis : null,
          ),
          
          const Spacer(),
          
          // Información adicional
          Wrap(
            spacing: info.adaptiveSpacing,
            runSpacing: info.adaptiveSpacing,
            children: [
              // Duración
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: info.paddingValue,
                  vertical: info.paddingValue * 0.66,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.orange,
                      size: info.iconSizeFor(32),
                    ),
                    SizedBox(width: info.adaptiveSpacing * 0.5),
                    Text(
                      '${block.duracionMinutos} min',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: info.fontSizeFor(28),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Responsables
              if (block.responsables.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: info.paddingValue,
                    vertical: info.paddingValue * 0.66,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.white70,
                        size: info.iconSizeFor(32),
                      ),
                      SizedBox(width: info.adaptiveSpacing * 0.5),
                      Flexible(
                        child: Text(
                          block.responsables.join(', '),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: info.fontSizeFor(24),
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          // Canciones (si es adoración)
          if (block.isAdoracion && block.canciones.isNotEmpty) ...[
            SizedBox(height: info.adaptiveSpacing),
            Container(
              padding: EdgeInsets.all(info.paddingValue),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CANCIONES',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: info.fontSizeFor(20),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: info.adaptiveSpacing),
                  ...block.canciones.map((song) => Padding(
                        padding: EdgeInsets.only(bottom: info.adaptiveSpacing * 0.5),
                        child: Row(
                          children: [
                            Icon(
                              Icons.music_note,
                              color: Colors.white70,
                              size: info.iconSizeFor(28),
                            ),
                            SizedBox(width: info.adaptiveSpacing),
                            Expanded(
                              child: Text(
                                song.nombre,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: info.fontSizeFor(28),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (song.tono != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: info.paddingValue * 0.66,
                                  vertical: info.paddingValue * 0.33,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  song.tono!,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: info.fontSizeFor(20),
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
            SizedBox(height: info.adaptiveSpacing),
            Container(
              padding: EdgeInsets.all(info.paddingValue),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.yellow, width: 2),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.yellow,
                    size: info.iconSizeFor(32),
                  ),
                  SizedBox(width: info.adaptiveSpacing),
                  Expanded(
                    child: Text(
                      block.comentarios!,
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: info.fontSizeFor(24),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: info.isMobile ? 2 : null,
                      overflow: info.isMobile ? TextOverflow.ellipsis : null,
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

  Widget _buildNextBlock(LiturgyBlock block, ResponsiveInfo info) {
    return Container(
      padding: EdgeInsets.all(info.paddingValue),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SIGUIENTE',
            style: TextStyle(
              color: Colors.white38,
              fontSize: info.fontSizeFor(18),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: info.adaptiveSpacing * 0.5),
          Row(
            children: [
              Icon(
                _getBlockIcon(block.tipo),
                color: Colors.white54,
                size: info.iconSizeFor(24),
              ),
              SizedBox(width: info.adaptiveSpacing * 0.5),
              Expanded(
                child: Text(
                  block.descripcion != null && block.descripcion!.isNotEmpty
                      ? '${block.tipo.displayName}: ${block.descripcion}'
                      : block.tipo.displayName,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: info.fontSizeFor(22),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${block.duracionMinutos} min',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: info.fontSizeFor(20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls(ResponsiveInfo info) {
    return Positioned(
      bottom: info.paddingValue * 2,
      left: info.paddingValue * 2,
      right: info.paddingValue * 2,
      child: Container(
        padding: EdgeInsets.all(info.paddingValue),
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
              iconSize: info.iconSizeFor(48),
              color: _currentBlockIndex > 0 ? Colors.white : Colors.white38,
              tooltip: 'Anterior',
            ),
            
            SizedBox(width: info.adaptiveSpacing * 2),
            
            // Botón salir
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close, size: info.iconSizeFor(24)),
              label: Text(
                'Salir',
                style: TextStyle(fontSize: info.fontSizeFor(18)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: info.paddingValue * 1.33,
                  vertical: info.paddingValue * 0.66,
                ),
                textStyle: TextStyle(
                  fontSize: info.fontSizeFor(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            SizedBox(width: info.adaptiveSpacing * 2),
            
            // Botón siguiente
            IconButton(
              onPressed: _currentBlockIndex < widget.liturgy.bloques.length - 1
                  ? _nextBlock
                  : null,
              icon: const Icon(Icons.arrow_forward),
              iconSize: info.iconSizeFor(48),
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
