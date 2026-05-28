import 'dart:typed_data';

import 'package:intl/intl.dart';

import '../../../presentation/ui/profile/ui/widget/user_image.dart';

class ChatParticipantDto {
  final int id;
  final String image;
  final String name;
  final String email;
  bool isOnline;

  ChatParticipantDto({
    required this.id,
    required this.image,
    required this.name,
    required this.email,
    this.isOnline = false,
  });

  factory ChatParticipantDto.fromJson(Map<String, dynamic> json) =>
      ChatParticipantDto(
        id: json['id'] as int,
        image: json['image'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'name': name,
        'email': email,
      };

  @override
  String toString() {
    return 'ChatParticipantDto(id: $id, image: $image, name: $name, email: $email, isOnline: $isOnline)';
  }


  UserImageDto getUserImageDTO()
  {
    return UserImageDto(
        id: id,
        name: name,
        imageUrl: image
    );
  }
}

class FileDto {
  final int id;
  final String path;
  final Uint8List? bytes;

  FileDto({required this.id, required this.path, this.bytes});

  FileDto copyWith({String? path, Uint8List? bytes}) {
    return FileDto(
      id: id,
      path: path ?? this.path,
      bytes: bytes ?? this.bytes,
    );
  }

  factory FileDto.fromJson(Map<String, dynamic> json) => FileDto(
        id: json['id'] as int? ?? 0,
        path: json['path'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'path': path,
      };

  @override
  String toString() {
    return 'FileDto(id: $id, path: $path, bytes: ${bytes != null ? "Loaded" : "Not Loaded"})';
  }
}

class MessageDto {
  final int? id;
  final int chatId;
  final int senderId;
  final String? message;
  final List<FileDto>? files;


  String? _createdAt = '';
  String get createdAt => _createdAt ?? "";
  set createdAt(String? createdAt) {

    var date = DateTime.parse(createdAt!);
      _createdAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  final String updatedAt;
  bool seen;

  MessageDto({
    this.id,
    required this.chatId,
    required this.senderId,
    this.message,
    this.files,
    String? createdAt,
    required this.updatedAt,
    this.seen = false,
  }){
    this.createdAt = createdAt;
  }

  MessageDto copyWith({
    int? id,
    int? chatId,
    int? senderId,
    String? message,
    List<FileDto>? files,
    String? createdAt,
    String? updatedAt,
    bool? seen,
  }) {
    return MessageDto(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      files: files ?? this.files,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      seen: seen ?? this.seen,
    );
  }

  factory MessageDto.fromJson(Map<String, dynamic> json) => MessageDto(
        id: json['id'] as int? ?? 0,
        chatId: json['chat_id'] as int? ?? 0,
        senderId: json['sender_id'] as int? ?? 0,
        message: json['message'] as String?,
        files: (json['files'] as List<dynamic>?)
            ?.map((file) => FileDto.fromJson(file as Map<String, dynamic>))
            .toList(),
        createdAt: json['created_at'] as String? ?? '',
        updatedAt: json['updated_at'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'chat_id': chatId,
        'sender_id': senderId,
        'message': message,
        'files': files?.map((file) => file.toJson()).toList(),
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  @override
  String toString() {
    return 'MessageDto(id: $id, chatId: $chatId, senderId: $senderId, message: $message, files: $files, createdAt: $createdAt, updatedAt: $updatedAt, seen: $seen)';
  }
}

class ChatPaginationDto {
  final List<MessageDto> messages;
  final Map<String, dynamic>? links;
  final Map<String, dynamic>? meta;

  ChatPaginationDto({
    required this.messages,
    this.links,
    this.meta,
  });

  ChatPaginationDto copyWith({
    List<MessageDto>? messages,
    Map<String, dynamic>? links,
    Map<String, dynamic>? meta,
  }) {
    return ChatPaginationDto(
      messages: messages ?? this.messages,
      links: links ?? this.links,
      meta: meta ?? this.meta,
    );
  }

  factory ChatPaginationDto.fromJson(Map<String, dynamic> json) {
    return ChatPaginationDto(
      messages: (json['data'] as List<dynamic>)
          .map(
              (message) => MessageDto.fromJson(message as Map<String, dynamic>))
          .toList(),
      links: json['links'] as Map<String, dynamic>?,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': messages.map((message) => message.toJson()).toList(),
      'links': links,
      'meta': meta,
    };
  }
}

class ChatDetailsDto {
  final int? chatId;
  final String? chatName;
  final ChatParticipantDto authUser;
  final List<ChatParticipantDto> chatParticipants;
  final ChatPaginationDto messages;
  final bool isGroup;
  bool haveUnreadMessages;

  ChatDetailsDto({
    required this.chatId,
    required this.chatName,
    required this.authUser,
    required this.chatParticipants,
    required this.messages,
    this.isGroup = false,
    this.haveUnreadMessages = false,
  });

  ChatDetailsDto copyWith({
    int? chatId,
    String? chatName,
    ChatParticipantDto? authUser,
    List<ChatParticipantDto>? chatParticipants,
    ChatPaginationDto? messages,
    bool? isGroup,
  }) {
    return ChatDetailsDto(
      chatId: chatId ?? this.chatId,
      chatName: chatName ?? this.chatName,
      authUser: authUser ?? this.authUser,
      chatParticipants: chatParticipants ?? this.chatParticipants,
      messages: messages ?? this.messages,
      isGroup: isGroup ?? this.isGroup,
    );
  }

  factory ChatDetailsDto.fromJson(Map<String, dynamic> json) {
    return ChatDetailsDto(
      chatId: json['chat_id'] as int?,
      chatName: json['chat_name'] as String?,
      authUser: ChatParticipantDto.fromJson(json['auth_user']),
      chatParticipants: (json['chat_participants'] as List<dynamic>)
          .map((participant) =>
              ChatParticipantDto.fromJson(participant as Map<String, dynamic>))
          .toList(),
      messages: ChatPaginationDto.fromJson(json['messages']),
      isGroup: (json['chat_group'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'chat_name': chatName,
      'auth_user': authUser.toJson(),
      'chat_participants': chatParticipants.map((p) => p.toJson()).toList(),
      'messages': messages.toJson(),
      'chat_group': isGroup,
    };
  }

  @override
  String toString() {
    return 'ChatDetailsDto(chatId: $chatId, chatName: $chatName, authUser: $authUser, chatParticipants: $chatParticipants, messages: $messages, isGroup: $isGroup, haveUnreadMessages: $haveUnreadMessages)';
  }
}
