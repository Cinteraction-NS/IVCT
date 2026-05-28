import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_event.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/user_event.dart';
import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:cinteraction_vc/layers/domain/repos/chat_repo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webrtc_interface/webrtc_interface.dart';
import '../../../core/app/injector.dart';
import '../../../core/io/network/models/data_channel_command.dart';
import '../../../core/io/network/models/participant.dart';
import '../../../core/janus/janus_client.dart';
import '../../../core/util/util.dart';
import '../../domain/entities/user.dart';
import '../../domain/source/api.dart';
import '../../presentation/cubit/chat/chat_cubit.dart';
import '../dto/chat/last_message_dto.dart';
import '../source/local/local_storage.dart';
import 'package:uuid/uuid.dart';

class ChatRepoImpl extends ChatRepo {
  ChatRepoImpl({required Api api}) : _api = api;
  User? user = getIt.get<LocalStorage>().loadLoggedUser();

  final Api _api;
  int room = 1234;

  late String myId = user?.id ?? "";
  late String displayName = user?.name ?? 'User $myId';

  // late JanusClient client;
  late JanusSession _session;
  late JanusTextRoomPlugin textRoom;

  AudioPlayer audioPlayer = AudioPlayer();

  VideoRoomPluginStateManager videoState = VideoRoomPluginStateManager();

  final _participantsStream = StreamController<List<Participant>>.broadcast();

  final _usersStream = StreamController<UserEvent>.broadcast();

  final _chatStream = StreamController<ChatEvent>.broadcast();

  final _chatDetailsStream = StreamController<ChatDetailsDto>.broadcast();

  final _paginationStream = StreamController<ChatPagination>.broadcast();

  final _usersPaginationStream = StreamController<UserListResponse>.broadcast();

  final _messagesStream = StreamController<List<MessageDto>>.broadcast();

  List<Participant> subscribers = [];
  List<UserDto> users = [];

  late ChatDetailsDto chatDetailsDto;

  UserDto? currentParticipant;
  List<MessageDto> messages = [];

  ChatDto? currentChat;

  List<ChatDto> chats = [];

  late bool isInCallChat;

  late String userStatus = UserStatus.online.value;

  @override
  Future<void> initialize(
      {required int chatGroupId, required bool isInCall}) async {
    chatDetailsDto = ChatDetailsDto(
        chatId: 0,
        chatName: "chatName",
        authUser: ChatParticipantDto(
            id: 0, image: 'image', name: 'name', email: 'email'),
        chatParticipants: [],
        messages: ChatPaginationDto(messages: []));
    room = chatGroupId;
    isInCallChat = isInCall;
    _session = await getIt.getAsync<JanusSession>();
    await _attachPlugin();
    if (!isInCall) {
      loadUsers(1, 20, user!.companyId!);
      loadChats(1, 20);
    }
    _setup();

    print("initialize chat");
  }

  @override
  Stream<List<Participant>> getParticipantsStream() {
    return _participantsStream.stream;
  }

  @override
  Stream<UserEvent> getUsersStream() {
    return _usersStream.stream;
  }

  @override
  Stream<ChatEvent> getChatsStream() {
    return _chatStream.stream.map((chats) {
      return chats;
    });
  }

  @override
  Stream<ChatDetailsDto> getChatDetailsStream() {
    return _chatDetailsStream.stream;
  }

  @override
  Stream<ChatPagination> getPaginationStream() {
    return _paginationStream.stream;
  }

  @override
  Stream<UserListResponse> getUsersPaginationStream() {
    return _usersPaginationStream.stream;
  }

  @override
  Stream<List<MessageDto>> getMessageStream() {
    return _messagesStream.stream;
  }

