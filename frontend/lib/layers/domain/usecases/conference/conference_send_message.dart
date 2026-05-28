import 'package:file_picker/file_picker.dart';

import '../../repos/conference_repo.dart';

class ConferenceSendMessage {
  ConferenceSendMessage({required this.repo});

  final ConferenceRepo repo;

  call(
    String msg,
    List<PlatformFile>? uploadedFiles,
  ) {
    repo.sendMessage(msg, uploadedFiles: uploadedFiles);
  }
}
