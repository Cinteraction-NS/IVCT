import 'dart:io';

import 'package:cinteraction_vc/core/navigation/router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app/app.dart';
import 'package:loggy/loggy.dart';

import 'core/app/injector.dart';
import 'core/deep_link_router.dart';
import 'core/util/nonweb_url_strategy.dart' if (dart.library.html) 'core/util/web_url_strategy.dart';

late SharedPreferences sharedPref;

Future<void> main() async {

  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();
  _initLoggy();
  _initGoogleFonts();

  sharedPref = await SharedPreferences.getInstance();
  await initializeGetIt();

  GoRouter.optionURLReflectsImperativeAPIs = true;


  // await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform
  // );

  configureUrl();
  runApp(const CinteractionFlutterApp());

  DeepLinkHandler.init((route) {
    print('🟢 Navigating to $route from main');
    _navKey.currentState?.context.go(route);
    router.push(route);
  });
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void _initLoggy() {
  Loggy.initLoggy(
    logOptions: const LogOptions(
      LogLevel.all,
      stackTraceLevel: LogLevel.warning,
    ),
    logPrinter: const PrettyPrinter(),
  );
}

void _initGoogleFonts() {
  GoogleFonts.config.allowRuntimeFetching = false;

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
}
