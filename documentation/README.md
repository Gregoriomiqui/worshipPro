# WorshipPro

> Aplicación móvil para crear, organizar y presentar liturgias de cultos cristianos

## 📚 Documentación Completa

Esta carpeta contiene toda la documentación necesaria para entender, desarrollar y mantener WorshipPro:

### 🚀 Para Empezar
- **[QUICKSTART.md](QUICKSTART.md)** - Instalación rápida y primeros pasos
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Resumen ejecutivo del proyecto

### 🏗️ Arquitectura y Desarrollo
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Arquitectura técnica detallada (MVVM, patrones, estructura)
- **[API_REFERENCE.md](API_REFERENCE.md)** - Referencia completa de APIs, modelos y métodos
- **[COMPONENT_GUIDE.md](COMPONENT_GUIDE.md)** - Guía de todos los widgets y componentes UI

### 🔧 Configuración y Utilidades
- **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** - Configuración completa de Firebase
- **[COMMANDS.md](COMMANDS.md)** - Referencia de comandos útiles de Flutter y Git

### 🐛 Mantenimiento
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Solución de problemas comunes
- **[CHANGELOG.md](CHANGELOG.md)** - Registro de cambios y versiones

---

## 🤖 Guía Rápida para Agentes IA

Si eres un agente de IA ayudando con este proyecto, sigue este flujo:

