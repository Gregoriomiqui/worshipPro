# Guía de Componentes - WorshipPro

## Índice
- [Screens (Pantallas)](#screens-pantallas)
- [Widgets Comunes](#widgets-comunes)
- [Widgets de Lista](#widgets-de-lista)
- [Widgets de Formulario](#widgets-de-formulario)
- [Widgets Responsive](#widgets-responsive)
- [Diálogos y Overlays](#diálogos-y-overlays)
- [Guía de Estilo](#guía-de-estilo)

---

## Screens (Pantallas)

### LiturgyListScreen

Pantalla principal que muestra lista de todas las liturgias.

**Ubicación:** `lib/screens/liturgy_list_screen.dart`

**Características:**
- Grid/lista responsive según dispositivo
- Búsqueda y filtrado (próximamente)
- FAB para crear nueva liturgia
- LanguageSelector en AppBar
- Estados: loading, error, empty, data

**Layout:**
```
Mobile:              Tablet/Desktop:
┌─────────────┐     ┌──────────────────┐
│ AppBar      │     │ AppBar           │
├─────────────┤     ├──────────────────┤
│ ListView    │     │ GridView (2-3)   │
│ - Item 1    │     │ [Card] [Card]    │
│ - Item 2    │     │ [Card] [Card]    │
│ - Item 3    │     │ [Card] [Card]    │
└─────────────┘     └──────────────────┘
```

**Uso:**
```dart
// Navegación
Navigator.of(context).pushNamed('/');
```

**Provider dependencies:**
- `LiturgyProvider` - Lista de liturgias
- `LanguageProvider` - Traducciones

---

### LiturgyEditorScreen

Pantalla de edición de liturgia con gestión de bloques.

**Ubicación:** `lib/screens/liturgy_editor_screen.dart`

**Características:**
- Formulario de liturgia (título, fecha, descripción)
- Lista de bloques con CRUD completo
- Dual-panel (tablet/desktop) o tabs (móvil)
- Validación de formularios
- Guardado con notificaciones

**Layout Mobile:**
```
┌─────────────────┐
│ AppBar          │
├─────────────────┤
│ TabBar          │
│ [Datos] [Bloques]│
├─────────────────┤
│                 │
│  Tab Content    │
│                 │
│                 │
└─────────────────┘
```

**Layout Tablet/Desktop:**
```
┌────────────────────────────────────┐
│ AppBar                             │
├──────────────┬─────────────────────┤
│  Formulario  │   Lista Bloques     │
│  [Título]    │   - Bloque 1        │
│  [Fecha]     │   - Bloque 2        │
│  [Desc]      │   + Agregar         │
│              │                     │
│  [Guardar]   │                     │
└──────────────┴─────────────────────┘
```

**Parámetros:**
```dart
LiturgyEditorScreen({
  String? liturgyId,    // null = crear nueva
})
```

**Uso:**
```dart
// Crear nueva
Navigator.of(context).pushNamed(
  '/liturgy-editor',
);

// Editar existente
Navigator.of(context).pushNamed(
  '/liturgy-editor',
  arguments: liturgy.id,
);
```

**Provider dependencies:**
- `LiturgyProvider` - CRUD liturgias
- `BlockProvider` - CRUD bloques

---

### PresentationModeScreen

Modo de presentación fullscreen para proyectar liturgia.

**Ubicación:** `lib/screens/presentation_mode_screen.dart`

**Características:**
- Vista fullscreen sin decoraciones
- Navegación entre bloques (flechas o swipe)
- Muestra información del bloque actual
- Lista de canciones si es bloque de adoración
- Indicador de progreso (bloque X de Y)
- Botón salir en esquina

**Layout:**
```
┌────────────────────────────────────┐
│                              [X]   │
│                                    │
│         Tipo de Bloque             │
│                                    │
│         Descripción                │
│                                    │
│    👥 Responsables                 │
│    🕐 Duración: 20 min             │
│                                    │
│    🎵 Canciones:                   │
│       1. Canción 1 (G)             │
│       2. Canción 2 (C)             │
│                                    │
│                                    │
│ [<]         3 de 8          [>]    │
└────────────────────────────────────┘
```

**Parámetros:**
```dart
PresentationModeScreen({
  required String liturgyId,
  int initialBlockIndex = 0,
})
```

**Uso:**
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => PresentationModeScreen(
      liturgyId: liturgy.id,
      initialBlockIndex: 0,
    ),
  ),
);
```

---

## Widgets Comunes

### LoadingWidget

Indicador de carga centrado con mensaje opcional.

**Ubicación:** `lib/widgets/common/loading_widget.dart`

**Props:**
```dart
LoadingWidget({
  Key? key,
  String? message,    // Mensaje opcional debajo del spinner
})
```

**Uso:**
```dart
if (provider.isLoading) {
  return LoadingWidget(
    message: l10n.loading,
  );
}
```

**Apariencia:**
```
    ⟳ [spinner]
    
   Cargando...
```

---

### EmptyStateWidget

Widget para mostrar estado vacío con ícono y acción opcional.

**Ubicación:** `lib/widgets/common/empty_state_widget.dart`

**Props:**
```dart
EmptyStateWidget({
  Key? key,
  required IconData icon,
  required String title,
  required String subtitle,
  Widget? action,          // Botón o acción opcional
})
```

**Uso:**
```dart
if (liturgies.isEmpty) {
  return EmptyStateWidget(
    icon: Icons.event_note,
    title: l10n.noLiturgies,
    subtitle: l10n.noLiturgiesDesc,
    action: ElevatedButton.icon(
      icon: Icon(Icons.add),
      label: Text(l10n.createLiturgy),
      onPressed: () => _createLiturgy(),
    ),
  );
}
```

**Apariencia:**
```
      📋
      
  Sin Liturgias
  
  Aún no has creado
  ninguna liturgia
  
  [+ Crear Liturgia]
```

---

### ErrorStateWidget

Widget para mostrar errores con opción de reintentar.

**Ubicación:** `lib/widgets/common/error_state_widget.dart`

**Props:**
```dart
ErrorStateWidget({
  Key? key,
  required String message,
  VoidCallback? onRetry,    // Callback para reintentar
})
```

**Uso:**
```dart
if (provider.error != null) {
  return ErrorStateWidget(
    message: provider.error!,
    onRetry: () => provider.loadLiturgies(),
  );
}
```

**Apariencia:**
```
      ⚠️
      
   Error al cargar
   
  [Reintentar]
```

---

### LanguageSelector

Selector de idioma en forma de PopupMenu.

**Ubicación:** `lib/widgets/language_selector.dart`

**Props:** Ninguno (usa Provider internamente)

**Uso:**
```dart
AppBar(
  title: Text('WorshipPro'),
  actions: [
    LanguageSelector(),
  ],
)
```

**Comportamiento:**
- Muestra ícono de idioma 🌐
- Al tocar abre menú con opciones ES/EN
- Marca con ✓ el idioma actual
- Cambia idioma al seleccionar
- Persiste selección en SharedPreferences

---

## Widgets de Lista

### LiturgyCard

Card que muestra resumen de una liturgia.

**Ubicación:** Dentro de `liturgy_list_screen.dart`

**Props:**
```dart
LiturgyCard({
  required Liturgy liturgy,
  required VoidCallback onTap,
  required VoidCallback onDelete,
})
```

**Características:**
- Responsive padding y fuentes
- Título destacado
- Fecha formateada según locale
- Duración total
- Número de bloques
- Descripción truncada
- Botón eliminar en esquina
- Tap abre editor

**Apariencia:**
```
┌─────────────────────────┐
│ Culto Dominical      [X]│
│                         │
│ 📅 15 de Marzo, 2024    │
│ ⏱️  2h 30min            │
│ 📋 8 bloques            │
│                         │
│ Culto de celebración... │
└─────────────────────────┘
```

---

### BlockCard

Card que muestra un bloque litúrgico en lista.

**Ubicación:** Dentro de `liturgy_editor_screen.dart`

**Props:**
```dart
BlockCard({
  required LiturgyBlock block,
  required VoidCallback onTap,
  required VoidCallback onDelete,
})
```

**Características:**
- Ícono según tipo de bloque
- Color distintivo por tipo
- Título/descripción
- Responsables
- Duración
- Indicador de canciones (si tiene)
- Botón editar y eliminar

**Apariencia:**
```
┌─────────────────────────────┐
│ 🎵 Adoración y Alabanza     │
│    Tiempo de adoración      │
│                             │
│ 👥 Juan, María              │
│ ⏱️  20 minutos              │
│ 🎵 3 canciones              │
│                             │
│              [Editar] [🗑️]  │
└─────────────────────────────┘
```

---

### SongListItem

Item de lista para una canción.

**Ubicación:** Dentro de block dialogs

**Props:**
```dart
SongListItem({
  required Song song,
  required int index,
  required VoidCallback onDelete,
})
```

**Apariencia:**
```
1. Cuán Grande es Él (G)  [🗑️]
```

---

## Widgets de Formulario

### DatePickerField

Campo de formulario para seleccionar fecha.

**Ubicación:** Dentro de `liturgy_editor_screen.dart`

**Uso:**
```dart
InkWell(
  onTap: () => _selectDate(),
  child: InputDecorator(
    decoration: InputDecoration(
      labelText: l10n.date,
      prefixIcon: Icon(Icons.calendar_today),
    ),
    child: Text(
      DateFormat('dd/MM/yyyy').format(_fecha),
    ),
  ),
)
```

---

### ResponsiveTextField

TextFormField con padding adaptable.

**Ejemplo de uso:**
```dart
ResponsiveBuilder(
  builder: (context, info) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: l10n.title,
        contentPadding: EdgeInsets.all(info.paddingValue * 0.75),
      ),
      style: TextStyle(fontSize: info.fontSizeFor(16)),
    );
  },
)
```

---

## Widgets Responsive

### ResponsiveBuilder

Widget que proporciona `ResponsiveInfo` a sus hijos.

**Ubicación:** `lib/utils/responsive_utils.dart`

**Props:**
```dart
ResponsiveBuilder({
  required Widget Function(BuildContext, ResponsiveInfo) builder,
})
```

**Uso:**
```dart
ResponsiveBuilder(
  builder: (context, info) {
    return Container(
      padding: EdgeInsets.all(info.paddingValue),
      child: Column(
        children: [
          Text(
            'Responsive',
            style: TextStyle(fontSize: info.fontSizeFor(20)),
          ),
          SizedBox(height: info.adaptiveSpacing),
          if (info.isDesktop) DesktopWidget(),
          if (info.isTablet) TabletWidget(),
          if (info.isMobile) MobileWidget(),
        ],
      ),
    );
  },
)
```

---

### ResponsiveLayout

Widget para layouts completamente diferentes por dispositivo.

**Props:**
```dart
ResponsiveLayout({
  required Widget mobile,
  Widget? tablet,       // Usa mobile si null
  Widget? desktop,      // Usa tablet o mobile si null
})
```

**Uso:**
```dart
ResponsiveLayout(
  mobile: ListView(children: [...]),
  tablet: GridView.count(crossAxisCount: 2, children: [...]),
  desktop: GridView.count(crossAxisCount: 3, children: [...]),
)
```

---

## Diálogos y Overlays

### ConfirmDialog

Diálogo de confirmación reutilizable.

**Uso:**
```dart
final confirmed = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(l10n.confirmDelete),
    content: Text(l10n.confirmDeleteLiturgy),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text(l10n.cancel),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        style: TextButton.styleFrom(
          foregroundColor: Colors.red,
        ),
        child: Text(l10n.delete),
      ),
    ],
  ),
);

