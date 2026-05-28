import '../../data/dto/engagement_dto.dart';
import '../entities/api_response.dart';
import '../entities/dashboard/dashboard_response.dart';

abstract class DashboardRepo {
  Future<ApiResponse<DashboardResponse?>> getDashboardData();
  Future<ApiResponse<EngagementTotalAverageDto>> getEngagementTotalAverage({
    required int meetingId,
    required int moduleId,
  });
}
