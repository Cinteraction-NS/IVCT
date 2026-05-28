class LoginEvent{}
class DisplayNameChangedEvent extends LoginEvent{
  final String displayName;
  DisplayNameChangedEvent(this.displayName);
}
class RoomIdChangedEvent extends LoginEvent{
  final int roomId;
  RoomIdChangedEvent(this.roomId);
}