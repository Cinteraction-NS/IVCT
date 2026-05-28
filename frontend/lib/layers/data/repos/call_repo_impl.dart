import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cinteraction_vc/core/util/util.dart';
import 'package:cinteraction_vc/layers/domain/repos/call_repo.dart';
import 'package:flutter/foundation.dart';

import '../../../core/app/injector.dart';
import '../../../core/janus/janus_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/source/api.dart';
import '../source/local/local_storage.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallRepoImpl extends CallRepo {
  CallRepoImpl({required Api api}) : _api = api;

  final Api _api;

  late JanusVideoCallPlugin videoCallPlugin;
  late StreamRenderer _localVideoRenderer;
  late StreamRenderer _remoteVideoRenderer;
  late RTCSessionDescription? remoteJsep;

  final _localStream = StreamController<StreamRenderer>.broadcast();
  final _remoteStream = StreamController<StreamRenderer>.broadcast();
  final _videoCallStream = StreamController<Result>.broadcast();

  User? user = getIt.get<LocalStorage>().loadLoggedUser();
  late String myId = user?.id ?? "";
  late String displayName = user?.name ?? 'User $myId';

  late JanusSession _session;

  List<MediaDeviceInfo>? _mediaDevicesList;

  @override
  Future<void> initialize() async {
    await _configureConnection();
    loadDevices();
  }

  @override
  Future<void> makeCall(String user) async {
    await _configureLocalVideoRenderer();

    // await videoCallPlugin.call(user);

    var offer = await videoCallPlugin.createOffer(
      audioRecv: true,
      videoRecv: true,
    );
    await videoCallPlugin.call(user, offer: offer);
  }

  Future<void> loadDevices() async {
    // if (WebRTC.platformIsAndroid || WebRTC.platformIsIOS) {
    //Ask for runtime permissions if necessary.
    //   var status = await Permission.bluetooth.request();
    //   if (status.isPermanentlyDenied) {
    //     print('BLEpermdisabled');
    //   }
    //   status = await Permission.bluetoothConnect.request();
    //   if (status.isPermanentlyDenied) {
    //     print('ConnectPermdisabled');
    //   }
    // }
    final devices = await navigator.mediaDevices.enumerateDevices();
    // setState(() {
    _mediaDevicesList = devices;
    // });
  }

  _addOnEndedToTrack(MediaStreamTrack track) {
    track.onEnded ??= () => _replaceAudioTrack();
  }

  _replaceAudioTrack() async {
    print('track is ended');
    var stream = await navigator.mediaDevices.getUserMedia({'audio': true});
    var audioTrack = stream.getAudioTracks()[0];

    // audioTrack.onEnded = () =>_replaceAudioTrack();
    _addOnEndedToTrack(audioTrack);

    List<RTCRtpSender>? senders =
        await videoCallPlugin.webRTCHandle?.peerConnection?.senders;
    senders?.forEach((sender) async {
      if (sender.track?.kind == 'audio') {
        await sender.replaceTrack(audioTrack);
        print('${sender.track?.label} track is replaced');
      }
    });
  }

  _selectAudioInput(String deviceId) async {
    print(deviceId);
    await Helper.selectAudioInput(deviceId);
  }

  @override
  Future<void> answerCall() async {
    await _configureLocalVideoRenderer();
    await videoCallPlugin.handleRemoteJsep(remoteJsep);
    var answer = await videoCallPlugin.createAnswer();
    await videoCallPlugin.acceptCall(answer: answer);
  }

  bool rejectedCall = false;

  @override
  Future<void> rejectCall(String from) async {
    if (rejectedCall) {
      return;
    }
    rejectedCall = true;

    await videoCallPlugin.hangup();
    cleanUpWebRTCStuff();
    _session.dispose();
    _videoCallStream.add((Result(event: "rejected", username: "")));
    remoteJsep = null;
    await _configureConnection();
    rejectedCall = false;
  }

  @override
  Stream<StreamRenderer> getLocalStream() {
    return _localStream.stream;
  }

  @override
  Stream<StreamRenderer> getRemoteStream() {
    return _remoteStream.stream;
  }

  @override
  Stream<Result> getVideoCallStream() {
    return _videoCallStream.stream;
  }

  _configureConnection() async {
    // _session = await _client.createSession();
    _session = await getIt.getAsync<JanusSession>();

    videoCallPlugin = await _session.attach<JanusVideoCallPlugin>();
    await videoCallPlugin.initializeWebRTCStack();
    await videoCallPlugin.initDataChannel();

    _remoteVideoRenderer = StreamRenderer('remote', 'remote');
    await _remoteVideoRenderer.init();

    videoCallPlugin.data?.listen((event) async {
      // var encodedString = jsonEncode(jsonEncode(event.text));
      Map<String, dynamic> data = json.decode(event.text);

      switch (data["request"]) {
        case "set":
          if (data.containsKey("audio")) {
            _manageMuteUIEvents("audio", data["audio"]);
          }

          if (data.containsKey("video")) {
            _manageMuteUIEvents("video", data["video"]);
          }
      }
    });
    videoCallPlugin.webRTCHandle?.peerConnection?.onConnectionState =
        (connectionState) async {
      print("PEER CONNECTION STATE: $connectionState");
      if (connectionState ==
          RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        print('connection established');
      }
    };

    videoCallPlugin.remoteTrack?.listen((event) async {
      print(event);

      if (event.track != null && event.flowing == true) {
        print("${event.track}");
        _remoteVideoRenderer.mediaStream?.addTrack(event.track!);
        _remoteVideoRenderer.videoRenderer.srcObject =
            _remoteVideoRenderer.mediaStream;
        // this is done only for web since web api are muted by default for local tagged mediaStream
        if (kIsWeb) {
          _remoteVideoRenderer.videoRenderer.muted = false;
        }
        _remoteStream.add(_remoteVideoRenderer);
      }
    });

    videoCallPlugin.typedMessages?.listen((even) async {
      Object data = even.event.plugindata?.data;

      if (data is VideoCallRegisteredEvent) {
        print('VideoCallRegisteredEvent');
      }
      if (data is VideoCallIncomingCallEvent) {

        remoteJsep = even.jsep;
        _videoCallStream.add(data.result!);
      }
      if (data is VideoCallAcceptedEvent) {
        print("video call is accepted");
        _videoCallStream.add(data.result!);
        await videoCallPlugin.handleRemoteJsep(even.jsep);
      }
      if (data is VideoCallCallingEvent) {
        _videoCallStream.add(data.result!);
      }
      if (data is VideoCallUpdateEvent) {
        if (even.jsep != null) {
          if (even.jsep?.type == "answer") {
            videoCallPlugin.handleRemoteJsep(even.jsep);
          } else {
            var answer = await videoCallPlugin.createAnswer();
            await videoCallPlugin.set(jsep: answer);
          }
        }
      }
      if (data is VideoCallHangupEvent) {
        print(VideoCallHangupEvent);
        await destroy();
      }
    }, onError: (error) async {
      if (error is JanusError) {
        print(error);
      }
    });
    _registerUser();
  }

  _manageMuteUIEvents(String kind, bool muted) async {
    print("_manageMuteUIEvents $kind $muted");
    if (kind == 'audio') {
      _remoteVideoRenderer.isAudioMuted = muted;
    } else {
      _remoteVideoRenderer.isVideoMuted = muted;
    }
    _remoteStream.add(_remoteVideoRenderer);
  }

  @override
  Future<void> mute({required String kind, required bool muted}) async {
    print("$kind $muted");
    var payload = {
      "request": "set",
      kind: muted,
    };

    await videoCallPlugin.sendData(jsonEncode(payload));

    _localVideoRenderer.mediaStream
        ?.getTracks()
        .where((element) => element.kind == kind)
        .toList()
        .forEach((element) {
      print('mid: ${element.id}');
      element.enabled = !muted;
    });

    if (kind == 'audio') {
      _localVideoRenderer.isAudioMuted = muted;
    } else {
      _localVideoRenderer.isVideoMuted = muted;
    }
  }

  Future<void> _registerUser() async {
    print("regiter user");
    await videoCallPlugin.register(myId);
  }

  destroy() async {
    rejectCall("from destroy");
  }

  _configureLocalVideoRenderer() async {
    _localVideoRenderer = StreamRenderer('local', 'local');
    await _localVideoRenderer.init();
    _localVideoRenderer.mediaStream =
        await videoCallPlugin.initializeMediaDevices(mediaConstraints: {
      'video': {'width': 640, 'height': 360},
      'audio': true
    });

    _localVideoRenderer.videoRenderer.srcObject =
        _localVideoRenderer.mediaStream;
    _localVideoRenderer.publisherName = displayName;
    _localVideoRenderer.publisherId = myId.toString();

    _localStream.add(_localVideoRenderer);
  }

  Future<void> cleanUpWebRTCStuff() async {
    try {
      _localVideoRenderer.dispose();
      _localVideoRenderer.videoRenderer.srcObject = null;
    } catch (e) {}

    try {
      _remoteVideoRenderer.dispose();
      _remoteVideoRenderer.videoRenderer.srcObject = null;
    } catch (e) {
      // print(e.toString());
    }
  }
}
