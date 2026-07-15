import 'dart:math';

import 'package:adguard_home_client/interface/adguardhome.dart';
import 'package:adguard_home_client/interface/blocked_services.dart';
import 'package:adguard_home_client/interface/querylog.dart';
import 'package:adguard_home_client/interface/stats.dart';
import 'package:adguard_home_client/generated_api/export.dart'
    hide BlockedService;

/// Tri-state for toggles. [mixed] is only produced by [UnifiedDataSource]
/// when underlying instances disagree. [loading] is the initial state.
enum ToggleState { loading, on, off, mixed }

extension ToggleStateX on ToggleState {
  bool get isOn => this == ToggleState.on;
  bool get isOff => this == ToggleState.off;
  bool get isMixed => this == ToggleState.mixed;
  bool get isLoading => this == ToggleState.loading;
  bool get isReady => isOn || isOff;
  bool? get asBool => isOn ? true : (isOff ? false : null);
}

ToggleState toggleStateFromBools(Iterable<bool> values) {
  final list = values.toList();
  if (list.isEmpty) return ToggleState.off;
  if (list.every((v) => v)) return ToggleState.on;
  if (list.every((v) => !v)) return ToggleState.off;
  return ToggleState.mixed;
}

class ProtectionSummary {
  const ProtectionSummary({required this.state, this.remaining});

  final ToggleState state;
  final Duration? remaining;
}

abstract class DataSource {
  /// True when this datasource fans out to multiple instances.
  bool get isUnified;

  /// Underlying live clients. Single → 1, unified → N (may be empty if no instances).
  List<AdGuardHome> get clients;

  /// Display names available for query-log source filtering in unified mode.
  List<String> get sourceNames;

  /// Drop any cached stats so the next [snapshot] performs a fresh fetch.
  void invalidateStats();

  Future<StatsSnapshot> snapshot();
  Future<QueryLogBatch> queryLog({
    int limit = 100,
    String? search,
    QueryLogReasonFilter reasonFilter = QueryLogReasonFilter.all,
    QueryLogCursor? cursor,
    String? source,
  });
  Future<String> version();

  Future<ToggleState> protectionEnabled();
  Future<ProtectionSummary> protectionSummary();
  Future<void> setProtection(bool value, {Duration? pauseFor});

  Future<ToggleState> safeBrowsingEnabled();
  Future<void> setSafeBrowsing(bool value);

  Future<ToggleState> parentalEnabled();
  Future<void> setParental(bool value);

  Future<ToggleState> safeSearchEnabled();
  Future<void> setSafeSearch(bool value);

  Future<List<String>> getUserRules();
  Future<void> setUserRules(List<String> rules);
  Future<void> addUserRule(String rule);
  Future<void> removeUserRule(String rule);

  Future<List<BlockedService>> getAvailableBlockedServices();
  Future<List<String>> getBlockedServices();
  Future<void> updateBlockedServices(List<String> serviceIds);
  Future<BlockedServicesSchedule> getBlockedServicesSchedule();
  Future<void> updateBlockedServicesSchedule(Schedule schedule);

  // --- DNS Rewrites ---
  Future<List<RewriteEntry>> getRewrites();
  Future<void> addRewrite(String domain, String answer);
  Future<void> deleteRewrite(String domain, String answer);
  Future<void> updateRewrite(RewriteEntry target, RewriteEntry update);

  // --- Filters & Blocklists ---
  Future<FilterStatus> getFilteringStatus();
  Future<void> addFilter(String name, String url, bool whitelist);
  Future<void> removeFilter(String url, bool whitelist);
  Future<void> toggleFilter(
    String url,
    String name,
    bool enabled,
    bool whitelist,
  );
  Future<void> refreshFilters();

  // --- Clients Management ---
  Future<Clients> getClients();
  Future<void> addClient(Client newClient);
  Future<void> updateClient(String originalName, Client updatedClient);
  Future<void> deleteClient(String name);

  // --- Query log and statistics configuration ---
  Future<GetQueryLogConfigResponse> getQueryLogConfig();
  Future<void> updateQueryLogConfig(GetQueryLogConfigResponse config);
  Future<void> clearQueryLog();
  Future<GetStatsConfigResponse> getStatsConfig();
  Future<void> updateStatsConfig(GetStatsConfigResponse config);
  Future<void> resetStats();

