# Guía de API - WorshipPro

## Índice
- [Modelos](#modelos)
- [Providers](#providers)
- [Services](#services)
- [Widgets](#widgets)
- [Utilidades](#utilidades)

---

## Modelos

### Liturgy

Modelo principal que representa una liturgia/culto.

```dart
class Liturgy {
  final String id;
  final String titulo;
  final DateTime fecha;
  final String? descripcion;
  final List<LiturgyBlock> bloques;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

#### Constructores

**Constructor principal**
```dart
Liturgy({
  required String id,
  required String titulo,
  required DateTime fecha,
  String? descripcion,
  List<LiturgyBlock> bloques = const [],
  required DateTime createdAt,
  required DateTime updatedAt,
})
```

**Factory fromMap**
```dart
factory Liturgy.fromMap(Map<String, dynamic> map, String id)
```
Convierte datos de Firestore a objeto Liturgy.

#### Métodos

**toMap()**
```dart
Map<String, dynamic> toMap()
```
Convierte Liturgy a formato para Firestore.

**copyWith()**
```dart
Liturgy copyWith({
  String? id,
  String? titulo,
  DateTime? fecha,
  String? descripcion,
  List<LiturgyBlock>? bloques,
  DateTime? createdAt,
  DateTime? updatedAt,
})
```
Crea copia con valores actualizados.

#### Computed Properties

**duracionTotalMinutos**
```dart
int get duracionTotalMinutos
```
Suma total de duración de todos los bloques.

**duracionTotalFormateada**
```dart
String get duracionTotalFormateada
```
Devuelve duración formateada: "2h 30min" o "45 min".

---

### LiturgyBlock

Representa un bloque dentro de una liturgia.

```dart
class LiturgyBlock {
  final String id;
  final BlockType tipo;
  final String? descripcion;      // OPCIONAL desde v1.1
  final List<String> responsables;
  final String? comentarios;
  final int duracionMinutos;
  final int orden;
  final List<Song> canciones;
}
```

#### Constructores

**Constructor principal**
```dart
LiturgyBlock({
  required String id,
  required BlockType tipo,
  String? descripcion,           // OPCIONAL
  required List<String> responsables,
  String? comentarios,
  required int duracionMinutos,
  required int orden,
  List<Song> canciones = const [],
})
```

**Factory fromMap**
```dart
factory LiturgyBlock.fromMap(Map<String, dynamic> map, String id)
```

#### Métodos

**toMap()**
```dart
Map<String, dynamic> toMap()
```

**copyWith()**
```dart
LiturgyBlock copyWith({
  String? id,
  BlockType? tipo,
  String? descripcion,
  List<String>? responsables,
  String? comentarios,
  int? duracionMinutos,
  int? orden,
  List<Song>? canciones,
})
```

#### Computed Properties

**isAdoracion**
```dart
bool get isAdoracion
```
Devuelve `true` si el tipo es `BlockType.adoracionAlabanza`.

---

### BlockType

Enum que define los tipos de bloques disponibles.

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

#### Propiedades

**translationKey**
```dart
String get translationKey
```
Clave para traducción ('worship', 'prayer', etc.).

**displayName**
```dart
String get displayName
```
Nombre en español (retrocompatibilidad).

#### Métodos

**getDisplayName(BuildContext context)**
```dart
String getDisplayName(BuildContext context)
```
Devuelve nombre traducido según idioma activo.

---

### Song

Representa una canción dentro de un bloque de adoración.

```dart
class Song {
  final String id;
  final String nombre;
  final String? tono;
}
```

#### Constructores

**Constructor principal**
```dart
Song({
  required String id,
  required String nombre,
  String? tono,
})
```

**Factory fromMap**
```dart
factory Song.fromMap(Map<String, dynamic> map, String id)
```

#### Métodos

**toMap()**
```dart
Map<String, dynamic> toMap()
```

**copyWith()**
```dart
Song copyWith({
  String? id,
  String? nombre,
  String? tono,
})
```

---

## Providers

### LiturgyProvider

Gestiona el estado de las liturgias.

```dart
class LiturgyProvider extends ChangeNotifier
```

#### Propiedades Públicas

```dart
List<Liturgy> get liturgies           // Lista de todas las liturgias
Liturgy? get currentLiturgy           // Liturgia actual en edición
bool get isLoading                    // Estado de carga
String? get error                     // Mensaje de error actual
```

#### Métodos Públicos

**initLiturgiesListener()**
```dart
Future<void> initLiturgiesListener()
```
Inicia listener en tiempo real para obtener todas las liturgias.
- Actualiza automáticamente con cambios en Firebase
- Llama a `notifyListeners()` en cada cambio

**loadLiturgy(String liturgyId)**
```dart
Future<void> loadLiturgy(String liturgyId)
```
Carga una liturgia específica con todos sus bloques.
- Parámetros:
  - `liturgyId`: ID de la liturgia a cargar
- Actualiza `currentLiturgy`
- Llama a `notifyListeners()`

**createLiturgy(Liturgy liturgy)**
```dart
Future<String?> createLiturgy(Liturgy liturgy)
```
Crea una nueva liturgia en Firebase.
- Parámetros:
  - `liturgy`: Objeto Liturgy a crear
- Retorna: ID de la liturgia creada o `null` si falla

**updateLiturgy(Liturgy liturgy)**
```dart
Future<bool> updateLiturgy(Liturgy liturgy)
```
Actualiza una liturgia existente.
- Parámetros:
  - `liturgy`: Liturgia con datos actualizados
- Retorna: `true` si éxito, `false` si falla

**deleteLiturgy(String liturgyId)**
```dart
Future<bool> deleteLiturgy(String liturgyId)
```
Elimina una liturgia y todos sus bloques/canciones.
- Parámetros:
  - `liturgyId`: ID de la liturgia a eliminar
- Retorna: `true` si éxito, `false` si falla

**clearError()**
```dart
void clearError()
```
Limpia el mensaje de error actual.

---

### BlockProvider

Gestiona operaciones CRUD de bloques.

```dart
class BlockProvider extends ChangeNotifier
```

#### Métodos Públicos

**createBlock(String liturgyId, LiturgyBlock block)**
```dart
Future<String?> createBlock(String liturgyId, LiturgyBlock block)
```
Crea un nuevo bloque en una liturgia.
- Parámetros:
  - `liturgyId`: ID de la liturgia padre
  - `block`: Bloque a crear
- Retorna: ID del bloque creado o `null` si falla

**updateBlock(String liturgyId, LiturgyBlock block)**
```dart
Future<bool> updateBlock(String liturgyId, LiturgyBlock block)
```
Actualiza un bloque existente.
- Retorna: `true` si éxito, `false` si falla

**deleteBlock(String liturgyId, String blockId)**
```dart
Future<bool> deleteBlock(String liturgyId, String blockId)
```
Elimina un bloque y todas sus canciones.
- Retorna: `true` si éxito, `false` si falla

**createSong(String liturgyId, String blockId, Song song)**
```dart
Future<String?> createSong(String liturgyId, String blockId, Song song)
```
Crea una canción en un bloque de adoración.
- Retorna: ID de la canción creada o `null` si falla

**deleteSong(String liturgyId, String blockId, String songId)**
```dart
Future<bool> deleteSong(String liturgyId, String blockId, String songId)
```
Elimina una canción específica.
- Retorna: `true` si éxito, `false` si falla

---

### LanguageProvider

Gestiona el idioma de la aplicación.

```dart
class LanguageProvider extends ChangeNotifier
```

#### Propiedades Públicas

```dart
Locale get locale                     // Locale actual (es/en)
bool get isSpanish                    // true si idioma es español
bool get isEnglish                    // true si idioma es inglés
```

#### Métodos Públicos

**setLocale(Locale locale)**
```dart
Future<void> setLocale(Locale locale)
```
Cambia el idioma de la aplicación.
- Guarda en SharedPreferences
- Llama a `notifyListeners()`

**setLanguage(String languageCode)**
```dart
Future<void> setLanguage(String languageCode)
```
Cambia idioma usando código ('es' o 'en').

**toggleLanguage()**
```dart
Future<void> toggleLanguage()
```
Alterna entre español e inglés.

---

## Services

### LiturgyService

Servicio que maneja todas las operaciones con Firebase.

```dart
class LiturgyService
```

#### Métodos - Liturgias

**streamLiturgies()**
```dart
Stream<List<Liturgy>> streamLiturgies()
```
Stream en tiempo real de todas las liturgias ordenadas por fecha.

**getLiturgyById(String liturgyId)**
```dart
Future<Liturgy?> getLiturgyById(String liturgyId)
```
Obtiene una liturgia específica con todos sus bloques.

**createLiturgy(Liturgy liturgy)**
```dart
Future<String> createLiturgy(Liturgy liturgy)
```
Crea nueva liturgia en Firestore.

**updateLiturgy(Liturgy liturgy)**
```dart
Future<void> updateLiturgy(Liturgy liturgy)
```
Actualiza liturgia existente.

**deleteLiturgy(String liturgyId)**
```dart
Future<void> deleteLiturgy(String liturgyId)
```
Elimina liturgia y todos sus datos relacionados.

#### Métodos - Bloques

**getBlocks(String liturgyId)**
```dart
Future<List<LiturgyBlock>> getBlocks(String liturgyId)
```
Obtiene todos los bloques de una liturgia ordenados.

**createBlock(String liturgyId, LiturgyBlock block)**
```dart
Future<String> createBlock(String liturgyId, LiturgyBlock block)
```
Crea nuevo bloque en subcollection.

**updateBlock(String liturgyId, LiturgyBlock block)**
```dart
Future<void> updateBlock(String liturgyId, LiturgyBlock block)
```
Actualiza bloque existente.

**deleteBlock(String liturgyId, String blockId)**
```dart
Future<void> deleteBlock(String liturgyId, String blockId)
```
Elimina bloque y todas sus canciones.

#### Métodos - Canciones

**getSongs(String liturgyId, String blockId)**
```dart
Future<List<Song>> getSongs(String liturgyId, String blockId)
```
Obtiene todas las canciones de un bloque.

**createSong(String liturgyId, String blockId, Song song)**
```dart
Future<String> createSong(String liturgyId, String blockId, Song song)
```
Crea canción en subcollection de bloque.

**deleteSong(String liturgyId, String blockId, String songId)**
```dart
Future<void> deleteSong(String liturgyId, String blockId, String songId)
```
Elimina canción específica.

---

## Widgets

### Common Widgets

#### LoadingWidget
```dart
class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({Key? key, this.message});
}
```
Muestra indicador de carga circular con mensaje opcional.

#### EmptyStateWidget
```dart
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  
  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });
}
```
Muestra estado vacío con ícono, texto y acción opcional.

#### ErrorStateWidget
```dart
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  const ErrorStateWidget({
    Key? key,
    required this.message,
    this.onRetry,
  });
}
```
Muestra error con opción de reintentar.

#### ConfirmDialog
```dart
class ConfirmDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
  })
}
```
Diálogo de confirmación. Retorna `true` si confirma.

### LanguageSelector
```dart
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key});
}
```
PopupMenu para cambiar idioma (ES/EN) con indicador visual.

---

## Utilidades

### ResponsiveUtils

#### Breakpoints
```dart
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1200;
  
  static bool isMobile(BuildContext context);
  static bool isTablet(BuildContext context);
  static bool isDesktop(BuildContext context);
  static bool isPortrait(BuildContext context);
  static bool isLandscape(BuildContext context);
}
```

#### ResponsiveInfo
```dart
class ResponsiveInfo {
  final BuildContext context;
  
