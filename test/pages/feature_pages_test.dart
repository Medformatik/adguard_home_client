import 'package:adguard_home_client/interface/adguardhome.dart';
import 'package:adguard_home_client/generated_api/export.dart';
import 'package:adguard_home_client/main.dart' as app;
import 'package:adguard_home_client/pages/blocked_services_schedule.dart';
import 'package:adguard_home_client/pages/clients.dart';
import 'package:adguard_home_client/pages/dns_tools.dart';
import 'package:adguard_home_client/pages/filters.dart';
import 'package:adguard_home_client/pages/home.dart';
import 'package:adguard_home_client/pages/privacy_settings.dart';
import 'package:adguard_home_client/pages/querylog.dart';
import 'package:adguard_home_client/utils/datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    final client = AdGuardHome(
      host: 'demo.demo.demo',
      username: 'demo',
      password: 'demo',
    );
    app.adGuardHome = client;
    app.dataSource = SingleDataSource(client);
    app.protectionStatus.value = ToggleState.loading;
  });

  tearDown(() {
    app.adGuardHome = null;
    app.dataSource = null;
  });

  testWidgets('clients distinguish inherited policy from explicit settings', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ClientsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Inherits global protection'), findsNWidgets(2));
    expect(find.text('AdBlock'), findsOneWidget);
  });

  testWidgets('filter action follows the selected tab', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FiltersPage()));
    await tester.pumpAndSettle();
    expect(find.text('Add Blocklist'), findsOneWidget);

    await tester.tap(find.text('Whitelists'));
    await tester.pumpAndSettle();

    expect(find.text('Add Whitelist'), findsOneWidget);
  });

  testWidgets('query log exposes reason filters', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: QueryLogPage()));
    await tester.pumpAndSettle();

    expect(find.text('Allowed'), findsWidgets);
    expect(find.text('Blocked'), findsWidgets);
    expect(find.text('Rewritten'), findsOneWidget);
  });

  testWidgets('privacy settings expose query-log controls', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacySettingsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Privacy & retention'), findsOneWidget);
    expect(find.text('Query log'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsWidgets);
    expect(find.byType(DropdownButtonFormField<num>), findsWidgets);
  });

  testWidgets('DNS diagnostics expose upstream test and cache actions', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DnsToolsPage()));
    await tester.pumpAndSettle();

    expect(find.textContaining('tls://1.1.1.1'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(find.text('Test upstream DNS servers'), findsOneWidget);
    expect(find.text('Clear DNS cache'), findsOneWidget);
  });

  testWidgets('upstream results scroll without overflowing a compact screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(411, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UpstreamTestResultsSheet(
            results: {
              for (var i = 1; i <= 10; i++) 'resolver-$i.example': 'OK',
            },
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Upstream test results'), findsOneWidget);
    expect(find.text('resolver-1.example'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('resolver-10.example'), findsOneWidget);
  });

  testWidgets('home exposes the timed-pause action', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final pauseButton = find.byIcon(Icons.timer_outlined);
    expect(pauseButton, findsOneWidget);
  });

  testWidgets('service schedule explains and renders allowed periods', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BlockedServicesSchedulePage(
          schedule: Schedule(
            timeZone: 'Europe/Berlin',
            mon: DayRange(start: 32400000, end: 61200000),
          ),
        ),
      ),
    );

    expect(find.text('Allowed periods'), findsOneWidget);
    expect(find.text('09:00–17:00'), findsOneWidget);
    expect(find.text('Europe/Berlin'), findsOneWidget);
  });
}
