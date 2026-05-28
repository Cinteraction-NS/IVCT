import '../entities/api_response.dart';
import '../entities/meetings/meeting.dart';

abstract class HomeRepo {
  Future<ApiResponse<Meeting>> scheduleMeeting({
    required String name,
    required String description,
    required String tag,
    required DateTime date,
    required List<String> emails,
  });

  Future<ApiResponse<Meeting?>> getNextMeeting();
}
