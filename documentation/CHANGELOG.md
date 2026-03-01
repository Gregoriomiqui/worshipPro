# Registro de Cambios - WorshipPro

Todos los cambios notables en este proyecto serán documentados en este archivo.

---

## [1.2.0] - 2025-12-21

### 🎯 Agregado
- **Mejoras en eliminación de cultos**
  - Botón de eliminar siempre visible en todas las tarjetas de cultos
  - Menú contextual al hacer long-press en tarjetas (editar/eliminar)
  - Deslizar para eliminar (swipe) en móviles con confirmación
  - Indicador de carga durante la eliminación
  - Feedback visual mejorado con SnackBars personalizados

### 🔧 Modificado
- **Terminología actualizada**
  - Todas las referencias de "liturgia" cambiadas a "culto" en español
  - UI completamente en español usa "culto" en lugar de "liturgia"
  - Nombres de código en inglés permanecen igual (buenas prácticas)

- **Cambio de iglesia seleccionada**
  - Nueva acción **Cambiar Iglesia** desde configuración de organización
  - Permite volver al listado de iglesias para seleccionar otra
  - No elimina membresía ni modifica miembros

---

## [1.1.0] - 2025

### 🔐 Agregado — Autenticación
- **Firebase Auth con múltiples proveedores**
  - Login con email/contraseña
  - Login con Google Sign-In
  - Registro de nuevos usuarios con nombre, email y contraseña
  - Recuperación de contraseña por email
  - `AuthService` (405 líneas) para toda la lógica de autenticación
  - `AuthProvider` para gestión de estado de sesión
  - `AuthGuard` en `main.dart` que redirige según estado de autenticación
  - 3 pantallas de auth: `LoginScreen`, `RegisterScreen`, `PasswordRecoveryScreen`

### 🏢 Agregado — Sistema Multi-tenant
- **Organizaciones e invitaciones**
  - Modelo `Organization` con nombre, descripción, createdBy
  - Modelo `Member` con roles: `admin` | `member`
  - Modelo `Invitation` con estados: `pending` | `accepted` | `rejected`
  - Modelo `User` con `organizationIds` y `activeOrganizationId`
  - `OrganizationService` (435 líneas) para CRUD de organizaciones, miembros e invitaciones
  - `OrganizationProvider` para gestión de estado de organizaciones
  - 4 pantallas: `OrganizationSelectorScreen`, `CreateOrganizationScreen`, `OrganizationSettingsScreen`, `InvitationsScreen`
  - Creador de organización es Admin automáticamente
  - Admins pueden invitar/eliminar miembros y gestionar configuración

### 🔥 Agregado — Firestore Multi-tenant
- **Estructura de datos reorganizada**
  - Liturgias ahora son subcollection de `organizations/{orgId}/liturgias/`
  - Nueva colección `users/` para datos de usuario autenticado
  - Nueva colección `organizations/` con subcollection `members/`
  - Nueva colección `invitations/` para sistema de invitaciones
  - `LiturgyService` actualizado (402 líneas) con rutas multi-tenant
  - `LiturgyProvider.setContext()` para cambiar organización activa
  - `BlockProvider.setOrganizationId()` para rutas multi-tenant

### 🔒 Agregado — Reglas de Seguridad
- **Firestore Security Rules completas**
  - Autenticación obligatoria para todas las operaciones
  - Aislamiento por organización: usuario solo accede a sus organizaciones
  - Helpers `isMemberOf()` y `isAdminOf()` para validación de roles
  - Solo admins pueden gestionar miembros
  - Usuarios solo pueden leer/escribir sus propios datos
  - Archivo `firestore.rules` desplegable con `firebase deploy --only firestore:rules`

### 📄 Agregado — Exportación a PDF
- **PdfService** (391 líneas) para generación de documentos PDF
  - Generar PDF formateado con toda la información de la liturgia
  - Compartir PDF directamente desde la app (`share_plus`)
  - Guardar PDF en almacenamiento local (`flutter_file_dialog`)
  - Gestión de permisos de almacenamiento (`permission_handler`)

### 🌍 Agregado — Internacionalización
- **Sistema de multi-idioma (ES/EN)**
  - Implementación completa de localización con 70+ traducciones
  - `AppLocalizations` personalizado con soporte para español e inglés
  - `LanguageProvider` para gestión de estado de idioma
  - `LanguageSelector` widget en AppBar para cambio rápido
  - Persistencia de preferencia de idioma con SharedPreferences
  - Todas las pantallas y diálogos traducidos

### 🔧 Modificado
- **Campo `hora` en liturgias**
  - Nuevo campo `hora` (TimeOfDay) en modelo `Liturgy`
  - Selector de hora en el editor de liturgias

- **10 tipos de bloques** (antes 9)
  - Agregado `lecturaBiblica` como tipo de bloque independiente

- **Campo `autor` en canciones**
  - Modelo `Song` ahora incluye campo `autor` (opcional)

- **Descripción opcional en bloques**
  - Campo `descripcion` en `LiturgyBlock` ahora es `String?` (nullable)

- **Actualización inmediata de listas**
  - Fix: Bloques aparecen inmediatamente después de agregar
  - Refrescado después de agregar, editar o eliminar bloques

- **Mejoras en manejo de errores**
  - Try-catch en todas las operaciones de Firebase
  - Mensajes de error descriptivos para el usuario

