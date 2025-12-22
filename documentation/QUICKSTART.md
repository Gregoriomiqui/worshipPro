# 🚀 Guía de inicio rápido - WorshipPro

Esta guía te ayudará a poner en marcha WorshipPro en menos de 10 minutos.

---

## ⚡ Paso 1: Instalar dependencias

```bash
flutter pub get
```

---

## 🔥 Paso 2: Configurar Firebase

### Opción más rápida: FlutterFire CLI

```bash
# 1. Instalar FlutterFire CLI (solo una vez)
dart pub global activate flutterfire_cli

# 2. Configurar Firebase
flutterfire configure

# Sigue las instrucciones:
# - Selecciona o crea un proyecto de Firebase
# - Selecciona las plataformas (iOS, Android, Web)
# - Se generará automáticamente firebase_options.dart
```

### Opción manual

Si prefieres configurar manualmente:

1. Ve a https://console.firebase.google.com/
2. Crea un nuevo proyecto llamado "WorshipPro" (o el nombre que prefieras)
3. En el proyecto, ve a **Firestore Database** y haz clic en **Crear base de datos**
4. Selecciona **Modo de prueba** (para desarrollo)
5. Elige una ubicación cercana

#### Para Android:
```bash
# Descarga google-services.json
# Colócalo en: android/app/google-services.json
```

#### Para iOS:
```bash
# Descarga GoogleService-Info.plist
# Colócalo en: ios/Runner/GoogleService-Info.plist
```

---

## 📱 Paso 3: Ejecutar la app

```bash
# Ver dispositivos disponibles
flutter devices

# Ejecutar en el dispositivo deseado
flutter run
```

O simplemente presiona F5 en VS Code / Android Studio.

---

## ✅ Verificar que todo funciona

1. La app debería abrirse sin errores
2. Deberías ver la pantalla de "No hay liturgias"
3. Haz clic en "Crear liturgia"
4. Completa el formulario y guarda
5. ¡Tu primera liturgia está creada! 🎉

---

## 🐛 Solución de problemas comunes

### Error: "No se puede conectar a Firebase"

**Solución**: Verifica que `firebase_options.dart` existe y tiene la configuración correcta.

```bash
# Regenerar configuración
flutterfire configure
```

### Error: "MissingPluginException"

**Solución**: Reinicia la app completamente.

```bash
# Detener la app (Ctrl+C en la terminal)
# Limpiar
flutter clean

# Reinstalar dependencias
flutter pub get

# Volver a ejecutar
flutter run
```

### Error de Firestore: "Permission denied"

**Solución**: En Firebase Console, ve a Firestore Database → Reglas y asegúrate de tener:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // Solo para desarrollo
    }
  }
}
```

---

## 📖 Próximos pasos

1. Lee el [README.md](README.md) completo para entender la estructura del proyecto
2. Explora los modelos de datos en `lib/models/`
3. Personaliza los colores en `lib/theme/app_theme.dart`
4. Agrega tus propios tipos de bloques en `lib/models/block_type.dart`

---

## 💡 Consejos

- **Usa un tablet o emulador de tablet** para la mejor experiencia
- **El modo presentación funciona mejor en pantalla completa**
- **Guarda frecuentemente** mientras editas liturgias
- **Prueba el modo presentación** antes del culto real

---

## 🙏 ¿Necesitas ayuda?

- Revisa el [README.md](README.md) principal
- Abre un issue en el repositorio
- Consulta la [documentación de Flutter](https://flutter.dev/docs)
- Consulta la [documentación de Firebase](https://firebase.google.com/docs)

---

¡Listo! Ahora estás preparado para usar WorshipPro en tu iglesia. 🎵
