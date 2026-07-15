import 'package:adguard_home_client/interface/querylog.dart';
import 'package:adguard_home_client/main.dart';
import 'package:adguard_home_client/utils/messages.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QueryLogPage extends StatefulWidget {
  const QueryLogPage({super.key});

  @override
  State<QueryLogPage> createState() => _QueryLogPageState();
}

class _QueryLogPageState extends State<QueryLogPage> {
  final List<QueryLogEntry> _entries = [];
  String _search = '';
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  QueryLogReasonFilter _reasonFilter = QueryLogReasonFilter.all;
  QueryLogCursor? _cursor;
  String? _sourceFilter;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  Object? _error;

  static final _timeFormat = DateFormat('HH:mm:ss');
  static final _dateFormat = DateFormat('y-MM-dd');

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.position.extentAfter < 320 &&
        _hasMore &&
        !_loading &&
        !_loadingMore) {
      _load(more: true);
    }
  }

  Future<void> _load({bool more = false}) async {
    if (more) {
      if (!_hasMore || _loadingMore) return;
      setState(() => _loadingMore = true);
    } else {
      setState(() {
        _loading = true;
        _error = null;
        _cursor = null;
        _hasMore = true;
      });
    }
    try {
      final batch = await dataSource!.queryLog(
        limit: 100,
        search: _search,
        reasonFilter: _reasonFilter,
        cursor: more ? _cursor : null,
        source: _sourceFilter,
      );
      if (!mounted) return;
      setState(() {
        if (!more) _entries.clear();
        final existing = {
          for (final entry in _entries)
            '${entry.source}\u0000${entry.time.toIso8601String()}\u0000${entry.client}\u0000${entry.question}',
        };
        for (final entry in batch.entries) {
          final key =
              '${entry.source}\u0000${entry.time.toIso8601String()}\u0000${entry.client}\u0000${entry.question}';
          if (existing.add(key)) _entries.add(entry);
        }
        _cursor = batch.nextCursor;
        _hasMore = batch.nextCursor != null && batch.entries.isNotEmpty;
        _loading = false;
        _loadingMore = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        if (more) {
          _hasMore = false;
        } else {
          _error = error;
        }
      });
      if (more) {
        showMessage(
          context,
          'Could not load older queries: $error',
          error: true,
        );
      }
    }
  }

  Future<void> _refresh() async {
    await _load();
  }

  void _setReasonFilter(QueryLogReasonFilter filter) {
    if (_reasonFilter == filter) return;
    setState(() {
      _reasonFilter = filter;
    });
    _load();
  }

  void _setSourceFilter(String? source) {
    if (_sourceFilter == source) return;
    setState(() => _sourceFilter = source);
    _load();
  }

  void _showDetails(BuildContext context, QueryLogEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final blocked = entry.blocked;
        final color = blocked ? scheme.error : scheme.primary;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.question,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${DateFormat('y-MM-dd HH:mm:ss').format(entry.time)} • ${entry.questionType}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const Divider(height: 32),
                if (entry.source != null) _row('Instance', entry.source!),
                _row('Client', entry.client),
                _row(
                  'Status',
                  entry.blocked ? 'Blocked' : 'Allowed',
                  valueColor: color,
                ),
                _row('Reason', _humanReason(entry.reason)),
                _row('Elapsed', '${entry.elapsedMs} ms'),
                if (entry.rule != null && entry.rule!.isNotEmpty)
                  _row('Rule', entry.rule!),
                if (entry.answers.isNotEmpty)
                  _row('Answer', entry.answers.join(', ')),
                const Divider(height: 24),
                FutureBuilder<List<String>>(
                  future: dataSource!.getUserRules(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Failed to load rules: ${snapshot.error}',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      );
                    }
                    final rules = snapshot.data ?? [];
                    final domain = entry.question;
                    final blockRule = '||$domain^';
                    final whitelistRule = '@@||$domain^';

                    final isBlocked = rules.contains(blockRule);
                    final isWhitelisted = rules.contains(whitelistRule);
                    var loadingAction = false;

                    return StatefulBuilder(
                      builder: (context, setSheetState) {
                        Future<void> handleAction(
                          Future<void> Function() action,
                          String successMsg,
                        ) async {
                          setSheetState(() => loadingAction = true);
                          try {
                            await action();
                            if (mounted && context.mounted) {
                              Navigator.pop(
                                context,
                              ); // Close details bottom sheet
                              showMessage(this.context, successMsg);
                            }
                          } catch (e) {
                            if (mounted && context.mounted) {
                              setSheetState(() => loadingAction = false);
                              showMessage(
                                this.context,
                                'Failed: $e',
                                error: true,
                              );
                            }
                          }
                        }

                        if (loadingAction) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }

                        return Row(
                          children: [
                            if (isBlocked)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => handleAction(
                                    () => dataSource!.removeUserRule(blockRule),
                                    'Removed block rule for $domain',
                                  ),
                                  icon: const Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                  ),
                                  label: const Text('Unblock Domain'),
                                ),
                              )
                            else if (isWhitelisted)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => handleAction(
                                    () => dataSource!.removeUserRule(
                                      whitelistRule,
                                    ),
                                    'Removed whitelist rule for $domain',
                                  ),
                                  icon: const Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                  ),
                                  label: const Text('Remove Whitelist'),
                                ),
                              )
                            else ...[
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: () => handleAction(
                                    () => dataSource!.addUserRule(blockRule),
                                    'Blocked $domain',
                                  ),
                                  icon: const Icon(Icons.block, size: 16),
                                  label: const Text('Block'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        theme.colorScheme.errorContainer,
                                    foregroundColor:
                                        theme.colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: () => handleAction(
                                    () =>
                                        dataSource!.addUserRule(whitelistRule),
                                    'Whitelisted $domain',
                                  ),
                                  icon: const Icon(Icons.security, size: 16),
                                  label: const Text('Whitelist'),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
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

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: valueColor != null ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _humanReason(String reason) {
    switch (reason) {
      case 'NotFilteredNotFound':
      case 'NotFilteredAllowList':
      case 'NotFilteredWhiteList':
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
      case 'RewriteEtcHosts':
      case 'RewriteRule':
        return 'Rewrite';
      default:
        return reason.isEmpty ? 'Unknown' : reason;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Query Log'),
        actions: [
          if (dataSource!.sourceNames.isNotEmpty)
            PopupMenuButton<String>(
              tooltip: 'Filter by instance',
              icon: const Icon(Icons.dns_outlined),
              onSelected: (value) =>
                  _setSourceFilter(value.isEmpty ? null : value),
              itemBuilder: (context) => [
                CheckedPopupMenuItem(
                  value: '',
                  checked: _sourceFilter == null,
                  child: const Text('All instances'),
                ),
                for (final source in dataSource!.sourceNames)
                  CheckedPopupMenuItem(
                    value: source,
                    checked: _sourceFilter == source,
                    child: Text(source),
                  ),
              ],
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(116),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    _search = value.trim();
                    _load();
                  },
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  children: [
                    for (final filter in QueryLogReasonFilter.values) ...[
                      FilterChip(
                        label: Text(switch (filter) {
                          QueryLogReasonFilter.all => 'All',
                          QueryLogReasonFilter.allowed => 'Allowed',
                          QueryLogReasonFilter.blocked => 'Blocked',
                          QueryLogReasonFilter.rewritten => 'Rewritten',
                        }),
                        selected: _reasonFilter == filter,
                        onSelected: (_) => _setReasonFilter(filter),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 64),
                  Center(child: Text('Failed to load: $_error')),
                  const SizedBox(height: 16),
                  Center(
                    child: FilledButton.tonal(
                      onPressed: _load,
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              )
            : _entries.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 64),
                  Center(child: Text('No queries logged.')),
                ],
              )
            : ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                itemCount: _entries.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == _entries.length) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final entry = _entries[i];
                  return Card.filled(
                    margin: const EdgeInsets.only(bottom: 6.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showDetails(context, entry),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: _QueryLogTile(
                          entry: entry,
                          timeFormat: _timeFormat,
                          dateFormat: _dateFormat,
                        ),
                      ),
                    ),
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

  const _QueryLogTile({
    required this.entry,
    required this.timeFormat,
    required this.dateFormat,
  });

  String _humanReason(String reason) {
    switch (reason) {
      case 'NotFilteredNotFound':
      case 'NotFilteredAllowList':
      case 'NotFilteredWhiteList':
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
      case 'RewriteEtcHosts':
      case 'RewriteRule':
        return 'Rewrite';
      default:
        return reason.isEmpty ? 'Unknown' : reason;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final blocked = entry.blocked;

    final Color badgeBg;
    final Color badgeText;
    final String badgeLabel = _humanReason(entry.reason);

    if (blocked) {
      badgeBg = scheme.errorContainer;
      badgeText = scheme.onErrorContainer;
    } else if (entry.reason == 'Rewrite' ||
        entry.reason == 'RewriteAutoHosts') {
      badgeBg = scheme.tertiaryContainer;
      badgeText = scheme.onTertiaryContainer;
    } else {
      badgeBg = scheme.primaryContainer;
      badgeText = scheme.onPrimaryContainer;
    }

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: blocked
                ? scheme.error.withValues(alpha: 0.1)
                : scheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            blocked ? Icons.block : Icons.check_circle_outline,
            color: blocked ? scheme.error : scheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.question.isEmpty ? '(unknown)' : entry.question,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                [
                  if (entry.source != null) entry.source!,
                  entry.client,
                  entry.questionType,
                  '${entry.elapsedMs} ms',
                ].join(' • '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateUtils.isSameDay(entry.time, DateTime.now())
                  ? timeFormat.format(entry.time)
                  : '${dateFormat.format(entry.time)}\n${timeFormat.format(entry.time)}',
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: badgeText,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