### 📦 Dependencias agregadas
- `firebase_auth: ^5.3.3` — Autenticación
- `google_sign_in: ^6.2.2` — Google Sign-In
- `pdf: ^3.11.2` — Generación de PDF
- `flutter_file_dialog: ^3.0.2` — Guardar archivos
- `share_plus: ^10.1.4` — Compartir archivos
- `path_provider: ^2.1.5` — Rutas de almacenamiento
- `permission_handler: ^11.3.1` — Permisos
- `shared_preferences: ^2.3.3` — Persistencia local

### 📝 Documentación
- `ARCHITECTURE.md` — Arquitectura técnica detallada
- `API_REFERENCE.md` — Referencia completa de modelos, providers y servicios
- `TROUBLESHOOTING.md` — Guía de solución de problemas
- `FIRESTORE_STRUCTURE_V1.1.md` — Estructura multi-tenant de Firestore
- `CHANGELOG.md` — Este archivo
- Reorganización de documentación en carpeta `/documentation`

---

## [1.0.0] - 2024

### 🎉 Lanzamiento Inicial

#### ✨ Características Principales
- **Gestión de Liturgias**
  - Crear, editar y eliminar liturgias/cultos
  - Campos: título, fecha, descripción
  - Vista de lista con ordenamiento por fecha
  - Búsqueda y filtrado
  - Cálculo automático de duración total

- **Bloques Litúrgicos**
  - Sistema de bloques para estructurar cultos
  - 9 tipos de bloques iniciales
  - Campos configurables: descripción, responsables, comentarios, duración
  - Reordenamiento de bloques
  - Eliminación con confirmación

- **Gestión de Canciones**
  - Agregar canciones a bloques de adoración
  - Nombre y tono de cada canción
  - Lista ordenada dentro de cada bloque
  - Eliminación individual de canciones

- **Modo Presentación**
  - Vista fullscreen para proyección
  - Navegación entre bloques con flechas
  - Información clara y visible
  - Muestra canciones del bloque actual

- **Diseño Responsive**
  - Soporte completo para móvil, tablet y desktop
  - Breakpoints: <600px (móvil), 600-1200px (tablet), >1200px (desktop)
  - Layouts adaptables según tamaño de pantalla
  - Dual-panel en tablet/desktop, tabs en móvil

- **Integración Firebase**
  - Cloud Firestore como base de datos
  - Estructura con subcollections (liturgias > bloques > canciones)
  - Sincronización en tiempo real

#### 🏗️ Arquitectura
- Patrón MVVM (Model-View-ViewModel)
- State Management con Provider
- Servicios separados para lógica de negocio
- Modelos de datos inmutables con copyWith

#### 📱 Plataformas Soportadas
- Android, iOS, Web, macOS, Windows, Linux

#### 🔧 Tecnologías
- Flutter SDK >=3.10.4
- Dart con null safety
- Firebase Core & Firestore
- Provider para estado
- UUID para generación de IDs
- Intl para formateo de fechas

---

## Convenciones del Formato

### Tipos de Cambios
- **🎉 Agregado** — Nuevas características
- **🔧 Modificado** — Cambios en funcionalidad existente
- **🐛 Corregido** — Corrección de bugs
- **🗑️ Eliminado** — Características removidas
- **🔒 Seguridad** — Actualizaciones de seguridad
- **📦 Dependencias** — Cambios en paquetes
- **🏗️ Arquitectura** — Cambios estructurales
- **📝 Documentación** — Solo cambios en docs

### Formato de Versiones
Este proyecto sigue [Semantic Versioning](https://semver.org/):
- **MAJOR** (1.x.x): Cambios incompatibles en la API
- **MINOR** (x.1.x): Nueva funcionalidad compatible
- **PATCH** (x.x.1): Correcciones compatibles de bugs

---

## Planeado para Próximas Versiones

### [1.3.0] — Próximo
- [ ] Modo offline con sincronización
- [ ] Búsqueda y filtros avanzados
- [ ] Temas claro/oscuro
- [ ] Más idiomas (PT, FR, etc.)

### [2.0.0] — Futuro
- [ ] Biblioteca de canciones compartida
- [ ] Plantillas de liturgias predefinidas
- [ ] Calendario de liturgias
- [ ] Estadísticas y reportes
- [ ] Modo colaborativo en tiempo real

---

## Migración entre Versiones

### De 1.0.0 a 1.1.0

#### Base de Datos
Cambios significativos en la estructura de Firestore:
- Liturgias migradas de `liturgias/` (root) a `organizations/{orgId}/liturgias/`
- Nuevas colecciones: `users/`, `organizations/`, `invitations/`
- Ver `FIRESTORE_STRUCTURE_V1.1.md` para estructura completa

#### Dependencias
Agregar a `pubspec.yaml`:
```yaml
dependencies:
  firebase_auth: ^5.3.3
  google_sign_in: ^6.2.2
  pdf: ^3.11.2
  flutter_file_dialog: ^3.0.2
  share_plus: ^10.1.4
  path_provider: ^2.1.5
  permission_handler: ^11.3.1
  shared_preferences: ^2.3.3
```

Ejecutar:
```bash
flutter pub get
```

#### Configuración
1. Habilitar Firebase Auth en Firebase Console
2. Configurar proveedores Email/Password y Google
3. Registrar SHA-1 para Google Sign-In en Android
4. Desplegar nuevas reglas de Firestore: `firebase deploy --only firestore:rules`

---

**Última actualización:** 2025
**Versión actual:** 1.2.0
