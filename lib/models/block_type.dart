import 'package:flutter/material.dart';
import 'package:worshippro/l10n/app_localizations.dart';

/// Tipos de bloques disponibles para la liturgia
enum BlockType {
  adoracionAlabanza('worship'),
  oracion('prayer'),
  lecturaBiblica('bibleReading'),
  reflexion('sermon'),
  accionGracias('blessing'),
  ofrendas('offering'),
  anuncios('announcement'),
  saludos('welcome'),
  despedida('blessing'),
  otros('other');

  const BlockType(this.translationKey);
  
  final String translationKey;
  
  /// Obtiene el nombre traducido del tipo de bloque
  String getDisplayName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n.translate(translationKey);
  }
  
  /// Obtiene el nombre en español (para compatibilidad)
  String get displayName {
    switch (this) {
      case BlockType.adoracionAlabanza:
        return 'Adoración y alabanza';
      case BlockType.oracion:
        return 'Oración';
      case BlockType.lecturaBiblica:
        return 'Lectura Bíblica';
      case BlockType.reflexion:
        return 'Reflexión';
      case BlockType.accionGracias:
        return 'Acción de gracias';
      case BlockType.ofrendas:
        return 'Ofrendas';
      case BlockType.anuncios:
        return 'Anuncios';
      case BlockType.saludos:
        return 'Saludos';
      case BlockType.despedida:
        return 'Despedida';
      case BlockType.otros:
        return 'Otros';
    }
  }
}

