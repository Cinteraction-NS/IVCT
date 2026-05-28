import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/dashboard/dashboard_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/ui/charts/ui/widget/chart.dart';
import 'package:cinteraction_vc/layers/presentation/ui/charts/ui/widget/user_chart_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../assets/colors/Colors.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen(
      {super.key,
      this.meetingId,
      required this.meetStart,
      required this.meetEnd});

  final int? meetingId;
  final DateTime meetStart;
  final DateTime meetEnd;

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  var duration = 0.0;

  @override
  void initState() {
    super.initState();

    // Call API when screen opens if meetingId is provided
    final meetingId = widget.meetingId;

    if (meetingId != null) {
      print('📊 ChartsScreen: Loading data for meetingId: $meetingId');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Get moduleId from current user's enabled modules
        final user = context.getCurrentUser;
        print('📊 Current user: ${user?.name}');
        print(
            '📊 User modules: ${user?.modules.map((m) => '${m.name}(${m.id})').join(', ')}');

        final engagementModule = user?.modules.firstWhere(
          (m) => m.name.toLowerCase() == 'engagement' && m.enabled == 1,
          orElse: () => user.modules.firstWhere((m) => m.enabled == 1),
        );

        if (engagementModule != null) {
          print(
              '📊 Using module: ${engagementModule.name} (id: ${engagementModule.id})');
          context.read<DashboardCubit>().getEngagementTotalAverage(
                meetingId: meetingId,
                moduleId: engagementModule.id,
              );
        } else {
          print('⚠️ No enabled module found for user');
        }
      });
    } else {
      print('⚠️ ChartsScreen: No meetingId provided');
    }

    duration = widget.meetEnd.difference(widget.meetStart).inSeconds as double;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardCubit, DashboardState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
              backgroundColor: ColorConstants.kGrey100,
              body: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: ListView(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),

                      SizedBox(
                          height: 350,
                          child: state.engagementLoading == true
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : state.engagementData == null ||
                                      state.engagementData!
                                          .buildBinnedSeriesByModule(
                                            slot: const Duration(seconds: 10),
                                            xAsTime: true,
                                            meetStart: widget.meetStart,
                                            meetEnd: widget.meetEnd,
                                          )
                                          .isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No engagement data available',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : MultiLineChart(
                                      series: state.engagementData!
                                          .buildBinnedSeriesByModule(
                                        slot: const Duration(seconds: 10),
                                        xAsTime: true,
                                        meetStart: widget.meetStart,
                                        meetEnd: widget.meetEnd,
                                      ),
                                      // Example: custom bottom titles if x is time index
                                      bottomTitleBuilder: (value, meta) {
                                        if (value % 10 != 0) {
                                          return const Text("");
                                        }
                                        final secs = value
                                            .round(); // or: (value + 1e-6).floor()
                                        final m = (secs ~/ 60)
                                            .toString()
                                            .padLeft(2, '0');
                                        final s = (secs % 60)
                                            .toString()
                                            .padLeft(2, '0');
                                        return Text('$m:$s',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall);
                                      },
                                      leftTitleBuilder: (value, meta) => Text(
                                          '${value.toInt()}%',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall),
                                    )),

                      const SizedBox(
                        height: 30,
                      ),

                      // Section Title
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Text(
                          'Individual Results',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: ColorConstants.kSecondaryColor,
                              ),
                        ),
                      ),

                      // Individual User Charts
                      LayoutBuilder(builder: (context, constraints) {
                        var minWidth = 400;
                        var space = 0.0;
                        var containerWidth =
                            constraints.maxWidth * 1 / 3 - space * 2 / 3;

                        if (constraints.maxWidth <= minWidth * 3) {
                          containerWidth =
                              constraints.maxWidth * 1 / 2 - space / 2;
                        }
                        if (constraints.maxWidth <= minWidth * 2) {
                          containerWidth = constraints.maxWidth;
                        }

                        if (state.engagementLoading == true) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state.engagementData == null ||
                            state.engagementData!.users.isEmpty) {
                          return const Center(
                            child: Text(
                              'No individual user data available',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        } else {
                          return Wrap(
                            spacing: space,
                            runSpacing: space,
                            children:
                                state.engagementData!.users.map((userData) {
                              return SizedBox(
                                width: containerWidth,
                                child: UserChartCard(
                                  userName: userData.name,
                                  duration: duration,
                                  data: state.engagementData!
                                      .buildBinnedSeriesByModule(
                                          slot: const Duration(seconds: 10),
                                          userId: userData.id,
                                          xAsTime: true,
                                          meetStart: widget.meetStart,
                                          meetEnd: widget.meetEnd),
                                ),
                              );
                            }).toList(),
                          );
                        }
                      }),

                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  )));
        });
  }
}
