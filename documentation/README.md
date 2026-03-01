# WorshipPro - Documentación

> Aplicación móvil para crear, organizar y presentar liturgias de cultos cristianos con sistema multi-tenant de organizaciones.

## 📚 Documentación Completa

### 🚀 Para Empezar
- **[QUICKSTART.md](QUICKSTART.md)** - Instalación rápida y primeros pasos
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Resumen ejecutivo del proyecto

### 🏗️ Arquitectura y Desarrollo
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Arquitectura técnica detallada (MVVM, patrones, estructura)
- **[API_REFERENCE.md](API_REFERENCE.md)** - Referencia completa de APIs, modelos y métodos
- **[COMPONENT_GUIDE.md](COMPONENT_GUIDE.md)** - Guía de todos los widgets y componentes UI

### 🔧 Configuración y Firebase
- **[FIREBASE_CONFIGURATION.md](FIREBASE_CONFIGURATION.md)** - Guía paso a paso para configurar Firebase Console (Auth + Firestore)
- **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** - Setup técnico de Firebase en el proyecto Flutter
- **[FIRESTORE_STRUCTURE_V1.1.md](FIRESTORE_STRUCTURE_V1.1.md)** - Estructura de datos multi-tenant en Firestore
- **[COMMANDS.md](COMMANDS.md)** - Referencia de comandos útiles de Flutter, Firebase y Git

### 📋 Implementación
- **[IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)** - Guía técnica de implementación v1.1
- **[IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md)** - Estado de implementación de features

### 🐛 Mantenimiento
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Solución de problemas comunes
- **[CHANGELOG.md](CHANGELOG.md)** - Registro de cambios y versiones

---

## 🤖 Guía Rápida para Agentes IA

