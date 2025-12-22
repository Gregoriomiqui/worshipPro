import 'package:flutter/material.dart';

/// Clase para manejar las traducciones de la aplicación
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('es', ''),
    Locale('en', ''),
  ];

  // Mapa de traducciones
  static final Map<String, Map<String, String>> _localizedValues = {
    'es': {
      // General
      'appTitle': 'WorshipPro',
      'loading': 'Cargando...',
      'error': 'Error',
      'cancel': 'Cancelar',
      'delete': 'Eliminar',
      'save': 'Guardar',
      'edit': 'Editar',
      'add': 'Agregar',
      'search': 'Buscar',
      'settings': 'Configuración',
      'language': 'Idioma',
      'spanish': 'Español',
      'english': 'Inglés',
      
      // Lista de cultos
      'liturgiesList': 'Mis Cultos',
      'noLiturgies': 'No hay cultos',
      'noLiturgiesDesc': 'Crea tu primer culto usando el botón + de abajo',
      'createLiturgy': 'Crear Culto',
      'blocks': 'bloques',
      'minutes': 'min',
      
      // Editor de culto
      'newLiturgy': 'Nuevo Culto',
      'editLiturgy': 'Editar Culto',
      'liturgyInfo': 'Información',
      'liturgyBlocks': 'Bloques',
      'title': 'Título',
      'date': 'Fecha',
      'addBlock': 'Agregar Bloque',
      'noBlocks': 'No hay bloques',
      'noBlocksDesc': 'Agrega bloques para estructurar tu culto',
      'totalDuration': 'Duración total',
      
      // Bloques
      'blockType': 'Tipo de bloque',
      'description': 'Descripción',
      'duration': 'Duración (minutos)',
      'responsible': 'Responsables',
      'responsibleHint': 'Separar con comas',
      'comments': 'Comentarios',
      'addSong': 'Agregar Canción',
      
      // Tipos de bloque
      'welcome': 'Bienvenida',
      'worship': 'Adoración',
      'prayer': 'Oración',
      'bibleReading': 'Lectura Bíblica',
      'sermon': 'Predicación',
      'offering': 'Ofrenda',
      'communion': 'Santa Cena',
      'announcement': 'Anuncios',
      'blessing': 'Bendición',
      'other': 'Otro',
      
      // Canciones
      'songName': 'Nombre de la canción',
      'key': 'Tono',
      'songs': 'Canciones',
      'noSongs': 'No hay canciones',
      
      // Modo presentación
      'presentationMode': 'Modo presentación',
      'next': 'Siguiente',
      'previous': 'Anterior',
      'exit': 'Salir',
      
      // Diálogos
      'confirmDelete': '¿Estás seguro?',
      'confirmDeleteLiturgy': '¿Deseas eliminar este culto?',
      'confirmDeleteBlock': '¿Deseas eliminar este bloque?',
      'confirmDeleteSong': '¿Deseas eliminar esta canción?',
      
      // Errores
      'errorLoadingLiturgies': 'Error al cargar los cultos',
      'errorSavingLiturgy': 'Error al guardar el culto',
      'errorDeletingLiturgy': 'Error al eliminar el culto',
      'liturgyDeletedSuccess': 'Culto eliminado correctamente',
      'liturgyCreatedSuccess': 'Culto creado correctamente',
      'liturgyUpdatedSuccess': 'Culto actualizado correctamente',
      'fillRequiredFields': 'Por favor completa todos los campos requeridos',
    },
    'en': {
      // General
      'appTitle': 'WorshipPro',
      'loading': 'Loading...',
      'error': 'Error',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'save': 'Save',
      'edit': 'Edit',
      'add': 'Add',
      'search': 'Search',
      'settings': 'Settings',
      'language': 'Language',
      'spanish': 'Spanish',
      'english': 'English',
      
      // Lista de liturgias
      'liturgiesList': 'My Liturgies',
      'noLiturgies': 'No liturgies',
      'noLiturgiesDesc': 'Create your first liturgy using the + button below',
      'createLiturgy': 'Create Liturgy',
      'blocks': 'blocks',
      'minutes': 'min',
      
      // Editor de liturgia
      'newLiturgy': 'New Liturgy',
      'editLiturgy': 'Edit Liturgy',
      'liturgyInfo': 'Information',
      'liturgyBlocks': 'Blocks',
      'title': 'Title',
      'date': 'Date',
      'addBlock': 'Add Block',
      'noBlocks': 'No blocks',
      'noBlocksDesc': 'Add blocks to structure your liturgy',
      'totalDuration': 'Total duration',
      
      // Bloques
      'blockType': 'Block type',
      'description': 'Description',
      'duration': 'Duration (minutes)',
      'responsible': 'Responsible',
      'responsibleHint': 'Separate with commas',
      'comments': 'Comments',
      'addSong': 'Add Song',
      
      // Tipos de bloque
      'welcome': 'Welcome',
      'worship': 'Worship',
      'prayer': 'Prayer',
      'bibleReading': 'Bible Reading',
      'sermon': 'Sermon',
      'offering': 'Offering',
      'communion': 'Communion',
      'announcement': 'Announcements',
      'blessing': 'Blessing',
      'other': 'Other',
      
      // Canciones
      'songName': 'Song name',
      'key': 'Key',
      'songs': 'Songs',
      'noSongs': 'No songs',
      
      // Modo presentación
      'presentationMode': 'Presentation mode',
      'next': 'Next',
      'previous': 'Previous',
      'exit': 'Exit',
      
      // Diálogos
      'confirmDelete': 'Are you sure?',
      'confirmDeleteLiturgy': 'Do you want to delete this liturgy?',
      'confirmDeleteBlock': 'Do you want to delete this block?',
      'confirmDeleteSong': 'Do you want to delete this song?',
      
      // Errores
      'errorLoadingLiturgies': 'Error loading liturgies',
      'errorSavingLiturgy': 'Error saving liturgy',
      'errorDeletingLiturgy': 'Error deleting liturgy',
      'liturgyDeletedSuccess': 'Liturgy deleted successfully',
      'liturgyCreatedSuccess': 'Liturgy created successfully',
      'liturgyUpdatedSuccess': 'Liturgy updated successfully',
      'fillRequiredFields': 'Please fill in all required fields',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Getters convenientes
  String get appTitle => translate('appTitle');
  String get loading => translate('loading');
  String get error => translate('error');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get save => translate('save');
  String get edit => translate('edit');
  String get add => translate('add');
  String get search => translate('search');
  String get settings => translate('settings');
  String get language => translate('language');
  String get spanish => translate('spanish');
  String get english => translate('english');
  
  String get liturgiesList => translate('liturgiesList');
  String get noLiturgies => translate('noLiturgies');
  String get noLiturgiesDesc => translate('noLiturgiesDesc');
  String get createLiturgy => translate('createLiturgy');
  String get blocks => translate('blocks');
  String get minutes => translate('minutes');
  
  String get newLiturgy => translate('newLiturgy');
  String get editLiturgy => translate('editLiturgy');
  String get liturgyInfo => translate('liturgyInfo');
  String get liturgyBlocks => translate('liturgyBlocks');
  String get title => translate('title');
  String get date => translate('date');
  String get addBlock => translate('addBlock');
  String get noBlocks => translate('noBlocks');
  String get noBlocksDesc => translate('noBlocksDesc');
  String get totalDuration => translate('totalDuration');
  
  String get blockType => translate('blockType');
  String get description => translate('description');
  String get duration => translate('duration');
  String get responsible => translate('responsible');
  String get responsibleHint => translate('responsibleHint');
  String get comments => translate('comments');
  String get addSong => translate('addSong');
  
  String get welcome => translate('welcome');
  String get worship => translate('worship');
  String get prayer => translate('prayer');
  String get sermon => translate('sermon');
  String get offering => translate('offering');
  String get communion => translate('communion');
  String get announcement => translate('announcement');
  String get blessing => translate('blessing');
  String get other => translate('other');
  
  String get songName => translate('songName');
  String get key => translate('key');
  String get songs => translate('songs');
  String get noSongs => translate('noSongs');
  
  String get presentationMode => translate('presentationMode');
  String get next => translate('next');
  String get previous => translate('previous');
  String get exit => translate('exit');
  
  String get confirmDelete => translate('confirmDelete');
  String get confirmDeleteLiturgy => translate('confirmDeleteLiturgy');
  String get confirmDeleteBlock => translate('confirmDeleteBlock');
  String get confirmDeleteSong => translate('confirmDeleteSong');
  
  String get errorLoadingLiturgies => translate('errorLoadingLiturgies');
  String get errorSavingLiturgy => translate('errorSavingLiturgy');
  String get errorDeletingLiturgy => translate('errorDeletingLiturgy');
  String get liturgyDeletedSuccess => translate('liturgyDeletedSuccess');
  String get liturgyCreatedSuccess => translate('liturgyCreatedSuccess');
  String get liturgyUpdatedSuccess => translate('liturgyUpdatedSuccess');
  String get fillRequiredFields => translate('fillRequiredFields');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['es', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
