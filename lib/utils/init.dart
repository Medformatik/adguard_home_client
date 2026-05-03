import 'package:adguard_home_client/interface/adguardhome.dart';
import 'package:adguard_home_client/main.dart';
import 'package:adguard_home_client/pages/settings.dart';
import 'package:flutter/foundation.dart';

Future<bool> initAdGuardHome() async {
  debugPrint('Initializing AdGuardHome instance');

  adGuardHome = AdGuardHome(
    host: SettingsValues.getHost()!,
    port: SettingsValues.getPort()!,
    tls: SettingsValues.getTls(),
    verifySsl: SettingsValues.getVerifySsl(),
    username: SettingsValues.getUsername()!,
    password: (await SettingsValues.getPassword())!,
  );

  if (await adGuardHome!.successfullyConnected()) {
    return true;
  } else {
    adGuardHome = null;
    return false;
  }
}
