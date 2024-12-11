import 'dart:convert';
import 'package:http/http.dart' as http;

class VisionApiService {
  final String apiKey = "9574230f0f99c48f22123972f54efa70253dc801";
  Future<Map<String, dynamic>?> analyzeImage(String imageUrl) async {
    final String endpoint =
        "https://vision.googleapis.com/v1/images:annotate?key=$apiKey";
    final Map<String, dynamic> requestBody = {
      "requests": [
        {
          "image": {
            "source": {"imageUrl": imageUrl}
          },
          "features": [
            {"type": "LABEL_DETECTION", "maxResults": 10},
            {"type": "IMAGE_PROPERTIES"}
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        return {};
      }
    } catch (e) {
      print("API 호출 오류: $e");
      return {};
    }
  }
}
