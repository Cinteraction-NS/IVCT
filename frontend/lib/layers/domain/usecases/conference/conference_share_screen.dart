

import 'package:webrtc_interface/webrtc_interface.dart';

import '../../repos/conference_repo.dart';

class ConferenceShareScreen {

  ConferenceShareScreen({required  this.repo});

  final ConferenceRepo repo;

  call( ) {
    repo.shareScreen();
  }
}
