import 'package:adguard_home_client/interface/adguardhome.dart';

class AdGuardHomeParental {
  final AdGuardHome _adGuardHome;
  AdGuardHomeParental(this._adGuardHome);

  Future<bool> enabled() async {
    final response = await _adGuardHome.request('parental/status');
    return response['enabled'] ?? false;
  }

  Future<void> enable() async => _adGuardHome.request('parental/enable', method: 'POST');
  Future<void> disable() async => _adGuardHome.request('parental/disable', method: 'POST');
}
