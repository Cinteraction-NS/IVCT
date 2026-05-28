import 'package:cinteraction_vc/core/util/util.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/io/network/models/participant.dart';
import '../../../data/dto/chat/chat_dto.dart';
import '../../../data/dto/chat/last_message_dto.dart';
import '../../../data/dto/user_dto.dart';
import '../../../domain/entities/chat_message.dart';

enum ListType { Chats, Users, Group }

class ChatState extends Equatable {
  final bool isLoading;
  final bool isInitial;
  final bool isInitialLoading;
  final List<Participant>? participants;

  final UserDto? currentParticipant;
  final ChatDto? currentChat;

  final List<UserDto>? users;
  final List<ChatMessage>? messages;
  final List<ChatDto>? chats;
  final List<MessageDto>? chatMessages;
  final ChatPagination? pagination;
  final UserListResponse? usersPagination;
  final ChatDetailsDto? chatDetails;
  final LastMessageDto? lastMessage;
  final int? stateIndex;
  final int unreadMessages;
  final bool incomingCall;
  final bool? calling;
  final String? caller;
  final bool audioMuted;
  final bool videoMuted;
  final ListType listType;
  final StreamRenderer? localStream;
  final StreamRenderer? remoteStream;
  final double uploadProgress;
  final bool isEmojiVisible;

  const ChatState({
    required this.isLoading,
    required this.isInitialLoading,
    required this.isInitial,
    this.messages,
    this.participants,
    this.stateIndex,
    required this.unreadMessages,
    this.incomingCall = false,
    this.caller,
    this.calling,
    this.localStream,
    this.remoteStream,
    this.currentParticipant,
    this.currentChat,
    this.users,
    this.chats,
    this.lastMessage,
    this.chatDetails,
    this.pagination,
    this.usersPagination,
    this.chatMessages,
    this.uploadProgress = 0.0,
    this.isEmojiVisible = false,
    required this.audioMuted,
    required this.videoMuted,
    required this.listType,
  });

  const ChatState.initial({
    bool isLoading = true,
    bool isInitial = true,
    bool isInitialLoading = true,
    int unreadMessages = 0,
    bool audioMuted = false,
    bool videoMuted = false,
    bool isEmojiVisible = false,
    ListType listType = ListType.Chats,
    ChatDetailsDto? chatDetails,
  }) : this(
          isLoading: isLoading,
          isInitial: isInitial,
          isInitialLoading: isInitialLoading,
          unreadMessages: unreadMessages,
          audioMuted: audioMuted,
          videoMuted: videoMuted,
          listType: listType,
          lastMessage: null,
          chatDetails: chatDetails,
          isEmojiVisible: isEmojiVisible,
        );

  @override
  List<Object?> get props => [
        isLoading,
        isInitial,
        isInitialLoading,
        participants,
        stateIndex,
        messages,
        chats,
        lastMessage,
        unreadMessages,
        incomingCall,
        caller,
        calling,
        localStream,
        remoteStream,
        currentParticipant,
        currentChat,
        users,
        audioMuted,
        videoMuted,
        listType,
        chatDetails,
        pagination,
        usersPagination,
        chatMessages,
        uploadProgress,
        isEmojiVisible,
      ];

  ChatState copyWith({
    bool? isLoading,
    bool? isInitial,
    bool? isInitialLoading,
    List<Participant>? participants,
    List<ChatMessage>? messages,
    List<ChatDto>? chats,
    LastMessageDto? lastMessage,
    int? numberOfParticipants,
    int? unreadMessages,
    bool? incomingCall,
    String? caller,
    bool? calling,
    bool? isEmojiVisible,
    StreamRenderer? localStream,
    StreamRenderer? remoteStream,
    UserDto? currentParticipant,
    ChatDetailsDto? chatDetails,
    ChatDto? currentChat,
    List<UserDto>? users,
    bool? audioMuted,
    bool? videoMuted,
    ListType? listType,
    ChatPagination? pagination,
    UserListResponse? usersPagination,
    List<MessageDto>? chatMessages,
    double? uploadProgress,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      isInitial: isInitial ?? this.isInitial,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      stateIndex: numberOfParticipants ?? this.stateIndex,
      messages: messages ?? this.messages,
      chats: chats ?? this.chats,
      lastMessage: lastMessage ?? this.lastMessage,
      participants: participants ?? this.participants,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      incomingCall: incomingCall ?? this.incomingCall,
      caller: caller ?? this.caller,
      calling: calling ?? this.calling,
      localStream: localStream ?? this.localStream,
      remoteStream: remoteStream ?? this.remoteStream,
      currentParticipant: currentParticipant ?? this.currentParticipant,
      currentChat: currentChat ?? this.currentChat,
      users: users ?? this.users,
      audioMuted: audioMuted ?? this.audioMuted,
      videoMuted: videoMuted ?? this.videoMuted,
      listType: listType ?? this.listType,
      chatDetails: chatDetails ?? this.chatDetails,
      pagination: pagination ?? this.pagination,
      usersPagination: usersPagination ?? this.usersPagination,
      chatMessages: chatMessages ?? this.chatMessages,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      isEmojiVisible: isEmojiVisible ?? this.isEmojiVisible,
    );
  }

  ChatState callFinished() {
    return ChatState(
      isLoading: isLoading,
      isInitial: isInitial,
      isInitialLoading: isInitialLoading,
      stateIndex: stateIndex,
      users: users,
      messages: messages,
      chats: chats,
      pagination: pagination,
      lastMessage: lastMessage,
      participants: participants,
      unreadMessages: unreadMessages,
      incomingCall: false,
      caller: "",
      calling: false,
      localStream: null,
      remoteStream: null,
      currentParticipant: currentParticipant,
      currentChat: currentChat,
      audioMuted: audioMuted,
      videoMuted: videoMuted,
      listType: ListType.Chats,
      chatDetails: chatDetails,
      chatMessages: chatMessages,
    );
  }


  ChatState clearCurrentChat() {
    return ChatState(
      isLoading: isLoading,
      isInitial: isInitial,
      isInitialLoading: isInitialLoading,
      stateIndex: stateIndex,
      users: users,
      messages: messages,
      chats: chats,
      pagination: pagination,
      lastMessage: lastMessage,
      participants: participants,
      unreadMessages: unreadMessages,
      incomingCall: incomingCall,
      caller: caller,
      calling: calling,
      localStream: localStream,
      remoteStream: remoteStream,
      currentParticipant: null,
      currentChat: null,
      audioMuted: audioMuted,
      videoMuted: videoMuted,
      listType: ListType.Chats,
      chatDetails: chatDetails,
      chatMessages: chatMessages,
    );
  }


}
