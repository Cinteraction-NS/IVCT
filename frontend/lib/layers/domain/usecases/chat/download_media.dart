import '../../repos/chat_repo.dart';

class DownloadMedia {
  DownloadMedia({required this.repo});

  final ChatRepo repo;

  call(int id, String fileName) {
    repo.openDownloadedMedia(id, fileName);
  }
}
