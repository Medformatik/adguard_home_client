import 'package:adguard_home_client/generated_api/export.dart';
import 'package:adguard_home_client/main.dart';
import 'package:adguard_home_client/utils/messages.dart';
import 'package:flutter/material.dart';

class DnsRewritesPage extends StatefulWidget {
  const DnsRewritesPage({super.key});

  @override
  State<DnsRewritesPage> createState() => _DnsRewritesPageState();
}

class _DnsRewritesPageState extends State<DnsRewritesPage> {
  List<RewriteEntry>? _rewrites;
  String _searchQuery = '';
  bool _loading = true;
  String? _error;
  final Set<String> _updating = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await dataSource!.getRewrites();
      if (!mounted) return;
      setState(() {
        _rewrites = list;
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

  Future<void> _addRewrite(String domain, String answer) async {
    if (_rewrites == null) return;
    final newEntry = RewriteEntry(
      domain: domain,
      answer: answer,
      enabled: true,
    );

    // Optimistic UI update
    setState(() {
      _rewrites!.insert(0, newEntry);
    });

    try {
      await dataSource!.addRewrite(domain, answer);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _rewrites!.remove(newEntry);
      });
      showMessage(context, 'Failed to add rewrite: $e', error: true);
    }
  }

  Future<void> _deleteRewrite(RewriteEntry entry) async {
    if (_rewrites == null) return;
    final domain = entry.domain ?? '';
    final answer = entry.answer ?? '';
    final previousList = List<RewriteEntry>.from(_rewrites!);

    // Optimistic UI update
    setState(() {
      _rewrites!.remove(entry);
    });

    try {
      await dataSource!.deleteRewrite(domain, answer);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _rewrites = previousList;
      });
      showMessage(context, 'Failed to delete rewrite: $e', error: true);
    }
  }

  Future<void> _setEnabled(RewriteEntry entry, bool enabled) async {
    if (_rewrites == null) return;
    final key = '${entry.domain}\u0000${entry.answer}';
    if (_updating.contains(key)) return;
    final index = _rewrites!.indexOf(entry);
    if (index == -1) return;
    final updated = RewriteEntry(
      domain: entry.domain,
      answer: entry.answer,
      enabled: enabled,
    );
    setState(() {
      _updating.add(key);
      _rewrites![index] = updated;
    });
    try {
      await dataSource!.updateRewrite(entry, updated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _rewrites![index] = entry);
      showMessage(context, 'Failed to update rewrite: $e', error: true);
    } finally {
      if (mounted) setState(() => _updating.remove(key));
    }
  }

  void _showAddDialog() {
    final domainController = TextEditingController();
    final answerController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add DNS Rewrite'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: domainController,
                    decoration: const InputDecoration(
                      labelText: 'Domain Name',
                      hintText: 'e.g. router.lan or *.local.dev',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Domain cannot be empty'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: answerController,
                    decoration: const InputDecoration(
                      labelText: 'IP Address / CNAME',
                      hintText: 'e.g. 192.168.1.1 or nas.local',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Answer/Redirect target cannot be empty'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  _addRewrite(
                    domainController.text.trim(),
                    answerController.text.trim(),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      domainController.dispose();
      answerController.dispose();
    });
  }

  Future<void> _confirmDelete(RewriteEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text('Delete DNS rewrite?'),
        content: Text('Remove ${entry.domain} → ${entry.answer}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _deleteRewrite(entry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _rewrites?.where((e) {
      final domain = (e.domain ?? '').toLowerCase();
      final answer = (e.answer ?? '').toLowerCase();
      final q = _searchQuery.toLowerCase();
      return domain.contains(q) || answer.contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DNS Rewrites'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Rule'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search rules...',
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
                          Icons.dns_outlined,
                          size: 64,
                          color: theme.colorScheme.secondary.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No rules match "$_searchQuery"'
                              : 'No DNS rewrite rules configured',
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
                      final entry = filtered[index];
                      final updateKey = '${entry.domain}\u0000${entry.answer}';
                      return Card.filled(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.swap_horiz,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: Text(
                            entry.domain ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              entry.answer ?? '',
                              style: TextStyle(
                                color: theme.colorScheme.secondary,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: entry.enabled,
                                onChanged: _updating.contains(updateKey)
                                    ? null
                                    : (value) => _setEnabled(entry, value),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Delete rewrite',
                                onPressed: () => _confirmDelete(entry),
                              ),
                            ],
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
