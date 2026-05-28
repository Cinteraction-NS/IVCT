import '../../../../core/app/injector.dart';
import '../../../data/dto/engagement_dto.dart';
import '../../entities/api_response.dart';
import '../../repos/dashboard_repo.dart';

class GetEngagementTotalAverageUseCase {
  GetEngagementTotalAverageUseCase();

  final DashboardRepo repo = getIt.get<DashboardRepo>();

  Future<ApiResponse<EngagementTotalAverageDto>> call({
    required int meetingId,
    required int moduleId,
  }) async {
    return repo.getEngagementTotalAverage(
        meetingId: meetingId, moduleId: moduleId);
  }
}
