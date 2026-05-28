import 'package:cinteraction_vc/layers/domain/entities/participant.dart';

class ParticipantDto extends Participant {
  ParticipantDto({required super.id, required super.display});

  factory ParticipantDto.fromJson(Map<String, dynamic> json) => ParticipantDto(
        id: json['id'] as int,
        display: json['display'] as String,
      )
        ..publisher = json['publisher'] as bool
        ..talking = json['talking'] as bool;

  Map<String, dynamic> toJson(ParticipantDto instance) => <String, dynamic>{
        'id': instance.id,
        'display': instance.display,
        'publisher': instance.publisher,
        'talking': instance.talking,
      };
}
