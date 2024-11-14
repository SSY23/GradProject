import 'package:flutter/material.dart';
import 'package:wearly/home_screen.dart';
import 'package:wearly/signup.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WEarly',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const HomeScreen(), // 초기 화면
      routes: {
        '/signup': (context) => const AuthView(),
      },
    );
  }
}
