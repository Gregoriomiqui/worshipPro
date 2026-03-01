# 🔥 Configuración de Firebase para WorshipPro

Este archivo contiene los pasos detallados para configurar Firebase en tu proyecto WorshipPro (v1.1 multi-tenant con autenticación).

---

## ⚙️ Método 1: FlutterFire CLI (Recomendado)

### Paso 1: Instalar FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### Paso 2: Login en Firebase

```bash
firebase login
```

Si no tienes Firebase CLI instalado:
```bash
npm install -g firebase-tools
```

### Paso 3: Configurar el proyecto

Desde la raíz del proyecto WorshipPro, ejecuta:

```bash
flutterfire configure
```

Esto:
1. Te pedirá seleccionar o crear un proyecto de Firebase
2. Te preguntará qué plataformas quieres configurar (iOS, Android, Web, macOS)
3. Generará automáticamente `lib/firebase_options.dart` con toda la configuración
4. Actualizará los archivos de configuración nativos necesarios

### Paso 4: Habilitar Firebase Authentication

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. En el menú lateral, selecciona **Authentication** → **Sign-in method**
4. Habilita los siguientes proveedores:
   - **Email/Password**: Activa el toggle
   - **Google**: Activa y configura con tu email de soporte

### Paso 5: Configurar Google Sign-In (Android)

Para que Google Sign-In funcione en Android, debes registrar el certificado SHA-1:

```bash
# Obtener el SHA-1 del certificado de debug
cd android
./gradlew signingReport
cd ..
```

Busca la línea `SHA1:` bajo la variante `debug`. Luego:

1. Ve a Firebase Console → **Project Settings** (⚙️)
2. En la sección **Your apps**, selecciona tu app Android
3. Click en **Add fingerprint**
4. Pega el SHA-1 copiado
5. **Re-descarga** `google-services.json` y reemplaza el archivo en `android/app/`

> ⚠️ **IMPORTANTE**: Sin el SHA-1 registrado, Google Sign-In fallará con `DEVELOPER_ERROR`.

### Paso 6: Habilitar Firestore

1. Ve a Firebase Console → **Firestore Database**
2. Haz clic en **Crear base de datos**
3. Selecciona **Modo de producción** (usaremos reglas personalizadas)
4. Elige una ubicación cercana (ej: `us-central1`, `southamerica-east1`)
5. Haz clic en **Habilitar**

### Paso 7: Desplegar reglas de seguridad

El proyecto incluye reglas multi-tenant en `firestore.rules`. Despliega con:

```bash
firebase deploy --only firestore:rules
```

Las reglas implementan:
- Autenticación obligatoria para todas las operaciones
- Aislamiento por organización con `isMemberOf()`
- Control de roles con `isAdminOf()` (solo admins gestionan miembros)
- Usuarios solo pueden leer/escribir sus propios datos

---

## ⚙️ Método 2: Configuración Manual (Alternativa)

### Para Android

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Haz clic en **Agregar aplicación** → **Android**
4. Registra tu app con el package name: `com.example.worshippro`
5. **Agrega el SHA-1** del certificado de debug (ver Paso 5 arriba)
6. Descarga el archivo `google-services.json`
7. Colócalo en: `android/app/google-services.json`

### Para iOS

1. En Firebase Console, haz clic en **Agregar aplicación** → **iOS**
2. Registra tu app con el Bundle ID
3. Descarga el archivo `GoogleService-Info.plist`
4. Colócalo en: `ios/Runner/GoogleService-Info.plist`

### Para Web

1. En Firebase Console, haz clic en **Agregar aplicación** → **Web**
2. Registra tu app web
3. Copia la configuración de Firebase
4. Crea `lib/firebase_options.dart` manualmente con la configuración

---

## ✅ Verificar la configuración

Para verificar que Firebase está correctamente configurado:

```bash
flutter run
```

Si ves la pantalla de **Login** sin errores, ¡Firebase está funcionando correctamente! 🎉

Flujo esperado:
1. **LoginScreen** → Iniciar sesión o registrarse
2. **OrganizationSelectorScreen** → Crear o seleccionar organización
3. **LiturgyListScreen** → Lista de liturgias de la organización activa

---

## 📊 Estructura de datos en Firestore

Una vez que Firebase esté funcionando, la app utilizará esta estructura multi-tenant:

