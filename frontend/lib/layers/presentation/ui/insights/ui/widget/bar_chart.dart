import 'dart:math';

import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../assets/colors/Colors.dart';
import '../../../profile/ui/widget/user_image.dart';
import 'graph_filter.dart';

class GetBarChart extends StatelessWidget {
  final Color color;

  final String title;

  const GetBarChart({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // var numberOfItems = context.isWide ? 12 : 3;
        var numberOfItems = (constraints.maxWidth) ~/ 175;
        numberOfItems = numberOfItems < 3 ? 3 : numberOfItems;
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
                  padding: const EdgeInsets.only(bottom: 70.0),
                  child: Row(
                    children: [
                      Expanded(
                          child:
                          Text(title, style: context.titleTheme.titleMedium)
                      ),

                      Visibility(
                          visible: context.isWide,
                          child: GraphFilter())
                    ],
                  ),


            ),
            SizedBox(
              height: 240,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final barsSpace =
                      constraints.maxWidth * 0.3 / numberOfItems;
                  final barsWidth =
                      constraints.maxWidth * 0.7 / numberOfItems;
                  return BarChart(
                    swapAnimationDuration:
                    const Duration(milliseconds: 150),
                    // Optional
                    swapAnimationCurve: Curves.linear,
                    // Optional

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
                        barGroups:
                        getData(barsWidth, barsSpace, numberOfItems),
                        minY: 0,
                        maxY: 100),
                  );
                },
              ),
            ),
            ],
          ),
        ));
      },
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xFF344053),
      fontSize: 14,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
    );

    const names = [
      'Olivia Rhye',
      'Ana Wright',
      'Alisa Hester',
      'Orlando Diggs'
    ];

    String text = names[Random().nextInt(4)];

    return Row(
      children: [
         UserImage.small(
          [UserImageDto(id: 0, name: '', imageUrl: 'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80')]),
        const SizedBox(
          width: 10,
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: style,
        )
      ],
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.w400, fontSize: 12);
    String text;
    switch (value.toInt()) {
      case 20:
        text = 'Very Poor';
        break;
      case 40:
        text = 'Poor';
        break;
      case 60:
        text = 'Average';
        break;
      case 80:
        text = 'Good';
        break;
      case 100:
        text = 'Excellent';
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

  List<BarChartGroupData> getData(double barsWidth, double barsSpace,
      int numberOfItems) {
    List<BarChartGroupData> list = [];

    for (int i = 0; i < numberOfItems; i++) {
      list.add(BarChartGroupData(
        x: i,
        barsSpace: barsSpace,
        barRods: [
          BarChartRodData(
              toY: Random().nextInt(100).toDouble(),
              borderRadius: BorderRadius.zero,
              width: barsWidth,
              color: color),
        ],
      ));
    }

    return list;
  }
}
