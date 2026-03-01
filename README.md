# ⛪ WorshipPro

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.10.4+-02569B?style=for-the-badge&logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart)
![License](https://img.shields.io/badge/License-Private-red?style=for-the-badge)

**Aplicación móvil profesional multi-tenant para crear, organizar y presentar liturgias de cultos cristianos**

[Características](#-características) • [Instalación](#-instalación-rápida) • [Documentación](#-documentación) • [Arquitectura](#️-arquitectura)

</div>

---

## 📖 Descripción

**WorshipPro** es una aplicación Flutter diseñada para tablets y dispositivos móviles que permite a líderes de cultos cristianos crear, gestionar y presentar liturgias de forma profesional y eficiente. Cuenta con autenticación (email/contraseña y Google Sign-In), sistema multi-tenant con organizaciones e invitaciones, exportación a PDF, y una interfaz responsive optimizada para tablets.

### 🎯 ¿Para quién es esta aplicación?

- 🎤 **Pastores y líderes de alabanza** que planifican servicios religiosos
- ⛪ **Iglesias cristianas** que buscan digitalizar su planificación litúrgica
- 📱 **Equipos técnicos** que manejan presentaciones durante los cultos
- 👥 **Comités de liturgia** que coordinan múltiples servicios

---

## ✨ Características

### 🔐 Autenticación y Multi-tenant
- ✅ Login con email/contraseña y Google Sign-In
- ✅ Registro de usuarios con validación
- ✅ Recuperación de contraseña por email
- ✅ Sistema de organizaciones (iglesias)
- ✅ Crear y gestionar múltiples organizaciones
- ✅ Roles: **Admin** (gestión completa) y **Miembro** (lectura/escritura liturgias)
- ✅ Sistema de invitaciones por email con estados (pendiente, aceptada, rechazada)
- ✅ Selector de organización activa

### 🎼 Gestión Completa de Liturgias
- ✅ Crear y editar liturgias con información detallada (título, fecha, hora, descripción)
- ✅ Organizar bloques de contenido con drag & drop (reordenamiento intuitivo)
- ✅ Cálculo automático de duración total del servicio
- ✅ Guardado automático en la nube con Firebase Firestore
- ✅ Duplicación de liturgias con sufijo incremental
- ✅ Liturgias aisladas por organización (multi-tenant)

### 🎵 Gestión de Canciones de Adoración
- ✅ Agregar canciones a bloques de adoración y alabanza (obligatorio)
- ✅ Registro de nombre, autor y tono musical (notación americana: C, D#, Eb, etc.)
- ✅ Reordenamiento de canciones dentro de cada bloque
- ✅ Visualización de cantidad de canciones en cada bloque

### 📋 10 Tipos de Bloques Predefinidos
- 🙏 **Adoración y Alabanza** - Con gestión de canciones
- 🤲 **Oración** - Momentos de oración dirigida
- 📖 **Lectura Bíblica** - Lectura de pasajes bíblicos
- 📚 **Reflexión/Sermón** - Mensaje principal
- 🙌 **Acción de Gracias** - Bendiciones y agradecimientos
- 💰 **Ofrendas** - Momento de ofrenda
- 📢 **Anuncios** - Comunicados y avisos
- 👋 **Saludos** - Bienvenida y presentación
- 🚪 **Despedida** - Cierre del servicio
- 📝 **Otros** - Bloques personalizados

### 📄 Exportación a PDF
- ✅ Generación de PDF profesional con diseño formateado
- ✅ Compartir PDF directamente desde la app
- ✅ Guardar PDF en almacenamiento local

### 📱 Interfaz Responsive y Moderna
- 💻 **Diseño tablet-first** optimizado para pantallas grandes
- 📱 **Responsive** adaptable a móviles, tablets y desktop
- 🌓 **Tema moderno** con paleta Indigo/Violeta
- 🎨 **Tipografía grande** y alto contraste para fácil lectura
- 🔄 **Auto-guardado** sin necesidad de botones manuales

### 🌐 Multiidioma
- 🇪🇸 **Español** (idioma principal)
- 🇺🇸 **Inglés** (soporte completo)
- 🔄 **Cambio dinámico** de idioma sin reiniciar la app

### 🎥 Modo Presentación
- 🖥️ **Pantalla completa** optimizada para proyección
- 👁️ **Visualización del bloque actual y siguiente**
- ⏱️ **Información de duración** de cada bloque
- 🎯 **Navegación simple** entre bloques
- 📊 **Contraste alto** para mejor visibilidad

### ☁️ Persistencia en la Nube
- 🔥 **Firebase Firestore** con estructura multi-tenant
- 🔒 **Firebase Auth** para autenticación segura
- 💾 **Sincronización automática** en tiempo real
- 🔐 **Reglas de seguridad** con aislamiento por organización

---

## 🚀 Instalación Rápida

### Requisitos Previos

```bash
# Verificar versión de Flutter
flutter --version
# Debe ser >= 3.10.4

# Verificar versión de Dart
dart --version
# Debe ser >= 3.10.4
```

### Paso 1: Clonar e Instalar

```bash
# Clonar el repositorio
git clone <repository-url>
cd worshippro

# Instalar dependencias
flutter pub get
```

### Paso 2: Configurar Firebase

```bash
# Instalar FlutterFire CLI (solo una vez)
dart pub global activate flutterfire_cli

# Configurar Firebase automáticamente
flutterfire configure
```

#### Configuración adicional requerida:

1. **Firebase Auth**: Habilitar proveedores Email/Password y Google en Firebase Console → Authentication
2. **Firestore**: Crear base de datos y desplegar reglas de seguridad:
   ```bash
   firebase deploy --only firestore:rules
   ```
3. **Google Sign-In (Android)**: Registrar SHA-1 del certificado de debug en Firebase Console:
   ```bash
   cd android && ./gradlew signingReport
   ```
   Copiar el SHA-1 y agregarlo en Firebase Console → Project Settings → Android app → SHA certificate fingerprints. Luego re-descargar `google-services.json`.

### Paso 3: Ejecutar

```bash
# Ejecutar en modo debug
flutter run

# O compilar para release
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
```

---

## 📱 Uso de la Aplicación

### 1. Autenticación
- **Login** con email/contraseña o Google Sign-In
- **Registro** de nuevo usuario con nombre, email y contraseña
- **Recuperar contraseña** por email

### 2. Organizaciones
- **Crear organización** (iglesia) — el creador es Admin automáticamente
- **Seleccionar organización** activa desde el selector
- **Invitar miembros** por email con rol Admin o Miembro
- **Gestionar configuración** de la organización (solo Admins)

### 3. Lista de Liturgias
- **Ver** todas las liturgias de la organización activa
- **Crear** nueva liturgia con el botón flotante (+)
- **Eliminar** deslizando o con icono papelera
- **Duplicar** mediante menú contextual

### 4. Editor de Liturgia
- **Información básica**: Título, fecha, hora y descripción (auto-guardado)
- **Gestión de bloques**: Agregar, editar, reordenar y eliminar bloques
- **Canciones**: Para bloques de adoración, agregar canciones con tono musical
- **Exportar a PDF**: Generar, compartir o guardar PDF del culto

### 5. Modo Presentación
- Click en el icono de presentación desde el editor
- Navega con flechas o gestos
- Muestra bloque actual con información detallada y preview del siguiente

---

## 🏗️ Arquitectura

### Patrón MVVM + Provider

```
┌─────────────────────────────────────────────────┐
│                    View Layer                    │
│         (Screens + Widgets + UI Logic)          │
│  Auth (3) | Organization (4) | Liturgy (3)      │
└───────────────┬─────────────────────────────────┘
                │ notifyListeners()
                ↓
┌─────────────────────────────────────────────────┐
│                ViewModel Layer                   │
│              (State Management)                  │
│  AuthProvider | OrganizationProvider |           │
│  LiturgyProvider | BlockProvider | LanguageP    │
└───────────────┬─────────────────────────────────┘
                │ async calls
                ↓
┌─────────────────────────────────────────────────┐
│                 Service Layer                    │
│              (Business Logic)                    │
│  AuthService | OrganizationService |            │
│  LiturgyService | PdfService                    │
└───────────────┬─────────────────────────────────┘
                │ Firebase SDK
                ↓
┌─────────────────────────────────────────────────┐
│                  Data Layer                      │
│          (Firebase Auth + Firestore)             │
│  users | organizations/{orgId}/liturgias/...     │
└─────────────────────────────────────────────────┘
```

### Estructura del Proyecto

```
lib/
├── main.dart                      # Punto de entrada, AuthGuard, MultiProvider
├── firebase_options.dart          # Configuración de Firebase
│
├── l10n/                          # Internacionalización
│   └── app_localizations.dart     # Sistema de traducciones ES/EN
│
├── models/                        # Modelos de datos (8 modelos)
│   ├── block_type.dart            # Enum: 10 tipos de bloques
│   ├── invitation.dart            # Modelo: Invitación a organización
│   ├── liturgy.dart               # Modelo: Culto (con campo hora)
│   ├── liturgy_block.dart         # Modelo: Bloque de liturgia
│   ├── member.dart                # Modelo: Miembro de organización
│   ├── organization.dart          # Modelo: Organización/Iglesia
│   ├── song.dart                  # Modelo: Canción (nombre, autor, tono)
│   └── user.dart                  # Modelo: Usuario autenticado
│
├── providers/                     # Gestión de estado (5 providers)
│   ├── auth_provider.dart         # Estado: Autenticación y sesión
│   ├── block_provider.dart        # Estado: Bloques y canciones
│   ├── language_provider.dart     # Estado: Idioma seleccionado
│   ├── liturgy_provider.dart      # Estado: Liturgias (CRUD, setContext)
│   └── organization_provider.dart # Estado: Organizaciones e invitaciones
│
├── services/                      # Lógica de negocio (4 servicios)
│   ├── auth_service.dart          # Servicio: Firebase Auth + Google Sign-In
│   ├── liturgy_service.dart       # Servicio: CRUD liturgias multi-tenant
│   ├── organization_service.dart  # Servicio: Organizaciones, miembros, invitaciones
│   └── pdf_service.dart           # Servicio: Generación y exportación de PDF
│
├── screens/                       # Pantallas principales (10 screens)
│   ├── login_screen.dart          # Pantalla: Login (email + Google)
│   ├── register_screen.dart       # Pantalla: Registro de usuario
│   ├── password_recovery_screen.dart # Pantalla: Recuperar contraseña
│   ├── organization_selector_screen.dart # Pantalla: Selector de organización
│   ├── create_organization_screen.dart   # Pantalla: Crear organización
│   ├── organization_settings_screen.dart # Pantalla: Configuración de org
│   ├── invitations_screen.dart    # Pantalla: Gestión de invitaciones
│   ├── liturgy_list_screen.dart   # Pantalla: Lista de liturgias
│   ├── liturgy_editor_screen.dart # Pantalla: Editor con auto-save
│   └── presentation_mode_screen.dart # Pantalla: Modo presentación
│
├── widgets/                       # Componentes reutilizables
│   ├── common_widgets.dart        # Loading, Empty, Error, Confirm
│   └── language_selector.dart     # Selector de idioma (AppBar)
│
├── theme/                         # Estilos y tema visual
│   └── app_theme.dart             # Definición del tema (Indigo/Violeta)
│
└── utils/                         # Utilidades
    └── responsive_utils.dart      # Breakpoints y helpers responsive
```

---

## 🔥 Estructura de Firestore (Multi-tenant v1.1)

```
firestore (root)
├── users/{userId}
│   ├── email, displayName, photoURL
│   ├── organizationIds: array<string>
│   ├── activeOrganizationId: string
│   └── authProviders: array<string>
│
├── organizations/{organizationId}
│   ├── nombre, descripcion, createdBy
│   │
│   ├── members/{userId}
│   │   ├── email, displayName, role ("admin"|"member")
│   │   └── joinedAt, invitedBy
│   │
│   └── liturgias/{liturgyId}
│       ├── titulo, fecha, hora, descripcion, createdBy
│       │
│       └── bloques/{blockId}
│           ├── tipo, descripcion, responsables, duracionMinutos, orden
│           │
│           └── canciones/{songId}
│               ├── nombre, autor, tono, orden
│
└── invitations/{invitationId}
    ├── organizationId, organizationName, email
    ├── role, invitedBy, invitedByName
    └── status ("pending"|"accepted"|"rejected")
```

### Reglas de Seguridad

Las reglas actuales implementan aislamiento multi-tenant con helpers `isMemberOf()` y `isAdminOf()`. Ver [firestore.rules](firestore.rules) para la implementación completa. Desplegar con:

```bash
firebase deploy --only firestore:rules
```

---

## 📦 Dependencias Principales

```yaml
dependencies:
  # Framework
  flutter_sdk: ^3.10.4

  # Firebase
  firebase_core: ^3.10.0        # Core de Firebase
  cloud_firestore: ^5.6.0       # Base de datos NoSQL
  firebase_auth: ^5.3.3         # Autenticación
  google_sign_in: ^6.2.2        # Google Sign-In

  # Estado
  provider: ^6.1.2              # Gestión de estado (MVVM)

  # PDF
  pdf: ^3.11.2                  # Generación de PDF
  flutter_file_dialog: ^3.0.2   # Guardar archivos
  share_plus: ^10.1.4           # Compartir archivos
  path_provider: ^2.1.5         # Rutas de almacenamiento
  permission_handler: ^11.3.1   # Permisos de almacenamiento

  # UI/UX
  intl: ^0.20.1                 # Internacionalización y formato de fechas
  cupertino_icons: ^1.0.8       # Iconos iOS

  # Utilidades
  uuid: ^4.5.1                  # Generación de IDs únicos
  shared_preferences: ^2.3.3    # Persistencia local (idioma)
```

---

## 📚 Documentación

Documentación completa en [`documentation/`](documentation/):

| Categoría | Archivo | Descripción |
|-----------|---------|-------------|
| 🚀 Inicio | [QUICKSTART.md](documentation/QUICKSTART.md) | Guía de instalación en 10 minutos |
| 📋 Resumen | [PROJECT_SUMMARY.md](documentation/PROJECT_SUMMARY.md) | Resumen ejecutivo del proyecto |
| 🏗️ Arquitectura | [ARCHITECTURE.md](documentation/ARCHITECTURE.md) | Arquitectura técnica detallada |
| 📖 API | [API_REFERENCE.md](documentation/API_REFERENCE.md) | Referencia de modelos, providers y servicios |
| 🧩 Componentes | [COMPONENT_GUIDE.md](documentation/COMPONENT_GUIDE.md) | Guía de widgets y pantallas |
| 🔥 Firebase | [FIREBASE_SETUP.md](documentation/FIREBASE_SETUP.md) | Configuración de Firebase y Auth |
| 🔥 Firestore | [FIRESTORE_STRUCTURE_V1.1.md](documentation/FIRESTORE_STRUCTURE_V1.1.md) | Estructura multi-tenant de Firestore |
| 🔧 Firebase Config | [FIREBASE_CONFIGURATION.md](documentation/FIREBASE_CONFIGURATION.md) | Configuración detallada de Firebase |
| 📝 Implementación | [IMPLEMENTATION_GUIDE.md](documentation/IMPLEMENTATION_GUIDE.md) | Guía de implementación |
| ✅ Estado | [IMPLEMENTATION_STATUS.md](documentation/IMPLEMENTATION_STATUS.md) | Estado actual de implementación |
| 🛠️ Comandos | [COMMANDS.md](documentation/COMMANDS.md) | Comandos útiles de Flutter y Firebase |
| 🐛 Problemas | [TROUBLESHOOTING.md](documentation/TROUBLESHOOTING.md) | Solución de problemas comunes |
| 📰 Cambios | [CHANGELOG.md](documentation/CHANGELOG.md) | Historial de cambios por versión |

---

## 🔧 Desarrollo

### Comandos Útiles

```bash
# Análisis de código
flutter analyze

# Formatear código
dart format .

# Ejecutar tests
flutter test

# Ver dispositivos disponibles
flutter devices

# Limpiar build
flutter clean

# Desplegar reglas de Firestore
firebase deploy --only firestore:rules
```

### Convenios de Código

- ✅ **Dart style guide** oficial
- ✅ **Null safety** habilitado
- ✅ **Comentarios en español** para claridad del equipo
- ✅ **Provider pattern** para gestión de estado
- ✅ **Separación de responsabilidades** (MVVM)

---

## 🗺️ Roadmap

### ✅ v1.0 — Lanzamiento Inicial
- [x] Gestión de liturgias (CRUD)
- [x] 10 tipos de bloques con canciones
- [x] Modo presentación
- [x] Multiidioma (ES/EN)
- [x] Diseño responsive tablet-first

### ✅ v1.1 — Multi-tenant y Autenticación
- [x] Firebase Auth (email + Google Sign-In)
- [x] Sistema de organizaciones con roles (Admin/Miembro)
- [x] Invitaciones por email
- [x] Firestore multi-tenant con reglas de seguridad
- [x] Exportación a PDF (generar, compartir, guardar)
- [x] Campo `hora` en liturgias

### v1.2 — Mejoras UX (Completado parcialmente)
- [x] Mejoras en eliminación de cultos (swipe, menú contextual)
- [x] Terminología "culto" en español
- [ ] Modo offline con sincronización
- [ ] Búsqueda y filtros avanzados
- [ ] Temas personalizables (light/dark)

### v2.0 — Futuro
- [ ] Biblioteca de canciones compartida
- [ ] Plantillas de liturgias predefinidas
- [ ] Calendario de liturgias
- [ ] Estadísticas de uso

---

## 📄 Licencia

Este proyecto es privado y de uso interno.

---

## 👨‍💻 Autor

**Jose Miquilena**
🔗 GitHub: [@josemiquilena](https://github.com/josemiquilena)

---

<div align="center">

**Hecho con ❤️ y ☕ por Jose Miquilena**

</div>
