import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'Components/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: 'Yeelight Controller',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme,
          colorSchemeSeed: lightColorScheme == null ? Colors.green : null,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          colorSchemeSeed: darkColorScheme == null ? Colors.green : null,
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.dark,
        home: const SafeArea(top: true, child: Home()),
      );
    });
  }
}
