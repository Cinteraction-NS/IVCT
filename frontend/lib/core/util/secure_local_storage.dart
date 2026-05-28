import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

const String keyAccessToken = 'access_token';

// to save token in local storage
Future<bool> saveAccessToken(String? accessToken) async {
  await storage.write(key: keyAccessToken, value: accessToken);
  print('Access token is saved $accessToken');

  return true;
}

Future<String?> getAccessToken() async {
  // print(storage.read(key: keyAccessToken));
  var accessToken = await storage.read(key: keyAccessToken);
  if (accessToken != null) {
    // print('Bearer $accessToken');
    return 'Bearer $accessToken';
  }
  return null;
}
