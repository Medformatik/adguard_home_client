import 'package:adguard_home_client/widgets/statistics_card.dart';
import 'package:flutter/material.dart';

class StatisticsTableCard extends StatefulWidget {
  final String title;
  final Color textColor;
  final IconData? icon;
  final String keyColumn;
  final String valueColumn;
  final Map<String, num> data;
  final num? total;
  final String valueSuffix;
  final int fractionDigits;

  const StatisticsTableCard({
    super.key,
    required this.title,
    required this.textColor,
    this.icon,
    required this.keyColumn,
    required this.valueColumn,
    required this.data,
    this.total,
    this.valueSuffix = '',
    this.fractionDigits = 0,
  });

  @override
  State<StatisticsTableCard> createState() => _StatisticsTableCardState();
}

class _StatisticsTableCardState extends State<StatisticsTableCard> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.icon != null)
                  Icon(widget.icon, color: widget.textColor, size: 24),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 200,
              child: widget.data.isEmpty
                  ? Center(
                      child: Text(
                        'No data',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    )
                  : Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Column(
                          children: widget.data.entries.map((entry) {
                            final ratio =
                                (widget.total != null && widget.total! > 0
                                        ? (entry.value / widget.total!)
                                        : 0.0)
                                    .clamp(0.0, 1.0);
                            final percentage = (ratio * 100).toStringAsFixed(1);
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SelectableText(
                                          entry.key,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${widget.fractionDigits == 0 ? formatNumber(entry.value) : entry.value.toStringAsFixed(widget.fractionDigits)}${widget.valueSuffix}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: widget.textColor,
                                        ),
                                      ),
                                      if (widget.total != null) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          '$percentage%',
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.6),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: ratio,
                                      backgroundColor: widget.textColor
                                          .withValues(alpha: 0.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        widget.textColor,
                                      ),
                                      minHeight: 5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
