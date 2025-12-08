import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/mapillary_image.dart';
import '../services/gemini_service.dart';
import '../services/export_service.dart';

class BatchAnalysisScreen extends StatefulWidget {
  final List<MapillaryImage> images;

  const BatchAnalysisScreen({
    super.key,
    required this.images,
  });

  @override
  State<BatchAnalysisScreen> createState() => _BatchAnalysisScreenState();
}

class _BatchAnalysisScreenState extends State<BatchAnalysisScreen> {
  final _promptController = TextEditingController();
  
  List<MapillaryImage> _sampleImages = [];
  Map<String, String> _sampleAnalysisResults = {};
  Map<String, String> _allAnalysisResults = {};
  
  bool _isAnalyzingSamples = false;
  bool _isAnalyzingAll = false;
  double _batchProgress = 0.0;
  String? _errorMessage;
  
  bool _showSamplePreview = false;

  @override
  void initState() {
    super.initState();
    _selectSampleImages();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _selectSampleImages() {
    // サンプルとして3枚選択（均等に分散）
    if (widget.images.length <= 3) {
      _sampleImages = widget.images;
    } else {
      final step = widget.images.length ~/ 3;
      _sampleImages = [
        widget.images[0],
        widget.images[step],
        widget.images[step * 2],
      ];
    }
  }

  Future<void> _analyzeSamples() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final settings = settingsProvider.settings;

    if (!settings.hasGeminiKey) {
      setState(() {
        _errorMessage = 'Gemini APIキーが設定されていません';
      });
      return;
    }

    if (_promptController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = '分析プロンプトを入力してください';
      });
      return;
    }

    setState(() {
      _isAnalyzingSamples = true;
      _errorMessage = null;
      _sampleAnalysisResults.clear();
    });

    try {
      final service = GeminiService(apiKey: settings.geminiApiKey!);
      final prompt = _promptController.text.trim();

      for (var image in _sampleImages) {
        final result = await service.analyzeImage(
          imageUrl: image.thumbUrl,
          prompt: prompt,
        );

        setState(() {
          _sampleAnalysisResults[image.id] = result;
        });
      }

      setState(() {
        _isAnalyzingSamples = false;
        _showSamplePreview = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('サンプル分析が完了しました')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isAnalyzingSamples = false;
      });
    }
  }

  Future<void> _analyzeAllImages() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final settings = settingsProvider.settings;

    setState(() {
      _isAnalyzingAll = true;
      _errorMessage = null;
      _batchProgress = 0.0;
      _allAnalysisResults.clear();
    });

    try {
      final service = GeminiService(apiKey: settings.geminiApiKey!);
      final prompt = _promptController.text.trim();

      int completed = 0;
      for (var image in widget.images) {
        try {
          final result = await service.analyzeImage(
            imageUrl: image.thumbUrl,
            prompt: prompt,
          );

          setState(() {
            _allAnalysisResults[image.id] = result;
            completed++;
            _batchProgress = completed / widget.images.length;
          });
        } catch (e) {
          setState(() {
            _allAnalysisResults[image.id] = 'エラー: $e';
            completed++;
            _batchProgress = completed / widget.images.length;
          });
        }

        // Rate limiting: 小休止
        if (completed % 10 == 0) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      setState(() {
        _isAnalyzingAll = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.images.length}件の分析が完了しました'),
            action: SnackBarAction(
              label: 'エクスポート',
              onPressed: _exportResults,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isAnalyzingAll = false;
      });
    }
  }

  Future<void> _exportResults() async {
    try {
      final exportService = ExportService();

      // Show export format dialog
      final format = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('エクスポート形式'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('JSON'),
                onTap: () => Navigator.pop(context, 'json'),
              ),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('Excel'),
                onTap: () => Navigator.pop(context, 'excel'),
              ),
            ],
          ),
        ),
      );

      if (format == null) return;

      String filePath;
      if (format == 'json') {
        filePath = await exportService.exportAnalysisResults(
          widget.images,
          _allAnalysisResults,
          asExcel: false,
        );
      } else {
        filePath = await exportService.exportAnalysisResults(
          widget.images,
          _allAnalysisResults,
          asExcel: true,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エクスポート完了: $filePath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エクスポートエラー: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI分析 (バッチ処理)'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image count info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.image, size: 32, color: Colors.blue),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '対象画像数',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${widget.images.length}件',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Analysis prompt
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '分析プロンプト',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _promptController,
                        decoration: const InputDecoration(
                          labelText: 'すべての画像に適用する分析内容',
                          hintText: '例: この画像の道路状況を説明してください',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _QuickPromptChip(
                            label: '道路状況',
                            prompt: 'この画像の道路状況を詳しく説明してください',
                            onTap: (prompt) {
                              _promptController.text = prompt;
                            },
                          ),
                          _QuickPromptChip(
                            label: '交通標識',
                            prompt: 'この画像に写っている交通標識をすべてリストアップしてください',
                            onTap: (prompt) {
                              _promptController.text = prompt;
                            },
                          ),
                          _QuickPromptChip(
                            label: '建物・施設',
                            prompt: 'この画像に写っている建物や施設の種類を特定してください',
                            onTap: (prompt) {
                              _promptController.text = prompt;
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Step 1: Sample preview button
              if (!_showSamplePreview)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isAnalyzingSamples ? null : _analyzeSamples,
                    icon: _isAnalyzingSamples
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.preview),
                    label: Text(_isAnalyzingSamples
                        ? 'サンプル分析中...'
                        : 'ステップ1: サンプル3枚でプレビュー'),
                  ),
                ),

              // Sample preview results
              if (_showSamplePreview && _sampleAnalysisResults.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'サンプル分析結果',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ..._sampleImages.asMap().entries.map((entry) {
                          final index = entry.key;
                          final image = entry.value;
                          final result = _sampleAnalysisResults[image.id] ?? '';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'サンプル ${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Location: ${image.latitude.toStringAsFixed(6)}, ${image.longitude.toStringAsFixed(6)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const Divider(),
                                  Text(
                                    result,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Step 2: Batch analysis button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isAnalyzingAll ? null : _analyzeAllImages,
                    icon: _isAnalyzingAll
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(_isAnalyzingAll
                        ? '全画像分析中... ${(_batchProgress * 100).toStringAsFixed(0)}%'
                        : 'ステップ2: 全${widget.images.length}件を一括分析'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ),
              ],

              // Batch progress
              if (_isAnalyzingAll) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '${(widget.images.length * _batchProgress).toInt()} / ${widget.images.length}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: _batchProgress),
                        const SizedBox(height: 8),
                        Text(
                          '残り約${((widget.images.length - widget.images.length * _batchProgress) * 3).toInt()}秒',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Completed results
              if (_allAnalysisResults.length == widget.images.length) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle, size: 48, color: Colors.blue.shade700),
                        const SizedBox(height: 8),
                        Text(
                          '分析完了!',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.images.length}件すべての分析が完了しました',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _exportResults,
                            icon: const Icon(Icons.download),
                            label: const Text('結果をエクスポート'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickPromptChip extends StatelessWidget {
  final String label;
  final String prompt;
  final Function(String) onTap;

  const _QuickPromptChip({
    required this.label,
    required this.prompt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: () => onTap(prompt),
      avatar: const Icon(Icons.flash_on, size: 18),
    );
  }
}
