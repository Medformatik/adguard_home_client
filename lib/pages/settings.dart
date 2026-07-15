import 'package:adguard_home_client/main.dart';
import 'package:adguard_home_client/pages/blocked_services.dart';
import 'package:adguard_home_client/pages/custom_rules.dart';
import 'package:adguard_home_client/utils/datasource.dart';
import 'package:adguard_home_client/utils/init.dart';
import 'package:adguard_home_client/utils/instances.dart';
import 'package:adguard_home_client/utils/messages.dart';
import 'package:adguard_home_client/utils/theme.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late List<Instance> _instances;
  String? _activeId;

  @override
  void initState() {
    super.initState();
    _refreshFromStorage();
  }

  void _refreshFromStorage() {
    _instances = Instances.list();
    _activeId = Instances.getActiveId();
  }

  Future<void> _switchTo(String id) async {
    final ok = await initAdGuardHome(switchTo: id);
    if (!mounted) return;
    if (ok) {
      activeInstanceName.value = activeLabelFor(id);
      protectionStatus.value = ToggleState.loading;
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } else {
      showMessage(
        context,
        'Could not connect to "${activeLabelFor(id) ?? "instance"}". Check its settings.',
        error: true,
      );
      setState(_refreshFromStorage);
    }
  }

  Future<void> _editInstance(Instance instance) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => InstanceEditPage(id: instance.id)),
    );
    if (!mounted) return;
    setState(_refreshFromStorage);
    if (instance.id == _activeId || _activeId == Instances.unifiedId) {
      await initAdGuardHome();
      if (mounted) activeInstanceName.value = activeLabelFor(_activeId);
    }
  }

  Future<void> _addInstance() async {
    final newId = await Navigator.of(context).push<String?>(
      MaterialPageRoute(builder: (_) => const InstanceEditPage(id: null)),
    );
    if (!mounted) return;
    setState(_refreshFromStorage);
    if (newId != null) await _switchTo(newId);
  }

  Future<void> _confirmDelete(Instance instance) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "${instance.name}"?'),
        content: const Text(
          'This removes the instance configuration and stored password from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await Instances.delete(instance.id);
    if (!mounted) return;
    setState(_refreshFromStorage);
    final newActive = Instances.getActiveId();
    if (newActive != null) {
      await initAdGuardHome();
      if (mounted) activeInstanceName.value = activeLabelFor(newActive);
    } else {
      adGuardHome = null;
      dataSource = null;
      activeInstanceName.value = null;
    }
  }

  Widget _instanceTile(Instance instance) {
    final isActive = instance.id == _activeId;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        isActive ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isActive ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(
        instance.name.isEmpty ? '(unnamed)' : instance.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${instance.tls ? 'https' : 'http'}://${instance.host}:${instance.port}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () => _editInstance(instance),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(instance),
          ),
        ],
      ),
      onTap: isActive ? null : () => _switchTo(instance.id),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System default';
    }
  }

  void _showThemeSelector(BuildContext context, ThemeMode current) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
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
                    'Select theme',
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
                        _themeTile(
                          context,
                          'System default',
                          ThemeMode.system,
                          current == ThemeMode.system,
                          () {
                            saveThemeMode(ThemeMode.system);
                            Navigator.pop(context);
                          },
                        ),
                        _themeTile(
                          context,
                          'Light',
                          ThemeMode.light,
                          current == ThemeMode.light,
                          () {
                            saveThemeMode(ThemeMode.light);
                            Navigator.pop(context);
                          },
                        ),
                        _themeTile(
                          context,
                          'Dark',
                          ThemeMode.dark,
                          current == ThemeMode.dark,
                          () {
                            saveThemeMode(ThemeMode.dark);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _themeTile(
    BuildContext context,
    String title,
    ThemeMode mode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final IconData icon;
    switch (mode) {
      case ThemeMode.light:
        icon = Icons.light_mode_outlined;
        break;
      case ThemeMode.dark:
        icon = Icons.dark_mode_outlined;
        break;
      case ThemeMode.system:
        icon = Icons.brightness_auto_outlined;
        break;
    }
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final managementEnabled = _activeId != Instances.unifiedId;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addInstance,
        icon: const Icon(Icons.add),
        label: const Text('Add instance'),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, currentThemeMode, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Appearance Section ---
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: Text(
                      'Appearance',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
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
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: Icon(
                              currentThemeMode == ThemeMode.dark
                                  ? Icons.dark_mode_outlined
                                  : currentThemeMode == ThemeMode.light
                                  ? Icons.light_mode_outlined
                                  : Icons.brightness_auto_outlined,
                              color: theme.colorScheme.primary,
                            ),
                            title: const Text(
                              'App Theme',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(_themeModeLabel(currentThemeMode)),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                            ),
                            onTap: () =>
                                _showThemeSelector(context, currentThemeMode),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Privacy & Filtering Section ---
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: Text(
                      'Privacy & Filtering',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
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
                          ListTile(
                            enabled: managementEnabled,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: Icon(
                              Icons.privacy_tip_outlined,
                              color: theme.colorScheme.primary,
                            ),
                            title: const Text(
                              'Privacy & Retention',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              'Configure query logs and statistics data',
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                            ),
                            onTap: managementEnabled
                                ? () => Navigator.pushNamed(context, '/privacy')
                                : null,
                          ),
                          ListTile(
                            enabled: managementEnabled,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: Icon(
                              Icons.troubleshoot_outlined,
                              color: theme.colorScheme.primary,
                            ),
                            title: const Text(
                              'DNS Diagnostics',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              'Inspect and test upstream DNS servers',
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                            ),
                            onTap: managementEnabled
                                ? () =>
                                      Navigator.pushNamed(context, '/dns-tools')
                                : null,
                          ),
                          ListTile(
                            enabled: managementEnabled,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: Icon(
                              Icons.devices_other_outlined,
                              color: theme.colorScheme.primary,
                            ),
                            title: const Text(
                              'Clients',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              'Manage device-specific protection policies',
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                            ),
                            onTap: managementEnabled
                                ? () => Navigator.pushNamed(context, '/clients')
                                : null,
                          ),
                          ListTile(
                            enabled: managementEnabled,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: Icon(
                              Icons.filter_alt_outlined,
                              color: theme.colorScheme.primary,
                            ),
                            title: const Text(
                              'Filters & Blocklists',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              'Manage adblock blocklists and whitelists',
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                            ),
                            onTap: managementEnabled
                                ? () => Navigator.pushNamed(context, '/filters')
                                : null,
                          ),
                          ListTile(
                            enabled: managementEnabled,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: Icon(
                              Icons.dns_outlined,
                              color: theme.colorScheme.primary,
                            ),
                            title: const Text(
                              'DNS Rewrites',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              'Redirect domains to custom IP addresses',
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                            ),
                            onTap: managementEnabled
                                ? () =>
                                      Navigator.pushNamed(context, '/rewrites')
                                : null,
                          ),
                          ListTile(
                            enabled: managementEnabled,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: Icon(
                              Icons.block_outlined,
                              color: theme.colorScheme.primary,
                            ),
                            title: const Text(
                              'Blocked Services',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              'Configure globally blocked services',
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                            ),
                            onTap: managementEnabled
                                ? () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const BlockedServicesPage(),
                                    ),
                                  )
                                : null,
                          ),
                          ListTile(
                            enabled: managementEnabled,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: Icon(
                              Icons.gavel_outlined,
                              color: theme.colorScheme.primary,
                            ),
                            title: const Text(
                              'Custom Rules',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text('Manage user blocking rules'),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                            ),
                            onTap: managementEnabled
                                ? () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CustomRulesPage(),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!managementEnabled) ...[
                    const SizedBox(height: 8),
                    const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text(
                        'Select one instance to edit its configuration',
                      ),
                      subtitle: Text(
                        'Unified mode is for aggregated statistics and shared protection controls.',
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // --- Aggregated View Section ---
                  if (_instances.length > 1) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                      child: Text(
                        'Aggregated View',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
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
                            _UnifiedTile(
                              isActive: _activeId == Instances.unifiedId,
                              onTap: _activeId == Instances.unifiedId
                                  ? null
                                  : () => _switchTo(Instances.unifiedId),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // --- Configured Instances Section ---
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: Text(
                      'Configured Instances',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_instances.isEmpty)
                    Card.filled(
                      child: const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'No AdGuard Home instances configured.\nTap "Add instance" to get started.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  else
                    Card.filled(
                      margin: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          children: [
                            for (final instance in _instances)
                              _instanceTile(instance),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class InstanceEditPage extends StatefulWidget {
  final String? id;
  const InstanceEditPage({super.key, required this.id});

  @override
  State<InstanceEditPage> createState() => _InstanceEditPageState();
}

class _InstanceEditPageState extends State<InstanceEditPage> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _host;
  late int _port;
  late bool _tls;
  late bool _verifySsl;
  late String _username;
  String? _password;
  bool _saving = false;

  bool get _isNew => widget.id == null;

  @override
  void initState() {
    super.initState();
    final existing = widget.id == null ? null : Instances.get(widget.id!);
    _name = existing?.name ?? '';
    _host = existing?.host ?? '';
    _port = existing?.port ?? 3000;
    _tls = existing?.tls ?? false;
    _verifySsl = existing?.verifySsl ?? true;
    _username = existing?.username ?? '';
    if (existing != null) {
      Instances.getPassword(existing.id).then((value) {
        if (mounted) setState(() => _password = value);
      });
    } else {
      _password = '';
    }
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    form.save();

    setState(() => _saving = true);
    try {
      final id = widget.id ?? Instances.generateId();
      final instance = Instance(
        id: id,
        name: _name.trim().isEmpty ? _host : _name.trim(),
        host: _host.trim(),
        port: _port,
        tls: _tls,
        verifySsl: _verifySsl,
        username: _username,
      );
      await Instances.save(instance);
      await Instances.setPassword(id, _password ?? '');
      if (!mounted) return;
      Navigator.pop(context, _isNew ? id : null);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isNew ? 'Add instance' : 'Edit instance')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Card.filled(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Name',
                        hintText: 'e.g. Home, Office',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      initialValue: _name,
                      onSaved: (v) => _name = v ?? '',
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Host',
                        hintText: 'IPv4, IPv6, or domain',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      initialValue: _host,
                      autocorrect: false,
                      keyboardType: TextInputType.url,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Host is required.'
                          : null,
                      onSaved: (v) => _host = (v ?? '').trim(),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Port',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      initialValue: _port.toString(),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Port is required.';
                        final port = int.tryParse(v);
                        if (port == null) return 'Port must be a number.';
                        if (port < 1 || port > 65535) {
                          return 'Port must be between 1 and 65535.';
                        }
                        return null;
                      },
                      onSaved: (v) => _port = int.parse(v ?? '0'),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Use HTTPS',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Connect over TLS'),
                      value: _tls,
                      onChanged: (v) => setState(() {
                        _tls = v;
                        if (!v) _verifySsl = true;
                      }),
                    ),
                    if (_tls)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Verify TLS certificate',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'Disable for self-signed certificates',
                        ),
                        value: _verifySsl,
                        onChanged: (v) => setState(() => _verifySsl = v),
                      ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      initialValue: _username,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Username is required.'
                          : null,
                      onSaved: (v) => _username = v ?? '',
                    ),
                    if (_password == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: LinearProgressIndicator(),
                      )
                    else
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        initialValue: _password,
                        obscureText: true,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Password is required.'
                            : null,
                        onSaved: (v) => _password = v ?? '',
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: _saving
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnifiedTile extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onTap;
  const _UnifiedTile({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        isActive ? Icons.radio_button_checked : Icons.merge_type,
        color: isActive ? scheme.primary : null,
      ),
      title: const Text(
        'Unified',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text(
        'Aggregated stats and controls across all instances',
      ),
      onTap: onTap,
    );
  }
}
