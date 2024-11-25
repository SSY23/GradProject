import 'package:flutter/material.dart';
import 'package:wearly/firstscreen.dart';
import 'package:wearly/homescreen.dart';
import 'package:wearly/signup.dart';
import 'package:wearly/login.dart';

void main() {
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
      home: const FirstScreen(), // 초기 화면
      routes: {
        '/signup': (context) => const AuthView(),
        '/login': (context) => const LoginView(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