if (confirmed == true) {
  // Ejecutar acción
}
```

---

### BlockFormDialog

Diálogo complejo para agregar/editar bloques.

**Ubicación:** Dentro de `liturgy_editor_screen.dart`

**Características:**
- Formulario multi-campo
- Dropdown para tipo de bloque
- TextField para descripción (opcional)
- Chips para responsables
- Slider para duración
- TextField para comentarios
- Sección de canciones (si es adoración)
- Validación

**Layout:**
```
┌───────────────────────────┐
│ Agregar Bloque       [X]  │
├───────────────────────────┤
│                           │
│ Tipo: [Adoración ▼]       │
│                           │
│ Descripción:              │
│ [___________________]     │
│                           │
│ Responsables:             │
│ [Juan] [x] [María] [x]    │
│ [+ Agregar]               │
│                           │
│ Duración: 20 min          │
│ ├─────●──────────┤         │
│                           │
│ 🎵 Canciones:             │
│ 1. Canción 1 (G)    [🗑️]  │
│ 2. Canción 2 (C)    [🗑️]  │
│ [+ Agregar Canción]       │
│                           │
│     [Cancelar] [Guardar]  │
└───────────────────────────┘
```

---

### SongFormDialog

Diálogo simple para agregar canciones.

**Campos:**
- Nombre (requerido)
- Tono (opcional)

**Layout:**
```
┌───────────────────────────┐
│ Agregar Canción      [X]  │
├───────────────────────────┤
│                           │
│ Nombre:                   │
│ [___________________]     │
│                           │
│ Tono:                     │
│ [___________________]     │
│                           │
│     [Cancelar] [Agregar]  │
└───────────────────────────┘
```

---

### SnackBar Notifications

Notificaciones tipo toast en parte inferior.

**Tipos:**

**Success:**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(l10n.liturgyCreatedSuccess),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 2),
  ),
);
```