  // --- DNS diagnostics ---
  Future<GetDnsInfoResponse> getDnsInfo();
  Future<Map<String, String>> testUpstreams(GetDnsInfoResponse config);
  Future<void> clearDnsCache();
}

class SingleDataSource implements DataSource {
  final AdGuardHome client;
  SingleDataSource(this.client);

  @override
  bool get isUnified => false;

  @override
  List<AdGuardHome> get clients => [client];

  @override
  List<String> get sourceNames => const [];

  @override
  void invalidateStats() => client.stats.refresh();

  @override
  Future<StatsSnapshot> snapshot() => client.stats.snapshot();

  @override
  Future<QueryLogBatch> queryLog({
    int limit = 100,
    String? search,
    QueryLogReasonFilter reasonFilter = QueryLogReasonFilter.all,
    QueryLogCursor? cursor,
    String? source,
  }) async {
    final batch = await client.queryLog.recent(
      limit: limit,
      search: search,
      reasonFilter: reasonFilter,
      olderThan: cursor?.bySource['0'],
    );
    return QueryLogBatch(
      entries: batch.entries,
      nextCursor: batch.nextCursor == null
          ? null
          : QueryLogCursor({'0': batch.nextCursor!.bySource['']}),
    );
  }

  @override
  Future<String> version() => client.version();

  @override
  Future<ToggleState> protectionEnabled() async =>
      (await client.protectionEnabled()) ? ToggleState.on : ToggleState.off;

  @override
  Future<ProtectionSummary> protectionSummary() async {
    final info = await client.protectionInfo();
    return ProtectionSummary(
      state: info.enabled ? ToggleState.on : ToggleState.off,
      remaining: info.remaining,
    );
  }

  @override
  Future<void> setProtection(bool value, {Duration? pauseFor}) =>
      client.setProtection(value, pauseFor: pauseFor);

  @override
  Future<ToggleState> safeBrowsingEnabled() async =>
      (await client.safeBrowsing.enabled()) ? ToggleState.on : ToggleState.off;

  @override
  Future<void> setSafeBrowsing(bool value) =>
      value ? client.safeBrowsing.enable() : client.safeBrowsing.disable();

  @override
  Future<ToggleState> parentalEnabled() async =>
      (await client.parental.enabled()) ? ToggleState.on : ToggleState.off;

  @override
  Future<void> setParental(bool value) =>
      value ? client.parental.enable() : client.parental.disable();

  @override
  Future<ToggleState> safeSearchEnabled() async =>
      (await client.safeSearch.enabled()) ? ToggleState.on : ToggleState.off;

  @override
  Future<void> setSafeSearch(bool value) => client.safeSearch.setEnabled(value);

  @override
  Future<List<String>> getUserRules() => client.filtering.getUserRules();

  @override
  Future<void> setUserRules(List<String> rules) =>
      client.filtering.setUserRules(rules);

  @override
  Future<void> addUserRule(String rule) async {
    final rules = await getUserRules();
    if (!rules.contains(rule)) {
      rules.add(rule);
      await client.filtering.setUserRules(rules);
    }
  }

  @override
  Future<void> removeUserRule(String rule) async {
    final rules = await getUserRules();
    if (rules.contains(rule)) {
      rules.remove(rule);
      await client.filtering.setUserRules(rules);
    }
  }

  @override
  Future<List<BlockedService>> getAvailableBlockedServices() =>
      client.blockedServices.getAvailableServices();

  @override
  Future<List<String>> getBlockedServices() =>
      client.blockedServices.getBlockedServices();

  @override
  Future<void> updateBlockedServices(List<String> serviceIds) =>
      client.blockedServices.updateBlockedServices(serviceIds);

  @override
  Future<BlockedServicesSchedule> getBlockedServicesSchedule() =>
      client.blockedServices.getSchedule();

  @override
  Future<void> updateBlockedServicesSchedule(Schedule schedule) =>
      client.blockedServices.updateSchedule(schedule);

  @override
  Future<List<RewriteEntry>> getRewrites() => client.rewrite.getRewrites();

  @override
  Future<void> addRewrite(String domain, String answer) =>
      client.rewrite.addRewrite(domain, answer);

