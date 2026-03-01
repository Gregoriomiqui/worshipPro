import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:worshippro/l10n/app_localizations.dart';
import 'package:worshippro/providers/auth_provider.dart';
import 'package:worshippro/providers/block_provider.dart';
import 'package:worshippro/providers/language_provider.dart';
import 'package:worshippro/providers/liturgy_provider.dart';
import 'package:worshippro/providers/organization_provider.dart';
import 'package:worshippro/screens/auth/login_screen.dart';
import 'package:worshippro/screens/liturgy_list_screen.dart';
import 'package:worshippro/screens/organization/organization_selector_screen.dart';
import 'package:worshippro/theme/app_theme.dart';
import 'package:worshippro/models/user.dart' as app_models;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  // NOTA: Ejecuta `flutterfire configure` para generar firebase_options.dart
  await Firebase.initializeApp();
  
  // Inicializar formato de fechas en español e inglés
  await initializeDateFormatting('es_ES', null);
  await initializeDateFormatting('en_US', null);
  
  runApp(const WorshipProApp());
}

/// Aplicación principal de WorshipPro con autenticación y multi-tenancy
class WorshipProApp extends StatelessWidget {
  const WorshipProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth debe ser primero para que otros providers puedan depender de él
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        // Organization provider
        ChangeNotifierProvider(create: (_) => OrganizationProvider()),
        
        // Otros providers
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
            
            // Pantalla inicial con guard de autenticación
            home: const AuthGuard(),
          );
        },
      ),
    );
  }
}

/// Guard de autenticación que redirige según el estado del usuario
class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        print('🔵 AuthGuard: Rebuilding - status: ${authProvider.status}');

        if (authProvider.status == AuthStatus.initial) {
          print('🔵 AuthGuard: Mostrando splash (status: ${authProvider.status})');
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (authProvider.status != AuthStatus.authenticated) {
          print('🔵 AuthGuard: No autenticado/loading → LoginScreen');
          return const LoginScreen();
        }
        
        // A partir de aquí, el usuario está autenticado.
        final user = authProvider.currentUser;

        if (user == null || user.organizationIds.isEmpty || user.activeOrganizationId == null) {
          print('🔵 AuthGuard: ✅ Sin organización activa → OrganizationSelectorScreen');
          return const OrganizationSelectorScreen();
        }

        // Si tiene organización activa, cargar datos y luego ir a liturgias.
        print('🔵 AuthGuard: ⚠️ Tiene organización activa (${user.activeOrganizationId}) → _InitialDataLoader');
        return _InitialDataLoader(user: user);
      },
    );
  }
}


/// Widget para cargar los datos iniciales de la organización y el usuario.
class _InitialDataLoader extends StatelessWidget {
  final app_models.User user;

  const _InitialDataLoader({required this.user});

  Future<void> _loadInitialData(BuildContext context) async {
    // Usar 'read' para ejecutar acciones sin volver a escuchar aquí
    final orgProvider = context.read<OrganizationProvider>();
    final liturgyProvider = context.read<LiturgyProvider>();
    final blockProvider = context.read<BlockProvider>();
    
    // Solo recargar datos si es estrictamente necesario para evitar bucles.
    // 1. Cargar la lista de organizaciones si no está ya cargada.
    if (orgProvider.userOrganizations.isEmpty) {
      await orgProvider.loadUserOrganizations(user.organizationIds);
    }
    
    // 2. Establecer la organización activa solo si no es ya la correcta.
    if (orgProvider.activeOrganization?.id != user.activeOrganizationId) {
      await orgProvider.setActiveOrganization(user.activeOrganizationId!);
    }
    
    // 3. Configurar el contexto para los otros providers.
    liturgyProvider.setContext(user.activeOrganizationId!, user.id);
    blockProvider.setOrganizationId(user.activeOrganizationId!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadInitialData(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          // Proporcionar una forma de reintentar
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error al cargar datos: ${snapshot.error}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Re-ejecutar el FutureBuilder
                      (context as Element).reassemble();
                    },
                    child: const Text('Reintentar'),
                  )
                ],
              ),
            ),
          );
        }

        // Una vez que los datos están cargados, ir a la pantalla principal.
        return const LiturgyListScreen();
      },
    );
  }
}
