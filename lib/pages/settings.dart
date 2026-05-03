import 'package:adguard_home_client/main.dart';
import 'package:adguard_home_client/utils/init.dart';
import 'package:adguard_home_client/utils/instances.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

    if (_instances.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _addInstance());
    }
  }

  void _refreshFromStorage() {
    _instances = Instances.list();
    _activeId = Instances.getActiveId();
  }

  Future<void> _switchTo(String id) async {
    final ok = await initAdGuardHome(switchTo: id);
    if (!mounted) return;
    if (ok) {
      activeInstanceName.value = Instances.get(id)?.name;
      protectionStatus.value = null;
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } else {
      Fluttertoast.showToast(
        msg: 'Could not connect to "${Instances.get(id)?.name ?? "instance"}". Check its settings.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(_refreshFromStorage);
    }
  }

  Future<void> _editInstance(Instance instance) async {
    await Navigator.of(context).push<void>(MaterialPageRoute(
      builder: (_) => InstanceEditPage(id: instance.id),
    ));
    if (!mounted) return;
    setState(_refreshFromStorage);
    if (instance.id == _activeId) {
      // Active instance was edited — reconnect with the latest values.
      await initAdGuardHome();
      if (mounted) activeInstanceName.value = Instances.get(instance.id)?.name;
    }
  }

  Future<void> _addInstance() async {
    final newId = await Navigator.of(context).push<String?>(MaterialPageRoute(
      builder: (_) => const InstanceEditPage(id: null),
    ));
    if (!mounted) return;
    setState(_refreshFromStorage);
    if (newId != null) await _switchTo(newId);
  }

  Future<void> _confirmDelete(Instance instance) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "${instance.name}"?'),
        content: const Text('This removes the instance configuration and stored password from this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton.tonal(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.errorContainer),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
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
      if (mounted) activeInstanceName.value = Instances.get(newActive)?.name;
    } else {
      adGuardHome = null;
      activeInstanceName.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instances')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addInstance,
        icon: const Icon(Icons.add),
        label: const Text('Add instance'),
      ),
      body: SafeArea(
        child: _instances.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No AdGuard Home instances configured.\nTap "Add instance" to get started.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.separated(
                itemCount: _instances.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final instance = _instances[i];
                  final isActive = instance.id == _activeId;
                  return ListTile(
                    leading: Icon(
                      isActive ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isActive ? Theme.of(context).colorScheme.primary : null,
                    ),
                    title: Text(instance.name.isEmpty ? '(unnamed)' : instance.name),
                    subtitle: Text('${instance.tls ? 'https' : 'http'}://${instance.host}:${instance.port}'),
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
                },
              ),
      ),
    );
  }
}

class InstanceEditPage extends StatefulWidget {
  /// `null` means "create a new instance".
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
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'e.g. Home, Office',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _name,
                      onSaved: (v) => _name = v ?? '',
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Host',
                        hintText: 'IPv4, IPv6, or domain',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _host,
                      autocorrect: false,
                      keyboardType: TextInputType.url,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Host is required.' : null,
                      onSaved: (v) => _host = (v ?? '').trim(),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Port',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _port.toString(),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Port is required.';
                        final port = int.tryParse(v);
                        if (port == null) return 'Port must be a number.';
                        if (port < 1 || port > 65535) return 'Port must be between 1 and 65535.';
                        return null;
                      },
                      onSaved: (v) => _port = int.parse(v ?? '0'),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Use HTTPS'),
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
                        title: const Text('Verify TLS certificate'),
                        subtitle: const Text('Disable for self-signed certificates'),
                        value: _verifySsl,
                        onChanged: (v) => setState(() => _verifySsl = v),
                      ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _username,
                      validator: (v) => (v == null || v.isEmpty) ? 'Username is required.' : null,
                      onSaved: (v) => _username = v ?? '',
                    ),
                    if (_password == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: LinearProgressIndicator(),
                      )
                    else
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _password,
                        obscureText: true,
                        validator: (v) => (v == null || v.isEmpty) ? 'Password is required.' : null,
                        onSaved: (v) => _password = v ?? '',
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save'),
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
