import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/mobile_view.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/dynamic_layout/cubit/dynamic_layout_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/video_widget/participant_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/io/network/models/data_channel_command.dart';
import '../../../../core/util/util.dart';
import '../../cubit/app/app_cubit.dart';
import '../../cubit/conference/conference_cubit.dart';
import '../../cubit/conference/conference_state.dart';

import 'desktop_view.dart';

class VideoRoomPage extends StatefulWidget {
  const VideoRoomPage({super.key});

  @override
  State<VideoRoomPage> createState() => _VideoRoomPageState();
}

class _VideoRoomPageState extends State<VideoRoomPage> {
  OverlayEntry? _overlayEntry;
  OverlayEntry? _overlayEntryMic;

  final List<String> _messages = [];
  late final DynamicLayoutCubit staggeredCubit;
  late final ParticipantManager participantManager;
  final GlobalKey _micTargetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    staggeredCubit = DynamicLayoutCubit();
    participantManager = ParticipantManager();
  }

  @override
  void dispose() {
    staggeredCubit.close();
    participantManager.disposeAll();
    super.dispose();
  }

  Widget _buildToast(String message, {Color? background = Colors.black26}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _showOverlay() {
    final renderBox =
        _micTargetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final targetPosition = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;
    const double width = 300;

    _overlayEntryMic?.remove();
    _overlayEntryMic = null;

    _overlayEntryMic = OverlayEntry(
      builder: (context) => Positioned(
        left: targetPosition.dx - width / 2 + targetSize.width / 2,
        top: targetPosition.dy - 40 - targetSize.height,
        // place above the widget
        width: width,
        child: Material(
          color: Colors.transparent,
          child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildToast(
                  'Are you talking? Your mic is off. Click the mic to turn it on.',
                  background: Colors.black54)),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntryMic!);
    // Optional: remove after delay
    Future.delayed(const Duration(seconds: 3), () {
      _overlayEntryMic?.remove();
      _overlayEntryMic = null;
    });
  }

  void showTopOverlay(BuildContext context, String message) {
    _messages.add(message);

    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            bottom: 100,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _messages.map((msg) => _buildToast(msg)).toList(),
              ),
            ),
          );
        },
      );

      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }

    // Auto remove each message after delay
    Future.delayed(const Duration(seconds: 2)).then((_) {
      _messages.remove(message);
      if (_messages.isEmpty) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      } else {
        _overlayEntry?.markNeedsBuild(); // Update the list
      }
    });
  }

  void _onConferenceState(BuildContext context, ConferenceState state) async {
    if (!mounted) {
      return;
    }

    if (state.error != null) {
      context.showSnackBarMessage(state.error ?? 'Error', isError: true);
    }
    if (state.isEnded) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      await context.read<AppCubit>().changeUserStatus(UserStatus.online);
    }

    if (state.isCallStarted && state.chatId != null) {
      context.read<ChatCubit>().load(true, state.chatId ?? 0);
      await context.read<AppCubit>().changeUserStatus(UserStatus.inTheCall);
    }
    if (state.toastMessage != null) {
      showTopOverlay(context, state.toastMessage!);
      context.read<ConferenceCubit>().clearToast();
    }

    if (state.showingMicIsOff) {
      _showOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController chatController = ScrollController();

    return BlocConsumer<ConferenceCubit, ConferenceState>(
        builder: (context, state) {
          if (state.isInitial) {
            return Container();
          }

          if (state.streamRenderers == null) {
            return Container();
          }

          if (state.streamRenderers!.entries.isEmpty) {
            return Container();
          }

          if (state.messages != null) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (chatController.hasClients) {
                chatController.jumpTo(chatController.position.maxScrollExtent);
              }
            });
          }

          List<StreamRenderer> items = [];
          List<StreamRenderer> screenShares = [];
          List<StreamRenderer> contributors = [];
          List<StreamRenderer> contributorsHandUp = [];

          // items.addAll(state.streamRenderers!.entries.map(
          //         (e) {
          //       participantManager.updateStream(e.value.id, e.value);
          //       return e.value;
          //     }
          // ).toList());

          screenShares.addAll(state.streamScreenShares!.entries.map((e) {
            participantManager.updateStream(e.value.id, e.value);
            return e.value;
          }).toList());

          for (var i = 0; i < state.numberOfStreamsCopy; i++) {
            items.addAll(state.streamRenderers!.entries.map((e) {
              participantManager.updateStream(e.value.id, e.value);
              return e.value;
            }).toList());
          }

          // var subscribers = state.streamSubscribers?.toList();
          contributors.addAll(
              state.streamSubscribers!.entries.map((e) => e.value).toList());
          contributorsHandUp.addAll(contributors
              .where((e) => e.isHandUp == true)
              .map((e) => e)
              .toList());

          var isRecording = state.recording == RecordingStatus.recording;

          staggeredCubit.setStreams(items);

          return Scaffold(
            body: Material(
              child: Center(
                child: Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    // color: ColorConstants.kBlack3,
                    decoration: BoxDecoration(
                      color: ColorConstants.kBlack3, // Background color
                      border: Border.all(
                        color: isRecording
                            ? ColorConstants.kPrimaryColor
                            : ColorConstants.kBlack3, // Border color
                        width: isRecording ? 3.0 : 0.0, // Border width
                      ), // Rounded corners
                    ),
                    child: Builder(
                      builder: (context) {
                        if (context.isWide) {
                          return getDesktopView(
                              context,
                              state,
                              items,
                              screenShares,
                              contributors,
                              contributorsHandUp,
                              _micTargetKey,
                              staggeredCubit,
                              participantManager);
                        } else {
                          return getMobileView(context, state, items,
                              contributors, contributorsHandUp);
                        }
                      },
                    )),
              ),
            ),
          );
          // }
        },
        listener: _onConferenceState);
  }
}
