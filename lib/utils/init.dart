import 'package:adguard_home_client/interface/adguardhome.dart';
import 'package:adguard_home_client/main.dart';
import 'package:adguard_home_client/utils/datasource.dart';
import 'package:adguard_home_client/utils/instances.dart';
import 'package:flutter/foundation.dart';

/// Build [adGuardHome] and [dataSource] for the active instance (or for
/// [switchTo] if given). Use [Instances.unifiedId] to switch into unified mode.
///
/// Returns true on a successful connection (or unified mode with at least one
/// reachable instance), false otherwise. Globals are cleared on failure.
Future<bool> initAdGuardHome({String? switchTo}) async {
  if (switchTo != null) {
    await Instances.setActiveId(switchTo);
  }
  final id = Instances.getActiveId();

  await _closeExisting();

  if (id == null) {
    adGuardHome = null;
    dataSource = null;
    return false;
  }

  if (id == Instances.unifiedId) {
    final instances = Instances.list();
    if (instances.isEmpty) {
      adGuardHome = null;
      dataSource = null;
      return false;
    }
    final clients = <AdGuardHome>[];
    final names = <String>[];
    for (final instance in instances) {
      final password = await Instances.getPassword(instance.id) ?? '';
      clients.add(AdGuardHome(
        host: instance.host,
        port: instance.port,
        tls: instance.tls,
        verifySsl: instance.verifySsl,
        username: instance.username,
        password: password,
      ));
      names.add(instance.name);
    }
    adGuardHome = clients.first; // legacy callers; not load-bearing
    dataSource = UnifiedDataSource(clients, names);
    debugPrint('Initialized unified DataSource over ${clients.length} instance(s)');
    final results = await Future.wait(clients.map((c) => c.successfullyConnected()));
    return results.any((ok) => ok);
  }

  final instance = Instances.get(id);
  if (instance == null) {
    adGuardHome = null;
    dataSource = null;
    return false;
  }
  final password = await Instances.getPassword(id) ?? '';

  debugPrint('Initializing AdGuardHome for instance "${instance.name}"');

  final client = AdGuardHome(
    host: instance.host,
    port: instance.port,
    tls: instance.tls,
    verifySsl: instance.verifySsl,
    username: instance.username,
    password: password,
  );
  adGuardHome = client;
  dataSource = SingleDataSource(client);

  return await client.successfullyConnected();
}

Future<void> _closeExisting() async {
  final ds = dataSource;
  if (ds != null) {
    await Future.wait(ds.clients.map((c) => c.close()));
  } else {
    await adGuardHome?.close();
  }
}
