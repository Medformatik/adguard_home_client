import 'package:adguard_home_client/interface/adguardhome.dart';
import 'package:adguard_home_client/generated_api/export.dart';

class AdGuardHomeFiltering {
  final AdGuardHome _client;

  AdGuardHomeFiltering(this._client);

  /// Fetch filtering status (which contains rules and list filters)
  Future<FilterStatus> getStatus() async {
    if (_client.isDemo) {
      return FilterStatus(
        enabled: true,
        interval: 36,
        filters: _demoBlocklists,
        whitelistFilters: _demoWhitelists,
        userRules: _client.demoUserRules,
      );
    }
    return _client.restClient.filtering.filteringStatus();
  }

  /// Fetch user-defined rules.
  Future<List<String>> getUserRules() async {
    if (_client.isDemo) {
      return _client.demoUserRules;
    }
    final response = await _client.restClient.filtering.filteringStatus();
    return response.userRules ?? [];
  }

  /// Overwrite the user-defined rules.
  Future<void> setUserRules(List<String> rules) async {
    if (_client.isDemo) {
      _client.demoUserRules = List<String>.from(rules);
      return;
    }
    await _client.restClient.filtering.filteringSetRules(
      body: SetRulesRequest(rules: rules),
    );
  }

  /// Add a filter URL (blocklist or whitelist)
  Future<void> addFilter(String name, String url, bool whitelist) async {
    if (_client.isDemo) {
      final list = whitelist ? _demoWhitelists : _demoBlocklists;
      list.add(
        Filter(
          id: DateTime.now().millisecondsSinceEpoch,
          name: name,
          enabled: true,
          rulesCount: 0,
          url: url,
        ),
      );
      return;
    }
    await _client.restClient.filtering.filteringAddUrl(
      body: AddUrlRequest(name: name, url: url, whitelist: whitelist),
    );
  }

  /// Remove a filter URL
  Future<void> removeFilter(String url, bool whitelist) async {
    if (_client.isDemo) {
      final list = whitelist ? _demoWhitelists : _demoBlocklists;
      list.removeWhere((f) => f.url == url);
      return;
    }
    await _client.restClient.filtering.filteringRemoveUrl(
      body: RemoveUrlRequest(url: url, whitelist: whitelist),
    );
  }

  /// Enable or disable a filter URL
  Future<void> toggleFilter(
    String url,
    String name,
    bool enabled,
    bool whitelist,
  ) async {
    if (_client.isDemo) {
      final list = whitelist ? _demoWhitelists : _demoBlocklists;
      final idx = list.indexWhere((f) => f.url == url);
      if (idx != -1) {
        final existing = list[idx];
        list[idx] = Filter(
          id: existing.id,
          name: name,
          enabled: enabled,
          rulesCount: existing.rulesCount,
          url: url,
        );
      }
      return;
    }
    await _client.restClient.filtering.filteringSetUrl(
      body: FilterSetUrl(
        url: url,
        whitelist: whitelist,
        data: FilterSetUrlData(enabled: enabled, name: name, url: url),
      ),
    );
  }

  /// Refresh rules lists
  Future<void> refreshFilters() async {
    if (_client.isDemo) return;
    await _client.restClient.filtering.filteringRefresh();
  }

  static final List<Filter> _demoBlocklists = [
    const Filter(
      id: 1,
      name: 'AdGuard Base Filter',
      enabled: true,
      rulesCount: 84000,
      url: 'https://adguard.txt',
    ),
    const Filter(
      id: 2,
      name: 'AdAway Default Blocklist',
      enabled: true,
      rulesCount: 15400,
      url: 'https://adaway.txt',
    ),
    const Filter(
      id: 3,
      name: 'Peter Lowe\'s Ad and tracking list',
      enabled: false,
      rulesCount: 3500,
      url:
          'https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext',
    ),
  ];

  static final List<Filter> _demoWhitelists = [
    const Filter(
      id: 10,
      name: 'My Whitelist Filter',
      enabled: true,
      rulesCount: 120,
      url: 'https://whitelist.txt',
    ),
  ];
}
