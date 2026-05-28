import 'dart:math';

import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/core/ui/widget/loading_overlay.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/home/home_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/ui/home/ui/widgets/home_item.dart';
import 'package:cinteraction_vc/layers/presentation/ui/home/ui/widgets/join_popup.dart';
import 'package:cinteraction_vc/layers/presentation/ui/home/ui/widgets/next_meeting_widget.dart';
import 'package:cinteraction_vc/layers/presentation/ui/home/ui/widgets/schedule_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../assets/colors/Colors.dart';
import '../../../../../core/ui/images/image.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> displayJoinRoomPopup(BuildContext context) async {
      return showDialog(
        context: context,
        builder: (context) {
          return const JoinPopup();
        },
      );
    }

    Future<void> displayAddScheduleMeetingPopup(BuildContext ctx) async {
      return showDialog(
        context: ctx,
        builder: (context) {
          return BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              return SchedulePopup(
                context: ctx,
                state: state,
              );
            },
          );
        },
      );
    }

    Widget startMeetingWidget() {
      return HomeTabItem.getHomeTabItem(
        context: context,
        image: const Image(
          image: ImageAsset('stand.png'),
          fit: BoxFit.fill,
        ),
        onClickAction: () {
          context.pushNamed('meeting',
              pathParameters: {
                'roomId': Random().nextInt(999999).toString(),
              },
              extra: context.getCurrentUser?.name);
        },
        label: 'Start Meeting',
        textStyle: context.textTheme.labelMedium,
      );
    }

    Widget addUserWidget() {
      return SizedBox(
        height: (context.isWide ? 124 : 52) + 40,
        width: 50,
      );

      return HomeTabItem.getHomeTabItem(
          context: context,
          image: const Image(
            image: ImageAsset('user-square.png'),
          ),
          bgColor: ColorConstants.kStateWarning.withAlpha(255),
          onClickAction: null,
          label: 'Add User',
          textStyle: context.textTheme.labelMedium);
    }

    Widget scheduleMeetingWidget() {
      return HomeTabItem.getHomeTabItem(
          context: context,
          image: const Image(
            image: ImageAsset('calendar-date.png'),
          ),
          bgColor: ColorConstants.kStateInfo,
          onClickAction: () async {
            displayAddScheduleMeetingPopup(context);
          },
          label: 'Schedule',
          textStyle: context.textTheme.labelMedium);
    }

    Widget joinMeetingWidget() {
      return HomeTabItem.getHomeTabItem(
          context: context,
          image: const Image(
            image: ImageAsset('add_user.png'),
          ),
          bgColor: ColorConstants.kStateSuccess,
          onClickAction: () => {
                // AppRoute.meeting.push(context)
                displayJoinRoomPopup(context)
              },
          label: 'Join',
          textStyle: context.textTheme.labelMedium);
    }

    return BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (context.isWide) {
            return LoadingOverlay(
              loading: state.loading,
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'WELCOME TO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    'Virtual Classroom of the Future',
                    textAlign: TextAlign.center,
                    style: context.titleTheme.titleLarge,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                startMeetingWidget(),
                                const SizedBox(
                                  height: 30,
                                ),
                                scheduleMeetingWidget()
                              ],
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Column(
                              children: [
                                joinMeetingWidget(),
                                const SizedBox(
                                  height: 30,
                                ),
                                addUserWidget()
                              ],
                            )
                          ],
                        ),
                        Visibility(
                          visible: state.nextMeeting != null,
                          child: const Spacer(),
                        ),
                        Visibility(
                          visible: state.nextMeeting != null,
                          child: state.nextMeeting == null
                              ? Container()
                              : NextMeetingWidget(
                                  meeting: state.nextMeeting!,
                                  banner: false,
                                ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              )),
            );
          } else {
            return LoadingOverlay(
              loading: state.loading,
              child: Container(
                margin: const EdgeInsets.only(right: 20, left: 20),
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    imageSVGAsset('original_long_logo') as Widget,
                    const SizedBox(height: 50),
                    Text(
                      'WELCOME TO',
                      textAlign: TextAlign.center,
                      style: context.titleTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.normal),
                    ),
                    Text(
                      'Virtual Classroom of the Future',
                      textAlign: TextAlign.center,
                      style: context.titleTheme.titleMedium,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: startMeetingWidget()),
                          Expanded(flex: 1, child: joinMeetingWidget()),
                          Expanded(flex: 1, child: scheduleMeetingWidget()),
                          Expanded(flex: 1, child: addUserWidget())
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 30,
                    ),
                    Visibility(
                        visible: state.nextMeeting != null,
                        child: Column(
                          children: [
                            Text(
                              'Upcoming Meetings',
                              textAlign: TextAlign.center,
                              style: context.titleTheme.titleSmall,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            state.nextMeeting == null
                                ? Container()
                                : NextMeetingWidget(
                                    meeting: state.nextMeeting!,
                                    banner: false,
                                  )

                            // Container(
                            //     margin: const EdgeInsets.only(right: 20, left: 20),
                            //     child:  NextMeetingWidget(meeting: state.nextMeeting!)),
                          ],
                        )),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }
        });
  }
}
