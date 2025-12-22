import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:worshippro/l10n/app_localizations.dart';
import 'package:worshippro/providers/block_provider.dart';
import 'package:worshippro/providers/language_provider.dart';
import 'package:worshippro/providers/liturgy_provider.dart';
import 'package:worshippro/screens/liturgy_list_screen.dart';
import 'package:worshippro/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp();
  
  // Inicializar formato de fechas en español e inglés
  await initializeDateFormatting('es_ES', null);
  await initializeDateFormatting('en_US', null);
  
  runApp(const WorshipProApp());
}

/// Aplicación principal de WorshipPro
class WorshipProApp extends StatelessWidget {
  const WorshipProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => LiturgyProvider()),
        ChangeNotifierProvider(create: (_) => BlockProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'WorshipPro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            
            // Localización multi-idioma
            locale: languageProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            
            // Pantalla inicial
            home: const LiturgyListScreen(),
          );
        },
      ),
    );
  }
}
