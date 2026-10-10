import 'package:flutter/material.dart';
import 'package:giroscopio_app/giroscope.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Material App', home: Giroscope());
  }
}
