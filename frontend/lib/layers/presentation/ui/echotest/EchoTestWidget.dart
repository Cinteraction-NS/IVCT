import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logging/logging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/janus/janus_client.dart';
import '../../../../core/util/conf.dart';

class EchoTestWidget extends StatefulWidget {
  const EchoTestWidget({super.key});

  @override
  State<EchoTestWidget> createState() => _JanusEchoTestWidgetState();
}

class _JanusEchoTestWidgetState extends State<EchoTestWidget> {
  JanusClient? janusClient;
  JanusSession? session;
  JanusEchoTestPlugin? echotestPlugin;

  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _initJanus();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _initJanus() async {
    WebSocketJanusTransport ws = WebSocketJanusTransport(url: url);

    janusClient = JanusClient(
      transport: ws,
      withCredentials: true,
      apiSecret: apiSecret,
      isUnifiedPlan: true,
      iceServers: iceServers,
      loggerLevel: Level.FINE,
    );

    session = await janusClient!.createSession();
    echotestPlugin = await session!.attach<JanusEchoTestPlugin>();

    echotestPlugin!.messages?.listen((payload) async {
      print("[ECHO] Received ${payload.event}");
      if (payload.jsep != null) {
        print("[ECHO] Received JSEP, setting remote description.");
        await echotestPlugin!.handleRemoteJsep(payload.jsep);
      }
    });

    echotestPlugin!.webRTCHandle?.peerConnection?.onIceConnectionState = (state) {
      print("ICE state: $state");
    };

    echotestPlugin!.remoteStream?.listen((mediaStream) {
      print("================");
      _remoteRenderer.srcObject = mediaStream;
    });

    echotestPlugin!.webRTCHandle?.peerConnection?.onTrack = (RTCTrackEvent event) {
      print("🔁 Received remote track: ${event.track.kind}");
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams[0];
      }
    };

    // echotestPlugin!.errors?.listen((err) {
    //   print('[ECHO] Error: $err');
    // });

    await echotestPlugin!.initializeMediaDevices();
    _localRenderer.srcObject = echotestPlugin!.webRTCHandle!.localStream;

    var offer = await echotestPlugin!.createOffer(audioRecv: true, videoRecv: true);

    var payload = {
      "audio": true,
      "video": true,
      "bitrate": 128000,
    };

    echotestPlugin?.send(data: payload, jsep: offer);

    setState(() => isConnected = true);
  }


  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    session?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Janus EchoTest')),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            isConnected ? '✅ Connected via EchoTest' : '🔌 Connecting...',
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(),
          const Text('📷 Local Video'),
          SizedBox(
            width: 200,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: RTCVideoView(_localRenderer, mirror: true),
            ),
          ),
          const Text('🪞 Remote (Echoed) Video'),
          SizedBox(
            width: 200,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: RTCVideoView(_remoteRenderer),
            ),
          ),
        ],
      ),
    );
  }
}
