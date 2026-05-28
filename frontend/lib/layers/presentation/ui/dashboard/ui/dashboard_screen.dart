import 'package:cinteraction_vc/layers/presentation/cubit/dashboard/dashboard_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/ui/dashboard/ui/widget/metric_chart.dart';
import 'package:cinteraction_vc/layers/presentation/ui/dashboard/ui/widget/new_groups_widget.dart';
import 'package:cinteraction_vc/layers/presentation/ui/dashboard/ui/widget/new_users_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../assets/colors/Colors.dart';
import '../../insights/ui/widget/bar_chart.dart';
import '../../insights/ui/widget/pie_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardCubit, DashboardState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state.loading == true) {
            return const Scaffold(
              backgroundColor: ColorConstants.kGrey100,
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Scaffold(
              backgroundColor: ColorConstants.kGrey100,
              body: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: ListView(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      LayoutBuilder(builder: (context, constraints) {
                        var minWidth = 400;
                        var space = 20.0;
                        var containerWidth =
                            constraints.maxWidth * 1 / 4 - space * 3 / 4;
                        if (constraints.maxWidth <= minWidth * 4) {
                          containerWidth =
                              constraints.maxWidth * 1 / 3 - space * 2 / 3;
                        }
                        if (constraints.maxWidth <= minWidth * 3) {
                          containerWidth =
                              constraints.maxWidth * 1 / 2 - space / 2;
                        }
                        if (constraints.maxWidth <= minWidth * 2) {
                          containerWidth = constraints.maxWidth;
                        }

                        return Wrap(
                          spacing: space,
                          runSpacing: space,
                          children: [
                            SizedBox(
                              width: containerWidth,
                              child: MetricGraph(
                                  title: 'Meetings attended',
                                  values: state.meetingAttended,
                                  mainValue: state.meetingAttendedSum ?? 0),
                            ),
                            SizedBox(
                              width: containerWidth,
                              child: MetricGraph(
                                  title: 'Average users per meeting',
                                  values: state.usersPerMeeting,
                                  mainValue: state.avgUsersPerMeeting ?? 0),
                            ),
                            SizedBox(
                              width: containerWidth,
                              child: MetricGraph(
                                  title: 'Session duration',
                                  values: state.durationsPerSession,
                                  mainValue: state.avgDurationPerSession ?? 0),
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
                        var containerWidth =
                            constraints.maxWidth * 1 / 2 - space / 2;
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
                                  NameValueClass(
                                      name: 'Realized meetings',
                                      value: state.realizedMeetings ?? 0),
                                  NameValueClass(
                                      name: 'Missed',
                                      value: state.missedMeetings ?? 0)
                                ],
                                title: 'My realized meetings',
                                colors: const [
                                  ColorConstants.kStateSuccess,
                                  ColorConstants.kGrey100
                                ],
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
                        var containerWidth =
                            constraints.maxWidth * 1 / 2 - space / 2;
                        if (constraints.maxWidth <= minWidth * 2) {
                          containerWidth = constraints.maxWidth;
                        }

                        return Wrap(
                          spacing: space,
                          runSpacing: space,
                          children: [
                            Container(
                              height: 350,
                              width: containerWidth,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const NewUsersWidget(),
                            ),
                            Container(
                              height: 350,
                              width: containerWidth,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const NewGroupsWidget(),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(
                        height: 20,
                      ),
                      const GetBarChart(
                        title: 'Total Engagement',
                        color: ColorConstants.kStateInfo,
                      )
                    ],
                  )));
        });
  }
}