### Primer Contacto
1. **Lee primero:** [ARCHITECTURE.md](ARCHITECTURE.md) - Estructura MVVM, 5 providers, 4 servicios, 10 pantallas
2. **Luego revisa:** [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - Contexto general y estado actual

### Durante el Desarrollo
- **Para implementar features:** [API_REFERENCE.md](API_REFERENCE.md) - Todos los Providers, Services y Modelos
- **Para UI/UX:** [COMPONENT_GUIDE.md](COMPONENT_GUIDE.md) - Widgets y guías de estilo
- **Para Firebase:** [FIRESTORE_STRUCTURE_V1.1.md](FIRESTORE_STRUCTURE_V1.1.md) - Estructura multi-tenant

### Solución de Problemas
- **Si hay errores:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Problemas comunes y soluciones
- **Para Firebase/Auth:** [FIREBASE_CONFIGURATION.md](FIREBASE_CONFIGURATION.md) - SHA-1, Google Sign-In, etc.

---

## 🎯 Descripción del Proyecto

**WorshipPro** es una aplicación Flutter diseñada para tablets y dispositivos móviles, que permite a líderes de cultos cristianos crear y gestionar liturgias de forma profesional.

### Características principales

- ✅ **Autenticación**: Email/Password + Google Sign-In con account linking
- ✅ **Multi-tenant**: Sistema de organizaciones (iglesias) con roles y invitaciones
- ✅ **Gestión de liturgias**: Crear, editar, duplicar y eliminar liturgias
- ✅ **10 tipos de bloques**: Adoración, oración, lectura bíblica, reflexión, etc.
- ✅ **Cálculo automático de duración**: Suma de todos los bloques
- ✅ **Modo presentación**: Pantalla completa optimizada para proyección
- ✅ **Canciones**: Gestión de canciones en bloques de adoración (nombre, autor, tono)
- ✅ **Exportación PDF**: Generar, compartir y guardar liturgias en PDF
- ✅ **Multiidioma**: Español e inglés con cambio dinámico
- ✅ **Responsive**: Adaptable a móvil, tablet y desktop
- ✅ **Persistencia Firebase**: Cloud Firestore con reglas de seguridad multi-tenant

---

## 📁 Estructura del proyecto

```
lib/
├── main.dart                          # Firebase + AuthGuard + 5 Providers
├── firebase_options.dart              # Generado con flutterfire configure
│
├── models/                            # 8 modelos de datos
│   ├── user.dart                      # Usuario con organizationIds
│   ├── organization.dart              # Organización (iglesia)
│   ├── member.dart                    # Miembro con roles (admin/member)
│   ├── invitation.dart                # Invitación con estados
│   ├── block_type.dart                # 10 tipos de bloques
│   ├── liturgy.dart                   # Liturgia con campo hora
│   ├── liturgy_block.dart             # Bloque de liturgia
│   └── song.dart                      # Canción (nombre, autor, tono)
│
├── services/                          # 4 servicios
│   ├── auth_service.dart              # Auth: email, Google, account linking
│   ├── organization_service.dart      # CRUD orgs, miembros, invitaciones
│   ├── liturgy_service.dart           # CRUD multi-tenant liturgias
│   └── pdf_service.dart               # Generación PDF
│
├── providers/                         # 5 providers
│   ├── auth_provider.dart             # Estado de autenticación
│   ├── organization_provider.dart     # Organizaciones y miembros
│   ├── liturgy_provider.dart          # Liturgias con contexto org
│   ├── block_provider.dart            # Bloques con contexto org
│   └── language_provider.dart         # Idioma con persistencia
│
├── screens/                           # 10 pantallas
│   ├── auth/                          # Login, registro, recuperar contraseña
│   ├── organization/                  # Selector, crear, settings, invitaciones
│   ├── liturgy_list_screen.dart       # Lista de liturgias
│   ├── liturgy_editor_screen.dart     # Editor de liturgia
│   └── presentation_mode_screen.dart  # Modo presentación
│
├── widgets/                           # Widgets reutilizables
│   ├── common_widgets.dart            # Loading, Empty, Error, Confirm
│   └── language_selector.dart         # Selector ES/EN
│
├── theme/                             # Tema Material 3
│   └── app_theme.dart                 # Paleta Indigo/Violeta
│
├── utils/                             # Utilidades
│   └── responsive_utils.dart          # Breakpoints y responsive helpers
│
└── l10n/                              # Internacionalización
    └── app_localizations.dart         # 70+ traducciones ES/EN
```

---

## 🔥 Estructura de Firestore (v1.1 Multi-tenant)

```
firestore (root)
├── users/{userId}
│   └── email, displayName, organizationIds, activeOrganizationId, authProviders
│
├── organizations/{organizationId}
│   ├── nombre, descripcion, createdBy
│   ├── members/{userId} → email, displayName, role (admin|member)
│   └── liturgias/{liturgyId}
│       ├── titulo, fecha, hora, descripcion, createdBy
│       └── bloques/{blockId}
│           ├── tipo, descripcion, responsables, duracionMinutos, orden
│           └── canciones/{songId} → nombre, autor, tono, orden
│
└── invitations/{invitationId}
    └── organizationId, email, role, status (pending|accepted|rejected)
```

---

## 🔒 Reglas de seguridad

Las reglas de Firestore implementan:
- **Autenticación obligatoria** para todas las operaciones
- **Aislamiento multi-tenant** con helper `isMemberOf(orgId)`
- **Control de roles** con helper `isAdminOf(orgId)`
- **Acceso a invitaciones** filtrado por email

Ver el archivo `firestore.rules` en la raíz del proyecto.

---

## 📦 Dependencias principales

| Paquete | Propósito |
|---------|-----------|
| `firebase_core` | Inicialización de Firebase |
| `cloud_firestore` | Base de datos NoSQL multi-tenant |
| `firebase_auth` | Autenticación (Email + Google) |
| `google_sign_in` | Google Sign-In nativo |
| `provider` | Gestión de estado (MVVM) |
| `pdf` | Generación de documentos PDF |
| `path_provider` | Acceso a directorios del sistema |
| `share_plus` | Compartir archivos |
| `flutter_file_dialog` | Guardar archivos en ubicación elegida |
| `permission_handler` | Gestión de permisos del sistema |
| `intl` | Internacionalización y formato de fechas |
| `uuid` | Generación de IDs únicos |
| `shared_preferences` | Persistencia local (idioma) |

---

**Última actualización:** Marzo 2026
**Versión actual:** v1.1 (Multi-tenant con Auth)
