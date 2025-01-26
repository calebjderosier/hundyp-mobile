import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void logError({required Object e, required StackTrace stackTrace, required bool fatal}) {
  FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
}

void setupLogging() {
  FlutterError.onError = (errorDetails) {
    log(
      'Caught Flutter Error',
      error: errorDetails.exception,
      stackTrace: errorDetails.stack,
      name: 'FlutterError',
    );

    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    FlutterError.presentError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    // also call web here thingy here
    return true;
  };
}
