import 'package:flutter/material.dart';

void main() {
  runApp(const SmartClosetApp());
}

class SmartClosetApp extends StatelessWidget {
  const SmartClosetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SmartClosetUI(),
    );
  }
}

class SmartClosetUI extends StatefulWidget {
  const SmartClosetUI({super.key});

  @override
  _SmartClosetUIState createState() => _SmartClosetUIState();
}

class _SmartClosetUIState extends State<SmartClosetUI>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool isClosetOpen = false; // 옷장 상태

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleCloset() {
    if (isClosetOpen) {
      // 옷장 닫기
      Navigator.pop(context);
      setState(() {
        isClosetOpen = false;
      });
    } else {
      // 옷장 열기
      _controller.forward().then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClosetContentScreen(
              onBack: () {
                Navigator.pop(context);
                setState(() {
                  isClosetOpen = false;
                  _controller.reverse();
                });
              },
            ),
          ),
        );
        setState(() {
          isClosetOpen = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: GestureDetector(
          onTap: toggleCloset, // 클릭 시 열리고 닫힘 전환
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              'assets/images/closet.png',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.contain, // 화면 맞춤
            ),
          ),
        ),
      ),
    );
  }
}

class ClosetContentScreen extends StatelessWidget {
  final VoidCallback onBack;

  const ClosetContentScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Closet"),
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: const Center(
        child: Text(
          "옷 리스트 화면",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
