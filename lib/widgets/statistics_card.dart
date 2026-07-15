import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final NumberFormat _intFormat = NumberFormat.decimalPattern();
final DateFormat _tooltipDateFormat = DateFormat('y-MM-dd');

String formatNumber(num value) {
  return _intFormat.format(value);
}

class StatisticsCard extends StatelessWidget {
  final String title;
  final Color textColor;
  final IconData? icon;
  final num primary;
  final String? primaryUnit;
  final num? secondary;
  final String? secondaryPrefix;
  final String? secondarySuffix;
  final List<num>? graph;

  const StatisticsCard({
    super.key,
    required this.primary,
    required this.title,
    required this.textColor,
    this.icon,
    this.primaryUnit,
    this.secondary,
    this.secondaryPrefix,
    this.secondarySuffix,
    this.graph,
  });

  String _format(num value) => formatNumber(value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasGraph = graph != null && graph!.any((v) => v != 0);

    final secondaryText = secondary == null
        ? null
        : '${secondaryPrefix != null ? '${secondaryPrefix!} ' : ''}'
              '${_format(secondary!)}'
              '${secondarySuffix != null ? ' ${secondarySuffix!}' : ''}';

    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) Icon(icon, color: textColor, size: 24),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: primary.toDouble()),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        final formattedPrimary =
                            _format(value.toInt()) +
                            (primaryUnit != null ? ' ${primaryUnit!}' : '');
                        return Text(
                          formattedPrimary,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    if (secondaryText != null)
                      Text(
                        secondaryText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (hasGraph)
              Padding(
                padding: const EdgeInsets.fromLTRB(4.0, 24.0, 4.0, 4.0),
                child: SizedBox(
                  height: 140,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipColor: (LineBarSpot s) =>
                              theme.colorScheme.inverseSurface,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map<LineTooltipItem>((
                              touchedSpot,
                            ) {
                              final lastIndex = graph!.length - 1;
                              final date = DateTime.now().subtract(
                                Duration(
                                  days: lastIndex - touchedSpot.x.toInt(),
                                ),
                              );
                              return LineTooltipItem(
                                '${_tooltipDateFormat.format(date)}\n${_format(touchedSpot.y.toInt())}',
                                TextStyle(
                                  color: theme.colorScheme.onInverseSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (int i = 0; i < graph!.length; i++)
                              FlSpot(i.toDouble(), graph![i].toDouble()),
                          ],
                          isCurved: true,
                          isStrokeCapRound: true,
                          gradient: LinearGradient(
                            colors: [
                              textColor,
                              textColor.withValues(alpha: 0.6),
                            ],
                          ),
                          barWidth: 3.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                textColor.withValues(alpha: 0.25),
                                textColor.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
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
