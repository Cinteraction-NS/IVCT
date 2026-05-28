import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/chat_view/chat_view.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/dynamic_layout/cubit/dynamic_layout_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/dynamic_layout/dynamic_layout_grid.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/participant_video_widget.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/participants_list_view/participants_list_view.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/video_widget/participant_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

import '../../../../assets/colors/Colors.dart';
import '../../../../core/ui/images/image.dart';
import '../../../../core/ui/widget/call_button_shape.dart';
import '../../../../core/ui/widget/engagement_progress.dart';
import '../../../../core/util/util.dart';
import '../../cubit/chat/chat_cubit.dart';
import '../../cubit/chat/chat_state.dart';
import '../../cubit/conference/conference_cubit.dart';
import '../../cubit/conference/conference_state.dart';

Widget getDesktopView(
    BuildContext context,
    ConferenceState state,
    List<StreamRenderer> items,
    List<StreamRenderer> screenShares,
    List<StreamRenderer> contributors,
    List<StreamRenderer> contributorsHandUp,
    GlobalKey micTargetKey,
    DynamicLayoutCubit staggeredCubit,
    ParticipantManager participantManager) {
  double chatContainedWidth = 400;
  bool showingChat = state.showingChat;

  return Stack(
    children: [
      Positioned.fill(
        child: Column(
          children: [
            //CONTENT LAYOUT
            Expanded(
              child: Row(
                children: [
                  //STREAMS LAYOUT
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            // MultiProvider(
                            //   providers: [
                            //     BlocProvider.value(value: staggeredCubit),
                            //     Provider.value(value: participantManager),
                            //   ],
                            //   child: const StaggeredAspectGrid(),
                            // ),

                            // Conditional screen share overlay
                            screenShares.isNotEmpty &&
                                    screenShares
                                            .where((element) =>
                                                int.parse(
                                                    element.publisherId!) ==
                                                state.screenShareId)
                                            .firstOrNull !=
                                        null
                                ? Row(
                                    children: [
                                      Expanded(
                                        flex: 7,
                                        child: ParticipantVideoWidget(
                                          remoteStream: screenShares
                                              .where((element) =>
                                                  int.parse(
                                                      element.publisherId!) ==
                                                  state.screenShareId)
                                              .first,
                                          height: double.maxFinite,
                                          width: double.maxFinite,
                                          showEngagement: false,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: BlocProvider<
                                            DynamicLayoutCubit>.value(
                                          value: staggeredCubit,
                                          child: const DynamicLayoutGrid(),
                                        ),
                                      ),
                                    ],
                                  )
                                : BlocProvider<DynamicLayoutCubit>.value(
                                    value: staggeredCubit,
                                    child: const DynamicLayoutGrid(),
                                  ),

                            Visibility(
                              visible: (state.avgEngagement ?? 0) > 0,
                              child: Positioned(
                                bottom: 20,
                                left: 24,
                                child: EngagementProgress(
                                  engagement: state.avgEngagement ?? 0,
                                  width: 266,
                                  height: 28,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  //CHAT VIEW
                  Visibility(
                    visible: state.showingChat,
                    child: getChatView(context, chatContainedWidth),
                    // ),
                  ),
                  //PARTICIPANTS LIST VIEW
                  Visibility(
                      visible: state.showingParticipants,
                      child: getParticipantsView(context, chatContainedWidth,
                          contributors, contributorsHandUp)),
                ],
              ),
            ),
            //CONTROL LAYOUT
            Container(
                height: 80,
                color: ColorConstants.kBlack3,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: double.maxFinite,
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: double.maxFinite,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CallButtonShape(
                                key: micTargetKey,
                                image: !state.audioMuted
                                    ? imageSVGAsset('icon_microphone') as Widget
                                    : imageSVGAsset('icon_microphone_disabled')
                                        as Widget,
                                onClickAction: () async {
                                  await context
                                      .read<ConferenceCubit>()
                                      .audioMute();
                                }),
                            const SizedBox(width: 20),
                            CallButtonShape(
                                image: !state.videoMuted
                                    ? imageSVGAsset('icon_video_recorder')
                                        as Widget
                                    : imageSVGAsset(
                                            'icon_video_recorder_disabled')
                                        as Widget,
                                onClickAction: () async {
                                  await context
                                      .read<ConferenceCubit>()
                                      .videoMute();
                                }),
                            const SizedBox(width: 20),
                            CallButtonShape(
                                image: imageSVGAsset('icon_arrow_square_up')
                                    as Widget,
                                bgColor: state.screenShared
                                    ? ColorConstants.kPrimaryColor
                                    : ColorConstants.kWhite30,
                                onClickAction: () async {
                                  // if (!state.screenShared) {
                                  await context
                                      .read<ConferenceCubit>()
                                      .shareScreen();
                                  // }
                                }),
                            const SizedBox(width: 20),
                            CallButtonShape(
                                image: Icon(
                                  state.handUp
                                      ? Icons.waving_hand_outlined
                                      : Icons.front_hand_outlined,
                                  color: Colors.white,
                                ),
                                bgColor: ColorConstants.kWhite30,
                                onClickAction: () async {
                                  await context
                                      .read<ConferenceCubit>()
                                      .handUp();
                                }),
                            const SizedBox(width: 20),
                            CallButtonShape(
                              // image: state.recording ? const Icon(Icons.stop, size: 30, color: Colors.red): const  Icon(Icons.fiber_manual_record, size: 30, color: Colors.red),
                              image: state.recording ==
                                      RecordingStatus.notRecording
                                  ? const Icon(Icons.fiber_manual_record,
                                      size: 30, color: Colors.red)
                                  : state.recording == RecordingStatus.loading
                                      ? const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        )
                                      : const Icon(Icons.stop,
                                          size: 30, color: Colors.red),
                              onClickAction: () async {
                                await context
                                    .read<ConferenceCubit>()
                                    .recordingMeet();
                              },
                            ),
                            const SizedBox(width: 20),
                            CallButtonShape(
                              image: imageSVGAsset('icon_phone') as Widget,
                              bgColor: ColorConstants.kPrimaryColor,
                              onClickAction: () async {
                                await context
                                    .read<ConferenceCubit>()
                                    .finishCall();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: double.maxFinite,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(children: [
                                CallButtonShape(
                                  image: const Icon(
                                    Icons.group,
                                    color: Colors.white,
                                  ),
                                  bgColor: ColorConstants.kPrimaryColor
                                      .withOpacity(0.4),
                                  onClickAction: () async {
                                    await context
                                        .read<ConferenceCubit>()
                                        .toggleParticipantsWindow();
                                  },
                                ),

                                Positioned(
                                  right: 5,
                                  top: 2,
                                  child: AnimatedOpacity(
                                    opacity: 1,
                                    duration: const Duration(milliseconds: 250),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 20,
                                        minHeight: 16,
                                      ),
                                      child: Text(
                                        contributors.length.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                )

                                // child: Text('${state.unreadMessages}', style: context.primaryTextTheme.labelSmall,)),
                                //   child: Text('1', style: context.primaryTextTheme.labelSmall?.copyWith(fontSize: 8, fontWeight: FontWeight.w700),)),,
                              ]),
                              const SizedBox(width: 20),
                              Stack(children: [
                                CallButtonShape(
                                  image:
                                      imageSVGAsset('icon_message') as Widget,
                                  bgColor: ColorConstants.kPrimaryColor
                                      .withOpacity(0.4),
                                  onClickAction: () async {
                                    await context
                                        .read<ConferenceCubit>()
                                        .toggleChatWindow();
                                  },
                                ),
                                BlocBuilder<ChatCubit, ChatState>(
                                  builder: (context, state) {
                                    final int unread = state.unreadMessages;

                                    if (showingChat || unread == 0) {
                                      return const SizedBox.shrink();
                                    }

                                    return Positioned(
                                      right: 5,
                                      top: 2,
                                      child: AnimatedOpacity(
                                        opacity: 1,
                                        duration:
                                            const Duration(milliseconds: 250),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 20,
                                            minHeight: 16,
                                          ),
                                          child: Text(
                                            unread > 99
                                                ? '99+'
                                                : unread.toString(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              ]),
                              const SizedBox(width: 20),
                            ]),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    ],
  );
}
