import 'package:cinteraction_vc/layers/data/dto/chat/chat_dto.dart';

class ChatEvent {
  final List<ChatDto> chats;
  final bool isSearch;

  ChatEvent({required this.chats, required this.isSearch});
}
