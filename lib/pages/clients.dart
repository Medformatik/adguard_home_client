import 'package:adguard_home_client/generated_api/export.dart';
import 'package:adguard_home_client/main.dart';
import 'package:adguard_home_client/pages/client_edit.dart';
import 'package:adguard_home_client/utils/messages.dart';
import 'package:flutter/material.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  Clients? _clientsData;
  bool _loading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await dataSource!.getClients();
      if (!mounted) return;
      setState(() {
        _clientsData = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deleteClient(Client client) async {
    if (_clientsData == null || client.name == null) return;
    final name = client.name!;
    final previousList = List<Client>.from(_clientsData!.clients ?? const []);

    // Optimistic UI update
    setState(() {
      _clientsData!.clients?.removeWhere((c) => c.name == name);
    });

    try {
      await dataSource!.deleteClient(name);
      if (mounted) showMessage(context, 'Client "$name" deleted');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _clientsData = Clients(
          clients: previousList,
          autoClients: _clientsData!.autoClients,
          supportedTags: _clientsData!.supportedTags,
        );
      });
      showMessage(context, 'Failed to delete client: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final configured = _clientsData?.clients;
    final filtered = configured?.where((c) {
      final name = (c.name ?? '').toLowerCase();
      final ids = (c.ids ?? []).join(' ').toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || ids.contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ClientEditPage(supportedTags: _clientsData?.supportedTags),
            ),
          );
          if (added == true) _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Client'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search clients by name or ID...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load: $_error',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.tonal(
                            onPressed: _load,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : filtered == null || filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.devices_other_outlined,
                          size: 64,
                          color: theme.colorScheme.secondary.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No clients match "$_searchQuery"'
                              : 'No clients configured',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final client = filtered[index];
                      return Card.filled(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final updated = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClientEditPage(
                                  client: client,
                                  supportedTags: _clientsData?.supportedTags,
                                ),
                              ),
                            );
                            if (updated == true) _load();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        client.name ?? '',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit_outlined,
                                        color: theme.colorScheme.primary,
                                        size: 20,
                                      ),
                                      onPressed: () async {
                                        final updated =
                                            await Navigator.push<bool>(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ClientEditPage(
                                                      client: client,
                                                      supportedTags:
                                                          _clientsData
                                                              ?.supportedTags,
                                                    ),
                                              ),
                                            );
                                        if (updated == true) _load();
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: theme.colorScheme.error,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Client?'),
                                            content: Text(
                                              'Are you sure you want to delete client "${client.name}"?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              FilledButton.tonal(
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: theme
                                                      .colorScheme
                                                      .errorContainer,
                                                  foregroundColor: theme
                                                      .colorScheme
                                                      .onErrorContainer,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _deleteClient(client);
                                                },
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    for (final id in client.ids ?? [])
                                      Chip(
                                        visualDensity: VisualDensity.compact,
                                        label: Text(
                                          id,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (client.useGlobalSettings != false)
                                  const Chip(
                                    avatar: Icon(Icons.sync, size: 16),
                                    label: Text('Inherits global protection'),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _FeatureChip(
                                        label: 'AdBlock',
                                        enabled:
                                            client.filteringEnabled ?? false,
                                      ),
                                      _FeatureChip(
                                        label: 'Parental',
                                        enabled:
                                            client.parentalEnabled ?? false,
                                      ),
                                      _FeatureChip(
                                        label: 'Browsing',
                                        enabled:
                                            client.safebrowsingEnabled ?? false,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  final bool enabled;

  const _FeatureChip({required this.label, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(
        enabled ? Icons.check_circle : Icons.cancel_outlined,
        size: 16,
      ),
      label: Text(label),
    );
  }
}
