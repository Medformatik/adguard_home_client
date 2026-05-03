import 'dart:math';

import 'package:adguard_home_client/interface/adguardhome.dart';
import 'package:adguard_home_client/interface/querylog.dart';
import 'package:adguard_home_client/interface/stats.dart';

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

abstract class DataSource {
  /// True when this datasource fans out to multiple instances.
  bool get isUnified;

  /// Underlying live clients. Single → 1, unified → N (may be empty if no instances).
  List<AdGuardHome> get clients;

  /// Drop any cached stats so the next [snapshot] performs a fresh fetch.
  void invalidateStats();

  Future<StatsSnapshot> snapshot();
  Future<List<QueryLogEntry>> queryLog({int limit = 100, String? search});
  Future<String> version();

  Future<ToggleState> protectionEnabled();
  Future<void> setProtection(bool value);

  Future<ToggleState> safeBrowsingEnabled();
  Future<void> setSafeBrowsing(bool value);

  Future<ToggleState> parentalEnabled();
  Future<void> setParental(bool value);

  Future<ToggleState> safeSearchEnabled();
  Future<void> setSafeSearch(bool value);
}

class SingleDataSource implements DataSource {
  final AdGuardHome client;
  SingleDataSource(this.client);

  @override
  bool get isUnified => false;

  @override
  List<AdGuardHome> get clients => [client];

  @override
  void invalidateStats() => client.stats.refresh();

  @override
  Future<StatsSnapshot> snapshot() => client.stats.snapshot();

  @override
  Future<List<QueryLogEntry>> queryLog({int limit = 100, String? search}) =>
      client.queryLog.recent(limit: limit, search: search);

  @override
  Future<String> version() => client.version();

  @override
  Future<ToggleState> protectionEnabled() async =>
      (await client.protectionEnabled()) ? ToggleState.on : ToggleState.off;

  @override
  Future<void> setProtection(bool value) =>
      value ? client.enableProtection() : client.disableProtection();

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
}

class UnifiedDataSource implements DataSource {
  @override
  final List<AdGuardHome> clients;

  /// Per-instance display names, parallel to [clients]. Used to tag query log entries.
  final List<String> names;

  UnifiedDataSource(this.clients, this.names) : assert(clients.length == names.length);

  @override
  bool get isUnified => true;

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
  Future<List<QueryLogEntry>> queryLog({int limit = 100, String? search}) async {
    if (clients.isEmpty) return const [];
    final perInstance = await Future.wait([
      for (int i = 0; i < clients.length; i++)
        clients[i].queryLog.recent(limit: limit, search: search).then((entries) {
          // Tag the source instance name for display.
          for (final e in entries) {
            e.source = names[i];
          }
          return entries;
        }),
    ]);
    final merged = <QueryLogEntry>[for (final list in perInstance) ...list];
    merged.sort((a, b) => b.time.compareTo(a.time));
    if (merged.length > limit) {
      return merged.sublist(0, limit);
    }
    return merged;
  }

  @override
  Future<String> version() async {
    if (clients.isEmpty) return 'No instances';
    return 'Unified (${clients.length} instance${clients.length == 1 ? '' : 's'})';
  }

  Future<ToggleState> _aggregate(Future<bool> Function(AdGuardHome) read) async {
    if (clients.isEmpty) return ToggleState.off;
    final values = await Future.wait(clients.map(read));
    return toggleStateFromBools(values);
  }

  Future<void> _fanOut(Future<void> Function(AdGuardHome) write) async {
    await Future.wait(clients.map(write));
  }

  @override
  Future<ToggleState> protectionEnabled() => _aggregate((c) => c.protectionEnabled());

  @override
  Future<void> setProtection(bool value) =>
      _fanOut((c) => value ? c.enableProtection() : c.disableProtection());

  @override
  Future<ToggleState> safeBrowsingEnabled() => _aggregate((c) => c.safeBrowsing.enabled());

  @override
  Future<void> setSafeBrowsing(bool value) =>
      _fanOut((c) => value ? c.safeBrowsing.enable() : c.safeBrowsing.disable());

  @override
  Future<ToggleState> parentalEnabled() => _aggregate((c) => c.parental.enabled());

  @override
  Future<void> setParental(bool value) =>
      _fanOut((c) => value ? c.parental.enable() : c.parental.disable());

  @override
  Future<ToggleState> safeSearchEnabled() => _aggregate((c) => c.safeSearch.enabled());

  @override
  Future<void> setSafeSearch(bool value) => _fanOut((c) => c.safeSearch.setEnabled(value));
}

StatsSnapshot _mergeSnapshots(List<StatsSnapshot> snaps) {
  if (snaps.isEmpty) return _emptySnapshot;

  int sumInt(int Function(StatsSnapshot) f) => snaps.fold<int>(0, (a, s) => a + f(s));
  Map<String, int> mergeMap(Map<String, int> Function(StatsSnapshot) f) {
    final merged = <String, int>{};
    for (final s in snaps) {
      f(s).forEach((k, v) => merged[k] = (merged[k] ?? 0) + v);
    }
    final entries = merged.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
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
          (snaps.fold<double>(0, (a, s) => a + s.avgProcessingTime * s.dnsQueries) / totalQueries)
              .toStringAsFixed(2))
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
  dnsQueriesPerDay: const [],
  blockedFilteringPerDay: const [],
  replacedSafebrowsingPerDay: const [],
  replacedParentalPerDay: const [],
);
