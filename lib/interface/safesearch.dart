import 'package:adguard_home_client/interface/adguardhome.dart';

class AdGuardHomeSafeSearch {
  final AdGuardHome _adGuardHome;
  AdGuardHomeSafeSearch(this._adGuardHome);

  Future<Map<String, dynamic>> _settings() => _adGuardHome.request('safesearch/status');

  Future<bool> enabled() async {
    final response = await _settings();
    return response['enabled'] ?? false;
  }

  Future<void> setEnabled(bool value) async {
    final current = Map<String, dynamic>.from(await _settings());
    current['enabled'] = value;
    current.remove('error');
    await _adGuardHome.request('safesearch/settings', method: 'PUT', data: current);
  }
}
