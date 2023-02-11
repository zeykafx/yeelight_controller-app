import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:yeedart/yeedart.dart';
import 'package:yeelight_controller_app/Components/color_dialog.dart';
import 'package:yeelight_controller_app/Components/status_card.dart';
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
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: StatusCard(
                    yeelightApi: yeelightApi,
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    children: [
                      // Buttons ---

                      Card(
                        color: yeelightApi.isDeviceFlowing
                            ? Theme.of(context).colorScheme.secondaryContainer
                            : null,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            if (yeelightApi.isDeviceFlowing) {
                              yeelightApi.isDeviceFlowing = false;
                              await yeelightApi.device!.setRGB(
                                color: const Color(0xffff0000).toHex(),
                                effect: const Effect.smooth(),
                                duration: const Duration(milliseconds: 200),
                              );
                            } else {
                              yeelightApi.startFlow();
                            }
                          },
                          child: Center(
                            child: Text(yeelightApi.isDeviceFlowing
                                ? "Disable Flow"
                                : "Enable Flow"),
                          ),
                        ),
                      ),

                      // turn on/off button
                      Card(
                        color: yeelightApi.devicePower
                            ? Theme.of(context).colorScheme.secondaryContainer
                            : null,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            yeelightApi.toggleLights();
                          },
                          child: Center(
                              child: Text(yeelightApi.devicePower
                                  ? "Turn Off"
                                  : "Turn On")),
                        ),
                      ),

                      Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => showDialog(
                              context: context,
                              builder: (BuildContext context) => ColorDialog(
                                  yeelightApi: yeelightApi,
                                  onStateChanged: () => setState(() {}))),
                          child: const Center(child: Text("Color & Brightness")),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
