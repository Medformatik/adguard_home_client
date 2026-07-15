import 'package:adguard_home_client/interface/adguardhome.dart';

class AdGuardHomeSafeBrowsing {
  final AdGuardHome _adGuardHome;
  AdGuardHomeSafeBrowsing(this._adGuardHome);

  Future<bool> enabled() async {
    if (_adGuardHome.isDemo) {
      return _adGuardHome.demoSafeBrowsing;
    }
    final response = await _adGuardHome.restClient.safebrowsing
        .safebrowsingStatus();
    return response.enabled ?? false;
  }

  Future<void> enable() async {
    if (_adGuardHome.isDemo) {
      _adGuardHome.demoSafeBrowsing = true;
      return;
    }
    await _adGuardHome.restClient.safebrowsing.safebrowsingEnable();
  }

  Future<void> disable() async {
    if (_adGuardHome.isDemo) {
      _adGuardHome.demoSafeBrowsing = false;
      return;
    }
    await _adGuardHome.restClient.safebrowsing.safebrowsingDisable();
  }
}