  @override
  Future<void> deleteRewrite(String domain, String answer) =>
      client.rewrite.deleteRewrite(domain, answer);

  @override
  Future<void> updateRewrite(RewriteEntry target, RewriteEntry update) =>
      client.rewrite.updateRewrite(target, update);

  @override
  Future<FilterStatus> getFilteringStatus() => client.filtering.getStatus();

  @override
  Future<void> addFilter(String name, String url, bool whitelist) =>
      client.filtering.addFilter(name, url, whitelist);

  @override
  Future<void> removeFilter(String url, bool whitelist) =>
      client.filtering.removeFilter(url, whitelist);

  @override
  Future<void> toggleFilter(
    String url,
    String name,
    bool enabled,
    bool whitelist,
  ) => client.filtering.toggleFilter(url, name, enabled, whitelist);

  @override
  Future<void> refreshFilters() => client.filtering.refreshFilters();

  @override
  Future<Clients> getClients() => client.clientsHandler.getClients();

  @override
  Future<void> addClient(Client newClient) =>
      client.clientsHandler.addClient(newClient);

  @override
  Future<void> updateClient(String originalName, Client updatedClient) =>
      client.clientsHandler.updateClient(originalName, updatedClient);

  @override
  Future<void> deleteClient(String name) =>
      client.clientsHandler.deleteClient(name);

  @override
  Future<GetQueryLogConfigResponse> getQueryLogConfig() =>
      client.queryLog.config();

  @override
  Future<void> updateQueryLogConfig(GetQueryLogConfigResponse config) =>
      client.queryLog.updateConfig(config);

  @override
  Future<void> clearQueryLog() => client.queryLog.clear();

  @override
  Future<GetStatsConfigResponse> getStatsConfig() => client.stats.config();

  @override
  Future<void> updateStatsConfig(GetStatsConfigResponse config) =>
      client.stats.updateConfig(config);

  @override
  Future<void> resetStats() => client.stats.reset();

  @override
  Future<GetDnsInfoResponse> getDnsInfo() => client.dns.info();

  @override
  Future<Map<String, String>> testUpstreams(GetDnsInfoResponse config) =>
      client.dns.testUpstreams(config);

  @override
  Future<void> clearDnsCache() => client.dns.clearCache();
}

class UnifiedDataSource implements DataSource {
  @override
  final List<AdGuardHome> clients;

  /// Per-instance display names, parallel to [clients]. Used to tag query log entries.
  final List<String> names;

  UnifiedDataSource(this.clients, this.names)
    : assert(clients.length == names.length);

  @override
  bool get isUnified => true;

  @override
  List<String> get sourceNames => List.unmodifiable(names);

  @override
  void invalidateStats() {
    for (final c in clients) {
      c.stats.refresh();
    }
  }

  @override
  Future<StatsSnapshot> snapshot() async {
    if (clients.isEmpty) return _emptySnapshot;
    final snapshots = await Future.wait(clients.map((c) => c.stats.snapshot()));
    return _mergeSnapshots(snapshots);
  }

  @override
  Future<QueryLogBatch> queryLog({
    int limit = 100,
    String? search,
    QueryLogReasonFilter reasonFilter = QueryLogReasonFilter.all,
    QueryLogCursor? cursor,
    String? source,
  }) async {
    if (clients.isEmpty) return const QueryLogBatch(entries: []);
    final indexes = [
      for (int i = 0; i < clients.length; i++)
        if (source == null || names[i] == source) i,
    ];
    final batches = await Future.wait([
      for (final i in indexes)
        clients[i].queryLog
            .recent(
              limit: limit,
              search: search,
              reasonFilter: reasonFilter,
              olderThan: cursor?.bySource['$i'],
            )
            .then((batch) {
              for (final e in batch.entries) {
                e.source = names[i];
              }
              return (index: i, batch: batch);
            }),
    ]);
    final merged = <QueryLogEntry>[
      for (final item in batches) ...item.batch.entries,
    ];
    merged.sort((a, b) => b.time.compareTo(a.time));
    if (merged.length > limit) {
      merged.removeRange(limit, merged.length);
    }
    final nextBySource = <String, String?>{};
    for (final item in batches) {
      if (item.batch.nextCursor == null) continue;
      final included = item.batch.entries.where(merged.contains).toList();
      if (included.isNotEmpty) {
        included.sort((a, b) => a.time.compareTo(b.time));
        nextBySource['${item.index}'] = included.first.time
            .toUtc()
            .toIso8601String();
      } else {
        final previous = cursor?.bySource['${item.index}'];
        if (previous != null) nextBySource['${item.index}'] = previous;
      }
    }
    return QueryLogBatch(
      entries: merged,
      nextCursor: nextBySource.isEmpty ? null : QueryLogCursor(nextBySource),
    );
  }

