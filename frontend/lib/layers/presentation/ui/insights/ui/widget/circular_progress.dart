import 'dart:math';

import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/layers/presentation/ui/insights/ui/widget/pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../../../assets/colors/Colors.dart';
import 'graph_filter.dart';

class CircularProgress extends StatelessWidget {
  final String title;

  final String centerTitle;
  final String centerSubtitle;

  final NameValueClass bigProgressBar;
  final Color? bigProgressBarColor;
  final NameValueClass smallProgressBar;
  final Color? smallProgressBarColor;

  const CircularProgress(
      {super.key,
      required this.title,
      required this.centerTitle,
      required this.centerSubtitle,
      required this.bigProgressBar,
      this.bigProgressBarColor = ColorConstants.kStateInfo,
      required this.smallProgressBar,
      this.smallProgressBarColor = ColorConstants.kStateSuccess});

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
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: context.titleTheme.titleMedium,
                      ),
                    ),
                    Visibility(visible: context.isWide, child: GraphFilter())
                  ],
                ),
              ),
              if (context.isWide)
                IntrinsicHeight(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                            child: SizedBox(
                          height: 240.0,
                          child: LayoutBuilder(
                            builder: (context, constraint) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularPercentIndicator(
                                    radius: [
                                          constraint.maxWidth,
                                          constraint.maxHeight
                                        ].reduce(min) /
                                        2,
                                    lineWidth: 16.0,
                                    animation: true,
                                    animationDuration: 1000,
                                    percent: bigProgressBar.value / 100,
                                    circularStrokeCap: CircularStrokeCap.round,
                                    progressColor: bigProgressBarColor,
                                    backgroundColor: ColorConstants.kWhite50,
                                  ),
                                  CircularPercentIndicator(
                                    radius: [
                                          constraint.maxWidth,
                                          constraint.maxHeight
                                        ].reduce(min) /
                                        2.5,
                                    lineWidth: 16.0,
                                    animation: true,
                                    animationDuration: 500,
                                    percent: smallProgressBar.value / 100,
                                    center: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          centerTitle,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Color(0xFF475466),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        // ---
                                        Text(
                                          centerSubtitle,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Color(0xFF403736),
                                            fontSize: 24,
                                            fontFamily: 'Nunito',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      ],
                                    ),
                                    circularStrokeCap: CircularStrokeCap.round,
                                    progressColor: smallProgressBarColor,
                                    backgroundColor: ColorConstants.kWhite50,
                                  ),
                                ],
                              );
                            },
                          ),
                        )),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: ShapeDecoration(
                                        color: bigProgressBarColor,
                                        shape: const OvalBorder(),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${bigProgressBar.value}% ${bigProgressBar.name}',
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                                color: ColorConstants.kGray2),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: ShapeDecoration(
                                        color: smallProgressBarColor,
                                        shape: const OvalBorder(),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${smallProgressBar.value}% ${smallProgressBar.name}',
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                                color: ColorConstants.kGray2),
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
                Column(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: ShapeDecoration(
                                      color: bigProgressBarColor,
                                      shape: const OvalBorder(),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '${bigProgressBar.value}% ${bigProgressBar.name}',
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(color: ColorConstants.kGray2),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: ShapeDecoration(
                                      color: smallProgressBarColor,
                                      shape: const OvalBorder(),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '${smallProgressBar.value}% ${smallProgressBar.name}',
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(color: ColorConstants.kGray2),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 240.0,
                          child: LayoutBuilder(
                            builder: (context, constraint) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularPercentIndicator(
                                    radius: [
                                          constraint.maxWidth,
                                          constraint.maxHeight
                                        ].reduce(min) /
                                        2,
                                    lineWidth: 16.0,
                                    animation: true,
                                    animationDuration: 1000,
                                    percent: bigProgressBar.value / 100,
                                    circularStrokeCap: CircularStrokeCap.round,
                                    progressColor: bigProgressBarColor,
                                    backgroundColor: ColorConstants.kWhite50,
                                  ),
                                  CircularPercentIndicator(
                                    radius: [
                                          constraint.maxWidth,
                                          constraint.maxHeight
                                        ].reduce(min) /
                                        2.5,
                                    lineWidth: 16.0,
                                    animation: true,
                                    animationDuration: 500,
                                    percent: smallProgressBar.value / 100,
                                    center: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          centerTitle,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Color(0xFF475466),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        // ---
                                        Text(
                                          centerSubtitle,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Color(0xFF403736),
                                            fontSize: 24,
                                            fontFamily: 'Nunito',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      ],
                                    ),
                                    circularStrokeCap: CircularStrokeCap.round,
                                    progressColor: smallProgressBarColor,
                                    backgroundColor: ColorConstants.kWhite50,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ]),
            ],
          )),
    );
  }
}
