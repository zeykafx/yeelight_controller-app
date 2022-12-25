import 'dart:async';
import 'dart:ui';
import 'package:yeelight_controller_app/Extensions/hex_color.dart';

import 'package:yeedart/yeedart.dart';

class YeelightApi {
  Device? device;
  bool devicePower = false;
  int deviceBrightness = 1;
  late Timer timer;

  final void Function() onStateChanged;

  YeelightApi({
    required this.onStateChanged,
  }) {
    getLights();
    getCurrentPower();
    timer = Timer.periodic(
        const Duration(seconds: 4), (Timer t) => getCurrentPower());
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
    device!.disconnect();
    device = null;
  }

  /// sets deviceBrightness and devicePower with the current brightness and power
  Future<void> getCurrentPower() async {
    await device?.getProps(parameters: ["bright", "power"]).then((response) {
      if (response != null &&
          response.result!.first != "" &&
          response.result![0] != "ok") {
        deviceBrightness = int.parse(response.result![0]);
        devicePower = response.result![1] == 'on';
      }
      onStateChanged();
    });
  }

  Future<Color?> getCurrentColor() async {
    CommandResponse? response = await device?.getProps(parameters: ["rgb"]);
      if (response != null) {
        // print(HexColor.fromHex(response.result?.first));
        Color currentColor = Color(int.parse(response.result?[0]));

        return currentColor;
      } else {
        return const Color(0xffff0000);
      }
  }

  /// toggles the lights, if on -> off and vice versa
  Future<void> toggleLights() async {
    devicePower ? device?.turnOff() : device?.turnOn();
    // device?.toggle();
    devicePower = !devicePower;
    onStateChanged();

    getCurrentPower();
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
