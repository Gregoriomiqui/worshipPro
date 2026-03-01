# 🔥 Estructura de Firestore - Versión 1.1 (Multi-tenant)

## 📊 Diagrama de Colecciones

```
firestore (root)
│
├── users (collection)
│   └── {userId} (document)
│       ├── email: string
│       ├── displayName: string
│       ├── photoURL: string (optional)
│       ├── organizationIds: array<string>  // IDs de organizaciones a las que pertenece
│       ├── activeOrganizationId: string    // Organización actualmente seleccionada
│       ├── authProviders: array<string>    // ["password", "google.com"]
│       ├── createdAt: timestamp
│       └── updatedAt: timestamp
│
├── organizations (collection)
│   └── {organizationId} (document)
│       ├── nombre: string
│       ├── descripcion: string (optional)
│       ├── createdBy: string              // userId del creador
│       ├── createdAt: timestamp
│       ├── updatedAt: timestamp
│       │
│       ├── members (subcollection)
│       │   └── {userId} (document)
│       │       ├── email: string
│       │       ├── displayName: string
│       │       ├── role: string           // "admin" | "member"
│       │       ├── joinedAt: timestamp
│       │       └── invitedBy: string (optional)
│       │
│       └── liturgias (subcollection)
│           └── {liturgyId} (document)
│               ├── titulo: string
│               ├── fecha: timestamp
│               ├── hora: string (optional)         // Hora del culto (ej: "10:00")
│               ├── descripcion: string (optional)
│               ├── createdBy: string
│               ├── createdAt: timestamp
│               ├── updatedAt: timestamp
│               │
│               └── bloques (subcollection)
│                   └── {blockId} (document)
│                       ├── tipo: string
│                       ├── descripcion: string
│                       ├── responsables: array<string>
│                       ├── comentarios: string (optional)
│                       ├── duracionMinutos: number
│                       ├── orden: number
│                       │
│                       └── canciones (subcollection)
│                           └── {songId} (document)
│                               ├── nombre: string
│                               ├── autor: string (optional)
│                               ├── tono: string (optional)
│                               └── orden: number
│
└── invitations (collection)
    └── {invitationId} (document)
        ├── organizationId: string
        ├── organizationName: string
        ├── email: string                  // Email del invitado
        ├── role: string                   // "admin" | "member"
        ├── invitedBy: string              // userId del invitador
        ├── invitedByName: string
        ├── status: string                 // "pending" | "accepted" | "rejected"
        ├── createdAt: timestamp
        └── expiresAt: timestamp (optional)
```

## 🔑 Cambios Clave vs v1.0

### 1. Nueva Colección `users`
- Almacena información del usuario autenticado
- **`organizationIds`**: Array de IDs de organizaciones a las que pertenece
- **`activeOrganizationId`**: Organización actualmente activa (UI context)
- **`authProviders`**: Lista de métodos de autenticación vinculados

### 2. Nueva Colección `organizations`
- Representa cada iglesia/organización
- **Creador automáticamente es Admin**
- Las `liturgias` ahora son **subcollection de organizations**

### 3. Subcollection `members`
- Dentro de cada organización
- Roles: `admin` (gestión completa) | `member` (lectura/escritura liturgias)
- Admins pueden agregar/eliminar miembros

### 4. Nueva Colección `invitations`
- Sistema de invitaciones por email
- Estados: `pending`, `accepted`, `rejected`
- Se puede configurar **Trigger Email Extension** para notificar automáticamente

## 🔐 Reglas de Seguridad

### Principios
1. **Autenticación obligatoria**: Todas las operaciones requieren `request.auth != null`
2. **Aislamiento de organizaciones**: Usuario solo accede a datos de sus organizaciones
3. **Control de roles**: Admins tienen permisos extendidos