  @override
  Future<String> version() async {
    if (clients.isEmpty) return 'No instances';
    return 'Unified (${clients.length} instance${clients.length == 1 ? '' : 's'})';
  }

  Future<ToggleState> _aggregate(
    Future<bool> Function(AdGuardHome) read,
  ) async {
    if (clients.isEmpty) return ToggleState.off;
    final values = await Future.wait(clients.map(read));
    return toggleStateFromBools(values);
  }

  Future<void> _fanOut(Future<void> Function(AdGuardHome) write) async {
    await Future.wait(clients.map(write));
  }

  @override
  Future<ToggleState> protectionEnabled() =>
      _aggregate((c) => c.protectionEnabled());

  @override
  Future<ProtectionSummary> protectionSummary() async {
    if (clients.isEmpty) {
      return const ProtectionSummary(state: ToggleState.off);
    }
    final infos = await Future.wait(clients.map((c) => c.protectionInfo()));
    final state = toggleStateFromBools(infos.map((info) => info.enabled));
    final durations = infos
        .map((info) => info.remaining)
        .whereType<Duration>()
        .toList();
    final remaining = state.isOff && durations.length == infos.length
        ? durations.reduce((a, b) => a < b ? a : b)
        : null;
    return ProtectionSummary(state: state, remaining: remaining);
  }

  @override
  Future<void> setProtection(bool value, {Duration? pauseFor}) =>
      _fanOut((c) => c.setProtection(value, pauseFor: pauseFor));

  @override
  Future<ToggleState> safeBrowsingEnabled() =>
      _aggregate((c) => c.safeBrowsing.enabled());

  @override
  Future<void> setSafeBrowsing(bool value) => _fanOut(
    (c) => value ? c.safeBrowsing.enable() : c.safeBrowsing.disable(),
  );

  @override
  Future<ToggleState> parentalEnabled() =>
      _aggregate((c) => c.parental.enabled());

  @override
  Future<void> setParental(bool value) =>
      _fanOut((c) => value ? c.parental.enable() : c.parental.disable());

  @override
  Future<ToggleState> safeSearchEnabled() =>
      _aggregate((c) => c.safeSearch.enabled());

  @override
  Future<void> setSafeSearch(bool value) =>
      _fanOut((c) => c.safeSearch.setEnabled(value));

  @override
  Future<List<String>> getUserRules() async {
    if (clients.isEmpty) return const [];
    return clients.first.filtering.getUserRules();
  }

  @override
  Future<void> setUserRules(List<String> rules) =>
      _fanOut((c) => c.filtering.setUserRules(rules));

  @override
  Future<void> addUserRule(String rule) async {
    await _fanOut((c) async {
      final rules = await c.filtering.getUserRules();
      if (!rules.contains(rule)) {
        rules.add(rule);
        await c.filtering.setUserRules(rules);
      }
    });
  }

  @override
  Future<void> removeUserRule(String rule) async {
    await _fanOut((c) async {
      final rules = await c.filtering.getUserRules();
      if (rules.contains(rule)) {
        rules.remove(rule);
        await c.filtering.setUserRules(rules);
      }
    });
  }

  @override
  Future<List<BlockedService>> getAvailableBlockedServices() async {
    if (clients.isEmpty) return const [];
    return clients.first.blockedServices.getAvailableServices();
  }

  @override
  Future<List<String>> getBlockedServices() async {
    if (clients.isEmpty) return const [];
    return clients.first.blockedServices.getBlockedServices();
  }

  @override
  Future<void> updateBlockedServices(List<String> serviceIds) async {
    await _fanOut((c) => c.blockedServices.updateBlockedServices(serviceIds));
  }

  @override
  Future<BlockedServicesSchedule> getBlockedServicesSchedule() async {
    if (clients.isEmpty) return const BlockedServicesSchedule(ids: []);
    return clients.first.blockedServices.getSchedule();
  }

