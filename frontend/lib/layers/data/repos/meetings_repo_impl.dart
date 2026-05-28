import 'package:cinteraction_vc/layers/data/dto/meetings/meeting_dto.dart';

import '../../domain/entities/api_response.dart';
import '../../domain/repos/meetings_repo.dart';

import '../../domain/source/api.dart';
import '../dto/meetings/meeting_response_dto.dart';
import '../source/network/api_impl.dart';

class MeetingRepoImpl extends MeetingRepo{

  MeetingRepoImpl({
    required Api api,
  }) : _api = api as ApiImpl;

  final ApiImpl _api;

  @override
  Future<ApiResponse<MeetingResponseDto?>> getListOfPastMeetings(int page) async{
    return await _api.getMeetings(page);
  }

  @override
  Future<ApiResponse<List<MeetingDto>?>>  getListOfScheduledMeetings() async{
    return await _api.getScheduledMeetings();
  }

}