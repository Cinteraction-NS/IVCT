import '../janus/janus_client.dart';

String baseUrl = 'https://'; //backend base url

//janus conf
String url = "wss://"; //janus url
bool withCredentials = false;
String apiSecret = "";
int maxPublishersDefault = 30;

//stun/turn server cong
String mixTurnServerUsername = 'username';
String mixTurnServerCredential = 'password';


String turnServerURL = '';
String stunServerURL = 'stun:stun.l.google.com:19302';

List<RTCIceServer> iceServers = <RTCIceServer>[

  RTCIceServer(urls: stunServerURL, username: "", credential: ""),
  RTCIceServer(
      urls: "$turnServerURL?transport=udp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential),
  RTCIceServer(
      urls: "$turnServerURL?transport=tcp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential),

];