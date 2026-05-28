import 'dart:typed_data';

import '../../repos/chat_repo.dart';

class SendFile {
  SendFile({required  this.repo});

  final ChatRepo repo;

  call(String name, Uint8List bytes){
    repo.sendFile(name, bytes);
  }
}