import 'package:adguard_home_client/generated_api/export.dart';
import 'package:adguard_home_client/interface/adguardhome.dart';
import 'package:adguard_home_client/interface/querylog.dart';
import 'package:adguard_home_client/utils/datasource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AdGuardHome client;

  setUp(() {
    client = AdGuardHome(
      host: 'demo.demo.demo',
      username: 'demo',
      password: 'demo',
    );
  });

  test('demo exposes complete dashboard and query-log data', () async {
    final snapshot = await client.stats.snapshot();
    final log = await client.queryLog.recent(search: 'doubleclick');

    expect(snapshot.period, 90);
    expect(snapshot.dnsQueries, greaterThan(0));
    expect(snapshot.topQueriedDomains, isNotEmpty);
    expect(snapshot.topUpstreamsResponses, isNotEmpty);
    expect(snapshot.topUpstreamsAvgTime.values.first, greaterThan(0));
    expect(log.entries, hasLength(1));
    expect(log.entries.single.blocked, isTrue);
  });

  test('demo supports timed protection pauses', () async {
    await client.setProtection(false, pauseFor: const Duration(minutes: 5));

    final paused = await client.protectionInfo();
    expect(paused.enabled, isFalse);
    expect(paused.remaining, isNotNull);
    expect(paused.remaining!.inMinutes, greaterThanOrEqualTo(4));

    await client.setProtection(true);
    final resumed = await client.protectionInfo();
    expect(resumed.enabled, isTrue);
    expect(resumed.remaining, isNull);
  });

  test('demo query log filters by response reason', () async {
    final allowed = await client.queryLog.recent(
      reasonFilter: QueryLogReasonFilter.allowed,
    );
    final blocked = await client.queryLog.recent(
      reasonFilter: QueryLogReasonFilter.blocked,
    );

    expect(allowed.entries, isNotEmpty);
    expect(allowed.entries.every((entry) => !entry.blocked), isTrue);
    expect(blocked.entries, isNotEmpty);
    expect(blocked.entries.every((entry) => entry.blocked), isTrue);
  });

  test('demo query log pagination does not repeat entries', () async {
    final first = await client.queryLog.recent(limit: 2);
    final second = await client.queryLog.recent(
      limit: 2,
      olderThan: first.nextCursor?.bySource[''],
    );

    expect(first.entries, hasLength(2));
    expect(first.nextCursor, isNotNull);
    expect(second.entries, hasLength(2));
    expect(
      second.entries.map((entry) => entry.question),
      isNot(contains(first.entries.first.question)),
    );
  });

  test('demo persists blocked-service schedule changes', () async {
    const schedule = Schedule(
      timeZone: 'Europe/Berlin',
      mon: DayRange(start: 32400000, end: 61200000),
    );

    await client.blockedServices.updateSchedule(schedule);
    final result = await client.blockedServices.getSchedule();
    expect(result.schedule?.timeZone, 'Europe/Berlin');
    expect(result.schedule?.mon?.start, 32400000);
  });

  test('demo exposes DNS diagnostics and upstream tests', () async {
    final info = await client.dns.info();
    final results = await client.dns.testUpstreams(info);

    expect(info.upstreamDns, isNotEmpty);
    expect(results.values, everyElement('OK'));
  });

  test('unified statistics aggregate upstream counts and latency', () async {
    final second = AdGuardHome(
      host: 'demo.demo.demo',
      username: 'demo',
      password: 'demo',
    );
    final single = await client.stats.snapshot();
    final unified = await UnifiedDataSource(
      [client, second],
      ['First', 'Second'],
    ).snapshot();

    final upstream = single.topUpstreamsResponses.keys.first;
    expect(
      unified.topUpstreamsResponses[upstream],
      single.topUpstreamsResponses[upstream]! * 2,
    );
    expect(
      unified.topUpstreamsAvgTime[upstream],
      single.topUpstreamsAvgTime[upstream],
    );
  });

  test('unified query log honors source filtering', () async {
    final second = AdGuardHome(
      host: 'demo.demo.demo',
      username: 'demo',
      password: 'demo',
    );
    final source = UnifiedDataSource([client, second], ['First', 'Second']);

    final batch = await source.queryLog(limit: 3, source: 'Second');
    expect(batch.entries, hasLength(3));
    expect(batch.entries.every((entry) => entry.source == 'Second'), isTrue);
  });

  test(
    'demo DNS rewrite can be toggled without changing its identity',
    () async {
      final original = (await client.rewrite.getRewrites()).first;
      final updated = RewriteEntry(
        domain: original.domain,
        answer: original.answer,
        enabled: !original.enabled,
      );

      await client.rewrite.updateRewrite(original, updated);
      final result = (await client.rewrite.getRewrites()).first;
      expect(result.domain, original.domain);
      expect(result.answer, original.answer);
      expect(result.enabled, updated.enabled);

      await client.rewrite.updateRewrite(updated, original);
    },
  );
}