  void unreadMessageSound() async {
    try {
      await audioPlayer.setSource(AssetSource('notification_message.mp3'));
      audioPlayer.resume();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  _editRoom() async {
    var exist = await textRoom.editRoom();
  }

  _checkRoom(int id) async {
    var exist = await textRoom.exists(id);
    print(exist);
    // JanusEvent event = JanusEvent.fromJson(exist);

    // print('room is exist: ${event.plugindata}');
    // if (event.plugindata?.data['exists'] == true) {
    if (exist!) {
      print('try to join publisher');
      await _joinRoom();
    } else {
      print('need to create the room');
      await _createRoom(id);
    }
  }

  _createRoom(int roomId) async {
    // Map<String, dynamic>? extras ={
    //   'publishers': maxPublishersDefault
    // };
    // var created = await textRoom.createRoom(roomId: room.toString(), adminKey: "supersecret", history: 10, isPrivate: false, description: "TestRoom", permanent: false, pin: "pin", secret: "secret", post: "https://7a2f-188-2-51-157.ngrok-free.app/api/message");
    // var created = await textRoom.createRoom(roomId: roomId);
    var payload = {"request": "create", "room": roomId};

    var created = await textRoom.send(data: payload);
    JanusEvent event = JanusEvent.fromJson(created);
    if (event.plugindata?.data['textroom'] == 'created') {
      await _joinRoom();
    } else {
      print('error creating room');
    }
  }

  _joinRoom() async {
    await textRoom.joinRoom(
      room,
      generateUniqueString(int.parse(user!.id)),
      display: displayName,
      pin: "",
    );
  }

  String generateUniqueString(int userId) {
    var uuid = const Uuid();
    return '$userId-${uuid.v4()}';
  }

  _attachPlugin() async {
    textRoom = await _session.attach<JanusTextRoomPlugin>();
  }

  _setup() async {
    await textRoom.setup();
    textRoom.onData?.listen((event) async {
      if (RTCDataChannelState.RTCDataChannelOpen == event) {
        _checkRoom(room);
        _setListener();
      }
    });
  }

  bool _haveUnread(List<MessageDto> messages) {
    for (var message in messages) {
      if (!message.seen) {
        return true;
      }
    }
    return false;
  }

  void _matchParticipantWithUser() {
    users = users.map((user) => user.copyWith(online: false)).toList();

    for (var subscriber in subscribers) {
      for (var i = 0; i < users.length; i++) {
        if (int.parse(users[i].id) == subscriber.id && subscriber.isOnline) {
          users[i] = users[i].copyWith(online: true);
        }
      }
    }

    _usersStream.add(UserEvent(
      users: users,
      isSearch: false,
    ));
  }

  void _matchParticipantWithChat(List<ChatDto> currentChats) {
    var updatedChats =
        currentChats.map((chat) => chat.copyWith(isOnline: false)).toList();

    for (var subscriber in subscribers) {
      for (var i = 0; i < updatedChats.length; i++) {
        bool isParticipantOnline = updatedChats[i].chatParticipants?.any(
                (data) => data.id == subscriber.id && subscriber.isOnline) ??
            false;
        if (isParticipantOnline) {
          updatedChats[i] = updatedChats[i].copyWith(isOnline: true);
        }
      }
    }

    chats = updatedChats;
    _chatStream.add(ChatEvent(chats: chats, isSearch: false));
  }

  _setListener() {
    textRoom.data?.listen((event) {
      // print("print event: ${event.text}");
      dynamic data = parse(event.text);

      if (data != null) {
        if (data['textroom'] == 'message') {
          // if (isInCallChat) {
          //   messages = chatDetailsDto.messages.messages;
          // }
          var senderId = int.parse(data['from'].split('-')[0]);
          final receviedMessage = data['text'] as String;
          final parsed = jsonDecode(receviedMessage);
          int? chatIdParsed = parsed['chatId'];
          int? msgIdParsed = parsed['msgId'];
          print('recevidedMsgId: $msgIdParsed');
          print('recevidedChatId: $chatIdParsed');
          try {
            Map<String, dynamic> result = jsonDecode(receviedMessage);
            var command = DataChannelCommand.fromJson(result);
            _renderCommand(command);
            return;
          } catch (e) {
            print(e.toString()); // Log raw message
          }

          String messageParsed = parsed['message'];
          if (messageParsed == '!@checkList') {
            loadChats(1, 20);
            return;
          }

          List<ChatParticipantDto> chatParticipants =
              chatDetailsDto.chatParticipants;
          ChatParticipantDto? matchedChat;

          if (chatParticipants.isNotEmpty) {
            try {
              matchedChat = chatParticipants.firstWhere(
                (item) => '${item.id}' == data['from'].split('-')[0],
              );

              //Added for unread chats//
            } catch (e) {
              for (var sub in subscribers) {
                for (var i = 0; i < chats.length; i++) {
                  if (chats[i]
                      .chatParticipants!
                      .any((datas) => datas.name == sub.display)) {
                    if (chats[i].id == chatIdParsed) {
                      chats[i] = chats[i].copyWith(
                        haveUnread: true,
                        lastMessage: LastMessageDto(
                          id: msgIdParsed,
                          message: messageParsed,
                          createdAt: DateTime.tryParse(data['date']),
                          chatId: chats[i].id,
                        ),
                      );
                    }

                    getChatMessages(chatIdParsed!);
                    if (!isInCallChat) {
                      unreadMessageSound();
                      _matchParticipantWithChat(chats);
                    }
                  }
                }
              }
            }
          }

          bool shouldShowInCurrentChat = matchedChat != null &&
              chatDetailsDto.chatId != null &&
              chatIdParsed == chatDetailsDto.chatId;

          if (!shouldShowInCurrentChat && chatIdParsed != null) {
            loadChats(1, 20);
          }

          if (shouldShowInCurrentChat) {
            final isFile = messageParsed.startsWith('http') &&
                messageParsed.contains('/storage/');

            final newMessage = MessageDto(
              id: msgIdParsed,
              chatId: chatDetailsDto.chatId!,
              senderId: senderId,
              createdAt: data['date'] as String,
              updatedAt: data['date'],
              message: isFile || messageParsed == '!@checkList'
                  ? null
                  : messageParsed,
              files: isFile
                  ? [
                      FileDto(
                          id: int.parse(RegExp(r'/storage/(\d+)/')
                                  .firstMatch(messageParsed)
                                  ?.group(1) ??
                              '0'),
                          path: messageParsed)
                    ]
                  : null,
            );

            final updatedMessages = ChatPaginationDto(
              messages: [
                ...chatDetailsDto.messages.messages,
                newMessage,
              ],
              links: chatDetailsDto.messages.links,
              meta: chatDetailsDto.messages.meta,
            );

            chatDetailsDto = ChatDetailsDto(
              chatName: chatDetailsDto.chatName,
              authUser: chatDetailsDto.authUser,
              chatId: chatDetailsDto.chatId,
              chatParticipants: chatDetailsDto.chatParticipants,
              messages: updatedMessages,
            );
            _chatDetailsStream.add(chatDetailsDto);
          }

          if (chatIdParsed != null) {
            getChatMessages(chatIdParsed);
          }

          _participantsStream.add((subscribers as List).cast<Participant>());
          _matchParticipantWithUser();
          // _matchParticipiantWithChat();
        }
        if (data['textroom'] == 'leave') {
          print('from: ${data['username']} Left The Chat!');

          String getUserId = data['username'].split('-')[0];

          var existingParticipants = subscribers
              .where((element) => element.id.toString() == getUserId)
              .toList();

          if (existingParticipants.isNotEmpty) {
            print("Participants found, removing deviceId...");

            for (var participant in existingParticipants) {
              participant.deviceId.remove(data['username']);

              if (participant.deviceId.isEmpty) {
                subscribers.remove(participant);
                print("Participant removed from subscribers.");
              }
            }
          }
          // getChatMessages(chatDetailsDto.chatId!);
          print("========= ${subscribers.length} ============");
          _participantsStream.add((subscribers as List).cast<Participant>());
          _matchParticipantWithUser();
          _matchParticipantWithChat(chats);
        }

        if (data['textroom'] == 'join') {
          if (isInCallChat) {
            getChatDetails(chatDetailsDto.chatId!, 1);
          }

          print('from: ${data['username']} Joined The Chat!');

          if (data['username'] == displayName) {
            return;
          }

          String getUserId = data['username'].split('-')[0];

          var existingParticipants = subscribers
              .where((element) => element.id.toString() == getUserId)
              .toList();

          if (existingParticipants.isEmpty) {
            print("There is no participant with this display name");
            var participant = Participant(
              display: data['display'],
              id: int.parse(getUserId),
              deviceId: [data['username']],
            );
            subscribers.add(participant);
          } else {
            for (var participant in existingParticipants) {
              if (!participant.deviceId.contains(data['username'])) {
                participant.deviceId.add(data['username']);
              }
            }
          }
          // getChatMessages(chatDetailsDto.chatId!);
          _participantsStream.add((subscribers as List).cast<Participant>());

          _matchParticipantWithUser();
          _matchParticipantWithChat(chats);

          _sendUserStatus();
        }

        if (data['participants'] != null) {
          for (var element in (data['participants'] as List<dynamic>)) {
            String getUserId = element['username'].split('-')[0];

            var existingParticipant = subscribers.firstWhere(
              (participant) => participant.id.toString() == getUserId,
              orElse: () {
                var newParticipant = Participant(
                  display: element['display'],
                  id: int.parse(getUserId),
                  deviceId: [element['username']],
                );
                subscribers.add(newParticipant);
                return newParticipant;
              },
            );

            if (!existingParticipant.deviceId.contains(element['username'])) {
              existingParticipant.deviceId.add(element['username']);
            }
          }

          _participantsStream.add((subscribers as List).cast<Participant>());
          _matchParticipantWithUser();
          _matchParticipantWithChat(chats);
        }
      }
    });
  }

  @override
  leaveRoom() async {
    try {
      await textRoom.leaveRoom(room);
      textRoom.dispose();
      _session.dispose();
    } catch (e) {
      print('no connection skipping $e');
    }
  }

  List<MessageDto> getChatMessages(int chatId) {
    messages = chatDetailsDto.messages.messages;
    _messagesStream.add(messages);

    return messages;
  }

  // @override
  // Future<void> sendMessage(String msg, int participiantId) async {
  //   // currentParticipant.display
  //   await _loadChats();
  //   await textRoom.sendMessage(room, msg, to: '$participiantId');
  //
  //   chatDetailsDto.messages.add(MessageDto(
  //       chatId: chatDetailsDto.chatId!,
  //       senderId: chatDetailsDto.authUser.id,
  //       message: msg,
  //       createdAt: DateTime.now().toIso8601String(),
  //       updatedAt: DateTime.now().toIso8601String()));
  //
  //   final updatedChatDetails = ChatDetailsDto(
  //     chatName: chatDetailsDto.chatName,
  //     authUser: chatDetailsDto.authUser,
  //     chatId: chatDetailsDto.chatId,
  //     chatParticipants: chatDetailsDto.chatParticipants,
  //     messages: [...chatDetailsDto.messages],
  //   );
  //
  //   _chatDetailsStream.add(updatedChatDetails);
  //   // var send =  await _api.sentChatMessage(text: msg, to: currentParticipant?.display, from: displayName);
  //
  //   // print(send);
  //   // getUserMessages()?.add(ChatMessage(
  //   //     message: msg,
  //   //     displayName: 'Me',
  //   //     time: DateTime.now(),
  //   //     avatarUrl: user!.imageUrl,
  //   //     seen: true));
  //   // _messagesStream.add(getUserMessages()!);
  // }

  @override
  Future<void> setCurrentParticipant(UserDto user) async {
    currentParticipant = user;
    // messages = getUserMessages()!;
    // _messagesStream.add(messages);
  }

  @override
  Future<void> messageSeen(int msgId) async {
    messages = chatDetailsDto.messages.messages;
    final updatedMessages = List<MessageDto>.from(messages);
    for (var i = 0; i < updatedMessages.length; i++) {
      if (updatedMessages[i].id == msgId) {
        updatedMessages[i] = updatedMessages[i].copyWith(seen: true);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('message_seen_$msgId', true);
        break;
      }
    }

    chatDetailsDto = chatDetailsDto.copyWith(
      messages: chatDetailsDto.messages.copyWith(messages: updatedMessages),
    );

    _chatDetailsStream.add(chatDetailsDto);
  }

  // void _updateChatWithDownloadedImage(int fileId, Uint8List imageBytes) {
  //   if (chatDetailsDto == null) return;
  //   FileDto newFile = FileDto(
  //     id: fileId,
  //     path: "data:image/jpeg;base64,${base64Encode(imageBytes)}",
  //   );

  //   MessageDto newMessage = MessageDto(
  //     chatId: chatDetailsDto.chatId!,
  //     senderId: chatDetailsDto.authUser.id,
  //     message: null,
  //     files: [newFile],
  //     createdAt: DateTime.now().toIso8601String(),
  //     updatedAt: DateTime.now().toIso8601String(),
  //   );

  //   final updatedChatDetails = ChatDetailsDto(
  //     chatName: chatDetailsDto.chatName,
  //     authUser: chatDetailsDto.authUser,
  //     chatId: chatDetailsDto.chatId,
  //     chatParticipants: chatDetailsDto.chatParticipants,
  //     messages: ChatPaginationDto(
  //       messages: [...chatDetailsDto.messages.messages, newMessage],
  //       links: chatDetailsDto.messages.links,
  //       meta: chatDetailsDto.messages.meta,
  //     ),
  //   );

  //   _chatDetailsStream.add(updatedChatDetails);
  // }
  @override
  loadUsers(int page, int paginate, int companyId, [String? search]) async {
    var response =
        await _api.getCompanyUsers(page, paginate, companyId, search);

    if (response.response != null) {
      var newUsers = response.response!.users
          .where((element) => element.id != myId)
          .toList();

      if (search == null || search.isEmpty) {
        if (page == 1) {
          users.clear();
        }
        users.addAll(newUsers);
      } else {
        // for search
        users = newUsers;
      }

      print('newUsers: $newUsers');
      _usersStream.add(UserEvent(
        users: users,
        isSearch: search != null && search.isNotEmpty,
      ));

      _usersPaginationStream.add(response.response!);
      _matchParticipantWithUser();
    }
  }

  /////////////CHAT API FUNCTIONS/////////////////

  @override
  loadChats(int page, int paginate, [String? search]) async {
    print('searchRepo: $search');
    var response =
        await _api.getAllChats(page: page, paginate: paginate, search: search);

    if (response.error == null) {
      ChatPagination pagination = response.response!;
      var newChats = pagination.chats;

      if (search == null || search.isEmpty) {
        if (page == 1) {
          chats.clear();
        }
        chats.addAll(newChats);
      } else {
        chats = newChats;
      }

      _chatStream.add(ChatEvent(
        chats: List.from(chats),
        isSearch: search != null && search.isNotEmpty,
      ));
      _paginationStream.add(pagination);
      _matchParticipantWithChat(chats);
    } else {
      print('Error: ${response.error}');
    }
  }

  @override
  deleteChat(int chatId, int userId) async {
    var response = await _api.deleteChat(chatId: chatId, userId: userId);
    if (response.error == null) {
      chats = response.response!;
      _chatStream.add(ChatEvent(chats: chats, isSearch: false));
      _matchParticipantWithChat(chats);
    } else {
      print('Error: ${response.error}');
    }
  }

  @override
  Future<void> setCurrentChat(ChatDto? chat) async {
    currentChat = chat;
    // messages = getUserMessages()!;
    // _messagesStream.add(messages);
  }

  @override
  Future<void> getChatDetails(int id, int page) async {
    try {
      var response = await _api.getChatById(id: id, page: page);
      if (response.error == null && response.response != null) {
        _chatDetailsStream.add(response.response!);
        chatDetailsDto = response.response!;
      } else {
        print("Error: ${response.error}");
      }
    } catch (e) {
      print("Error while fetching chat: $e");
    }
  }

  @override
  Future<void> getChatDetailsByParticipiant(int id, int page) async {
    try {
      var response = await _api.getChatByParticipiant(id: id, page: page);
      if (response.error == null && response.response != null) {
        _chatDetailsStream.add(response.response!);
        chatDetailsDto = response.response!;
      } else {
        print("Errors: ${response.error}");
      }
    } catch (e) {
      print("Error while fetching chat: $e");
    }
  }

  @override
  Future<void> deleteMessage(int id) async {
    try {
      var response = await _api.deleteMessageById(id: id);
      if (response.error == null && response.response != null) {
        _chatDetailsStream.add(response.response!);
        chatDetailsDto = response.response!;
      } else {
        print("Error: ${response.error}");
      }
    } catch (e) {
      print("Error while delete message: $e");
    }
  }

  @override
  Future<void> openDownloadedMedia(int id, String fileName) async {
    try {
      var response = await _api.downloadMedia(id: id);

      if (response.error == null) {
        Uint8List fileBytes = response.response!;

        if (fileBytes.isEmpty) {
          print("❌ Greška: Bajtovi fajla su prazni!");
          return;
        }

        if (kIsWeb) {
          final updatedMessages =
              chatDetailsDto.messages.messages.map((message) {
            final updatedFiles = message.files?.map((file) {
              if (file.id == id) {
                return FileDto(id: file.id, path: file.path, bytes: fileBytes);
              }
              return file;
            }).toList();

            return MessageDto(
              id: message.id,
              chatId: message.chatId,
              senderId: message.senderId,
              message: message.message,
              files: updatedFiles,
              createdAt: message.createdAt,
              updatedAt: message.updatedAt,
            );
          }).toList();

          final updatedChatDetails = ChatDetailsDto(
            chatId: chatDetailsDto.chatId,
            chatName: chatDetailsDto.chatName,
            authUser: chatDetailsDto.authUser,
            chatParticipants: chatDetailsDto.chatParticipants,
            messages: ChatPaginationDto(
              messages: updatedMessages ?? chatDetailsDto.messages.messages,
              links: chatDetailsDto.messages.links,
              meta: chatDetailsDto.messages.meta,
            ),
          );

          _chatDetailsStream.add(updatedChatDetails);
        }
      } else {
        print("Error while download: ${response.error}");
      }
    } catch (e) {
      print("Exception in openDownloadedMedia: $e");
    }
  }

  @override
  Future<void> editMessage(int id, String message) async {
    try {
      var response = await _api.editMessageById(id: id, message: message);
      if (response.error == null && response.response != null) {
        _chatDetailsStream.add(response.response!);
        chatDetailsDto = response.response!;
        // sendMessage(
        //     message,
        //     chatDetailsDto.chatParticipants
        //         .map((data) => data.id.toString())
        //         .toList(),
        //     chatId: chatDetailsDto.chatId,
        //     msgId: id);
      } else {
        print("Error: ${response.error}");
      }
    } catch (e) {
      print('Error while edit message: $e');
    }
  }

  @override
  Future<void> addUserOnGroupChat(
      int chatId, int userId, List<int> participantIds) async {
    try {
      var response = await _api.addUserToGroupChat(
          chatId: chatId, userId: userId, participantIds: participantIds);
      if (response.error == null && response.response != null) {
        _chatDetailsStream.add(response.response!);
        chatDetailsDto = response.response!;
        // print('test: ${participantIds.map((id) => id.toString()).toList()}');
        sendMessage(
            '!@checkList', participantIds.map((id) => id.toString()).toList());
      } else {
        print("Error: ${response.error}");
      }
    } catch (e) {
      print('Error while edit message: $e');
    }
  }

  @override
  Future<void> removeUserFromGroup(int chatId, int userId) async {
    try {
      var response =
          await _api.removeUserFromGroupChat(chatId: chatId, userId: userId);
      if (response.error == null && response.response != null) {
        _chatDetailsStream.add(response.response!);
        chatDetailsDto = response.response!;
      } else {
        print("Error: ${response.error}");
      }
    } catch (e) {
      print('Error while edit message: $e');
    }
  }

  @override
  Future<void> sendMessage(String? msg, List<String> participantIds,
      {int? chatId, int? msgId}) async {
    final matchingDeviceIds =
        subscribers.expand((subscriber) => subscriber.deviceId).where((device) {
      final firstPart = device.split('-').first;
      return participantIds.contains(firstPart);
    }).toList();
    final messagePayload = jsonEncode({
      "chatId": chatId,
      "message": msg,
      "msgId": msgId,
    });
    await textRoom.sendMessage(
      room,
      messagePayload,
      tos: matchingDeviceIds,
    );
  }

  @override
  Future<void> sendMessageToChatWrapper(String? name, int? chatId,
      String? messageContent, int senderId, List<int> participantIds,
      {List<PlatformFile>? uploadedFiles}) async {
    var response = await _api.sendMessageToChat(
      name: name,
      chatId: chatId,
      senderId: senderId,
      message: messageContent == '!@checkList' ? null : messageContent,
      participantIds: participantIds,
      uploadedFiles: uploadedFiles,
      onProgress: (double progress) {
        getIt.get<ChatCubit>().updateUploadProgress(progress);
      },
    );

    if (response.error == null && response.response != null) {
      print('response.response!.chatId: ${response.response!.chatId}');
      print('chatId: $chatId');
      if (chatId == null && response.response!.chatId != null) {
        chatDetailsDto = chatDetailsDto.copyWith(
          chatId: response.response!.chatId,
        );
        _chatDetailsStream.add(chatDetailsDto);
      } else {
        List<String> participants =
            participantIds.map((int value) => value.toString()).toList();

        int? finalChatId = response.response!.chatId;

        if (finalChatId != null) {
          sendMessage(
              response.response?.files?.isNotEmpty == true
                  ? response.response!.files![0].path
                  : messageContent,
              participants,
              chatId: finalChatId,
              msgId: response.response!.id);
        }
      }

      // if (messageContent == '!@checkList') {
      //   return;
      // }
      chatDetailsDto.messages.messages.add(MessageDto(
        chatId: response.response!.chatId,
        createdAt: response.response!.createdAt,
        message: response.response!.message,
        senderId: response.response!.senderId,
        updatedAt: DateTime.now().toIso8601String(),
        id: response.response!.id,
        files: response.response!.files is List<Map<String, dynamic>>
            ? (response.response!.files as List<Map<String, dynamic>>)
                .map((file) => FileDto.fromJson(file))
                .toList()
            : response.response!.files,
      ));
      final updatedChatDetails = ChatDetailsDto(
        chatName: chatDetailsDto.chatName,
        authUser: chatDetailsDto.authUser,
        chatId: response.response!.chatId,
        chatParticipants: chatDetailsDto.chatParticipants,
        messages: ChatPaginationDto(
          messages: [...chatDetailsDto.messages.messages],
          links: chatDetailsDto.messages.links,
          meta: chatDetailsDto.messages.meta,
        ),
      );

      _chatDetailsStream.add(updatedChatDetails);
      loadChats(1, 20);
    } else {
      print("Error: ${response.error}");
    }
  }

  //////////////////////////////////////

  @override
  Future<void> chooseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      // uploadImageToStorage(file.name, file.bytes);
    } else {
      // User canceled the picker
    }
  }

