import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../Api/yeelight_api.dart';

class StatusCard extends StatefulWidget {
  final YeelightApi yeelightApi;

  const StatusCard({Key? key, required this.yeelightApi}) : super(key: key);

  @override
  _StatusCardState createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 120,
        child: CustomPaint(
          painter: _BrightnessIndicatorPainter(
              brightness: widget.yeelightApi.deviceBrightness.toDouble(),
              context: context),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        title: Text(widget.yeelightApi.device != null
                            ? "Disconnection"
                            : "Connection"),
                        content: SingleChildScrollView(
                          child: Text(widget.yeelightApi.device != null
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
                              widget.yeelightApi.device != null
                                  ? widget.yeelightApi.disconnect()
                                  : widget.yeelightApi.getLights();
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
                  Text(widget.yeelightApi.device != null
                          ? "Connected"
                          : "Disconnected")
                      .textColor(widget.yeelightApi.device != null
                          ? Colors.green
                          : Colors.red)
                      .padding(all: 4)
                      .boxShadow(
                          color: widget.yeelightApi.device != null
                              ? Colors.green
                              : Colors.red,
                          blurRadius: 30,
                          spreadRadius: -9),
                  // Status and Brightness
                  Text(
                      "LED status: ${widget.yeelightApi.devicePower ? "On" : "Off"}"),
                  Text("Brightness: ${widget.yeelightApi.deviceBrightness}%"),
                ],
              ),
            ),
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