  // Propiedades
  DeviceType get deviceType;          // mobile, tablet, desktop
  bool get isMobile;
  bool get isTablet;
  bool get isDesktop;
  bool get isPortrait;
  bool get isLandscape;
  double get width;
  double get height;
  
  // Métodos
  T valueByDevice<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  });
  
  EdgeInsets get adaptivePadding;     // 16/24/32
  double get paddingValue;            // 16.0/24.0/32.0
  double get adaptiveSpacing;         // 12.0/16.0/20.0
  
  double fontSizeFor(double baseSize); // Escala: 0.9x/1x/1.1x
  double iconSizeFor(double baseSize); // Escala: 0.85x/1x/1.15x
}
```

#### ResponsiveBuilder
```dart
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveInfo info) builder;
  
  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  });
}
```

**Uso:**
```dart
ResponsiveBuilder(
  builder: (context, info) {
    return Container(
      padding: EdgeInsets.all(info.paddingValue),
      child: Text(
        'Responsive Text',
        style: TextStyle(fontSize: info.fontSizeFor(16)),
      ),
    );
  },
)
```

#### ResponsiveLayout
```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });
}
```

**Uso:**
```dart
ResponsiveLayout(
  mobile: MobileWidget(),
  tablet: TabletWidget(),
  desktop: DesktopWidget(),
)
```

---

## Localización

### AppLocalizations

```dart
class AppLocalizations {
  final Locale locale;
  
