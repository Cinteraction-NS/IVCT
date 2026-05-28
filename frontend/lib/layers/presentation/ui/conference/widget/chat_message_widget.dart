import 'dart:typed_data';
import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/layers/domain/entities/chat_message.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/text_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../chat/link_text.dart';
import '../../profile/ui/widget/user_image.dart';

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({super.key, required this.message});

  final ChatMessage message;

  bool _isImage(PlatformFile file) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    return imageExtensions.any((ext) => file.name.toLowerCase().endsWith(ext));
  }

  @override
  Widget build(BuildContext context) {
    bool hasFiles = message.files != null && message.files!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: message.displayName == 'Me'
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (message.displayName != 'Me' && message.avatarUrl.isNotEmpty)
            UserImage.medium([message.getUserImageDTO()]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: message.displayName == 'Me'
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: message.displayName == 'Me'
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    if (message.displayName != 'Me')
                      Text(
                        message.displayName,
                        style: context.primaryTextTheme.displaySmall,
                      ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('hh:mm a').format(message.time),
                      style: context.primaryTextTheme.bodySmall
                          ?.copyWith(color: ColorConstants.kGray600),
                    ),
                  ],
                ),
                if (hasFiles)
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: message.files!.map((file) {
                        if (_isImage(file) && file.bytes != null) {
                          return GestureDetector(
                            onTap: () => openLocalFile(context, file),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  file.bytes!,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () => openLocalFile(context, file),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                mainAxisAlignment: message.displayName == 'Me'
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.insert_drive_file,
                                      size: 24, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    file.name,
                                    style: context.primaryTextTheme.bodyMedium
                                        ?.copyWith(color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }).toList(),
                    ),
                  )
                else
                  LinkText(message.message),
              ],
            ),
          )
        ],
      ),
    );
  }
}
