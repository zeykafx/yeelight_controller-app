import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:yeedart/yeedart.dart';
import 'package:yeelight_controller_app/Components/color_dialog.dart';
import 'package:yeelight_controller_app/Extensions/hex_color.dart';

import '../Api/yeelight_api.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late YeelightApi yeelightApi;

  @override
  void initState() {
    yeelightApi = YeelightApi(onStateChanged: () {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    yeelightApi.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yeelight LED Controller"),
      ),
      body: Center(
          child: <Widget>[
        // Connection status
        Text(yeelightApi.device != null ? "Connected" : "Disconnected")
            .textColor(yeelightApi.device != null ? Colors.green : Colors.red)
            .padding(all: 4)
            .boxShadow(
                color: yeelightApi.device != null ? Colors.green : Colors.red,
                blurRadius: 30,
                spreadRadius: -9),
        // Status and Brightness
        Text(
            "LED status: ${yeelightApi.devicePower ? "On" : "Off"}, Brightness: ${yeelightApi.deviceBrightness}%"),

        // Buttons ---
        ElevatedButton(
          onPressed: () {
            yeelightApi.device != null
                ? yeelightApi.disconnect()
                : yeelightApi.getLights();
          },
          child: Text(yeelightApi.device != null ? "Disconnect" : "Connect"),
        ),

        // turn on/off button
        ElevatedButton(
          onPressed: () {
            yeelightApi.toggleLights();
          },
          child: Text(yeelightApi.devicePower ? "Turn Off" : "Turn On"),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                if (yeelightApi.isDeviceFlowing) {
                  await yeelightApi.device!.setRGB(
                    color: const Color(0xffff0000).toHex(),
                    effect: const Effect.smooth(),
                    duration: const Duration(milliseconds: 200),
                  );
                } else {
                  yeelightApi.startFlow();
                }
              },
              child: Text(
                  yeelightApi.isDeviceFlowing ? "Disable Flow" : "Enable Flow"),
            ),
            const Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 4)),
            ElevatedButton(
              onPressed: () => showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      ColorDialog(yeelightApi: yeelightApi)),
              child: const Text("Change Color"),
            ),
          ],
        ),
      ].toColumn(
              mainAxisAlignment: MainAxisAlignment.center,
              separator: Styled.widget().padding(vertical: 4))),
    );
  }
}
