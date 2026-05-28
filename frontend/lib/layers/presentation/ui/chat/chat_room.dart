import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/core/app/style.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/core/io/network/models/data_channel_command.dart';
import 'package:cinteraction_vc/core/io/network/urls.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';

import 'package:cinteraction_vc/layers/presentation/cubit/home/home_cubit.dart';

import 'package:cinteraction_vc/layers/presentation/ui/chat/widget/dialogs/add_participiant_dialog.dart';
import 'package:cinteraction_vc/layers/presentation/ui/chat/widget/chat_details_widget.dart';
import 'package:cinteraction_vc/layers/presentation/ui/chat/widget/dialogs/editGroupDialog.dart';
import 'package:cinteraction_vc/layers/presentation/ui/chat/widget/user_list_view.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/participant_video_widget.dart';
import 'package:cinteraction_vc/layers/presentation/ui/chat/widget/dialogs/group_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../assets/colors/Colors.dart';
import '../../../../core/ui/images/image.dart';
import '../../../../core/ui/widget/call_button_shape.dart';
import '../../../domain/entities/user.dart';
import '../../cubit/app/app_cubit.dart';
import '../../cubit/app/app_state.dart';
import '../home/ui/widgets/next_meeting_widget.dart';
import 'widget/chat_list_view.dart';
import '../home/ui/widgets/home_item.dart';
import '../home/ui/widgets/join_popup.dart';
import '../home/ui/widgets/schedule_popup.dart';
import '../profile/ui/widget/user_image.dart';

class ChatRoomPage extends StatelessWidget {
  const ChatRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.getCurrentUser;

    AudioPlayer audioPlayer = AudioPlayer();

    void playIncomingCallSound() async {
      try {
        await audioPlayer.setSource(AssetSource('discord_incoming_call.mp3'));
        audioPlayer.resume();
      } catch (e) {
        print('Error playing sound: $e');
      }
    }

    void stopIncomingCallSound() async {
      await audioPlayer.stop();
    }

    AlertDialog? callDialog;
    AlertDialog? incomingDialog;

