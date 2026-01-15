import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class FirebaseImageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Only logo is bundled with app - all exam images loaded from Firebase
  static const String logoPath = 'assets/illustrations/logo.png';

  /// Get image URL from Firebase Storage for exam images
  static Future<String> getImageUrl(String imageName) async {
    try {
      // Get from Firebase Storage
      final ref = _storage.ref().child('exam_images/$imageName');
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error loading image from Firebase: $e');
      throw Exception('Failed to load image: $imageName');
    }
  }

  /// Widget to display exam image with caching and loading states
  static Widget buildExamImage(
    String imageName, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return FutureBuilder<String>(
      future: getImageUrl(imageName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPlaceholder(width, height);
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorPlaceholder();
        }

        final url = snapshot.data!;

        // Load from network with caching
        return CachedNetworkImage(
          imageUrl: url,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => _buildLoadingPlaceholder(width, height),
          errorWidget: (context, url, error) => _buildErrorPlaceholder(),
          // Cache for 30 days
          cacheManager: ExamImageCacheManager(),
          fadeInDuration: const Duration(milliseconds: 300),
          fadeOutDuration: const Duration(milliseconds: 300),
        );
      },
    );
  }

  static Widget _buildLoadingPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 8),
            Text(
              'Loading...',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildErrorPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 48, color: Colors.grey[600]),
            SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              'Check internet connection',
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  /// Check if images are cached and available offline
  static Future<bool> isImageCached(String imageName) async {
    try {
      final url = await getImageUrl(imageName);
      final cacheManager = ExamImageCacheManager();
      final fileInfo = await cacheManager.getFileFromCache(url);
      return fileInfo != null;
    } catch (e) {
      return false;
    }
  }

  /// Get cache status for all exam images
  static Future<Map<String, dynamic>> getCacheStatus() async {
    try {
      return {
        'cachedCount': 0,
        'message': 'Cache manager active',
      };
    } catch (e) {
      return {'cachedCount': 0, 'message': 'Cache unavailable'};
    }
  }

  /// Clear image cache
  static Future<void> clearCache() async {
    try {
      final cacheManager = ExamImageCacheManager();
      await cacheManager.emptyCache();
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}

// Custom cache manager for exam images - 30 day cache, 200 images max
class ExamImageCacheManager extends CacheManager {
  static const key = 'examImageCache';

  static final ExamImageCacheManager _instance = ExamImageCacheManager._();
  factory ExamImageCacheManager() => _instance;

  ExamImageCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 30), // Cache for 30 days
            maxNrOfCacheObjects: 200, // Max 200 images (all exam images)
            repo: JsonCacheInfoRepository(databaseName: key),
            fileService: HttpFileService(),
          ),
        );
}
