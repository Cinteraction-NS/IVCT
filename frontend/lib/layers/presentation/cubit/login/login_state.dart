import 'package:equatable/equatable.dart';

// class HomepageStates extends Equatable {
//   final int roomId;
//   final String displayName;
//
//   const HomepageStates({required this.roomId, required this.displayName});
//
//
//   static HomepageStates initial() =>  const HomepageStates(
//     roomId: 1234567,
//     displayName: '',
//   );
//
//
//   @override
//   List<Object> get props => [];
//
//   HomepageStates copyWith({
//     int? roomId,
//     String? displayName,
//   }) =>
//      HomepageStates(
//             roomId: roomId ?? this.roomId,
//             displayName: displayName ?? this.displayName
//     );
// }

class LoginStates {
  final int roomId;
  final String displayName;


  const LoginStates({required this.roomId, required this.displayName});

  LoginStates.initial()
      : roomId = 1234567,
        displayName = '';

  LoginStates.changedRoomId(this.roomId, this.displayName);
  LoginStates.changedDisplay(this.displayName, this.roomId);


  LoginStates update({
    int? roomId,
    String? displayName,
  }) {
    return
      LoginStates(
          roomId: roomId ?? this.roomId,
          displayName: displayName ?? this.displayName
      );
  }

}
