import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/mapillary_service.dart';
import '../services/update_service.dart';
import '../models/search_area.dart';
import '../widgets/update_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _mapillaryKeyController = TextEditingController();
  final _geminiKeyController = TextEditingController();
  bool _obscureMapillaryKey = true;
  bool _obscureGeminiKey = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      _mapillaryKeyController.text = settingsProvider.settings.mapillaryApiKey ?? '';
      _geminiKeyController.text = settingsProvider.settings.geminiApiKey ?? '';
    });
  }

  @override
  void dispose() {
    _mapillaryKeyController.dispose();
    _geminiKeyController.dispose();
    super.dispose();
  }

  Future<void> _checkForUpdates(BuildContext context) async {
    // Show loading dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('アップデートを確認中...'),
            ],
          ),
        ),
      );
    }

    try {
      final updateService = UpdateService();
      final updateInfo = await updateService.checkForUpdates();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (updateInfo != null) {
        // Show update dialog
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => UpdateDialog(
              updateInfo: updateInfo,
              onDismiss: () async {
                await updateService.dismissUpdate(updateInfo.version);
              },
            ),
          );
        }
      } else {
        // No updates available
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  const Text('最新版です'),
                ],
              ),
              content: Text(
                'お使いのアプリは最新バージョン(v${UpdateService.currentVersion})です。',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red.shade600),
                const SizedBox(width: 8),
                const Text('確認失敗'),
              ],
            ),
            content: Text(
              'アップデートの確認に失敗しました。\n\nエラー: $e',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _testMapillaryConnection(BuildContext context) async {
    final apiKey = _mapillaryKeyController.text.trim();
    
    if (apiKey.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter an API key first'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Show loading dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Testing Mapillary API...'),
            ],
          ),
        ),
      );
    }

    try {
      // Test API with a simple request (Tokyo Station)
      final service = MapillaryService(apiKey: apiKey);
      final searchArea = SearchArea.pointRadius(
        latitude: 35.6812,
        longitude: 139.7671,
        radiusMeters: 100,
      );
      
      final results = await service.searchImages(
        searchArea: searchArea,
        limit: 5,
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show result
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text('Connection Successful'),
              ],
            ),
            content: Text(
              'API key is valid!\n\nTest search found ${results.length} images near Tokyo Station.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red.shade600),
                const SizedBox(width: 8),
                const Text('Connection Failed'),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(
                'Failed to connect to Mapillary API.\n\n'
                'Error: ${e.toString()}\n\n'
                'Possible causes:\n'
                '• Invalid API key\n'
                '• Expired API key\n'
                '• Network connection issues\n'
                '• Mapillary service temporarily unavailable\n\n'
                'Please check your API key at:\n'
                'https://www.mapillary.com/developer',
                style: const TextStyle(fontSize: 13),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final settings = settingsProvider.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Mode Toggle
              Card(
                child: SwitchListTile(
                  title: const Text(
                    'Premium Mode',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    settings.isPremiumMode
                        ? 'Unlimited image collection (up to 200,000)'
                        : 'Limited to 100 images per search',
                  ),
                  value: settings.isPremiumMode,
                  onChanged: (value) {
                    settingsProvider.togglePremiumMode();
                  },
                  secondary: Icon(
                    settings.isPremiumMode ? Icons.workspace_premium : Icons.free_breakfast,
                    color: settings.isPremiumMode ? Colors.amber : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // API Keys Section
              Text(
                'API Configuration',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Mapillary API Key
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.map, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Mapillary API Key',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _mapillaryKeyController,
                        obscureText: _obscureMapillaryKey,
                        decoration: InputDecoration(
                          labelText: 'API Key',
                          hintText: 'Enter your Mapillary API key',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureMapillaryKey ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureMapillaryKey = !_obscureMapillaryKey;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await settingsProvider.updateMapillaryApiKey(_mapillaryKeyController.text);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mapillary API key saved')),
                                );
                              }
                            },
                            child: const Text('Save Key'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _testMapillaryConnection(context),
                            icon: const Icon(Icons.science, size: 16),
                            label: const Text('Test'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Get your API key from: https://www.mapillary.com/developer',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Gemini API Key
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.psychology, color: Colors.purple),
                          const SizedBox(width: 8),
                          Text(
                            'Gemini API Key',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _geminiKeyController,
                        obscureText: _obscureGeminiKey,
                        decoration: InputDecoration(
                          labelText: 'API Key',
                          hintText: 'Enter your Gemini API key',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureGeminiKey ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureGeminiKey = !_obscureGeminiKey;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          await settingsProvider.updateGeminiApiKey(_geminiKeyController.text);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gemini API key saved')),
                            );
                          }
                        },
                        child: const Text('Save Gemini Key'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Get your API key from: https://makersuite.google.com/app/apikey',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // App Version & Update Check
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'アプリバージョン',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Version ${UpdateService.currentVersion}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _checkForUpdates(context),
                        icon: const Icon(Icons.system_update, size: 18),
                        label: const Text('アップデートを確認'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Info Section
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'About API Keys',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• API keys are stored locally on your device\n'
                        '• Mapillary API is required for image search\n'
                        '• Gemini API is required for AI analysis\n'
                        '• Both APIs are free to use with rate limits',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
