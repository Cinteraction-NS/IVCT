import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/layers/presentation/ui/insights/ui/widget/audio_bar_chart.dart';
import 'package:cinteraction_vc/layers/presentation/ui/insights/ui/widget/bar_chart.dart';
import 'package:cinteraction_vc/layers/presentation/ui/insights/ui/widget/circular_progress.dart';
import 'package:cinteraction_vc/layers/presentation/ui/insights/ui/widget/line_chart.dart';
import 'package:cinteraction_vc/layers/presentation/ui/insights/ui/widget/pie_chart.dart';
import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.kGrey100,
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: ListView(
          children: [
            const SizedBox(
              height: 20,
            ),
            const LineChartWidget(),
            const SizedBox(
              height: 20,
            ),
            // if (context.isWide)

            LayoutBuilder(builder: (context, constraints) {
              var minWidth = 400;
              var space = 20.0;
              var containerWidth = constraints.maxWidth * 1 / 2 - space / 2;
              if (constraints.maxWidth <= minWidth * 2) {
                containerWidth = constraints.maxWidth;
              }

              return Wrap(
                spacing: space,
                runSpacing: space,
                children: [
                  SizedBox(
                    width: containerWidth,
                    child: PieChartStats(
                      values: [
                        NameValueClass(name: 'Chat Messages', value: 13),
                        NameValueClass(name: 'Raised Hands', value: 40),
                        NameValueClass(name: 'Emoticons', value: 47)
                      ],
                      title: 'Participation Levels',
                    ),
                  ),
                  SizedBox(
                    width: containerWidth,
                    child: PieChartStats(values: [
                      NameValueClass(name: '- 0 mins', value: 30),
                      NameValueClass(name: ' - 5 mins', value: 40),
                      NameValueClass(name: '- 10 mins', value: 20),
                      NameValueClass(name: '- 15+ mins', value: 10)
                    ], title: 'Inactivity'),
                  ),
                ],
              );
            }),

            const SizedBox(
              height: 20,
            ),
            const GetBarChart(
              title: 'Attention/Focus',
              color: ColorConstants.kStateInfo,
            ),
            const SizedBox(
              height: 20,
            ),

            LayoutBuilder(builder: (context, constraints) {
              var minWidth = 400;
              var space = 20.0;
              var containerWidth = constraints.maxWidth * 1 / 2 - space / 2;
              if (constraints.maxWidth <= minWidth * 2) {
                containerWidth = constraints.maxWidth;
              }

              return Wrap(
                spacing: space,
                runSpacing: space,
                children: [
                  SizedBox(
                    width: containerWidth,
                    child: const GetAudiBarChart(
                      title: 'Audio Analysis',
                    ),
                  ),
                  SizedBox(
                    width: containerWidth,
                    child: const CircularProgress(
                      title: 'Content Interaction',
                      centerTitle: 'Switching',
                      centerSubtitle: '54 Users',
                      bigProgressBar:
                          NameValueClass(name: 'Closing App', value: 75),
                      smallProgressBar:
                          NameValueClass(name: 'Switching tabs', value: 90),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(
              height: 20,
            ),

            LayoutBuilder(builder: (context, constraints) {
              var minWidth = 400;
              var space = 20.0;
              var containerWidth = constraints.maxWidth * 1 / 2 - space / 2;
              if (constraints.maxWidth <= minWidth * 2) {
                containerWidth = constraints.maxWidth;
              }

              return Wrap(
                spacing: space,
                runSpacing: space,
                children: [
                  SizedBox(
                    width: containerWidth,
                    child: const CircularProgress(
                      title: 'Technical Issue',
                      centerTitle: 'Technical issues',
                      centerSubtitle: '24 Users',
                      bigProgressBar: NameValueClass(
                          name: 'Poor internet connection', value: 75),
                      smallProgressBar: NameValueClass(
                          name: 'Audio/Video problems', value: 50),
                    ),
                  ),
                  SizedBox(
                    width: containerWidth,
                    child: const PieChartStats(values: [
                      NameValueClass(name: 'Discontent', value: 13),
                      NameValueClass(name: 'Neutral', value: 40),
                      NameValueClass(name: 'Content', value: 47)
                    ], title: 'Emotional recognition'),
                  ),
                ],
              );
            }),

            const SizedBox(
              height: 20,
            ),
            const GetBarChart(
              title: 'User Feedback',
              color: ColorConstants.kStateSuccess,
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
