import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_dto.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/io/network/models/participant.dart';
import '../../../../core/janus/janus_client.dart';
import '../../../../core/logger/loggy_types.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/util/util.dart';
import '../../../data/dto/user_dto.dart';
import '../../../domain/usecases/call/call_use_cases.dart';
import '../../../domain/usecases/chat/chat_usecases.dart';

class ChatCubit extends Cubit<ChatState> with BlocLoggy {
  final ChatUseCases chatUseCases;
  final CallUseCases callUseCases;

  final bool isInCallChat;
  bool isLoaded = false;
  int myRoomId = 0;

  ChatCubit(
      {required this.chatUseCases,
      required this.callUseCases,
      required this.isInCallChat})
      : super(const ChatState.initial()) {
    if (!isInCallChat) load(isInCallChat, 1234);
  }

  void load(bool isInCall, int roomId) async {
    if (!isLoaded) {
      myRoomId = roomId;
      print("Chat Cubit is created for $myRoomId");
      await chatUseCases.chatInitialize(
          isInCall: isInCall, chatGroupId: roomId);
      if (!isInCall) {
        await callUseCases.initialize();
      } else {
        setCurrentChat(ChatDto(id: roomId, name: "name", chatGroup: true));
        getChatDetails(roomId, 1);
      }

      chatUseCases.getParticipantsStream().listen(_onParticipants);
      chatUseCases.getUsersStream().listen((event) {
        _onUsers(event.users, isSearch: event.isSearch);
      });
      chatUseCases.getChatsStream().listen((event) {
        _onChats(event.chats, isSearch: event.isSearch);
      });

      chatUseCases.getMessageStream().listen(_onMessages);
      chatUseCases.getChatDetailsStream().listen(_onChatDetails);
      chatUseCases.getPaginationStream().listen(_onPagination);
      chatUseCases.getUsersPaginationStream().listen(_onUsersPagination);

      if (!isInCall) {
        callUseCases.videoCallStream().listen(_onVideoCall);
        callUseCases.getLocalStream().listen(_onLocalStream);
        callUseCases.getRemoteStream().listen(_onRemoteStream);
      }

      isLoaded = true;
      print("inCall chat loaded: $isInCall");
    }
  }

  @override
  Future<void> close() {
    print('Chat Cubit for room: $myRoomId is being disposed');
    return super.close();
  }

  void _onMessages(List<MessageDto> messages) {
    int unreadCount = messages.where((element) => element.seen == false).length;
    // emit(state.copyWith(
    //   isInitial: true,
    //   chatMessages: messages,
    //   numberOfParticipants: Random().nextInt(10000),
    //   unreadMessages: unreadCount,
    // ));
  }

  void _onLocalStream(StreamRenderer localStream) {
    emit(state.copyWith(localStream: localStream));
  }

  void _onRemoteStream(StreamRenderer remoteStream) {
    emit(state.copyWith(
        remoteStream: remoteStream,
        numberOfParticipants: Random().nextInt(10000)));

    print('remote stream changed');
  }

  void _onPagination(ChatPagination pagination) {
    emit(state.copyWith(pagination: pagination));
  }

  void _onUsersPagination(UserListResponse userPagination) {
    emit(state.copyWith(usersPagination: userPagination));
  }

  void _onParticipants(List<Participant> participants) {
    print("_onParticipants");
    emit(state.copyWith(
        isInitial: false,
        participants: participants,
        numberOfParticipants: Random().nextInt(10000)));
  }

  Future<void> removeUserLocally(int userId) async {
    final currentUsers = List<UserDto>.from(state.users ?? []);
    currentUsers.removeWhere((user) => int.parse(user.id) == userId);

    emit(state.copyWith(users: currentUsers));
  }

  void _onUsers(List<UserDto> newUsers, {bool isSearch = false}) {
    print('newUsers: $newUsers');

    if (isSearch) {
      emit(state.copyWith(
        isInitial: false,
        users: newUsers,
        numberOfParticipants: Random().nextInt(10000),
      ));
      return;
    }

    final updatedUsers = List<UserDto>.from(state.users ?? []);

    for (var user in newUsers) {
      final existingIndex = updatedUsers.indexWhere((u) => u.id == user.id);

      if (existingIndex != -1) {
        updatedUsers[existingIndex] = updatedUsers[existingIndex].copyWith(
          name: user.name,
          email: user.email,
          online: user.online,
        );
      } else {
        updatedUsers.add(user);
      }
    }

    emit(state.copyWith(
      isInitial: false,
      users: updatedUsers,
      numberOfParticipants: Random().nextInt(10000),
    ));
  }

