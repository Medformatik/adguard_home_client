import 'package:adguard_home_client/interface/adguardhome.dart';

class AdGuardHomeParental {
  final AdGuardHome _adGuardHome;
  AdGuardHomeParental(this._adGuardHome);

  Future<bool> enabled() async {
    if (_adGuardHome.isDemo) {
      return _adGuardHome.demoParental;
    }
    // AdGuard Home versions have returned both `enabled` and `enable` here;
    // the bundled OpenAPI schema and its example even disagree.  Keep this
    // tolerant so a generated-model mismatch cannot silently disable the UI.
    final response = await _adGuardHome.request('parental/status');
    return (response['enabled'] ?? response['enable']) == true;
  }

  Future<void> enable() async {
    if (_adGuardHome.isDemo) {
      _adGuardHome.demoParental = true;
      return;
    }
    await _adGuardHome.restClient.parental.parentalEnable();
  }

  Future<void> disable() async {
    if (_adGuardHome.isDemo) {
      _adGuardHome.demoParental = false;
      return;
    }
    await _adGuardHome.restClient.parental.parentalDisable();
  }
}
