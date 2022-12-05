import "dart:async";
import "dart:developer";

import "package:after_layout/after_layout.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:local_auth_demo/singleton/local_auth_singleton.dart";
import "package:status_alert/status_alert.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage>
    with WidgetsBindingObserver, AfterLayoutMixin<HomePage> {
  final LocalAuthSingleton _auth = LocalAuthSingleton();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Local Authentication Demo"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: Row(
          children: <Widget>[
            Icon(
              LocalAuthSingleton().isUnlocked
                  ? Icons.lock_outlined
                  : Icons.lock_open_outlined,
            ),
            const SizedBox(width: 10),
            Text(
              LocalAuthSingleton().isUnlocked ? "Lock" : "Unlock",
            ),
          ],
        ),
        onPressed: () async {
          await HapticFeedback.vibrate();
          LocalAuthSingleton().isUnlocked == true
              ? LocalAuthSingleton().isUnlocked = false
              : await LocalAuthSingleton().authenticate(
                  mounted: mounted,
                  showStatusAlert: (bool didAuthenticate) {
                    StatusAlert.show(
                      context,
                      duration: const Duration(seconds: 1),
                      title: "Authentication",
                      subtitle: didAuthenticate ? "Successfully" : "Failed",
                      configuration: IconConfiguration(
                        icon: didAuthenticate ? Icons.check : Icons.close,
                      ),
                      maxWidth: MediaQuery.of(context).size.width,
                    );
                  },
                  showSnackBar: (PlatformException e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.message ?? ""),
                      ),
                    );
                  },
                );
          setState(() {});
        },
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              textAndIconWidget(
                text: "Can Check Biometrics?",
                value: _auth.canCheckBiometrics,
              ),
              textAndIconWidget(
                text: "Is Device Supported?",
                value: _auth.isDeviceSupported,
              ),
              textAndIconWidget(
                text: "Can Authenticate?",
                value: _auth.canAuthenticate,
              ),
              textAndIconWidget(
                text: "Has Available Biometrics?",
                value: _auth.hasAvailableBiometrics,
              ),
              Text(
                "Available Biometrics List : ${_auth.availableBiometricsName}",
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await localAuthInit();
        break;
      case AppLifecycleState.inactive:
        log("AppLifecycleState: $state");
        break;
      case AppLifecycleState.paused:
        log("AppLifecycleState: $state");
        break;
      case AppLifecycleState.detached:
        log("AppLifecycleState: $state");
        break;
    }
  }

  Future<void> localAuthInit() async {
    if (LocalAuthSingleton().availableBiometrics.isNotEmpty) {
      LocalAuthSingleton().availableBiometrics.clear();
    }
    if (LocalAuthSingleton().availableBiometricsName.isNotEmpty) {
      LocalAuthSingleton().availableBiometricsName.clear();
    }
    await LocalAuthSingleton().canCheckBiometricsFunction();
    await LocalAuthSingleton().isDeviceSupportedFunction();
    await LocalAuthSingleton().canAuthenticateFunction();
    await LocalAuthSingleton().fetchAvailableBiometricsFunction();
    LocalAuthSingleton().hasAvailableBiometricsFunction();
    setState(() {});
    return Future<void>.value();
  }

  Column textAndIconWidget({required String text, required bool value}) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(text),
            const SizedBox(width: 10),
            Icon(value ? Icons.check : Icons.close, size: 20),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    await localAuthInit();
  }
}
