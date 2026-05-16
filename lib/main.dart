import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/auth/splash_screen.dart';
import 'services/locale_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  initializeDateFormatting().then(
    (_) => runApp(
      ChangeNotifierProvider(
        create: (context) => LocaleProvider(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PawWalk',

          // Language Configuration
          locale: provider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('fr'),
          ],

          // Theme Configuration
          themeMode: provider.themeMode,

          // Light Theme
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF2563EB),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            cardColor: Colors.white,
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),

          // Dark Theme
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF2563EB),
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            cardColor: const Color(0xFF1E293B),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF334155),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF475569)),
              ),
              labelStyle: const TextStyle(color: Colors.white70),
              hintStyle: const TextStyle(color: Colors.white30),
            ),
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}
