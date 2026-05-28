import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../assets/colors/Colors.dart';
import '../../../../../../core/ui/images/image.dart';
import '../../../../../../core/ui/widget/call_button_shape.dart';
import '../../../../../../core/util/util.dart';
import '../../../../cubit/conference/conference_cubit.dart';
import '../../../profile/ui/widget/user_image.dart';

Widget getParticipantsView(
    BuildContext context,
    double width,
    List<StreamRenderer> contributors,
    List<StreamRenderer> contributorsHandUp) {
  return Container(
    width: width,
    height: double.maxFinite,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(23.0),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'IN THE MEETING',
                  style: context.titleTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  context.read<ConferenceCubit>().toggleParticipantsWindow();
                },
              )
            ],
          ),
          Visibility(
            visible: contributorsHandUp.isNotEmpty,
            child: Text(
              'Raised hands',
              style: context.titleTheme.titleSmall,
            ),
          ),
          ...contributorsHandUp.map((contributor) {
            var name = contributor.publisherName;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UserImage.medium(
                  [contributor.getUserImageDTO()],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
          Text(
            'Contributors',
            style: context.titleTheme.titleSmall,
          ),
          Expanded(
              child: ListView.builder(
            itemCount: contributors.length,
            itemBuilder: (context, index) {
              var contributor = contributors[index];
              var name = contributor.publisherName;

              return Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    UserImage.medium([contributor.getUserImageDTO()]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    CallButtonShape(
                        size: 35,
                        bgColor: !(contributor.isAudioMuted ?? true)
                            ? ColorConstants.kStateSuccess
                            : ColorConstants.kPrimaryColor,
                        image: !(contributor.isAudioMuted ?? true)
                            ? imageSVGAsset('icon_microphone') as Widget
                            : imageSVGAsset('icon_microphone_disabled')
                                as Widget,
                        onClickAction: () async {
                          await context
                              .read<ConferenceCubit>()
                              .muteByID(contributor.id);
                        }),
                    const SizedBox(width: 6),
                    TextButton(
                        onPressed: () {
                          context.read<ConferenceCubit>().kick(contributor.id);
                        },
                        child: Text(
                          "Kick",
                          style: context.textTheme.bodySmall,
                        ))
                  ],
                ),
              );
            },
          )),
        ],
      ),
    ),
  );
}
