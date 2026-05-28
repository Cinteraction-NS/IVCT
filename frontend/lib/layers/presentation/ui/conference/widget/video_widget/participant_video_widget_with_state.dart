// import 'dart:math';
//
// import 'package:cinteraction_vc/core/extension/context.dart';
// import 'package:cinteraction_vc/core/util/platform/platform.dart';
// import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/video_widget/cubit/video_widget_cubit.dart';
// import 'package:cinteraction_vc/layers/presentation/ui/profile/ui/widget/user_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:flutter/material.dart';
// import 'package:webrtc_interface/webrtc_interface.dart';
//
// import '../../../../../../assets/colors/Colors.dart';
// import '../../../../../../core/ui/images/image.dart';
// import '../../../../../../core/ui/widget/engagement_progress.dart';
// import '../../../../../../core/util/util.dart';
// import 'cubit/video_widget_state.dart';
//
// class ParticipantVideoWidgetNew extends StatelessWidget {
//   const ParticipantVideoWidgetNew({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<VideoWidgetCubit, VideoWidgetState>(
//         buildWhen: (previous, current) {
//       // return previous.audioMuted != current.audioMuted ||
//       //     previous.itemWidth != current.itemWidth ||
//       //     previous.itemHeight != current.itemHeight ||
//       //     previous.isSpeaking != current.isSpeaking;
//         return previous != current;
//
//     }, builder: (context, state) {
//
//           print("rebuild width:${state.itemWidth}");
//       return SizedBox(
//           height: state.itemHeight,
//           width: state.itemWidth,
//           child: LayoutBuilder(builder: (context, constraints) {
//             final halfHeight =
//                 min(constraints.maxHeight, constraints.maxWidth) / 3;
//
//             var screenShare = state.videoRenderer.publisherName
//                 .toLowerCase()
//                 .contains('screenshare');
//             // print("rebuild widget for it is new widget: ${state.videoRenderer.publisherName}");
//
//             print("REBUILD WIDGET FOR: ${state.videoRenderer.publisherName}");
//             return Stack(
//               children: [
//                 Container(
//                   margin: const EdgeInsets.all(4),
//                   child: Stack(
//                     children: [
//                       Visibility(
//                         visible: !state.videoMuted && state.isVideoFlowing,
//                         replacement: Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(16),
//                               gradient: RadialGradient(
//                                 center: Alignment.center,
//                                 radius: 0.6,
//                                 colors: [
//                                   ColorConstants.getRandomColor(
//                                       state.publisherId),
//                                   ColorConstants.getRandomColor(
//                                       state.publisherId,
//                                       shade: 700),
//                                 ],
//                               ),
//                               border: Border.all(
//                                 color: state.isSpeaking
//                                     ? Colors.white
//                                     : Colors.transparent,
//                                 width: state.isSpeaking == true ? 2.0 : 0.0,
//                               ),
//                             ),
//                             child: Center(
//                                 child: UserImage.size(
//                                     [state.videoRenderer.getUserImageDTO()],
//                                     halfHeight,
//                                     700))),
//                         child: Stack(
//                           children: [
//                             Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(16),
//                                 color: Colors.white.withAlpha(20),
//                               ),
//                             ),
//                             getVideoView(
//                                 context,
//                                 state.videoRenderer.videoRenderer,
//                                 screenShare,
//                                 state.itemWidth,
//                                 state.itemHeight,
//                                 state.videoRenderer.publisherId!,
//                                 state.videoRenderer.publisherName),
//                             Container(
//                                 width: double.maxFinite,
//                                 height: double.maxFinite,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(16),
//                                   border: Border.all(
//                                     color: state.isSpeaking
//                                         ? Colors.white
//                                         : Colors.transparent,
//                                     // Border color
//                                     width: state.isSpeaking
//                                         ? 2.0
//                                         : 0.0, // Border thickness
//                                   ),
//                                   color: Colors.transparent,
//                                 ))
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Text('${remoteStream.videoRenderer.videoWidth}:${remoteStream.videoRenderer.videoHeight}'),
//                 Positioned(
//                     top: 20,
//                     right: 24,
//                     child: Row(
//                       children: [
//                         Visibility(
//                           visible: state.itemWidth > 200,
//                           child:
//                               EngagementProgress(engagement: state.engagement),
//                         ),
//                       ],
//                     )),
//                 Positioned(
//                     left: 24,
//                     top: 20,
//                     child: Text(
//                       state.videoRenderer.publisherName,
//                       style: context.textTheme.displayLarge
//                           ?.copyWith(color: Colors.white),
//                     )),
//                 Positioned(
//                     bottom: 20,
//                     left: 24,
//                     child: Row(
//                       children: [
//                         Visibility(
//                             visible: state.audioMuted,
//                             child: imageSVGAsset('icon_microphone_disabled')
//                                 as Widget),
//                         Visibility(
//                             visible: state.videoMuted,
//                             child: imageSVGAsset('icon_video_recorder_disabled')
//                                 as Widget),
//                         Visibility(
//                           visible: state.handUp,
//                           child: const Icon(Icons.waving_hand_outlined,
//                               color: Colors.white),
//                         )
//                       ],
//                     )),
//               ],
//             );
//           }));
//     });
//   }
// }
