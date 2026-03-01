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

### Configuración adicional requerida

1. **Habilitar Authentication** en Firebase Console:
   - Ve a Authentication → Sign-in method
   - Activa **Email/Password**
   - Activa **Google** (con tu email de soporte)

2. **Habilitar Firestore** en Firebase Console:
   - Ve a Firestore Database → Crear base de datos
   - Selecciona Modo de producción
   - Elige ubicación cercana

3. **Desplegar reglas de seguridad**:
   ```bash
   firebase deploy --only firestore:rules
   ```

4. **Registrar SHA-1 para Google Sign-In** (Android):
   ```bash
   cd android && ./gradlew signingReport
   ```
   Copia el SHA-1 → Firebase Console → Project Settings → Android app → Add fingerprint.
   Re-descarga `google-services.json` y reemplaza en `android/app/`.

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
2. Deberías ver la **pantalla de Login**
3. **Registra un nuevo usuario** con email y contraseña (o usa Google Sign-In)
4. **Crea tu primera organización** (iglesia)
5. **Crea tu primera liturgia** con el botón (+)
6. ¡Tu primera liturgia está creada! 🎉

### Flujo esperado:
```
LoginScreen → RegisterScreen → OrganizationSelectorScreen
→ CreateOrganizationScreen → LiturgyListScreen → LiturgyEditorScreen
```

---

## 🐛 Solución de problemas comunes

### Error: "DEVELOPER_ERROR" al usar Google Sign-In

**Causa**: No se ha registrado el SHA-1 del certificado en Firebase Console.
**Solución**: Ver Paso 2, punto 4.

### Error: "No se puede conectar a Firebase"

**Solución**: Verifica que `firebase_options.dart` existe y tiene la configuración correcta.

```bash
# Regenerar configuración
flutterfire configure
```

### Error: "Unable to resolve host firestore.googleapis.com"

**Causa**: El dispositivo no tiene conexión a internet.
**Solución**: Verificar conexión WiFi/datos móviles.

### Error: "MissingPluginException"

**Solución**: Reinicia la app completamente.

```bash
flutter clean && flutter pub get && flutter run
```

### Error de Firestore: "Permission denied"

**Solución**: Despliega las reglas de seguridad:

```bash
firebase deploy --only firestore:rules
```

---

## 📖 Próximos pasos

1. Lee el [README.md](../README.md) completo para entender la estructura del proyecto
2. Explora los modelos de datos en `lib/models/` (8 modelos)
3. Revisa la [ARCHITECTURE.md](ARCHITECTURE.md) para entender el patrón MVVM
4. Personaliza los colores en `lib/theme/app_theme.dart`
5. Invita miembros a tu organización desde la app

---

## 💡 Consejos

- **Usa un tablet o emulador de tablet** para la mejor experiencia
- **El modo presentación funciona mejor en pantalla completa**
- **Exporta a PDF** para compartir el programa del culto
- **Prueba el modo presentación** antes del culto real
- **Invita miembros** a tu organización para trabajo colaborativo

---

## 🙏 ¿Necesitas ayuda?

- Revisa el [README.md](../README.md) principal
- Consulta [TROUBLESHOOTING.md](TROUBLESHOOTING.md) para problemas comunes
- Revisa [FIREBASE_SETUP.md](FIREBASE_SETUP.md) para configuración detallada de Firebase
- Consulta la [documentación de Flutter](https://flutter.dev/docs)
- Consulta la [documentación de Firebase](https://firebase.google.com/docs)
