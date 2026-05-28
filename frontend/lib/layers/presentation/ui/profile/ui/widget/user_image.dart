import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/string.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/ui/widget/url_image.dart';

class UserImage extends StatelessWidget {
  const UserImage.small(this.users, {super.key}) : size = 32, shade = 200;

  const UserImage.medium(this.users, {super.key}) : size = 48, shade = 200;

  const UserImage.large(this.users, {super.key}) : size = 200, shade = 200;

  const UserImage.size(this.users, this.size, this.shade, {super.key});

  final List<UserImageDto> users;
  final double size;
  final int shade;

  @override
  Widget build(BuildContext context) {
    if (users.isNotEmpty) {
      return MultiUserAvatar(users: users, size: size, shade: shade,);
    } else {
      return CircleAvatar(
        backgroundColor: ColorConstants.kPrimaryColor,
        radius: size / 2,
        child: const Text(""),
      );
    }
  }
}

class MultiUserAvatar extends StatelessWidget {
  final List<UserImageDto> users; // max 4
  final double size;
  final int shade;

  const MultiUserAvatar({required this.users, this.size = 60, required this.shade, super.key});

  @override
  Widget build(BuildContext context) {
    final displayUsers = users.take(4).toList();
    final numberOfCol = displayUsers.length > 1 ? 2 : 1;
    final numberOfRow = displayUsers.length > 2 ? 2 : 1;

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: Colors.grey.shade200,
        child: Wrap(
          children: List.generate(displayUsers.length, (i) {
            final user = displayUsers[i];

            final width = (i == 2 && displayUsers.length == 3)
                ? size
                : size / numberOfCol;
            final height = size / numberOfRow;

            return Container(
              width: width,
              height: height,
              color: ColorConstants.getRandomColor(user.id, shade: shade),
              child: Center(
                  child: Stack(
                children: [
                  Center(
                    child:
                        Text(
                      user.name.getInitials().toUpperCase(),
                      style: TextStyle(
                        fontSize: displayUsers.length == 1 ? size/3 : 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (user.imageUrl != '' &&
                      !user.imageUrl.contains('ui-avatars'))
                    Center(
                      child: UrlImage.square(
                        // fit: BoxFit.fill,
                        url: user.imageUrl,
                        size: max(height, width),
                      ),
                    )
                ],
              )),
            );
          }),
        ),
      ),
    );
  }
}

class UserImageDto {
  UserImageDto({required this.id, required this.name, required this.imageUrl});

  final int id;
  final String name;
  final String imageUrl;
}
