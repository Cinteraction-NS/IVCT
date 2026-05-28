import 'dart:typed_data';

import '../../repos/chat_repo.dart';

class ChooseFile {
  ChooseFile({required  this.repo});

  final ChatRepo repo;

  call(){
    repo.chooseFile();
  }
}