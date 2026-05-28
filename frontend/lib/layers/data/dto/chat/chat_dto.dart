import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import '../../../../core/io/network/models/data_channel_command.dart';
import 'last_message_dto.dart';

class ChatDto {
  final int id;
  final String name;
  final String? userImage;
  final LastMessageDto? lastMessage;
  final List<ChatParticipantDto>? chatParticipants;
  final int currentPage;
  final int lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;
  final DateTime? createdAt;
  bool isOnline;
  String userStatus;
  bool haveUnread;
  final bool chatGroup;

  ChatDto({
    required this.id,
    required this.name,
    this.userImage,
    this.lastMessage,
    this.chatParticipants,
    this.currentPage = 1,
    this.lastPage = 1,
    this.nextPageUrl,
    this.prevPageUrl,
    this.createdAt,
    this.isOnline = false,
    this.haveUnread = false,
    this.userStatus = "offline",
    required this.chatGroup,
  });

  ChatDto copyWith({
    int? id,
    String? name,
    String? userImage,
    LastMessageDto? lastMessage,
    List<ChatParticipantDto>? chatParticipants,
    int? currentPage,
    int? lastPage,
    String? nextPageUrl,
    String? prevPageUrl,
    DateTime? createdAt,
    bool? isOnline,
    bool? haveUnread,
    bool? chatGroup,
    String? userStatus,
  }) {
    return ChatDto(
      id: id ?? this.id,
      name: name ?? this.name,
      userImage: userImage ?? this.userImage,
      lastMessage: lastMessage ?? this.lastMessage,
      chatParticipants: chatParticipants ?? this.chatParticipants,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      nextPageUrl: nextPageUrl ?? this.nextPageUrl,
      prevPageUrl: prevPageUrl ?? this.prevPageUrl,
      createdAt: createdAt ?? this.createdAt,
      isOnline: isOnline ?? this.isOnline,
      haveUnread: haveUnread ?? this.haveUnread,
      chatGroup: chatGroup ?? this.chatGroup,
      userStatus: userStatus ?? this.userStatus,
    );
  }

  factory ChatDto.fromJson(Map<String, dynamic> json) {
    return ChatDto(
      id: json['chat_id'] as int,
      name: json['chat_name'] as String,
      userImage: json['user_image'] as String?,
      lastMessage: (json['last_message'] != null &&
              json['last_message'] is Map<String, dynamic> &&
              json['last_message'].isNotEmpty)
          ? LastMessageDto.fromJson(json['last_message'])
          : null,
      chatParticipants: json['chat_participants'] != null
          ? (json['chat_participants'] as List)
              .map((participant) => ChatParticipantDto.fromJson(participant))
              .toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      currentPage: json['meta']?['current_page'] as int? ?? 1,
      lastPage: json['meta']?['last_page'] as int? ?? 1,
      nextPageUrl: json['links']?['next'] as String?,
      prevPageUrl: json['links']?['prev'] as String?,
      chatGroup: json['chat_group'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'chat_id': id,
        'chat_name': name,
        'user_image': userImage,
        'last_message': lastMessage?.toJson(),
        'chat_participants': chatParticipants?.map((p) => p.toJson()).toList(),
        'created_at': createdAt?.toIso8601String(),
        'meta': {
          'current_page': currentPage,
          'last_page': lastPage,
        },
        'links': {
          'next': nextPageUrl,
          'prev': prevPageUrl,
        },
        'chat_group': chatGroup,
        'userStatus': userStatus,
      };

  @override
  String toString() {
    return 'ChatDto(id: $id, name: $name, userImage: $userImage, lastMessage: $lastMessage, chatParticipants: $chatParticipants, createdAt: $createdAt, currentPage: $currentPage, lastPage: $lastPage, nextPageUrl: $nextPageUrl, prevPageUrl: $prevPageUrl, isOnline: $isOnline, chatGroup: $chatGroup, haveUnread: $haveUnread, userStatus: $userStatus )';
  }


  String getChatName()
  {
    if(chatGroup && name == "Meeting Group")
    {
      final participants = chatParticipants
          ?.map((e) => e.name)
          .join(', ') ?? '';
      return "Meeting with $participants";
    }
    return name;
  }
}

class ChatPagination {
  final List<ChatDto> chats;
  final int currentPage;
  final int lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  ChatPagination({
    required this.chats,
    required this.currentPage,
    required this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory ChatPagination.fromJson(Map<String, dynamic> json) => ChatPagination(
        chats: (json['data'] as List)
            .map((chat) => ChatDto.fromJson(chat))
            .toList(),
        currentPage: json['meta']?['current_page'] as int? ?? 1,
        lastPage: json['meta']?['last_page'] as int? ?? 1,
        nextPageUrl: json['links']?['next'] as String?,
        prevPageUrl: json['links']?['prev'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'data': chats.map((chat) => chat.toJson()).toList(),
        'meta': {
          'current_page': currentPage,
          'last_page': lastPage,
        },
        'links': {
          'next': nextPageUrl,
          'prev': prevPageUrl,
        },
      };
}
