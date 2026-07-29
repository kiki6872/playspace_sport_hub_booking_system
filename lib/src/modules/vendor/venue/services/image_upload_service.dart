import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ImageUploadService {
  static const String _apiKey = "be7c64d4fafaeb6bf0ac1d08ec39f198";

  Future<String?> uploadImage(File image) async {
    final bytes = await image.readAsBytes();

    final base64Image = base64Encode(bytes);

    final uri = Uri.parse("https://api.imgbb.com/1/upload?key=$_apiKey");

    final response = await http.post(uri, body: {"image": base64Image});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data["data"]["url"];
    }

    return null;
  }
}
