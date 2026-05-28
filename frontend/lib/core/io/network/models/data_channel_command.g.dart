// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_channel_command.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataChannelCommand _$DataChannelCommandFromJson(Map<String, dynamic> json) =>
    DataChannelCommand(
      command: $enumDecode(_$DataChannelCmdEnumMap, json['cmd']),
      id: json['id'] as String,
      data: json['data'],
    );

Map<String, dynamic> _$DataChannelCommandToJson(DataChannelCommand instance) =>
    <String, dynamic>{
      'cmd': _$DataChannelCmdEnumMap[instance.command]!,
      'id': instance.id,
      'data': instance.data,
    };

const _$DataChannelCmdEnumMap = {
  DataChannelCmd.publish: 'publish',
  DataChannelCmd.unPublish: 'unPublish',
  DataChannelCmd.engagement: 'engagement',
  DataChannelCmd.message: 'message',
  DataChannelCmd.muteById: 'muteById',
  DataChannelCmd.userStatus: 'userStatus',
  // DataChannelCmd.trackStatus: 'trackStatus',
  // DataChannelCmd.askForTrackStatus: 'askForTrackStatus',
};
