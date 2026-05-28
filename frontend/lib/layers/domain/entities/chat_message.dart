import 'package:file_picker/file_picker.dart';

import '../../data/dto/chat/chat_detail_dto.dart';
import '../../presentation/ui/profile/ui/widget/user_image.dart';

class ChatMessage {
  ChatMessage(
      {required this.message,
      required this.displayName,
      required this.time,
      required this.avatarUrl,
      this.seen,
      this.files});

  final String message;
  final String displayName;
  final DateTime time;
  final String avatarUrl;
  final List<PlatformFile>? files;
  bool? seen;


  UserImageDto getUserImageDTO()
  {
    return UserImageDto(
      id: 0,
        name: displayName,
        imageUrl: avatarUrl
    );
  }
}
