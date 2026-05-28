import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../assets/colors/Colors.dart';
import 'graph_filter.dart';

class LineChartWidget extends StatelessWidget {
  const LineChartWidget();

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
                padding: const EdgeInsets.only(bottom: 20.0),
                child:
                Text('Insights', style: context.titleTheme.headlineSmall),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Attendance ',
                          style: context.titleTheme.titleMedium),
                    ),

                    Visibility(
                        visible: context.isWide,
                        child: GraphFilter())
                  ],
                ),
              ),
              SizedBox(
                height: 240,
                child: LineChart(
                  data,
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.linear,
                ),
              ),
            ],
          ),
        ));
  }

  LineChartData get data =>
      LineChartData(
        lineTouchData: lineTouchData,
        gridData: gridData,
        titlesData: titlesData,
        borderData: borderData,
        lineBarsData: lineBarsData,
        minX: 0,
        maxX: 13,
        maxY: 110,
        minY: 0,
      );

  LineTouchData get lineTouchData =>
      const LineTouchData(
        enabled: false,
      );

  FlTitlesData get titlesData =>
      FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  List<LineChartBarData> get lineBarsData =>
      [
        lineChartBarData,
      ];

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.w400, fontSize: 12);
    String text;
    switch (value.toInt()) {
      case 20:
        text = '20';
        break;
      case 40:
        text = '40';
        break;
      case 60:
        text = '60';
        break;
      case 80:
        text = '80';
        break;
      case 100:
        text = '100';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  SideTitles leftTitles() =>
      SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 20,
        reservedSize: 40,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
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

  SideTitles get bottomTitles =>
      SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  FlLine gridLine(double value) {
    return const FlLine(
      color: ColorConstants.kSecondaryColor,
      strokeWidth: 0.3,
      dashArray: [1, 0],
    );
  }

  FlGridData get gridData =>
      FlGridData(
        getDrawingHorizontalLine: gridLine,
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: false,
        horizontalInterval: 20,
      );

  FlBorderData get borderData =>
      FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Colors.transparent),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData get lineChartBarData =>
      LineChartBarData(
        isCurved: true,
        curveSmoothness: 0,
        color: ColorConstants.kPrimaryColor.withOpacity(0.5),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(0, 12),
          FlSpot(1, 20),
          FlSpot(2, 60),
          FlSpot(3, 80),
          FlSpot(4, 30),
          FlSpot(5, 45),
          FlSpot(6, 50),
          FlSpot(7, 28),
          FlSpot(8, 17),
          FlSpot(9, 30),
          FlSpot(9.4, 66),
          FlSpot(10, 78),
          FlSpot(11, 90),
          FlSpot(12, 72),
        ],
      );
}