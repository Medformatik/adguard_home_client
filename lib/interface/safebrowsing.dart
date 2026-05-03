import 'package:adguard_home_client/interface/adguardhome.dart';

class AdGuardHomeSafeBrowsing {
  final AdGuardHome _adGuardHome;
  AdGuardHomeSafeBrowsing(this._adGuardHome);

  Future<bool> enabled() async {
    final response = await _adGuardHome.request('safebrowsing/status');
    return response['enabled'] ?? false;
  }

  Future<void> enable() async => _adGuardHome.request('safebrowsing/enable', method: 'POST');
  Future<void> disable() async => _adGuardHome.request('safebrowsing/disable', method: 'POST');
}
