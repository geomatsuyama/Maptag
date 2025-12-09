import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateService {
  // GitHub Repository information
  static const String repoOwner = 'geomatsuyama';
  static const String repoName = 'Maptag';
  static const String currentVersion = '1.0.0';
  
  // Check for updates from GitHub Releases
  Future<UpdateInfo?> checkForUpdates() async {
    try {
      final url = 'https://api.github.com/repos/$repoOwner/$repoName/releases/latest';
      
      if (kDebugMode) {
        debugPrint('🔍 Checking for updates: $url');
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestVersion = data['tag_name'] as String;
        final releaseNotes = data['body'] as String?;
        final publishedAt = DateTime.parse(data['published_at'] as String);
        final htmlUrl = data['html_url'] as String;
        
        // Remove 'v' prefix if present (e.g., v1.0.0 -> 1.0.0)
        final cleanVersion = latestVersion.startsWith('v') 
            ? latestVersion.substring(1) 
            : latestVersion;
        
        if (kDebugMode) {
          debugPrint('✅ Current version: $currentVersion');
          debugPrint('📦 Latest version: $cleanVersion');
        }
        
        // Compare versions
        if (_isNewerVersion(currentVersion, cleanVersion)) {
          return UpdateInfo(
            version: cleanVersion,
            releaseNotes: releaseNotes ?? 'No release notes available',
            publishedAt: publishedAt,
            downloadUrl: htmlUrl,
          );
        }
        
        if (kDebugMode) {
          debugPrint('✓ App is up to date');
        }
        
        return null;
      } else {
        if (kDebugMode) {
          debugPrint('❌ Failed to check for updates: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking for updates: $e');
      }
      return null;
    }
  }

  // Compare version strings (e.g., "1.0.0" vs "1.1.0")
  bool _isNewerVersion(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      final latestPart = i < latestParts.length ? latestParts[i] : 0;
      
      if (latestPart > currentPart) return true;
      if (latestPart < currentPart) return false;
    }
    
    return false;
  }

  // Save the last update check time
  Future<void> saveLastUpdateCheck() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_update_check', DateTime.now().millisecondsSinceEpoch);
  }

  // Get the last update check time
  Future<DateTime?> getLastUpdateCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('last_update_check');
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  // Check if we should check for updates (once per day)
  Future<bool> shouldCheckForUpdates() async {
    final lastCheck = await getLastUpdateCheck();
    if (lastCheck == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastCheck);
    
    return difference.inHours >= 24;
  }

  // Mark an update as dismissed (don't show again for this version)
  Future<void> dismissUpdate(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dismissed_update_version', version);
  }

  // Check if an update was dismissed
  Future<bool> wasUpdateDismissed(String version) async {
    final prefs = await SharedPreferences.getInstance();
    final dismissedVersion = prefs.getString('dismissed_update_version');
    return dismissedVersion == version;
  }
}

class UpdateInfo {
  final String version;
  final String releaseNotes;
  final DateTime publishedAt;
  final String downloadUrl;

  UpdateInfo({
    required this.version,
    required this.releaseNotes,
    required this.publishedAt,
    required this.downloadUrl,
  });
}
