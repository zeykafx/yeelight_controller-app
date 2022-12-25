import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:yeedart/yeedart.dart';
import 'package:yeelight_controller_app/Api/yeelight_api.dart';
import 'package:yeelight_controller_app/Extensions/hex_color.dart';

class ColorDialog extends StatefulWidget {
  final YeelightApi yeelightApi;

  const ColorDialog({Key? key, required this.yeelightApi}) : super(key: key);

  @override
  State<ColorDialog> createState() => _ColorDialogState();
}

class _ColorDialogState extends State<ColorDialog> {
  Color pickerColor = const Color(0xffff0000);
  double brightnessToSet = 100;

  @override
  void initState() {
    brightnessToSet = widget.yeelightApi.deviceBrightness.toDouble();
    widget.yeelightApi.getCurrentColor().then((value) {
      setState(() {
        pickerColor = value ?? const Color(0xffff0000);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Set brightness and color"),
      content: SingleChildScrollView(
          child: <Widget>[
        ColorPicker(
          pickerColor: pickerColor,
          onColorChanged: (Color color) => setState(() {
            pickerColor = color;
          }),
          pickerAreaHeightPercent: 0.8,
        ).padding(bottom: 4),
        const Divider(thickness: 0.5).padding(bottom: 4),
        Text("Brightness ${brightnessToSet.toStringAsFixed(0)}%"),
        Slider(
            value: brightnessToSet,
            min: 1,
            max: 100,
            label: brightnessToSet.toStringAsFixed(0),
            onChanged: (double value) {
              setState(() {
                brightnessToSet = value;
              });
            }),
      ].toColumn(mainAxisSize: MainAxisSize.min)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
            )),
        TextButton(
          onPressed: () async {
            // set the device's RGB and brightness

            if (widget.yeelightApi.device != null) {
              await widget.yeelightApi.device!.setRGB(
                color: pickerColor.toHex(),
                effect: const Effect.smooth(),
                duration: const Duration(milliseconds: 200),
              );

              await widget.yeelightApi.device!.setBrightness(
                brightness: brightnessToSet.toInt(),
                effect: const Effect.smooth(),
                duration: const Duration(milliseconds: 200),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      "Not connected to a device, unable to change brightness and color")));
            }

            Navigator.pop(context);
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}
