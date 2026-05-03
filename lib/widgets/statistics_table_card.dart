import 'package:adguard_home_client/widgets/statistics_card.dart';
import 'package:flutter/material.dart';

class StatisticsTableCard extends StatelessWidget {
  final String title;
  final Color textColor;
  final IconData? icon;
  final String keyColumn;
  final String valueColumn;
  final Map<String, int> data;
  final int? total;

  const StatisticsTableCard({
    super.key,
    required this.title,
    this.textColor = Colors.black,
    this.icon,
    required this.keyColumn,
    required this.valueColumn,
    required this.data,
    this.total,
  });

  List<DataColumn> _getColumns(BoxConstraints constraints) {
    double columnWidth(double factor) => constraints.maxWidth * factor;

    final columns = <DataColumn>[
      DataColumn(
        label: SizedBox(
          width: total != null ? columnWidth(0.6) : columnWidth(0.8),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(keyColumn, overflow: TextOverflow.visible, softWrap: true),
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth(0.2),
          child: Padding(
            padding: total != null ? EdgeInsets.zero : const EdgeInsets.only(right: 16.0),
            child: Text(valueColumn, overflow: TextOverflow.visible, softWrap: true),
          ),
        ),
        numeric: true,
      ),
    ];
    if (total != null) {
      columns.add(
        DataColumn(
          label: SizedBox(
            width: columnWidth(0.2),
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Text('', overflow: TextOverflow.visible, softWrap: true),
            ),
          ),
          numeric: true,
        ),
      );
    }
    return columns;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) Icon(icon, color: textColor),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              height: 200,
              child: data.isEmpty
                  ? Center(
                      child: Text(
                        'No data',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          return DataTable(
                            horizontalMargin: 0,
                            columnSpacing: 0,
                            headingRowHeight: 32,
                            dataRowMinHeight: 28,
                            dataRowMaxHeight: 32,
                            headingRowColor: WidgetStateProperty.all<Color>(textColor.withValues(alpha: 0.2)),
                            columns: _getColumns(constraints),
                            rows: data.entries.map<DataRow>((row) {
                              final cells = <DataCell>[
                                DataCell(
                                  SizedBox(
                                    width: constraints.maxWidth * (total != null ? 0.6 : 0.8),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16.0),
                                      child: Text(row.key, overflow: TextOverflow.visible, softWrap: true),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: constraints.maxWidth * 0.2,
                                    child: Padding(
                                      padding: total != null ? EdgeInsets.zero : const EdgeInsets.only(right: 16.0),
                                      child: Text(
                                        formatNumber(row.value),
                                        overflow: TextOverflow.visible,
                                        softWrap: true,
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ),
                                ),
                              ];
                              if (total != null) {
                                final pct = total! > 0 ? (row.value / total! * 100).toStringAsFixed(1) : '0.0';
                                cells.add(DataCell(
                                  SizedBox(
                                    width: constraints.maxWidth * 0.2,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 16.0),
                                      child: Text(
                                        '$pct %',
                                        overflow: TextOverflow.visible,
                                        softWrap: true,
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ),
                                ));
                              }
                              return DataRow(cells: cells);
                            }).toList(),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
