import '../../../../layers/domain/entities/chat_message.dart';

class Participant {
  Participant({
    required this.id,
    required this.display,
    this.publisher = false,
    this.talking = false,
    List<String>? deviceId,
    List<ChatMessage>? messages,
  })  : deviceId = deviceId ?? [],
        messages = messages ?? [];

  int id;
  String display;
  bool publisher;
  bool talking;

  // Not serialized
  List<String> deviceId;

  // Not included in serialization; could be added if needed
  List<ChatMessage> messages;

  bool haveUnreadMessages = false;

  bool get isOnline => deviceId.isNotEmpty;

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'] as int,
      display: json['display'] as String,
      publisher: json['publisher'] as bool? ?? false,
      talking: json['talking'] as bool? ?? false,
      // deviceId is excluded from JSON, handled separately
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display': display,
      'publisher': publisher,
      'talking': talking,
      // deviceId is excluded from JSON
    };
  }
}
