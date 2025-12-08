import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  final String apiKey;

  GeminiService({required this.apiKey});

  Future<String> analyzeImage({
    required String imageUrl,
    required String prompt,
  }) async {
    try {
      final url = '$baseUrl/models/gemini-1.5-flash:generateContent?key=$apiKey';

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': await _getBase64ImageFromUrl(imageUrl),
                }
              },
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.4,
          'topK': 32,
          'topP': 1,
          'maxOutputTokens': 2048,
        }
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List;
          
          if (parts.isNotEmpty) {
            return parts[0]['text'] as String;
          }
        }
        
        return 'No analysis result available';
      } else {
        throw Exception('Failed to analyze image: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error analyzing image with Gemini: $e');
    }
  }

  Future<List<Map<String, dynamic>>> analyzeBatch({
    required List<String> imageUrls,
    required String prompt,
    Function(int current, int total)? onProgress,
  }) async {
    final results = <Map<String, dynamic>>[];
    
    for (int i = 0; i < imageUrls.length; i++) {
      try {
        final analysis = await analyzeImage(
          imageUrl: imageUrls[i],
          prompt: prompt,
        );
        
        results.add({
          'image_url': imageUrls[i],
          'analysis': analysis,
          'success': true,
        });
        
        onProgress?.call(i + 1, imageUrls.length);
      } catch (e) {
        results.add({
          'image_url': imageUrls[i],
          'error': e.toString(),
          'success': false,
        });
        
        onProgress?.call(i + 1, imageUrls.length);
      }
    }
    
    return results;
  }

  Future<String> _getBase64ImageFromUrl(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      
      if (response.statusCode == 200) {
        return base64Encode(response.bodyBytes);
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error downloading image: $e');
    }
  }
}
