import 'package:adguard_home_client/generated_api/export.dart';
import 'package:adguard_home_client/interface/adguardhome.dart';

class AdGuardHomeDns {
  AdGuardHomeDns(this._client);

  final AdGuardHome _client;

  Future<GetDnsInfoResponse> info() async {
    if (_client.isDemo) {
      return const GetDnsInfoResponse(
        upstreamDns: ['tls://1.1.1.1', 'https://dns.google/dns-query'],
        fallbackDns: ['9.9.9.9'],
        bootstrapDns: ['1.1.1.1', '8.8.8.8'],
        localPtrUpstreams: ['192.168.1.1'],
        dnssecEnabled: true,
        cacheEnabled: true,
        cacheSize: 4194304,
        cacheOptimistic: true,
        upstreamTimeout: 10,
        ratelimit: 20,
        upstreamMode: DnsConfigUpstreamMode.loadBalance,
      );
    }
    return _client.restClient.global.dnsInfo();
  }

  Future<Map<String, String>> testUpstreams(GetDnsInfoResponse config) async {
    if (_client.isDemo) {
      return {
        for (final upstream in config.upstreamDns ?? const <String>[])
          upstream: 'OK',
      };
    }
    return _client.restClient.global.testUpstreamDns(
      body: UpstreamsConfig(
        bootstrapDns: config.bootstrapDns ?? const [],
        upstreamDns: config.upstreamDns ?? const [],
        fallbackDns: config.fallbackDns,
        privateUpstream: config.localPtrUpstreams,
      ),
    );
  }

  Future<void> clearCache() async {
    if (_client.isDemo) return;
    await _client.restClient.global.cacheClear();
  }
}
