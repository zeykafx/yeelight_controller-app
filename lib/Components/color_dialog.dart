import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:yeedart/yeedart.dart';
import 'package:yeelight_controller_app/Api/yeelight_api.dart';
import 'package:yeelight_controller_app/Extensions/hex_color.dart';

class ColorDialog extends HookWidget {
  final YeelightApi yeelightApi;

  const ColorDialog({Key? key, required this.yeelightApi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pickerColor = useState<Color>(const Color(0xffff0000));
    final currentColor = useState<Color>(const Color(0xffff0000));
    final brightnessToSet = useState<double>(100);

    return AlertDialog(
      title: const Text("Set brightness and color"),
      content: SingleChildScrollView(
          child: <Widget>[
            ColorPicker(
              pickerColor: pickerColor.value,
              onColorChanged: (Color color) => pickerColor.value = color,
              pickerAreaHeightPercent: 0.8,
            ).padding(bottom: 4),
            const Divider(thickness: 0.5).padding(bottom: 4),
            Text("Brightness ${brightnessToSet.value.toStringAsFixed(0)}%"),
            Slider(
                value: brightnessToSet.value,
                min: 1,
                max: 100,
                label: brightnessToSet.value.toStringAsFixed(0),
                onChanged: (double value) {
                  brightnessToSet.value = value;
                }),
        ].toColumn(mainAxisSize: MainAxisSize.min)
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
            )),
        TextButton(
          onPressed: () async {
            // set the device's RGB and brightness

            if (yeelightApi.device != null) {
              await yeelightApi.device!.setRGB(
                color: pickerColor.value.toHex(),
                effect: const Effect.smooth(),
                duration: const Duration(milliseconds: 200),
              );

              await yeelightApi.device!.setBrightness(
                brightness: brightnessToSet.value.toInt(),
                effect: const Effect.smooth(),
                duration: const Duration(milliseconds: 200),
              );
            } else {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Not connected to a device, unable to change brightness and color")));
            }

            Navigator.pop(context);
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}
