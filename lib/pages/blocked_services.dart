import 'dart:convert';
import 'package:adguard_home_client/interface/blocked_services.dart';
import 'package:adguard_home_client/main.dart';
import 'package:adguard_home_client/generated_api/export.dart'
    hide BlockedService;
import 'package:adguard_home_client/pages/blocked_services_schedule.dart';
import 'package:adguard_home_client/utils/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BlockedServicesPage extends StatefulWidget {
  const BlockedServicesPage({super.key});

  @override
  State<BlockedServicesPage> createState() => _BlockedServicesPageState();
}

class _BlockedServicesPageState extends State<BlockedServicesPage> {
  List<BlockedService>? _allServices;
  List<String>? _blockedIds;
  Schedule? _schedule;
  String _searchQuery = '';
  bool _loading = true;
  String? _error;
  final Set<String> _updatingIds = {};

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
      final results = await Future.wait([
        dataSource!.getAvailableBlockedServices(),
        dataSource!.getBlockedServicesSchedule(),
      ]);
      if (!mounted) return;
      setState(() {
        _allServices = results[0] as List<BlockedService>;
        final config = results[1] as BlockedServicesSchedule;
        _blockedIds = config.ids ?? const [];
        _schedule = config.schedule ?? const Schedule(timeZone: 'Local');
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _editSchedule() async {
    final current = _schedule;
    if (current == null) return;
    final updated = await Navigator.of(context).push<Schedule>(
      MaterialPageRoute(
        builder: (_) => BlockedServicesSchedulePage(schedule: current),
      ),
    );
    if (updated == null || !mounted) return;
    try {
      await dataSource!.updateBlockedServicesSchedule(updated);
      if (!mounted) return;
      setState(() => _schedule = updated);
      showMessage(context, 'Service schedule saved');
    } catch (error) {
      if (mounted) {
        showMessage(context, 'Could not save schedule: $error', error: true);
      }
    }
  }

  Future<void> _toggleService(
    BlockedService service,
    bool currentlyBlocked,
  ) async {
    if (_blockedIds == null || _updatingIds.contains(service.id)) return;
    final id = service.id;
    final previousBlockedList = List<String>.from(_blockedIds!);

    final newBlockedList = List<String>.from(_blockedIds!);
    if (currentlyBlocked) {
      newBlockedList.remove(id);
    } else {
      newBlockedList.add(id);
    }

    setState(() {
      _blockedIds = newBlockedList;
      _updatingIds.add(id);
    });

    try {
      await dataSource!.updateBlockedServices(newBlockedList);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _blockedIds = previousBlockedList;
      });
      showMessage(context, 'Failed to update ${service.name}: $e', error: true);
    } finally {
      if (mounted) setState(() => _updatingIds.remove(id));
    }
  }

  String _formatGroupName(String? groupId) {
    if (groupId == null || groupId.isEmpty) return 'General Services';
    switch (groupId.toLowerCase()) {
      case 'social':
        return 'Social Media';
      case 'gaming':
        return 'Gaming';
      case 'media':
      case 'streaming':
      case 'video':
        return 'Media & Streaming';
      case 'shopping':
        return 'Shopping';
      case 'communication':
      case 'chat':
        return 'Communication';
      case 'entertainment':
        return 'Entertainment';
      default:
        if (groupId.length >= 2 && groupId.length <= 3) {
          return groupId.toUpperCase();
        }
        return groupId[0].toUpperCase() + groupId.substring(1);
    }
  }

  Widget _buildIcon(BlockedService service, ThemeData theme, bool isBlocked) {
    if (service.iconSvg != null && service.iconSvg!.isNotEmpty) {
      try {
        String svgString = service.iconSvg!;

        // Handle Base64 encoded or Data URLs
        if (svgString.startsWith('data:image/svg+xml;base64,')) {
          final base64Content = svgString.substring(
            'data:image/svg+xml;base64,'.length,
          );
          svgString = utf8.decode(base64Decode(base64Content.trim()));
        } else if (!svgString.startsWith('<svg')) {
          svgString = utf8.decode(base64Decode(svgString.trim()));
        }

        if (svgString.startsWith('<svg')) {
          return SvgPicture.string(
            svgString,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              isBlocked ? theme.colorScheme.error : theme.colorScheme.primary,
              BlendMode.srcIn,
            ),
          );
        }
      } catch (_) {
        // Fallback on error
      }
    }

    return Icon(
      isBlocked ? Icons.block : Icons.check_circle_outline,
      color: isBlocked ? theme.colorScheme.error : theme.colorScheme.primary,
      size: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredServices = _allServices?.where((s) {
      final query = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(query) ||
          s.id.toLowerCase().contains(query);
    }).toList();

    // Group the filtered services
    final grouped = <String, List<BlockedService>>{};
    if (filteredServices != null) {
      for (final s in filteredServices) {
        final groupName = (s.groupName != null && s.groupName!.isNotEmpty)
            ? s.groupName!
            : _formatGroupName(s.groupId);
        grouped.putIfAbsent(groupName, () => []).add(s);
      }
    }
    final sortedGroupKeys = grouped.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Services'),
        actions: [
          IconButton.filledTonal(
            tooltip: 'Allowed periods',
            onPressed: _schedule == null ? null : _editSchedule,
            icon: const Icon(Icons.calendar_month_outlined),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search services',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load services: $_error',
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
            : filteredServices == null || filteredServices.isEmpty
            ? const Center(child: Text('No services found.'))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
                itemCount: sortedGroupKeys.length,
                itemBuilder: (context, gIndex) {
                  final groupName = sortedGroupKeys[gIndex];
                  final servicesInGroup = grouped[groupName]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                        child: Text(
                          groupName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      Card.filled(
                        margin: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            children: servicesInGroup.map((service) {
                              final isBlocked =
                                  _blockedIds?.contains(service.id) ?? false;
                              final isUpdating = _updatingIds.contains(
                                service.id,
                              );

                              return InkWell(
                                onTap: () => _toggleService(service, isBlocked),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 12.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: isBlocked
                                              ? theme.colorScheme.error
                                                    .withValues(alpha: 0.1)
                                              : theme.colorScheme.primary
                                                    .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: _buildIcon(
                                          service,
                                          theme,
                                          isBlocked,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              service.name,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              isBlocked ? 'Blocked' : 'Active',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: isBlocked
                                                        ? theme
                                                              .colorScheme
                                                              .error
                                                        : theme
                                                              .colorScheme
                                                              .primary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                        value: isBlocked,
                                        onChanged: isUpdating
                                            ? null
                                            : (_) => _toggleService(
                                                service,
                                                isBlocked,
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
