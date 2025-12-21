/// Tipos de bloques disponibles para la liturgia
enum BlockType {
  adoracionAlabanza('Adoración y alabanza'),
  oracion('Oración'),
  reflexion('Reflexión'),
  accionGracias('Acción de gracias'),
  ofrendas('Ofrendas'),
  anuncios('Anuncios'),
  saludos('Saludos'),
  despedida('Despedida'),
  otros('Otros');

  const BlockType(this.displayName);
  
  final String displayName;
}
