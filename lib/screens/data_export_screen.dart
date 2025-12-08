import 'package:flutter/material.dart';

class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  State<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  bool _includeEXIF = true;
  bool _includeMetadata = true;
  bool _includeAnalysis = false;
  String _selectedFormat = 'json';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Export'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
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
                            'Export Data',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Export your Mapillary search results and AI analysis to JSON or Excel format. '
                        'Perfect for GIS analysis and further data processing.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Export Format
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export Format',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'json',
                            label: Text('JSON'),
                            icon: Icon(Icons.code, size: 16),
                          ),
                          ButtonSegment(
                            value: 'excel',
                            label: Text('Excel'),
                            icon: Icon(Icons.table_chart, size: 16),
                          ),
                          ButtonSegment(
                            value: 'csv',
                            label: Text('CSV'),
                            icon: Icon(Icons.description, size: 16),
                          ),
                        ],
                        selected: {_selectedFormat},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _selectedFormat = newSelection.first;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Data Options
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Options',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        title: const Text('Include EXIF Data'),
                        subtitle: const Text('Lat/Lng, Altitude, Compass, Camera info'),
                        value: _includeEXIF,
                        onChanged: (value) {
                          setState(() {
                            _includeEXIF = value ?? true;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Include Metadata'),
                        subtitle: const Text('Sequence ID, Creator, Organization'),
                        value: _includeMetadata,
                        onChanged: (value) {
                          setState(() {
                            _includeMetadata = value ?? true;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Include AI Analysis'),
                        subtitle: const Text('Gemini analysis results (if available)'),
                        value: _includeAnalysis,
                        onChanged: (value) {
                          setState(() {
                            _includeAnalysis = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Export Preview
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export Preview',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildExportPreview(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Recent Exports (placeholder)
              Text(
                'Recent Exports',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.folder_open, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'No exports yet',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Search for images first, then export results here',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please search for images first in the Mapillary tab'),
            ),
          );
        },
        icon: const Icon(Icons.download),
        label: const Text('Export Data'),
      ),
    );
  }

  Widget _buildExportPreview() {
    final fields = <String>[];
    
    if (_includeEXIF) {
      fields.addAll([
        'Image ID',
        'Latitude',
        'Longitude',
        'Altitude',
        'Compass Angle',
        'Captured At',
        'Camera Make',
        'Camera Model',
      ]);
    }
    
    if (_includeMetadata) {
      fields.addAll([
        'Sequence ID',
        'Creator Username',
        'Organization ID',
        'Image URL',
      ]);
    }
    
    if (_includeAnalysis) {
      fields.add('AI Analysis Result');
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fields to export (${fields.length} total):',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: fields.map((field) {
              return Chip(
                label: Text(
                  field,
                  style: const TextStyle(fontSize: 12),
                ),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
