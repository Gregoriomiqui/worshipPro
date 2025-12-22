# Arquitectura de WorshipPro

## Visión General

WorshipPro es una aplicación Flutter que sigue el patrón **MVVM (Model-View-ViewModel)** con **Provider** para gestión de estado. La aplicación está diseñada para ser **responsive** y soporta **múltiples idiomas** (ES/EN).

## Estructura del Proyecto

```
lib/
├── l10n/                    # Localización e internacionalización
│   └── app_localizations.dart
├── models/                  # Modelos de datos
│   ├── block_type.dart
│   ├── liturgy.dart
│   ├── liturgy_block.dart
│   └── song.dart
├── providers/              # Gestión de estado (Provider)
│   ├── block_provider.dart
│   ├── language_provider.dart
│   └── liturgy_provider.dart
├── screens/                # Pantallas de la aplicación
│   ├── liturgy_list_screen.dart
│   ├── liturgy_editor_screen.dart
│   └── presentation_mode_screen.dart
├── services/               # Servicios (Firebase, etc.)
│   └── liturgy_service.dart
├── theme/                  # Tema y estilos
│   └── app_theme.dart
├── utils/                  # Utilidades
│   └── responsive_utils.dart
├── widgets/                # Widgets reutilizables
│   ├── common_widgets.dart
│   └── language_selector.dart
└── main.dart              # Punto de entrada
```

## Capas de la Arquitectura

### 1. Capa de Presentación (View)
**Ubicación:** `lib/screens/` y `lib/widgets/`

- **Pantallas principales:**
  - `LiturgyListScreen`: Lista de liturgias con grid/list adaptativo
  - `LiturgyEditorScreen`: Editor con tabs (móvil) o dual-panel (tablet/desktop)
  - `PresentationModeScreen`: Modo presentación fullscreen

- **Widgets comunes:**
  - `LoadingWidget`: Indicador de carga
  - `EmptyStateWidget`: Estado vacío
  - `ErrorStateWidget`: Manejo de errores
  - `ConfirmDialog`: Diálogos de confirmación
  - `LanguageSelector`: Selector de idioma

### 2. Capa de Lógica de Negocio (ViewModel)
**Ubicación:** `lib/providers/`

#### LiturgyProvider
```dart
class LiturgyProvider extends ChangeNotifier {
  // Estado
  List<Liturgy> _liturgies = [];
  Liturgy? _currentLiturgy;
  bool _isLoading = false;
  String? _error;
  
  // Métodos CRUD
  Future<void> initLiturgiesListener();
  Future<void> loadLiturgy(String liturgyId);
  Future<String?> createLiturgy(Liturgy liturgy);
  Future<bool> updateLiturgy(Liturgy liturgy);
  Future<bool> deleteLiturgy(String liturgyId);
}
```

#### BlockProvider
```dart
class BlockProvider extends ChangeNotifier {
  // Operaciones CRUD para bloques
  Future<String?> createBlock(String liturgyId, LiturgyBlock block);
  Future<bool> updateBlock(String liturgyId, LiturgyBlock block);
  Future<bool> deleteBlock(String liturgyId, String blockId);
}
```

#### LanguageProvider
```dart
class LanguageProvider extends ChangeNotifier {
  Locale _locale;
  
  Future<void> setLocale(Locale locale);
  Future<void> toggleLanguage();
}
```

### 3. Capa de Datos (Model)
**Ubicación:** `lib/models/`

#### Liturgy
```dart
class Liturgy {
  final String id;
  final String titulo;
  final DateTime fecha;
  final String? descripcion;
  final List<LiturgyBlock> bloques;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Computed properties
  int get duracionTotalMinutos;
  String get duracionTotalFormateada;
}
```

#### LiturgyBlock
```dart
class LiturgyBlock {
  final String id;
  final BlockType tipo;
  final String? descripcion;  // OPCIONAL
  final List<String> responsables;
  final String? comentarios;
  final int duracionMinutos;
  final int orden;
  final List<Song> canciones;
  
  bool get isAdoracion;
}
```

