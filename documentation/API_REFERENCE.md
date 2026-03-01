# Guía de API - WorshipPro v1.1

## Índice
- [Modelos](#modelos)
- [Providers](#providers)
- [Services](#services)
- [Widgets](#widgets)
- [Utilidades](#utilidades)
- [Localización](#localización)

---

## Modelos

### User

Modelo de usuario autenticado.

```dart
class User {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final List<String> organizationIds;
  final String? activeOrganizationId;
  final List<String> authProviders; // ["password", "google.com"]
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

#### Métodos
- `toMap()` → `Map<String, dynamic>`
- `factory User.fromMap(Map<String, dynamic> map, String id)`
- `copyWith({...})`

---

### Organization

Modelo de organización (iglesia).

```dart
class Organization {
  final String id;
  final String nombre;
  final String? descripcion;
  final String createdBy; // userId del creador
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

#### Métodos
- `toMap()` → `Map<String, dynamic>`
- `factory Organization.fromMap(Map<String, dynamic> map, String id)`
- `copyWith({...})`

---

### Member

Modelo de miembro de una organización.

```dart
enum MemberRole { admin, member }

class Member {
  final String id;
  final String email;
  final String displayName;
  final MemberRole role;
  final DateTime joinedAt;
  final String? invitedBy;
}
```

#### Métodos
- `toMap()` → `Map<String, dynamic>`
- `factory Member.fromMap(Map<String, dynamic> map, String id)`
- `copyWith({...})`

---

### Invitation

Modelo de invitación a una organización.

```dart
enum InvitationStatus { pending, accepted, rejected }

class Invitation {
  final String id;
  final String organizationId;
  final String organizationName;
  final String email;
  final MemberRole role;
  final String invitedBy;
  final String invitedByName;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
}
```

#### Métodos
- `toMap()` → `Map<String, dynamic>`
- `factory Invitation.fromMap(Map<String, dynamic> map, String id)`
- `copyWith({...})`

---

### Liturgy

Modelo principal que representa una liturgia/culto.

```dart
class Liturgy {
  final String id;
  final String titulo;
  final DateTime fecha;
  final String? hora;         // Nuevo en v1.1
  final String? descripcion;
  final List<LiturgyBlock> bloques;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

#### Computed Properties
- `duracionTotalMinutos` → `int` — Suma de duración de todos los bloques
- `duracionTotalFormateada` → `String` — "2h 30min" o "45 min"

#### Métodos
- `toMap()` → `Map<String, dynamic>`
- `factory Liturgy.fromMap(Map<String, dynamic> map, String id)`
- `copyWith({...})`

---

### LiturgyBlock

Representa un bloque dentro de una liturgia.

```dart
class LiturgyBlock {
  final String id;
  final BlockType tipo;
  final String? descripcion;      // OPCIONAL
  final List<String> responsables;
  final String? comentarios;
  final int duracionMinutos;
  final int orden;
  final List<Song> canciones;
}
```

#### Computed Properties
- `isAdoracion` → `bool` — `true` si tipo es `BlockType.adoracionAlabanza`

#### Métodos
- `toMap()` → `Map<String, dynamic>`
- `factory LiturgyBlock.fromMap(Map<String, dynamic> map, String id)`
- `copyWith({...})`

---

### BlockType

Enum que define los **10 tipos** de bloques disponibles.

```dart
enum BlockType {
  adoracionAlabanza,
  oracion,
  lecturaBiblica,    // Nuevo en v1.1
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
- `translationKey` → `String` — Clave para traducción ('worship', 'prayer', 'bibleReading', etc.)
- `displayName` → `String` — Nombre en español (retrocompatibilidad)

#### Métodos
- `getDisplayName(BuildContext context)` → `String` — Nombre traducido según idioma activo

---

### Song

Representa una canción dentro de un bloque de adoración.

```dart
class Song {
  final String id;
  final String nombre;
  final String? autor;
  final String? tono;
}
```

#### Métodos
- `toMap()` → `Map<String, dynamic>`
- `factory Song.fromMap(Map<String, dynamic> map, String id)`
- `copyWith({...})`

---

## Providers

### AuthProvider

Gestiona el estado de autenticación.

```dart
class AuthProvider extends ChangeNotifier
```

#### Propiedades Públicas
```dart
AuthStatus get status              // initial, authenticated, unauthenticated, loading
User? get currentUser              // Usuario actual autenticado
String? get error                  // Mensaje de error
bool get isAuthenticated           // true si status == authenticated
```

#### Métodos
```dart
Future<void> registerWithEmail(String email, String password, String displayName)
Future<void> loginWithEmail(String email, String password)
Future<void> loginWithGoogle()
Future<void> logout()
Future<void> resetPassword(String email)
void clearError()
```

**Nota:** Escucha automáticamente `FirebaseAuth.authStateChanges()` y recarga datos del usuario desde Firestore.

---

### OrganizationProvider

Gestiona organizaciones, miembros e invitaciones.

```dart
class OrganizationProvider extends ChangeNotifier
```

#### Propiedades Públicas
```dart
List<Organization> get organizations     // Organizaciones del usuario
Organization? get activeOrganization     // Organización activa
String? get activeOrganizationId         // ID de la org activa
List<Member> get members                 // Miembros de la org activa
List<Invitation> get invitations         // Invitaciones pendientes del usuario
bool get isLoading
String? get error
```

#### Métodos
```dart
Future<void> loadUserOrganizations(String userId)
Future<void> setActiveOrganization(String orgId)
Future<String?> createOrganization(String nombre, String? descripcion)
Future<void> loadMembers()
Future<void> inviteMember(String email, MemberRole role)
Future<void> removeMember(String memberId)
Future<void> updateMemberRole(String memberId, MemberRole newRole)
Future<void> loadInvitations(String email)
Future<void> acceptInvitation(Invitation invitation)
Future<void> rejectInvitation(String invitationId)
```

---

### LiturgyProvider

Gestiona el estado de las liturgias. **Requiere contexto de organización.**

```dart
class LiturgyProvider extends ChangeNotifier
```

#### Propiedades Públicas
```dart
List<Liturgy> get liturgies           // Lista de todas las liturgias
Liturgy? get currentLiturgy           // Liturgia actual en edición
bool get isLoading
String? get error
```

#### Métodos
```dart
void setContext(String organizationId, String userId)  // ⚠️ Llamar antes de usar
Future<void> initLiturgiesListener()
Future<void> loadLiturgy(String liturgyId)
Future<String?> createLiturgy(Liturgy liturgy)
Future<bool> updateLiturgy(Liturgy liturgy)
Future<bool> deleteLiturgy(String liturgyId)
void clearError()
```

---

### BlockProvider

Gestiona operaciones CRUD de bloques y canciones. **Requiere contexto de organización.**

```dart
class BlockProvider extends ChangeNotifier
```

#### Métodos
```dart
void setOrganizationId(String organizationId)  // ⚠️ Llamar antes de usar
Future<String?> createBlock(String liturgyId, LiturgyBlock block)
Future<bool> updateBlock(String liturgyId, LiturgyBlock block)
Future<bool> deleteBlock(String liturgyId, String blockId)
Future<String?> createSong(String liturgyId, String blockId, Song song)
Future<bool> deleteSong(String liturgyId, String blockId, String songId)
```

---

### LanguageProvider

Gestiona el idioma de la aplicación.

```dart
class LanguageProvider extends ChangeNotifier
```

#### Propiedades Públicas
```dart
Locale get locale                     // Locale actual (es/en)
bool get isSpanish
bool get isEnglish
```

#### Métodos
```dart
Future<void> setLocale(Locale locale)
Future<void> setLanguage(String languageCode)
Future<void> toggleLanguage()
```

---

## Services

### AuthService

Servicio de autenticación con Firebase Auth.

```dart
class AuthService
```

#### Métodos
```dart
// Registro y Login
Future<UserCredential> registerWithEmail(String email, String password, String displayName)
Future<UserCredential> loginWithEmail(String email, String password)
Future<UserCredential> signInWithGoogle()
Future<void> linkGoogleAccount()
Future<void> sendPasswordResetEmail(String email)
Future<void> signOut()

// Gestión de usuario en Firestore
Future<void> createUserDocument(FirebaseUser user, {String? displayName})
Future<User?> getUserFromFirestore(String uid)
Future<void> updateUserActiveOrganization(String uid, String orgId)
```

**Excepciones:** Lanza `AuthException` con códigos específicos (email-already-in-use, wrong-password, etc.)

---

### OrganizationService

Servicio de gestión de organizaciones con Firestore.

```dart
class OrganizationService
```

#### Métodos - Organizaciones
```dart
Future<String> createOrganization(String nombre, String? descripcion, String userId, String userEmail, String userDisplayName)
Future<Organization?> getOrganization(String orgId)
Future<List<Organization>> getUserOrganizations(String userId)
Future<void> updateOrganization(String orgId, {String? nombre, String? descripcion})
Future<void> deleteOrganization(String orgId)
```

#### Métodos - Miembros
```dart
Future<List<Member>> getMembers(String orgId)
Future<int> getMembersCount(String orgId)
Future<bool> isUserAdmin(String orgId, String userId)
Future<void> addMember(String orgId, String userId, String email, String displayName, MemberRole role)
Future<void> removeMember(String orgId, String userId)
Future<void> updateMemberRole(String orgId, String userId, MemberRole newRole)
```

#### Métodos - Invitaciones
```dart
Future<String> createInvitation(String orgId, String orgName, String email, MemberRole role, String invitedBy, String invitedByName)
Future<List<Invitation>> getPendingInvitations(String email)
Future<void> acceptInvitation(Invitation invitation, String userId, String displayName)
Future<void> rejectInvitation(String invitationId)
```

---

### LiturgyService

Servicio multi-tenant para liturgias. **Todos los métodos requieren `organizationId`.**

Path base: `organizations/{orgId}/liturgias/`

```dart
class LiturgyService
```

#### Métodos - Liturgias
```dart
Stream<List<Liturgy>> streamLiturgies(String organizationId)
Future<Liturgy?> getLiturgyById(String organizationId, String liturgyId)
Future<String> createLiturgy(String organizationId, Liturgy liturgy)
Future<void> updateLiturgy(String organizationId, Liturgy liturgy)
Future<void> deleteLiturgy(String organizationId, String liturgyId)
Future<String> duplicateLiturgy(String organizationId, String liturgyId)
```

#### Métodos - Bloques
```dart
Future<List<LiturgyBlock>> getBlocks(String organizationId, String liturgyId)
Future<String> createBlock(String organizationId, String liturgyId, LiturgyBlock block)
Future<void> updateBlock(String organizationId, String liturgyId, LiturgyBlock block)
Future<void> deleteBlock(String organizationId, String liturgyId, String blockId)
```

#### Métodos - Canciones
```dart
Future<List<Song>> getSongs(String organizationId, String liturgyId, String blockId)
Future<String> createSong(String organizationId, String liturgyId, String blockId, Song song)
Future<void> deleteSong(String organizationId, String liturgyId, String blockId, String songId)
```

---

### PdfService

Servicio de generación y exportación de PDF.

```dart
class PdfService
```

#### Métodos
```dart
Future<Uint8List> generateLiturgyPdf(Liturgy liturgy)
Future<void> sharePdf(Liturgy liturgy)
Future<void> savePdf(Liturgy liturgy)
```

**Características del PDF generado:**
- Formato A4
- Header con título, fecha, hora y descripción
- Cards de bloques con tipo, duración, responsables y comentarios
- Lista de canciones con autor y tono para bloques de adoración
- Footer con información de la app

---

## Widgets

### Common Widgets

#### LoadingWidget
```dart
class LoadingWidget extends StatelessWidget {
  final String? message;
}
```

#### EmptyStateWidget
```dart
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
}
```

#### ErrorStateWidget
```dart
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
}
```

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

### LanguageSelector
```dart
class LanguageSelector extends StatelessWidget
```
PopupMenu para cambiar idioma (ES/EN) con indicador visual del idioma actual.

---

## Utilidades

### ResponsiveUtils

#### Breakpoints
```dart
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context);
  static bool isTablet(BuildContext context);
  static bool isDesktop(BuildContext context);
}
```

#### ResponsiveInfo
```dart
class ResponsiveInfo {
  DeviceType get deviceType;
  bool get isMobile / isTablet / isDesktop;
  bool get isPortrait / isLandscape;
  double get width / height;

  T valueByDevice<T>({required T mobile, T? tablet, T? desktop});
  EdgeInsets get adaptivePadding;
  double get paddingValue;       // 16/24/32
  double get adaptiveSpacing;    // 12/16/20
  double fontSizeFor(double baseSize);  // 0.9x/1x/1.1x
  double iconSizeFor(double baseSize);  // 0.85x/1x/1.15x
}
```

#### ResponsiveBuilder
```dart
ResponsiveBuilder(
  builder: (context, info) {
    return Container(
      padding: EdgeInsets.all(info.paddingValue),
      child: Text('Text', style: TextStyle(fontSize: info.fontSizeFor(16))),
    );
  },
)
```

#### ResponsiveLayout
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

  // 70+ getters disponibles
  String get appTitle;
  String get loading;
  // ...
}
```

### Uso
```dart
final l10n = AppLocalizations.of(context);
Text(l10n.appTitle);
```

### Categorías de traducciones
- **General:** appTitle, loading, error, cancel, delete, save, edit, add, search, settings, language
- **Auth:** login, register, email, password, forgotPassword, loginWithGoogle
- **Organizaciones:** organization, createOrganization, members, invitations, admin, member
- **Liturgias:** liturgiesList, noLiturgies, createLiturgy, blocks, minutes, newLiturgy, editLiturgy
- **Bloques:** blockType, description, duration, responsible, comments, addBlock, noBlocks
- **Tipos (10):** welcome, worship, prayer, bibleReading, sermon, offering, communion, announcement, blessing, other
- **Canciones:** songName, key, songs, noSongs, addSong
- **Presentación:** presentationMode, next, previous, exit
- **Diálogos:** confirmDelete, confirmDeleteLiturgy, confirmDeleteBlock, confirmDeleteSong
- **Errores:** errorLoadingLiturgies, errorSavingLiturgy, fillRequiredFields

---

## Ejemplos de Uso

### Autenticación
```dart
// Registro
await context.read<AuthProvider>().registerWithEmail(email, password, displayName);

// Login con Google
await context.read<AuthProvider>().loginWithGoogle();

// Logout
await context.read<AuthProvider>().logout();
```

### Organizaciones
```dart
// Crear organización
final orgId = await context.read<OrganizationProvider>()
    .createOrganization('Mi Iglesia', 'Descripción opcional');

// Invitar miembro
await context.read<OrganizationProvider>()
    .inviteMember('email@ejemplo.com', MemberRole.member);
```

### Liturgias (requiere contexto de org)
```dart
// Crear liturgia
final liturgy = Liturgy(
  id: const Uuid().v4(),
  titulo: 'Culto Dominical',
  fecha: DateTime.now(),
  hora: '10:00',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
final liturgyId = await context.read<LiturgyProvider>().createLiturgy(liturgy);
```

### Bloques (requiere contexto de org)
```dart
final block = LiturgyBlock(
  id: const Uuid().v4(),
  tipo: BlockType.adoracionAlabanza,
  descripcion: 'Tiempo de alabanza',
  responsables: ['Juan', 'María'],
  duracionMinutos: 20,
  orden: 0,
);
await context.read<BlockProvider>().createBlock(liturgyId, block);
```

### Exportar a PDF
```dart
// Compartir
await PdfService().sharePdf(liturgy);

// Guardar
await PdfService().savePdf(liturgy);
```

### Escuchar Cambios
```dart
Consumer<AuthProvider>(
  builder: (context, auth, child) {
    if (auth.status == AuthStatus.unauthenticated) {
      return LoginScreen();
    }
    return LiturgyListScreen();
  },
)
```
