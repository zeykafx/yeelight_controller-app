import 'dart:async';

import 'package:yeedart/yeedart.dart';

class YeelightApi {
  Device? device;
  bool devicePower = false;
  int deviceBrightness = 0;
  late Timer timer;

  YeelightApi() {
    getLights();
    timer = Timer.periodic(const Duration(seconds: 4), (Timer t) => getCurrentPower());
  }

  Future<void> getLights() async {
    await Yeelight.discover().then((value) {
      if (value.isNotEmpty) {
        DiscoveryResponse lightStrip = value[0];
        device = Device(
          address: lightStrip.address,
          port: lightStrip.port!,
        );
        devicePower = lightStrip.powered != null ? lightStrip.powered! : false;
      }
    });
  }

  void disconnect() {
    device!.disconnect();
    device = null;
  }

  Future<void> getCurrentPower() async {
    await device?.getProps(id: 1, parameters: ["bright, power"]).then((response) {
      if (response != null && response.result![0] != "ok") {
        deviceBrightness = int.parse(response.result![0]);
        devicePower = response.result![1] == 'on';
      }
    });
  }

  Future<void> toggleLights() async {
    device!.toggle();

    await Future<void>.delayed(const Duration(milliseconds: 200)).then((_) {
      getCurrentPower();
    });
  }

  Future<void> startFlow() async {
    FlowTransition transitionSpeed = const FlowTransition.sleep(duration: Duration(milliseconds: 2000));
    await device!.startFlow(
      flow: Flow(
        count: 0,
        action: const FlowAction.recover(),
        transitions: [
          const FlowTransition.rgb(color: 0xff0000, brightness: 100, duration: Duration(milliseconds: 3000)),
          transitionSpeed,
          const FlowTransition.rgb(color: 0x00ff00, brightness: 100, duration: Duration(milliseconds: 3000)),
          transitionSpeed,
          const FlowTransition.rgb(color: 0x00ffff, brightness: 100, duration: Duration(milliseconds: 3000)),
          transitionSpeed,
        ],
      ),
    );
  }



}
