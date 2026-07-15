import 'package:adguard_home_client/generated_api/export.dart';
import 'package:adguard_home_client/main.dart';
import 'package:adguard_home_client/utils/messages.dart';
import 'package:flutter/material.dart';

class ClientEditPage extends StatefulWidget {
  final Client? client;
  final List<String>? supportedTags;

  const ClientEditPage({super.key, this.client, this.supportedTags});

  @override
  State<ClientEditPage> createState() => _ClientEditPageState();
}

class _ClientEditPageState extends State<ClientEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _idsController;

  bool _useGlobalSettings = true;
  bool _filteringEnabled = false;
  bool _parentalEnabled = false;
  bool _safebrowsingEnabled = false;
  bool _safesearchEnabled = false;
  bool _ignoreQuerylog = false;
  bool _ignoreStatistics = false;
  List<String> _tags = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.client;
    _nameController = TextEditingController(text: c?.name ?? '');
    _idsController = TextEditingController(text: (c?.ids ?? []).join(', '));

    _useGlobalSettings = c?.useGlobalSettings ?? true;
    _filteringEnabled = c?.filteringEnabled ?? false;
    _parentalEnabled = c?.parentalEnabled ?? false;
    _safebrowsingEnabled = c?.safebrowsingEnabled ?? false;
    _safesearchEnabled =
        c?.safeSearch?.enabled ?? c?.safesearchEnabled ?? false;
    _ignoreQuerylog = c?.ignoreQuerylog ?? false;
    _ignoreStatistics = c?.ignoreStatistics ?? false;
    _tags = List<String>.from(c?.tags ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final ids = _idsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final payload = Client(
      name: _nameController.text.trim(),
      ids: ids,
      useGlobalSettings: _useGlobalSettings,
      filteringEnabled: _filteringEnabled,
      parentalEnabled: _parentalEnabled,
      safebrowsingEnabled: _safebrowsingEnabled,
      safesearchEnabled: _safesearchEnabled,
      safeSearch: SafeSearchConfig(
        enabled: _safesearchEnabled,
        bing: widget.client?.safeSearch?.bing,
        duckduckgo: widget.client?.safeSearch?.duckduckgo,
        ecosia: widget.client?.safeSearch?.ecosia,
        google: widget.client?.safeSearch?.google,
        pixabay: widget.client?.safeSearch?.pixabay,
        yandex: widget.client?.safeSearch?.yandex,
        youtube: widget.client?.safeSearch?.youtube,
      ),
      useGlobalBlockedServices: widget.client?.useGlobalBlockedServices ?? true,
      blockedServicesSchedule: widget.client?.blockedServicesSchedule,
      blockedServices: widget.client?.blockedServices ?? const [],
      upstreams: widget.client?.upstreams ?? const [],
      tags: _tags,
      ignoreQuerylog: _ignoreQuerylog,
      ignoreStatistics: _ignoreStatistics,
      upstreamsCacheEnabled: widget.client?.upstreamsCacheEnabled,
      upstreamsCacheSize: widget.client?.upstreamsCacheSize,
    );

    try {
      final String successMessage;
      if (widget.client != null) {
        await dataSource!.updateClient(widget.client!.name!, payload);
        successMessage = 'Client updated successfully';
      } else {
        await dataSource!.addClient(payload);
        successMessage = 'Client added successfully';
      }
      if (!mounted) return;
      showMessage(context, successMessage);
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      if (mounted) {
        showMessage(context, 'Failed to save client: $e', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.client != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Client' : 'Add Client')),
      body: _saving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // General Settings Card
                  Card.filled(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Client Details',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Friendly Name',
                              hintText: 'e.g. My Laptop',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Name is required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _idsController,
                            decoration: const InputDecoration(
                              labelText: 'IP, CIDR, MAC, or Client ID',
                              hintText: 'e.g. 192.168.1.10, AA:BB:CC:11:22:33',
                              helperText: 'Separate multiple items with commas',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'At least one identifier is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Policy Settings Card
                  Card.filled(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Protection Policies',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Use Global Settings',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              'Inherit DNS upstreams and blocking policies from global configuration',
                            ),
                            value: _useGlobalSettings,
                            onChanged: (val) =>
                                setState(() => _useGlobalSettings = val),
                          ),
                          if (!_useGlobalSettings) ...[
                            const Divider(height: 24),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'AdBlock Filtering',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: const Text(
                                'Block ad server domains for this client',
                              ),
                              value: _filteringEnabled,
                              onChanged: (val) =>
                                  setState(() => _filteringEnabled = val),
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Safe Browsing',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: const Text(
                                'Block malware and phishing domains',
                              ),
                              value: _safebrowsingEnabled,
                              onChanged: (val) =>
                                  setState(() => _safebrowsingEnabled = val),
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Parental Control',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: const Text(
                                'Block adult sites and content',
                              ),
                              value: _parentalEnabled,
                              onChanged: (val) =>
                                  setState(() => _parentalEnabled = val),
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Safe Search',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: const Text(
                                'Enforce safe search on major search engines',
                              ),
                              value: _safesearchEnabled,
                              onChanged: (val) =>
                                  setState(() => _safesearchEnabled = val),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Card.filled(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Exclude from query log'),
                            subtitle: const Text(
                              'Do not retain this client’s DNS queries',
                            ),
                            value: _ignoreQuerylog,
                            onChanged: (value) =>
                                setState(() => _ignoreQuerylog = value),
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Exclude from statistics'),
                            subtitle: const Text(
                              'Do not include this client in dashboard totals',
                            ),
                            value: _ignoreStatistics,
                            onChanged: (value) =>
                                setState(() => _ignoreStatistics = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tags Card
                  if (widget.supportedTags != null &&
                      widget.supportedTags!.isNotEmpty)
                    Card.filled(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tags',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final tag in widget.supportedTags!)
                                  FilterChip(
                                    label: Text(tag),
                                    selected: _tags.contains(tag),
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _tags.add(tag);
                                        } else {
                                          _tags.remove(tag);
                                        }
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed: _save,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        isEdit ? 'Save Changes' : 'Create Client',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
