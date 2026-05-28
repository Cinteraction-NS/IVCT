import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/layers/presentation/ui/dashboard/ui/widget/empty_state_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../assets/colors/Colors.dart';
import 'graph_filter.dart';

class PieChartStats extends StatelessWidget {
  final List<NameValueClass> values;
  final String title;
  final List<Color>? colors;

  const PieChartStats(
      {super.key,
      required this.values,
      required this.title,
      this.colors = const [
        ColorConstants.kStateInfo,
        ColorConstants.kStateError,
        ColorConstants.kStateSuccess,
        ColorConstants.kStateWarning,
        ColorConstants.kEngProgress30,
        ColorConstants.kEngProgress65,
      ]});

  @override
  Widget build(BuildContext context) {
    print('pie chart $values');

    var sum = 0;
    values.forEach((element) {
      sum += element.value;
    });

    if (sum <= 0) {
      return const Center(
        child: EmptyStateWidget(),
      );
    }

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
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 48.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: context.titleTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Visibility(visible: context.isWide, child: GraphFilter()),
                    ],
                  ),
                ),
              ),
              if (context.isWide)
                IntrinsicHeight(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                            child: SizedBox(
                          height: 240,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return PieChart(
                                PieChartData(sections: [
                                  for (final (index, item) in values.indexed)
                                    PieChartSectionData(
                                        color: colors?[index],
                                        title: item.name,
                                        value: item.value.toDouble(),
                                        showTitle: false,
                                        radius: constraints.maxHeight / 5)
                                ]
                                    // read about it in the PieChartData section
                                    ),
                                swapAnimationDuration: const Duration(
                                    milliseconds: 150), // Optional
                                swapAnimationCurve: Curves.linear, // Optional
                              );
                            },
                          ),
                        )),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final (index, item) in values.indexed)
                                Container(
                                  margin: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 14,
                                        height: 14,
                                        decoration: ShapeDecoration(
                                          color: colors?[index],
                                          shape: const OvalBorder(),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${((item.value / sum) * 100).toInt()}%(${item.value}) ${item.name}',
                                          style: context.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: ColorConstants.kGray2),
                                          overflow: TextOverflow.clip,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                            ],
                          ),
                        ),
                      ]),
                )
              else
                IntrinsicHeight(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (final (index, item) in values.indexed)
                              Container(
                                margin: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: ShapeDecoration(
                                        color: colors?[index],
                                        shape: const OvalBorder(),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 30,
                                    ),
                                    Text(
                                      '${sum / item.value * 100}%(${item.value}) ${item.name}',
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                              color: ColorConstants.kGray2),
                                    )
                                  ],
                                ),
                              )
                          ],
                        ),
                        Expanded(
                            child: SizedBox(
                          height: 180.0,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return PieChart(
                                PieChartData(sections: [
                                  for (final (index, item) in values.indexed)
                                    PieChartSectionData(
                                        color: colors?[index],
                                        title: item.name,
                                        value: item.value.toDouble(),
                                        showTitle: false,
                                        radius: constraints.maxHeight / 5)
                                ]
                                    // read about it in the PieChartData section
                                    ),
                                swapAnimationDuration: const Duration(
                                    milliseconds: 150), // Optional
                                swapAnimationCurve: Curves.linear, // Optional
                              );
                            },
                          ),
                        )),
                      ]),
                ),
            ],
          )),
    );
  }
}

class NameValueClass {
  const NameValueClass({required this.name, required this.value});

  final String name;
  final int value;
}