    makeCallDialog() async {
      callDialog = await showDialog<AlertDialog>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text("Calling..."),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context, rootNavigator: true)
                            .pop(incomingDialog);
                        // Navigator.of(context, rootNavigator: true).pop(callDialog);
                        // await publishVideo.hangup();
                        context.read<ChatCubit>().rejectCall();
                      },
                      child: const Text('Reject')),
                ],
              ),
            );
          });
    }

    Future<dynamic> showIncomingCallDialog(
        BuildContext context, String caller) async {
      playIncomingCallSound();

      return showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text('Incoming call from ${caller}'),
              actions: [
                ElevatedButton(
                    onPressed: () async {
                      context.read<ChatCubit>().answerCall();
                      Navigator.of(context).pop(incomingDialog);
                      stopIncomingCallSound();
                      // Navigator.of(context).pop(callDialog);
                    },
                    child: const Text('Answer')),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context, rootNavigator: true)
                          .pop(incomingDialog);
                      context.read<ChatCubit>().rejectCall();
                      stopIncomingCallSound();
                    },
                    child: const Text('Reject')),
              ],
            );
          });
    }

    Future<void> displayJoinRoomPopup(BuildContext context) async {
      return showDialog(
        context: context,
        builder: (context) {
          return const JoinPopup();
        },
      );
    }

    Future<void> displayAddScheduleMeetingPopup(ChatState state) async {
      return showDialog(
        context: context,
        builder: (_) => BlocProvider.value(
            value: context.read<HomeCubit>(), // koristi instancu iz stranice
            child: SchedulePopup(
              context: context,
              state: state,
            )),
      );
    }

    Future<void> displayCreateGroupPopup(BuildContext ctx, state) async {
      return showDialog(
          context: ctx,
          builder: (context) {
            return CreateGroupDialog(
              state: state,
              context: ctx,
            );
          });
    }

    Future<void> displayEditGroupPopup(BuildContext ctx, state) async {
      return showDialog(
          context: ctx,
          builder: (context) {
            return EditGroupDialog(
              state: state,
              context: ctx,
            );
          });
    }

    return BlocListener<AppCubit, AppState>(
      listenWhen: (previous, current) =>
          previous.userStatus != current.userStatus,
      listener: (context, state) {
        print(state.userStatus.value);
        context.read<ChatCubit>().setUserStatus(state.userStatus.value);
      },
      child: BlocProvider<ChatCubit>.value(
        value: getIt.get<ChatCubit>(),
        child: BlocConsumer<ChatCubit, ChatState>(
            listenWhen: (previous, current) =>
                previous.incomingCall != current.incomingCall ||
                previous.calling != current.calling ||
                previous.chats != current.chats,
            listener: (context, state) async {
              final previousState = context.read<ChatCubit>().state;

              //  INCOMING CALL STARTED
              if (state.incomingCall ?? false) {
                await showIncomingCallDialog(context, state.caller!);
                return;
              }

              //  INCOMING CALL ENDED
              if ((previousState.incomingCall ?? false) &&
                  !(state.incomingCall ?? false)) {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop(incomingDialog);
                  stopIncomingCallSound();
                }
              }

              //  OUTGOING CALL STARTED
              if (state.calling ?? false) {
                await makeCallDialog();
                return;
              }

              //  OUTGOING CALL ENDED
              if ((previousState.calling ?? false) &&
                  !(state.calling ?? false)) {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop(incomingDialog);
                }
              }
            },
            builder: (context, state) {
              return Scaffold(
                  body: Stack(
                children: [
                  if (context.isWide)
                    Row(
                      children: [
                        // First column
                        getLeftSide(
                            context,
                            state,
                            300,
                            () => {displayJoinRoomPopup(context)},
                            () => {displayAddScheduleMeetingPopup(state)},
                            () => {displayCreateGroupPopup(context, state)}),

                        const VerticalDivider(
                          color: Colors.grey, // Color of the divider
                          thickness: 1, // Thickness of the divider
                          width: 20, // Width of the space taken by the divider
                        ),
                        Expanded(
                          flex: 2,
                          child: getChatDetailsView(context, state, user,
                              () => {displayEditGroupPopup(context, state)}),
                        ),
                      ],
                    )
                  else
                    Stack(
                      children: [
                        getLeftSide(
                            context,
                            state,
                            double.maxFinite,
                            () => {displayJoinRoomPopup(context)},
                            () => {displayAddScheduleMeetingPopup(state)},
                            () => {displayCreateGroupPopup(context, state)}),
                        Visibility(
                            visible: state.currentChat != null ||
                                state.currentParticipant != null,
                            // visible: false,

                            child: getChatDetailsView(context, state, user,
                                () => {displayEditGroupPopup(context, state)}))
                      ],
                    )
                ],
              ));
            }),
      ), // The rest of your UI
    );
  }
}

