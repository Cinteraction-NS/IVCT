import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/ui/widget/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/ui/images/image.dart';
import '../../../../../../core/ui/widget/content_layout_web.dart';
import '../../../../../../core/ui/widget/engagement_progress.dart';
import '../../../../../domain/entities/meetings/meeting.dart';
import '../../../../cubit/meetings/meetings_cubit.dart';
import '../../../../../../core/app/injector.dart';
import '../../../charts/ui/charts_screen.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/dashboard/dashboard_cubit.dart';

class MeetingListLayout extends StatefulWidget {
  const MeetingListLayout({super.key});

  @override
  State<StatefulWidget> createState() => _MeetingListLayoutState();
}

class _MeetingListLayoutState extends State<MeetingListLayout> {
  late double extentAfter;
  final _controller = ScrollController();

  Meeting? _selectedMeeting; // inline charts selection

  @override
  void initState() {
    super.initState();
    _controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_controller.position.pixels == _controller.position.maxScrollExtent) {
      context.read<MeetingCubit>().loadMeetings();
    }
  }

  void _selectMeeting(Meeting meeting) {
    setState(() => _selectedMeeting = meeting);
  }

  void _clearSelection() {
    setState(() => _selectedMeeting = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedMeeting != null) {
      // Show Charts inline with back button
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _clearSelection,
                ),
                const SizedBox(width: 8),
                Text('Charts for meeting #${_selectedMeeting?.callId}',
                    style: context.titleTheme.titleLarge),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocProvider(
              create: (_) => getIt.get<DashboardCubit>(),
              child: ChartsScreen(
                  meetingId: _selectedMeeting?.callId,
                  meetStart: _selectedMeeting!.meetingStart,
                  meetEnd: _selectedMeeting!.meetingEnd ??
                      _selectedMeeting!.meetingStart
                          .add(Duration(minutes: 30))),
            ),
          ),
        ],
      );
    }

    void showPastMeetings() {
      context.read<MeetingCubit>().loadMeetings();
      context.read<MeetingCubit>().tabChanged();
    }

    void showScheduledMeetings() {
      context.read<MeetingCubit>().loadScheduledMeetings();
      context.read<MeetingCubit>().tabChanged();
    }

    return BlocConsumer<MeetingCubit, MeetingState>(
      listener: (context, state) {},
      builder: (context, state) {
        Widget body;
        if (context.isWide) {
          body = ContentLayoutWeb(
            child: SizedBox(
              height: double.maxFinite,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Meetings',
                              style: context.titleTheme.headlineLarge,
                            ),
                            Text('${state.meetings.length} Meetings'),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => showPastMeetings(),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Visibility(
                                        visible: state.isShowingPastMeetings,
                                        child: SizedBox(
                                          height: 52,
                                          width: 200,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                    color: ColorConstants
                                                        .kPrimaryColor
                                                        .withOpacity(0.05)),
                                              ),
                                              Container(
                                                  height: 2,
                                                  color: ColorConstants
                                                      .kPrimaryColor),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 52,
                                        width: 200,
                                        child: Center(
                                          child: Text('Past Meetings',
                                              style: context
                                                  .textTheme.displaySmall
                                                  ?.copyWith(
                                                color:
                                                    state.isShowingPastMeetings
                                                        ? ColorConstants
                                                            .kPrimaryColor
                                                        : ColorConstants.kGray2,
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                  onTap: () => showScheduledMeetings(),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Visibility(
                                        visible: !state.isShowingPastMeetings,
                                        child: SizedBox(
                                          height: 52,
                                          width: 200,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                    color: ColorConstants
                                                        .kPrimaryColor
                                                        .withOpacity(0.05)),
                                              ),
                                              Container(
                                                  height: 2,
                                                  color: ColorConstants
                                                      .kPrimaryColor),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 52,
                                        width: 200,
                                        child: Center(
                                          child: Text('Schedule Meeting',
                                              style: context
                                                  .textTheme.displaySmall
                                                  ?.copyWith(
                                                color:
                                                    !state.isShowingPastMeetings
                                                        ? ColorConstants
                                                            .kPrimaryColor
                                                        : ColorConstants.kGray2,
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        )),
                        // ElevatedButton(
                        //     onPressed: () =>
                        //     {
                        //       context.read<RolesCubit>().addRole()
                        //     },
                        //     child: const Text('Start a meeting'))
                      ],
                    ),
                  ),
                  Table(columnWidths: const {
                    0: FixedColumnWidth(100),
                    1: FixedColumnWidth(200),
                    2: FixedColumnWidth(150),
                    //   3: FixedColumnWidth(209),
                    //   4: FixedColumnWidth(209),
                  }, children: [
                    TableRow(
                        decoration:
                            const BoxDecoration(color: Color(0xFFF0F0F0)),
                        children: [
                          const TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('Meeting'),
                              )),
                          const TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('Organizer'),
                              )),

                          // Visibility(
                          //   visible: state.isShowingPastMeetings,
                          //   child: const TableCell(
                          //       verticalAlignment:
                          //           TableCellVerticalAlignment.middle,
                          //       child:
                          //           Center(child: Text('Average Engagement'))),
                          // ),

                          const TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Center(child: Text('Users'))),
                          Visibility(
                            visible: state.isShowingPastMeetings,
                            child: const TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Center(child: Text('Recorded'))),
                          ),
                          const TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('Start'),
                              )),
                          const TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('End'),
                              )),

                          const TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Center(child: Text('Actions')),
                              ),

                          // TableCell(
                          //     verticalAlignment: TableCellVerticalAlignment.middle,
                          //     child: imageSVGAsset('')!),
                        ])
                  ]),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _controller,
                      scrollDirection: Axis.vertical,
                      child: Table(
                        border: const TableBorder(
                            horizontalInside: BorderSide(
                                width: 0.5,
                                color: ColorConstants.kGray5,
                                style: BorderStyle.solid)),
                        columnWidths: const {
                          0: FixedColumnWidth(100),
                          1: FixedColumnWidth(200),
                          2: FixedColumnWidth(150),
                          //   3: FixedColumnWidth(209),
                          //   4: FixedColumnWidth(209),
                        },
                        children: [
                          for (var meeting in state.meetings)
                            TableRow(children: [
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      meeting.callId.toString(),
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),

                              ),
                              TableCell(
                                  child:  Padding(
                                  padding: const EdgeInsets.only(
                                      top: 27, bottom: 27),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // UserImage.medium(meeting.organizer.imageUrl),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(meeting.organizer,
                                                style: context
                                                    .textTheme.displaySmall)
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              // Visibility(
                              //   visible: state.isShowingPastMeetings,
                              //   child: TableCell(
                              //       verticalAlignment:
                              //           TableCellVerticalAlignment.middle,
                              //       child: InkWell(
                              //         onTap: () => _selectMeeting(meeting),
                              //         child: EngagementProgress(
                              //           engagement:
                              //               ((meeting.averageEngagement ?? 0) *
                              //                       100)
                              //                   .toInt(),
                              //           width: double.maxFinite,
                              //         ),
                              //       )),
                              // ),
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                    child: Center(
                                        child: Text(
                                            '${meeting.totalNumberOfUsers ?? 0}'))),
                              //     child: isShowingPastMeetings
                              //         ? Center(child: Text('${meeting.users.length}'))
                              //         : Center(child: MembersWidget(users: meeting.users)))
                              // ,
                              Visibility(
                                visible: state.isShowingPastMeetings,
                                child: TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Center(

                                            child: imageSVGAsset(
                                                meeting.recorded ?? false
                                                    ? 'badge_approved'
                                                    : 'badge_waiting'))),
                              ),
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child:  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                        DateFormat('dd.MM.yyyy. hh:mm a')
                                            .format(meeting.meetingStart)),
                                  ),
                                ),

                              TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Visibility(
                                          visible: meeting.meetingEnd != null,
                                          child: meeting.meetingEnd != null
                                              ? Text(DateFormat(
                                                      'dd.MM.yyyy. hh:mm a')
                                                  .format(meeting.meetingEnd!))
                                              : const Text('')),
                                    ),
                                  ),
                              
                              TableCell(
                                verticalAlignment:
                                TableCellVerticalAlignment.middle,
                                child:
                                Center(child: TextButton(onPressed: () => _selectMeeting(meeting)
                                    , child: const Text('Details'))),
                              )
                              
                            ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          body = Expanded(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 85,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: Text(
                        'Meetings',
                        style: context.titleTheme.headlineLarge,
                      ),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => showPastMeetings(),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Visibility(
                                  visible: state.isShowingPastMeetings,
                                  child: SizedBox(
                                    height: 52,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                              color: ColorConstants
                                                  .kPrimaryColor
                                                  .withOpacity(0.05)),
                                        ),
                                        Container(
                                            height: 2,
                                            color:
                                                ColorConstants.kPrimaryColor),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 52,
                                  child: Center(
                                    child: Text('Past Meetings',
                                        style: context.textTheme.labelMedium
                                            ?.copyWith(
                                          color: state.isShowingPastMeetings
                                              ? ColorConstants.kPrimaryColor
                                              : ColorConstants.kGray2,
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => showScheduledMeetings(),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Visibility(
                                  visible: !state.isShowingPastMeetings,
                                  child: SizedBox(
                                    height: 52,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                              color: ColorConstants
                                                  .kPrimaryColor
                                                  .withOpacity(0.05)),
                                        ),
                                        Container(
                                            height: 2,
                                            color:
                                                ColorConstants.kPrimaryColor),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 52,
                                  child: Center(
                                    child: Text('Schedule Meeting',
                                        style: context.textTheme.labelMedium
                                            ?.copyWith(
                                          color: !state.isShowingPastMeetings
                                              ? ColorConstants.kPrimaryColor
                                              : ColorConstants.kGray2,
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                        child: Column(
                      children: [
                        Expanded(
                            child: ListView.builder(
                                itemCount: state.meetings.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () =>
                                        _selectMeeting(state.meetings[index]),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10,
                                          bottom: 20,
                                          right: 10,
                                          left: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${index + 1}.',
                                                style: context
                                                    .textTheme.titleSmall,
                                              ),
                                              const SizedBox(
                                                width: 3,
                                              ),
                                              Expanded(
                                                child: Text(
                                                    state.meetings[index].callId
                                                        .toString(),
                                                    style: context
                                                        .textTheme.titleSmall),
                                              ),
                                              Visibility(
                                                  visible: !state
                                                      .isShowingPastMeetings,
                                                  child: Text(
                                                      '${state.meetings[index].meetingStart.day}.${state.meetings[index].meetingStart.month}.${state.meetings[index].meetingStart.year}')),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(state
                                                    .meetings[index].organizer),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Visibility(
                                                  visible: state
                                                      .isShowingPastMeetings,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                                  'Duration: ${state.meetings[index].formatMeetingDuration()}')),
                                                          const Text(
                                                              'Recorded: '),
                                                          imageSVGAsset(state
                                                                      .meetings[
                                                                          index]
                                                                      .recorded ??
                                                                  false
                                                              ? 'badge_approved'
                                                              : 'badge_waiting') as Widget
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      EngagementProgress(
                                                        engagement: (state
                                                                    .meetings[
                                                                        index]
                                                                    .averageEngagement! *
                                                                100)
                                                            .toInt(),
                                                        width: double.maxFinite,
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: !state
                                                      .isShowingPastMeetings,
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                          'Start: ${state.meetings[index].meetingStart.hour}:${state.meetings[index].meetingStart.minute}'),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                          'Start: ${state.meetings[index].meetingEnd?.hour}:${state.meetings[index].meetingEnd?.minute}'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                })),
                      ],
                    ))
                  ],
                ),
              ),
            ),
          );
        }

        return LoadingOverlay(
          loading: state.isLoading,
          child: Column(
            children: [body],
          ),
        );
      },
    );
  }
}
