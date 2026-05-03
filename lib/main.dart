import 'package:adguard_home_client/app.dart';
import 'package:adguard_home_client/interface/adguardhome.dart';
import 'package:adguard_home_client/utils/datasource.dart';
import 'package:adguard_home_client/utils/init.dart';
import 'package:adguard_home_client/utils/instances.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

AdGuardHome? adGuardHome;

/// Active live data source — wraps a single instance or fans out across all
/// configured ones in unified mode.
DataSource? dataSource;

/// Shared protection state — both the AppBar toggle and the protections card listen to it.
final ValueNotifier<ToggleState> protectionStatus = ValueNotifier(ToggleState.loading);

/// Active instance label, surfaced in the home AppBar. Updated by initAdGuardHome
/// callers and the instance switcher.
final ValueNotifier<String?> activeInstanceName = ValueNotifier(null);

bool get instanceConfigured => dataSource != null;

/// Compute the AppBar label for the currently active id.
String? activeLabelFor(String? id) {
  if (id == null) return null;
  if (id == Instances.unifiedId) return 'Unified';
  return Instances.get(id)?.name;
}

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('instances');

  await Instances.migrateLegacy();

  if (Instances.getActiveId() != null) {
    await initAdGuardHome();
    activeInstanceName.value = activeLabelFor(Instances.getActiveId());
  }

  runApp(const AdGuardHomeClientApp());
}
