import 'package:json_annotation/json_annotation.dart';
part 'data_channel_command.g.dart';

enum DataChannelCmd {
  publish('publish'),
  unPublish('unPublish'),
  engagement('engagement'),
  message('message'),
  muteById('muteById'),
  // trackStatus('trackStatus'),
  // askForTrackStatus('askForTrackStatus')
  userStatus('userStatus');

  const DataChannelCmd(this.value);
  final String value;
}


enum UserStatus {
  online('online'),
  offline('offline'),
  inTheCall('inTheCall');

  const UserStatus(this.value);
  final String value;
}


@JsonSerializable()
class DataChannelCommand{

  DataChannelCommand({
    required this.command,
    required this.id,
    this.data
  });

  @JsonKey(name: 'cmd')
  DataChannelCmd command;

  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'data')
  dynamic data;


  @override
  factory DataChannelCommand.fromJson(Map<String, dynamic> json) => _$DataChannelCommandFromJson(json);

  Map<String, dynamic> toJson() => _$DataChannelCommandToJson(this);
}