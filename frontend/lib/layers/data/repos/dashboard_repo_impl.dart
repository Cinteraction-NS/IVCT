import 'package:cinteraction_vc/layers/data/dto/engagement_dto.dart';
import 'package:cinteraction_vc/layers/domain/entities/api_response.dart';
import 'package:cinteraction_vc/layers/domain/entities/dashboard/dashboard_response.dart';
import 'package:cinteraction_vc/layers/domain/repos/dashboard_repo.dart';

import '../../domain/source/api.dart';

class DashboardRepoImpl extends DashboardRepo {
  DashboardRepoImpl({
    required Api api,
  }) : _api = api;

  final Api _api;

  @override
  Future<ApiResponse<DashboardResponse?>> getDashboardData() {
    return _api.getDashboardData();
  }

  @override
  Future<ApiResponse<EngagementTotalAverageDto>> getEngagementTotalAverage({
    required int meetingId,
    required int moduleId,
  }) {
    return _api.getEngagementTotalAverage(
        meetingId: meetingId, moduleId: moduleId);
  }
}
