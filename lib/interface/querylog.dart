import 'package:adguard_home_client/interface/adguardhome.dart';
import 'package:adguard_home_client/generated_api/export.dart';

enum QueryLogReasonFilter { all, allowed, blocked, rewritten }

extension QueryLogReasonFilterValues on QueryLogReasonFilter {
  List<FilteringReason>? get apiReasons => switch (this) {
    QueryLogReasonFilter.all => null,
    QueryLogReasonFilter.allowed => const [
      FilteringReason.notFilteredNotFound,
      FilteringReason.notFilteredWhiteList,
      FilteringReason.notFilteredError,
    ],
    QueryLogReasonFilter.blocked => const [
      FilteringReason.filteredBlackList,
      FilteringReason.filteredSafeBrowsing,
      FilteringReason.filteredParental,
      FilteringReason.filteredInvalid,
      FilteringReason.filteredSafeSearch,
      FilteringReason.filteredBlockedService,
    ],
    QueryLogReasonFilter.rewritten => const [
      FilteringReason.rewrite,
      FilteringReason.rewriteEtcHosts,
      FilteringReason.rewriteRule,
    ],
  };
}

class QueryLogCursor {
  const QueryLogCursor(this.bySource);

  final Map<String, String?> bySource;
}

class QueryLogBatch {
  const QueryLogBatch({required this.entries, this.nextCursor});

  final List<QueryLogEntry> entries;
  final QueryLogCursor? nextCursor;
}

class QueryLogEntry {
  final DateTime time;
  final String client;
  final String question;
  final String questionType;
  final String reason;
  final int elapsedMs;
  final String? rule;
  final List<String> answers;

  /// Set by [UnifiedDataSource] to identify the originating instance.
  /// Null for single-instance views.
  String? source;

  QueryLogEntry({
    required this.time,
    required this.client,
    required this.question,
    required this.questionType,
    required this.reason,
    required this.elapsedMs,
    required this.rule,
    required this.answers,
    this.source,
  });

  bool get blocked => reason.startsWith('Filtered');

  factory QueryLogEntry.fromJson(Map<String, dynamic> j) {
    final question = (j['question'] as Map?) ?? const {};
    final answerList = (j['answer'] as List?) ?? const [];
    return QueryLogEntry(
      time:
          DateTime.tryParse(j['time']?.toString() ?? '')?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      client: (j['client'] ?? '').toString(),
      question: (question['name'] ?? '').toString(),
      questionType: (question['type'] ?? '').toString(),
      reason: (j['reason'] ?? '').toString(),
      elapsedMs: _parseElapsedMs(j['elapsedMs']),
      rule: j['rule']?.toString(),
      answers: [
        for (final a in answerList)
          if (a is Map && a['value'] != null) a['value'].toString(),
      ],
    );
  }

  factory QueryLogEntry.fromApi(QueryLogItem item) {
    return QueryLogEntry(
      time:
          DateTime.tryParse(item.time ?? '')?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      client: item.client ?? '',
      question: item.question?.unicodeName ?? item.question?.name ?? '',
      questionType: item.question?.type ?? '',
      reason: item.reason?.json ?? '',
      elapsedMs: _parseElapsedMs(item.elapsedMs),
      rule: item.rules?.isNotEmpty == true ? item.rules!.first.text : item.rule,
      answers: [
        for (final answer in item.answer ?? const <DnsAnswer>[])
          if (answer.value != null) answer.value!,
      ],
    );
  }

  static int _parseElapsedMs(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.round();
    final parsed = double.tryParse(value.toString());
    return parsed == null ? 0 : parsed.round();
  }
}

class AdGuardHomeQueryLog {
  final AdGuardHome _adGuardHome;
  AdGuardHomeQueryLog(this._adGuardHome);

  Future<QueryLogBatch> recent({
    int limit = 100,
    String? olderThan,
    String? search,
    QueryLogReasonFilter reasonFilter = QueryLogReasonFilter.all,
  }) async {
    if (_adGuardHome.isDemo) {
      final params = <String, String>{'limit': '$limit'};
      if (search != null && search.isNotEmpty) params['search'] = search;
      final response = await _adGuardHome.request('querylog', params: params);
      final raw = (response['data'] as List?) ?? const [];
      final allEntries =
          [
                for (final item in raw)
                  if (item is Map)
                    QueryLogEntry.fromJson(Map<String, dynamic>.from(item)),
              ]
              .where((entry) {
                final reasons = reasonFilter.apiReasons;
                return reasons == null ||
                    reasons.any((reason) => reason.json == entry.reason);
              })
              .where((entry) {
                final cursor = DateTime.tryParse(olderThan ?? '');
                return cursor == null || entry.time.isBefore(cursor);
              })
              .toList();
      final entries = allEntries.take(limit).toList();
      return QueryLogBatch(
        entries: entries,
        nextCursor: allEntries.length > entries.length && entries.isNotEmpty
            ? QueryLogCursor({'': entries.last.time.toUtc().toIso8601String()})
            : null,
      );
    }

    final response = await _adGuardHome.restClient.log.queryLog(
      olderThan: olderThan,
      limit: limit,
      search: search?.isEmpty == true ? null : search,
      reason: reasonFilter.apiReasons,
    );
    final entries = [
      for (final item in response.data ?? const <QueryLogItem>[])
        QueryLogEntry.fromApi(item),
    ];
    return QueryLogBatch(
      entries: entries,
      nextCursor: entries.isNotEmpty && response.oldest != null
          ? QueryLogCursor({'': response.oldest})
          : null,
    );
  }

  Future<GetQueryLogConfigResponse> config() async {
    if (_adGuardHome.isDemo) {
      return const GetQueryLogConfigResponse(
        enabled: true,
        interval: 604800000,
        anonymizeClientIp: false,
        ignored: [],
        ignoredEnabled: false,
      );
    }
    return _adGuardHome.restClient.log.getQueryLogConfig();
  }

  Future<void> updateConfig(GetQueryLogConfigResponse config) async {
    if (_adGuardHome.isDemo) return;
    await _adGuardHome.restClient.log.putQueryLogConfig(body: config);
  }

  Future<void> clear() async {
    if (_adGuardHome.isDemo) return;
    await _adGuardHome.restClient.log.querylogClear();
  }
}
