# 🎵 WorshipPro v1.1 - Quick Start Guide

Sistema multi-tenant de gestión de liturgias con autenticación Firebase.

## 🚀 Inicio Rápido

### 1. Instalar Dependencias

```bash
flutter pub get
```

### 2. Configurar Firebase

```bash
# Instalar herramientas
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# Iniciar sesión
firebase login

# Configurar proyecto
flutterfire configure
```

Esto generará automáticamente `lib/firebase_options.dart`.

### 3. Configurar Firebase Console

Sigue la guía completa en [documentation/FIREBASE_CONFIGURATION.md](documentation/FIREBASE_CONFIGURATION.md):

1. **Habilitar Authentication**:
   - Email/Password
   - Google Sign-In
   
2. **Crear Firestore Database**:
   - Aplicar reglas de `firestore.rules`

3. **Configurar plataformas**:
   - Android: SHA-1 y `google-services.json`
   - iOS: URL Scheme y `GoogleService-Info.plist`

### 4. Ejecutar la Aplicación

```bash
flutter clean
flutter pub get
flutter run
```

## 📱 Flujo de la Aplicación

1. **Login/Registro**:
   - Email/Password
   - Google Sign-In
   - Recuperación de contraseña

2. **Seleccionar/Crear Iglesia**:
   - Crear nueva organización
   - Seleccionar organización existente
   - Ver invitaciones pendientes

3. **Gestión de Liturgias**:
   - Crear, editar, eliminar liturgias
   - Agregar bloques y canciones
   - Visualizar en modo presentación

4. **Configuración de Iglesia** (Solo Admins):
   - Información de la organización
   - Invitar miembros
   - Gestionar roles

## 🏗️ Arquitectura

### Multi-Tenancy

Todas las liturgias están aisladas por organización:

```
organizations/{orgId}/
  ├── liturgias/{liturgyId}
  │   ├── bloques/{blockId}
  │   └── canciones/{songId}
  └── members/{userId}
```

### Autenticación

- **Email/Password**: Registro tradicional
- **Google Sign-In**: OAuth 2.0
- **Account Linking**: Vincular Google a cuenta existente

### Roles

- **Admin**: Permisos completos, puede invitar miembros
- **Member**: Acceso a liturgias, sin gestión de miembros

## 📁 Estructura del Proyecto

```
lib/
├── models/          # Modelos de datos (User, Organization, Liturgy...)
├── services/        # Lógica de negocio (Auth, Organization, Liturgy...)
├── providers/       # Estado con Provider pattern
├── screens/         # Pantallas UI
│   ├── auth/        # Login, Register, PasswordRecovery
│   ├── organization/# OrganizationSelector, Settings, Invitations
│   └── *.dart       # LiturgyList, LiturgyEditor, etc.
├── widgets/         # Widgets reutilizables
├── theme/           # Tema de la app
└── main.dart        # Entry point con AuthGuard
```

## 🔐 Seguridad

### Firestore Rules

Las reglas de seguridad validan:

- ✅ Usuario autenticado
- ✅ Pertenece a la organización
- ✅ Tiene el rol correcto (admin/member)

```javascript
function isMemberOf(orgId) {
  return request.auth.uid != null &&
         orgId in get(/databases/$(database)/documents/users/$(request.auth.uid)).data.organizationIds;
}

function isAdminOf(orgId) {
  return isMemberOf(orgId) && 
         get(/databases/$(database)/documents/organizations/$(orgId)/members/$(request.auth.uid)).data.role == 'admin';
}
```

## 🧪 Testing

### Flujo de Prueba Manual

1. **Registro**:
   - Crea cuenta con email: `test@example.com`
   - Verifica en Firebase Console > Authentication

2. **Crear Iglesia**:
   - Nombre: "Iglesia de Prueba"
   - Verifica en Firestore > organizations

3. **Crear Liturgia**:
   - Título: "Domingo 15 de Diciembre"
   - Fecha: Hoy
   - Verifica en Firestore > organizations/{orgId}/liturgias

4. **Invitar Miembro**:
   - Email de otro usuario
   - Rol: Member
   - Verifica en Firestore > invitations

## 📚 Documentación

- [FIREBASE_CONFIGURATION.md](documentation/FIREBASE_CONFIGURATION.md) - Configuración de Firebase Console
- [IMPLEMENTATION_STATUS.md](documentation/IMPLEMENTATION_STATUS.md) - Estado de implementación
- [FIRESTORE_STRUCTURE_V1.1.md](documentation/FIRESTORE_STRUCTURE_V1.1.md) - Estructura de datos
- [IMPLEMENTATION_GUIDE.md](documentation/IMPLEMENTATION_GUIDE.md) - Guía técnica detallada
- [ARCHITECTURE.md](documentation/ARCHITECTURE.md) - Arquitectura del proyecto
- [PROJECT_SUMMARY.md](documentation/PROJECT_SUMMARY.md) - Resumen del proyecto

## 🐛 Troubleshooting

### "No se pudo inicializar Firebase"
```bash
flutterfire configure
flutter clean && flutter pub get
```

### Error de Google Sign-In (Android)
- Agrega SHA-1 en Firebase Console
- Descarga nuevo `google-services.json`

### Error de permisos en Firestore
- Verifica que publicaste las reglas de `firestore.rules`
- Verifica que el usuario está autenticado

### "Index required"
- Firebase te dará un enlace en la consola de error
- Haz clic para crear el índice automáticamente

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama: `git checkout -b feature/nueva-funcionalidad`
3. Commit: `git commit -m 'Agregar nueva funcionalidad'`
4. Push: `git push origin feature/nueva-funcionalidad`
5. Abre un Pull Request

## 📄 Licencia

Este proyecto es privado y confidencial.

## 💬 Soporte

Para preguntas o problemas, contacta al equipo de desarrollo.

---

**WorshipPro v1.1** - Sistema de Gestión de Liturgias Multi-Tenant
Desarrollado con Flutter + Firebase 🚀
