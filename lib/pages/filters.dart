import 'package:adguard_home_client/generated_api/export.dart';
import 'package:adguard_home_client/main.dart';
import 'package:adguard_home_client/utils/messages.dart';
import 'package:flutter/material.dart';

class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key});

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  FilterStatus? _status;
  bool _loading = true;
  String? _error;
  final Set<String> _updatingUrls = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChanged);
    _load();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (!_tabController.indexIsChanging && mounted) setState(() {});
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await dataSource!.getFilteringStatus();
      if (!mounted) return;
      setState(() {
        _status = res;
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

  Future<void> _toggleFilter(
    Filter filter,
    bool whitelist,
    bool newValue,
  ) async {
    if (_status == null || _updatingUrls.contains(filter.url)) return;

    // Get current lists
    final filters = _status!.filters == null
        ? <Filter>[]
        : List<Filter>.from(_status!.filters!);
    final whitelists = _status!.whitelistFilters == null
        ? <Filter>[]
        : List<Filter>.from(_status!.whitelistFilters!);
    final activeList = whitelist ? whitelists : filters;

    final idx = activeList.indexWhere((f) => f.url == filter.url);
    if (idx == -1) return;

    // Optimistic UI state update
    final updatedFilter = Filter(
      id: filter.id,
      name: filter.name,
      enabled: newValue,
      rulesCount: filter.rulesCount,
      url: filter.url,
      lastUpdated: filter.lastUpdated,
    );

    setState(() {
      _updatingUrls.add(filter.url);
      activeList[idx] = updatedFilter;
      _status = FilterStatus(
        enabled: _status!.enabled,
        interval: _status!.interval,
        userRules: _status!.userRules,
        filters: whitelist ? _status!.filters : activeList,
        whitelistFilters: whitelist ? activeList : _status!.whitelistFilters,
      );
    });

    try {
      await dataSource!.toggleFilter(
        filter.url,
        filter.name,
        newValue,
        whitelist,
      );
    } catch (e) {
      if (!mounted) return;
      // Revert optimistic update on failure
      setState(() {
        activeList[idx] = filter;
        _status = FilterStatus(
          enabled: _status!.enabled,
          interval: _status!.interval,
          userRules: _status!.userRules,
          filters: whitelist ? _status!.filters : activeList,
          whitelistFilters: whitelist ? activeList : _status!.whitelistFilters,
        );
      });
      showMessage(context, 'Failed to update filter: $e', error: true);
    } finally {
      if (mounted) setState(() => _updatingUrls.remove(filter.url));
    }
  }

  Future<void> _addFilter(String name, String url, bool whitelist) async {
    try {
      await dataSource!.addFilter(name, url, whitelist);
      _load(); // Reload fresh state
      if (mounted) showMessage(context, 'Filter added successfully');
    } catch (e) {
      if (mounted) {
        showMessage(context, 'Failed to add filter: $e', error: true);
      }
    }
  }

  Future<void> _removeFilter(Filter filter, bool whitelist) async {
    if (_status == null) return;

    // Get current lists
    final filters = _status!.filters == null
        ? <Filter>[]
        : List<Filter>.from(_status!.filters!);
    final whitelists = _status!.whitelistFilters == null
        ? <Filter>[]
        : List<Filter>.from(_status!.whitelistFilters!);
    final activeList = whitelist ? whitelists : filters;
    final previousStatus = _status;

    // Optimistic UI state update
    setState(() {
      activeList.removeWhere((f) => f.url == filter.url);
      _status = FilterStatus(
        enabled: _status!.enabled,
        interval: _status!.interval,
        userRules: _status!.userRules,
        filters: whitelist ? _status!.filters : activeList,
        whitelistFilters: whitelist ? activeList : _status!.whitelistFilters,
      );
    });

    try {
      await dataSource!.removeFilter(filter.url, whitelist);
    } catch (e) {
      if (!mounted) return;
      // Revert optimistic update
      setState(() {
        _status = previousStatus;
      });
      showMessage(context, 'Failed to remove filter: $e', error: true);
    }
  }

  Future<void> _refreshFilters() async {
    showMessage(context, 'Refreshing filter lists…');
    try {
      await dataSource!.refreshFilters();
      _load();
      if (mounted) showMessage(context, 'Filter lists refreshed');
    } catch (e) {
      if (mounted) showMessage(context, 'Refresh failed: $e', error: true);
    }
  }

  void _showAddDialog(bool whitelist) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            whitelist ? 'Add Whitelist Filter' : 'Add Blocklist Filter',
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Filter Name',
                      hintText: 'e.g. My Custom Filter',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Name cannot be empty'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      labelText: 'Filter URL / File Path',
                      hintText: 'e.g. https://example.com/filter.txt',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'URL/Path cannot be empty'
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
                  _addFilter(
                    nameController.text.trim(),
                    urlController.text.trim(),
                    whitelist,
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      urlController.dispose();
    });
  }

  Widget _buildFilterList(List<Filter>? list, bool whitelist, ThemeData theme) {
    if (list == null || list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_alt_outlined,
              size: 64,
              color: theme.colorScheme.secondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              whitelist
                  ? 'No whitelists configured'
                  : 'No blocklists configured',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final filter = list[index];
        return Card.filled(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              filter.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  filter.url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${filter.rulesCount} rules',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    if (filter.lastUpdated != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Updated: ${_formatDate(filter.lastUpdated!)}',
                        style: TextStyle(
                          color: theme.colorScheme.secondary.withValues(
                            alpha: 0.8,
                          ),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: filter.enabled,
                  onChanged: _updatingUrls.contains(filter.url)
                      ? null
                      : (val) => _toggleFilter(filter, whitelist, val),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Filter List?'),
                        content: Text(
                          'Are you sure you want to remove "${filter.name}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          FilledButton.tonal(
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.errorContainer,
                              foregroundColor:
                                  theme.colorScheme.onErrorContainer,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _removeFilter(filter, whitelist);
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
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters & Blocklists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Force Reload Rules',
            onPressed: _refreshFilters,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Status',
            onPressed: _load,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Blocklists'),
            Tab(text: 'Whitelists'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(_tabController.index == 1),
        icon: const Icon(Icons.add),
        label: Text(
          _tabController.index == 1 ? 'Add Whitelist' : 'Add Blocklist',
        ),
      ),
      body: _loading
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
                      'Failed to load filters: $_error',
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
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFilterList(_status?.filters, false, theme),
                _buildFilterList(_status?.whitelistFilters, true, theme),
              ],
            ),
    );
  }
}