#### BlockType (Enum)
```dart
enum BlockType {
  adoracionAlabanza,
  oracion,
  reflexion,
  accionGracias,
  ofrendas,
  anuncios,
  saludos,
  despedida,
  otros
}
```

### 4. Capa de Servicios
**Ubicación:** `lib/services/`

#### LiturgyService
Maneja todas las operaciones con Firebase Firestore:

```dart
class LiturgyService {
  // Liturgias
  Stream<List<Liturgy>> streamLiturgies();
  Future<Liturgy?> getLiturgyById(String liturgyId);
  Future<String> createLiturgy(Liturgy liturgy);
  Future<void> updateLiturgy(Liturgy liturgy);
  Future<void> deleteLiturgy(String liturgyId);
  
  // Bloques
  Future<List<LiturgyBlock>> getBlocks(String liturgyId);
  Future<String> createBlock(String liturgyId, LiturgyBlock block);
  Future<void> updateBlock(String liturgyId, LiturgyBlock block);
  Future<void> deleteBlock(String liturgyId, String blockId);
  
  // Canciones
  Future<List<Song>> getSongs(String liturgyId, String blockId);
  Future<String> createSong(String liturgyId, String blockId, Song song);
  Future<void> deleteSong(String liturgyId, String blockId, String songId);
}
```

## Flujo de Datos

### 1. Lectura de Datos (Read)
```
Firebase → LiturgyService → LiturgyProvider → Screen → UI
```

### 2. Escritura de Datos (Write)
```
UI → Screen → Provider → Service → Firebase → Provider.notifyListeners() → UI
```

### 3. Actualización en Tiempo Real
```
Firebase Stream → Service → Provider.initLiturgiesListener() → notifyListeners() → Consumer → UI
```

## Patrones de Diseño

### 1. **Repository Pattern**
`LiturgyService` actúa como repositorio que abstrae la lógica de acceso a datos.

### 2. **Observer Pattern**
`Provider` + `ChangeNotifier` + `Consumer` para reactividad.

### 3. **Factory Pattern**
Métodos `.fromMap()` en modelos para construir objetos desde Firebase.

### 4. **Builder Pattern**
`ResponsiveBuilder` para construir UIs adaptativas.

### 5. **Dependency Injection**
`MultiProvider` en `main.dart` para inyectar dependencias.

## Sistema Responsive

### Breakpoints
```dart
class Breakpoints {
  static const double mobile = 600;   // < 600px
  static const double tablet = 1200;  // 600-1200px
  static const double desktop = 1200; // > 1200px
}
```

### ResponsiveInfo
Proporciona información del dispositivo y valores adaptativos:
- `deviceType`: mobile, tablet, desktop
- `isLandscape` / `isPortrait`
- `fontSizeFor(double baseSize)`: Escala fuentes
- `iconSizeFor(double baseSize)`: Escala íconos
- `paddingValue`: Padding adaptativo
- `adaptiveSpacing`: Espaciado adaptativo

### Layouts Adaptativos

#### Lista de Liturgias
- **Móvil/Portrait**: ListView vertical
- **Tablet Landscape/Desktop**: GridView (2-3 columnas)

#### Editor de Liturgia
- **Móvil**: Tabs (Información / Bloques)
- **Tablet/Desktop**: Dual-panel (Información | Bloques)

#### Modo Presentación
- **Móvil Portrait**: Oculta "Bloque Siguiente"
- **Landscape/Desktop**: Muestra todo

## Sistema de Localización

### Idiomas Soportados
- Español (es)
- Inglés (en)

### Estructura
```dart
class AppLocalizations {
  final Locale locale;
  
  String translate(String key);
  
  // Getters convenientes
  String get appTitle;
  String get loading;
  // ... más de 70 traducciones
}
```

