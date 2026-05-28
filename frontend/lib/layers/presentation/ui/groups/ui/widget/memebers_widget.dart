import 'package:cinteraction_vc/core/extension/string.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/entities/user.dart';
import '../../../profile/ui/widget/user_image.dart';

class MembersWidget extends StatelessWidget {
  final List<User> users;

  const MembersWidget({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    int maxAvatar = 10;
    double height = 48;

    return LayoutBuilder(
      builder: (context, constraints){
        var width = constraints.maxWidth;
        maxAvatar = ((width-height)/ (height*2/3)).floor();
// print(maxAvatar);
        return SizedBox(
          height: height,
          width: width,
          child: Stack(children: [
            for (var (index, user) in users.indexed)
              if (index == maxAvatar)
                Positioned(
                    left: ((height * 2 / 3) * index).toDouble(),
                    child: Container(
                      width: height,
                      height: height,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF2F3F6),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 2,
                            strokeAlign: BorderSide.strokeAlignOutside,
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(200),
                        ),
                      ),
                      child: Center(child: Text('+${users.length - index}')),
                    ))
              else if (index < maxAvatar)
                Positioned(
                    left: ((height * 2 / 3) * index).toDouble(),
                    child: SizedBox(
                      width: height,
                      height: height,
                      child: UserImage.medium([user.getUserImageDTO()]),
                    ))
          ]),
        );
      },

    );
  }
}
