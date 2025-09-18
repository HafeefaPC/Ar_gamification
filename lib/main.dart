import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:face_reflector/core/routing/app_router.dart';
import 'package:face_reflector/core/providers/providers.dart';

import 'package:face_reflector/shared/services/global_wallet_service.dart';
import 'package:face_reflector/core/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Initialize Supabase at app level
  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    print('Supabase initialized successfully in main');

    // Test the connection immediately
    final client = Supabase.instance.client;
    print('Supabase client created successfully');

    // Try to make a simple test query
    try {
      final response = await client.from('events').select('id').limit(1);
      print('Initial connection test successful: ${response.length} records');
    } catch (e) {
      print('Initial connection test failed: $e');
    }
  } catch (e) {
    print('Error initializing Supabase in main: $e');
  }

  // Initialize providers
  initializeProviders();

  runApp(const ProviderScope(child: FaceReflectorApp()));
}

class FaceReflectorApp extends ConsumerStatefulWidget {
  const FaceReflectorApp({super.key});

  @override
  ConsumerState<FaceReflectorApp> createState() => _FaceReflectorAppState();
}

class _FaceReflectorAppState extends ConsumerState<FaceReflectorApp> {
  @override
  void initState() {
    super.initState();
    // Initialize services after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeServices();
    });
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize global wallet service
      final globalWalletService = ref.read(globalWalletServiceProvider);
      await globalWalletService.initialize(ref);

      debugPrint('Services initialized successfully');
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'TOKON',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryColor,
          brightness: Brightness.dark,
          primary: AppTheme.primaryColor,
          secondary: AppTheme.secondaryColor,
          surface: AppTheme.surfaceColor,
          onPrimary: AppTheme.textColor,
          onSecondary: AppTheme.textColor,
          onSurface: AppTheme.textColor,
        ),
        scaffoldBackgroundColor: AppTheme.backgroundColor,
        appBarTheme: AppTheme.modernAppBarTheme,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppTheme.modernPrimaryButton,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: AppTheme.modernOutlinedButton,
        ),
        textButtonTheme: TextButtonThemeData(style: AppTheme.modernTextButton),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppTheme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
      routerConfig: router,
      locale: const Locale('en', 'US'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],
    );
  }
}
