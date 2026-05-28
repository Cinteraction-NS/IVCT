
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_event.dart';
import 'login_state.dart';


class LoginBloc extends Bloc<LoginEvent, LoginStates> {

  LoginBloc() : super(LoginStates.initial()) {
    on<DisplayNameChangedEvent>(onDisplayNameChanged);
    on<RoomIdChangedEvent>(onRoomIdChanged);
  }

  void onDisplayNameChanged(DisplayNameChangedEvent event, Emitter<LoginStates> emit) async {
    // emit(state.copyWith(displayName: event.displayName));
    // emit(HomepageStates.changedDisplay(event.displayName));
    // emit(HomepageStates.changedDisplay(event.displayName, state.roomId));
    emit(state.update(displayName: event.displayName));

  }

  void onRoomIdChanged(RoomIdChangedEvent event, Emitter<LoginStates> emit) async {
    // emit(state.copyWith(roomId: event.roomId));

    // emit(HomepageStates.changedRoomId(event.roomId, state.displayName));
    emit(state.update(roomId: event.roomId));
  }
}