  static AppLocalizations of(BuildContext context);
  String translate(String key);
  
  // Getters (70+ disponibles)
  String get appTitle;
  String get loading;
  String get error;
  String get save;
  String get delete;
  // ... etc
}
```

**Uso:**
```dart
final l10n = AppLocalizations.of(context);
Text(l10n.appTitle);
```

### Traducciones Disponibles

**General:** appTitle, loading, error, cancel, delete, save, edit, add, search, settings, language, spanish, english

**Liturgias:** liturgiesList, noLiturgies, noLiturgiesDesc, createLiturgy, blocks, minutes, newLiturgy, editLiturgy

**Bloques:** blockType, description, duration, responsible, comments, addSong, addBlock, noBlocks

**Tipos:** welcome, worship, prayer, sermon, offering, communion, announcement, blessing, other

**Canciones:** songName, key, songs, noSongs

**Presentación:** presentationMode, next, previous, exit

**Diálogos:** confirmDelete, confirmDeleteLiturgy, confirmDeleteBlock, confirmDeleteSong

**Errores:** errorLoadingLiturgies, errorSavingLiturgy, errorDeletingLiturgy, liturgyCreatedSuccess, liturgyUpdatedSuccess, liturgyDeletedSuccess, fillRequiredFields

---

## Ejemplos de Uso

### Crear una Liturgia
```dart
final liturgy = Liturgy(
  id: const Uuid().v4(),
  titulo: 'Culto Dominical',
  fecha: DateTime.now(),
  descripcion: 'Culto de celebración',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

final liturgyId = await context.read<LiturgyProvider>().createLiturgy(liturgy);
```

### Agregar un Bloque
```dart
final block = LiturgyBlock(
  id: const Uuid().v4(),
  tipo: BlockType.adoracionAlabanza,
  descripcion: 'Tiempo de alabanza', // Opcional
  responsables: ['Juan', 'María'],
  duracionMinutos: 20,
  orden: 0,
);

await context.read<BlockProvider>().createBlock(liturgyId, block);
await context.read<LiturgyProvider>().loadLiturgy(liturgyId); // Refrescar
```

### Escuchar Cambios
```dart
Consumer<LiturgyProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return LoadingWidget();
    }
    
    if (provider.error != null) {
      return ErrorStateWidget(message: provider.error!);
    }
    
    return ListView.builder(
      itemCount: provider.liturgies.length,
      itemBuilder: (context, index) {
        final liturgy = provider.liturgies[index];
        return ListTile(title: Text(liturgy.titulo));
      },
    );
  },
)
```

### Cambiar Idioma
```dart
final languageProvider = context.read<LanguageProvider>();
await languageProvider.setLanguage('en'); // o 'es'
```
