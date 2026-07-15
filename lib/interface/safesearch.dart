import 'package:adguard_home_client/interface/adguardhome.dart';
import 'package:adguard_home_client/generated_api/models/safe_search_config.dart';

class AdGuardHomeSafeSearch {
  final AdGuardHome _adGuardHome;
  AdGuardHomeSafeSearch(this._adGuardHome);

  Future<SafeSearchConfig> _settings() async {
    if (_adGuardHome.isDemo) {
      return SafeSearchConfig(
        enabled: _adGuardHome.demoSafeSearch,
        bing: true,
        duckduckgo: true,
        google: true,
        yandex: true,
        youtube: true,
      );
    }
    return _adGuardHome.restClient.safesearch.safesearchStatus();
  }

  Future<bool> enabled() async {
    final response = await _settings();
    return response.enabled ?? false;
  }

  Future<void> setEnabled(bool value) async {
    if (_adGuardHome.isDemo) {
      _adGuardHome.demoSafeSearch = value;
      return;
    }
    final current = await _settings();
    final updated = SafeSearchConfig(
      enabled: value,
      bing: current.bing,
      duckduckgo: current.duckduckgo,
      ecosia: current.ecosia,
      google: current.google,
      pixabay: current.pixabay,
      yandex: current.yandex,
      youtube: current.youtube,
    );
    await _adGuardHome.restClient.safesearch.safesearchSettings(body: updated);
  }
}
