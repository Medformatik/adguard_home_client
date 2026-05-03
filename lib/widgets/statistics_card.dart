import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final NumberFormat _intFormat = NumberFormat.decimalPattern();
final DateFormat _tooltipDateFormat = DateFormat('y-MM-dd');

String formatNumber(num value) {
  if (value is int) return _intFormat.format(value);
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
    this.textColor = Colors.black,
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
    final hasGraph = graph != null && graph!.any((v) => v != 0);
    final primaryText = _format(primary) + (primaryUnit != null ? ' ${primaryUnit!}' : '');
    final secondaryText = secondary == null
        ? null
        : '${secondaryPrefix != null ? '${secondaryPrefix!} ' : ''}'
            '${_format(secondary!)}'
            '${secondarySuffix != null ? ' ${secondarySuffix!}' : ''}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) Icon(icon, color: textColor),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textColor),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      primaryText,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: textColor, fontSize: 20.0),
                    ),
                    if (secondaryText != null)
                      Text(
                        secondaryText,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: textColor),
                      ),
                  ],
                ),
              ],
            ),
            if (hasGraph)
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 8.0),
                child: SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipColor: (LineBarSpot s) => textColor.withValues(alpha: 0.8),
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map<LineTooltipItem>((touchedSpot) {
                              final lastIndex = graph!.length - 1;
                              final date = DateTime.now().subtract(Duration(days: lastIndex - touchedSpot.x.toInt()));
                              return LineTooltipItem(
                                '${_tooltipDateFormat.format(date)}: ${_format(touchedSpot.y.toInt())}',
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (int i = 0; i < graph!.length; i++) FlSpot(i.toDouble(), graph![i].toDouble()),
                          ],
                          isCurved: true,
                          isStrokeCapRound: true,
                          color: textColor,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: textColor.withValues(alpha: 0.3),
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
