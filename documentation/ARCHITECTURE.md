# Arquitectura de WorshipPro

## Visión General

WorshipPro es una aplicación Flutter que sigue el patrón **MVVM (Model-View-ViewModel)** con **Provider** para gestión de estado. La aplicación es **multi-tenant**, soporta **autenticación** con Firebase Auth, y es **responsive** con soporte **multiidioma** (ES/EN).

## Estructura del Proyecto

```
lib/
├── l10n/                    # Localización e internacionalización
│   └── app_localizations.dart
├── models/                  # Modelos de datos (8 modelos)
│   ├── user.dart            # Usuario autenticado
│   ├── organization.dart    # Organización (iglesia)
│   ├── member.dart          # Miembro con roles
│   ├── invitation.dart      # Invitación con estados
│   ├── block_type.dart      # 10 tipos de bloques
│   ├── liturgy.dart         # Liturgia con hora
│   ├── liturgy_block.dart   # Bloque de liturgia
│   └── song.dart            # Canción (nombre, autor, tono)
├── providers/               # Gestión de estado (5 providers)
│   ├── auth_provider.dart
│   ├── organization_provider.dart
│   ├── liturgy_provider.dart
│   ├── block_provider.dart
│   └── language_provider.dart
├── screens/                 # Pantallas de la aplicación (10 pantallas)
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── password_recovery_screen.dart
│   ├── organization/
│   │   ├── organization_selector_screen.dart
│   │   ├── create_organization_screen.dart
│   │   ├── organization_settings_screen.dart
│   │   └── invitations_screen.dart
│   ├── liturgy_list_screen.dart
│   ├── liturgy_editor_screen.dart
│   └── presentation_mode_screen.dart
├── services/                # Servicios (4 servicios)
│   ├── auth_service.dart
│   ├── organization_service.dart
│   ├── liturgy_service.dart
│   └── pdf_service.dart
├── theme/                   # Tema y estilos
│   └── app_theme.dart
├── utils/                   # Utilidades
│   └── responsive_utils.dart
├── widgets/                 # Widgets reutilizables
│   ├── common_widgets.dart
│   └── language_selector.dart
└── main.dart                # Punto de entrada
```

## Capas de la Arquitectura

### 1. Capa de Presentación (View)
**Ubicación:** `lib/screens/` y `lib/widgets/`

- **Pantallas de autenticación:**
  - `LoginScreen`: Login con Email/Password y Google Sign-In
  - `RegisterScreen`: Registro con validaciones completas
  - `PasswordRecoveryScreen`: Recuperación de contraseña con confirmación

- **Pantallas de organización:**
  - `OrganizationSelectorScreen`: Selector de iglesia, crear nueva, ver invitaciones
  - `CreateOrganizationScreen`: Formulario de nueva organización
  - `OrganizationSettingsScreen`: Gestión de miembros, roles e invitaciones
  - `InvitationsScreen`: Lista de invitaciones pendientes

- **Pantallas principales:**
  - `LiturgyListScreen`: Lista de liturgias con grid/list adaptativo y nombre de org activa
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

#### AuthProvider
```dart
class AuthProvider extends ChangeNotifier {
  AuthStatus _status; // initial, authenticated, unauthenticated, loading
  User? _currentUser;
  String? _error;

  Future<void> registerWithEmail(String email, String password, String displayName);
  Future<void> loginWithEmail(String email, String password);
  Future<void> loginWithGoogle();
  Future<void> logout();
  Future<void> resetPassword(String email);
}
```

#### OrganizationProvider
```dart
class OrganizationProvider extends ChangeNotifier {
  List<Organization> _organizations;
  Organization? _activeOrganization;
  List<Member> _members;
  List<Invitation> _invitations;

  Future<void> loadUserOrganizations(String userId);
  Future<void> setActiveOrganization(String orgId);
  Future<String?> createOrganization(String nombre, String? descripcion);
  Future<void> inviteMember(String email, MemberRole role);
  Future<void> acceptInvitation(Invitation invitation);
  Future<void> rejectInvitation(String invitationId);
}
```

