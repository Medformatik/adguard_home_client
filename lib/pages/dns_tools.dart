import 'package:adguard_home_client/generated_api/export.dart';
import 'package:adguard_home_client/main.dart';
import 'package:adguard_home_client/utils/messages.dart';
import 'package:flutter/material.dart';

class DnsToolsPage extends StatefulWidget {
  const DnsToolsPage({super.key});

  @override
  State<DnsToolsPage> createState() => _DnsToolsPageState();
}

class _DnsToolsPageState extends State<DnsToolsPage> {
  GetDnsInfoResponse? _info;
  Object? _error;
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final info = await dataSource!.getDnsInfo();
      if (mounted) setState(() => _info = info);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  String _list(List<String>? values) =>
      values == null || values.isEmpty ? 'None' : values.join('\n');

  String _mode(DnsConfigUpstreamMode? mode) => switch (mode) {
    DnsConfigUpstreamMode.fastestAddr => 'Fastest address',
    DnsConfigUpstreamMode.loadBalance => 'Load balancing',
    DnsConfigUpstreamMode.parallel => 'Parallel requests',
    DnsConfigUpstreamMode.empty || null => 'Default',
    _ => mode.toString(),
  };

  Future<void> _test() async {
    setState(() => _testing = true);
    try {
      final results = await dataSource!.testUpstreams(_info!);
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => UpstreamTestResultsSheet(results: results),
      );
    } catch (error) {
      if (mounted) {
        showMessage(context, 'Could not test upstreams: $error', error: true);
      }
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.cleaning_services_outlined),
        title: const Text('Clear DNS cache?'),
        content: const Text(
          'Cached DNS responses will be discarded. New queries may briefly take longer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear cache'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await dataSource!.clearDnsCache();
      if (mounted) showMessage(context, 'DNS cache cleared');
    } catch (error) {
      if (mounted) {
        showMessage(context, 'Could not clear cache: $error', error: true);
      }
    }
  }

  Widget _heading(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );

  Widget _valueTile(IconData icon, String title, String value) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    subtitle: SelectableText(value),
  );

  @override
  Widget build(BuildContext context) {
    final info = _info;
    return Scaffold(
      appBar: AppBar(title: const Text('DNS diagnostics')),
      body: _error != null
          ? Center(
              child: FilledButton.tonalIcon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: Text('Retry: $_error'),
              ),
            )
          : info == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                _heading('Resolvers'),
                Card.filled(
                  child: Column(
                    children: [
                      _valueTile(
                        Icons.dns_outlined,
                        'Upstream DNS servers',
                        _list(info.upstreamDns),
                      ),
                      _valueTile(
                        Icons.alt_route,
                        'Fallback servers',
                        _list(info.fallbackDns),
                      ),
                      _valueTile(
                        Icons.rocket_launch_outlined,
                        'Bootstrap servers',
                        _list(info.bootstrapDns),
                      ),
                      _valueTile(
                        Icons.lan_outlined,
                        'Private reverse DNS servers',
                        _list(info.localPtrUpstreams),
                      ),
                    ],
                  ),
                ),
                _heading('Runtime configuration'),
                Card.filled(
                  child: Column(
                    children: [
                      _valueTile(
                        Icons.route_outlined,
                        'Upstream mode',
                        _mode(info.upstreamMode),
                      ),
                      _valueTile(
                        Icons.verified_user_outlined,
                        'DNSSEC',
                        info.dnssecEnabled == true ? 'Enabled' : 'Disabled',
                      ),
                      _valueTile(
                        Icons.cached_outlined,
                        'DNS cache',
                        info.cacheEnabled == false
                            ? 'Disabled'
                            : '${info.cacheSize ?? 0} bytes${info.cacheOptimistic == true ? ' · optimistic' : ''}',
                      ),
                      _valueTile(
                        Icons.timer_outlined,
                        'Upstream timeout',
                        '${info.upstreamTimeout ?? 0} seconds',
                      ),
                      _valueTile(
                        Icons.speed_outlined,
                        'Rate limit',
                        '${info.ratelimit ?? 0} requests per second',
                      ),
                    ],
                  ),
                ),
                _heading('Actions'),
                Card.filled(
                  child: Column(
                    children: [
                      ListTile(
                        leading: _testing
                            ? const SizedBox.square(
                                dimension: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.network_check_outlined),
                        title: const Text('Test upstream DNS servers'),
                        subtitle: const Text(
                          'Verify that every configured resolver responds',
                        ),
                        onTap: _testing ? null : _test,
                      ),
                      ListTile(
                        leading: const Icon(Icons.cleaning_services_outlined),
                        title: const Text('Clear DNS cache'),
                        onTap: _clearCache,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class UpstreamTestResultsSheet extends StatelessWidget {
  const UpstreamTestResultsSheet({super.key, required this.results});

  final Map<String, String> results;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Text(
                  'Upstream test results',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: results.isEmpty
                      ? const [
                          ListTile(
                            leading: Icon(Icons.info_outline),
                            title: Text('No upstreams configured'),
                          ),
                        ]
                      : [
                          for (final result in results.entries)
                            ListTile(
                              leading: Icon(
                                result.value == 'OK'
                                    ? Icons.check_circle_outline
                                    : Icons.error_outline,
                              ),
                              title: Text(result.key),
                              subtitle: Text(result.value),
                            ),
                        ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
