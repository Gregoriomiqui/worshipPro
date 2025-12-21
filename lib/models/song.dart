/// Modelo para representar una canción en el bloque de adoración
class Song {
  final String id;
  final String nombre;
  final String? autor;
  final String? tono;

  Song({
    required this.id,
    required this.nombre,
    this.autor,
    this.tono,
  });

  /// Crea una canción desde un mapa de datos
  factory Song.fromMap(Map<String, dynamic> map, String id) {
    return Song(
      id: id,
      nombre: map['nombre'] as String? ?? '',
      autor: map['autor'] as String?,
      tono: map['tono'] as String?,
    );
  }

  /// Convierte la canción a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'autor': autor,
      'tono': tono,
    };
  }

  /// Crea una copia de la canción con valores opcionales actualizados
  Song copyWith({
    String? id,
    String? nombre,
    String? autor,
    String? tono,
  }) {
    return Song(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      autor: autor ?? this.autor,
      tono: tono ?? this.tono,
    );
  }
}
