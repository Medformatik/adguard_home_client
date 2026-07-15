import 'dart:async';

import 'package:adguard_home_client/interface/stats.dart';
import 'package:adguard_home_client/main.dart';
import 'package:adguard_home_client/pages/settings.dart';
import 'package:adguard_home_client/utils/datasource.dart';
import 'package:adguard_home_client/utils/init.dart';
import 'package:adguard_home_client/utils/instances.dart';
import 'package:adguard_home_client/utils/messages.dart';
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
    fut
        .then((snap) {
          if (!mounted) return;
          setState(() => _lastSnapshot = snap);
        })
        .catchError((_) {});
  }

  Future<void> _showInstanceSwitcher(BuildContext context) async {
    final result = await showModalBottomSheet<_SwitcherResult>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final instances = Instances.list();
        final activeId = Instances.getActiveId();
        final theme = Theme.of(context);

        final showUnified = instances.length >= 2;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 12),
                  child: Text(
                    'Switch instance',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Card.filled(
                  margin: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      children: [
                        if (showUnified)
                          _switcherTile(
                            context,
                            isActive: activeId == Instances.unifiedId,
                            icon: Icons.merge_type,
                            title: 'Unified',
                            subtitle: 'Aggregated across all instances',
                            onTap: () {
                              Navigator.pop(
                                context,
                                _SwitcherResult.switchTo(Instances.unifiedId),
                              );
                            },
                          ),
                        ...instances.map((i) {
                          final isActive = i.id == activeId;
                          return _switcherTile(
                            context,
                            isActive: isActive,
                            icon: null,
                            title: i.name.isEmpty ? '(unnamed)' : i.name,
                            subtitle:
                                '${i.tls ? 'https' : 'http'}://${i.host}:${i.port}',
                            onTap: () {
                              Navigator.pop(
                                context,
                                _SwitcherResult.switchTo(i.id),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text(
                    'Manage instances',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onTap: () => Navigator.pop(context, _SwitcherResult.manage()),
                ),
              ],
            ),
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
        showMessage(
          this.context,
          'Could not connect to "${activeLabelFor(result.switchToId) ?? "instance"}"',
          error: true,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        isActive
            ? Icons.radio_button_checked
            : (icon ?? Icons.radio_button_unchecked),
        color: isActive ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      onTap: isActive ? () => Navigator.pop(context) : onTap,
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
        showMessage(context, 'Failed to refresh: $e', error: true);
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
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      FutureBuilder<String?>(
                        future: _version,
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.hasData ? snapshot.data! : 'Loading...',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
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
        actions: const [
          _QueryLogButton(),
          _SettingsButton(),
          _ProtectionToggleButton(),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<StatsSnapshot>(
            future: _snapshot,
            builder: (context, asyncSnap) {
              final data = asyncSnap.data ?? _lastSnapshot;
              if (data != null) {
                return _scrollable(
                  _StatsBody(snapshot: data, protectionsKey: _protectionsKey),
                );
              }
              if (asyncSnap.hasError) {
                return _scrollable(
                  _ErrorBlock(
                    message: 'Could not load statistics.',
                    onRetry: _refresh,
                  ),
                );
              }
              return _scrollable(
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 96),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
          padding: const EdgeInsets.fromLTRB(8.0, 12.0, 0.0, 0),
          child: Text(
            'Statistics for the last ${snapshot.period} days',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ),
        StatisticsCard(
          primary: snapshot.dnsQueries,
          secondary: snapshot.avgProcessingTime,
          secondaryPrefix: '~',
          secondarySuffix: 'ms',
          graph: snapshot.dnsQueriesPerDay,
          title: 'DNS Queries',
          textColor: scheme.primary,
          icon: Icons.dns,
        ),
        StatisticsCard(
          primary: snapshot.blockedFiltering,
          secondary: snapshot.blockedPercentage,
          secondarySuffix: '%',
          graph: snapshot.blockedFilteringPerDay,
          title: 'Blocked by Filters',
          textColor: scheme.error,
          icon: Icons.security,
        ),
        StatisticsCard(
          primary: snapshot.replacedSafebrowsing,
          graph: snapshot.replacedSafebrowsingPerDay,
          title: 'Blocked malware/phishing',
          textColor: scheme.tertiary,
          icon: Icons.coronavirus,
        ),
        StatisticsCard(
          primary: snapshot.replacedParental,
          graph: snapshot.replacedParentalPerDay,
          title: 'Blocked adult websites',
          textColor: scheme.secondary,
          icon: Icons.person,
        ),
        StatisticsCard(
          primary: snapshot.replacedSafesearch,
          title: 'Enforced safe search',
          textColor: scheme.primary,
          icon: Icons.search,
        ),
        StatisticsTableCard(
          data: snapshot.topQueriedDomains,
          total: snapshot.dnsQueries,
          title: 'Top queried domains',
          keyColumn: 'Domain',
          valueColumn: 'Count',
          textColor: scheme.primary,
          icon: Icons.dns,
        ),
        StatisticsTableCard(
          data: snapshot.topBlockedDomains,
          total: snapshot.blockedFiltering,
          title: 'Top blocked domains',
          keyColumn: 'Domain',
          valueColumn: 'Count',
          textColor: scheme.error,
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
        StatisticsTableCard(
          data: snapshot.topUpstreamsResponses,
          total: snapshot.topUpstreamsResponses.values.fold<int>(
            0,
            (a, b) => a + b,
          ),
          title: 'Upstream responses',
          keyColumn: 'Upstream',
          valueColumn: 'Responses',
          textColor: scheme.tertiary,
          icon: Icons.swap_vert_circle_outlined,
        ),
        StatisticsTableCard(
          data: snapshot.topUpstreamsAvgTime,
          title: 'Upstream response time',
          keyColumn: 'Upstream',
          valueColumn: 'Average',
          valueSuffix: ' ms',
          fractionDigits: 2,
          textColor: scheme.secondary,
          icon: Icons.speed_outlined,
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
  DateTime? _pauseUntil;
  Timer? _pauseTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void reload() => _load();

  @override
  void dispose() {
    _pauseTimer?.cancel();
    super.dispose();
  }

  void _setPauseRemaining(Duration? remaining) {
    _pauseTimer?.cancel();
    _pauseTimer = null;
    _pauseUntil = remaining == null || remaining <= Duration.zero
        ? null
        : DateTime.now().add(remaining);
    if (_pauseUntil == null) return;
    _pauseTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_pauseUntil!.isAfter(DateTime.now())) {
        setState(() {});
      } else {
        _pauseTimer?.cancel();
        _pauseTimer = null;
        _pauseUntil = null;
        _load();
      }
    });
  }

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
        ds.protectionSummary(),
        ds.safeBrowsingEnabled(),
        ds.parentalEnabled(),
        ds.safeSearchEnabled(),
      ]);
      if (!mounted) return;
      final protection = results[0] as ProtectionSummary;
      protectionStatus.value = protection.state;
      _setPauseRemaining(protection.remaining);
      setState(() {
        _safeBrowsing = results[1] as ToggleState;
        _parental = results[2] as ToggleState;
        _safeSearch = results[3] as ToggleState;
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
      if (next) _setPauseRemaining(null);
    } catch (e) {
      protectionStatus.value = current;
      if (!mounted) return;
      showMessage(context, 'Failed to update protection', error: true);
    }
  }

  Future<void> _pauseProtection(Duration? duration) async {
    final previous = protectionStatus.value;
    protectionStatus.value = ToggleState.off;
    _setPauseRemaining(duration);
    try {
      await dataSource!.setProtection(false, pauseFor: duration);
    } catch (e) {
      protectionStatus.value = previous;
      _setPauseRemaining(null);
      if (mounted) {
        showMessage(context, 'Failed to pause protection', error: true);
      }
    }
  }

  Future<void> _showPauseOptions() async {
    final result = await showModalBottomSheet<_PauseChoice>(
      context: context,
      showDragHandle: true,
      builder: (context) => const _PauseProtectionSheet(),
    );
    if (result != null) await _pauseProtection(result.duration);
  }

  String? get _pauseSubtitle {
    final until = _pauseUntil;
    if (until == null) return null;
    final remaining = until.difference(DateTime.now());
    if (remaining <= Duration.zero) return null;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds.remainder(60);
    return 'Paused · ${minutes > 0 ? '${minutes}m ' : ''}${seconds}s remaining';
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
      showMessage(context, 'Failed to update $label', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Card.filled(
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_error != null) {
      return Card.filled(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(
                child: Text('Could not load protection settings.'),
              ),
              TextButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return ValueListenableBuilder<ToggleState>(
      valueListenable: protectionStatus,
      builder: (context, overallProtection, _) {
        return Card.filled(
          margin: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                _CompactToggle(
                  label: 'Protection',
                  icon: Icons.shield,
                  state: overallProtection,
                  onTap: _toggleProtection,
                  subtitle: _pauseSubtitle,
                  extraAction: IconButton.filledTonal(
                    style: _primaryContainerIconButtonStyle(context),
                    tooltip: 'Pause protection',
                    onPressed: overallProtection.isReady
                        ? _showPauseOptions
                        : null,
                    icon: const Icon(Icons.timer_outlined),
                  ),
                ),
                _CompactToggle(
                  label: 'Safe Browsing',
                  icon: Icons.coronavirus,
                  state: _safeBrowsing,
                  onTap: () {
                    _toggle(
                      label: 'Safe Browsing',
                      current: _safeBrowsing,
                      apply: dataSource!.setSafeBrowsing,
                      commit: (val) => setState(() => _safeBrowsing = val),
                    );
                  },
                ),
                _CompactToggle(
                  label: 'Parental Control',
                  icon: Icons.person,
                  state: _parental,
                  onTap: () {
                    _toggle(
                      label: 'Parental Control',
                      current: _parental,
                      apply: dataSource!.setParental,
                      commit: (val) => setState(() => _parental = val),
                    );
                  },
                ),
                _CompactToggle(
                  label: 'Safe Search',
                  icon: Icons.search,
                  state: _safeSearch,
                  onTap: () {
                    _toggle(
                      label: 'Safe Search',
                      current: _safeSearch,
                      apply: dataSource!.setSafeSearch,
                      commit: (val) => setState(() => _safeSearch = val),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PauseChoice {
  const _PauseChoice(this.duration);

  final Duration? duration;
}

class _PauseProtectionSheet extends StatelessWidget {
  const _PauseProtectionSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Text(
                'Pause protection',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            for (final option in const [
              ('30 seconds', Duration(seconds: 30)),
              ('5 minutes', Duration(minutes: 5)),
              ('15 minutes', Duration(minutes: 15)),
              ('1 hour', Duration(hours: 1)),
            ])
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(option.$1),
                onTap: () => Navigator.pop(context, _PauseChoice(option.$2)),
              ),
            ListTile(
              leading: const Icon(Icons.pause_circle_outline),
              title: const Text('Until resumed'),
              onTap: () => Navigator.pop(context, const _PauseChoice(null)),
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
  final VoidCallback onTap;
  final String? subtitle;
  final Widget? extraAction;

  const _CompactToggle({
    required this.label,
    required this.icon,
    required this.state,
    required this.onTap,
    this.subtitle,
    this.extraAction,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = !state.isReady;
    final mixed = state.isMixed;
    final scheme = Theme.of(context).colorScheme;

    final Color iconColor;
    if (state.isOn) {
      if (label == 'Protection') {
        iconColor = scheme.primary;
      } else if (label == 'Safe Browsing') {
        iconColor = scheme.tertiary;
      } else if (label == 'Parental Control') {
        iconColor = scheme.secondary;
      } else {
        iconColor = scheme.primary;
      }
    } else {
      iconColor = scheme.onSurface.withValues(alpha: 0.4);
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, size: 22, color: iconColor),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: disabled ? scheme.onSurface.withValues(alpha: 0.4) : null,
        ),
      ),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (extraAction != null) ...[extraAction!, const SizedBox(width: 8)],
          if (mixed)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                'Mixed',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Switch(
            value: state.isOn,
            onChanged: disabled ? null : (_) => onTap(),
          ),
        ],
      ),
      onTap: disabled ? null : onTap,
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
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onRetry,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, size: 16),
                SizedBox(width: 8),
                Text('Retry'),
              ],
            ),
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
    return IconButton.filledTonal(
      style: _primaryContainerIconButtonStyle(context),
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
      style: _primaryContainerIconButtonStyle(context),
      icon: const Icon(Icons.settings),
      tooltip: 'Settings',
      onPressed: () => Navigator.pushNamed(context, '/settings'),
    );
  }
}

ButtonStyle _primaryContainerIconButtonStyle(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return IconButton.styleFrom(
    backgroundColor: scheme.primaryContainer,
    foregroundColor: scheme.onPrimaryContainer,
    disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
    disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
  );
}

class _ProtectionToggleButton extends StatefulWidget {
  const _ProtectionToggleButton();

  @override
  State<_ProtectionToggleButton> createState() =>
      _ProtectionToggleButtonState();
}

class _ProtectionToggleButtonState extends State<_ProtectionToggleButton> {
  @override
  void initState() {
    super.initState();
    if (instanceConfigured && protectionStatus.value.isLoading) {
      dataSource!
          .protectionEnabled()
          .then((v) {
            if (mounted) protectionStatus.value = v;
          })
          .catchError((_) {});
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
      showMessage(context, 'Could not toggle protection: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<ToggleState>(
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
            backgroundColor: on ? scheme.error : scheme.primary,
            foregroundColor: on ? scheme.onError : scheme.onPrimary,
          ),
          icon: Icon(on ? Icons.shield_outlined : Icons.shield),
          tooltip: on ? 'Disable protection' : 'Enable protection',
          onPressed: _toggle,
        );
      },
    );
  }
}
