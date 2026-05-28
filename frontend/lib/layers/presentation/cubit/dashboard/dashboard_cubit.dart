import 'package:cinteraction_vc/layers/data/dto/engagement_dto.dart';
import 'package:cinteraction_vc/layers/domain/entities/dashboard/dashboard_response.dart';
import 'package:cinteraction_vc/layers/domain/usecases/dashboard/dashboard_usecases.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/logger/loggy_types.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/api_response.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> with BlocLoggy {
  DashboardCubit({
    required DashboardUseCases dashboardUseCases,
  })  : _dashboardUseCases = dashboardUseCases,
        super(DashboardState.initial(
            meetingAttended: const [],
            durationsPerSession: const [],
            usersPerMeeting: const [])) {
    _init();
  }

  final DashboardUseCases _dashboardUseCases;

  void _init() async {
    getDashboardData();
  }

  void getDashboardData() async {
    emit(state.copyWith(loading: true));
    ApiResponse<DashboardResponse?> data =
        await _dashboardUseCases.getDashboardDataUseCase();

    List<double> meetingAttended = [];
    data.response?.meetingsAttended.meetings.forEach((element) {
      meetingAttended.add(element.value.toDouble());
    });

    List<double> avgSession = [];
    List<double> avgUser = [];
    data.response?.sessionDuration.meetings.forEach((element) {
      avgSession.add(element.duration.toDouble());
      avgUser.add(element.users.toDouble());
    });

    emit(state.copyWith(
      loading: false,
      meetingAttendedSum: data.response?.meetingsAttended.sum,
      meetingAttended: meetingAttended,
      usersPerMeeting: avgUser,
      durationsPerSession: avgSession,
      avgDurationPerSession:
          data.response!.sessionDuration.averageDuration.toInt(),
      avgUsersPerMeeting: data.response!.sessionDuration.averageUsers.toInt(),
      realizedMeetings: data.response?.realizedMeetings.realized,
      missedMeetings: data.response?.realizedMeetings.missed,
    ));
  }

  void getEngagementTotalAverage(
      {required int meetingId, required int moduleId}) async {
    print(
        '🔄 DashboardCubit: getEngagementTotalAverage called with meetingId: $meetingId, moduleId: $moduleId');
    emit(state.copyWith(engagementLoading: true));

    ApiResponse<EngagementTotalAverageDto> data =
        await _dashboardUseCases.getEngagementTotalAverageUseCase(
            meetingId: meetingId, moduleId: moduleId);

    print('🔄 DashboardCubit: API response received');
    print('🔄 Error: ${data.error}');
    print('🔄 Response: ${data.response}');

    if (data.error == null && data.response != null) {
      print('✅ Engagement data loaded successfully');

      loggy.info('Engagement data loaded successfully');
      emit(state.copyWith(
        engagementLoading: false,
        engagementData: data.response,
      ));
    } else {
      print('❌ Failed to load engagement data: ${data.error?.toString()}');
      loggy.error('Failed to load engagement data: ${data.error?.toString()}');
      emit(state.copyWith(engagementLoading: false));
    }
  }
}
