import 'package:adguard_home_client/interface/adguardhome.dart';
import 'package:adguard_home_client/generated_api/export.dart';

class AdGuardHomeRewrite {
  final AdGuardHome _client;

  AdGuardHomeRewrite(this._client);

  /// Fetch DNS Rewrites list
  Future<List<RewriteEntry>> getRewrites() async {
    if (_client.isDemo) {
      return _demoRewrites;
    }
    return _client.restClient.rewrite.rewriteList();
  }

  /// Add a DNS Rewrite rule
  Future<void> addRewrite(String domain, String answer) async {
    if (_client.isDemo) {
      _demoRewrites.add(
        RewriteEntry(domain: domain, answer: answer, enabled: true),
      );
      return;
    }
    await _client.restClient.rewrite.rewriteAdd(
      body: RewriteEntry(domain: domain, answer: answer, enabled: true),
    );
  }

  /// Delete a DNS Rewrite rule
  Future<void> deleteRewrite(String domain, String answer) async {
    if (_client.isDemo) {
      _demoRewrites.removeWhere(
        (e) => e.domain == domain && e.answer == answer,
      );
      return;
    }
    await _client.restClient.rewrite.rewriteDelete(
      body: RewriteEntry(domain: domain, answer: answer),
    );
  }

  Future<void> updateRewrite(RewriteEntry target, RewriteEntry update) async {
    if (_client.isDemo) {
      final index = _demoRewrites.indexWhere(
        (entry) =>
            entry.domain == target.domain && entry.answer == target.answer,
      );
      if (index != -1) _demoRewrites[index] = update;
      return;
    }
    await _client.restClient.rewrite.rewriteUpdate(
      body: RewriteUpdate(target: target, update: update),
    );
  }

  static final List<RewriteEntry> _demoRewrites = [
    const RewriteEntry(
      domain: 'router.lan',
      answer: '192.168.1.1',
      enabled: true,
    ),
    const RewriteEntry(
      domain: 'nas.local',
      answer: '192.168.1.100',
      enabled: true,
    ),
    const RewriteEntry(
      domain: 'pi.hole',
      answer: '192.168.1.250',
      enabled: true,
    ),
    const RewriteEntry(
      domain: 'my-service.local',
      answer: '10.0.0.5',
      enabled: true,
    ),
  ];
}