  void _onChats(List<ChatDto> newChats, {bool isSearch = false}) {
    List<ChatDto> updatedChats;

    if (isSearch) {
      updatedChats = newChats;
    } else {
      updatedChats = List.from(state.chats ?? []);
      for (var chat in newChats) {
        int existingIndex = updatedChats.indexWhere((c) => c.id == chat.id);

        if (existingIndex != -1) {
          updatedChats[existingIndex] = updatedChats[existingIndex].copyWith(
            lastMessage: chat.lastMessage,
            isOnline: chat.isOnline,
            haveUnread: chat.haveUnread,
            userStatus: chat.userStatus,
          );
        } else {
          updatedChats.add(chat);
        }
      }
    }

    final current = state.currentChat;
    if (current != null) {
      final updated =
          newChats.firstWhere((c) => c.id == current.id, orElse: () => current);
      emit(state.copyWith(
        currentChat: current.copyWith(
          isOnline: updated.isOnline,
          userStatus: updated.userStatus,
        ),
      ));
    }

    emit(state.copyWith(
      isLoading: false,
      chats: updatedChats,
    ));
  }

  void _onChatDetails(ChatDetailsDto chatDetails) async {
    final prefs = await SharedPreferences.getInstance();

    bool isPaginationActive =
        (chatDetails.messages.meta?['current_page'] ?? 1) > 1;

    final List<MessageDto> locallyUpdatedMessages =
        chatDetails.messages.messages.map((message) {
      final seen = prefs.getBool('message_seen_${message.id}') ?? false;
      return seen ? message.copyWith(seen: true) : message;
    }).toList();

    if (!isPaginationActive) {
      emit(state.copyWith(
        isInitialLoading: false,
        chatDetails: chatDetails.copyWith(
          messages: chatDetails.messages.copyWith(
            messages: locallyUpdatedMessages,
          ),
        ),
        chatMessages: locallyUpdatedMessages,
        unreadMessages: locallyUpdatedMessages
            .where((element) => element.seen == false)
            .length,
      ));
      return;
    }

    List<MessageDto> updatedMessages =
        List.from(state.chatDetails!.messages.messages);

    for (var newMessage in locallyUpdatedMessages) {
      int existingIndex =
          updatedMessages.indexWhere((m) => m.id == newMessage.id);

      if (existingIndex != -1) {
        updatedMessages[existingIndex] = newMessage;
      } else {
        updatedMessages.insert(0, newMessage);
      }
    }

    emit(state.copyWith(
      chatDetails: state.chatDetails!.copyWith(
        messages: state.chatDetails!.messages.copyWith(
          messages: updatedMessages,
          links: chatDetails.messages.links,
          meta: chatDetails.messages.meta,
        ),
      ),
      unreadMessages:
          updatedMessages.where((element) => element.seen == false).length,
    ));
  }

  Future<void> sendMessage(String msg, List<String> participantIds) async {
    chatUseCases.sendMessage(msg: msg, participantIds: participantIds);
  }

  // Future<void> sendMessageToUser(int senderId, String message, int participiantId ) {

  // }

  Future<void> setCurrentParticipant(UserDto user) async {
    chatUseCases.setCurrentParticipant(user);
    emit(state.copyWith(currentParticipant: user));
  }

  Future<void> setCurrentChat(ChatDto? chat) async {
    chatUseCases.setCurrentChat(chat);
    emit(state.copyWith(currentChat: chat));
  }

  Future<void> clearCurrentChat() async {
    chatUseCases.setCurrentChat(null);
    emit(state.clearCurrentChat());
  }

  Future<void> openDownloadMedia(int id, String fileName) async {
    chatUseCases.downloadMedia(id, fileName);
  }

  Future<void> loadChats(int page, int paginate, [String? search]) async {
    try {
      final chats = await chatUseCases.loadChats(page, paginate, search);

      print('chatsSearch: $chats');
      emit(state.copyWith(chats: chats));
    } catch (e) {
      print("Error loading chats: $e");
    }
  }

