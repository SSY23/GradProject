import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

Future<File?> removeBackground(File imageFile) async {
  const apiKey = '2BCYrk9oh2kZAigJtBaUV598';
  const url = 'https://api.remove.bg/v1.0/removebg';
  final request = http.MultipartRequest('POST', Uri.parse(url))
    ..fields['size'] = 'auto'
    ..files.add(await http.MultipartFile.fromPath('image_file', imageFile.path))
    ..headers['X-Api-Key'] = apiKey;

  final response = await request.send();

  if (response.statusCode == 200) {
    final bytes = await response.stream.toBytes();
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/result.png');
    await file.writeAsBytes(bytes);
    return file;
  } else {
    print('Background removal failed: ${response.statusCode}');
    return null;
  }
}