  @override
  Future<void> updateBlockedServicesSchedule(Schedule schedule) =>
      _fanOut((c) => c.blockedServices.updateSchedule(schedule));

  @override
  Future<List<RewriteEntry>> getRewrites() async {
    if (clients.isEmpty) return const [];
    final lists = await Future.wait(
      clients.map((c) => c.rewrite.getRewrites()),
    );
    final merged = <RewriteEntry>[];
    final seen = <String>{};
    for (final list in lists) {
      for (final item in list) {
        final key = '${item.domain}_${item.answer}';
        if (!seen.contains(key)) {
          seen.add(key);
          merged.add(item);
        }
      }
    }
    return merged;
  }

  @override
  Future<void> addRewrite(String domain, String answer) =>
      _fanOut((c) => c.rewrite.addRewrite(domain, answer));

  @override
  Future<void> deleteRewrite(String domain, String answer) =>
      _fanOut((c) => c.rewrite.deleteRewrite(domain, answer));

  @override
  Future<void> updateRewrite(RewriteEntry target, RewriteEntry update) =>
      _fanOut((c) => c.rewrite.updateRewrite(target, update));

  @override
  Future<FilterStatus> getFilteringStatus() async {
    if (clients.isEmpty) return const FilterStatus(enabled: false);
    return clients.first.filtering.getStatus();
  }

  @override
  Future<void> addFilter(String name, String url, bool whitelist) =>
      _fanOut((c) => c.filtering.addFilter(name, url, whitelist));

  @override
  Future<void> removeFilter(String url, bool whitelist) =>
      _fanOut((c) => c.filtering.removeFilter(url, whitelist));

  @override
  Future<void> toggleFilter(
    String url,
    String name,
    bool enabled,
    bool whitelist,
  ) => _fanOut((c) => c.filtering.toggleFilter(url, name, enabled, whitelist));

  @override
  Future<void> refreshFilters() => _fanOut((c) => c.filtering.refreshFilters());

  @override
  Future<Clients> getClients() async {
    if (clients.isEmpty) {
      return const Clients(clients: [], autoClients: [], supportedTags: []);
    }
    final results = await Future.wait(
      clients.map((c) => c.clientsHandler.getClients()),
    );
    final allConfigured = <Client>[];
    final seenNames = <String>{};
    for (final res in results) {
      final clientsList = res.clients;
      if (clientsList != null) {
        for (final c in clientsList) {
          final cname = c.name;
          if (cname != null && !seenNames.contains(cname)) {
            seenNames.add(cname);
            allConfigured.add(c);
          }
        }
      }
    }
    return Clients(
      clients: allConfigured,
      autoClients: results.first.autoClients,
      supportedTags: results.first.supportedTags,
    );
  }

  @override
  Future<void> addClient(Client newClient) =>
      _fanOut((c) => c.clientsHandler.addClient(newClient));

  @override
  Future<void> updateClient(String originalName, Client updatedClient) =>
      _fanOut(
        (c) => c.clientsHandler.updateClient(originalName, updatedClient),
      );

  @override
  Future<void> deleteClient(String name) =>
      _fanOut((c) => c.clientsHandler.deleteClient(name));

  Never _configurationUnsupported() => throw UnsupportedError(
    'Select a single instance to edit server configuration.',
  );

  @override
  Future<GetQueryLogConfigResponse> getQueryLogConfig() async =>
      _configurationUnsupported();

  @override
  Future<void> updateQueryLogConfig(GetQueryLogConfigResponse config) async =>
      _configurationUnsupported();

  @override
  Future<void> clearQueryLog() async => _configurationUnsupported();

  @override
  Future<GetStatsConfigResponse> getStatsConfig() async =>
      _configurationUnsupported();

  @override
  Future<void> updateStatsConfig(GetStatsConfigResponse config) async =>
      _configurationUnsupported();

  @override
  Future<void> resetStats() async => _configurationUnsupported();

  @override
  Future<GetDnsInfoResponse> getDnsInfo() async => _configurationUnsupported();

  @override
  Future<Map<String, String>> testUpstreams(GetDnsInfoResponse config) async =>
      _configurationUnsupported();

  @override
  Future<void> clearDnsCache() async => _configurationUnsupported();
}

