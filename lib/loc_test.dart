import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LocationPermissionTest(),
    );
  }
}

class LocationPermissionTest extends StatefulWidget {
  const LocationPermissionTest({super.key});

  @override
  State<LocationPermissionTest> createState() => _LocationPermissionTestState();
}

class _LocationPermissionTestState extends State<LocationPermissionTest> {
  String locationMessage = "위치 정보를 요청하세요";
  bool isLoading = false;

  // 위치 권한 요청 및 현재 위치 가져오기
  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('위치 서비스가 비활성화되어 있습니다.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('위치 권한이 거부되었습니다.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('위치 권한이 영구적으로 거부되었습니다.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        locationMessage = "위도: ${position.latitude}, 경도: ${position.longitude}";
      });
    } catch (e) {
      setState(() {
        locationMessage = "위치 정보를 가져오는 중 오류 발생: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('위치 권한 테스트'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              locationMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _getCurrentLocation,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('위치 정보 요청'),
            ),
          ],
        ),
      ),
    );
  }
}
