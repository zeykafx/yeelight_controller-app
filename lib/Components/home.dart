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
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          constraints: const BoxConstraints(maxWidth: 320),
          child: GridView.count(
            crossAxisCount: 2,
            children: [
              Card(
                child: CustomPaint(
                  painter: _BrightnessIndicatorPainter(
                      brightness: yeelightApi.deviceBrightness.toDouble(),
                      context: context),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: Text(yeelightApi.device != null
                                    ? "Disconnection"
                                    : "Connection"),
                                content: SingleChildScrollView(
                                  child: Text(yeelightApi.device != null
                                      ? "Do you want to disconnect from the currently connected LEDs?"
                                      : "Do you want to attempt to connect to LEDs?"),
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        "Cancel",
                                      )),
                                  TextButton(
                                    onPressed: () async {
                                      yeelightApi.device != null
                                          ? yeelightApi.disconnect()
                                          : yeelightApi.getLights();
                                      Navigator.pop(context);
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              ));
                    },
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(yeelightApi.device != null
                                  ? "Connected"
                                  : "Disconnected")
                              .textColor(yeelightApi.device != null
                                  ? Colors.green
                                  : Colors.red)
                              .padding(all: 4)
                              .boxShadow(
                                  color: yeelightApi.device != null
                                      ? Colors.green
                                      : Colors.red,
                                  blurRadius: 30,
                                  spreadRadius: -9),
                          // Status and Brightness
                          Text(
                              "LED status: ${yeelightApi.devicePower ? "On" : "Off"}"),
                          Text("Brightness: ${yeelightApi.deviceBrightness}%"),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Buttons ---

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
                      child: Text(
                          yeelightApi.devicePower ? "Turn Off" : "Turn On")),
                ),
              ),

              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
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
                  child: Center(
                    child: Text(yeelightApi.isDeviceFlowing
                        ? "Disable Flow"
                        : "Enable Flow"),
                  ),
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
      ),
    );
  }
}

class _BrightnessIndicatorPainter extends CustomPainter {
  final double brightness;
  final BuildContext context;
  _BrightnessIndicatorPainter(
      {required this.brightness, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Theme.of(context).colorScheme.secondaryContainer
      ..style = PaintingStyle.fill;
    final width = size.width * brightness / 100;
    canvas.drawRRect(
        RRect.fromLTRBR(0, 0, width, size.height, const Radius.circular(8)),
        paint);
  }

  @override
  bool shouldRepaint(_BrightnessIndicatorPainter oldDelegate) =>
      brightness != oldDelegate.brightness;
}
