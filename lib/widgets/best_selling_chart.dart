import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BestSellingChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final int maxItemsToShow;

  const BestSellingChart({
    super.key,
    required this.data,
    this.maxItemsToShow = 5,
  });

  @override
  Widget build(BuildContext context) {
    print("DEBUG_WIDGET: BestSellingChart build - Data count: ${data.length}");
    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
          child: Text(
            "No sales data available to display chart.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      );
    }

    final List<Map<String, dynamic>> chartData = data.take(maxItemsToShow).toList();
    List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    for (int i = 0; i < chartData.length; i++) {
      final product = chartData[i];
      final dynamic quantityDynamic = product['quantitySold'];
      int quantity = 0;

      if (quantityDynamic is int) {
        quantity = quantityDynamic;
      } else if (quantityDynamic is double) {
        quantity = quantityDynamic.toInt();
      } else if (quantityDynamic is String) {
        quantity = int.tryParse(quantityDynamic) ?? 0;
      }

      if (quantity.toDouble() > maxY) {
        maxY = quantity.toDouble();
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: quantity.toDouble(),
              color: Theme.of(context).primaryColor.withOpacity(0.85),
              width: 22,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    if (maxY == 0) {
      maxY = 10;
    } else {
      maxY = (maxY * 1.25).ceilToDouble();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20.0, right: 20.0, left: 8.0, bottom: 10.0),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: barGroups,
          alignment: BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final int index = value.toInt();
                  if (index >= 0 && index < chartData.length) {
                    dynamic productNameDynamic = chartData[index]['name'];
                    String name = "P.${index + 1}";
                    if (productNameDynamic is String && productNameDynamic.isNotEmpty) {
                      name = productNameDynamic;
                    } else if (productNameDynamic != null) {
                      name = productNameDynamic.toString();
                      if (name.isEmpty) name = "P.${index + 1}";
                    }
                    String displayName = name;
                    if (displayName.length > 12) {
                      displayName = '${displayName.substring(0, 10)}...';
                    }
                    return SideTitleWidget(
                      meta: meta,
                      space: 8.0,
                      child: Text(
                        displayName,
                        style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 10),
                        overflow: TextOverflow.clip,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                interval: (maxY / 5).ceilToDouble() > 0 ? (maxY / 5).ceilToDouble() : 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value == meta.max && maxY > 0) return Container();
                  if (value == 0 && maxY > 0) return Container();
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontSize: 10),
                    textAlign: TextAlign.right,
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              left: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey.shade200, strokeWidth: 0.8);
            },
            checkToShowHorizontalLine: (value) => true,
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(

              tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              tooltipMargin: 8,
              getTooltipItem: (BarChartGroupData group, int groupIndex,
                  BarChartRodData rod, int rodIndex) {
                String productName = "Unknown";
                if (group.x.toInt() >= 0 && group.x.toInt() < chartData.length) {
                  dynamic nameDyn = chartData[group.x.toInt()]['name'];
                  if (nameDyn is String && nameDyn.isNotEmpty) productName = nameDyn;
                  else if (nameDyn != null) productName = nameDyn.toString();
                }
                return BarTooltipItem(
                  '$productName\n',
                  const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                  children: <TextSpan>[
                    TextSpan(
                      text: (rod.toY).toInt().toString(),
                      style: TextStyle(
                          color: Colors.yellow.shade600,
                          fontSize: 15,
                          fontWeight: FontWeight.w900),
                    ),
                    const TextSpan(
                      text: ' sold',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                  textAlign: TextAlign.center,
                );
              },
            ),
            handleBuiltInTouches: true,
          ),
        ),
        swapAnimationDuration: const Duration(milliseconds: 250),
        swapAnimationCurve: Curves.linear,
      ),
    );
  }
}