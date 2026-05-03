import 'package:adguard_home_client/interface/adguardhome.dart';

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
      time: DateTime.tryParse(j['time']?.toString() ?? '')?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0),
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

  Future<List<QueryLogEntry>> recent({int limit = 100, String? olderThan, String? search}) async {
    final params = <String, String>{'limit': '$limit'};
    if (olderThan != null) params['older_than'] = olderThan;
    if (search != null && search.isNotEmpty) params['search'] = search;
    final response = await _adGuardHome.request('querylog', params: params);
    final raw = (response['data'] as List?) ?? const [];
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>) QueryLogEntry.fromJson(entry),
    ];
  }
}
