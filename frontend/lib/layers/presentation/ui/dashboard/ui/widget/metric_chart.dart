import 'dart:math';

import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/layers/presentation/ui/dashboard/ui/widget/empty_state_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../../assets/colors/Colors.dart';
import '../../../../../../core/ui/images/image.dart';

class MetricGraph extends StatelessWidget {
  final String title;
  final List<double> values;
  final int mainValue;

  const MetricGraph(
      {super.key,
      required this.title,
      required this.values,
      required this.mainValue});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const EmptyStateWidget();
    }

    var statusColor = values.first < values.last
        ? ColorConstants.kStateSuccess
        : ColorConstants.kStateError;

    return Container(
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: context.titleTheme.titleSmall,
                      ),
                    ),
                    IconButton(
                        onPressed: () => {},
                        icon: imageSVGAsset('three_dots') as Widget)
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$mainValue',
                            style: context.titleTheme.titleLarge,
                          ),
                          const Spacer(),
                          // Row(
                          //   children: [
                          //     if (values.first < values.last)
                          //       imageSVGAsset('arrow_up') as Widget
                          //     else
                          //       imageSVGAsset('arrow_down') as Widget,
                          //     Text(
                          //       '${((values.last - values.first).abs() / values.last * 100).toInt()}%',
                          //       textAlign: TextAlign.center,
                          //       style: context.textTheme.labelMedium
                          //           ?.copyWith(color: statusColor),
                          //     ),
                          //     const SizedBox(
                          //       width: 8,
                          //     ),
                          //     Text('vs last month',
                          //         style: context.textTheme.labelMedium)
                          //   ],
                          // )
                        ],
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 80,
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                color: statusColor,
                                barWidth: 1,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: statusColor.withOpacity(0.05),
                                ),
                                spots: [
                                  for (final (index, item) in values.indexed)
                                    FlSpot(index.toDouble(), item.toDouble()),
                                ],
                              ),
                            ],
                            titlesData: const FlTitlesData(show: false),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            minX: 0,
                            maxX: values.length.toDouble() - 1,
                            maxY: values.reduce(max).toDouble(),
                            minY: 0,
                          ),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.linear,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
