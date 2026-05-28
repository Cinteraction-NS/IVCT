class LastMessageDto {
  final int? id;
  final int? chatId;
  final int? senderId;
  final String? message;
  final List? filePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LastMessageDto({
    this.id,
    this.chatId,
    this.senderId,
    this.message,
    this.filePath,
    this.createdAt,
    this.updatedAt,
  });

  factory LastMessageDto.fromJson(Map<String, dynamic> json) => LastMessageDto(
        id: json['id'] as int?,
        chatId: json['chatId'] as int?,
        senderId: json['sender_id'] as int?,
        message: json['message'] as String?,
        filePath: json['files'] as List?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'chatId': chatId,
        'sender_id': senderId,
        'message': message,
        'file_path': filePath,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  LastMessageDto copyWith({
    int? id,
    int? chatId,
    int? senderId,
    String? message,
    List? filePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LastMessageDto(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
