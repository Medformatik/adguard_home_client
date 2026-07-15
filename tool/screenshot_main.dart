import 'package:adguard_home_client/app.dart';
import 'package:adguard_home_client/interface/adguardhome.dart';
import 'package:adguard_home_client/main.dart' as app;
import 'package:adguard_home_client/utils/datasource.dart';
import 'package:adguard_home_client/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter('screenshots');
  await Hive.openBox('settings');
  await Hive.openBox('instances');

  final client = AdGuardHome(
    host: 'demo.demo.demo',
    username: 'demo',
    password: 'demo',
  );
  app.adGuardHome = client;
  app.dataSource = SingleDataSource(client);
  app.activeInstanceName.value = 'Demo instance';
  app.protectionStatus.value = ToggleState.loading;
  themeModeNotifier.value = ThemeMode.light;

  runApp(const AdGuardHomeClientApp(useDynamicColors: false));
}
