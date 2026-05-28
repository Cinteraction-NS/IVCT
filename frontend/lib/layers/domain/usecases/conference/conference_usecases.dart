import 'package:cinteraction_vc/layers/domain/usecases/conference/conference_end_stream.dart';
import 'package:cinteraction_vc/layers/domain/usecases/conference/conference_share_screen.dart';
import 'package:cinteraction_vc/layers/domain/usecases/conference/conference_subscribers_stream.dart';
import 'package:cinteraction_vc/layers/domain/usecases/conference/dispose_screen_sharing_stream.dart';

import '../../../../core/app/injector.dart';
import '../../repos/conference_repo.dart';
import 'conference_change_substream.dart';
import 'conference_finish_call.dart';
import 'conference_get_engagement_stream.dart';
import 'conference_get_participants.dart';
import 'conference_get_renderer_stream.dart';
import 'conference_get_screenshare_stream.dart';
import 'conference_hand_up.dart';
import 'conference_initialize.dart';
import 'conference_kick.dart';
import 'conference_messages_stream.dart';
import 'conference_mute.dart';
import 'conference_mute_by_id.dart';
import 'conference_ping.dart';
import 'conference_publish.dart';
import 'conference_publish_by_id.dart';
import 'conference_send_message.dart';
import 'conference_start_call.dart';
import 'conference_start_recording.dart';
import 'conference_stop_recording.dart';
import 'conference_switch_camera.dart';
import 'conference_toast_message.dart';
import 'conference_toggle_engagement.dart';
import 'conference_unpublish.dart';
import 'conference_unpublish_by_id.dart';
import 'conference_user_talking_stream.dart';

class ConferenceUseCases {
  ConferenceUseCases({required this.repo})
      : conferenceInitialize = ConferenceInitialize(repo: repo),
        getRendererStream = GetRendererStream(repo: repo),
        getEndStream = GetEndStream(repo: repo),
        getSubscriberStream = GetSubscriberStream(repo: repo),
        finishCall = ConferenceFinishCall(repo: repo),
        mute = ConferenceMute(repo: repo),
        changeSubStream = ConferenceChangeSubStream(repo: repo),
        getParticipants = ConferenceGetParticipants(repo: repo),
        kick = ConferenceKick(repo: repo),
        unPublish = ConferenceUnPublish(repo: repo),
        ping = ConferencePing(repo: repo),
        toggleEngagement = ConferenceToggleEngagement(repo: repo),
        publish = ConferencePublish(repo: repo),
        switchCamera = ConferenceSwitchCamera(repo: repo),
        unPublishById = ConferenceUnPublishById(repo: repo),
        publishById = ConferencePublishById(repo: repo),
        shareScreen = ConferenceShareScreen(repo: repo),
        getAvgEngagementStream = GetAvgEngagementStream(repo: repo),
        startCall = ConferenceStartCall(repo: repo),
        sendMessage = ConferenceSendMessage(repo: repo),
        getMessageStream = ConferenceMessageStream(repo: repo),
        startRecording = ConferenceStartRecording(repo: repo),
        muteById = ConferenceMuteById(repo: repo),
        stopRecording = ConferenceStopRecording(repo: repo),
        getToastMessageStream = ConferenceToastMessageStream(repo: repo),
        handUpU = ConferenceHandUp(repo: repo),
        getScreenShareStream = GetScreenShareStream(repo: repo),
        getDisposeScreenShareStream = DisposeScreenSharingStream(repo: repo),
        userTalkingStream = GetUserTalkingStream(repo: repo);

  final ConferenceRepo repo;

  ConferenceInitialize conferenceInitialize;
  GetRendererStream getRendererStream;
  GetEndStream getEndStream;
  GetSubscriberStream getSubscriberStream;
  ConferenceFinishCall finishCall;
  ConferenceMute mute;
  ConferenceChangeSubStream changeSubStream;
  ConferenceGetParticipants getParticipants;
  ConferenceKick kick;
  ConferenceUnPublish unPublish;
  ConferencePing ping;
  ConferenceToggleEngagement toggleEngagement;
  ConferencePublish publish;
  ConferenceSwitchCamera switchCamera;
  ConferenceUnPublishById unPublishById;
  ConferencePublishById publishById;
  GetAvgEngagementStream getAvgEngagementStream;
  ConferenceShareScreen shareScreen;
  ConferenceStartCall startCall;
  ConferenceSendMessage sendMessage;
  ConferenceMessageStream getMessageStream;
  ConferenceStartRecording startRecording;
  ConferenceStopRecording stopRecording;
  ConferenceMuteById muteById;
  ConferenceToastMessageStream getToastMessageStream;
  ConferenceHandUp handUpU;
  GetUserTalkingStream userTalkingStream;
  GetScreenShareStream getScreenShareStream;
  DisposeScreenSharingStream getDisposeScreenShareStream;
}
