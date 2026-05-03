import 'package:adguard_home_client/app.dart';
import 'package:adguard_home_client/interface/adguardhome.dart';
import 'package:adguard_home_client/utils/init.dart';
import 'package:adguard_home_client/utils/instances.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

AdGuardHome? adGuardHome;

/// Shared protection state — both the AppBar toggle and the protections card listen to it.
final ValueNotifier<bool?> protectionStatus = ValueNotifier(null);

/// Active instance label, surfaced in the home AppBar. Updated by initAdGuardHome
/// callers and the instance switcher.
final ValueNotifier<String?> activeInstanceName = ValueNotifier(null);

bool get instanceConfigured => adGuardHome != null;

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('instances');

  await Instances.migrateLegacy();

  if (Instances.getActiveId() != null) {
    await initAdGuardHome();
    final id = Instances.getActiveId();
    if (id != null) {
      activeInstanceName.value = Instances.get(id)?.name;
    }
  }

  runApp(const AdGuardHomeClientApp());
}
