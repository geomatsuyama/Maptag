import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

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
                      ElevatedButton(
                        onPressed: () async {
                          await settingsProvider.updateMapillaryApiKey(_mapillaryKeyController.text);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Mapillary API key saved')),
                            );
                          }
                        },
                        child: const Text('Save Mapillary Key'),
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
