import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:worshippro/providers/block_provider.dart';
import 'package:worshippro/providers/liturgy_provider.dart';
import 'package:worshippro/screens/liturgy_list_screen.dart';
import 'package:worshippro/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp();
  
  // Inicializar formato de fechas en español
  await initializeDateFormatting('es_ES', null);
  
  runApp(const WorshipProApp());
}

/// Aplicación principal de WorshipPro
class WorshipProApp extends StatelessWidget {
  const WorshipProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LiturgyProvider()),
        ChangeNotifierProvider(create: (_) => BlockProvider()),
      ],
      child: MaterialApp(
        title: 'WorshipPro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        
        // Localización en español
        locale: const Locale('es', 'ES'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
        ],
        
        // Pantalla inicial
        home: const LiturgyListScreen(),
      ),
    );
  }
}
