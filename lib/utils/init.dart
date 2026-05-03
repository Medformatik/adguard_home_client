import 'package:adguard_home_client/interface/adguardhome.dart';
import 'package:adguard_home_client/main.dart';
import 'package:adguard_home_client/utils/instances.dart';
import 'package:flutter/foundation.dart';

/// Build [adGuardHome] for the active instance (or for [switchTo] if given).
///
/// Returns true on a successful connection, false otherwise. The global is
/// cleared if no instance is configured or the connection fails.
Future<bool> initAdGuardHome({String? switchTo}) async {
  if (switchTo != null) {
    await Instances.setActiveId(switchTo);
  }
  final id = Instances.getActiveId();
  if (id == null) {
    await adGuardHome?.close();
    adGuardHome = null;
    return false;
  }
  final instance = Instances.get(id);
  if (instance == null) {
    await adGuardHome?.close();
    adGuardHome = null;
    return false;
  }
  final password = await Instances.getPassword(id) ?? '';

  debugPrint('Initializing AdGuardHome for instance "${instance.name}"');

  await adGuardHome?.close();
  adGuardHome = AdGuardHome(
    host: instance.host,
    port: instance.port,
    tls: instance.tls,
    verifySsl: instance.verifySsl,
    username: instance.username,
    password: password,
  );

  if (await adGuardHome!.successfullyConnected()) {
    return true;
  }
  return false;
}
