import 'dart:async';

import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/layers/domain/entities/api_response.dart';
import 'package:cinteraction_vc/layers/domain/usecases/home/home_use_cases.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/meetings/meetings_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/logger/loggy_types.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/meetings/meeting.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> with BlocLoggy {
  HomeCubit({required this.homeUseCases})
      : super(HomeState.initial(
            scheduleDate: DateTime.now()
                .copyWith(minute: 0)
                .add(const Duration(hours: 2)))) {
    init();
  }

  final HomeUseCases homeUseCases;

  void init() {
    print('Called Init');
    getNextMeeting();
  }

  void getNextMeeting() async {
    emit(state.copyWith(loading: true));
    print('Initilized');

    var response = await homeUseCases.getNextMeetingUseCase();

    final meeting = response.response;
    print('nextMeetingTest: ${meeting?.eventName}');

    emit(state.copyWith(nextMeeting: meeting, loading: false));
  }

  void clearNextMeeting() {
    emit(state.copyWith(nextMeeting: null));
  }

  void setScheduleDate(DateTime date) {
    emit(state.copyWith(scheduleDate: date));
  }

  void setScheduleTime(TimeOfDay? timeOfDay) {
    emit(state.copyWith(
        scheduleDate: state.scheduleStartDateTime
            ?.copyWith(hour: timeOfDay?.hour, minute: timeOfDay?.minute)));
  }

  Future<ApiResponse<Meeting>> scheduleMeeting(
      String name, String desc, String tag, List<String> emails) async {
    emit(state.copyWith(loading: true));

    final response = await homeUseCases.scheduleMeetingUseCase(
      name,
      desc,
      tag,
      state.scheduleStartDateTime!,
      emails,
    );

    print('API returned: ${response.response}');
    emit(state.copyWith(loading: false, nextMeeting: response.response));

    getNextMeeting();

    return response;
  }
}
