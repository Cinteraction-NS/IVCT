import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/chat_view/chat_view.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/participant_video_widget.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/participants_list_view/participants_list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../assets/colors/Colors.dart';
import '../../../../core/ui/images/image.dart';
import '../../../../core/ui/widget/call_button_shape.dart';
import '../../../../core/util/util.dart';
import '../../cubit/chat/chat_cubit.dart';
import '../../cubit/chat/chat_state.dart';
import '../../cubit/conference/conference_cubit.dart';
import '../../cubit/conference/conference_state.dart';

Widget getMobileView(
    BuildContext context,
    ConferenceState state,
    List<StreamRenderer> items,
    List<StreamRenderer> contributors,
    List<StreamRenderer> contributorsHandUp) {
  return SafeArea(
      child: Stack(
    children: [
      Column(
        children: [
          Expanded(
              child: Container(
                  child: getLayout(
                      context, items, state.isGridLayout, 3.0, 0, false))),
          Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CallButtonShape(
                    image: imageSVGAsset('icon_phone') as Widget,
                    bgColor: ColorConstants.kPrimaryColor,
                    onClickAction: () async {
                      await context.read<ConferenceCubit>().finishCall();
                    },
                  ),
                  const Spacer(),
                  CallButtonShape(
                      image: !state.audioMuted
                          ? imageSVGAsset('icon_microphone') as Widget
                          : imageSVGAsset('icon_microphone_disabled') as Widget,
                      onClickAction: () async {
                        await context.read<ConferenceCubit>().audioMute();
                      }),
                  const Spacer(),
                  CallButtonShape(
                      image: !state.videoMuted
                          ? imageSVGAsset('icon_video_recorder') as Widget
                          : imageSVGAsset('icon_video_recorder_disabled')
                              as Widget,
                      onClickAction: () async {
                        await context.read<ConferenceCubit>().videoMute();
                      }),
                  const Spacer(),
                  CallButtonShape(
                      image: imageSVGAsset('icon_switch_camera') as Widget,
                      onClickAction: () async {
                        await context.read<ConferenceCubit>().switchCamera();
                      }),
                  const Spacer(),
                  BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      final int unread = state.unreadMessages;

                      // if (showingChat ||
                      //     unread == 0) {
                      //   return const SizedBox
                      //       .shrink();
                      // }

                      return Stack(children: [
                        PopupMenuButton<String>(
                          iconColor: Colors.white,
                          icon: const Icon(Icons.more_vert),
                          onSelected: (e) async {
                            switch (e) {
                              case 'Chat':
                                await context
                                    .read<ConferenceCubit>()
                                    .toggleChatWindow();
                                break;
                              case 'Participants':
                                await context
                                    .read<ConferenceCubit>()
                                    .toggleParticipantsWindow();
                                break;
                              case 'HandUp':
                                await context.read<ConferenceCubit>().handUp();
                                break;

                              case 'Switch Camera':
                                await context
                                    .read<ConferenceCubit>()
                                    .switchCamera();
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return {'Chat', 'Participants', 'HandUp'}
                                .map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: choice == 'Chat'
                                    ? Row(children: [
                                        Text(choice),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Visibility(
                                          visible: unread > 0,
                                          child: AnimatedOpacity(
                                            opacity: 1,
                                            duration: const Duration(
                                                milliseconds: 250),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
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
                                        ),
                                      ])
                                    : Text(choice),
                              );
                            }).toList();
                          },
                        ),
                        Visibility(
                          visible: unread > 0,
                          child: Positioned(
                            right: 5,
                            top: 2,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: ColorConstants.kPrimaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        )
                        // child: Text('${state.unreadMessages}', style: context.primaryTextTheme.labelSmall,)),
                        //   child: Text('1', style: context.primaryTextTheme.labelSmall?.copyWith(fontSize: 8, fontWeight: FontWeight.w700),)),,
                      ]);
                    },
                  ),
                ],
              ))
        ],
      ),
      Visibility(
        visible: state.showingChat,
        child: getChatView(context, double.maxFinite),
        // ),
      ),
      Visibility(
          visible: state.showingParticipants,
          child: getParticipantsView(
              context, double.maxFinite, contributors, contributorsHandUp)),
    ],
  ));
}

Widget getLayout(BuildContext context, List<StreamRenderer> items, bool isGrid,
    double borderWidth, double parrentHeight, bool isSideWidowOpen) {
  StreamRenderer? screenshared;

  try {
    if (items.isNotEmpty) {
      for (var stream in items) {
        if (stream.publisherName.toLowerCase().contains('screenshare')) {
          screenshared = stream;
          items.remove(stream);
          break;
        }
      }
    }
  } on Exception catch (e) {
    print(e);
  }

  var width = MediaQuery.of(context).size.width - (isSideWidowOpen ? 400 : 0);

  final double itemWidth = width;
  //Mobile layout
  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      return ListView.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return ParticipantVideoWidget(
                remoteStream: items[index],
                height: (constraints.minHeight) /
                    (items.length > 3 ? 3 : items.length),
                width: itemWidth);
          });
    },
  );
}