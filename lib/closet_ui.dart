import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

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
  bool isClosetOpen = false;

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
          onTap: toggleCloset,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              'assets/images/closet.png',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class ClosetContentScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ClosetContentScreen({super.key, required this.onBack});

  @override
  State<ClosetContentScreen> createState() => _ClosetContentScreenState();
}

class _ClosetContentScreenState extends State<ClosetContentScreen> {
  final WebSocketChannel _channel =
      WebSocketChannel.connect(Uri.parse('ws://172.20.40.222/ws')); //서버 연결
  final List<Map<String, dynamic>> _clothingItems = [];

  @override
  void initState() {
    super.initState();
    _listenForUpdates();
  }

  @override
  void dispose() {
    _channel.sink.close(status.normalClosure);
    super.dispose();
  }

  void _listenForUpdates() {
    _channel.stream.listen((message) {
      final data = jsonDecode(message);
      setState(() {
        _clothingItems.add(data);
      });
    }, onError: (error) {
      print("WebSocket 에러: $error");
    }, onDone: () {
      print("WebSocket 연결 종료됨");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Closet"),
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: _clothingItems.isEmpty
          ? const Center(
              child: Text(
                "옷 리스트가 없습니다.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
            )
          : ListView.builder(
              itemCount: _clothingItems.length,
              itemBuilder: (context, index) {
                final item = _clothingItems[index];
                return ListTile(
                  leading: Image.network(
                    item['imageUrl'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item['visionData']['label'] ?? "Unknown"),
                  subtitle:
                      Text("색상: ${item['visionData']['color'] ?? "Unknown"}"),
                );
              },
            ),
    );
  }
}