Widget getLeftSide(BuildContext context, ChatState state, double? width,
    Function joinRoom, Function scheduleMeeting, Function createGroup) {
  return SizedBox(
    width: width,
    child: Column(
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: HomeTabItem.mobile(
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
                ),
              ),
              Expanded(
                child: HomeTabItem.mobile(
                    image: const Image(
                      image: ImageAsset('add_user.png'),
                    ),
                    bgColor: ColorConstants.kStateSuccess,
                    onClickAction: () => {
                          // AppRoute.meeting.push(context)
                          joinRoom()
                        },
                    label: 'Join',
                    textStyle: context.textTheme.labelMedium),
              ),
              Expanded(
                child: HomeTabItem.mobile(
                    image: const Image(
                      image: ImageAsset('calendar-date.png'),
                    ),
                    bgColor: ColorConstants.kStateInfo,
                    onClickAction: () async {
                      scheduleMeeting();
                      // displayAddScheduleMeetingPopup();
                    },
                    label: 'Schedule',
                    textStyle: context.textTheme.labelMedium),
              )
            ],
          ),
        ),
        const Divider(),
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(10),
          child: Row(
            children: ListType.values.map((option) {
              return Expanded(
                child: ListTile(
                  titleAlignment: ListTileTitleAlignment.center,
                  title: Tooltip(
                    message: option == ListType.Users
                        ? "Contacts"
                        : option == ListType.Chats
                            ? "Chats"
                            : option == ListType.Group
                                ? "Create Group"
                                : "",
                    child: option == ListType.Group
                        ? IconButton(
                            icon: Icon(
                              Icons.group_add,
                              size: 24.0,
                              color: state.listType == option
                                  ? ColorConstants.kPrimaryColor
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              // await displayCreateGroupPopup(context, state);
                              createGroup();
                            },
                          )
                        : option == ListType.Users
                            ? Icon(
                                Icons.contacts,
                                size: 24.0,
                                color: state.listType == option
                                    ? ColorConstants.kPrimaryColor
                                    : Colors.grey,
                              )
                            : option == ListType.Chats
                                ? Icon(
                                    Icons.chat,
                                    size: 24.0,
                                    color: state.listType == option
                                        ? ColorConstants.kPrimaryColor
                                        : Colors.grey,
                                  )
                                : Text(
                                    option.name,
                                    textAlign: TextAlign.center,
                                  ),
                  ),
                  onTap: () {
                    context.read<ChatCubit>().changeListType(option);
                  },
                  selected: state.listType == option,
                  selectedColor: ColorConstants.kPrimaryColor,
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(),
        Expanded(
          child: state.listType == ListType.Chats
              ? (state.chats?.isNotEmpty ?? false)
                  ? ChatsListView(state: state)
                  : const Center(
                      child: Text('There is no chats'),
                    )
              : UsersListView(state: state),
        ),
        BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            print(
                "Builder rebuilding with nextMeeting: ${state.nextMeeting?.eventName}");

            return Visibility(
              visible: state.nextMeeting != null,
              child: state.nextMeeting == null
                  ? Container()
                  : NextMeetingWidget(
                      meeting: state.nextMeeting!,
                      banner: true,
                    ),
            );
          },
        )
      ],
    ),
  );
}

String getUserStatus(bool isOnline, String userStatus) {
  return isOnline
      ? userStatus == UserStatus.inTheCall.value
          ? "In The Call"
          : "Available"
      : "Unavailable";
}

