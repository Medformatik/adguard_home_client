import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

const String _instancesBoxName = 'instances';
const String _settingsBoxName = 'settings';
const String _activeIdKey = 'activeInstanceId';
const String _migratedKey = 'migratedToMultiInstance';
const FlutterSecureStorage _secure = FlutterSecureStorage();

class Instance {
  final String id;
  String name;
  String host;
  int port;
  bool tls;
  bool verifySsl;
  String username;

  Instance({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    this.tls = false,
    this.verifySsl = true,
    required this.username,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'host': host,
        'port': port,
        'tls': tls,
        'verifySsl': verifySsl,
        'username': username,
      };

  factory Instance.fromMap(String id, Map data) {
    return Instance(
      id: id,
      name: (data['name'] ?? '').toString(),
      host: (data['host'] ?? '').toString(),
      port: (data['port'] ?? 3000) as int,
      tls: (data['tls'] ?? false) as bool,
      verifySsl: (data['verifySsl'] ?? true) as bool,
      username: (data['username'] ?? '').toString(),
    );
  }
}

class Instances {
  static Box get _box => Hive.box(_instancesBoxName);
  static Box get _settings => Hive.box(_settingsBoxName);

  static String generateId() {
    final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final salt = Random().nextInt(0xffff).toRadixString(16).padLeft(4, '0');
    return '$ts-$salt';
  }

  static List<Instance> list() {
    final keys = _box.keys.cast<String>().toList()..sort();
    return [
      for (final key in keys)
        if (_box.get(key) is Map) Instance.fromMap(key, Map<String, dynamic>.from(_box.get(key) as Map)),
    ];
  }

  static Instance? get(String id) {
    final raw = _box.get(id);
    if (raw is! Map) return null;
    return Instance.fromMap(id, Map<String, dynamic>.from(raw));
  }

  static Future<void> save(Instance instance) async {
    await _box.put(instance.id, instance.toMap());
  }

  static Future<void> delete(String id) async {
    await _box.delete(id);
    await _secure.delete(key: _passwordKey(id));
    if (getActiveId() == id) {
      final remaining = list();
      await setActiveId(remaining.isEmpty ? null : remaining.first.id);
    }
  }

  static String? getActiveId() => _settings.get(_activeIdKey) as String?;

  static Future<void> setActiveId(String? id) async {
    if (id == null) {
      await _settings.delete(_activeIdKey);
    } else {
      await _settings.put(_activeIdKey, id);
    }
  }

  static String _passwordKey(String id) => 'instance:$id:password';
  static Future<String?> getPassword(String id) => _secure.read(key: _passwordKey(id));
  static Future<void> setPassword(String id, String value) => _secure.write(key: _passwordKey(id), value: value);

  /// Migrate single-instance settings (host/port/username/password + tls/verifySsl
  /// stored under flat keys in `settings` + secure key `password`) into the new
  /// instances repository. Idempotent.
  static Future<void> migrateLegacy() async {
    if (_settings.get(_migratedKey) == true) return;
    final oldHost = _settings.get('host') as String?;
    final oldPort = _settings.get('port') as int?;
    final oldUser = _settings.get('username') as String?;

    if (oldHost != null && oldPort != null && oldUser != null && _box.isEmpty) {
      final id = generateId();
      final instance = Instance(
        id: id,
        name: 'Default',
        host: oldHost,
        port: oldPort,
        tls: (_settings.get('tls') ?? false) as bool,
        verifySsl: (_settings.get('verifySsl') ?? true) as bool,
        username: oldUser,
      );
      await save(instance);
      final pass = await _secure.read(key: 'password');
      if (pass != null) {
        await setPassword(id, pass);
      }
      await setActiveId(id);
    }
    await _settings.put(_migratedKey, true);
  }
}