  Future<void> loadUsers(int page, int paginate, int companyId,
      [String? search]) async {
    try {
      final users =
          await chatUseCases.loadUsers(page, paginate, companyId, search);
      print('usersSSSS: $users');

      // _onUsers(users);
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  Future<void> deleteChat(int chatId, int userId) async {
    try {
      //Updated becasue of pagination on scroll//
      List<ChatDto> updatedChats = List.from(state.chats ?? []);
      updatedChats.removeWhere((chat) => chat.id == chatId);
      emit(state.copyWith(chats: updatedChats));
      await chatUseCases.deleteChat(chatId, userId);
    } catch (e) {
      print("❌ Error delete chat: $e");
    }
  }

  Future<void> getChatDetails(int? chatId, int page) async {
    try {
      final chatDetails = await chatUseCases.getChatDetails(chatId!, page);
      bool isNewChat = state.chatDetails?.chatId != chatId;
      emit(state.copyWith(
          chatDetails: chatDetails, isInitialLoading: isNewChat));
    } catch (e) {
      print("Error fetching chat details: $e");
    }
  }

  Future<void> chatSeen(int chatId) async {
    final updatedChats = List<ChatDto>.from(state.chats ?? []);

    final index = updatedChats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      updatedChats[index] = updatedChats[index].copyWith(haveUnread: false);
      emit(state.copyWith(chats: updatedChats));
    }
  }

  Future<void> getChatDetailsByParticipiant(
      int participiantId, int page) async {
    try {
      final chatDetails =
          await chatUseCases.getChatDetailsByParticipiant(participiantId, page);
      emit(state.copyWith(chatDetails: chatDetails, isInitialLoading: true));
    } catch (e) {
      print("Error while fetching chat by participiant: $e");
    }
  }

  Future<void> deleteChatMessage(int msgId, int chatId, int page) async {
    chatUseCases.chatDeleteMessage(msgId);
    final chatDetails = await chatUseCases.getChatDetails(chatId, page);
    emit(state.copyWith(chatDetails: chatDetails));
  }

  Future<void> editChatMessage(
      int msgId, String message, int chatId, int page) async {
    chatUseCases.chatEditMessage(msgId, message);
    final chatDetails = await chatUseCases.getChatDetails(chatId, page);
    emit(state.copyWith(chatDetails: chatDetails));
  }

  Future<void> removeUserFromGroup(int chatId, int userId, int page) async {
    chatUseCases.removeUserFromGroup(chatId, userId);
    final chatDetails = await chatUseCases.getChatDetails(chatId, page);
    emit(state.copyWith(chatDetails: chatDetails));
  }

  Future<void> addUserToGroupChat(
      int chatId, int userId, List<int> participantIds, int page) async {
    chatUseCases.addUserToGroup(chatId, userId, participantIds);
    final chatDetails = await chatUseCases.getChatDetails(chatId, page);
    emit(state.copyWith(chatDetails: chatDetails));
  }

  Future<void> chatMessageSeen(int msgId) async {
    chatUseCases.messageSeen(msgId: msgId);
    // state.chatMessages![index].seen = true;
    // final int unreadCount =
    //     state.chatMessages!.where((element) => element.seen == false).length;
    // emit(state.copyWith(unreadMessages: unreadCount));
  }

  void toggleEmojiVisibility() {
    emit(state.copyWith(isEmojiVisible: !(state.isEmojiVisible ?? false)));
  }

  void showEmoji(bool show) {
    emit(state.copyWith(isEmojiVisible: show));
  }

  void updateUploadProgress(double progress) {
    emit(state.copyWith(uploadProgress: progress));
  }

  Future<void> sendFile(String name, Uint8List bytes) async {
    chatUseCases.sendFile(name, bytes);
  }

  Future<void> chooseFile() async {
    chatUseCases.chooseFile();
  }

  Future<void> leaveRoom() async {
    chatUseCases.leaveRoom();
  }

  Future<void> sendChatMessage(
      {required String messageContent,
      List<PlatformFile>? uploadedFiles}) async {
    print('ChatId: ${state.chatDetails?.chatId}');
    var participiansList = !isInCallChat
        ? state.chatDetails!.chatParticipants.map((data) => data.id).toList()
        : state.participants!.map((data) => data.id).toList();

    chatUseCases.sendMessageToChatStream(
        chatId: state.chatDetails?.chatId,
        messageContent: messageContent,
        participantIds: participiansList,
        senderId: state.chatDetails!.authUser.id,
        uploadedFiles: uploadedFiles);
  }

  void _onVideoCall(Result result) {
    if (result.event == "incomingcall") {
      ;
      emit(state.copyWith(
          incomingCall: true,
          caller: state.users
              ?.firstWhere((element) => element.id == result.username)
              .name));
    }
    if (result.event == "calling") {
      emit(state.copyWith(calling: true));
    }

    if (result.event == "accepted") {
      emit(state.copyWith(calling: false, incomingCall: false));
    }

    if (result.event == "rejected") {
      print("change state to non call");
      emit(state.callFinished());
    }
  }

  Future<void> makeCall(String toUser) async {
    callUseCases.makeCall(toUser: toUser);
  }

  Future<void> answerCall() async {
    callUseCases.answerCall();
    emit(state.callFinished());
  }

  Future<void> rejectCall() async {
    callUseCases.rejectCall("click button");
    // emit(state.callFinished());
  }

  Future<void> audioMute() async {
    var mute = state.audioMuted;
    await callUseCases.mute(kind: 'audio', muted: !mute);
    emit(state.copyWith(audioMuted: !mute));
  }

  Future<void> videoMute() async {
    var mute = state.videoMuted;
    await callUseCases.mute(kind: 'video', muted: !mute);
    emit(state.copyWith(videoMuted: !mute));
  }

  void changeListType(ListType listType) {
    emit(state.copyWith(listType: listType));
  }

  Future<void> setUserStatus(String status) async {
    print("call setUserStatus from chat cubit");
    chatUseCases.setUserStatus(status);
  }
}