Widget userStatusWidget(ChatState state) {
  String currentUserState = getUserStatus(state.currentChat?.isOnline ?? false,
      state.currentChat?.userStatus ?? UserStatus.online.value);

  return Row(
    children: [
      Container(
        width: 15.0,
        // Adjust the width as needed
        height: 15.0,
        // Adjust the height as needed
        decoration: BoxDecoration(
          color: (state.listType == ListType.Chats
                  ? state.currentChat?.isOnline == true
                  : state.currentParticipant?.online == true)
              ? Colors.green
              : Colors.amber,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 5.0),
      Text(currentUserState),
    ],
  );
}

Widget getChatDetailsView(
    BuildContext context, ChatState state, User? user, Function editGroup) {
  return Container(
    width: double.maxFinite,
    height: double.maxFinite,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: () {
        if (state.localStream != null) {
          if (state.remoteStream == null) {
            return ParticipantVideoWidget(
                remoteStream: state.localStream!,
                height: double.maxFinite,
                width: double.maxFinite);
          } else {
            return Stack(
              children: [
                ParticipantVideoWidget(
                    remoteStream: state.remoteStream!,
                    height: double.maxFinite,
                    width: double.maxFinite),
                ParticipantVideoWidget(
                    remoteStream: state.localStream!, height: 200, width: 200),
                Positioned.fill(
                  bottom: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CallButtonShape(
                          image: !state.audioMuted
                              ? imageSVGAsset('icon_microphone') as Widget
                              : imageSVGAsset('icon_microphone_disabled')
                                  as Widget,
                          onClickAction: () async {
                            await context.read<ChatCubit>().audioMute();
                          }),
                      const SizedBox(width: 20),
                      CallButtonShape(
                          image: !state.videoMuted
                              ? imageSVGAsset('icon_video_recorder') as Widget
                              : imageSVGAsset('icon_video_recorder_disabled')
                                  as Widget,
                          onClickAction: () async {
                            await context.read<ChatCubit>().videoMute();
                          }),
                      const SizedBox(width: 20),
                      CallButtonShape(
                          image:
                              imageSVGAsset('icon_arrow_square_up') as Widget,
                          bgColor: true
                              ? ColorConstants.kPrimaryColor
                              : ColorConstants.kWhite30,
                          onClickAction: () async {}),
                      const SizedBox(width: 20),
                      CallButtonShape(
                        image: imageSVGAsset('icon_phone') as Widget,
                        bgColor: ColorConstants.kPrimaryColor,
                        onClickAction: () async {
                          await context.read<ChatCubit>().rejectCall();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        }

        if (state.currentParticipant != null || state.chatDetails != null) {
          if (state.localStream != null) {
            if (state.remoteStream == null) {
              return ParticipantVideoWidget(
                  remoteStream: state.localStream!,
                  height: double.maxFinite,
                  width: double.maxFinite);
            } else {
              return Stack(
                children: [
                  ParticipantVideoWidget(
                      remoteStream: state.remoteStream!,
                      height: double.maxFinite,
                      width: double.maxFinite),
                  ParticipantVideoWidget(
                      remoteStream: state.remoteStream!,
                      height: 200,
                      width: 200),
                  Positioned.fill(
                    bottom: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CallButtonShape(
                            image: false
                                ? imageSVGAsset('icon_microphone') as Widget
                                : imageSVGAsset('icon_microphone_disabled')
                                    as Widget,
                            onClickAction: () async {
                              // await context
                              //     .read<ConferenceCubit>()
                              //     .audioMute();
                            }),
                        const SizedBox(width: 20),
                        CallButtonShape(
                            image: false
                                ? imageSVGAsset('icon_video_recorder') as Widget
                                : imageSVGAsset('icon_video_recorder_disabled')
                                    as Widget,
                            onClickAction: () async {
                              // await context
                              //     .read<ConferenceCubit>()
                              //     .videoMute();
                            }),
                        const SizedBox(width: 20),
                        CallButtonShape(
                            image:
                                imageSVGAsset('icon_arrow_square_up') as Widget,
                            bgColor: true
                                ? ColorConstants.kPrimaryColor
                                : ColorConstants.kWhite30,
                            onClickAction: () async {}),

                        // const SizedBox(width: 20),

                        // Stack(children: [
                        //   CallButtonShape(
                        //     image: imageSVGAsset('icon_message')
                        //     as Widget,
                        //     bgColor: ColorConstants.kPrimaryColor
                        //         .withOpacity(0.4),
                        //     onClickAction: () async {
                        //       await context
                        //           .read<ConferenceCubit>()
                        //           .toggleChatWindow();
                        //     },
                        //   ),
                        //   Positioned(
                        //     right: 0,
                        //     top: 0,
                        //     child: AnimatedOpacity(
                        //       opacity:
                        //       (state.unreadMessages != null &&
                        //           state.unreadMessages! > 0)
                        //           ? 1
                        //           : 0,
                        //       duration:
                        //       const Duration(milliseconds: 250),
                        //       child: Container(
                        //         width: 12,
                        //         height: 12,
                        //         decoration: const ShapeDecoration(
                        //           color: Colors.white,
                        //           shape: OvalBorder(),
                        //         ),
                        //         // child: Text(
                        //         //   '1',
                        //         //   style: context
                        //         //       .primaryTextTheme.labelSmall
                        //         //       ?.copyWith(
                        //         //           fontSize: 8,
                        //         //           fontWeight:
                        //         //               FontWeight.w700),
                        //         // )
                        //       ),
                        //     ),
                        //   ),
                        //   // child: Text('${state.unreadMessages}', style: context.primaryTextTheme.labelSmall,)),
                        //   //   child: Text('1', style: context.primaryTextTheme.labelSmall?.copyWith(fontSize: 8, fontWeight: FontWeight.w700),)),,
                        // ]),

                        const SizedBox(width: 20),
                        // CallButtonShape(
                        //     image: imageSVGAsset('icon_user') as Widget,
                        //     // onClickAction: joined ? switchCamera : null),
                        //     onClickAction: joined ? null : null),
                        // const SizedBox(width: 20),
                        CallButtonShape(
                          image: imageSVGAsset('icon_phone') as Widget,
                          bgColor: ColorConstants.kPrimaryColor,
                          onClickAction: () async {
                            await context.read<ChatCubit>().rejectCall();
                          },
                        ),

                        // const SizedBox(width: 20),

                        // CallButtonShape(
                        //     image: state.engagementEnabled
                        //         ? const Icon(Icons.image)
                        //         : const Icon(Icons.image_not_supported),
                        //     onClickAction: () async {
                        //       await context
                        //           .read<ConferenceCubit>()
                        //           .toggleEngagement();
                        //     }),
                        //
                      ],
                    ),
                  ),
                ],
              );
            }
          }

          return Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    if (!context.isWide)
                      Container(
                        color: Colors.white,
                        child: IconButton(
                            onPressed: () =>
                                {context.read<ChatCubit>().clearCurrentChat()},
                            icon: const Icon(Icons.arrow_back)),
                      ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.listType == ListType.Chats
                              ? (state.currentChat?.getChatName() ?? "")
                              : state.currentParticipant?.name ?? "",
                          style: titleThemeStyle.textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        state.listType == ListType.Chats &&
                                state.chatDetails!.isGroup
                            ? Row(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      // await displayEditGroupPopup(
                                      //     context, state);
                                      editGroup();
                                    },
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: Row(children: [
                                        Text((state.chatDetails!
                                                    .chatParticipants.length +
                                                1)
                                            .toString()),
                                        const SizedBox(width: 3.0),
                                        const Text('participants'),
                                      ]),
                                    ),
                                  ),
                                ],
                              )
                            : userStatusWidget(state)
                      ],
                    )),
                    const SizedBox(
                      width: 5,
                    ),
                    Row(
                      children: [
                        Visibility(
                            visible: state.listType == ListType.Chats
                                ? state.currentChat?.isOnline == true
                                : state.currentParticipant?.online == true,
                            child: CallButtonShape(
                              image: imageSVGAsset('icon_phone') as Widget,
                              bgColor: ColorConstants.kGray600,
                              onClickAction: () async {
                                await context.read<ChatCubit>().makeCall(
                                    (state.listType == ListType.Chats
                                        ? state.currentChat?.chatParticipants
                                            ?.first.id
                                            .toString()
                                        : state.currentParticipant?.id)!);

                                // await context.read<ChatCubit>().rejectCall();
                              },
                            )),
                        Tooltip(
                          message: 'Start a group chat',
                          child: IconButton(
                            icon: const Icon(Icons.person_add,
                                color: ColorConstants.kSecondaryColor),
                            onPressed: () async {
                              final currentParticipants = state
                                  .chatDetails!.chatParticipants
                                  .map((p) => p.id.toString())
                                  .toSet();

                              final availableUsers = state.users!
                                  .where((user) => !currentParticipants
                                      .contains(user.id.toString()))
                                  .toList();
                              showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    AddParticipantsDialog(
                                  users: availableUsers,
                                  onAddParticipants: (selectedUsers) async {
                                    final participantIds = selectedUsers
                                        .map((user) => int.parse(user.id))
                                        .toList();

                                    if (!state.chatDetails!.isGroup) {
                                      participantIds.add(state
                                          .chatDetails!.chatParticipants[0].id);
                                    }

                                    state.chatDetails!.isGroup
                                        ? await getIt
                                            .get<ChatCubit>()
                                            .chatUseCases
                                            .addUserToGroup(
                                                state.chatDetails!.chatId!,
                                                state.chatDetails!.authUser.id,
                                                participantIds)
                                        : await getIt
                                            .get<ChatCubit>()
                                            .chatUseCases
                                            .sendMessageToChatStream(
                                                senderId: state
                                                    .chatDetails!.authUser.id,
                                                participantIds: participantIds);
                                  },
                                  context: context,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(child: ChatDetailsWidget(state)),
            ],
          );
        }
        return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 10,
              ),
              UserImage.medium([user!.getUserImageDTO()]),
              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome!',
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleLarge,
                  ),
                  Text(
                    user.name,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleLarge,
                  ),
                ],
              )
            ]);
      }(),
    ),
  );
}
