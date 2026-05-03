import 'package:adguard_home_client/pages/home.dart';
import 'package:adguard_home_client/pages/querylog.dart';
import 'package:adguard_home_client/pages/settings.dart';
import 'package:flutter/material.dart';

class AdGuardHomeClientApp extends StatelessWidget {
  const AdGuardHomeClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = Colors.green;
    return MaterialApp(
      title: 'AdGuard Home',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
        '/querylog': (context) => const QueryLogPage(),
      },
      initialRoute: '/',
    );
  }
}
