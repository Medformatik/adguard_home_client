import 'package:adguard_home_client/interface/stats.dart';
import 'package:adguard_home_client/main.dart';
import 'package:adguard_home_client/pages/settings.dart';
import 'package:adguard_home_client/widgets/statistics_card.dart';
import 'package:adguard_home_client/widgets/statistics_table_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<StatsSnapshot>? _snapshot;
  StatsSnapshot? _lastSnapshot;
  Future<String?>? _version;
  final _protectionsKey = GlobalKey<_ProtectionsCardState>();

  @override
  void initState() {
    super.initState();
    if (instanceConfigured) {
      _load();
    }
  }

  void _load() {
    adGuardHome!.stats.refresh();
    final fut = adGuardHome!.stats.snapshot();
    _snapshot = fut;
    _version = adGuardHome!.version();
    fut.then((snap) {
      if (!mounted) return;
      setState(() => _lastSnapshot = snap);
    }).catchError((_) {});
  }

  Future<void> _refresh() async {
    if (!instanceConfigured) return;
    setState(_load);
    _protectionsKey.currentState?.reload();
    try {
      await _snapshot;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!instanceConfigured) return const SettingsPage();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AdGuard Home'),
            FutureBuilder<String?>(
              future: _version,
              builder: (context, snapshot) {
                return Text(
                  snapshot.hasData ? snapshot.data! : 'Loading...',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ],
        ),
        actions: const [_QueryLogButton(), _SettingsButton(), _ProtectionToggleButton()],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<StatsSnapshot>(
            future: _snapshot,
            builder: (context, asyncSnap) {
              final data = asyncSnap.data ?? _lastSnapshot;
              if (data != null) {
                return _scrollable(_StatsBody(snapshot: data, protectionsKey: _protectionsKey));
              }
              if (asyncSnap.hasError) {
                return _scrollable(_ErrorBlock(
                  message: 'Could not load statistics.',
                  onRetry: _refresh,
                ));
              }
              return _scrollable(const Padding(
                padding: EdgeInsets.symmetric(vertical: 96),
                child: Center(child: CircularProgressIndicator()),
              ));
            },
          ),
        ),
      ),
    );
  }

  Widget _scrollable(Widget child) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  final StatsSnapshot snapshot;
  final Key? protectionsKey;
  const _StatsBody({required this.snapshot, this.protectionsKey});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16.0,
      children: [
        _ProtectionsCard(key: protectionsKey),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0, 0.0, 0),
          child: Text(
            'Statistics for the last ${snapshot.period} days',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        StatisticsCard(
          primary: snapshot.dnsQueries,
          secondary: snapshot.avgProcessingTime,
          secondaryPrefix: '~',
          secondarySuffix: 'ms',
          graph: snapshot.dnsQueriesPerDay,
          title: 'DNS Queries',
          textColor: Colors.blue,
          icon: Icons.dns,
        ),
        StatisticsCard(
          primary: snapshot.blockedFiltering,
          secondary: snapshot.blockedPercentage,
          secondarySuffix: '%',
          graph: snapshot.blockedFilteringPerDay,
          title: 'Blocked by Filters',
          textColor: Colors.red,
          icon: Icons.security,
        ),
        StatisticsCard(
          primary: snapshot.replacedSafebrowsing,
          graph: snapshot.replacedSafebrowsingPerDay,
          title: 'Blocked malware/phishing',
          textColor: Colors.green[500]!,
          icon: Icons.coronavirus,
        ),
        StatisticsCard(
          primary: snapshot.replacedParental,
          graph: snapshot.replacedParentalPerDay,
          title: 'Blocked adult websites',
          textColor: Colors.yellow[700]!,
          icon: Icons.person,
        ),
        StatisticsCard(
          primary: snapshot.replacedSafesearch,
          title: 'Enforced safe search',
          textColor: Colors.purple[500]!,
          icon: Icons.search,
        ),
        StatisticsTableCard(
          data: snapshot.topQueriedDomains,
          total: snapshot.dnsQueries,
          title: 'Top queried domains',
          keyColumn: 'Domain',
          valueColumn: 'Count',
          textColor: Colors.blue,
          icon: Icons.dns,
        ),
        StatisticsTableCard(
          data: snapshot.topBlockedDomains,
          total: snapshot.blockedFiltering,
          title: 'Top blocked domains',
          keyColumn: 'Domain',
          valueColumn: 'Count',
          textColor: Colors.red,
          icon: Icons.security,
        ),
        StatisticsTableCard(
          data: snapshot.topClients,
          total: snapshot.dnsQueries,
          title: 'Top clients',
          keyColumn: 'Client',
          valueColumn: 'Count',
          textColor: scheme.onSurface,
          icon: Icons.people,
        ),
      ],
    );
  }
}

class _ProtectionsCard extends StatefulWidget {
  const _ProtectionsCard({super.key});

  @override
  State<_ProtectionsCard> createState() => _ProtectionsCardState();
}

