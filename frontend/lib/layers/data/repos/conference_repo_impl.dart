import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cinteraction_vc/core/io/network/models/participant.dart';
import 'package:cinteraction_vc/core/util/util.dart';
import 'package:cinteraction_vc/layers/data/dto/meetings/meeting_dto.dart';
import 'package:cinteraction_vc/layers/domain/entities/api_response.dart';
import 'package:cinteraction_vc/layers/domain/entities/chat_message.dart';
import 'package:cinteraction_vc/layers/domain/repos/conference_repo.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../core/app/injector.dart';
import '../../../core/extension/merge_videos.dart';
import '../../../core/io/network/models/data_channel_command.dart';
import '../../../core/janus/janus_client.dart';
import '../../../core/util/conf.dart';

import '../../../core/util/debouncer.dart';
import '../../../core/util/platform/platform.dart';
import '../../domain/entities/user.dart';
import '../../domain/source/api.dart';
import '../../presentation/cubit/chat/chat_cubit.dart';

import '../dto/ai/ai_module_dto.dart';
import '../source/local/local_storage.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class ConferenceRepoImpl extends ConferenceRepo {
  ConferenceRepoImpl({
    required Api api,
  }) : _api = api;

  final Api _api;

  JanusClient? client;
  WebSocketJanusTransport? ws;
  JanusSession? session;

  late StreamRenderer localVideoRenderer;
  late StreamRenderer localScreenSharingRenderer;

  int? myPvtId;

  bool joined = true;
  bool screenSharing = false;
  bool front = true;
  dynamic fullScreenDialog;

  JanusVideoRoomPlugin? videoPlugin;
  JanusVideoRoomPlugin? remotePlugin;
  JanusVideoRoomPlugin? screenPlugin;

  VideoRoomPluginStateManager videoState = VideoRoomPluginStateManager();

  int room = 12344321;
  late JanusVideoRoom? roomDetails;

  final _conferenceStream =
      StreamController<Map<dynamic, StreamRenderer>>.broadcast();
  final _conferenceScreenShareStream =
      StreamController<Map<dynamic, StreamRenderer>>.broadcast();

  // final _contributorsStream = StreamController<Map<dynamic, StreamRenderer>>.broadcast();

  final _conferenceEndedStream = StreamController<String>.broadcast();
  final _conferenceChatStream = StreamController<List<ChatMessage>>.broadcast();
  final _participantsStream =
      StreamController<Map<dynamic, StreamRenderer>>.broadcast();
  final _avgEngagementStream = StreamController<int>.broadcast();
  final _talkingIdStream = StreamController<int>.broadcast();
  final _conferenceToastMessageStream = StreamController<String>.broadcast();
  final _userIsTalkingStream = StreamController<void>.broadcast();
  final _disposeScreenSharingStream = StreamController<void>.broadcast();

  User? user = getIt.get<LocalStorage>().loadLoggedUser();

  late String myId = user?.id ?? "";
  late String displayName = user?.name ?? 'User $myId';

  get screenShareId => int.parse(myId) * 1000 + 999;

  int? callId;

  List<ChatMessage> messages = [];

  final _debouncer = Debouncer(delay: const Duration(milliseconds: 50));


  List<ModuleDto> activeModules = [];

  @override
  Future<void> initialize(
      {required int roomId, required String displayName}) async {
    room = roomId;
    this.displayName = user!.name;

    ws = WebSocketJanusTransport(url: url);
    client = JanusClient(
        transport: ws!,
        withCredentials: true,
        apiSecret: apiSecret,
        isUnifiedPlan: true,
        iceServers: iceServers,
        loggerLevel: Level.FINE);
    session = await client?.createSession();
    _initLocalMediaRenderer();

    activeModules = user?.modules.where((m) => m.enabled == 1).toList() ?? [];
    await _configureConnection();
    await _joinRoom();
  }

  @override
  Stream<Map<dynamic, StreamRenderer>> getStreamRendererStream() {
    return _conferenceStream.stream;
  }

  @override
  Stream<Map<dynamic, StreamRenderer>> getSubscribersStream() {
    return _participantsStream.stream;
  }

  @override
  Stream<String> getConferenceEndedStream() {
    return _conferenceEndedStream.stream;
  }

  @override
  Stream<int> getAvgEngagementStream() {
    return _avgEngagementStream.stream;
  }

  @override
  Stream<List<ChatMessage>> getConferenceMessagesStream() {
    return _conferenceChatStream.stream;
  }

  _initLocalMediaRenderer() {
    print('initLocalMediaRenderer');
    localVideoRenderer = StreamRenderer('local', 'local');
    localVideoRenderer.imageUrl = user?.imageUrl;
  }

  _configureConnection() async {
    videoPlugin = await _attachPlugin(pop: true);
    _eventMessagesHandler();
    await _configureLocalVideoRenderer();
  }

  _attachPlugin({bool pop = false}) async {
    JanusVideoRoomPlugin? videoPlugin =
        await session?.attach<JanusVideoRoomPlugin>();

    videoPlugin?.typedMessages?.listen((event) async {
      Object data = event.event.plugindata?.data;
      if (data is VideoRoomJoinedEvent) {
        await videoPlugin.initDataChannel();
        print("initdatachannel video plugin");

        myPvtId = data.privateId;
        if (pop) {
          // Navigator.of(context).pop(joiningDialog);
        }
        {
          _canBePublished().then((value) async {
            if (value) {
              await _publishMyOwn();
              _getScore();
            }
          });
        }
      }
      if (data is VideoRoomLeavingEvent) {
        print('unscubscribing');
        _unSubscribeTo(data.leaving!);
      }
      if (data is VideoRoomUnPublishedEvent) {
        _unSubscribeTo(data.unpublished);
      }
      videoPlugin.handleRemoteJsep(event.jsep);
    });

    return videoPlugin;
  }

  _attachSubscriberOnPublisherChange(List<dynamic>? publishers) async {
    if (publishers == null) {
      return;
    }

    print('PUBLISHER CHANGE: publishers: ${publishers}');

    List<Map> sources = [];
    for (Map publisher in publishers) {
      if ([myId, screenShareId.toString()]
          .contains(publisher['id'].toString())) {
        print('PUBLISHER CHANGE: publishers: its me');
        continue;
      }

      if (currentTalkerIds.length < maxVisibleSlots) {
        currentTalkerIds.add(publisher['id'].toString());
      }

      videoState.feedIdToDisplayStreamsMap[publisher['id']] =
          Publisher.fromJson(publisher as Map<String, dynamic>);

      List<Map> mappedStreams = [];
      for (Map stream in publisher['streams'] ?? []) {
        if (videoState.feedIdToMidSubscriptionMap[publisher['id']] != null &&
            videoState.feedIdToMidSubscriptionMap[publisher['id']]
                    ?[stream['mid']] ==
                true) {
          print('PUBLISHER CHANGE: publishers streams : ${publisher['id']}');
          continue;
        }
        stream['id'] = publisher['id'];
        stream['display'] = publisher['display'];

        if (publisher.containsKey('metadata')) {
          var metadata = publisher['metadata'];
          stream['metadataMuted'] = stream['type'] == 'audio'
              ? metadata['isAudioMuted']
              : stream['type'] == 'video'
                  ? metadata['isVideoMuted']
                  : null;
          stream['isHandUp'] = metadata['isHandUp'];
          stream['imageUrl'] = metadata['imageUrl'];
        }

        sources.add(stream);
      }
      // sources.add(mappedStreams);
    }

    print('subscribing_test: $sources');
    await _subscribeTo(sources);
  }

  _eventMessagesHandler() async {
    videoPlugin?.messages?.listen((payload) async {
      print('eventMessagesHandlerTest: $payload');

      JanusEvent event = JanusEvent.fromJson(payload.event);
      List<dynamic>? publishers = event.plugindata?.data['publishers'];

      publishers?.forEach((publisher) {
        String display = publisher['display'];
        _conferenceToastMessageStream.add('$display joined');
      });

      await _attachSubscriberOnPublisherChange(publishers);

      List<dynamic>? participants = event.plugindata?.data['participants'];

      if (participants != null) {
        participants.forEach((publisher) {
          var metadata = publisher['metadata'];
          if (metadata != null) {
            var id = publisher['id'];
            _manageMetadata(id.toString(), metadata);
          }
        });
      }

      var metadata = event.plugindata?.data['metadata'];
      if (metadata != null) {
        var id = event.plugindata?.data['id'];
        _manageMetadata(id.toString(), metadata);
      }

      var kicked = event.plugindata?.data['kicked'];
      if (kicked != null) {
        _unSubscribeTo(kicked);
      }

      var unpublished = event.plugindata?.data['unpublished'];
      if (unpublished != null) {
        if (unpublished == 'ok') {
          _cleanupWebRTC();
        }
      }

      var leaving = event.plugindata?.data['leaving'];
      if (leaving == 'ok') {
        _closeCall(event.plugindata?.data['reason']);
      }

      var pluginData = event.plugindata;
      if (pluginData != null) {
        var data = pluginData.data;
        if (data != null) {
          var dataMap = data as Map<String, dynamic>;
          if (dataMap.containsKey('display')) {
            var id = dataMap['id'];
            StreamRenderer? renderer =
                videoState.streamsToBeRendered[id.toString()];
            renderer?.publisherName = dataMap['display'];
            _refreshStreams();
            return;
          }

          // {event: {janus: event, session_id: 8890060192473935, sender: 4573435648381413, plugindata: {plugin: janus.plugin.videoroom, data: {videoroom: event, room: 1234, id: 57, mid: 1, moderation: muted}}}, jsep: null}
          // {event: {janus: event, session_id: 8890060192473935, sender: 4573435648381413, plugindata: {plugin: janus.plugin.videoroom, data: {videoroom: event, room: 1234, id: 57, mid: 1, moderation: unmuted}}}, jsep: null}

          // if (dataMap.containsKey('moderation')) {
          //   var moderation = dataMap['moderation'];
          //   print('moderation: $moderation');
          //   if (moderation == 'muted' || moderation == 'unmuted') {
          //     var id = '${dataMap['id']}';
          //     var mid = dataMap['mid'];
          //     var kind = mid == '0' ? 'audio' : 'video';
          //     var muted = moderation == 'muted';
          //     _manageMuteUIEvents(id, kind, muted);
          //   }
          // }

          if (data.containsKey("videoroom")) {
            var videoroom = dataMap['videoroom'];
            if (data.containsKey("id")) {
              var id = dataMap['id'];
              if (videoroom == "talking") {
                _manageTalkingEvents(id, true);
              }
              if (videoroom == "stopped-talking") {
                _manageTalkingEvents(id, false);
              }
            }
          }
        }
      }

      var errorCode = event.plugindata?.data['error_code'];
      if (errorCode != null) {
        if (errorCode == 436) //already in the room
        {
          _selfKickAndJoin();
        }
      }
    });

    screenPlugin?.messages?.listen((payload) async {
      JanusEvent event = JanusEvent.fromJson(payload.event);
      List<dynamic>? publishers = event.plugindata?.data['publishers'];
      await _attachSubscriberOnPublisherChange(publishers);
    });

    videoPlugin?.renegotiationNeeded?.listen((event) async {
      if (videoPlugin?.webRTCHandle?.peerConnection?.signalingState !=
          RTCSignalingState.RTCSignalingStateStable) return;
      // print('retrying to connect publisher');
      var offer = await videoPlugin?.createOffer(
        audioRecv: false,
        videoRecv: false,
      );
      await videoPlugin?.configure(sessionDescription: offer);
    });
    screenPlugin?.renegotiationNeeded?.listen((event) async {
      if (screenPlugin?.webRTCHandle?.peerConnection?.signalingState !=
          RTCSignalingState.RTCSignalingStateStable) return;
      // print('retrying to connect publisher');
      var offer =
          await screenPlugin?.createOffer(audioRecv: false, videoRecv: false);
      await screenPlugin?.configure(bitrate: 0, sessionDescription: offer);
    });

    videoPlugin?.peerConnection?.onConnectionState = (state) {
      // print('peerConnection state: ${state.name}');
    };
  }

  _manageTalkingEvents(int feedId, bool talking) async {
    var id = user?.id == feedId.toString() ? "local" : feedId.toString();
    StreamRenderer? renderer = videoState.streamsToBeRendered[id];
    if (renderer == null) {
      return;
    }
    _startRecord(renderer.mediaStream!);
    renderer.isTalking = talking;

    if (!currentTalkerIds.contains(id) && talking && id != "local") {
      _changeTalker(id);
    } else {
      _refreshStreams();
    }
  }

  _changeTalker(String id) {
    print("_changeTalker");
    _debouncer.run(() {
      print("changing talker EXECUTE");
      updateTalkerSlots(videoState.streamsToBeRendered, currentTalkerIds, id);
      _checkVideoStreams(force: true);
      _refreshStreams();
    });
  }

  _manageMetadata(String id, Map<String, dynamic> metadata) {
    StreamRenderer? renderer = videoState.streamsToBeRendered[id];

    if (renderer == null) {
      return;
    }
    _manageMuteUIEvents(renderer, 'audio', metadata['isAudioMuted']);
    _manageMuteUIEvents(renderer, 'video', metadata['isVideoMuted']);
    _manageHandUp(renderer, metadata['isHandUp']);
    renderer.imageUrl = metadata['imageUrl'];

    _refreshStreams();
  }

  _manageHandUp(StreamRenderer renderer, bool handUp) {
    if (renderer.isHandUp != handUp && handUp) {
      _conferenceToastMessageStream
          .add('${renderer.publisherName} raised hand!');
    }
    renderer.isHandUp = handUp;
  }

  _manageMuteUIEvents(StreamRenderer renderer, String kind, bool muted) async {
    if (renderer.publisherName.toLowerCase().contains('screenshare')) {
      return;
    }

    if (kind == 'audio') {
      if (renderer.isAudioMuted == muted) {
        return;
      }
      if (muted) {
        renderer.isTalking = false;
      }
      renderer.isAudioMuted = muted;
    } else if (kind == 'video') {
      if (renderer.isVideoMuted == muted) {
        return;
      }
      renderer.isVideoMuted = muted;
    }
  }

  _configureLocalVideoRenderer() async {
    await localVideoRenderer.init();

    try {
      bool? cameraAvailable = await videoPlugin?.hasCamera();

      if (cameraAvailable!) {
        localVideoRenderer.mediaStream =
            await videoPlugin?.initializeMediaDevices(simulcastSendEncodings: [
          RTCRtpEncoding(
              rid: "h",
              minBitrate: 256000,
              // 256 kbps
              maxBitrate: 512000,
              // 512 kbps
              active: true,
              scalabilityMode: 'L2T2',
              maxFramerate: 24),
          RTCRtpEncoding(
              rid: "m",
              minBitrate: 128000,
              // 128 kbps
              maxBitrate: 256000,
              // 256 kbps
              active: true,
              scalabilityMode: 'L2T2',
              scaleResolutionDownBy: 2,
              // 240p
              maxFramerate: 24),
          RTCRtpEncoding(
            rid: "l",
            minBitrate: 64000,
            // 64 kbps
            maxBitrate: 128000,
            // 128 kbps
            active: true,
            scalabilityMode: 'L2T2',
            scaleResolutionDownBy: 8, // 180pmaxFramerate: 24
          ),
        ], mediaConstraints: {
          'video': {'width': 640, 'height': 360},
          // 720p max for higher quality
          'audio': true,
        });

        localVideoRenderer.isVideoMuted = false;
      } else {
        localVideoRenderer.isVideoMuted = true;
        print("System dont detect any camera.");
        localVideoRenderer.mediaStream =
            await videoPlugin?.initializeMediaDevices();
      }
    } catch (e) {
      localVideoRenderer.isVideoMuted = true;
      print("Camera not available. Falling back to audio only.");
      localVideoRenderer.mediaStream =
          await videoPlugin?.initializeMediaDevices();
    }

    localVideoRenderer.videoRenderer.srcObject = localVideoRenderer.mediaStream;
    localVideoRenderer.publisherName = displayName;
    localVideoRenderer.publisherId = myId.toString();
    localVideoRenderer.videoRenderer.onResize = () {};

    Map<String, StreamRenderer> renderers = {};
    renderers.addAll(videoState.streamsToBeRendered);

    videoState.streamsToBeRendered.clear();
    videoState.streamsToBeRendered
        .putIfAbsent('local', () => localVideoRenderer);
    videoState.streamsToBeRendered.addAll(renderers);

    _checkVideoStreams();
    _refreshStreams();
  }

  Map<int, String> videoMids = {};

  _subscribeTo(List<Map> sources) async {
    if (sources.isEmpty) {
      return;
    }

    if (remotePlugin == null) {
      remotePlugin = await session?.attach<JanusVideoRoomPlugin>();
      remotePlugin?.messages?.listen((payload) async {
        JanusEvent event = JanusEvent.fromJson(payload.event);
        // print('object ${event.plugindata?.data['streams']}');
        List<dynamic>? streams = event.plugindata?.data['streams'];
        if (streams != null) {
          videoMids.clear();
        }

        streams?.forEach((element) {
          if (element['type'] == 'video' &&
              element['active'] == true &&
              element.containsKey('feed_id')) {
            int feedId = element['feed_id'];
            String mid = element['mid'].toString();
            videoMids[feedId] = mid; // latest video MID per feed
          }

          videoState.subStreamsToFeedIdMap[element['mid']] = element;
          // to avoid duplicate subscriptions
          if (videoState.feedIdToMidSubscriptionMap[element['feed_id']] == null)
            videoState.feedIdToMidSubscriptionMap[element['feed_id']] = {};
          videoState.feedIdToMidSubscriptionMap[element['feed_id']]
              [element['mid']] = true;
        });

        // print("print liste: ${videoState.feedIdToMidSubscriptionMap}");
        // print("print liste: ${videoMids}");
        if (payload.jsep != null) {
          await remotePlugin?.initDataChannel();
          print("initdatachannel remoteplugin");
          await remotePlugin?.handleRemoteJsep(payload.jsep);
          await remotePlugin?.start(room);
        }
      });

      remotePlugin?.webRTCHandle!.peerConnection!.onDataChannel = (channel) {
        channel.onBufferedAmountLow = (currentAmount) {
          print("onBufferedAmountLow ${currentAmount.toString()}");
        };

        channel.onBufferedAmountChange = (currentAmount, changedAmount) {
          print("onBufferedAmountChange ${currentAmount.toString()}");
        };

        channel.onMessage = (data) {
          try {
            Map<String, dynamic> result = jsonDecode(data.text);
            var command = DataChannelCommand.fromJson(result);
            _renderCommand(command);
          } on Exception catch (_) {
            print(data.text);
          }
        };

        channel.onDataChannelState = (state) {
          print("onDataChannelState ${state.name}");
          // if(state == RTCDataChannelState.RTCDataChannelOpen)
          // {
          //   _askForMuteStatus();
          // }
        };

        channel.stateChangeStream.listen((state) {
          print("stateChangeStream ${state.name}");
          // if(state == RTCDataChannelState.RTCDataChannelOpen)
          //   {
          //     _askForMuteStatus();
          //   }
        });

        channel.messageStream.listen((message) {
          // print("messageStream ${message.text}");
        });
      };

      remotePlugin?.remoteTrack?.listen((event) async {
        // print({
        //   'mid': event.mid,
        //   'flowing': event.flowing,
        //   'TrackId': event.track?.id,
        //   'TrackKind': event.track?.kind,
        //   'TrackLabel': event.track?.label!,
        //   'TrackMuted': event.track?.muted!,
        //   'TrackEnabled': event.track?.enabled
        // });
        print(event);

        int? feedId = videoState.subStreamsToFeedIdMap[event.mid]?['feed_id'];

        Publisher? feed = videoState.feedIdToDisplayStreamsMap[feedId];
        if (feed == null) {
          return;
        }

        if (event.flowing == false) {
          final feedKey = feedId.toString();
          final isVideo = event.track?.kind == "video";
          var renderer = videoState.streamsToBeRendered[feedKey];
          if (renderer == null) return;
          if (isVideo) {
            print("try to set video flowing");
            renderer.setVideoFlowing = event.flowing;

            _checkVideoStreams();
            _refreshStreams();
          }
        }

        if (event.flowing == true) {
          final feedKey = feedId.toString();
          final isAudio = event.track?.kind == "audio";
          final isVideo = event.track?.kind == "video";

          var renderer = videoState.streamsToBeRendered[feedKey];

          // If new renderer is needed
          if (renderer == null) {
            renderer = StreamRenderer(feedKey, feedKey);
            await renderer.init();
            renderer.mediaStream = await createLocalMediaStream(feedKey);
            videoState.streamsToBeRendered[feedKey] = renderer;
            print("Created new renderer for $feedKey");
          }

          // Always update common metadata
          renderer.publisherName = feed.displayName;
          renderer.publisherId = feedKey;

          if (isAudio) {
            print("Handling AUDIO for $feedId");

            renderer.mediaStream?.getAudioTracks().forEach((track) {
              renderer?.mediaStream?.removeTrack(track);
            });

            if (event.track != null) {
              renderer.mediaStream?.addTrack(event.track!);
            }

            renderer.videoRenderer.srcObject = renderer.mediaStream;
            renderer.videoRenderer.muted = false;

            final audioSource = sources.firstWhere(
              (item) => item['id'] == feedId && item['type'] == 'audio',
              orElse: () => <String, dynamic>{},
            );

            if (audioSource.isNotEmpty) {
              renderer.isAudioMuted = audioSource['metadataMuted'];
            }

            renderer.isHandUp = audioSource['isHandUp'];
            renderer.imageUrl = audioSource['imageUrl'];

            renderer.audioMid = event.mid;
          } else if (isVideo) {
            renderer.setVideoFlowing = event.flowing;
            // Remove existing video tracks
            renderer.mediaStream?.getVideoTracks().forEach((track) {
              renderer?.mediaStream?.removeTrack(track);
            });

            // Add new video track
            if (event.track != null) {
              renderer.mediaStream?.addTrack(event.track!);
            }

            // Reset video renderer to prevent flipping/mirroring issues
            renderer.videoRenderer.srcObject = null;
            await Future.delayed(const Duration(milliseconds: 10));
            renderer.videoRenderer.srcObject = renderer.mediaStream;
            renderer.videoRenderer.onResize = () => _refreshStreams();
            renderer.videoRenderer.muted = false;

            final Map<dynamic, dynamic> videoSource = sources.firstWhere(
              (item) => item['id'] == feedId && item['type'] == 'video',
              orElse: () => <String, dynamic>{},
            );

            if (videoSource.isNotEmpty && renderer.initialSet == false) {
              renderer.isVideoMuted = videoSource['metadataMuted'];
              renderer.initialSet = true;
            }

            renderer.videoMid = event.mid;
            // renderer.isVideoMuted = event.track!.muted!;
          }

          _checkVideoStreams();
          _refreshStreams();
        }
      });

      List<PublisherStream> streams = sources
          .map((e) => PublisherStream(
                feed: e['id'],
                mid: e['mid'],
                simulcast: e['simulcast'],
              ))
          .toList();

      print("join subscriber: $streams");
      await remotePlugin?.joinSubscriber(room, streams: streams, pin: "");
      _checkVideoStreams();
      return;
    }

    List<Map>? added, removed;
    // for (var streams in sources) {
    for (var stream in sources) {
      // If the publisher is VP8/VP9 and this is an older Safari, let's avoid video
      if (stream['disabled'] != null) {
        // Unsubscribe
        removed ??= [];
        removed.add({
          'feed': stream['id'], // This is mandatory
          'mid': stream['mid'] // This is optional (all streams, if missing)
        });
        videoState.feedIdToMidSubscriptionMap[stream['id']]
            ?.remove(stream['mid']);
        videoState.feedIdToMidSubscriptionMap.remove(stream['id']);
        continue;
      }
      if (videoState.feedIdToMidSubscriptionMap[stream['id']] != null &&
          videoState.feedIdToMidSubscriptionMap[stream['id']][stream['mid']] ==
              true) {
        print("Already subscribed to stream, skipping:");
        continue;
      }

      // Subscribe
      added ??= [];
      added.add({
        'feed': stream['id'], // This is mandatory
        'mid': stream['mid'] // This is optional (all streams, if missing)
      });

      if (videoState.feedIdToMidSubscriptionMap[stream['id']] == null) {
        videoState.feedIdToMidSubscriptionMap[stream['id']] = {};
      }
      videoState.feedIdToMidSubscriptionMap[stream['id']][stream['mid']] = true;
    }
    // }
    print("try to subscribe to:");
    if ((added == null || added.isEmpty) &&
        (removed == null || removed.isEmpty)) {
      // Nothing to do
      return;
    }

    print("try to subscribe to: $added");
    await remotePlugin?.update(
        subscribe: added
            ?.map((e) => SubscriberUpdateStream(
                feed: e['feed'], mid: e['mid'], crossrefid: null))
            .toList(),
        unsubscribe: removed
            ?.map((e) => SubscriberUpdateStream(
                feed: e['feed'], mid: e['mid'], crossrefid: null))
            .toList());
  }

  Future<void> _unSubscribeTo(int id) async {
    print('unsubscribed: $id');
    var feed = videoState.feedIdToDisplayStreamsMap[id];
    if (feed == null) return;

    videoState.feedIdToDisplayStreamsMap.remove(id);

    await videoState.streamsToBeRendered[id]?.dispose();

    videoState.streamsToBeRendered.remove(id.toString());

    List<Map> unsubscribeStreams = (feed.streams).map((stream) {
      return {
        'feed': id,
        'mid': stream.mid // This is optional (all streams, if missing)
      };
    }).toList();

    if (remotePlugin != null) {
      await remotePlugin?.update(
          unsubscribe: unsubscribeStreams
              .map((e) => SubscriberUpdateStream(
                  feed: e['feed'], mid: e['mid'], crossrefid: null))
              .toList());
    }
    videoState.feedIdToMidSubscriptionMap.remove(id);

    if (currentTalkerIds.contains(id.toString())) {
      currentTalkerIds.remove(id.toString());
      videoState.streamsToBeRendered.forEach((key, value) {
        if (!currentTalkerIds.contains(key) && key != 'local') {
          if (currentTalkerIds.length < maxVisibleSlots) {
            currentTalkerIds.add(key);
          }
        }
      });

      _checkVideoStreams(force: true);
    }

    _refreshStreams();
  }

  Future<void> _unSubscribeVideoTo(int id) async {
    String? mid = videoMids[id];

    // var feed = videoState.streamsToBeRendered[id.toString()];
    if (mid == null) return;

    // feed?.isVideoMuted = true;

    List<Map> unsubscribeStreams = [];
    unsubscribeStreams.add({
      'feed': id,
      'mid': "1" // This is optional (all streams, if missing)
    });

    if (remotePlugin != null && unsubscribeStreams.isNotEmpty) {
      print("_unSubscribeVideoTo $unsubscribeStreams");

      await remotePlugin?.update(
          unsubscribe: unsubscribeStreams
              .map((e) => SubscriberUpdateStream(
                  feed: e['feed'], mid: e['mid'], crossrefid: null))
              .toList());
    } else {
      print("_unSubscribeVideoTo error ${unsubscribeStreams}");
    }
  }

  Future<void> _subscribeVideoTo(int id) async {
    print("=============_subscribeVideoTo $id ==============");
    var feed = videoState.streamsToBeRendered[id.toString()];
    if (feed == null) return;
    feed.mirrorVideo = true;

    String? mid = videoMids[id];
    if (mid != null) {
      print("allready subscribed");
      return;
    }

    List<Map> subscribeStreams = [];
    subscribeStreams.add({
      'feed': id,
      'mid': "1" // This is optional (all streams, if missing)
    });

    if (remotePlugin != null && subscribeStreams.isNotEmpty) {
      print("_subscribeVideoTo $subscribeStreams");

      await remotePlugin?.update(
          subscribe: subscribeStreams
              .map((e) => SubscriberUpdateStream(
                  feed: e['feed'], mid: e['mid'], crossrefid: null))
              .toList());
    } else {
      print("_subscribeVideoTo error ${subscribeStreams}");
    }
  }

  _selfKickAndJoin() async {
    await _kick(id: myId);
    await _joinPublisher();
  }

  ///
  /// InCall actions
  ///
  @override
  Future<void> kick({required String id}) async {
    StreamRenderer? renderer = videoState.streamsToBeRendered[id];
    if (renderer == null) {
      return;
    }
    _startRecord(renderer.mediaStream!);
    _kick(id: id);

    // _unSubscribeVideoTo(int.parse(id));
  }

  _kick({required String id}) async {
    var payload = {
      "request": "kick",
      "room": room,
      "id": int.parse(id),
    };
    await videoPlugin?.send(data: payload);
  }

  Timer? _audioLevelTimer;
  bool _monitorPaused = false;

  void startAudioLevelMonitor(MediaStreamTrack audioTrack) {
    _audioLevelTimer?.cancel();

    _audioLevelTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_monitorPaused) return;

      var stats =
          await videoPlugin?.webRTCHandle?.peerConnection?.getStats(audioTrack);
      for (var report in stats!) {
        if (report.type == 'media-source') {
          final level = report.values['audioLevel'];
          print("audioLevel: $level");
          if (level != null &&
              level > 0.1 &&
              localVideoRenderer.isAudioMuted!) {
            print('User is speaking while muted!');
            _pauseMonitoring(duration: const Duration(seconds: 5));
            _userIsTalkingStream.add(_);
          }
        }
      }
    });
  }

  void stopAudioLevelMonitor() {
    _audioLevelTimer?.cancel();
    _audioLevelTimer = null;
  }

  void _pauseMonitoring({Duration duration = const Duration(seconds: 5)}) {
    _monitorPaused = true;
    Timer(duration, () {
      _monitorPaused = false;
    });
  }

  @override
  Future<void> mute({required String kind, required bool muted}) async {
    var payload = {
      "request": "moderate",
      "room": room,
      "id": int.parse(myId),
      "mid": kind == 'video' ? '1' : '0',
      "mute": muted
    };

    await videoPlugin?.send(data: payload);
    localVideoRenderer.mediaStream
        ?.getTracks()
        .where((element) => element.kind == kind)
        .toList()
        .forEach((element) {
      // element.enabled = !muted;
      if (muted) {
        startAudioLevelMonitor(element);
      } else {
        stopAudioLevelMonitor();
      }
    });

    if (kind == 'audio') {
      localVideoRenderer.isAudioMuted = muted;
    } else {
      localVideoRenderer.isVideoMuted = muted;
    }

    await _changeMetaData();
    _refreshStreams();
    _getScore();
  }

  @override
  Future<void> handUp({required bool handUp}) async {
    localVideoRenderer.isHandUp = handUp;
    await _changeMetaData();
  }

  @override
  Future<void> ping({required String msg}) async {
    await videoPlugin?.sendData(msg);
  }

  @override
  Future<void> switchCamera() async {
    front = !front;
    await videoPlugin?.switchCamera(deviceId: await getCameraDeviceId(front));
    localVideoRenderer = StreamRenderer('local', 'local');
    await localVideoRenderer.init();
    localVideoRenderer.videoRenderer.srcObject =
        videoPlugin?.webRTCHandle!.localStream;
    localVideoRenderer.publisherName = user!.name;
    videoState.streamsToBeRendered['local'] = localVideoRenderer;
  }

  @override
  Future<void> shareScreen() async {
    if (screenSharing) {
      _disposeScreenSharing();
      return;
    }

    screenSharing = true;

    localScreenSharingRenderer =
        StreamRenderer(screenShareId.toString(), 'local_screenshare');
    screenPlugin = await session?.attach<JanusVideoRoomPlugin>();
    screenPlugin?.typedMessages?.listen((event) async {
      Object data = event.event.plugindata?.data;
      if (data is VideoRoomJoinedEvent) {
        myPvtId = data.privateId;
        (await screenPlugin?.configure(
            bitrate: 0,
            sessionDescription: await screenPlugin?.createOffer(
                audioRecv: false, videoRecv: false)));
      }
      if (data is VideoRoomLeavingEvent) {
        _unSubscribeTo(data.leaving!);
      }
      if (data is VideoRoomUnPublishedEvent) {
        _unSubscribeTo(data.unpublished);
      }
      screenPlugin?.handleRemoteJsep(event.jsep);
    });
    await localScreenSharingRenderer.init();
    localScreenSharingRenderer.publisherId = screenShareId.toString();

    localScreenSharingRenderer.mediaStream =
        await screenPlugin?.initializeMediaDevices(mediaConstraints: {
      'video': {'frameRate': 30, 'width': 1920, 'height': 1080},
      'audio': true
    }, useDisplayMediaDevices: true);

    localScreenSharingRenderer.videoRenderer.srcObject =
        localScreenSharingRenderer.mediaStream;
    localScreenSharingRenderer.publisherName = "Your Screenshare";

    videoState.streamsToBeRendered.putIfAbsent(
        screenShareId.toString(), () => localScreenSharingRenderer);

    await screenPlugin?.joinPublisher(room,
        displayName: "${displayName}_screenshare", id: screenShareId, pin: "");

    localScreenSharingRenderer.mediaStream
        ?.getVideoTracks()
        .forEach((videoTrack) {
      videoTrack.onEnded = () {
        print("onEnded");
        _disposeScreenSharing();
      };
    });

    _refreshStreams();
  }

  Future<void> _disposeScreenSharing() async {
    screenSharing = false;

    (localScreenSharingRenderer.mediaStream?.getTracks())?.forEach((track) {
      track.stop();
    });
    StreamRenderer? rendererRemoved;

    videoState.feedIdToMidSubscriptionMap.remove(localScreenSharingRenderer.id);
    rendererRemoved =
        videoState.streamsToBeRendered.remove(localScreenSharingRenderer.id);

    await rendererRemoved?.dispose();
    await screenPlugin?.hangup();
    screenPlugin = null;

    _disposeScreenSharingStream.add(null);
    _refreshStreams();
  }

  @override
  Stream<void> getDisposeScreenSharingStream() {
    return _disposeScreenSharingStream.stream;
  }

  @override
  Future<void> finishCall() async {
    _closeCall('User hanged');
  }

  Future<dynamic> _closeCall(String reason) async {
    await _endCall();
    await getIt.get<ChatCubit>().loadChats(1, 20);

    // var listFeed = videoState.feedIdToDisplayStreamsMap.keys;
    List<int> listFeed = videoState.feedIdToDisplayStreamsMap.keys.toList();
    for (var feed in listFeed) {
      await _unSubscribeTo(feed);
    }
    videoState.streamsToBeRendered.forEach((key, value) async {
      await value.dispose();
    });
    // setState(() {
    videoState.streamsToBeRendered.clear();
    videoState.feedIdToDisplayStreamsMap.clear();
    videoState.subStreamsToFeedIdMap.clear();
    videoState.feedIdToMidSubscriptionMap.clear();
    joined = false;
    // screenSharing = false;
    engagementEnabled = false;
    // });

    await videoPlugin?.hangup();
    if (screenSharing) {
      await screenPlugin?.hangup();
    }
    await videoPlugin?.dispose();
    await screenPlugin?.dispose();
    await remotePlugin?.dispose();
    remotePlugin = null;

    session?.dispose();

    _conferenceEndedStream.add(reason);
  }

  Future<bool> _endCall() async {
    return await _api.endCall(callId: callId, userId: user?.id);
  }

  /// End InCall actions

  ///
  /// Stream actions
  ///

  @override
  Future<void> publish() async {
    _canBePublished().then((value) async {
      if (value) {
        await videoPlugin?.initializeWebRTCStack();
        await _configureLocalVideoRenderer();
        await _publishMyOwn();
        await videoPlugin?.initDataChannel();
        print("initdatachannel video plugin on publish");
      }
    });
  }

  @override
  Future<void> publishById({required String id}) async {
    // _changeTalker(id);
    _manageTalkingEvents(int.parse(id), true);
    await videoPlugin?.sendData(jsonEncode(
        DataChannelCommand(command: DataChannelCmd.publish, id: id).toJson()));
  }

  @override
  Future<void> muteById({required String id}) async {
    await videoPlugin?.sendData(jsonEncode(
        DataChannelCommand(command: DataChannelCmd.muteById, id: id).toJson()));
  }

  @override
  Future<void> unPublishById({required String id}) async {
    await videoPlugin?.sendData(jsonEncode(
        DataChannelCommand(command: DataChannelCmd.unPublish, id: id)
            .toJson()));
    // _subscribeVideoTo(int.parse(id));
  }

  @override
  Future<void> unPublish() async {
    await videoPlugin?.unpublish();
  }

  Future<bool> _canBePublished() async {
    var participants = await getParticipants();
    var publishers = participants.where((element) => element.publisher);
    print('Number of publishers ${publishers.length}');

    var max = roomDetails?.maxPublishers!.toInt() ?? maxPublishersDefault;

    return publishers.length < max;
  }

  _publishMyOwn() async {
    var offer =
        await videoPlugin?.createOffer(audioRecv: false, videoRecv: false);
    await videoPlugin?.configure(bitrate: 2000000, sessionDescription: offer);

    for (var audioTrack in localVideoRenderer.mediaStream!.getAudioTracks()) {
      print('${audioTrack.id} audio track');
      _addOnEndedToTrack(audioTrack);
    }
  }

  _addOnEndedToTrack(MediaStreamTrack track) {
    track.onEnded ??= () => _replaceAudioTrack();
  }

  _replaceAudioTrack() async {
    print('track is ended');
    var stream = await navigator.mediaDevices.getUserMedia({'audio': true});
    var audioTrack = stream.getAudioTracks()[0];

    _addOnEndedToTrack(audioTrack);

    List<RTCRtpSender>? senders =
        await videoPlugin?.webRTCHandle?.peerConnection?.senders;
    senders?.forEach((sender) async {
      if (sender.track?.kind == 'audio') {
        print('${sender.track?.label} track is replaced');
        await sender.replaceTrack(audioTrack);
        print('${sender.track?.label} track is replaced');
      }
    });
  }

  _unPublish() async {
    await videoPlugin?.unpublish();
  }

  @override
  Future<List<Participant>> getParticipants() async {
    //   var payload = {"request": "listparticipants", "room": room};
    //   Map participants = await videoPlugin?.send(data: payload);
    //   JanusEvent event = JanusEvent.fromJson(participants);
    //
    //   List<Participant> subscribers = [];
    //
    //   for (var par in event.plugindata?.data['participants']) {
    //     var participant = Participant.fromJson(par as Map<String, dynamic>);
    //     subscribers.add(participant);
    //   }
    //   _participantsStream.add(subscribers);
    //
    //   return subscribers;
    return List.empty();
  }

  @override
  Future<void> changeSubStream(
      {required ConfigureStreamQuality quality,
      required StreamRenderer remoteStream}) async {
    changeSubstream(remoteStreamId: remoteStream.id, substream: 1);
    remoteStream.subStreamQuality = quality;
  }

  @override
  Future<void> changeSubstream(
      {required String remoteStreamId, required int substream}) async {
    print('changedSubstream for mid=$remoteStreamId to $substream');
    await remotePlugin?.send(data: {
      'request': "configure",
      'mid': remoteStreamId,
      'substream': substream
    });
  }

  _changeMetaData() async {
    var metadata = {
      "isAudioMuted": localVideoRenderer.isAudioMuted,
      "isVideoMuted": localVideoRenderer.isVideoMuted,
      "isHandUp": localVideoRenderer.isHandUp,
      "imageUrl": user?.imageUrl
    };

    await videoPlugin?.configure(metadata: metadata);
  }

  ///End Stream actions
  var maxVisibleSlots = 8;
  List<String> currentTalkerIds = [];

  void updateTalkerSlots(Map<dynamic, StreamRenderer> publisherMap,
      List<String> currentTalkerIds, String newSpeakerId) {
    if (newSpeakerId == 'local') {
      return;
    }
    // Already visible → no update
    if (currentTalkerIds.contains(newSpeakerId)) return;

    // Room to add → just add
    if (currentTalkerIds.length < maxVisibleSlots) {
      currentTalkerIds.add(newSpeakerId);
      return;
    }

    // Replace the oldest talker
    String? oldestId;
    DateTime? oldestTime;

    for (String id in currentTalkerIds) {
      DateTime? time = publisherMap[id]?.talkingStartTime;

      if (oldestTime == null || (time != null && time.isBefore(oldestTime))) {
        oldestTime = time;
        oldestId = id;
      }
    }

    if (oldestId != null) {
      int indexToReplace = currentTalkerIds.indexOf(oldestId);
      currentTalkerIds[indexToReplace] = newSpeakerId;
    }
  }

  var lastLengthOnStreams = 0;

  _checkVideoStreams({bool? force = false}) {
    if (lastLengthOnStreams != videoState.streamsToBeRendered.length ||
        force!) {
      for (var entry in videoState.streamsToBeRendered.entries) {
        if (entry.value.id != "local") {
          if (currentTalkerIds.contains(entry.value.id)) {
            _subscribeVideoTo(int.parse(entry.value.id));
          } else {
            _unSubscribeVideoTo(int.parse(entry.value.id));
          }
        }
      }

      lastLengthOnStreams = videoState.streamsToBeRendered.length;
    }
  }

  _refreshStreams() {
    var screenshareKeys = videoState.streamsToBeRendered.keys
        .where((key) => isScreenShare(key.toString()))
        .toList();

    Iterable<String> currentTalkers = currentTalkerIds.cast<String>();
    Iterable<String> screenshare = screenshareKeys.cast<String>();

    final List<String> list = ["local", ...currentTalkers];
    final List<String> screenshareList = [
      if (screenSharing) screenShareId.toString(),
      ...screenshare
    ];

    videoState.streamsToBeRendered.forEach(
      (key, value) {
        if (key == 'local') {
          value.isSharing = screenshareList.contains(screenShareId.toString());
          return;
        }

        if (!isScreenShare(key)) {
          var checkKey = int.parse(value.publisherId!) * 1000 + 999;
          value.isSharing = screenshareList.contains(checkKey.toString());
        }
      },
    );

    _conferenceStream.add(Map.fromEntries(
      list.where((key) {
        return videoState.streamsToBeRendered.containsKey(key) &&
            !isScreenShare(key);
      }).map((key) => MapEntry(key, videoState.streamsToBeRendered[key]!)),
    ));

    _conferenceScreenShareStream.add(Map.fromEntries(
      screenshareList
          .where((key) => videoState.streamsToBeRendered.containsKey(key))
          .map((key) => MapEntry(key, videoState.streamsToBeRendered[key]!)),
    ));

    _participantsStream.add(videoState.streamsToBeRendered);
  }

  _joinRoom() async {
    await _checkRoom();
  }

  _checkRoom() async {
    var exist = await videoPlugin?.exists(room);
    JanusEvent event = JanusEvent.fromJson(exist);
    print('room is exist: ${event.plugindata}');
    if (event.plugindata?.data['exists'] == true) {
      print('try to join publisher');
      await _joinPublisher();
    } else {
      print('need to create the room');
      await _createRoom(room);
    }
  }

  _createRoom(int roomId) async {
    Map<String, dynamic>? extras = {
      'publishers': maxPublishersDefault,
      'audiolevel_event': true,
      'audio_active_packets': 25,
      'audio_level_average': 35,
      'audio_level_threshold': 10,
      "audio_level_event": true,
      "audio_level_ext": true,
    };
    var created = await videoPlugin?.createRoom(room, extras: extras);
    JanusEvent event = JanusEvent.fromJson(created);
    if (event.plugindata?.data['videoroom'] == 'created') {
      await _joinPublisher();
    } else {
      print('error creating room');
    }
  }

  _joinPublisher() async {
    roomDetails = await _getRoomDetails(room);
    print(roomDetails);

    var metadata = {
      "isAudioMuted": localVideoRenderer.isAudioMuted,
      "isVideoMuted": localVideoRenderer.isVideoMuted,
      "isHandUp": localVideoRenderer.isHandUp,
      "imageUrl": localVideoRenderer.imageUrl
    };

    await videoPlugin?.joinPublisher(room,
        displayName: displayName, id: int.parse(myId), metadata: metadata);
  }

  Future<JanusVideoRoom?> _getRoomDetails(int roomId) async {
    var payload = {"request": "list"};
    Map allRooms = await videoPlugin?.send(data: payload);

    JanusEvent event = JanusEvent.fromJson(allRooms);

    for (var r in event.plugindata?.data['list']) {
      var room = JanusVideoRoom.fromJson(r as Map<String, dynamic>);
      if (room.room == roomId) {
        print(room);
        return room;
      }
    }
    return null;
  }

  Future<List<JanusVideoRoom>> _listRooms() async {
    print('get all rooms');
    var payload = {"request": "list"};
    Map allRooms = await videoPlugin?.send(data: payload);
    JanusEvent event = JanusEvent.fromJson(allRooms);

    List<JanusVideoRoom> rooms = [];

    for (var room in event.plugindata?.data['list']) {
      var participant = JanusVideoRoom.fromJson(room as Map<String, dynamic>);
      rooms.add(participant);
    }
    return rooms;
  }

  _cleanupWebRTC() async {
    StreamRenderer? rendererRemoved;
    rendererRemoved =
        videoState.streamsToBeRendered.remove(localVideoRenderer.id);
    await rendererRemoved?.dispose();

    localVideoRenderer.dispose();

    var config = videoPlugin?.webRTCHandle;
    if (config!.localStream != null) {
      config.localStream?.getAudioTracks().forEach((element) async {
        await element.stop();
      });

      config.localStream?.getVideoTracks().forEach((element) async {
        await element.stop();
      });
    }

    await config.peerConnection?.close();
    config.peerConnection = null;
    config.localStream?.dispose();

    _refreshStreams();
  }

  _renderCommand(DataChannelCommand command) {
    switch (command.command) {
      case DataChannelCmd.unPublish:
        if (command.id == myId.toString()) {
          _unPublish();
        }
        break;

      case DataChannelCmd.publish:
        if (command.id == myId.toString()) {
          print('publish myself');
          publish();
        }
        break;

      case DataChannelCmd.engagement:
        final modules = command.data['modules'] as List<dynamic>?;

        // print('MODULEEES $modules');

        if (modules != null) {
          print('[renderCommand] Received modules: $modules');

          for (final module in modules) {
            final name = module['name'];
            final value = module['value'] as int?;

            final ModuleDto? foundModule = activeModules
                .where((m) => m.name.toLowerCase() == name.toString().toLowerCase())
                .cast<ModuleDto?>()
                .firstOrNull;

            if (foundModule != null){
              videoState.streamsToBeRendered[command.id]?.moduleScores[foundModule] = value!;
              videoState.streamsToBeRendered[command.id]?.addSpot(name, value!, foundModule.id ?? 1);
            }
          }
          _refreshStreams();
        } else {
          print('[renderCommand] No modules received in engagement command');
        }
        break;

      case DataChannelCmd.message:
        print('message received ${command.data['message']}');
        messages.add(ChatMessage(
          message: command.data['message'],
          displayName: command.data['displayName'],
          time: DateTime.parse(command.data['time']),
          avatarUrl: command.data['avatarUrl'],
          seen: false,
        ));
        _conferenceChatStream.add(messages);
        break;

      case DataChannelCmd.muteById:
        if (command.id == myId.toString()) {
          mute(kind: 'audio', muted: !localVideoRenderer.isAudioMuted!);
        }
        break;

      case DataChannelCmd.userStatus:
        throw UnimplementedError();
    }
  }

  _getScore() async {
    if (engagementIsRunning || (localVideoRenderer.isVideoMuted ?? false))
      return;

    engagementIsRunning = true;

    try {
      final image = await captureFrameFromVideo(localVideoRenderer);
      final img = base64Encode(image!.asUint8List().toList()).toString();

      // final activeModules =
      //     user?.modules.where((m) => m.enabled == 1).toList() ?? [];

      for (final module in activeModules) {
        final result = await _api.getModuleScore(
          url: module.url,
          name: module.name,
          callId: callId!,
          image: img,
          participantId: user!.id,
        );

        if (result != null) {
          module.isPercentage = result.isPercentage;
          final multiplier = result.isPercentage ? 100 : 1;
          final scoreInt = (result.score! * multiplier).toInt();
          // final scoreInt = 6;

          videoState.streamsToBeRendered['local']?.moduleScores[module] = scoreInt;
          videoState.streamsToBeRendered['local']?.addSpot(result.name, scoreInt, module.id);

          // Šalji na server za sve module
          await _createEngagementOnServer(result.score!, result.name);

          // Dodatno šalji na engagement endpoint samo za engagement module
          if (result.name == 'engagement') {
            await _sendMyEngagementToServer(result.score!);
          }

          _sendMyEngagementToOthers(score: scoreInt, name: result.name);
        }
      }

      _refreshStreams();
    } finally {
      engagementIsRunning = false;
      if (engagementEnabled) {
        await Future.delayed(const Duration(seconds: 3));
        _getScore();
      }
    }
  }

  // _sendMyTrackStatus() async {
  //
  //   var data = {
  //     'audioMuted': localVideoRenderer.isAudioMuted,
  //     'videoMuted': localVideoRenderer.isVideoMuted,
  //   };
  //
  //   print("send my track status");
  //   await videoPlugin?.sendData(jsonEncode(DataChannelCommand(
  //           command: DataChannelCmd.trackStatus,
  //           id: user!.id.toString(),
  //           data: data)
  //       .toJson()));
  // }
  //
  // _askForMuteStatus() async
  // {
  //   print("ask for mute statuses");
  //   var data = {};
  //   await videoPlugin?.sendData(jsonEncode(DataChannelCommand(
  // command: DataChannelCmd.askForTrackStatus,
  // id: user!.id.toString(),
  // data: data)
  //     .toJson()));
  // }

  _sendMyEngagementToServer(double engagement) async {
    await _api.sendEngagement(
        engagement: engagement, userId: user!.id.toString(), callId: callId);
  }

  _createEngagementOnServer(double value, String moduleName) async {
    try {
      // Pronađi module_id na osnovu moduleName
      final module = user?.modules.firstWhere(
        (m) => m.name.toLowerCase() == moduleName.toLowerCase(),
        orElse: () => user!.modules.first, // fallback na prvi modul
      );

      if (module != null) {
        await _api.createEngagement(
          meetingId: callId!,
          userId: int.parse(user!.id),
          moduleId: module.id,
          value: value,
        );
        print('Engagement kreiran za $moduleName: $value');
      }
    } catch (e) {
      print('Greška pri kreiranju engagement-a: $e');
    }
  }

  _sendMyEngagementToOthers({
    int? score,
    String? name,
  }) async {
    final List<Map<String, dynamic>> modulesToSend = [];

    if (score != null) {
      modulesToSend.add({'name': name, 'value': score});
    }

    if (modulesToSend.isEmpty) return;

    final data = {'modules': modulesToSend};

    await videoPlugin?.sendData(
      jsonEncode(
        DataChannelCommand(
          command: DataChannelCmd.engagement,
          id: user!.id.toString(),
          data: data,
        ).toJson(),
      ),
    );
  }

  _broadcastMessage(String msg) async {
    var data = {
      "message": msg,
      'displayName': user!.name,
      'time': DateTime.now().toIso8601String(),
      'avatarUrl': user!.imageUrl
    };

    await videoPlugin?.sendData(jsonEncode(DataChannelCommand(
            command: DataChannelCmd.message,
            id: user!.id.toString(),
            data: data)
        .toJson()));
  }

  bool engagementEnabled = true;
  bool engagementIsRunning = false;

  @override
  Future<void> toggleEngagement({required bool enabled}) async {
    engagementEnabled = enabled;
    _getScore();
  }

  @override
  Future<ApiResponse<bool>> sendMessage(String msg,
      {List<PlatformFile>? uploadedFiles}) async {
    messages.add(ChatMessage(
      files: uploadedFiles,
      message: msg,
      displayName: 'Me',
      time: DateTime.now(),
      avatarUrl: user!.imageUrl,
      seen: true,
    ));
    _conferenceChatStream.add(messages);
    await _broadcastMessage(msg);
    return ApiResponse(response: true);
  }

  List<MediaRecorder> recorderList = [];
  var currentIndexRecording = "";
  bool recording = false;
  List<dynamic> blobs = []; // Store video blobs
  List<Future<void>> stopFutures = [];

  // flutterWebRTC.MediaRecorder? mediaRecorder;

  Future<void> startRecordStream(MediaStream stream) async {
    MediaRecorder? mediaRecorder = MediaRecorder();
    try {
      print("mediaRecorder: $mediaRecorder");
      mediaRecorder.startWeb(stream, mimeType: 'video/webm;codecs=vp8,opus');
      recorderList.add(mediaRecorder);
    } catch (e) {
      print("Error starting recording: $e");
    }
  }

  _startRecord(MediaStream stream) async {
    try {
      if (stream.id != currentIndexRecording && recording) {
        await stopRecord();
        print('=============================');
        print(stream.id);
        print('=============================');
        startRecordStream(stream);
        currentIndexRecording = stream.id;
      }
    } catch (e) {
      print("Error starting recording: $e");
      return false;
    }
  }

  Future<StreamRenderer> getItemByIndex(int index) async {
    Map<dynamic, StreamRenderer> streams = await _conferenceStream.stream.first;
    if (index < 0 || index >= streams.length) {
      throw RangeError("Index out of range");
    }
    return streams.values.elementAt(index);
  }

  @override
  Future<bool> startRecording() async {
    try {
      recorderList = [];
      blobs = [];
      currentIndexRecording = "";
      recording = true;

      StreamRenderer stream = await getItemByIndex(0);
      _startRecord(stream.mediaStream!);
      return true;
    } catch (e) {
      print("Error starting recording: $e");
      recording = false;
      return false;
    }
  }

  stopRecord() async {
    print('===============_stopRecord_==============');
    if (recorderList.isNotEmpty) {
      for (var recorder in List.from(recorderList)) {
        stopFutures.add(recorder.stop().then((blob) {
          blobs.add(blob); // Add the actual Blob, not a URL
          recorderList.remove(recorder);
          print('=============== blob: $blob ==============');
          print('=============== recorderList.remove ==============');
        }));
      }
    }

    await Future.wait(stopFutures).then((v) {
      print('===============_stopRecord_ finish ==============');
    }); // Ensure all recordings are stopped
  }

  @override
  Future<void> stopRecording() async {
    await stopRecord();
    recording = false;
    if (blobs.isNotEmpty) {
      mergeVideos(blobs);
    } else {
      print("Not enough videos to merge.");
    }
    // }
  }

  Future<List<Uint8List>> fetchVideoData(List<String> urls) async {
    return await Future.wait(urls.map((url) async {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          print("Success to fetch video: $url");
          return response.bodyBytes;
        } else {
          print("Failed to fetch video: $url");
          throw Exception('Failed to load file');
        }
      } catch (e) {
        print("Error fetching video from $url: $e");
        rethrow;
      }
    }));
  }

  Future<Uint8List> fetchDataFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.bodyBytes; // Return the byte data of the file
    } else {
      throw Exception('Failed to load file from URL');
    }
  }

  // void mergeVideos(List<dynamic> blobs) {
  //   // final js.JsArray blobArray = js.JsArray.from(blobs);

  //   // Call the JavaScript function directly
  //   // js.context.callMethod('concatenateVideos', [blobArray]);
  // }

  void downloadRecording(String blob) async {
    print("Recording downloaded.");

    final Uri url = Uri.parse(blob);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $blob');
    }
  }

  @override
  Future<MeetingDto?> startCall() async {
    var res = await _api.startCall(streamId: room.toString(), userId: user?.id);
    callId = res.response?.callId;
    return res.response;
  }

  @override
  Stream<String> getToastStream() {
    return _conferenceToastMessageStream.stream;
  }

  @override
  Stream<void> getUserTalkingStream() {
    return _userIsTalkingStream.stream;
  }

  @override
  Stream<Map<dynamic, StreamRenderer>> getConferenceScreenShareStream() {
    return _conferenceScreenShareStream.stream;
  }

  bool isScreenShare(String id) {
    var key = int.tryParse(id);
    if (key == null) return false;

    return key % 1000 == 999;
  }

  int getUserIdFromScreenShareId(int screenShareId) {
    return screenShareId ~/ 1000;
  }
}