### Uso
```dart
final l10n = AppLocalizations.of(context);
Text(l10n.appTitle);
```

### Persistencia
El idioma se guarda en `SharedPreferences` y se carga al iniciar.

## Gestión de Estado

### Provider Setup
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => LanguageProvider()),
    ChangeNotifierProvider(create: (_) => LiturgyProvider()),
    ChangeNotifierProvider(create: (_) => BlockProvider()),
  ],
  child: MaterialApp(...)
)
```

### Consumir Estado
```dart
// Leer
final liturgy = context.read<LiturgyProvider>().currentLiturgy;

// Escuchar cambios
Consumer<LiturgyProvider>(
  builder: (context, provider, child) {
    return Text(provider.currentLiturgy?.titulo ?? '');
  },
)
```

## Firebase Structure

```
liturgies/
├── {liturgyId}/
│   ├── titulo: string
│   ├── fecha: timestamp
│   ├── descripcion: string?
│   ├── createdAt: timestamp
│   ├── updatedAt: timestamp
│   └── bloques/ (subcollection)
│       ├── {blockId}/
│       │   ├── tipo: string
│       │   ├── descripcion: string?
│       │   ├── responsables: array<string>
│       │   ├── comentarios: string?
│       │   ├── duracionMinutos: number
│       │   ├── orden: number
│       │   └── canciones/ (subcollection)
│       │       └── {songId}/
│       │           ├── nombre: string
│       │           └── tono: string?
```

## Convenciones de Código

### Nombrado
- **Clases**: PascalCase (ej: `LiturgyProvider`)
- **Archivos**: snake_case (ej: `liturgy_provider.dart`)
- **Variables**: camelCase (ej: `currentLiturgy`)
- **Constantes**: camelCase con const (ej: `const double mobile = 600`)

### Organización de Imports
```dart
// Flutter SDK
import 'package:flutter/material.dart';

// Packages externos
import 'package:provider/provider.dart';

// Imports locales
import 'package:worshippro/models/liturgy.dart';
```

### Widgets Privados
Usar `_` para widgets internos de archivo:
```dart
class _BlockCard extends StatelessWidget { ... }
```

## Manejo de Errores

### En Providers
```dart
try {
  // Operación
  _error = null;
} catch (e) {
  _error = 'Mensaje de error: $e';
} finally {
  notifyListeners();
}
```

### En UI
```dart
if (provider.error != null) {
  return ErrorStateWidget(
    message: provider.error!,
    onRetry: () => provider.retry(),
  );
}
```

## Performance

### Optimizaciones Implementadas
1. **Lazy Loading**: Los bloques se cargan solo cuando se necesitan
2. **Stream Listeners**: Solo para la lista principal, no para edición
3. **Consumer Específicos**: Solo rebuild de widgets necesarios
4. **Const Widgets**: Uso extensivo de `const` para widgets estáticos
5. **Keys**: ListView/GridView con keys para optimizar renders

## Testing Strategy

### Niveles de Testing
1. **Unit Tests**: Modelos y utilidades
2. **Widget Tests**: Widgets individuales
3. **Integration Tests**: Flujos completos

### Ejemplo
```dart
testWidgets('should display liturgy title', (tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('WorshipPro'), findsOneWidget);
});
```

## Seguridad

### Firebase Rules Recomendadas
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /liturgies/{liturgyId} {
      allow read, write: if request.auth != null;
      
      match /bloques/{blockId} {
        allow read, write: if request.auth != null;
        
        match /canciones/{songId} {
          allow read, write: if request.auth != null;
        }
      }
    }
  }
}
```

## Deployment

### Build para Producción
```bash
flutter build apk --release      # Android
flutter build ios --release      # iOS
flutter build web --release      # Web
```

### Configuración Pre-Deploy
1. Configurar Firebase (`firebase_options.dart`)
2. Actualizar versión en `pubspec.yaml`
3. Revisar permisos en manifests
4. Probar en dispositivos físicos
