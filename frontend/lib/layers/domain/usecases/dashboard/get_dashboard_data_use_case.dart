import '../../../../core/app/injector.dart';
import '../../entities/api_response.dart';
import '../../entities/dashboard/dashboard_response.dart';
import '../../repos/dashboard_repo.dart';

class GetDashboardDataUseCase {
  GetDashboardDataUseCase();

  final DashboardRepo repo = getIt.get<DashboardRepo>();

  Future<ApiResponse<DashboardResponse?>> call() async {
    return repo.getDashboardData();
  }
}
