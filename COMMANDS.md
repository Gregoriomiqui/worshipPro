# 🛠️ Comandos útiles - WorshipPro

Esta es una referencia rápida de comandos útiles para trabajar con WorshipPro.

---

## 🚀 Configuración inicial

```bash
# Instalar dependencias
flutter pub get

# Configurar Firebase (requerido)
flutterfire configure

# Verificar configuración
flutter doctor
```

---

## ▶️ Ejecutar la aplicación

```bash
# Ver dispositivos disponibles
flutter devices

# Ejecutar en modo debug (desarrollo)
flutter run

# Ejecutar en modo release (producción)
flutter run --release

# Ejecutar en un dispositivo específico
flutter run -d <device_id>

# Ejecutar en Chrome (web)
flutter run -d chrome

# Ejecutar en emulador iOS
flutter run -d "iPhone 15 Pro"

# Ejecutar en emulador Android
flutter run -d emulator-5554
```

---

## 🧹 Limpieza y mantenimiento

```bash
# Limpiar archivos de build
flutter clean

# Reinstalar dependencias
flutter pub get

# Actualizar dependencias
flutter pub upgrade

# Ver dependencias desactualizadas
flutter pub outdated

# Limpiar y reconstruir
flutter clean && flutter pub get && flutter run
```

---

## 🔧 Análisis y formato

```bash
# Analizar el código
flutter analyze

# Formatear todo el código
dart format lib/ test/

# Formatear un archivo específico
dart format lib/main.dart

# Verificar formato sin aplicar cambios
dart format --set-exit-if-changed lib/
```

---

## 🧪 Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar un test específico
flutter test test/widget_test.dart

# Ejecutar tests con cobertura
flutter test --coverage

# Ver reporte de cobertura (requiere lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📱 Build para producción

### Android APK

```bash
# Build APK de debug
flutter build apk --debug

# Build APK de release
flutter build apk --release

# Build APK split por ABI (archivos más pequeños)
flutter build apk --split-per-abi

# Ubicación del APK
# build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (AAB)

```bash
# Build AAB para Google Play Store
flutter build appbundle --release

# Ubicación del AAB
# build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
# Build para iOS (requiere Mac)
flutter build ios --release

# Abrir en Xcode para firmar y distribuir
open ios/Runner.xcworkspace
```

### Web

```bash
# Build para web
flutter build web --release

# Los archivos estarán en build/web/
# Puedes subirlos a cualquier hosting estático
```

### macOS

```bash
# Build para macOS
flutter build macos --release
```

---

## 🔥 Firebase

```bash
# Configurar Firebase
flutterfire configure

# Actualizar configuración de Firebase
flutterfire configure --force

# Ver proyectos de Firebase
firebase projects:list

# Seleccionar proyecto de Firebase
firebase use <project_id>

# Ver configuración actual
firebase projects:list
```

---

## 📊 Logs y debugging

```bash
# Ver logs en tiempo real
flutter logs

# Ver logs de un dispositivo específico
flutter logs -d <device_id>

# Ejecutar con verbose logs
flutter run -v

# Hot reload manual (mientras la app está corriendo)
# Presiona 'r' en la terminal

# Hot restart manual
# Presiona 'R' en la terminal

# Abrir DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

---

## 🔍 Debugging específico de Firebase

```bash
# Ver logs de Firestore
adb logcat | grep Firestore     # Android
log stream | grep Firestore      # iOS

# Limpiar caché de Firebase (Android)
adb shell pm clear com.google.android.gms

# Ver reglas de Firestore
firebase firestore:indexes
```

---

## 📦 Gestión de paquetes

```bash
# Agregar un nuevo paquete
flutter pub add <package_name>

# Agregar un paquete de dev
flutter pub add --dev <package_name>

# Remover un paquete
flutter pub remove <package_name>

# Listar dependencias en árbol
flutter pub deps
```

---

## 🛠️ Herramientas útiles

```bash
# Generar íconos de app (requiere flutter_launcher_icons)
flutter pub run flutter_launcher_icons:main

# Generar splash screen (requiere flutter_native_splash)
flutter pub run flutter_native_splash:create

# Verificar versión de Flutter
flutter --version

# Actualizar Flutter
flutter upgrade

# Cambiar canal de Flutter
flutter channel stable
flutter channel beta
```

---

## 🐛 Solución de problemas

```bash
# Resetear completamente el entorno
flutter clean
rm -rf ~/.pub-cache
flutter pub get

# Resetear dispositivos
flutter devices --reset

# Reinstalar Flutter (macOS/Linux)
cd <flutter_directory>
git clean -xfd
git pull
flutter doctor

# Verificar estado de Flutter
flutter doctor -v
```

---

## 📱 Emuladores

```bash
# Listar emuladores Android disponibles
flutter emulators

# Crear nuevo emulador Android
avdmanager create avd -n tablet -k "system-images;android-33;google_apis;x86_64" -d "Nexus 10"

# Lanzar emulador Android
flutter emulators --launch <emulator_id>

# Listar simuladores iOS
xcrun simctl list devices

# Lanzar simulador iOS
open -a Simulator
```

---

## 🎨 Comandos específicos de WorshipPro

```bash
# Ejecutar en modo tablet (Android)
flutter run --dart-define=TABLET_MODE=true

# Ejecutar con Firebase Emulator (local)
flutter run --dart-define=USE_FIREBASE_EMULATOR=true

# Build solo para tablets (ejemplo)
flutter build apk --target-platform android-arm64 --release
```

---

## 💡 Tips

1. **Hot reload**: Presiona `r` para recargar sin perder el estado
2. **Hot restart**: Presiona `R` para reiniciar completamente
3. **Widget inspector**: Presiona `w` para abrir el widget inspector
4. **Performance overlay**: Presiona `p` para ver métricas de rendimiento
5. **Salir**: Presiona `q` para detener la app

---

## 📚 Recursos adicionales

```bash
# Documentación oficial de Flutter
open https://flutter.dev/docs

# Paquetes de Pub.dev
open https://pub.dev

# Firebase Console
open https://console.firebase.google.com

# Flutter DevTools
flutter pub global run devtools
```

---

## ⚡ Atajos de desarrollo

Crear un alias en tu `.bashrc` o `.zshrc`:

```bash
# Atajos para WorshipPro
alias wpr='cd ~/path/to/worshippro && flutter run'
alias wpc='cd ~/path/to/worshippro && flutter clean && flutter pub get'
alias wpb='cd ~/path/to/worshippro && flutter build apk --release'
alias wpa='cd ~/path/to/worshippro && flutter analyze'
alias wpt='cd ~/path/to/worshippro && flutter test'
```

---

¡Listo! Con estos comandos puedes trabajar eficientemente en WorshipPro. 🚀
