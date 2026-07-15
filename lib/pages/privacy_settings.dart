import 'package:adguard_home_client/generated_api/export.dart';
import 'package:adguard_home_client/main.dart';
import 'package:adguard_home_client/utils/messages.dart';
import 'package:flutter/material.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  final _queryIgnored = TextEditingController();
  final _statsIgnored = TextEditingController();
  GetQueryLogConfigResponse? _query;
  GetStatsConfigResponse? _stats;
  Object? _error;
  bool _saving = false;

  static const _day = Duration.millisecondsPerDay;
  static const _retentionChoices = <num>[
    6 * Duration.millisecondsPerHour,
    _day,
    7 * _day,
    30 * _day,
    90 * _day,
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _queryIgnored.dispose();
    _statsIgnored.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final values = await Future.wait([
        dataSource!.getQueryLogConfig(),
        dataSource!.getStatsConfig(),
      ]);
      if (!mounted) return;
      final query = values[0] as GetQueryLogConfigResponse;
      final stats = values[1] as GetStatsConfigResponse;
      _queryIgnored.text = query.ignored.join('\n');
      _statsIgnored.text = stats.ignored.join('\n');
      setState(() {
        _query = query;
        _stats = stats;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  List<String> _domains(TextEditingController controller) => controller.text
      .split(RegExp(r'[,\n]'))
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList();

  String _retentionLabel(num milliseconds) {
    final duration = Duration(milliseconds: milliseconds.round());
    if (duration.inHours < 24) return '${duration.inHours} hours';
    return '${duration.inDays} ${duration.inDays == 1 ? 'day' : 'days'}';
  }

  List<num> _choices(num current) {
    final values = {..._retentionChoices, current}.toList();
    values.sort((a, b) => a.compareTo(b));
    return values;
  }

  void _updateQuery({
    bool? enabled,
    num? interval,
    bool? anonymize,
    bool? ignoredEnabled,
  }) {
    final value = _query!;
    setState(() {
      _query = GetQueryLogConfigResponse(
        enabled: enabled ?? value.enabled,
        interval: interval ?? value.interval,
        anonymizeClientIp: anonymize ?? value.anonymizeClientIp,
        ignored: value.ignored,
        ignoredEnabled: ignoredEnabled ?? value.ignoredEnabled,
      );
    });
  }

  void _updateStats({bool? enabled, num? interval, bool? ignoredEnabled}) {
    final value = _stats!;
    setState(() {
      _stats = GetStatsConfigResponse(
        enabled: enabled ?? value.enabled,
        interval: interval ?? value.interval,
        ignored: value.ignored,
        ignoredEnabled: ignoredEnabled ?? value.ignoredEnabled,
      );
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final query = _query!;
      final stats = _stats!;
      await dataSource!.updateQueryLogConfig(
        GetQueryLogConfigResponse(
          enabled: query.enabled,
          interval: query.interval,
          anonymizeClientIp: query.anonymizeClientIp,
          ignored: _domains(_queryIgnored),
          ignoredEnabled: query.ignoredEnabled,
        ),
      );
      await dataSource!.updateStatsConfig(
        GetStatsConfigResponse(
          enabled: stats.enabled,
          interval: stats.interval,
          ignored: _domains(_statsIgnored),
          ignoredEnabled: stats.ignoredEnabled,
        ),
      );
      if (mounted) showMessage(context, 'Privacy settings saved');
    } catch (error) {
      if (mounted) showMessage(context, 'Could not save: $error', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDestructive({
    required String title,
    required String message,
    required String actionLabel,
    required Future<void> Function() action,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await action();
      if (mounted) showMessage(context, '$title complete');
    } catch (error) {
      if (mounted) showMessage(context, '$title failed: $error', error: true);
    }
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );

  Widget _retentionDropdown({
    required num value,
    required ValueChanged<num> onChanged,
  }) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: DropdownButtonFormField<num>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Retention period'),
      items: [
        for (final choice in _choices(value))
          DropdownMenuItem(value: choice, child: Text(_retentionLabel(choice))),
      ],
      onChanged: (choice) {
        if (choice != null) onChanged(choice);
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final query = _query;
    final stats = _stats;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & retention'),
        actions: [
          IconButton.filledTonal(
            tooltip: 'Save',
            onPressed: query == null || stats == null || _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _error != null
          ? Center(
              child: FilledButton.tonalIcon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: Text('Retry: $_error'),
              ),
            )
          : query == null || stats == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                _sectionTitle('Query log'),
                Card.filled(
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.receipt_long_outlined),
                        title: const Text('Record queries'),
                        value: query.enabled,
                        onChanged: (value) => _updateQuery(enabled: value),
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.visibility_off_outlined),
                        title: const Text('Anonymize client IP addresses'),
                        value: query.anonymizeClientIp,
                        onChanged: (value) => _updateQuery(anonymize: value),
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.rule_outlined),
                        title: const Text('Exclude listed domains'),
                        value: query.ignoredEnabled ?? false,
                        onChanged: (value) =>
                            _updateQuery(ignoredEnabled: value),
                      ),
                      _retentionDropdown(
                        value: query.interval,
                        onChanged: (value) => _updateQuery(interval: value),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: TextField(
                          controller: _queryIgnored,
                          minLines: 2,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Excluded domains',
                            hintText: 'one.example per line',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _sectionTitle('Statistics'),
                Card.filled(
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.analytics_outlined),
                        title: const Text('Collect statistics'),
                        value: stats.enabled,
                        onChanged: (value) => _updateStats(enabled: value),
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.rule_outlined),
                        title: const Text('Exclude listed domains'),
                        value: stats.ignoredEnabled ?? false,
                        onChanged: (value) =>
                            _updateStats(ignoredEnabled: value),
                      ),
                      _retentionDropdown(
                        value: stats.interval,
                        onChanged: (value) => _updateStats(interval: value),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: TextField(
                          controller: _statsIgnored,
                          minLines: 2,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Excluded domains',
                            hintText: 'one.example per line',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _sectionTitle('Delete data'),
                Card.filled(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.delete_sweep_outlined),
                        title: const Text('Clear query log'),
                        onTap: () => _confirmDestructive(
                          title: 'Clear query log',
                          message: 'Permanently delete all recorded queries?',
                          actionLabel: 'Clear',
                          action: dataSource!.clearQueryLog,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.restart_alt),
                        title: const Text('Reset statistics'),
                        onTap: () => _confirmDestructive(
                          title: 'Reset statistics',
                          message:
                              'Permanently delete all collected statistics?',
                          actionLabel: 'Reset',
                          action: dataSource!.resetStats,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
