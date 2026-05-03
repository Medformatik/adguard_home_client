import 'package:adguard_home_client/interface/querylog.dart';
import 'package:adguard_home_client/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QueryLogPage extends StatefulWidget {
  const QueryLogPage({super.key});

  @override
  State<QueryLogPage> createState() => _QueryLogPageState();
}

class _QueryLogPageState extends State<QueryLogPage> {
  Future<List<QueryLogEntry>>? _entries;
  String _search = '';
  final _searchController = TextEditingController();

  static final _timeFormat = DateFormat('HH:mm:ss');
  static final _dateFormat = DateFormat('y-MM-dd');

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _load() {
    setState(() {
      _entries = dataSource!.queryLog(limit: 100, search: _search);
    });
  }

  Future<void> _refresh() async {
    _load();
    try {
      await _entries;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Query Log'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Filter by domain or client',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _search = '';
                          _load();
                        },
                      ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                _search = value.trim();
                _load();
              },
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<QueryLogEntry>>(
          future: _entries,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 64),
                  Center(child: Text('Failed to load: ${snapshot.error}')),
                ],
              );
            }
            final items = snapshot.data ?? const [];
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 64),
                  Center(child: Text('No queries logged.')),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) => _QueryLogTile(entry: items[i], timeFormat: _timeFormat, dateFormat: _dateFormat),
            );
          },
        ),
      ),
    );
  }
}

class _QueryLogTile extends StatelessWidget {
  final QueryLogEntry entry;
  final DateFormat timeFormat;
  final DateFormat dateFormat;

  const _QueryLogTile({required this.entry, required this.timeFormat, required this.dateFormat});

  String _humanReason(String reason) {
    switch (reason) {
      case 'NotFilteredNotFound':
      case 'NotFilteredAllowList':
        return 'Allowed';
      case 'FilteredBlackList':
        return 'Blocked';
      case 'FilteredSafeBrowsing':
        return 'Safe Browsing';
      case 'FilteredParental':
        return 'Parental';
      case 'FilteredInvalid':
        return 'Invalid';
      case 'FilteredSafeSearch':
        return 'Safe Search';
      case 'FilteredBlockedService':
        return 'Service';
      case 'Rewrite':
      case 'RewriteAutoHosts':
        return 'Rewrite';
      default:
        return reason.isEmpty ? 'Unknown' : reason;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final blocked = entry.blocked;
    final color = blocked ? scheme.error : scheme.primary;
    return ListTile(
      leading: Icon(
        blocked ? Icons.block : Icons.check_circle_outline,
        color: color,
      ),
      title: Text(
        entry.question.isEmpty ? '(unknown)' : entry.question,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        [
          if (entry.source != null) entry.source!,
          entry.client,
          entry.questionType,
          '${entry.elapsedMs} ms',
        ].join(' • '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(dateFormat.format(entry.time), style: Theme.of(context).textTheme.bodySmall),
          Text(timeFormat.format(entry.time), style: Theme.of(context).textTheme.bodySmall),
          Text(
            _humanReason(entry.reason),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
      onTap: () => _showDetails(context),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.question, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('y-MM-dd HH:mm:ss').format(entry.time)} • ${entry.questionType}',
                  style: theme.textTheme.bodySmall,
                ),
                const Divider(height: 24),
                if (entry.source != null) _row('Instance', entry.source!),
                _row('Client', entry.client),
                _row('Reason', _humanReason(entry.reason)),
                _row('Elapsed', '${entry.elapsedMs} ms'),
                if (entry.rule != null && entry.rule!.isNotEmpty) _row('Rule', entry.rule!),
                if (entry.answers.isNotEmpty) _row('Answer', entry.answers.join(', ')),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
