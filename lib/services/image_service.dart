import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ImageService {
  static const String baseUrl = 'https://chevenergies.techsavanna.technology';

  // Cache for loaded images
  static final Map<String, Uint8List> _imageCache = {};

  // Fetch image from API
  static Future<Uint8List?> fetchImage(String fileUrl) async {
    // Check cache first
    if (_imageCache.containsKey(fileUrl)) {
      return _imageCache[fileUrl];
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/method/route_plan.apis.manage.view_image'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'file_url': fileUrl}),
      );

      if (response.statusCode == 200) {
        final imageBytes = response.bodyBytes;

        // Cache the image
        _imageCache[fileUrl] = imageBytes;

        return imageBytes;
      } else {
        print(
          'Failed to fetch image: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error fetching image: $e');
      return null;
    }
  }

  // Clear image cache
  static void clearCache() {
    _imageCache.clear();
  }

  // Remove specific image from cache
  static void removeFromCache(String fileUrl) {
    _imageCache.remove(fileUrl);
  }

  // Get cache size
  static int get cacheSize => _imageCache.length;

  // Check if image is cached
  static bool isCached(String fileUrl) {
    return _imageCache.containsKey(fileUrl);
  }
}
