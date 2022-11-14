import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:yeelight_controller_app/Components/color_dialog.dart';

import '../Api/yeelight_api.dart';

class Home extends HookWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    YeelightApi yeelightApi = YeelightApi();

    return Scaffold(
      body: Center(
          child: <Widget>[
            Text(
                yeelightApi.device != null ? "Connected" : "Disconnected"
            )
                .textColor(yeelightApi.device != null ? Colors.green : Colors.red)
                .padding(all: 4)
                .boxShadow(
                  color: yeelightApi.device != null ? Colors.green : Colors.red,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: -12
                ),

            Text("LED status: ${yeelightApi.devicePower ? "On" : "Off"}, brightness: ${yeelightApi.deviceBrightness}%"),

            ElevatedButton(
              onPressed: () {
                yeelightApi.device != null ? yeelightApi.disconnect() : yeelightApi.getLights();
              },
              child: Text(yeelightApi.device != null ? 'Disconnect' : "Connect"),
            ),

            ElevatedButton(
              onPressed: () {
                yeelightApi.toggleLights();
              },
              child: Text(yeelightApi.devicePower ? 'Turn Off' : "Turn On"),
            ),

            ElevatedButton(
              onPressed: () {
                yeelightApi.startFlow();
              },
              child: const Text('Start flow'),
            ),

            ElevatedButton(
              onPressed: () => showDialog(context: context, builder: (BuildContext context) => ColorDialog(yeelightApi: yeelightApi)),
              child: const Text("Change color & brightness"),
            ),
      ].toColumn(mainAxisAlignment: MainAxisAlignment.center, separator: Styled.widget().padding(vertical: 8))),
    );
  }
}
