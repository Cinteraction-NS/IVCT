import 'dart:io';
import 'dart:typed_data';

import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_event.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/user_event.dart';
import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/get_chat_details.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/send_message.dart';
import 'package:file_picker/file_picker.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import '../../../core/io/network/models/data_channel_command.dart';
import '../../../core/io/network/models/participant.dart';
import '../../../core/util/util.dart';
import '../../data/dto/chat/chat_dto.dart';
import '../entities/chat_message.dart';

abstract class ChatRepo {
  const ChatRepo();

  Future<void> initialize({required int chatGroupId, required bool isInCall});
  Future<void> sendMessage(String msg, List<String> participantIds);
  Stream<List<Participant>> getParticipantsStream();
  Stream<UserEvent> getUsersStream();
  Stream<ChatEvent> getChatsStream();
  Stream<List<MessageDto>> getMessageStream();
  Stream<ChatDetailsDto> getChatDetailsStream();
  Stream<ChatPagination> getPaginationStream();
  Stream<UserListResponse> getUsersPaginationStream();

  Future<void> sendMessageToChatWrapper(String? name, int? chatId,
      String? messageContent, int senderId, List<int> participantIds,
      {List<PlatformFile>? uploadedFiles});
  // Future<void> createGroup(String name, int senderId, List<int> participantIds,);
  Future<void> loadChats(int page, int paginate, String? search);
  Future<void> loadUsers(int page, int paginate, int companyId, String? search);
  Future<void> setCurrentParticipant(UserDto user);
  Future<void> setCurrentChat(ChatDto? chat);
  Future<void> setUserStatus(String status);
  Future<void> getChatDetails(int id, int page);
  Future<void> getChatDetailsByParticipiant(int id, int page);
  Future<void> deleteChat(int chatId, int userId);
  Future<void> deleteMessage(int id);
  Future<void> editMessage(int id, String message);
  Future<void> removeUserFromGroup(int chatId, int userId);
  Future<void> openDownloadedMedia(int id, String fileName);
  Future<void> addUserOnGroupChat(
      int chatId, int userId, List<int> participantIds);
  Future<void> messageSeen(int msgId);

  // Future<void> makeCall(String user);
  // Future<void> answerCall();
  // Future<void> rejectCall();
  // Stream<String> getVideoCallStream();
  // Stream<StreamRenderer> getLocalStream();
  // Stream<StreamRenderer> getRemoteStream();

  Future<void> sendFile(String name, Uint8List bytes);
  Future<void> chooseFile();
  Future<void> leaveRoom();
}
