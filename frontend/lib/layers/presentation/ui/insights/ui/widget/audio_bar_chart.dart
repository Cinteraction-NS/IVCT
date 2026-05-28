import 'dart:math';

import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../assets/colors/Colors.dart';
import 'graph_filter.dart';

class GetAudiBarChart extends StatelessWidget {
  final Color red = ColorConstants.kStateError;
  final Color green = ColorConstants.kStateSuccess;
  final Color blue = ColorConstants.kStateInfo;

  final String title;

  const GetAudiBarChart({super.key, required this.title});

  final numberOfItems = 12;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: Row(
                  children: [
                 Expanded(child: Text(title, style: context.titleTheme.titleMedium)),
                    Visibility(
                        visible: context.isWide,
                        child: GraphFilter()),
                  ],
                ),
              ),
              SizedBox(
                height: 240,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final barsSpace =
                        (constraints.maxWidth - 16 * numberOfItems) /
                            numberOfItems;
                    const barsWidth = 16.0;
                    return BarChart(
                      BarChartData(
                          alignment: BarChartAlignment.start,
                          barTouchData: BarTouchData(
                            enabled: false,
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: bottomTitles,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: context.isWide,
                                reservedSize: 80,
                                getTitlesWidget: leftTitles,
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            checkToShowHorizontalLine: (value) =>
                            value % 10 == 0,
                            getDrawingHorizontalLine: (value) =>
                                FlLine(
                                  color: ColorConstants.kSecondaryColor
                                      .withOpacity(0.1),
                                  strokeWidth: 1,
                                ),
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          groupsSpace: barsSpace,
                          barGroups: getData(barsWidth, barsSpace),
                          minY: 0,
                          maxY: 1),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = const Text('Jan', style: style);
        break;
      case 2:
        text = const Text('Feb', style: style);
        break;
      case 3:
        text = const Text('Mar', style: style);
        break;
      case 4:
        text = const Text('Apr', style: style);
        break;
      case 5:
        text = const Text('May', style: style);
        break;
      case 6:
        text = const Text('Jun', style: style);
        break;
      case 7:
        text = const Text('Jul', style: style);
        break;
      case 8:
        text = const Text('Aug', style: style);
        break;
      case 9:
        text = const Text('Sep', style: style);
        break;
      case 10:
        text = const Text('Oct', style: style);
        break;
      case 11:
        text = const Text('Nov', style: style);
        break;
      case 12:
        text = const Text('Dec', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.w400, fontSize: 12);
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0';
        break;
      case 0.25:
        text = 's0.25s';
        break;
      case 0.5:
        text = '0.5s';
        break;
      case 0.75:
        text = '0.75';
        break;
      case 1:
        text = '1';
        break;
      default:
        return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        text,
        style: style,
      ),
    );
  }

  List<BarChartGroupData> getData(double barsWidth, double barsSpace) {
    List<BarChartGroupData> list = [];

    for (int i = 1; i <= numberOfItems; i++) {
      var blueValue = Random().nextDouble() * (0.3 - 0) + 0;
      var greenValue = Random().nextDouble() * (0.6 - blueValue) + blueValue;
      var redValue = Random().nextDouble() * (0.75 - greenValue) + greenValue;

      list.add(
        BarChartGroupData(
          x: i,
          barsSpace: barsSpace,
          barRods: [
            BarChartRodData(
                toY: redValue,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                width: barsWidth,
                rodStackItems: [
                  BarChartRodStackItem(0, blueValue, blue),
                  BarChartRodStackItem(blueValue, greenValue, green),
                  BarChartRodStackItem(greenValue, redValue, red),
                ]),
          ],
        ),
      );
    }

    return list;
  }
}
