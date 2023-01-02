import 'dart:async';
import 'dart:ui';

import 'package:yeedart/yeedart.dart';

class YeelightApi {
  Device? device;
  bool devicePower = false;
  bool isDeviceFlowing = false;
  int deviceBrightness = 1;
  late Timer timer;

  final void Function() onStateChanged;

  YeelightApi({
    required this.onStateChanged,
  }) {
    getLights();
    getCurrentStatus();
    timer = Timer.periodic(
        const Duration(seconds: 4), (Timer t) => getCurrentStatus());
  }

  /// discovers lights on the local network
  Future<void> getLights() async {
    await Yeelight.discover().then((value) {
      if (value.isNotEmpty) {
        DiscoveryResponse lightStrip = value[0];
        device = Device(
          address: lightStrip.address,
          port: lightStrip.port!,
        );
        devicePower = lightStrip.powered != null ? lightStrip.powered! : false;
        onStateChanged();
      }
    });
  }

  /// disconnects from the connected LEDs
  void disconnect() {
    if (device == null) {
      device!.disconnect();
    }
    device = null;
    onStateChanged();
  }

  /// sets deviceBrightness and devicePower with the current brightness and power
  Future<void> getCurrentStatus() async {
    try {
      await device?.getProps(parameters: ["bright", "power", "flowing"]).then(
          (response) {
        if (response != null &&
            response.result!.first != "" &&
            response.result![0] != "ok") {
          deviceBrightness = int.parse(response.result![0]);
          devicePower = response.result![1] == 'on';
          isDeviceFlowing = int.parse(response.result![2]) == 1 ? true : false;
        }
        onStateChanged();
      });
    } catch (e) {}
  }

  Future<Color> getCurrentColor() async {
    try {
      CommandResponse? response = await device?.getProps(parameters: ["rgb"]);
      if (response != null) {
        Color currentColor = Color(int.parse(response.result?[0]));
        return currentColor;
      }
    } catch (e) {}
    return const Color(0xffff0000);
  }

  /// toggles the lights, if on -> off and vice versa
  Future<void> toggleLights() async {
    devicePower ? device?.turnOff() : device?.turnOn();
    // device?.toggle();
    devicePower = !devicePower;
    onStateChanged();

    getCurrentStatus();
  }

  /// starts flow mode on the connected LEDs
  Future<void> startFlow() async {
    FlowTransition transitionSpeed =
        const FlowTransition.sleep(duration: Duration(milliseconds: 2000));
    await device!.startFlow(
      flow: Flow(
        count: 0,
        action: const FlowAction.recover(),
        transitions: [
          const FlowTransition.rgb(
              color: 0xff0000,
              brightness: 100,
              duration: Duration(milliseconds: 3000)),
          transitionSpeed,
          const FlowTransition.rgb(
              color: 0x00ff00,
              brightness: 100,
              duration: Duration(milliseconds: 3000)),
          transitionSpeed,
          const FlowTransition.rgb(
              color: 0x00ffff,
              brightness: 100,
              duration: Duration(milliseconds: 3000)),
          transitionSpeed,
        ],
      ),
    );
    onStateChanged();
  }
}