**Error:**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(l10n.errorSavingLiturgy),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 3),
  ),
);
```

---

## Guía de Estilo

### Colores

```dart
// Primary
Color(0xFF6200EE)  // Púrpura principal
Color(0xFF3700B3)  // Púrpura oscuro

// Accent
Color(0xFF03DAC6)  // Turquesa

// Estados
Colors.green       // Éxito
Colors.red         // Error
Colors.orange      // Advertencia
Colors.blue        // Info

// Superficies
Colors.white       // Fondo principal
Colors.grey[100]   // Fondo alternativo
Colors.grey[300]   // Bordes
```

### Tipografía

```dart
// Títulos
headline1: 96.0, light
headline2: 60.0, light
headline3: 48.0, regular
headline4: 34.0, regular
headline5: 24.0, regular
headline6: 20.0, medium

// Cuerpo
bodyText1: 16.0, regular
bodyText2: 14.0, regular

// Botones
button: 14.0, medium, uppercase
```

### Espaciado

```dart
// Móvil
Padding: 16.0
Spacing: 12.0
BorderRadius: 8.0

// Tablet
Padding: 24.0
Spacing: 16.0
BorderRadius: 12.0

// Desktop
Padding: 32.0
Spacing: 20.0
BorderRadius: 16.0
```

### Iconos

```dart
// Tamaños
Small: 16.0
Medium: 24.0
Large: 32.0
XLarge: 48.0

