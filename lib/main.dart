import 'package:flutter/material.dart';
import 'package:wearly/firstscreen.dart';
import 'package:wearly/homescreen.dart';
import 'package:wearly/signup.dart';
import 'package:wearly/login.dart';
import 'package:wearly/selected_style.dart';
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
      home: const StyleSelectorScreen(
        imageUrl: 'http://example.com/sample-image.jpg',
      ),
      routes: {
        '/signup': (context) => const AuthView(),
        '/login': (context) => const LoginView(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