### Primer Contacto
1. **Lee primero:** [ARCHITECTURE.md](ARCHITECTURE.md) - Entiende la estructura MVVM, capas y flujo de datos
2. **Luego revisa:** [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - Contexto general del proyecto

### Durante el Desarrollo
- **Para implementar features:** [API_REFERENCE.md](API_REFERENCE.md) - Todos los Providers, Services y Modelos
- **Para UI/UX:** [COMPONENT_GUIDE.md](COMPONENT_GUIDE.md) - Widgets disponibles y guías de estilo
- **Para comandos:** [COMMANDS.md](COMMANDS.md) - Todos los comandos necesarios

### Solución de Problemas
- **Si hay errores:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Problemas comunes y soluciones
- **Para Firebase:** [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Configuración paso a paso

### Información Importante
- **Cambios recientes:** [CHANGELOG.md](CHANGELOG.md) - Últimas modificaciones

---

## 🎯 Descripción del Proyecto

**WorshipPro** es una aplicación Flutter diseñada específicamente para tablets, que permite a líderes de cultos cristianos crear y gestionar liturgias de forma simple y eficiente.

### Características principales

- ✅ **Gestión de liturgias**: Crea, edita y organiza liturgias completas
- ✅ **Bloques personalizables**: 9 tipos de bloques predefinidos (adoración, oración, reflexión, etc.)
- ✅ **Cálculo automático de duración**: La app suma automáticamente la duración de todos los bloques
- ✅ **Modo presentación**: Pantalla completa optimizada para presentar durante el culto
- ✅ **Canciones en adoración**: Agrega canciones con nombre, autor y tono
- ✅ **Persistencia con Firebase**: Todas las liturgias se guardan en Cloud Firestore
- ✅ **Diseño tablet-first**: Optimizado para tablets con tipografía grande y alto contraste

---

## 📁 Estructura del proyecto

```
lib/
├── main.dart                          # Punto de entrada de la aplicación
├── firebase_options.dart              # Configuración de Firebase (placeholder)
│
├── models/                            # Modelos de datos
│   ├── block_type.dart                # Enum de tipos de bloques
│   ├── liturgy.dart                   # Modelo de liturgia
│   ├── liturgy_block.dart             # Modelo de bloque
│   └── song.dart                      # Modelo de canción
│
├── services/                          # Servicios
│   └── liturgy_service.dart           # Servicio de Firebase/Firestore
│
├── providers/                         # Gestión de estado (Provider)
│   ├── liturgy_provider.dart          # Provider de liturgias
│   └── block_provider.dart            # Provider de bloques
│
├── screens/                           # Pantallas principales
│   ├── liturgy_list_screen.dart       # Listado de liturgias
│   ├── liturgy_editor_screen.dart     # Editor de liturgia
│   └── presentation_mode_screen.dart  # Modo presentación
│
├── widgets/                           # Widgets compartidos
│   └── common_widgets.dart            # Widgets comunes (Loading, Empty, Error, etc.)
│
└── theme/                             # Tema de la aplicación
    └── app_theme.dart                 # Definición de colores y estilos
```

---

## 🔥 Estructura de Firestore

### Colección: `liturgias`

```
liturgias (colección)
├── {liturgyId} (documento)
│   ├── titulo: string
│   ├── fecha: timestamp
│   ├── descripcion: string?
│   ├── createdAt: timestamp
│   ├── updatedAt: timestamp
│   │
│   └── bloques (subcolección)
│       ├── {blockId} (documento)
│       │   ├── tipo: string (enum: adoracionAlabanza, oracion, etc.)
│       │   ├── descripcion: string
│       │   ├── responsables: array<string>
│       │   ├── comentarios: string?
│       │   ├── duracionMinutos: number
│       │   ├── orden: number
│       │   │
│       │   └── canciones (subcolección) // Solo para bloques de tipo "adoracionAlabanza"
│       │       └── {songId} (documento)
│       │           ├── nombre: string
│       │           ├── autor: string?
│       │           └── tono: string?
```

---

## 🚀 Instalación y configuración

### Requisitos previos

- Flutter SDK (>=3.10.4)
- Cuenta de Firebase
- Android Studio o Xcode (para emuladores/simuladores)

### Paso 1: Clonar el repositorio

```bash
cd worshippro
```

### Paso 2: Instalar dependencias

```bash
flutter pub get
```

### Paso 3: Configurar Firebase

#### Opción A: Usar FlutterFire CLI (Recomendado)

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase para tu proyecto
flutterfire configure
```

Esto generará automáticamente el archivo `firebase_options.dart` con tu configuración.

#### Opción B: Configuración manual

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto
3. Habilita **Cloud Firestore**
4. Agrega aplicaciones:
   - **Android**: Descarga `google-services.json` y colócalo en `android/app/`
   - **iOS**: Descarga `GoogleService-Info.plist` y colócalo en `ios/Runner/`
   - **Web**: Copia la configuración web

### Paso 4: Ejecutar la aplicación

```bash
# Para Android
flutter run -d android

# Para iOS
flutter run -d ios

# Para web
flutter run -d chrome
```

---

## 📱 Pantallas de la aplicación

### 1. Listado de liturgias

Muestra todas las liturgias creadas, ordenadas por fecha. Incluye:
- Título y fecha de cada liturgia
- Duración total calculada
- Número de bloques
- Botón para crear nueva liturgia
- Botón para eliminar liturgia

### 2. Editor de liturgia

Interfaz dividida en dos paneles:

**Panel izquierdo**: Información básica
- Título del culto
- Fecha
- Descripción opcional
- **Duración total** (calculada automáticamente)

**Panel derecho**: Gestión de bloques
- Lista de bloques reordenables (drag & drop)
- Agregar, editar y eliminar bloques
- Ver detalles: tipo, descripción, duración, responsables
- Agregar canciones (solo en bloques de adoración)

### 3. Modo presentación

Pantalla completa optimizada para presentar durante el culto:
- **Bloque actual**: Mostrado con tipografía grande y alto contraste
- **Bloque siguiente**: Vista previa en la parte inferior
- **Duración total del culto**: Visible en el header
- **Controles de navegación**: Botones para avanzar/retroceder
- **Información detallada**: Responsables, canciones, comentarios

---

## 🧩 Tipos de bloques disponibles

| Tipo | Descripción |
|------|-------------|
| **Adoración y alabanza** | Tiempo de música y canciones (permite agregar canciones) |
| **Oración** | Momentos de oración congregacional o dirigida |
| **Reflexión** | Lectura bíblica, meditación o predicación |
| **Acción de gracias** | Testimonios o momentos de gratitud |
| **Ofrendas** | Tiempo de ofrenda |
| **Anuncios** | Comunicaciones e información |
| **Saludos** | Bienvenida o saludo fraternal |
| **Despedida** | Bendición final |
| **Otros** | Cualquier otro tipo de actividad |

---

## 🎨 Personalización

### Cambiar colores del tema

Edita `lib/theme/app_theme.dart`:

```dart
static const Color primaryColor = Color(0xFF6366F1); // Indigo
static const Color secondaryColor = Color(0xFF8B5CF6); // Violeta
```

### Agregar nuevos tipos de bloques

Edita `lib/models/block_type.dart`:

```dart
enum BlockType {
  // ... existentes
  tuNuevoTipo('Tu nuevo tipo'),
}
```

---

## 🔒 Reglas de seguridad de Firestore

Para producción, configura reglas de seguridad apropiadas en Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir lectura y escritura a todas las liturgias (ajustar según necesidad)
    match /liturgias/{liturgyId} {
      allow read, write: if true; // Cambiar según autenticación
      
      match /bloques/{blockId} {
        allow read, write: if true;
        
        match /canciones/{songId} {
          allow read, write: if true;
        }
      }
    }
  }
}
```

⚠️ **Nota**: Las reglas anteriores son permisivas para desarrollo. En producción, implementa autenticación y reglas más restrictivas.

---

## 📦 Dependencias principales

| Paquete | Propósito |
|---------|-----------|
| `firebase_core` | Inicialización de Firebase |
| `cloud_firestore` | Base de datos NoSQL en la nube |
| `provider` | Gestión de estado |
| `intl` | Internacionalización y formato de fechas |
| `uuid` | Generación de IDs únicos |

---

## 🛣️ Roadmap (Futuras mejoras)

- [ ] Autenticación de usuarios
- [ ] Sincronización offline
- [ ] Exportar liturgias a PDF
- [ ] Compartir liturgias entre usuarios
- [ ] Temas oscuros
- [ ] Soporte multiidioma
- [ ] Historial de versiones de liturgias
- [ ] Plantillas de liturgias predefinidas

---

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

---

**¡Que Dios bendiga tu ministerio!** 🙏

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