// Por contexto
AppBar: 24.0
ListTile: 24.0
FAB: 24.0
EmptyState: 64.0
```

### Elevaciones

```dart
Card: 2.0
Dialog: 24.0
AppBar: 4.0
FAB: 6.0
BottomSheet: 8.0
```

### Animaciones

```dart
// Duraciones
Fast: 200ms
Normal: 300ms
Slow: 500ms

// Curvas
Entrada: Curves.easeOut
Salida: Curves.easeIn
Énfasis: Curves.easeInOut
```

---

## Convenciones de Código

### Nombres de Archivos
```
snake_case.dart
liturgy_list_screen.dart
responsive_utils.dart
```

### Nombres de Clases
```dart
PascalCase
LiturgyListScreen
ResponsiveBuilder
```

### Nombres de Variables
```dart
camelCase
liturgyProvider
isLoading
userName
```

### Nombres de Constantes
```dart
camelCase (final/const)
static const double mobilePadding = 16.0;
```

### Organización de Imports
```dart
// 1. Dart/Flutter
import 'dart:async';
import 'package:flutter/material.dart';

// 2. Packages
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// 3. App
import '../models/liturgy.dart';
import '../providers/liturgy_provider.dart';
import '../utils/responsive_utils.dart';
```

### Comentarios
```dart
// Comentarios simples en español

/// Documentación de clase/método
/// con descripción detallada

// TODO: Tareas pendientes
// FIXME: Problemas a corregir
// NOTE: Notas importantes
```

---

## Testing

### Widget Tests

```dart
testWidgets('LoadingWidget shows message', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: LoadingWidget(message: 'Cargando...'),
    ),
  );
  
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  expect(find.text('Cargando...'), findsOneWidget);
});
```

### Integration Tests

```dart
testWidgets('Create liturgy flow', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Tap FAB
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
  
  // Fill form
  await tester.enterText(find.byKey(Key('titulo')), 'Test');
  await tester.tap(find.text('Guardar'));
  await tester.pumpAndSettle();
  
  // Verify
  expect(find.text('Test'), findsOneWidget);
});
```

---

## Accesibilidad

### Semantic Labels
```dart
Semantics(
  label: 'Eliminar liturgia',
  child: IconButton(
    icon: Icon(Icons.delete),
    onPressed: () => _delete(),
  ),
)
```

### Contrast Ratios
- Texto normal: 4.5:1 mínimo
- Texto grande: 3:1 mínimo
- Iconos: 3:1 mínimo

### Focus Order
- Lógico de arriba a abajo, izquierda a derecha
- Skip links para navegación rápida

### Screen Readers
- Todas las imágenes con descripción
- Botones con labels descriptivos
- Estados de carga anunciados
