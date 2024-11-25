import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:wearly/remove_back.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Default: 옷장
  final List<dynamic> _uploadedImages = []; // File 또는 URL 저장 가능
  final ImagePicker _picker = ImagePicker();
  final RemoveBgService _removeBgService = RemoveBgService();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _uploadedImages.add(imageFile);
      });

      // 배경 제거 API 호출 (서버와 연결)
      String? resultUrl = await _removeBgService.removeBackground(imageFile);
      if (resultUrl != null) {
        setState(() {
          _uploadedImages[_uploadedImages.length - 1] = resultUrl; // URL로 업데이트
        });
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('앨범에서 선택하기'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('취소'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeImage(int index) {
    setState(() {
      _uploadedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WEarly'),
      ),
      body: Stack(
        children: [
          _currentIndex == 0
              ? GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _uploadedImages.length,
            itemBuilder: (context, index) {
              var image = _uploadedImages[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  image is String
                      ? Image.network(
                    image,
                    fit: BoxFit.cover,
                  )
                      : Image.file(
                    image,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.black12,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          )
              : Center(
            child: Text(
              _currentIndex == 1 ? '추천 기록 페이지' : '마이 페이지',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          if (_currentIndex == 0)
            Positioned(
              bottom: 70,
              left: MediaQuery.of(context).size.width / 2 - 35,
              child: FloatingActionButton(
                onPressed: _showImageSourceSheet,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.add_a_photo),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: '옷장',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '추천 기록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이 페이지',
          ),
        ],
      ),
    );
  }
}
