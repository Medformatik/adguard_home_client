import 'dart:math';
import 'dart:core';

import 'package:adguard_home_client/interface/adguardhome.dart';
import 'package:adguard_home_client/generated_api/models/stats.dart';
import 'package:adguard_home_client/generated_api/models/get_stats_config_response.dart';

class AdGuardHomeStats {
  final AdGuardHome _adGuardHome;
  AdGuardHomeStats(this._adGuardHome);

  Future<Map<String, dynamic>>? _statsCache;
  Future<GetStatsConfigResponse>? _statsInfoCache;

  Future<Map<String, dynamic>> _stats() =>
      _statsCache ??= _adGuardHome.request('stats');
  Future<GetStatsConfigResponse> _statsInfo() =>
      _statsInfoCache ??= _adGuardHome.isDemo
      ? Future.value(
          const GetStatsConfigResponse(
            enabled: true,
            interval: 7776000000,
            ignored: [],
            ignoredEnabled: false,
          ),
        )
      : _adGuardHome.restClient.stats.getStatsConfig();

  Future<Stats> _statsModel() async {
    final raw = await _stats();
    return Stats.fromJson(raw);
  }

  /// Drop cached responses so the next read fetches fresh data.
  void refresh() {
    _statsCache = null;
    _statsInfoCache = null;
  }

  Future<Map<String, dynamic>> fullReport() async {
    return {
      'DNS queries': await dnsQueries(),
      'Blocked DNS queries': await blockedFiltering(),
      'Blocked percentage ratio of DNS queries': await blockedPercentage(),
      'Blocked pages by safe browsing': await replacedSafebrowsing(),
      'Blocked pages by parental control': await replacedParental(),
      'Enforced safe searches': await replacedSafesearch(),
      'Average processing time of DNS queries (in ms)':
          await avgProcessingTime(),
      'Time period to keep data (in days)': await period(),
      'Top queried domains': await topQueriedDomains(),
      'Top blocked domains': await topBlockedDomains(),
      'Top clients': await topClients(),
      'Top upstreams by responses': await topUpstreamsResponses(),
      'Top upstreams by average response time': await topUpstreamsAvgTime(),
      'DNS queries per day': await dnsQueriesPerDay(),
      'Blocked DNS queries per day': await blockedFilteringPerDay(),
      'Blocked pages by safe browsing per day':
          await replacedSafebrowsingPerDay(),
      'Blocked pages by parental control per day':
          await replacedParentalPerDay(),
    };
  }

  Future<int> dnsQueries() async {
    final s = await _statsModel();
    return s.numDnsQueries ?? 0;
  }

  Future<int> blockedFiltering() async {
    final s = await _statsModel();
    return s.numBlockedFiltering ?? 0;
  }

  Future<double> blockedPercentage() async {
    final s = await _statsModel();
    final total = s.numDnsQueries ?? 0;
    final blocked = s.numBlockedFiltering ?? 0;
    if (total == 0) return 0;
    return round((blocked / total) * 100.0, 2);
  }

  Future<int> replacedSafebrowsing() async {
    final s = await _statsModel();
    return s.numReplacedSafebrowsing ?? 0;
  }

  Future<int> replacedParental() async {
    final s = await _statsModel();
    return s.numReplacedParental ?? 0;
  }

  Future<int> replacedSafesearch() async {
    final s = await _statsModel();
    return s.numReplacedSafesearch ?? 0;
  }

  Future<double> avgProcessingTime() async {
    final s = await _statsModel();
    final total = s.numDnsQueries ?? 0;
    final avg = s.avgProcessingTime ?? 0.0;
    if (total == 0 || avg == 0.0) return 0;
    return round(avg * 1000, 2);
  }

  Future<int> period() async {
    final s = await _statsInfo();
    return (s.interval / Duration.millisecondsPerDay).round();
  }

  Future<Map<String, int>> topQueriedDomains() async {
    /* Return the top queried domains.

        Returns:
            The top queried domains as a Map<String, int>.
        */
    Map<String, dynamic> response = await _stats();
    Map<String, int> topQueriedDomains = {};
    if (response['top_queried_domains'] != null) {
      response['top_queried_domains'].forEach((i) {
        Map<String, dynamic> topDomain = Map<String, dynamic>.from(i);
        topQueriedDomains[topDomain.entries.first.key] =
            topDomain.entries.first.value;
      });
    }
    return topQueriedDomains;
  }

  Future<Map<String, int>> topBlockedDomains() async {
    /* Return the top blocked domains.

        Returns:
            The top blocked domains as a Map<String, int>.
        */
    Map<String, dynamic> response = await _stats();
    Map<String, int> topBlockedDomains = {};
    if (response['top_blocked_domains'] != null) {
      response['top_blocked_domains'].forEach((i) {
        Map<String, dynamic> topDomain = Map<String, dynamic>.from(i);
        topBlockedDomains[topDomain.entries.first.key] =
            topDomain.entries.first.value;
      });
    }
    return topBlockedDomains;
  }

  Future<Map<String, int>> topClients() async {
    /* Return the top clients.

        Returns:
            The top clients as a Map<String, int>.
        */
    Map<String, dynamic> response = await _stats();
    Map<String, int> topClients = {};
    if (response['top_clients'] != null) {
      response['top_clients'].forEach((i) {
        Map<String, dynamic> topClient = Map<String, dynamic>.from(i);
        topClients[topClient.entries.first.key] = topClient.entries.first.value;
      });
    }
    return topClients;
  }

