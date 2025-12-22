# 🔥 Configuración de Firebase para WorshipPro

Este archivo contiene los pasos detallados para configurar Firebase en tu proyecto WorshipPro.

---

## ⚙️ Método 1: FlutterFire CLI (Recomendado - Más Rápido)

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

### Paso 4: Habilitar Firestore

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. En el menú lateral, selecciona **Firestore Database**
4. Haz clic en **Crear base de datos**
5. Selecciona **Modo de prueba** (para desarrollo)
6. Elige una ubicación cercana (ej: `us-central`)
7. Haz clic en **Habilitar**

### Paso 5: Configurar reglas de Firestore (Desarrollo)

En la consola de Firebase, ve a **Firestore Database** → **Reglas** y pega:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // Solo para desarrollo!
    }
  }
}
```

⚠️ **IMPORTANTE**: Estas reglas son muy permisivas y solo deben usarse en desarrollo.

---

## ⚙️ Método 2: Configuración Manual (Alternativa)

### Para Android

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Haz clic en **Agregar aplicación** → **Android**
4. Registra tu app con el package name: `com.example.worshippro` (o el que uses)
5. Descarga el archivo `google-services.json`
6. Colócalo en: `android/app/google-services.json`

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

Si ves la pantalla de "No hay liturgias" sin errores, ¡Firebase está funcionando correctamente! 🎉

---

## 🚨 Solución de problemas comunes

### Error: "No Firebase App '[DEFAULT]' has been created"

**Solución**: Asegúrate de que `firebase_options.dart` existe y está correctamente importado en `main.dart`.

### Error: "FirebaseOptions cannot be null"

**Solución**: Regenera la configuración con `flutterfire configure`.

### Error: "PERMISSION_DENIED: Missing or insufficient permissions"

**Solución**: Revisa las reglas de Firestore en Firebase Console.

### Error en iOS: "GoogleService-Info.plist not found"

**Solución**: Asegúrate de que el archivo está en `ios/Runner/` y ejecuta:
```bash
cd ios
pod install
cd ..
flutter clean
flutter run
```

### Error en Android: "google-services.json not found"

**Solución**: Asegúrate de que el archivo está en `android/app/` y ejecuta:
```bash
flutter clean
flutter run
```

---

## 📊 Estructura de datos en Firestore

Una vez que Firebase esté funcionando, la app creará automáticamente esta estructura:

```
liturgias/
  {liturgyId}/
    titulo: "Culto dominical"
    fecha: timestamp
    descripcion: "..."
    createdAt: timestamp
    updatedAt: timestamp
    
    bloques/
      {blockId}/
        tipo: "adoracionAlabanza"
        descripcion: "Tiempo de alabanza"
        responsables: ["Juan", "María"]
        duracionMinutos: 20
        orden: 0
        
        canciones/
          {songId}/
            nombre: "Amazing Grace"
            autor: "John Newton"
            tono: "Re"
```

---

## 🔒 Reglas de producción (cuando estés listo para publicar)

Reemplaza las reglas de desarrollo con algo como esto:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Requiere autenticación
    match /liturgias/{liturgyId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid != null;
      
      match /bloques/{blockId} {
        allow read: if request.auth != null;
        allow write: if request.auth != null;
        
        match /canciones/{songId} {
          allow read: if request.auth != null;
          allow write: if request.auth != null;
        }
      }
    }
  }
}
```

Luego, implementa Firebase Authentication en la app.

---

## 📚 Recursos adicionales

- [Documentación oficial de FlutterFire](https://firebase.flutter.dev/)
- [Firestore Getting Started](https://firebase.google.com/docs/firestore/quickstart)
- [Firebase Console](https://console.firebase.google.com/)

---

¡Listo! Ahora tu app WorshipPro está completamente configurada con Firebase. 🚀