#### LiturgyProvider
```dart
class LiturgyProvider extends ChangeNotifier {
  void setContext(String organizationId, String userId);

  List<Liturgy> _liturgies;
  Liturgy? _currentLiturgy;
  bool _isLoading;
  String? _error;

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
  void setOrganizationId(String organizationId);

  Future<String?> createBlock(String liturgyId, LiturgyBlock block);
  Future<bool> updateBlock(String liturgyId, LiturgyBlock block);
  Future<bool> deleteBlock(String liturgyId, String blockId);
  Future<String?> createSong(String liturgyId, String blockId, Song song);
  Future<bool> deleteSong(String liturgyId, String blockId, String songId);
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

#### Modelos principales

| Modelo | Campos clave |
|--------|-------------|
| `User` | id, email, displayName, organizationIds, activeOrganizationId, authProviders |
| `Organization` | id, nombre, descripcion, createdBy |
| `Member` | id, email, displayName, role (admin/member), joinedAt |
| `Invitation` | id, organizationId, email, role, status (pending/accepted/rejected), expiresAt |
| `Liturgy` | id, titulo, fecha, hora, descripcion, bloques |
| `LiturgyBlock` | id, tipo, descripcion?, responsables, duracionMinutos, orden, canciones |
| `BlockType` | 10 valores: adoracionAlabanza, oracion, lecturaBiblica, reflexion, accionGracias, ofrendas, anuncios, saludos, despedida, otros |
| `Song` | id, nombre, autor, tono |

### 4. Capa de Servicios
**Ubicación:** `lib/services/`

| Servicio | Responsabilidad |
|----------|----------------|
| `AuthService` | Firebase Auth: email/password, Google Sign-In, account linking, password reset, gestión de docs de usuario |
| `OrganizationService` | CRUD de organizaciones, miembros, invitaciones. Verificación de permisos |
| `LiturgyService` | CRUD multi-tenant: `organizations/{orgId}/liturgias/...`. Streams en tiempo real |
| `PdfService` | Generación de PDF A4, compartir y guardar archivos |

## Flujo de Datos

### 1. Flujo de Autenticación
```
App Start → AuthGuard → AuthProvider.authStateChanges
  → Unauthenticated → LoginScreen
  → Authenticated (sin org) → OrganizationSelectorScreen
  → Authenticated (con org) → _InitialDataLoader → LiturgyListScreen
```

### 2. Lectura de Datos
```
Firebase → Service(orgId) → Provider → Consumer → UI
```

### 3. Escritura de Datos
```
UI → Screen → Provider → Service(orgId) → Firebase → Provider.notifyListeners() → UI
```

### 4. Actualización en Tiempo Real
```
Firebase Stream → Service → Provider.initLiturgiesListener() → notifyListeners() → Consumer → UI
```

## Patrones de Diseño

1. **Repository Pattern** — Servicios abstraen acceso a datos
2. **Observer Pattern** — Provider + ChangeNotifier + Consumer
3. **Factory Pattern** — `.fromMap()` en modelos
4. **Builder Pattern** — `ResponsiveBuilder` para UIs adaptativas
5. **Dependency Injection** — `MultiProvider` en `main.dart`
6. **Guard Pattern** — `AuthGuard` para navegación condicional

## Sistema Responsive

### Breakpoints
```dart
class Breakpoints {
  static const double mobile = 600;   // < 600px
  static const double tablet = 900;   // 600-1200px
  static const double desktop = 1200; // > 1200px
}
```

### Layouts Adaptativos
- **Lista de Liturgias**: ListView (móvil) → GridView 2-3 columnas (tablet/desktop)
- **Editor**: Tabs (móvil) → Dual-panel (tablet/desktop)
- **Presentación**: Compacto (móvil portrait) → Completo (landscape/desktop)

## Gestión de Estado (Provider Setup)

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => OrganizationProvider()),
    ChangeNotifierProvider(create: (_) => LanguageProvider()),
    ChangeNotifierProvider(create: (_) => LiturgyProvider()),
    ChangeNotifierProvider(create: (_) => BlockProvider()),
  ],
  child: MaterialApp(home: AuthGuard()),
)
```

## Firebase Structure (v1.1 Multi-tenant)

```
firestore (root)
├── users/{userId}
│   └── email, displayName, organizationIds, activeOrganizationId, authProviders
├── organizations/{organizationId}
│   ├── nombre, descripcion, createdBy
│   ├── members/{userId} → email, displayName, role
│   └── liturgias/{liturgyId}
│       ├── titulo, fecha, hora, descripcion, createdBy
│       └── bloques/{blockId}
│           ├── tipo, descripcion, responsables, duracionMinutos, orden
│           └── canciones/{songId} → nombre, autor, tono, orden
└── invitations/{invitationId}
    └── organizationId, email, role, status, invitedBy
```

## Seguridad (Firestore Rules)

Las reglas de seguridad implementan:
- **Autenticación obligatoria** para todas las operaciones
- **Aislamiento de organizaciones** con `isMemberOf(orgId)`
- **Control de roles** con `isAdminOf(orgId)` para operaciones admin
- **Acceso a invitaciones** filtrado por email del usuario

Ver `firestore.rules` en la raíz del proyecto para la implementación completa.

## Convenciones de Código

- **Clases**: PascalCase (`LiturgyProvider`)
- **Archivos**: snake_case (`liturgy_provider.dart`)
- **Variables**: camelCase (`currentLiturgy`)
- **Imports**: Flutter SDK → Packages externos → Imports locales