  Future<Map<String, int>> topUpstreamsResponses() async {
    return _topIntMap('top_upstreams_responses');
  }

  Future<Map<String, double>> topUpstreamsAvgTime() async {
    final response = await _stats();
    final result = <String, double>{};
    for (final item
        in (response['top_upstreams_avg_time'] as List?) ?? const []) {
      if (item is! Map || item.isEmpty) continue;
      final entry = item.entries.first;
      final seconds = (entry.value as num?)?.toDouble();
      if (seconds != null) result[entry.key.toString()] = seconds * 1000;
    }
    return result;
  }

  Future<Map<String, int>> _topIntMap(String key) async {
    final response = await _stats();
    final result = <String, int>{};
    for (final item in (response[key] as List?) ?? const []) {
      if (item is! Map || item.isEmpty) continue;
      final entry = item.entries.first;
      final value = entry.value as num?;
      if (value != null) result[entry.key.toString()] = value.round();
    }
    return result;
  }

  Future<List<int>> dnsQueriesPerDay() async {
    final s = await _statsModel();
    return s.dnsQueries ?? const [];
  }

  Future<List<int>> blockedFilteringPerDay() async {
    final s = await _statsModel();
    return s.blockedFiltering ?? const [];
  }

  Future<List<int>> replacedSafebrowsingPerDay() async {
    final s = await _statsModel();
    return s.replacedSafebrowsing ?? const [];
  }

  Future<List<int>> replacedParentalPerDay() async {
    final s = await _statsModel();
    return s.replacedParental ?? const [];
  }

  Future<void> reset() async {
    if (_adGuardHome.isDemo) return;
    await _adGuardHome.restClient.stats.statsReset();
    refresh();
  }

  Future<GetStatsConfigResponse> config() => _statsInfo();

  Future<void> updateConfig(GetStatsConfigResponse config) async {
    if (_adGuardHome.isDemo) return;
    await _adGuardHome.restClient.stats.putStatsConfig(body: config);
    refresh();
  }

  double round(double value, int places) {
    double mod = pow(10.0, places) as double;
    return ((value * mod).round().toDouble() / mod);
  }

  Future<StatsSnapshot> snapshot() async {
    final results = await Future.wait([
      dnsQueries(),
      blockedFiltering(),
      blockedPercentage(),
      replacedSafebrowsing(),
      replacedParental(),
      replacedSafesearch(),
      avgProcessingTime(),
      period(),
      topQueriedDomains(),
      topBlockedDomains(),
      topClients(),
      topUpstreamsResponses(),
      topUpstreamsAvgTime(),
      dnsQueriesPerDay(),
      blockedFilteringPerDay(),
      replacedSafebrowsingPerDay(),
      replacedParentalPerDay(),
    ]);
    return StatsSnapshot(
      dnsQueries: results[0] as int,
      blockedFiltering: results[1] as int,
      blockedPercentage: results[2] as double,
      replacedSafebrowsing: results[3] as int,
      replacedParental: results[4] as int,
      replacedSafesearch: results[5] as int,
      avgProcessingTime: results[6] as double,
      period: results[7] as int,
      topQueriedDomains: results[8] as Map<String, int>,
      topBlockedDomains: results[9] as Map<String, int>,
      topClients: results[10] as Map<String, int>,
      topUpstreamsResponses: results[11] as Map<String, int>,
      topUpstreamsAvgTime: results[12] as Map<String, double>,
      dnsQueriesPerDay: List<int>.from(results[13] as List),
      blockedFilteringPerDay: List<int>.from(results[14] as List),
      replacedSafebrowsingPerDay: List<int>.from(results[15] as List),
      replacedParentalPerDay: List<int>.from(results[16] as List),
    );
  }
}

class StatsSnapshot {
  final int dnsQueries;
  final int blockedFiltering;
  final double blockedPercentage;
  final int replacedSafebrowsing;
  final int replacedParental;
  final int replacedSafesearch;
  final double avgProcessingTime;
  final int period;
  final Map<String, int> topQueriedDomains;
  final Map<String, int> topBlockedDomains;
  final Map<String, int> topClients;
  final Map<String, int> topUpstreamsResponses;
  final Map<String, double> topUpstreamsAvgTime;
  final List<int> dnsQueriesPerDay;
  final List<int> blockedFilteringPerDay;
  final List<int> replacedSafebrowsingPerDay;
  final List<int> replacedParentalPerDay;

  StatsSnapshot({
    required this.dnsQueries,
    required this.blockedFiltering,
    required this.blockedPercentage,
    required this.replacedSafebrowsing,
    required this.replacedParental,
    required this.replacedSafesearch,
    required this.avgProcessingTime,
    required this.period,
    required this.topQueriedDomains,
    required this.topBlockedDomains,
    required this.topClients,
    required this.topUpstreamsResponses,
    required this.topUpstreamsAvgTime,
    required this.dnsQueriesPerDay,
    required this.blockedFilteringPerDay,
    required this.replacedSafebrowsingPerDay,
    required this.replacedParentalPerDay,
  });
}
