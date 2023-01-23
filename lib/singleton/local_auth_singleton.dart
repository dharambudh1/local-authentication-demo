import "dart:async";
import "dart:developer";

import "package:flutter/services.dart";
import "package:local_auth/local_auth.dart";
// import "package:local_auth/error_codes.dart" as auth_error;

class LocalAuthSingleton {
  factory LocalAuthSingleton() {
    return _singleton;
  }

  LocalAuthSingleton._internal();

  static final LocalAuthSingleton _singleton = LocalAuthSingleton._internal();

  final LocalAuthentication auth = LocalAuthentication();

  bool canCheckBiometrics = false;
  bool isDeviceSupported = false;
  bool canAuthenticate = false;
  List<BiometricType> availableBiometrics = <BiometricType>[];
  List<String> availableBiometricsName = <String>[];
  bool hasAvailableBiometrics = false;
  bool isUnlocked = false;

  Future<void> canCheckBiometricsFunction() async {
    canCheckBiometrics = await auth.canCheckBiometrics;
    log("canCheckBiometrics: $canCheckBiometrics");
    return Future<void>.value();
  }

  Future<void> isDeviceSupportedFunction() async {
    isDeviceSupported = await auth.isDeviceSupported();
    log("isDeviceSupported: $isDeviceSupported");
    return Future<void>.value();
  }

  Future<void> canAuthenticateFunction() async {
    canAuthenticate = canCheckBiometrics || isDeviceSupported;
    log("canAuthenticate: $canAuthenticate");
    return Future<void>.value();
  }

  Future<void> fetchAvailableBiometricsFunction() async {
    availableBiometrics = await auth.getAvailableBiometrics();
    for (final BiometricType element in availableBiometrics) {
      availableBiometricsName.add(element.name);
      log("availableBiometrics: ${element.name}");
    }
  }

  void hasAvailableBiometricsFunction() {
    availableBiometrics.isEmpty
        ? hasAvailableBiometrics = false
        : hasAvailableBiometrics = true;
    log("hasAvailableBiometrics: $hasAvailableBiometrics");
  }

  Future<void> authenticate({
    required bool mounted,
    required void Function(bool didAuthenticate) showStatusAlert,
    required void Function(PlatformException e) showSnackBar,
  }) async {
    try {
      final bool didAuthenticate = await LocalAuthSingleton().auth.authenticate(
            localizedReason: "Please authenticate to unlock content",
          );
      log("didAuthenticate: $didAuthenticate");
      LocalAuthSingleton().isUnlocked = didAuthenticate;
      if (mounted) {
        showStatusAlert(didAuthenticate);
      } else {
        return Future<void>.value();
      }
    } on PlatformException catch (e) {
      log("PlatformException Error: ${e.toString()}");
      log("PlatformException Error code: ${e.code}");
      log("PlatformException Error message: ${e.message}");
      log("PlatformException Error details: ${e.details}");
      log("PlatformException Error stacktrace: ${e.stacktrace}");
      showSnackBar(e);
    } finally {
      final bool stopped = await LocalAuthSingleton().auth.stopAuthentication();
      log("stopAuthentication: $stopped");
    }
    return Future<void>.value();
  }
}
