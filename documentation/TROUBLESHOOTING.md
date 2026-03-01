# Guía de Solución de Problemas - WorshipPro

## Índice
- [Problemas de Configuración](#problemas-de-configuración)
- [Problemas con Firebase](#problemas-con-firebase)
- [Problemas de Compilación](#problemas-de-compilación)
- [Problemas de UI](#problemas-de-ui)
- [Problemas de Estado](#problemas-de-estado)
- [Problemas de Localización](#problemas-de-localización)
- [Problemas Responsive](#problemas-responsive)
- [Comandos Útiles](#comandos-útiles)

---

## Problemas de Configuración

### Error: SDK de Flutter no encontrado

**Síntoma:**
```
Flutter SDK not found
```

**Solución:**
```bash
# Verificar instalación
flutter --version

# Si no está instalado, instalar desde flutter.dev
# Agregar Flutter al PATH
export PATH="$PATH:`pwd`/flutter/bin"
```

### Error: Versión de Dart incompatible

**Síntoma:**
```
The current Dart SDK version is X.X.X
Because worshippro requires SDK version >=3.10.4
```

**Solución:**
```bash
# Actualizar Flutter (incluye Dart)
flutter upgrade

# Verificar versión
flutter --version
```

### Dependencias no instaladas

**Síntoma:**
```
Error: Cannot find package 'provider'
```

**Solución:**
```bash
# Limpiar y reinstalar
flutter clean
flutter pub get

# Si persiste
rm -rf .dart_tool
rm -rf build
rm pubspec.lock
flutter pub get
```

---

## Problemas con Firebase

### Error: Firebase no inicializado

**Síntoma:**
```
[core/no-app] No Firebase App '[DEFAULT]' has been created
```

**Solución:**
1. Verificar que `firebase_options.dart` existe en `lib/`
2. Verificar inicialización en `main.dart`:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

3. Regenerar configuración:
```bash
flutterfire configure
```

### Error: Configuración de Firebase faltante

**Síntoma:**
```
FirebaseOptions cannot be null
```

**Solución:**
```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar proyecto
flutterfire configure

# Seguir las instrucciones:
# 1. Seleccionar proyecto Firebase
# 2. Seleccionar plataformas (ios, android, web, etc.)
# 3. Archivo firebase_options.dart se genera automáticamente
```

### Error: Reglas de seguridad de Firestore

**Síntoma:**
```
[cloud_firestore/permission-denied] Missing or insufficient permissions
```

**Solución:**
1. Ir a Firebase Console → Firestore Database → Rules
2. Para desarrollo:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

3. Para producción, el proyecto usa reglas multi-tenant con aislamiento por organización.
   Despliega las reglas configuradas en `firestore.rules`:
```bash
firebase deploy --only firestore:rules
```

### Error: Plataforma no configurada

**Síntoma:**
```
No Firebase App for platform 'ios' has been configured
```

**Solución:**
```bash
# Reconfigurar incluyendo todas las plataformas
flutterfire configure

# Para iOS específicamente
cd ios
pod install
cd ..

# Para Android
cd android
./gradlew clean
cd ..
```

### Error: Conexión a Firestore falla

**Síntoma:**
- App se queda en loading infinito
- No se cargan datos

**Solución:**
1. Verificar conexión a internet
2. Verificar que proyecto Firebase está activo
3. Comprobar en Firebase Console que Firestore está habilitado
4. Verificar reglas de seguridad (ver arriba)

---

## Problemas de Compilación

### Error: Gradle sync failed (Android)

**Síntoma:**
```
FAILURE: Build failed with an exception
Could not resolve all dependencies
```

**Solución:**
```bash
# Limpiar cache de Gradle
cd android
./gradlew clean
cd ..

# Limpiar Flutter
flutter clean
flutter pub get

# Reconstruir
flutter build apk

# Si persiste, verificar versiones en android/build.gradle.kts
```

### Error: Pod install failed (iOS)

**Síntoma:**
```
CocoaPods not installed or not in valid state
```

**Solución:**
```bash
# Instalar CocoaPods
sudo gem install cocoapods

# Limpiar y reinstalar
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..

# Reconstruir
flutter clean
flutter pub get
flutter build ios
```

### Error: Xcode build failed (iOS)

**Síntoma:**
```
Error: No valid signing certificates found
```

**Solución:**
1. Abrir proyecto en Xcode: `open ios/Runner.xcworkspace`
2. Ir a Runner → Signing & Capabilities
3. Seleccionar equipo de desarrollo
4. Cambiar Bundle Identifier si es necesario

### Error: Android Studio no reconoce dispositivo

**Síntoma:**
```
No devices found
```

**Solución:**
```bash
# Verificar dispositivos conectados
flutter devices

# Para Android
adb devices

# Reiniciar ADB
adb kill-server
adb start-server

# Para iOS
xcrun simctl list

# Abrir simulador iOS
open -a Simulator
```

---

## Problemas de UI

### Bloques no se muestran después de agregar

**Síntoma:**
- Se agrega un bloque
- No aparece en la lista
- Hay que salir y volver para verlo

**Solución:**
Este problema ya está resuelto en la versión actual. Si persiste:

1. Verificar que después de crear/editar/eliminar se llama a:
```dart
await context.read<LiturgyProvider>().loadLiturgy(widget.liturgyId);
```

2. NO usar:
```dart
await liturgyProvider.refreshCurrentLiturgy(); // ❌ Viejo método
```

### Layout se desborda (overflow)

**Síntoma:**
```
RenderFlex overflowed by X pixels
```

**Solución:**
```dart
// Envolver en Expanded o Flexible
Column(
  children: [
    Flexible(  // o Expanded
      child: ListView(...),
    ),
  ],
)

// O usar SingleChildScrollView
SingleChildScrollView(
  child: Column(...),
)
```

### Diseño no responsive

**Síntoma:**
- UI se ve mal en tablet/desktop
- Elementos muy pequeños o grandes

**Solución:**
```dart
// Usar ResponsiveBuilder
ResponsiveBuilder(
  builder: (context, info) {
    return Container(
      padding: EdgeInsets.all(info.paddingValue), // Adaptativo
      child: Text(
        'Texto',
        style: TextStyle(fontSize: info.fontSizeFor(16)), // Escalado
      ),
    );
  },
)

// O ResponsiveLayout
ResponsiveLayout(
  mobile: MobileView(),
  tablet: TabletView(),
  desktop: DesktopView(),
)
```

### Diálogos no se traducen

**Síntoma:**
- UI está en español pero diálogos en inglés (o viceversa)

**Solución:**
```dart
// Siempre usar AppLocalizations
final l10n = AppLocalizations.of(context);

showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(l10n.confirmDelete), // ✅ Traducido
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(l10n.cancel),
      ),
    ],
  ),
);
```

---

## Problemas de Estado

### Estado no se actualiza

**Síntoma:**
- Se modifican datos en Firestore
- UI no se actualiza automáticamente

**Solución:**
```dart
// Asegurarse de usar Consumer o watch
Consumer<LiturgyProvider>(
  builder: (context, provider, child) {
    return ListView.builder(
      itemCount: provider.liturgies.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text(provider.liturgies[index].titulo));
      },
    );
  },
)

// O con context.watch
final provider = context.watch<LiturgyProvider>();
```

### Múltiples listeners creados

**Síntoma:**
```
Warning: Multiple listeners attached
```

**Solución:**
```dart
// Usar initState para iniciar listener una sola vez
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<LiturgyProvider>().initLiturgiesListener();
  });
}

// NO llamar initLiturgiesListener() múltiples veces
```

### Provider no encontrado

**Síntoma:**
```
Error: Could not find the correct Provider<LiturgyProvider>
```

**Solución:**
1. Verificar que Provider está en `main.dart`:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => OrganizationProvider()),
    ChangeNotifierProvider(create: (_) => LiturgyProvider()),
    ChangeNotifierProvider(create: (_) => BlockProvider()),
    ChangeNotifierProvider(create: (_) => LanguageProvider()),
  ],
  child: MyApp(),
)
```

2. No usar `context` antes de que widgets estén construidos:
```dart
// ❌ Incorrecto
final provider = context.read<LiturgyProvider>();

@override
Widget build(BuildContext context) {
  return Text('...');
}

// ✅ Correcto
@override
Widget build(BuildContext context) {
  final provider = context.read<LiturgyProvider>();
  return Text('...');
}
```

---

## Problemas de Localización

### Idioma no cambia

**Síntoma:**
- Se llama a `setLanguage()` pero UI permanece igual

**Solución:**
1. Verificar que `MaterialApp` usa `Consumer`:
```dart
Consumer<LanguageProvider>(
  builder: (context, langProvider, child) {
    return MaterialApp(
      locale: langProvider.locale, // ✅ Escucha cambios
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''),
        Locale('en', ''),
      ],
      // ...
    );
  },
)
```

2. Verificar `notifyListeners()` en LanguageProvider:
```dart
Future<void> setLocale(Locale locale) async {
  _locale = locale;
  await _saveLanguage(locale.languageCode);
  notifyListeners(); // ✅ Importante
}
```

### Traducciones faltantes

**Síntoma:**
```
NoSuchMethodError: The getter 'newKey' was called on null
```

**Solución:**
1. Agregar clave en `app_localizations.dart`:
```dart
class AppLocalizations {
  // En _localizedValues
  'newKey': {
    'es': 'Nuevo Texto',
    'en': 'New Text',
  },
  
  // Agregar getter
  String get newKey => _localizedValues['newKey']![locale.languageCode]!;
}
```

### Idioma no persiste al reiniciar app

**Síntoma:**
- Cambio de idioma funciona
- Al cerrar y abrir app vuelve al idioma por defecto

**Solución:**
```dart
// Verificar que LanguageProvider carga idioma guardado
class LanguageProvider extends ChangeNotifier {
  LanguageProvider() {
    _loadLanguage(); // ✅ Cargar en constructor
  }
  
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'es';
    _locale = Locale(languageCode);
    notifyListeners();
  }
}
```

---

## Problemas Responsive

### Breakpoints no funcionan correctamente

**Síntoma:**
- Tablet muestra UI de móvil
- Desktop muestra UI de tablet

**Solución:**
```dart
// Verificar breakpoints en responsive_utils.dart
class Breakpoints {
  static const double mobile = 600;    // < 600 = mobile
  static const double tablet = 1200;   // 600-1200 = tablet
                                       // > 1200 = desktop
}

// Usar correctamente
if (info.isMobile) {
  return MobileLayout();
} else if (info.isTablet) {
  return TabletLayout();
} else {
  return DesktopLayout();
}
```

### Orientación no detectada

**Síntoma:**
- UI no cambia al rotar dispositivo

**Solución:**
```dart
// Usar ResponsiveBuilder que escucha cambios de orientación
ResponsiveBuilder(
  builder: (context, info) {
    if (info.isPortrait) {
      return PortraitLayout();
    } else {
      return LandscapeLayout();
    }
  },
)

// O usar OrientationBuilder directamente
OrientationBuilder(
  builder: (context, orientation) {
    if (orientation == Orientation.portrait) {
      return PortraitView();
    } else {
      return LandscapeView();
    }
  },
)
```

---

## Comandos Útiles

### Limpieza completa
```bash
# Limpiar todo
flutter clean
rm -rf .dart_tool
rm -rf build
rm pubspec.lock

# Reinstalar
flutter pub get

# Para Android
cd android
./gradlew clean
cd ..

# Para iOS
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
```

### Verificación de dependencias
```bash
# Ver dependencias
flutter pub deps

# Verificar actualizaciones
flutter pub outdated

# Actualizar dependencias
flutter pub upgrade
```

### Debugging
```bash
# Ejecutar en modo debug
flutter run

# Ver logs
flutter logs

# Inspeccionar widgets
flutter run --dart-define=FLUTTER_WEB_USE_SKIA=true

# Modo verbose
flutter run -v
```

### Análisis de código
```bash
# Análisis estático
flutter analyze

# Formatear código
dart format .

# Verificar imports no usados
flutter pub run dart_code_metrics:metrics analyze lib

# Tests
flutter test
```

### Firebase
```bash
# Reconfigurar Firebase
flutterfire configure

# Ver proyectos disponibles
firebase projects:list

# Usar proyecto específico
firebase use <project-id>
```

### Build
```bash
# Android APK
flutter build apk

# Android Bundle (para Play Store)
flutter build appbundle

# iOS
flutter build ios

# Web
flutter build web

# macOS
flutter build macos

# Windows
flutter build windows

# Linux
flutter build linux
```

### Información del sistema
```bash
# Info completa
flutter doctor -v

# Verificar dispositivos
flutter devices

# Verificar emuladores
flutter emulators

# Lanzar emulador
flutter emulators --launch <emulator_id>
```

---

## Problemas Conocidos y Limitaciones

### Limitación: Descripción opcional en bloques existentes

**Situación:**
Bloques creados antes de v1.1 pueden tener descripción como string vacío en lugar de `null`.

**Solución:**
El código maneja ambos casos correctamente:
```dart
Text(block.descripcion ?? block.tipo.displayName)
```

### Limitación: Firestore offline

**Situación:**
Firestore no funciona completamente offline por defecto.

**Mejora futura:**
```dart
// Habilitar persistencia
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### Problema: DEVELOPER_ERROR al usar Google Sign-In

**Situación:**
Al intentar iniciar sesión con Google aparece `PlatformException(sign_in_failed, ... DEVELOPER_ERROR)`.

**Causa:** SHA-1 del certificado de debug no registrado en Firebase Console.

**Solución:**
1. Obtener SHA-1:
```bash
cd android && ./gradlew signingReport
```
2. Copiar el SHA-1 de la variante `debug`
3. Firebase Console → Project Settings → Android app → Add fingerprint
4. Re-descargar `google-services.json` y reemplazar en `android/app/`
5. `flutter clean && flutter run`

### Problema: Unable to resolve host firestore.googleapis.com

**Situación:**
La app no puede conectarse a Firestore y muestra `UnknownHostException`.

**Causa:** El dispositivo no tiene conexión a internet.

**Solución:** Verificar conexión WiFi o datos móviles del dispositivo.

---

## Obtener Ayuda

1. **Documentación interna:**
   - `ARCHITECTURE.md` — Arquitectura de la app (MVVM multi-tenant)
   - `API_REFERENCE.md` — Referencia de 8 modelos, 5 providers, 4 servicios
   - `FIREBASE_SETUP.md` — Configuración de Firebase Auth + Firestore
   - `FIRESTORE_STRUCTURE_V1.1.md` — Estructura multi-tenant de Firestore

2. **Logs detallados:**
```bash
flutter run -v > logs.txt 2>&1
```

3. **Flutter Doctor:**
```bash
flutter doctor -v
```

4. **Comunidad:**
   - [Flutter Documentation](https://docs.flutter.dev)
   - [Firebase Documentation](https://firebase.google.com/docs)
   - [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
