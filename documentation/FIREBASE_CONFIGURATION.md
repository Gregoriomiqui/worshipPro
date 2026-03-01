# Guía de Configuración de Firebase Console

Esta guía te llevará paso a paso para configurar Firebase Authentication y Firestore en Firebase Console.

## 📋 Requisitos Previos

- Cuenta de Firebase/Google Cloud
- Proyecto de Firebase creado
- Firebase CLI instalado (`npm install -g firebase-tools`)
- FlutterFire CLI instalado (`dart pub global activate flutterfire_cli`)

## 🔧 Paso 1: Configurar Firebase en tu Proyecto Flutter

### 1.1 Iniciar sesión en Firebase CLI

```bash
firebase login
```

### 1.2 Ejecutar FlutterFire Configure

```bash
flutterfire configure
```

Este comando:
- Detectará automáticamente tu proyecto Flutter
- Te permitirá seleccionar o crear un proyecto de Firebase
- Generará el archivo `firebase_options.dart` automáticamente
- Configurará iOS, Android y Web

Selecciona las plataformas que necesites:
- ✅ Android
- ✅ iOS
- ✅ Web (opcional)
- ✅ macOS (opcional)

## 🔐 Paso 2: Habilitar Firebase Authentication

### 2.1 Ir a Firebase Console

