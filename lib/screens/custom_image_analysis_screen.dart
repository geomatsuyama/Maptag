import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/settings_provider.dart';
import '../services/gemini_service.dart';

class CustomImageAnalysisScreen extends StatefulWidget {
  const CustomImageAnalysisScreen({super.key});

  @override
  State<CustomImageAnalysisScreen> createState() => _CustomImageAnalysisScreenState();
}

class _CustomImageAnalysisScreenState extends State<CustomImageAnalysisScreen> {
  final _promptController = TextEditingController(
    text: 'この画像に写っている建物、道路、看板、風景などを詳しく説明してください。',
  );
  
  List<UploadedImage> _uploadedImages = [];
  bool _isAnalyzing = false;
  double _analysisProgress = 0.0;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: kIsWeb, // On web, we need the bytes
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            if (file.bytes != null) {
              _uploadedImages.add(
                UploadedImage(
                  name: file.name,
                  bytes: file.bytes!,
                  size: file.size,
                ),
              );
            }
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${result.files.length}枚の画像を追加しました')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('画像の読み込みに失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _analyzeImages() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final settings = settingsProvider.settings;

    if (!settings.hasGeminiKey) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gemini APIキーを設定してください'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_uploadedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('分析する画像を選択してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisProgress = 0.0;
    });

    try {
      final service = GeminiService(apiKey: settings.geminiApiKey!);
      final prompt = _promptController.text.trim();

      for (int i = 0; i < _uploadedImages.length; i++) {
        final image = _uploadedImages[i];
        
        if (image.analysisResult == null) {
          try {
            // Convert bytes to base64
            final base64Image = base64Encode(image.bytes);
            
            // Analyze using custom method for base64 images
            final result = await _analyzeImageWithBase64(
              service: service,
              base64Image: base64Image,
              prompt: prompt,
            );
            
            setState(() {
              image.analysisResult = result;
              image.analysisStatus = AnalysisStatus.completed;
              _analysisProgress = (i + 1) / _uploadedImages.length;
            });
          } catch (e) {
            setState(() {
              image.analysisResult = 'エラー: $e';
              image.analysisStatus = AnalysisStatus.failed;
              _analysisProgress = (i + 1) / _uploadedImages.length;
            });
          }
        }
      }

      setState(() {
        _isAnalyzing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('分析が完了しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分析に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String> _analyzeImageWithBase64({
    required GeminiService service,
    required String base64Image,
    required String prompt,
  }) async {
    // Use the updated analyzeImage method with base64Image parameter
    final response = await service.analyzeImage(
      imageUrl: '', // Not used when base64Image is provided
      prompt: prompt,
      base64Image: base64Image,
    );

    return response;
  }

  void _removeImage(int index) {
    setState(() {
      _uploadedImages.removeAt(index);
    });
  }

  void _clearAll() {
    setState(() {
      _uploadedImages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final settings = settingsProvider.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('自分の画像を分析'),
        actions: [
          if (_uploadedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: '全てクリア',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upload Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.upload_file, color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  '画像をアップロード',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _isAnalyzing ? null : _pickImages,
                                icon: const Icon(Icons.add_photo_alternate),
                                label: const Text('画像を選択'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_uploadedImages.length}枚の画像が選択されています',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Prompt Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.edit_note, color: Colors.purple.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  '分析プロンプト',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _promptController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                labelText: 'AIへの指示',
                                hintText: '例: この画像の建物や看板に書かれているテキストを全て抽出してください',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Analysis Progress
                    if (_isAnalyzing)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                '分析中... ${(_analysisProgress * 100).toStringAsFixed(0)}%',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(value: _analysisProgress),
                            ],
                          ),
                        ),
                      ),

                    // Images Grid
                    if (_uploadedImages.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'アップロード済み画像',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _uploadedImages.length,
                        itemBuilder: (context, index) {
                          final image = _uploadedImages[index];
                          return _ImageCard(
                            image: image,
                            onRemove: () => _removeImage(index),
                            onTap: () => _showImageDetail(context, image),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Analyze Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    if (!settings.hasGeminiKey)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text('Gemini APIキーが設定されていません'),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: (_isAnalyzing || !settings.hasGeminiKey || _uploadedImages.isEmpty)
                            ? null
                            : _analyzeImages,
                        icon: _isAnalyzing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(_isAnalyzing ? '分析中...' : '画像を分析'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDetail(BuildContext context, UploadedImage image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(image.name),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Preview
                      Center(
                        child: Image.memory(
                          image.bytes,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // File Info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ファイル情報',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text('ファイル名: ${image.name}'),
                              Text('サイズ: ${_formatFileSize(image.size)}'),
                              Text('ステータス: ${_getStatusText(image.analysisStatus)}'),
                            ],
                          ),
                        ),
                      ),
                      
                      // Analysis Result
                      if (image.analysisResult != null) ...[
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI分析結果',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                SelectableText(image.analysisResult!),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _getStatusText(AnalysisStatus status) {
    switch (status) {
      case AnalysisStatus.pending:
        return '未分析';
      case AnalysisStatus.analyzing:
        return '分析中';
      case AnalysisStatus.completed:
        return '完了';
      case AnalysisStatus.failed:
        return '失敗';
    }
  }
}

class _ImageCard extends StatelessWidget {
  final UploadedImage image;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _ImageCard({
    required this.image,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.memory(
                    image.bytes,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        image.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _StatusIcon(status: image.analysisStatus),
                          const SizedBox(width: 4),
                          Text(
                            _getStatusText(image.analysisStatus),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getStatusColor(image.analysisStatus),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.close, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  foregroundColor: Colors.white,
                ),
                onPressed: onRemove,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _StatusIcon({required AnalysisStatus status}) {
    IconData icon;
    Color color;
    
    switch (status) {
      case AnalysisStatus.pending:
        icon = Icons.pending;
        color = Colors.grey;
        break;
      case AnalysisStatus.analyzing:
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        break;
      case AnalysisStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case AnalysisStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
    }
    
    return Icon(icon, size: 14, color: color);
  }

  String _getStatusText(AnalysisStatus status) {
    switch (status) {
      case AnalysisStatus.pending:
        return '未分析';
      case AnalysisStatus.analyzing:
        return '分析中';
      case AnalysisStatus.completed:
        return '完了';
      case AnalysisStatus.failed:
        return '失敗';
    }
  }

  Color _getStatusColor(AnalysisStatus status) {
    switch (status) {
      case AnalysisStatus.pending:
        return Colors.grey;
      case AnalysisStatus.analyzing:
        return Colors.orange;
      case AnalysisStatus.completed:
        return Colors.green;
      case AnalysisStatus.failed:
        return Colors.red;
    }
  }
}

enum AnalysisStatus {
  pending,
  analyzing,
  completed,
  failed,
}

class UploadedImage {
  final String name;
  final Uint8List bytes;
  final int size;
  String? analysisResult;
  AnalysisStatus analysisStatus;

  UploadedImage({
    required this.name,
    required this.bytes,
    required this.size,
    this.analysisResult,
    this.analysisStatus = AnalysisStatus.pending,
  });
}
