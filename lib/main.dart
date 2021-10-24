import 'package:flutter/material.dart';
import 'package:tts_task/test.dart';
import 'sound_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'tss-task',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF040640),
        appBarTheme: AppBarTheme(
          color: Color(0xFF040640),
          elevation: 0.0,
        ),
        textTheme: TextTheme(
          bodyText1: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        sliderTheme: SliderThemeData(
          thumbColor: Colors.white,
          thumbShape:
          RoundSliderThumbShape(enabledThumbRadius: 5.0),
          activeTrackColor: Color(0xFFF94E80),
          inactiveTrackColor: Colors.grey.shade400,
        ),
      ),
      initialRoute: SoundView.id,
      // initialRoute: Test.id,
      routes: {
        SoundView.id: (_) => SoundView(),
        Test.id: (_) => Test(),
      },
    );
  }
}