class _ProtectionsCardState extends State<_ProtectionsCard> {
  bool? _safeBrowsing;
  bool? _parental;
  bool? _safeSearch;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void reload() => _load();

  Future<void> _load() async {
    final hasData = _safeBrowsing != null;
    if (!hasData) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final results = await Future.wait([
        adGuardHome!.protectionEnabled(),
        adGuardHome!.safeBrowsing.enabled(),
        adGuardHome!.parental.enabled(),
        adGuardHome!.safeSearch.enabled(),
      ]);
      if (!mounted) return;
      protectionStatus.value = results[0];
      setState(() {
        _safeBrowsing = results[1];
        _parental = results[2];
        _safeSearch = results[3];
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (!hasData) _error = e.toString();
      });
    }
  }

  Future<void> _toggleProtection() async {
    final current = protectionStatus.value;
    if (current == null) return;
    final next = !current;
    protectionStatus.value = next;
    try {
      if (next) {
        await adGuardHome!.enableProtection();
      } else {
        await adGuardHome!.disableProtection();
      }
    } catch (e) {
      protectionStatus.value = current;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update Protection'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _toggle({
    required String label,
    required bool current,
    required Future<void> Function(bool) apply,
    required void Function(bool) commit,
  }) async {
    final next = !current;
    commit(next);
    try {
      await apply(next);
    } catch (e) {
      if (!mounted) return;
      commit(current);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update $label'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: _loading
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            : _error != null
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Expanded(child: Text('Could not load protection settings.')),
                        TextButton(onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      ValueListenableBuilder<bool?>(
                        valueListenable: protectionStatus,
                        builder: (context, value, _) => _CompactToggle(
                          label: 'Protection',
                          icon: Icons.shield,
                          value: value ?? false,
                          onChanged: _toggleProtection,
                        ),
                      ),
                      _CompactToggle(
                        label: 'Safe Browsing',
                        icon: Icons.coronavirus,
                        value: _safeBrowsing!,
                        onChanged: () => _toggle(
                          label: 'Safe Browsing',
                          current: _safeBrowsing!,
                          apply: (next) => next ? adGuardHome!.safeBrowsing.enable() : adGuardHome!.safeBrowsing.disable(),
                          commit: (val) => setState(() => _safeBrowsing = val),
                        ),
                      ),
                      _CompactToggle(
                        label: 'Parental Control',
                        icon: Icons.person,
                        value: _parental!,
                        onChanged: () => _toggle(
                          label: 'Parental Control',
                          current: _parental!,
                          apply: (next) => next ? adGuardHome!.parental.enable() : adGuardHome!.parental.disable(),
                          commit: (val) => setState(() => _parental = val),
                        ),
                      ),
                      _CompactToggle(
                        label: 'Safe Search',
                        icon: Icons.search,
                        value: _safeSearch!,
                        onChanged: () => _toggle(
                          label: 'Safe Search',
                          current: _safeSearch!,
                          apply: (next) => adGuardHome!.safeSearch.setEnabled(next),
                          commit: (val) => setState(() => _safeSearch = val),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _CompactToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final VoidCallback onChanged;

  const _CompactToggle({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: value,
                onChanged: (_) => onChanged(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorBlock({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _QueryLogButton extends StatelessWidget {
  const _QueryLogButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.list_alt),
      tooltip: 'Query log',
      onPressed: () => Navigator.pushNamed(context, '/querylog'),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton();

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      icon: const Icon(Icons.settings),
      tooltip: 'Settings',
      onPressed: () => Navigator.pushNamed(context, '/settings'),
    );
  }
}

class _ProtectionToggleButton extends StatefulWidget {
  const _ProtectionToggleButton();

  @override
  State<_ProtectionToggleButton> createState() => _ProtectionToggleButtonState();
}

class _ProtectionToggleButtonState extends State<_ProtectionToggleButton> {
  @override
  void initState() {
    super.initState();
    if (instanceConfigured && protectionStatus.value == null) {
      adGuardHome!.protectionEnabled().then((v) {
        if (mounted) protectionStatus.value = v;
      }).catchError((_) {});
    }
  }

  Future<void> _toggle() async {
    final current = protectionStatus.value;
    if (current == null) return;
    final next = !current;
    protectionStatus.value = next;
    try {
      if (next) {
        await adGuardHome!.enableProtection();
      } else {
        await adGuardHome!.disableProtection();
      }
    } catch (e) {
      protectionStatus.value = current;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not toggle protection: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ValueListenableBuilder<bool?>(
        valueListenable: protectionStatus,
        builder: (context, value, _) {
          if (value == null) {
            return IconButton.filledTonal(
              icon: const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              onPressed: null,
            );
          }
          return IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: value ? Colors.red : Colors.green[700],
              foregroundColor: Colors.white,
            ),
            icon: Icon(value ? Icons.shield_outlined : Icons.shield),
            tooltip: value ? 'Disable protection' : 'Enable protection',
            onPressed: _toggle,
          );
        },
      ),
    );
  }
}
