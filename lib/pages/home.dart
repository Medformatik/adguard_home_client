import 'package:adguard_home_client/interface/stats.dart';
import 'package:adguard_home_client/main.dart';
import 'package:adguard_home_client/pages/settings.dart';
import 'package:adguard_home_client/utils/datasource.dart';
import 'package:adguard_home_client/utils/init.dart';
import 'package:adguard_home_client/utils/instances.dart';
import 'package:adguard_home_client/widgets/statistics_card.dart';
import 'package:adguard_home_client/widgets/statistics_table_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _SwitcherResult {
  final bool manage;
  final String? switchToId;
  const _SwitcherResult._(this.manage, this.switchToId);
  factory _SwitcherResult.manage() => const _SwitcherResult._(true, null);
  factory _SwitcherResult.switchTo(String id) => _SwitcherResult._(false, id);
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
    final ds = dataSource!;
    ds.invalidateStats();
    final fut = ds.snapshot();
    _snapshot = fut;
    _version = ds.version();
    fut.then((snap) {
      if (!mounted) return;
      setState(() => _lastSnapshot = snap);
    }).catchError((_) {});
  }

  Future<void> _showInstanceSwitcher(BuildContext context) async {
    final result = await showModalBottomSheet<_SwitcherResult>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final instances = Instances.list();
        final activeId = Instances.getActiveId();
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Switch instance', style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
              if (instances.length >= 2)
                _switcherTile(
                  context,
                  isActive: activeId == Instances.unifiedId,
                  icon: Icons.merge_type,
                  title: 'Unified',
                  subtitle: 'Aggregated across all instances',
                  onTap: () => Navigator.pop(context, _SwitcherResult.switchTo(Instances.unifiedId)),
                ),
              ...instances.map((i) {
                final isActive = i.id == activeId;
                return _switcherTile(
                  context,
                  isActive: isActive,
                  icon: null,
                  title: i.name.isEmpty ? '(unnamed)' : i.name,
                  subtitle: '${i.tls ? 'https' : 'http'}://${i.host}:${i.port}',
                  onTap: () => Navigator.pop(context, _SwitcherResult.switchTo(i.id)),
                );
              }),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Manage instances'),
                onTap: () => Navigator.pop(context, _SwitcherResult.manage()),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (!mounted || result == null) return;
    if (result.manage) {
      await Navigator.pushNamed(this.context, '/settings');
      return;
    }
    if (result.switchToId != null) {
      final ok = await initAdGuardHome(switchTo: result.switchToId);
      if (!mounted) return;
      if (ok) {
        activeInstanceName.value = activeLabelFor(result.switchToId);
        protectionStatus.value = ToggleState.loading;
        setState(_load);
        _protectionsKey.currentState?.reload();
      } else {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Text('Could not connect to "${activeLabelFor(result.switchToId) ?? "instance"}"'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _switcherTile(
    BuildContext context, {
    required bool isActive,
    required IconData? icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        isActive ? Icons.radio_button_checked : (icon ?? Icons.radio_button_unchecked),
        color: isActive ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: isActive ? null : onTap,
    );
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
        title: InkWell(
          onTap: () => _showInstanceSwitcher(context),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder<String?>(
                        valueListenable: activeInstanceName,
                        builder: (context, name, _) => Text(
                          name?.isNotEmpty == true ? name! : 'AdGuard Home',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      FutureBuilder<String?>(
                        future: _version,
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.hasData ? snapshot.data! : 'Loading...',
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
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
  ToggleState _safeBrowsing = ToggleState.loading;
  ToggleState _parental = ToggleState.loading;
  ToggleState _safeSearch = ToggleState.loading;
  bool _loaded = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void reload() => _load();

  Future<void> _load() async {
    if (!_loaded) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final ds = dataSource!;
      final results = await Future.wait([
        ds.protectionEnabled(),
        ds.safeBrowsingEnabled(),
        ds.parentalEnabled(),
        ds.safeSearchEnabled(),
      ]);
      if (!mounted) return;
      protectionStatus.value = results[0];
      setState(() {
        _safeBrowsing = results[1];
        _parental = results[2];
        _safeSearch = results[3];
        _loading = false;
        _loaded = true;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (!_loaded) _error = e.toString();
      });
    }
  }

  Future<void> _toggleProtection() async {
    final current = protectionStatus.value;
    if (!current.isReady) return;
    final next = !current.isOn;
    protectionStatus.value = next ? ToggleState.on : ToggleState.off;
    try {
      await dataSource!.setProtection(next);
    } catch (e) {
      protectionStatus.value = current;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update Protection'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _toggle({
    required String label,
    required ToggleState current,
    required Future<void> Function(bool) apply,
    required void Function(ToggleState) commit,
  }) async {
    if (!current.isReady) return;
    final next = !current.isOn;
    commit(next ? ToggleState.on : ToggleState.off);
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
                      ValueListenableBuilder<ToggleState>(
                        valueListenable: protectionStatus,
                        builder: (context, value, _) => _CompactToggle(
                          label: 'Protection',
                          icon: Icons.shield,
                          state: value,
                          onChanged: _toggleProtection,
                        ),
                      ),
                      _CompactToggle(
                        label: 'Safe Browsing',
                        icon: Icons.coronavirus,
                        state: _safeBrowsing,
                        onChanged: () => _toggle(
                          label: 'Safe Browsing',
                          current: _safeBrowsing,
                          apply: dataSource!.setSafeBrowsing,
                          commit: (val) => setState(() => _safeBrowsing = val),
                        ),
                      ),
                      _CompactToggle(
                        label: 'Parental Control',
                        icon: Icons.person,
                        state: _parental,
                        onChanged: () => _toggle(
                          label: 'Parental Control',
                          current: _parental,
                          apply: dataSource!.setParental,
                          commit: (val) => setState(() => _parental = val),
                        ),
                      ),
                      _CompactToggle(
                        label: 'Safe Search',
                        icon: Icons.search,
                        state: _safeSearch,
                        onChanged: () => _toggle(
                          label: 'Safe Search',
                          current: _safeSearch,
                          apply: dataSource!.setSafeSearch,
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
  final ToggleState state;
  final VoidCallback onChanged;

  const _CompactToggle({
    required this.label,
    required this.icon,
    required this.state,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = !state.isReady;
    final mixed = state.isMixed;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: disabled ? null : onChanged,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: disabled ? scheme.onSurface.withValues(alpha: 0.5) : null),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: disabled ? scheme.onSurface.withValues(alpha: 0.5) : null),
              ),
            ),
            if (mixed)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  'Mixed',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurface.withValues(alpha: 0.6)),
                ),
              ),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: state.isOn,
                onChanged: disabled ? null : (_) => onChanged(),
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
    if (instanceConfigured && protectionStatus.value.isLoading) {
      dataSource!.protectionEnabled().then((v) {
        if (mounted) protectionStatus.value = v;
      }).catchError((_) {});
    }
  }

  Future<void> _toggle() async {
    final current = protectionStatus.value;
    if (!current.isReady) return;
    final next = !current.isOn;
    protectionStatus.value = next ? ToggleState.on : ToggleState.off;
    try {
      await dataSource!.setProtection(next);
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
      child: ValueListenableBuilder<ToggleState>(
        valueListenable: protectionStatus,
        builder: (context, value, _) {
          if (value.isLoading) {
            return IconButton.filledTonal(
              icon: const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              onPressed: null,
            );
          }
          if (value.isMixed) {
            return IconButton.filledTonal(
              icon: const Icon(Icons.shield_moon_outlined),
              tooltip: 'Protection differs across instances',
              onPressed: null,
            );
          }
          final on = value.isOn;
          return IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: on ? Colors.red : Colors.green[700],
              foregroundColor: Colors.white,
            ),
            icon: Icon(on ? Icons.shield_outlined : Icons.shield),
            tooltip: on ? 'Disable protection' : 'Enable protection',
            onPressed: _toggle,
          );
        },
      ),
    );
  }
}
