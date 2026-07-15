import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:adguard_home_client/interface/blocked_services.dart';
import 'package:adguard_home_client/interface/filtering.dart';
import 'package:adguard_home_client/interface/parental.dart';
import 'package:adguard_home_client/interface/querylog.dart';
import 'package:adguard_home_client/interface/safebrowsing.dart';
import 'package:adguard_home_client/interface/safesearch.dart';
import 'package:adguard_home_client/interface/stats.dart';
import 'package:adguard_home_client/interface/rewrite.dart';
import 'package:adguard_home_client/interface/clients.dart';
import 'package:adguard_home_client/interface/dns.dart';
import 'package:adguard_home_client/generated_api/export.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

class AdGuardHome {
  final String host;
  final String basePath;
  final String? password;
  final int port;
  final int requestTimeout;
  final bool tls;
  final String? userAgent;
  final String? username;
  final bool verifySsl;

  late AdGuardHomeFiltering filtering;
  late AdGuardHomeParental parental;
  late AdGuardHomeQueryLog queryLog;
  late AdGuardHomeSafeBrowsing safeBrowsing;
  late AdGuardHomeSafeSearch safeSearch;
  late AdGuardHomeStats stats;
  late AdGuardHomeBlockedServices blockedServices;
  late AdGuardHomeRewrite rewrite;
  late AdGuardHomeClients clientsHandler;
  late AdGuardHomeDns dns;
  late final RestClient restClient;

  Dio? _session;
  bool _closeSession = false;

  bool get isDemo =>
      host == 'demo.demo.demo' &&
      port == 3000 &&
      username == 'demo' &&
      password == 'demo';
  bool demoProtectionEnabled = true;
  DateTime? demoProtectionPausedUntil;
  bool demoSafeBrowsing = true;
  bool demoParental = false;
  bool demoSafeSearch = true;
  List<String> demoUserRules = [
    '||doubleclick.net^',
    '||malware.example.org^',
    '||adult.example.com^',
    '@@||allowlist.example.com^',
  ];
  List<String> demoBlockedServiceIds = ['tiktok', 'instagram'];
  Schedule demoBlockedServicesSchedule = const Schedule(timeZone: 'Local');

  AdGuardHome({
    required this.host,
    this.basePath = '/control',
    this.password,
    this.port = 3000,
    this.requestTimeout = 10000,
    this.tls = false,
    this.userAgent,
    this.username,
    this.verifySsl = true,
  }) {
    if (!isDemo) {
      final scheme = tls ? 'https' : 'http';
      final baseUrl = '$scheme://$host:$port$basePath';
      final headers = <String, String>{
        'Accept': 'application/json, text/plain, */*',
      };
      if (userAgent != null) {
        headers['User-Agent'] = userAgent!;
      }
      if (username != null && password != null) {
        headers['authorization'] =
            'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      }
      _session = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: Duration(milliseconds: requestTimeout),
          receiveTimeout: Duration(milliseconds: requestTimeout),
          headers: headers,
        ),
      );
      if (tls && !verifySsl) {
        (_session!.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
            () {
              final client = HttpClient();
              client.badCertificateCallback = (cert, host, port) => true;
              return client;
            };
      }
      restClient = RestClient(_session!);
      _closeSession = true;
    } else {
      restClient = RestClient(Dio());
    }

    filtering = AdGuardHomeFiltering(this);
    parental = AdGuardHomeParental(this);
    queryLog = AdGuardHomeQueryLog(this);
    safeBrowsing = AdGuardHomeSafeBrowsing(this);
    safeSearch = AdGuardHomeSafeSearch(this);
    stats = AdGuardHomeStats(this);
    blockedServices = AdGuardHomeBlockedServices(this);
    rewrite = AdGuardHomeRewrite(this);
    clientsHandler = AdGuardHomeClients(this);
    dns = AdGuardHomeDns(this);
  }