```
users/{userId}
  email: "user@example.com"
  displayName: "Juan"
  organizationIds: ["orgId1", "orgId2"]
  activeOrganizationId: "orgId1"
  authProviders: ["password", "google.com"]

organizations/{organizationId}
  nombre: "Mi Iglesia"
  descripcion: "..."
  createdBy: "userId"

  members/{userId}
    email: "user@example.com"
    displayName: "Juan"
    role: "admin"
    joinedAt: timestamp

  liturgias/{liturgyId}
    titulo: "Culto dominical"
    fecha: timestamp
    hora: "10:00"
    descripcion: "..."
    createdBy: "userId"

    bloques/{blockId}
      tipo: "adoracionAlabanza"
      descripcion: "Tiempo de alabanza"
      responsables: ["Juan", "María"]
      duracionMinutos: 20
      orden: 0

      canciones/{songId}
        nombre: "Amazing Grace"
        autor: "John Newton"
        tono: "G"

invitations/{invitationId}
  organizationId: "orgId1"
  organizationName: "Mi Iglesia"
  email: "invitado@example.com"
  role: "member"
  status: "pending"
```

---

## 🔒 Reglas de seguridad (producción)

Las reglas actuales del proyecto (`firestore.rules`) ya implementan seguridad completa:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }

    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }

    function isMemberOf(organizationId) {
      return organizationId in getUserData().organizationIds;
    }

    function isAdminOf(organizationId) {
      return get(/databases/$(database)/documents/organizations/$(organizationId)/members/$(request.auth.uid)).data.role == 'admin';
    }

    // Users: solo pueden acceder a sus propios datos
    match /users/{userId} {
      allow read, write: if isAuthenticated() && request.auth.uid == userId;
    }

    // Organizations: miembros pueden leer, admins pueden escribir
    match /organizations/{organizationId} {
      allow read: if isAuthenticated() && isMemberOf(organizationId);
      allow create: if isAuthenticated();
      allow update, delete: if isAuthenticated() && isAdminOf(organizationId);

      // Members
      match /members/{memberId} {
        allow read: if isAuthenticated() && isMemberOf(organizationId);
        allow write: if isAuthenticated() && isAdminOf(organizationId);
      }

      // Liturgias y sub-colecciones
      match /liturgias/{liturgyId} {
        allow read, write: if isAuthenticated() && isMemberOf(organizationId);

        match /bloques/{blockId} {
          allow read, write: if isAuthenticated() && isMemberOf(organizationId);

          match /canciones/{songId} {
            allow read, write: if isAuthenticated() && isMemberOf(organizationId);
          }
        }
      }
    }

    // Invitations
    match /invitations/{invitationId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated();
    }
  }
}
```

Desplegar con:
```bash
firebase deploy --only firestore:rules
```

---

## 🚨 Solución de problemas comunes

### Error: "DEVELOPER_ERROR" al usar Google Sign-In

**Causa**: SHA-1 no registrado en Firebase Console.
**Solución**: Ver Paso 5 — registrar SHA-1 y re-descargar `google-services.json`.

### Error: "No Firebase App '[DEFAULT]' has been created"

**Solución**: Asegúrate de que `firebase_options.dart` existe y está correctamente importado en `main.dart`.

### Error: "FirebaseOptions cannot be null"

**Solución**: Regenera la configuración con `flutterfire configure`.

### Error: "PERMISSION_DENIED: Missing or insufficient permissions"

**Solución**: Despliega las reglas de seguridad: `firebase deploy --only firestore:rules`.

### Error: "Unable to resolve host firestore.googleapis.com"

**Causa**: El dispositivo no tiene conexión a internet.
**Solución**: Verificar conexión WiFi/datos del dispositivo.

### Error en iOS: "GoogleService-Info.plist not found"

**Solución**:
```bash
cd ios && pod install && cd ..
flutter clean && flutter run
```

### Error en Android: "google-services.json not found"

**Solución**:
```bash
flutter clean && flutter run
```

---

## 📚 Recursos adicionales

- [Documentación oficial de FlutterFire](https://firebase.flutter.dev/)
- [Firebase Auth Flutter](https://firebase.flutter.dev/docs/auth/overview)
- [Firestore Getting Started](https://firebase.google.com/docs/firestore/quickstart)
- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)
- [Firebase Console](https://console.firebase.google.com/)
