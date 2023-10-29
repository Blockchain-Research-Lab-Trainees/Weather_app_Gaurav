import 'package:flutter/material.dart';
import 'package:gaurav_app/start_page.dart';
import 'package:gaurav_app/weather_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => WeatherProvider(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: ThemeData.dark(useMaterial3: true),

      home: StartPage(),
    );
  }
}