  Future<Map<String, dynamic>> request(
    String uri, {
    String method = 'GET',
    dynamic data,
    Map? jsonData,
    Map<String, String>? params,
  }) async {
    /* 
    Handle a request to the AdGuard Home instance.

    Make a request against the AdGuard Home API and handles the response.

    Args:
      uri: The request URI on the AdGuard Home API to call.
      method: HTTP method to use for the request; e.g., GET, POST.
      data: RAW HTTP request data to send with the request.
      json_data: Dictionary of data to send as JSON with the request.
      params: Mapping of request parameters to send with the request.

    Returns:
      The response from the API. In case the response is a JSON response,
      the method will return a decoded JSON response as a Python
      dictionary. In other cases, it will return the RAW text response.

    Raises:
      AdGuardHomeConnectionError: An error occurred while communicating
        with the AdGuard Home instance (connection issues).
      AdGuardHomeError: An error occurred while processing the
        response from the AdGuard Home instance (invalid data).
    */

    if (isDemo) return _demoResponse(uri, data, params);

    String scheme = tls ? 'https' : 'http';
    String url = '$scheme://$host:$port$basePath/$uri';

    String? auth;

    Map<String, String> headers = {
      'Accept': 'application/json, text/plain, */*',
    };

    if (userAgent != null) {
      headers['User-Agent'] = userAgent!;
    }

    if (username != null && password != null) {
      auth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      headers['authorization'] = auth;
    }

    if (_session == null) {
      return {'error': 'Session not initialized'};
    }

    late final Response response;

    try {
      response = await _session!.fetch(
        RequestOptions(
          method: method,
          path: url,
          headers: headers,
          data: data,
          connectTimeout: Duration(milliseconds: requestTimeout),
          queryParameters: params,
        ),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint('AdGuardHome request failed: ${e.response!.statusCode}');
      } else {
        debugPrint('AdGuardHome request error: ${e.message}');
      }
      rethrow;
    }

    String? contentType = response.headers.value('Content-Type');

    if ([4, 5].contains(response.statusCode! ~/ 100)) {
      if (contentType == 'application/json') {
        debugPrint('AdGuardHomeError: ${response.statusCode}');
      }
    }

    if (contentType != null && contentType.contains('application/json')) {
      var data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {
          // Keep it as a raw string if parsing fails
        }
      }
      if (data is List) {
        return {'services': data, 'data': data};
      }
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {'data': data};
    }