1. Abre [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. En el menú lateral, haz clic en **Authentication** (🔐)

### 2.2 Habilitar Email/Password

1. Ve a la pestaña **Sign-in method**
2. Busca **Email/Password** en la lista
3. Haz clic en él para expandir
4. **Habilita** el toggle
5. Haz clic en **Guardar**

### 2.3 Habilitar Google Sign-In

1. En la misma pestaña **Sign-in method**
2. Busca **Google** en la lista
3. Haz clic en él para expandir
4. **Habilita** el toggle
5. Selecciona un **Support email** (tu email de soporte)
6. Haz clic en **Guardar**

#### Configuración adicional para Google Sign-In en Android:

1. Descarga el archivo `google-services.json` actualizado:
   - Ve a **Configuración del proyecto** (⚙️) > **Tus apps**
   - Selecciona tu app Android
   - Descarga `google-services.json`
   - Colócalo en `android/app/google-services.json`

2. Obtén el SHA-1 de tu aplicación:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   
3. Agrega el SHA-1 en Firebase Console:
   - Ve a **Configuración del proyecto** > **Tus apps** > Android
   - Haz clic en **Agregar huella digital**
   - Pega el SHA-1

#### Configuración adicional para Google Sign-In en iOS:

1. Descarga el archivo `GoogleService-Info.plist` actualizado:
   - Ve a **Configuración del proyecto** > **Tus apps**
   - Selecciona tu app iOS
   - Descarga `GoogleService-Info.plist`
   - Colócalo en `ios/Runner/GoogleService-Info.plist`

2. Abre `ios/Runner.xcworkspace` en Xcode
3. Agrega el `REVERSED_CLIENT_ID` al URL Scheme:
   - Selecciona el proyecto Runner en el navegador
   - Ve a la pestaña **Info**
   - Expande **URL Types**
   - Agrega un nuevo URL Scheme con el valor del `REVERSED_CLIENT_ID` de `GoogleService-Info.plist`

## 🗄️ Paso 3: Configurar Cloud Firestore

### 3.1 Crear Base de Datos

1. En Firebase Console, ve a **Firestore Database** (🗄️)
2. Haz clic en **Crear base de datos**
3. Selecciona el modo:
   - **Producción**: Más seguro (recomendado)
   - **Modo de prueba**: Solo para desarrollo inicial
4. Selecciona una **ubicación** (elige la más cercana a tus usuarios)
   - Ejemplo: `us-central1`, `southamerica-east1`
5. Haz clic en **Habilitar**

### 3.2 Aplicar Reglas de Seguridad

1. Ve a la pestaña **Reglas**
2. **Reemplaza** el contenido con las reglas de `firestore.rules` de tu proyecto
3. Copia el contenido del archivo `firestore.rules` en la raíz del proyecto
4. Pega el contenido en el editor de Firebase Console
5. Haz clic en **Publicar**

**Importante**: Las reglas incluyen:
- ✅ Autenticación requerida para todas las operaciones
- ✅ Aislamiento multi-tenant (organizaciones)
- ✅ Validación de roles (admin/member)
- ✅ Helpers: `isMemberOf()` y `isAdminOf()`

### 3.3 Crear Índices (Opcional pero Recomendado)

1. Ve a la pestaña **Índices**
2. Firebase creará índices automáticamente cuando los necesites
3. Si aparecen errores de índices en la consola, Firebase te dará un enlace directo para crearlos

Alternativamente, puedes desplegar los índices con:

```bash
firebase deploy --only firestore:indexes
```

Esto usa el archivo `firestore.indexes.json` en la raíz del proyecto.

## 📱 Paso 4: Configuración Específica de Plataforma

### Android

El archivo `android/app/google-services.json` debe estar presente:

```
android/
  app/
    google-services.json  ← Este archivo
    build.gradle.kts
```

### iOS

El archivo `ios/Runner/GoogleService-Info.plist` debe estar presente:

```
ios/
  Runner/
    GoogleService-Info.plist  ← Este archivo
    Info.plist
```

### Web (Opcional)

Actualiza `web/index.html` con tu configuración de Firebase. FlutterFire configure debería haberlo hecho automáticamente.

## ✅ Paso 5: Verificar Configuración

### 5.1 Limpiar y Reconstruir

```bash
flutter clean
flutter pub get
```

### 5.2 Ejecutar la Aplicación

```bash
flutter run
```

### 5.3 Pruebas de Autenticación

1. **Registro con Email/Password**:
   - Abre la app
   - Ve a la pantalla de registro
   - Crea una cuenta con email y contraseña
   - Verifica en Firebase Console > Authentication > Users

2. **Login con Google**:
   - Haz clic en "Continuar con Google"
   - Selecciona una cuenta de Google
   - Verifica que aparece en Firebase Console

3. **Crear Organización**:
   - Después del login, crea una iglesia
   - Verifica en Firestore Console:
     - Colección `organizations` con un documento
     - Subcollection `members` con tu usuario como admin
     - Colección `users` con tu perfil actualizado

## 🐛 Solución de Problemas

### Error: "No se pudo inicializar Firebase"

- ✅ Verifica que ejecutaste `flutterfire configure`
- ✅ Verifica que `firebase_options.dart` existe en `lib/`
- ✅ Ejecuta `flutter clean && flutter pub get`

### Error de Google Sign-In en Android

- ✅ Verifica que agregaste el SHA-1 en Firebase Console
- ✅ Descarga un nuevo `google-services.json`
- ✅ Verifica que `com.google.gms:google-services` está en `build.gradle`

### Error de Google Sign-In en iOS

- ✅ Verifica que `GoogleService-Info.plist` está en `ios/Runner/`
- ✅ Verifica que agregaste el URL Scheme en Xcode
- ✅ Ejecuta `cd ios && pod install`

### Error: "Missing permissions" en Firestore

- ✅ Verifica que publicaste las reglas de `firestore.rules`
- ✅ Verifica que el usuario está autenticado
- ✅ Verifica que el usuario pertenece a una organización

### Error: "Index required"

Firebase te dará un enlace directo en la consola de error. Haz clic en él para crear el índice automáticamente.

## 📚 Recursos Adicionales

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Authentication Docs](https://firebase.google.com/docs/auth)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)

## 🎉 ¡Listo!

Tu aplicación WorshipPro ahora está completamente configurada con:

- ✅ Firebase Authentication (Email/Password + Google)
- ✅ Cloud Firestore con reglas de seguridad multi-tenant
- ✅ Registro y login funcional
- ✅ Sistema de organizaciones (iglesias)
- ✅ Gestión de miembros e invitaciones

¡Puedes comenzar a crear liturgias! 🎵