StatsSnapshot _mergeSnapshots(List<StatsSnapshot> snaps) {
  if (snaps.isEmpty) return _emptySnapshot;

  int sumInt(int Function(StatsSnapshot) f) =>
      snaps.fold<int>(0, (a, s) => a + f(s));
  Map<String, int> mergeMap(Map<String, int> Function(StatsSnapshot) f) {
    final merged = <String, int>{};
    for (final s in snaps) {
      f(s).forEach((k, v) => merged[k] = (merged[k] ?? 0) + v);
    }
    final entries = merged.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }

  Map<String, double> mergeUpstreamLatency() {
    final weightedSums = <String, double>{};
    final responseCounts = <String, int>{};
    for (final snapshot in snaps) {
      for (final entry in snapshot.topUpstreamsAvgTime.entries) {
        final count = snapshot.topUpstreamsResponses[entry.key] ?? 0;
        if (count <= 0) continue;
        weightedSums[entry.key] =
            (weightedSums[entry.key] ?? 0) + entry.value * count;
        responseCounts[entry.key] = (responseCounts[entry.key] ?? 0) + count;
      }
    }
    final entries = weightedSums.entries.map((entry) {
      return MapEntry(entry.key, entry.value / responseCounts[entry.key]!);
    }).toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }

  List<int> zipSum(List<int> Function(StatsSnapshot) f) {
    final all = snaps.map(f).toList();
    if (all.isEmpty) return [];
    final maxLen = all.map((s) => s.length).reduce(max);
    final result = List<int>.filled(maxLen, 0);
    for (final list in all) {
      final offset = maxLen - list.length;
      for (int i = 0; i < list.length; i++) {
        result[offset + i] += list[i];
      }
    }
    return result;
  }

  final totalQueries = sumInt((s) => s.dnsQueries);
  final totalBlocked = sumInt((s) => s.blockedFiltering);
  final blockedPct = totalQueries > 0
      ? double.parse((totalBlocked / totalQueries * 100).toStringAsFixed(2))
      : 0.0;
  final weightedAvg = totalQueries > 0
      ? double.parse(
          (snaps.fold<double>(
                    0,
                    (a, s) => a + s.avgProcessingTime * s.dnsQueries,
                  ) /
                  totalQueries)
              .toStringAsFixed(2),
        )
      : 0.0;

  return StatsSnapshot(
    dnsQueries: totalQueries,
    blockedFiltering: totalBlocked,
    blockedPercentage: blockedPct,
    replacedSafebrowsing: sumInt((s) => s.replacedSafebrowsing),
    replacedParental: sumInt((s) => s.replacedParental),
    replacedSafesearch: sumInt((s) => s.replacedSafesearch),
    avgProcessingTime: weightedAvg,
    period: snaps.map((s) => s.period).fold<int>(0, max),
    topQueriedDomains: mergeMap((s) => s.topQueriedDomains),
    topBlockedDomains: mergeMap((s) => s.topBlockedDomains),
    topClients: mergeMap((s) => s.topClients),
    topUpstreamsResponses: mergeMap((s) => s.topUpstreamsResponses),
    topUpstreamsAvgTime: mergeUpstreamLatency(),
    dnsQueriesPerDay: zipSum((s) => s.dnsQueriesPerDay),
    blockedFilteringPerDay: zipSum((s) => s.blockedFilteringPerDay),
    replacedSafebrowsingPerDay: zipSum((s) => s.replacedSafebrowsingPerDay),
    replacedParentalPerDay: zipSum((s) => s.replacedParentalPerDay),
  );
}

final StatsSnapshot _emptySnapshot = StatsSnapshot(
  dnsQueries: 0,
  blockedFiltering: 0,
  blockedPercentage: 0,
  replacedSafebrowsing: 0,
  replacedParental: 0,
  replacedSafesearch: 0,
  avgProcessingTime: 0,
  period: 0,
  topQueriedDomains: const {},
  topBlockedDomains: const {},
  topClients: const {},
  topUpstreamsResponses: const {},
  topUpstreamsAvgTime: const {},
  dnsQueriesPerDay: const [],
  blockedFilteringPerDay: const [],
  replacedSafebrowsingPerDay: const [],
  replacedParentalPerDay: const [],
);