    final text = response.data.toString();
    return {'message': text};
  }

  // Return if AdGuard Home protection is enabled or not.
  Future<bool> protectionEnabled() async {
    return (await protectionInfo()).enabled;
  }

  Future<ProtectionInfo> protectionInfo() async {
    if (isDemo) {
      final pauseUntil = demoProtectionPausedUntil;
      if (pauseUntil != null && !pauseUntil.isAfter(DateTime.now())) {
        demoProtectionPausedUntil = null;
        demoProtectionEnabled = true;
      }
      return ProtectionInfo(
        enabled: demoProtectionEnabled,
        remaining: demoProtectionPausedUntil?.difference(DateTime.now()),
      );
    }
    final response = await restClient.global.status();
    final duration = response.protectionDisabledDuration;
    return ProtectionInfo(
      enabled: response.protectionEnabled,
      remaining: duration != null && duration > 0
          ? Duration(milliseconds: duration)
          : null,
    );
  }

  Future<void> setProtection(bool enabled, {Duration? pauseFor}) async {
    if (isDemo) {
      demoProtectionEnabled = enabled;
      demoProtectionPausedUntil = !enabled && pauseFor != null
          ? DateTime.now().add(pauseFor)
          : null;
      return;
    }
    await restClient.global.setProtection(
      body: SetProtectionRequest(
        enabled: enabled,
        duration: enabled ? null : pauseFor?.inMilliseconds,
      ),
    );
  }

  Future<void> enableProtection() async {
    try {
      await setProtection(true);
    } catch (e) {
      debugPrint('AdGuardHomeError: Failed enabling AdGuard Home protection.');
      rethrow;
    }
  }

  Future<void> disableProtection() async {
    try {
      await setProtection(false);
    } catch (e) {
      debugPrint('AdGuardHomeError: Failed disabling AdGuard Home protection.');
      rethrow;
    }
  }

  // Return the current version of the AdGuard Home instance.
  Future<String> version() async {
    if (isDemo) return 'Version: Demo';
    try {
      final response = await restClient.global.status();
      return response.version;
    } catch (_) {
      return 'Version unknown';
    }
  }

  // Returns if the AdGuard Home instance is connected or not
  Future<bool> successfullyConnected() async {
    if (isDemo) return true;
    try {
      await restClient.global.status();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> close() async {
    if (_session != null && _closeSession) {
      _session!.close();
    }
  }

  Map<String, dynamic> _demoResponse(
    String uri,
    dynamic data,
    Map<String, String>? params,
  ) {
    switch (uri) {
      case 'status':
        return {'protection_enabled': demoProtectionEnabled, 'version': 'Demo'};
      case 'stats':
        return _demoStatsPayload;
      case 'stats_info':
        return {'interval': 90};
      case 'safebrowsing/status':
        return {'enabled': demoSafeBrowsing};
      case 'safebrowsing/enable':
        demoSafeBrowsing = true;
        return {};
      case 'safebrowsing/disable':
        demoSafeBrowsing = false;
        return {};
      case 'parental/status':
        return {'enabled': demoParental};
      case 'parental/enable':
        demoParental = true;
        return {};
      case 'parental/disable':
        demoParental = false;
        return {};
      case 'safesearch/status':
        return {
          'enabled': demoSafeSearch,
          'bing': true,
          'duckduckgo': true,
          'google': true,
          'yandex': true,
          'youtube': true,
        };
      case 'safesearch/settings':
        if (data is Map && data['enabled'] is bool) {
          demoSafeSearch = data['enabled'] as bool;
        }
        return {};
      case 'querylog':
        final search = params?['search']?.toLowerCase();
        if (search == null || search.isEmpty) return {'data': _demoQueryLog};
        return {
          'data': [
            for (final entry in _demoQueryLog)
              if ((entry['question']?['name'] ?? '')
                      .toString()
                      .toLowerCase()
                      .contains(search) ||
                  (entry['client'] ?? '').toString().toLowerCase().contains(
                    search,
                  ))
                entry,
          ],
        };
    }
    return {};
  }

  static final Map<String, dynamic> _demoStatsPayload = (() {
    final rng = Random(42);
    List<int> series(int base, int variance) => List<int>.generate(
      90,
      (i) => (base + rng.nextInt(variance) - variance ~/ 2).clamp(0, 1 << 31),
    );
    final dnsQueries = series(1500, 800);
    final blockedFiltering = series(380, 200);
    final replacedSafebrowsing = series(8, 16);
    final replacedParental = series(2, 6);
    final totalQueries = dnsQueries.fold<int>(0, (a, b) => a + b);
    final totalBlocked = blockedFiltering.fold<int>(0, (a, b) => a + b);
    final totalSafebrowsing = replacedSafebrowsing.fold<int>(
      0,
      (a, b) => a + b,
    );
    final totalParental = replacedParental.fold<int>(0, (a, b) => a + b);
    return {
      'num_dns_queries': totalQueries,
      'num_blocked_filtering': totalBlocked,
      'num_replaced_safebrowsing': totalSafebrowsing,
      'num_replaced_parental': totalParental,
      'num_replaced_safesearch': 124,
      'avg_processing_time': 0.0124,
      'top_queried_domains': const [
        {'play.googleapis.com': 12345},
        {'apple.com': 8124},
        {'github.com': 6532},
        {'cloudflare.com': 5421},
        {'wikipedia.org': 4127},
      ],
      'top_blocked_domains': const [
        {'doubleclick.net': 4321},
        {'googlesyndication.com': 3210},
        {'facebook.com': 2890},
        {'analytics.google.com': 1842},
        {'ads.youtube.com': 1457},
      ],
      'top_clients': const [
        {'192.168.1.10': 18432},
        {'192.168.1.42': 12891},
        {'192.168.1.5': 7321},
        {'192.168.1.78': 4128},
      ],
      'top_upstreams_responses': const [
        {'tls://1.1.1.1': 72104},
        {'https://dns.google/dns-query': 45892},
        {'9.9.9.9': 10924},
      ],
      'top_upstreams_avg_time': const [
        {'tls://1.1.1.1': 0.0118},
        {'https://dns.google/dns-query': 0.0186},
        {'9.9.9.9': 0.0251},
      ],
      'dns_queries': dnsQueries,
      'blocked_filtering': blockedFiltering,
      'replaced_safebrowsing': replacedSafebrowsing,
      'replaced_parental': replacedParental,
    };
  })();

  static final List<Map<String, dynamic>> _demoQueryLog = (() {
    final now = DateTime.now().toUtc();
    final samples = <Map<String, dynamic>>[
      {
        'name': 'play.googleapis.com',
        'reason': 'NotFilteredNotFound',
        'client': '192.168.1.10',
      },
      {
        'name': 'doubleclick.net',
        'reason': 'FilteredBlackList',
        'rule': '||doubleclick.net^',
        'client': '192.168.1.42',
      },
      {
        'name': 'github.com',
        'reason': 'NotFilteredNotFound',
        'client': '192.168.1.10',
      },
      {
        'name': 'malware.example.org',
        'reason': 'FilteredSafeBrowsing',
        'client': '192.168.1.5',
      },
      {
        'name': 'ads.facebook.com',
        'reason': 'FilteredBlackList',
        'rule': '||facebook.com^',
        'client': '192.168.1.78',
      },
      {
        'name': 'youtube.com',
        'reason': 'NotFilteredNotFound',
        'client': '192.168.1.10',
      },
      {
        'name': 'adult.example.com',
        'reason': 'FilteredParental',
        'client': '192.168.1.78',
      },
      {
        'name': 'cloudflare.com',
        'reason': 'NotFilteredNotFound',
        'client': '192.168.1.42',
      },
      {
        'name': 'analytics.google.com',
        'reason': 'FilteredBlackList',
        'rule': '||google-analytics.com^',
        'client': '192.168.1.10',
      },
      {
        'name': 'wikipedia.org',
        'reason': 'NotFilteredNotFound',
        'client': '192.168.1.5',
      },
      {
        'name': 'tracker.example.net',
        'reason': 'FilteredBlackList',
        'rule': '||tracker.example.net^',
        'client': '192.168.1.42',
      },
      {
        'name': 'apple.com',
        'reason': 'NotFilteredNotFound',
        'client': '192.168.1.10',
      },
    ];
    return [
      for (int i = 0; i < samples.length; i++)
        {
          'time': now.subtract(Duration(minutes: i * 4 + 1)).toIso8601String(),
          'question': {'name': samples[i]['name'], 'type': 'A', 'class': 'IN'},
          'answer': [
            {
              'value': samples[i]['reason'].toString().startsWith('Filtered')
                  ? '0.0.0.0'
                  : '93.184.216.34',
            },
          ],
          'reason': samples[i]['reason'],
          'elapsedMs': (0.4 + i * 0.13).toStringAsFixed(4),
          if (samples[i]['rule'] != null) 'rule': samples[i]['rule'],
          'client': samples[i]['client'],
        },
    ];
  })();
}

class ProtectionInfo {
  const ProtectionInfo({required this.enabled, this.remaining});

  final bool enabled;
  final Duration? remaining;
}
