import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mapillary_image.dart';
import '../models/search_area.dart';
import 'package:flutter/foundation.dart';

class MapillaryService {
  static const String baseUrl = 'https://graph.mapillary.com';
  final String apiKey;

  MapillaryService({required this.apiKey});

  Future<List<MapillaryImage>> searchImages({
    required SearchArea searchArea,
    int limit = 1000,
    Function(int current, int total)? onProgress,
  }) async {
    final List<MapillaryImage> allImages = [];
    String? nextUrl;
    int totalFetched = 0;

    try {
      // Build initial request URL based on search area type
      String initialUrl = _buildSearchUrl(searchArea, limit: 1000);

      nextUrl = initialUrl;

      // Pagination loop to handle large datasets (up to 200k images)
      while (nextUrl != null && totalFetched < limit) {
        if (kDebugMode) {
          debugPrint('🔍 Mapillary API Request: $nextUrl');
          debugPrint('🔑 API Key (first 10 chars): ${apiKey.substring(0, apiKey.length > 10 ? 10 : apiKey.length)}...');
        }
        
        final response = await http.get(
          Uri.parse(nextUrl),
          headers: {
            'Authorization': 'OAuth $apiKey',
          },
        );
        
        if (kDebugMode) {
          debugPrint('📥 Response Status: ${response.statusCode}');
          if (response.statusCode != 200) {
            debugPrint('❌ Error Response Body: ${response.body}');
          }
        }

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final features = data['data'] as List?;
          
          if (kDebugMode) {
            debugPrint('✅ Received ${features?.length ?? 0} images in this batch');
          }

          if (features != null) {
            for (var feature in features) {
              if (totalFetched >= limit) break;
              
              try {
                final image = MapillaryImage.fromJson(feature);
                allImages.add(image);
                totalFetched++;
                
                // Report progress
                onProgress?.call(totalFetched, limit);
              } catch (e) {
                // Skip malformed images
                continue;
              }
            }
          }

          // Check for pagination
          final paging = data['paging'] as Map?;
          nextUrl = paging?['next'] as String?;

          // If we've reached the limit or no more pages, break
          if (totalFetched >= limit || nextUrl == null) {
            break;
          }
        } else {
          throw Exception('Failed to fetch images: ${response.statusCode} - ${response.body}');
        }
      }

      return allImages;
    } catch (e) {
      throw Exception('Error searching Mapillary images: $e');
    }
  }

  String _buildSearchUrl(SearchArea searchArea, {int limit = 1000}) {
    final fields = [
      'id',
      'geometry',
      'captured_at',
      'compass_angle',
      'sequence_id',
      'creator_username',
      'creator_id',
      'camera_make',
      'camera_model',
      'width',
      'height',
      'is_pano',
      'organization_id',
    ].join(',');

    String url = '$baseUrl/images?fields=$fields&limit=$limit';

    switch (searchArea.type) {
      case SearchAreaType.pointRadius:
        final params = searchArea.parameters;
        final lat = params['latitude'];
        final lon = params['longitude'];
        final radius = params['radius'];
        url += '&closeto=$lon,$lat&radius=$radius';
        break;

      case SearchAreaType.boundingBox:
        final params = searchArea.parameters;
        final bbox = [
          params['min_longitude'],
          params['min_latitude'],
          params['max_longitude'],
          params['max_latitude'],
        ].join(',');
        url += '&bbox=$bbox';
        break;

      case SearchAreaType.polygon:
        final coords = searchArea.parameters['coordinates'] as List;
        // Convert polygon coordinates to GeoJSON format
        final coordsStr = coords.map((point) => '${point[0]},${point[1]}').join(',');
        url += '&geometry=$coordsStr';
        break;
    }

    return url;
  }

  Future<MapillaryImage?> getImageDetails(String imageId) async {
    try {
      final fields = [
        'id',
        'geometry',
        'captured_at',
        'compass_angle',
        'sequence_id',
        'creator_username',
        'creator_id',
        'camera_make',
        'camera_model',
        'width',
        'height',
        'is_pano',
        'organization_id',
      ].join(',');

      final url = '$baseUrl/$imageId?fields=$fields';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'OAuth $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MapillaryImage.fromJson(data);
      } else {
        throw Exception('Failed to fetch image details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching image details: $e');
    }
  }
}
