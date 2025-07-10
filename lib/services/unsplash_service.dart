import 'dart:convert';
import 'package:http/http.dart' as http;

class UnsplashService {
  final String accessKey = 'O2uOJWdJtvUUiIro4BqRfOV4uxS-_dn9EYL9fK3Fcnc';

  Future<List<String>> getRandomImages({int count = 5, String query = "puzzle"}) async {
    final url =
        'https://api.unsplash.com/photos/random?count=$count&query=$query&client_id=$accessKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      // Extrage doar URL-urile de la imagini (ex: regular)
      return data.map<String>((img) => img['urls']['regular'] as String).toList();
    } else {
      throw Exception('Failed to load images from Unsplash');
    }
  }
}