import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart'; // 서버 URL이 설정된 파일

class ClosetContentScreen extends StatefulWidget {
  final String userId;

  const ClosetContentScreen({super.key, required this.userId});

  @override
  State<ClosetContentScreen> createState() => _ClosetContentScreenState();
}

class _ClosetContentScreenState extends State<ClosetContentScreen> {
  List<Map<String, dynamic>> clothingItems = [];
  bool isLoading = true;
  bool isClosetOpen = false;

  @override
  void initState() {
    super.initState();
    fetchClothingItems(); // 초기 데이터를 가져옵니다.
  }

  // 서버에서 옷장 데이터를 가져오는 함수
  Future<void> fetchClothingItems() async {
    final String apiUrl = '$serverUrl/tablet/images?userId=${widget.userId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('Server Response: ${response.body}'); // 디버깅용

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          setState(() {
            clothingItems = List<Map<String, dynamic>>.from(responseData['data']);
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print('Error: ${responseData['error']}');
        }
      } else {
        throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching clothing items: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // 옷장 열기/닫기 토글
  void toggleCloset() {
    setState(() {
      isClosetOpen = !isClosetOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Closet"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: isClosetOpen
            ? isLoading
            ? const CircularProgressIndicator() // 로딩 상태
            : clothingItems.isEmpty
            ? const Text(
          "옷 리스트가 없습니다.",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        )
            : GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 한 행에 3개씩 표시
            crossAxisSpacing: 10, // 열 간 간격
            mainAxisSpacing: 10, // 행 간 간격
            childAspectRatio: 0.75, // 이미지 비율 (너비:높이)
          ),
          itemCount: clothingItems.length,
          itemBuilder: (context, index) {
            final item = clothingItems[index];
            return Column(
              children: [
                Expanded(
                  child: Image.network(
                    item['image_url'], // 이미지 URL
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item['category'] ?? '',
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis, // 긴 텍스트 잘라내기
                ),
              ],
            );
          },
        )
            : GestureDetector(
          onTap: toggleCloset, // Closet 열기
          child: Image.asset(
            'assets/images/closet.png', // 닫힌 옷장 이미지
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
