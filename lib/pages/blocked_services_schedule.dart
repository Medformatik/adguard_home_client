import 'package:adguard_home_client/generated_api/export.dart';
import 'package:flutter/material.dart';

class BlockedServicesSchedulePage extends StatefulWidget {
  const BlockedServicesSchedulePage({super.key, required this.schedule});

  final Schedule schedule;

  @override
  State<BlockedServicesSchedulePage> createState() =>
      _BlockedServicesSchedulePageState();
}

class _BlockedServicesSchedulePageState
    extends State<BlockedServicesSchedulePage> {
  late final TextEditingController _timeZone;
  late final List<_DaySetting> _days;

  static const _millisecondsPerMinute = Duration.millisecondsPerMinute;

  @override
  void initState() {
    super.initState();
    _timeZone = TextEditingController(
      text: widget.schedule.timeZone?.isNotEmpty == true
          ? widget.schedule.timeZone
          : 'Local',
    );
    _days = [
      _DaySetting('Sunday', widget.schedule.sun),
      _DaySetting('Monday', widget.schedule.mon),
      _DaySetting('Tuesday', widget.schedule.tue),
      _DaySetting('Wednesday', widget.schedule.wed),
      _DaySetting('Thursday', widget.schedule.thu),
      _DaySetting('Friday', widget.schedule.fri),
      _DaySetting('Saturday', widget.schedule.sat),
    ];
  }

  @override
  void dispose() {
    _timeZone.dispose();
    super.dispose();
  }

  String _formatMinutes(int minutes) {
    if (minutes == 24 * 60) return '24:00';
    final hour = minutes ~/ 60;
    final minute = minutes.remainder(60);
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickTime(_DaySetting day, {required bool start}) async {
    final current = start ? day.startMinutes : day.endMinutes;
    final normalized = current == 24 * 60 ? 23 * 60 + 59 : current;
    final value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: normalized ~/ 60,
        minute: normalized.remainder(60),
      ),
    );
    if (value == null) return;
    final minutes = value.hour * 60 + value.minute;
    if (start && minutes >= day.endMinutes ||
        !start && minutes <= day.startMinutes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time')),
        );
      }
      return;
    }
    setState(() {
      if (start) {
        day.startMinutes = minutes;
      } else {
        day.endMinutes = minutes;
      }
    });
  }

  DayRange? _range(_DaySetting day) => day.enabled
      ? DayRange(
          start: day.startMinutes * _millisecondsPerMinute,
          end: day.endMinutes * _millisecondsPerMinute,
        )
      : null;

  void _save() {
    final timeZone = _timeZone.text.trim();
    Navigator.pop(
      context,
      Schedule(
        timeZone: timeZone.isEmpty ? 'Local' : timeZone,
        sun: _range(_days[0]),
        mon: _range(_days[1]),
        tue: _range(_days[2]),
        wed: _range(_days[3]),
        thu: _range(_days[4]),
        fri: _range(_days[5]),
        sat: _range(_days[6]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service schedule'),
        actions: [
          IconButton.filledTonal(
            tooltip: 'Save schedule',
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card.filled(
            child: const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Allowed periods'),
              subtitle: Text(
                'Selected services are allowed during these periods. Outside them, service blocking is active.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _timeZone,
            decoration: const InputDecoration(
              labelText: 'IANA time zone',
              helperText: 'Use Local for the AdGuard Home server time zone',
              prefixIcon: Icon(Icons.public),
            ),
          ),
          const SizedBox(height: 16),
          Card.filled(
            child: Column(
              children: [
                for (final day in _days)
                  Column(
                    children: [
                      SwitchListTile(
                        title: Text(day.name),
                        subtitle: day.enabled
                            ? Text(
                                '${_formatMinutes(day.startMinutes)}–${_formatMinutes(day.endMinutes)}',
                              )
                            : const Text('Blocking active all day'),
                        value: day.enabled,
                        onChanged: (value) =>
                            setState(() => day.enabled = value),
                      ),
                      if (day.enabled)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _pickTime(day, start: true),
                                  icon: const Icon(Icons.schedule),
                                  label: Text(
                                    'Start ${_formatMinutes(day.startMinutes)}',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _pickTime(day, start: false),
                                  icon: const Icon(Icons.schedule),
                                  label: Text(
                                    'End ${_formatMinutes(day.endMinutes)}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySetting {
  _DaySetting(this.name, DayRange? range)
    : enabled = range != null,
      startMinutes =
          ((range?.start ?? 9 * Duration.millisecondsPerHour) /
                  Duration.millisecondsPerMinute)
              .round(),
      endMinutes =
          ((range?.end ?? 17 * Duration.millisecondsPerHour) /
                  Duration.millisecondsPerMinute)
              .round();

  final String name;
  bool enabled;
  int startMinutes;
  int endMinutes;
}
