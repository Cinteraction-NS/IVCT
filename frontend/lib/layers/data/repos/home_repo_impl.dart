import 'package:cinteraction_vc/layers/domain/entities/api_response.dart';
import 'package:cinteraction_vc/layers/domain/entities/meetings/meeting.dart';
import 'package:cinteraction_vc/layers/domain/repos/home_repo.dart';

import '../../domain/source/api.dart';

class HomeRepoImpl extends HomeRepo {
  HomeRepoImpl({
    required Api api,
  }) : _api = api;

  final Api _api;

  @override
  Future<ApiResponse<Meeting>> scheduleMeeting(
      {required String name,
      required String description,
      required String tag,
      required DateTime date,
      required List<String> emails}) async {
    var response = await _api.scheduleMeeting(
        name: name,
        description: description,
        tag: tag,
        date: date,
        emails: emails);
    return ApiResponse(response: response.response);
  }

  @override
  Future<ApiResponse<Meeting?>> getNextMeeting() async {
    return await _api.getNextMeeting();
  }
}
