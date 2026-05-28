import 'dart:io';

import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:file_picker/file_picker.dart';

import '../../repos/chat_repo.dart';

class SendMessageToChatStream {
  SendMessageToChatStream({required this.repo});

  final ChatRepo repo;

  call({
    String? name,
    int? chatId,
    String? messageContent,
    required int senderId,
    required List<int> participantIds,
    List<PlatformFile>? uploadedFiles,
  }) {
    return repo.sendMessageToChatWrapper(
      name,
      chatId,
      messageContent,
      senderId,
      participantIds,
      uploadedFiles: uploadedFiles,
    );
  }
}
