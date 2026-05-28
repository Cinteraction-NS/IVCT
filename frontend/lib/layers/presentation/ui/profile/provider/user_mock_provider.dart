import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../domain/entities/user.dart';



User get _mockUser =>
    User(
      id: "23",
      name: 'John Doe',
      email: 'john@test.com',
      imageUrl:
      'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
      createdAt: DateTime.now(),
    );

class ProfileProvider {
  ProfileProvider() {
    triggerNotLoggedIn();
  }


  /// The scopes required by this application.
  static const List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional clientId
    // clientId: '86369065781-lpajm2ln4bu8ds7vlb6780rmq0evae3o.apps.googleusercontent.com',
    scopes: scopes,
  );

  final _userStream = StreamController<User?>.broadcast();
  final _errorStream = StreamController<String>.broadcast();

  Stream<User?> getUserStream() => _userStream.stream;
  Stream<String> getErrorStream() => _errorStream.stream;

  Future<User?> triggerLoggedIn() async {
    await _networkDelay();

    final user = _mockUser;
    _userStream.add(user);
    return user;
  }

  Future<User?> loginWithEmailPassword(String email, String pass) async {
    // await _networkDelay();
    // SignIn handler = SignIn(email: email, password: pass);

    // var response = await handler.execute();
    //
    //
    // if(response != null)
    // {
    //   try
    //   {
    //     var auth = LoginResponse.fromJson(response);
    //
    //     final user = _mockUser;
    //     _userStream.add(user);
    //     return user;
    //   }
    //   on Exception catch(e){
    //     _userStream.add(null);
    //     _errorStream.add(response['message'] as String);
    //     return null;
    //   }
    // }
    // else{
    //   _userStream.add(null);
    //   _errorStream.add('Something went wrong');
    //   return null;
    // }
  }


  Future<User?> triggerGoogleLoggedIn() async {
      var googleUser = await _googleSignIn.signIn();
      bool isAuthorized = googleUser != null;
      // However, on web...

      if (kIsWeb && googleUser != null) {
        isAuthorized = await _googleSignIn.canAccessScopes(scopes);
      }

      if (isAuthorized && googleUser != null) {
        final user = User(
            id: "23",
            name: googleUser.displayName ?? "",
            email: googleUser.email,
            imageUrl: googleUser.photoUrl ?? "",
            createdAt: DateTime.now()
        );

        _userStream.add(user);
        return user;
      }

    _userStream.add(null);
    return null;
  }

  Future<User?> triggerFacebookLoggedIn() async {

    final LoginResult loginResult = await FacebookAuth.instance.login();

    if (loginResult.status == LoginStatus.success) {
      // _accessToken = loginResult.accessToken;
      final userInfo = await FacebookAuth.instance.getUserData();

        print('Facebook user: ${userInfo['name']}');

        // final user = _mockUser;
      final user = User(
          id: userInfo['id'],
          name: userInfo['name'],
          email: userInfo['email'],
          imageUrl: 'http://graph.facebook.com/${userInfo['id']}/picture?',
          createdAt: DateTime.now()
      );

      _userStream.add(user);
      return user;

    } else {
      print('ResultStatus: ${loginResult.status}');
      print('Message: ${loginResult.message}');
    }

    _userStream.add(null);
    return null;
  }




    Future<void> triggerNotLoggedIn() async {
    await _networkDelay();
    _userStream.add(null);
    }

    void triggerLoggedOut() {
    _userStream.add(null);
    _googleSignIn.signOut();
    }

    /// Simulate network delay
    Future<void> _networkDelay() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    }
  }
