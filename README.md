# ⛪ WorshipPro

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.10.4+-02569B?style=for-the-badge&logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart)
![License](https://img.shields.io/badge/License-Private-red?style=for-the-badge)

**Aplicación móvil profesional para crear, organizar y presentar liturgias de cultos cristianos**

[Características](#-características) • [Instalación](#-instalación-rápida) • [Documentación](#-documentación) • [Arquitectura](#️-arquitectura) • [Capturas](#-capturas-de-pantalla)

</div>

---

## 📖 Descripción

**WorshipPro** es una aplicación Flutter diseñada específicamente para tablets que permite a líderes de cultos cristianos crear, gestionar y presentar liturgias de forma profesional y eficiente. Con una interfaz intuitiva y optimizada para tablets, la aplicación facilita la planificación de servicios religiosos desde la preparación hasta la presentación en vivo.

### 🎯 ¿Para quién es esta aplicación?

- 🎤 **Pastores y líderes de alabanza** que planifican servicios religiosos
- ⛪ **Iglesias cristianas** que buscan digitalizar su planificación litúrgica
- 📱 **Equipos técnicos** que manejan presentaciones durante los cultos
- 👥 **Comités de liturgia** que coordinan múltiples servicios

---

## ✨ Características

### 🎼 Gestión Completa de Liturgias
- ✅ Crear y editar liturgias con información detallada (título, fecha, descripción)
- ✅ Organizar bloques de contenido con drag & drop (reordenamiento intuitivo)
- ✅ Cálculo automático de duración total del servicio
- ✅ Guardado automático en la nube con Firebase Firestore
- ✅ Duplicación de liturgias con sufijo incremental

### 🎵 Gestión de Canciones de Adoración
- ✅ Agregar canciones a bloques de adoración y alabanza (obligatorio)
- ✅ Registro de nombre, autor y tono musical (notación americana: C, D#, Eb, etc.)
- ✅ Reordenamiento de canciones dentro de cada bloque
- ✅ Visualización de cantidad de canciones en cada bloque

### 📋 9 Tipos de Bloques Predefinidos
- 🙏 **Adoración y Alabanza** - Con gestión de canciones
- 🤲 **Oración** - Momentos de oración dirigida
- 📖 **Reflexión/Sermón** - Mensaje principal
- 🙌 **Acción de Gracias** - Bendiciones y agradecimientos
- 💰 **Ofrendas** - Momento de ofrenda
- 📢 **Anuncios** - Comunicados y avisos
- 👋 **Saludos** - Bienvenida y presentación
- 🚪 **Despedida** - Cierre del servicio
- 📝 **Otros** - Bloques personalizados

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
- 🔥 **Firebase Firestore** como backend
- 💾 **Sincronización automática** en tiempo real
- 🔒 **Estructura segura** con colecciones y subcolecciones
- 📊 **Backup automático** en la nube

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

#### Opción A: FlutterFire CLI (Recomendado)

```bash
# Instalar FlutterFire CLI (solo una vez)
dart pub global activate flutterfire_cli

# Configurar Firebase automáticamente
flutterfire configure

# Selecciona o crea un proyecto de Firebase
# Selecciona las plataformas: Android, iOS, Web
# Se generará automáticamente firebase_options.dart
```

#### Opción B: Manual

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto "WorshipPro"
3. Habilita **Firestore Database** en modo prueba
4. Descarga archivos de configuración:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`

### Paso 3: Configurar Firestore

En Firebase Console:
1. Ve a **Firestore Database**
2. Click en **Crear base de datos**
3. Selecciona **Modo de prueba** (para desarrollo)
4. Elige ubicación cercana (us-central1, southamerica-east1, etc.)

### Paso 4: Ejecutar

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

### 1. Lista de Liturgias
- **Ver** todas las liturgias creadas en grid/list adaptativo
- **Crear** nueva liturgia con el botón flotante (+)
- **Eliminar** deslizando hacia la izquierda (móvil) o click en icono papelera
- **Duplicar** mediante menú contextual (long press o click derecho)

### 2. Editor de Liturgia
- **Información básica**: Título, fecha y descripción (se guarda automáticamente)
- **Gestión de bloques**: Agregar, editar, reordenar y eliminar bloques
- **Drag & drop**: Arrastra bloques para reordenar
- **Canciones**: Para bloques de adoración, agrega canciones con tono musical

### 3. Bloques de Adoración
- Las canciones son **obligatorias** (debe haber al menos una)
- Cada canción tiene: **nombre**, **autor** (opcional), **tono** (C, D#, Eb, etc.)
- Puedes **reordenar** canciones arrastrándolas
- El tono se selecciona con un **dropdown** de notación americana

### 4. Modo Presentación
- Click en el icono de presentación (🎥) desde el editor
- Navega con flechas o gestos
- Muestra bloque actual con información detallada
- Preview del siguiente bloque
- Salir con botón X o ESC

---

## 🏗️ Arquitectura

### Patrón MVVM + Provider

```
┌─────────────────────────────────────────────────┐
│                    View Layer                    │
│         (Screens + Widgets + UI Logic)          │
│  liturgy_list_screen | liturgy_editor_screen    │
└───────────────┬─────────────────────────────────┘
                │ notifyListeners()
                ↓
┌─────────────────────────────────────────────────┐
│                ViewModel Layer                   │
│              (State Management)                  │
│    LiturgyProvider | BlockProvider | LanguageP  │
└───────────────┬─────────────────────────────────┘
                │ async calls
                ↓
┌─────────────────────────────────────────────────┐
│                 Service Layer                    │
│              (Business Logic)                    │
│            LiturgyService (CRUD)                 │
└───────────────┬─────────────────────────────────┘
                │ Firebase SDK
                ↓
┌─────────────────────────────────────────────────┐
│                  Data Layer                      │
│                (Firebase Firestore)              │
│         liturgias > bloques > canciones          │
└─────────────────────────────────────────────────┘
```

### Estructura del Proyecto

```
lib/
├── main.dart                      # Punto de entrada, configuración inicial
├── firebase_options.dart          # Configuración de Firebase
│
├── l10n/                          # Internacionalización
│   └── app_localizations.dart     # Sistema de traducciones ES/EN
│
├── models/                        # Modelos de datos (Plain Dart Objects)
│   ├── block_type.dart            # Enum: 9 tipos de bloques
│   ├── liturgy.dart               # Modelo: Culto completo
│   ├── liturgy_block.dart         # Modelo: Bloque de liturgia
│   └── song.dart                  # Modelo: Canción (nombre, autor, tono)
│
├── providers/                     # Gestión de estado (ChangeNotifier)
│   ├── block_provider.dart        # Estado: Bloques y canciones
│   ├── language_provider.dart     # Estado: Idioma seleccionado
│   └── liturgy_provider.dart      # Estado: Liturgias (CRUD)
│
├── services/                      # Lógica de negocio
│   └── liturgy_service.dart       # Servicio: Firestore CRUD operations
│
├── screens/                       # Pantallas principales
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

## 🔥 Estructura de Firestore

```
firestore
└── liturgias (collection)
    └── {liturgyId} (document)
        ├── titulo: string
        ├── fecha: timestamp
        ├── descripcion: string (optional)
        ├── createdAt: timestamp
        ├── updatedAt: timestamp
        │
        └── bloques (subcollection)
            └── {blockId} (document)
                ├── tipo: string (adoracionAlabanza, oracion, etc.)
                ├── descripcion: string
                ├── responsables: array<string>
                ├── comentarios: string (optional)
                ├── duracionMinutos: number
                ├── orden: number
                │
                └── canciones (subcollection) 
                    └── {songId} (document)   // Solo en bloques de adoración
                        ├── nombre: string
                        ├── autor: string (optional)
                        ├── tono: string (optional)
                        └── orden: number
```

### Reglas de Seguridad de Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Liturgias
    match /liturgias/{liturgyId} {
      allow read, write: if true; // Modo desarrollo
      
      // Bloques
      match /bloques/{blockId} {
        allow read, write: if true;
        
        // Canciones
        match /canciones/{songId} {
          allow read, write: if true;
        }
      }
    }
  }
}
```

> ⚠️ **Importante**: En producción, implementar reglas de seguridad con autenticación

---

## 📦 Dependencias Principales

```yaml
dependencies:
  # Framework
  flutter_sdk: ^3.10.4
  
  # Firebase
  firebase_core: ^3.10.0       # Core de Firebase
  cloud_firestore: ^5.6.0      # Base de datos NoSQL
  
  # Estado
  provider: ^6.1.2             # Gestión de estado (MVVM)
  
  # UI/UX
  intl: ^0.20.1                # Internacionalización y formato de fechas
  cupertino_icons: ^1.0.8      # Iconos iOS
  
  # Utilidades
  uuid: ^4.5.1                 # Generación de IDs únicos
  shared_preferences: ^2.3.3   # Persistencia local (idioma)
  
  # Localización
  flutter_localizations:       # Localización de Flutter
    sdk: flutter
```

---

## 📚 Documentación

La aplicación cuenta con documentación completa en la carpeta [`documentation/`](documentation/):

### 🚀 Inicio Rápido
- **[QUICKSTART.md](documentation/QUICKSTART.md)** - Guía de instalación en 10 minutos
- **[PROJECT_SUMMARY.md](documentation/PROJECT_SUMMARY.md)** - Resumen ejecutivo

### 🏗️ Desarrollo
- **[ARCHITECTURE.md](documentation/ARCHITECTURE.md)** - Arquitectura técnica detallada
- **[API_REFERENCE.md](documentation/API_REFERENCE.md)** - Referencia completa de APIs
- **[COMPONENT_GUIDE.md](documentation/COMPONENT_GUIDE.md)** - Guía de widgets y componentes

### 🔧 Configuración
- **[FIREBASE_SETUP.md](documentation/FIREBASE_SETUP.md)** - Setup completo de Firebase
- **[COMMANDS.md](documentation/COMMANDS.md)** - Comandos útiles de Flutter

### 🐛 Mantenimiento
- **[TROUBLESHOOTING.md](documentation/TROUBLESHOOTING.md)** - Solución de problemas
- **[CHANGELOG.md](documentation/CHANGELOG.md)** - Historial de cambios

---

## 🎨 Capturas de Pantalla

### Lista de Liturgias
Vista responsive con grid adaptativo que muestra todas las liturgias creadas con información resumida (fecha, duración, cantidad de bloques).

### Editor de Liturgia
Panel dual en tablets/desktop con información básica a la izquierda y gestión de bloques a la derecha. Auto-guardado en tiempo real.

### Bloques de Adoración
Modal responsive con lista de canciones, drag & drop para reordenar, y dropdown con notación americana para tonos musicales.

### Modo Presentación
Pantalla completa optimizada para proyección con bloque actual destacado y preview del siguiente bloque.

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

# Actualizar dependencias
flutter pub upgrade
```

### Convenios de Código

- ✅ **Dart style guide** oficial
- ✅ **Null safety** habilitado
- ✅ **Comentarios en español** para claridad del equipo
- ✅ **Nombres descriptivos** en español (variables, métodos, clases)
- ✅ **Provider pattern** para gestión de estado
- ✅ **Separación de responsabilidades** (MVVM)

### Testing

```bash
# Ejecutar todos los tests
flutter test

# Tests con coverage
flutter test --coverage

# Ver coverage en HTML
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 🤝 Contribución

### Flujo de Trabajo

1. Fork el proyecto
2. Crea una rama feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add: Amazing feature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

### Convenciones de Commits

```
feat: Nueva funcionalidad
fix: Corrección de bug
docs: Cambios en documentación
style: Formato, puntos y comas, etc
refactor: Refactorización de código
test: Agregar o modificar tests
chore: Cambios en build, dependencias, etc
```

---

## 🐛 Problemas Conocidos y Soluciones

### Error: "Firebase not initialized"
```bash
# Asegúrate de ejecutar primero
flutterfire configure
```

### Error: "PlatformException with Firestore"
```bash
# Limpia y reinstala
flutter clean
flutter pub get
flutter run
```

### Error de compilación en iOS
```bash
cd ios
pod install
cd ..
flutter run
```

---

## 📄 Licencia

Este proyecto es privado y de uso interno.

---

## 👨‍💻 Autor

**Jose Miquilena**  
📧 Email: [tu-email@example.com](mailto:tu-email@example.com)  
🔗 GitHub: [@josemiquilena](https://github.com/josemiquilena)

---

## 🙏 Agradecimientos

- **Flutter Team** por el excelente framework
- **Firebase** por la infraestructura backend
- **Comunidad Flutter** por los packages y soporte

---

## 🗺️ Roadmap

### v1.1 (Próxima versión)
- [ ] Autenticación de usuarios con Firebase Auth
- [ ] Compartir liturgias entre usuarios
- [ ] Exportar liturgias a PDF
- [ ] Plantillas de liturgias predefinidas

### v1.2
- [ ] Modo offline con sincronización
- [ ] Búsqueda y filtros avanzados
- [ ] Estadísticas de uso
- [ ] Temas personalizables (light/dark)

### v2.0
- [ ] Aplicación web completa
- [ ] API REST para integraciones
- [ ] Sistema de roles y permisos
- [ ] Calendario de liturgias

---

## 📞 Soporte

¿Tienes preguntas o problemas?

1. 📖 Revisa la [documentación](documentation/)
2. 🐛 Revisa [issues existentes](../../issues)
3. 💬 Crea un [nuevo issue](../../issues/new)
4. 📧 Contacta al desarrollador

---

<div align="center">

**Hecho con ❤️ y ☕ por Jose Miquilena**

⭐ Si te gusta el proyecto, dale una estrella

</div>
