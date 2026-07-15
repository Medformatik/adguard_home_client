import 'package:adguard_home_client/pages/home.dart';
import 'package:adguard_home_client/pages/querylog.dart';
import 'package:adguard_home_client/pages/settings.dart';
import 'package:adguard_home_client/pages/dns_rewrites.dart';
import 'package:adguard_home_client/pages/filters.dart';
import 'package:adguard_home_client/pages/clients.dart';
import 'package:adguard_home_client/pages/dns_tools.dart';
import 'package:adguard_home_client/pages/privacy_settings.dart';
import 'package:adguard_home_client/utils/theme.dart';
import 'package:dynamic_system_colors/dynamic_system_colors.dart';
import 'package:flutter/material.dart';

class AdGuardHomeClientApp extends StatelessWidget {
  const AdGuardHomeClientApp({super.key, this.useDynamicColors = true});

  final bool useDynamicColors;

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightScheme = useDynamicColors && lightDynamic != null
            ? lightDynamic
            : _fallbackScheme(brightness: Brightness.light);
        final darkScheme = useDynamicColors && darkDynamic != null
            ? darkDynamic
            : _fallbackScheme(brightness: Brightness.dark);
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, themeMode, _) => MaterialApp(
            title: 'AdGuard Home',
            theme: _theme(lightScheme),
            darkTheme: _theme(darkScheme),
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            routes: {
              '/': (context) => const HomePage(),
              '/settings': (context) => const SettingsPage(),
              '/querylog': (context) => const QueryLogPage(),
              '/rewrites': (context) => const DnsRewritesPage(),
              '/filters': (context) => const FiltersPage(),
              '/clients': (context) => const ClientsPage(),
              '/dns-tools': (context) => const DnsToolsPage(),
              '/privacy': (context) => const PrivacySettingsPage(),
            },
            initialRoute: '/',
          ),
        );
      },
    );
  }

  ColorScheme _fallbackScheme({required Brightness brightness}) {
    return ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.expressive,
    );
  }

  ThemeData _theme(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
