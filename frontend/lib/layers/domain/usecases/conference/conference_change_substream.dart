
import '../../../../core/janus/janus_client.dart';
import '../../../../core/util/util.dart';
import '../../repos/conference_repo.dart';

class ConferenceChangeSubStream {

  ConferenceChangeSubStream({required  this.repo});

  final ConferenceRepo repo;


  call( ConfigureStreamQuality quality, StreamRenderer remoteStream) {
    repo.changeSubStream(quality: quality, remoteStream: remoteStream);
  }
}