  uploadImageToStorage(String name, Uint8List? bytes) async {
    if (kIsWeb) {
      // Reference _reference = FirebaseStorage.instance
      //     .ref()
      //     .child('files/${Path.basename("$name")}');
      // await _reference.putData(bytes!).whenComplete(() async {
      //   await _reference.getDownloadURL().then((value) {
      //     // uploadedPhotoUrl = value;
      //
      //     print(value);
      //     // sendMessage(value);
      //   });
      // });
    } else {
//write a code for android or ios
    }
  }

  @override
  Future<void> sendFile(String name, Uint8List bytes) async {
    uploadImageToStorage(name, bytes);
  }

  _renderCommand(DataChannelCommand command) {
    if (command.command == DataChannelCmd.userStatus) {
      chats = chats.map((chat) {
        if (chat.chatParticipants!.any((p) => p.id == int.parse(command.id)) &&
            !chat.chatGroup) {
          return chat.copyWith(
              userStatus: command.data["userStatus"] as String);
        } else {
          return chat;
        }
      }).toList();
      _chatStream.add(ChatEvent(chats: chats, isSearch: false));
    }
  }

  @override
  Future<void> setUserStatus(String status) async {
    userStatus = status;
    _sendUserStatus();
  }

  _sendUserStatus() async {
    if (!isInCallChat) {
      var data = {'userStatus': userStatus};
      var json = DataChannelCommand(
          command: DataChannelCmd.userStatus,
          id: user!.id.toString(),
          data: data);

      await textRoom.sendMessage(room, jsonEncode(json.toJson()));
    }
  }
}