### Helpers
```javascript
function isMemberOf(organizationId) {
  return organizationId in getUserData().organizationIds;
}

function isAdminOf(organizationId) {
  return get(/databases/$(database)/documents/organizations/$(organizationId)/members/$(request.auth.uid)).data.role == 'admin';
}
```

### Ejemplos de Uso

#### Usuario lee sus datos
```javascript
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}
```

#### Usuario lee liturgias de su organización
```javascript
match /organizations/{organizationId}/liturgias/{liturgyId} {
  allow read, write: if isMemberOf(organizationId);
}
```

#### Solo admins pueden agregar miembros
```javascript
match /organizations/{organizationId}/members/{memberId} {
  allow create, update, delete: if isAdminOf(organizationId);
}
```

## 📧 Sistema de Invitaciones

### Flujo Completo

1. **Admin invita usuario**:
   ```dart
   // OrganizationService.inviteMember(email)
   FirebaseFirestore.instance.collection('invitations').add({
     'organizationId': orgId,
     'email': email,
     'invitedBy': currentUserId,
     'status': 'pending',
     ...
   });
   ```

2. **Trigger Email Extension** (Firebase):
   - Detecta nuevo documento en `invitations`
   - Envía email automático con link de invitación
   - Configuración: [Firebase Console > Extensions > Trigger Email]

3. **Usuario acepta invitación**:
   ```dart
   // Usuario entra a la app y ve invitaciones pendientes
   // Al aceptar:
   // 1. Se agrega a organizations/{orgId}/members/{userId}
   // 2. Se actualiza users/{userId}.organizationIds
   // 3. Se marca invitations/{invId}.status = 'accepted'
   ```

## 🔄 Migración de Datos v1.0 → v1.1

### Script de Migración (Pseudo-código)

```dart
Future<void> migrateToMultiTenant() async {
  // 1. Crear organización por defecto
  final defaultOrg = await createOrganization(
    nombre: "Mi Iglesia",
    createdBy: "SYSTEM",
  );

  // 2. Mover liturgias existentes a la nueva estructura
  final oldLiturgies = await firestore.collection('liturgias').get();
  
  for (var doc in oldLiturgies.docs) {
    await firestore
      .collection('organizations')
      .doc(defaultOrg.id)
      .collection('liturgias')
      .doc(doc.id)
      .set(doc.data());
      
    // Copiar subcollections (bloques, canciones)...
  }

  // 3. Eliminar colección antigua (opcional)
  // await deleteCollection('liturgias');
}
```

## 🚀 Consultas Comunes

### Obtener liturgias de la organización activa
```dart
final user = await userDoc.get();
final activeOrgId = user.data()['activeOrganizationId'];

final liturgiesSnapshot = await firestore
  .collection('organizations')
  .doc(activeOrgId)
  .collection('liturgias')
  .orderBy('fecha', descending: true)
  .get();
```

### Obtener todas las organizaciones del usuario
```dart
final user = await userDoc.get();
final orgIds = List<String>.from(user.data()['organizationIds']);

final orgs = await Future.wait(
  orgIds.map((id) => firestore.collection('organizations').doc(id).get())
);
```

### Verificar si usuario es admin
```dart
final memberDoc = await firestore
  .collection('organizations')
  .doc(orgId)
  .collection('members')
  .doc(userId)
  .get();

final isAdmin = memberDoc.data()?['role'] == 'admin';
```

## ⚠️ Consideraciones Importantes

1. **Índices compuestos**: Firestore puede requerir índices para consultas completas
2. **Límites de lectura**: Verificar members antes de queries grandes
3. **Caché offline**: Configurar persistencia para mejor UX
4. **Validación de emails**: Verificar formato antes de crear invitaciones
5. **Expiración de invitaciones**: Considerar TTL de 7 días

## 📚 Referencias

- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Multi-tenancy Patterns](https://firebase.google.com/docs/firestore/solutions/role-based-access)
- [Trigger Email Extension](https://extensions.dev/extensions/firebase/firestore-send-email)
