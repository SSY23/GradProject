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
      initialRoute: '/',
      routes: {
        '/': (context) => const FirstScreen(),
        '/signup': (context) => const AuthView(),
        '/login': (context) => const LoginView(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null && args.containsKey('userId')) {
            return MaterialPageRoute(
              builder: (context) => HomeScreen(userId: args['userId']),
            );
          }
        }
        return null;
      },
    );
  }
}
