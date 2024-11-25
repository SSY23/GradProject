import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class RemoveBgService {
  final String serverUrl = 'http://172.20.4.99:3000/closet/test';

  Future<String?> removeBackground(File imageFile) async {
    try {
      if (!imageFile.existsSync()) {
        print('파일이 존재하지 않습니다.');
        return null;
      }

      var request = http.MultipartRequest('POST', Uri.parse(serverUrl));

      var multipartFile = await http.MultipartFile.fromPath('image', imageFile.path);
      request.files.add(multipartFile);

      var response = await request.send().timeout(Duration(seconds: 30)); // 30초 타임아웃

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final Map<String, dynamic> data = jsonDecode(responseData);

        if (data.containsKey('bg_removed_image_url')) {
          return data['bg_removed_image_url'];
        } else {
          print('배경 제거 성공했지만 결과 URL을 찾을 수 없음.');
          return null;
        }
      } else {
        print('배경 제거 실패: ${response.statusCode} - ${response.reasonPhrase}');
        // 응답 데이터 로깅
        final responseData = await response.stream.bytesToString();
        print('응답 데이터: $responseData');
        return null;
      }
    } catch (e) {
      if (e is SocketException) {
        print('네트워크 연결 실패: $e');
      } else if (e is TimeoutException) {
        print('요청 시간이 초과되었습니다.');
      } else {
        print('오류 발생: $e');
      }
      return null;
    }
  }
}
