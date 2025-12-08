import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/search_area.dart';
import '../models/mapillary_image.dart';
import '../services/mapillary_service.dart';
import 'batch_analysis_screen.dart';

enum MapSelectionMode {
  pointRadius,
  boundingBox,
  polygon,
}

class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({super.key});

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  final MapController _mapController = MapController();
  MapSelectionMode _selectionMode = MapSelectionMode.pointRadius;
  
  // Point + Radius mode
  LatLng? _selectedPoint;
  double _radius = 1000; // meters
  
  // Bounding Box mode
  LatLng? _bboxStart;
  LatLng? _bboxEnd;
  
  // Polygon mode
  List<LatLng> _polygonPoints = [];
  
  // Search results
  List<MapillaryImage> _searchResults = [];
  bool _isSearching = false;
  double _searchProgress = 0.0;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地図で検索エリア指定'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'クリア',
            onPressed: _clearSelection,
          ),
        ],
      ),
      body: Column(
        children: [
          // Selection Mode Tabs
          Container(
            padding: const EdgeInsets.all(8),
            child: SegmentedButton<MapSelectionMode>(
              segments: const [
                ButtonSegment(
                  value: MapSelectionMode.pointRadius,
                  label: Text('地点+半径'),
                  icon: Icon(Icons.location_on, size: 16),
                ),
                ButtonSegment(
                  value: MapSelectionMode.boundingBox,
                  label: Text('矩形範囲'),
                  icon: Icon(Icons.crop_square, size: 16),
                ),
                ButtonSegment(
                  value: MapSelectionMode.polygon,
                  label: Text('ポリゴン'),
                  icon: Icon(Icons.polyline, size: 16),
                ),
              ],
              selected: {_selectionMode},
              onSelectionChanged: (Set<MapSelectionMode> newSelection) {
                setState(() {
                  _selectionMode = newSelection.first;
                  _clearSelection();
                });
              },
            ),
          ),

          // Instructions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getInstructionText(),
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Radius slider (for point mode)
          if (_selectionMode == MapSelectionMode.pointRadius && _selectedPoint != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('半径: ${_radius.toInt()}m'),
                  Slider(
                    value: _radius,
                    min: 100,
                    max: 5000,
                    divisions: 49,
                    label: '${_radius.toInt()}m',
                    onChanged: (value) {
                      setState(() {
                        _radius = value;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Map
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(35.6812, 139.7671), // Tokyo
                initialZoom: 13.0,
                onTap: (tapPosition, point) => _handleMapTap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.mapanalyzer.analysis',
                ),
                ..._buildSelectionLayers(),
                if (_searchResults.isNotEmpty) _buildResultMarkers(),
              ],
            ),
          ),

          // Search Progress
          if (_isSearching)
            LinearProgressIndicator(value: _searchProgress),

          // Action Buttons
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
              child: Row(
                children: [
                  if (_searchResults.isNotEmpty) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showResultsDialog(),
                        icon: const Icon(Icons.list),
                        label: Text('結果: ${_searchResults.length}件'),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _canSearch() && !_isSearching ? _performSearch : null,
                      icon: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      label: Text(_isSearching ? '検索中...' : '検索実行'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInstructionText() {
    switch (_selectionMode) {
      case MapSelectionMode.pointRadius:
        return '地図上をタップして中心点を選択してください';
      case MapSelectionMode.boundingBox:
        return '地図上を2回タップして矩形の対角線を指定してください';
      case MapSelectionMode.polygon:
        return '地図上を複数回タップしてポリゴンを作成してください';
    }
  }

  void _handleMapTap(LatLng point) {
    setState(() {
      switch (_selectionMode) {
        case MapSelectionMode.pointRadius:
          _selectedPoint = point;
          break;
        case MapSelectionMode.boundingBox:
          if (_bboxStart == null) {
            _bboxStart = point;
          } else {
            _bboxEnd = point;
          }
          break;
        case MapSelectionMode.polygon:
          _polygonPoints.add(point);
          break;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedPoint = null;
      _bboxStart = null;
      _bboxEnd = null;
      _polygonPoints.clear();
      _errorMessage = null;
    });
  }

  bool _canSearch() {
    switch (_selectionMode) {
      case MapSelectionMode.pointRadius:
        return _selectedPoint != null;
      case MapSelectionMode.boundingBox:
        return _bboxStart != null && _bboxEnd != null;
      case MapSelectionMode.polygon:
        return _polygonPoints.length >= 3;
    }
  }

  Future<void> _performSearch() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final settings = settingsProvider.settings;

    if (!settings.hasMapillaryKey) {
      setState(() {
        _errorMessage = 'Mapillary APIキーが設定されていません';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _searchProgress = 0.0;
      _searchResults = [];
    });

    try {
      SearchArea? searchArea;

      switch (_selectionMode) {
        case MapSelectionMode.pointRadius:
          searchArea = SearchArea.pointRadius(
            latitude: _selectedPoint!.latitude,
            longitude: _selectedPoint!.longitude,
            radiusMeters: _radius,
          );
          break;

        case MapSelectionMode.boundingBox:
          final minLat = _bboxStart!.latitude < _bboxEnd!.latitude
              ? _bboxStart!.latitude
              : _bboxEnd!.latitude;
          final maxLat = _bboxStart!.latitude > _bboxEnd!.latitude
              ? _bboxStart!.latitude
              : _bboxEnd!.latitude;
          final minLon = _bboxStart!.longitude < _bboxEnd!.longitude
              ? _bboxStart!.longitude
              : _bboxEnd!.longitude;
          final maxLon = _bboxStart!.longitude > _bboxEnd!.longitude
              ? _bboxStart!.longitude
              : _bboxEnd!.longitude;

          searchArea = SearchArea.boundingBox(
            minLongitude: minLon,
            minLatitude: minLat,
            maxLongitude: maxLon,
            maxLatitude: maxLat,
          );
          break;

        case MapSelectionMode.polygon:
          searchArea = SearchArea.polygon(
            coordinates: _polygonPoints
                .map((point) => [point.longitude, point.latitude])
                .toList(),
          );
          break;
      }

      final service = MapillaryService(apiKey: settings.mapillaryApiKey!);

      final results = await service.searchImages(
        searchArea: searchArea,
        limit: settings.imageLimit,
        onProgress: (current, total) {
          setState(() {
            _searchProgress = current / total;
          });
        },
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${results.length}件の画像が見つかりました')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isSearching = false;
      });
    }
  }

  List<Widget> _buildSelectionLayers() {
    final layers = <Widget>[];

    switch (_selectionMode) {
      case MapSelectionMode.pointRadius:
        if (_selectedPoint != null) {
          layers.add(
            CircleLayer(
              circles: [
                CircleMarker(
                  point: _selectedPoint!,
                  radius: _radius,
                  useRadiusInMeter: true,
                  color: Colors.blue.withValues(alpha: 0.3),
                  borderColor: Colors.blue,
                  borderStrokeWidth: 2,
                ),
              ],
            ),
          );
          layers.add(
            MarkerLayer(
              markers: [
                Marker(
                  point: _selectedPoint!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          );
        }
        break;

      case MapSelectionMode.boundingBox:
        if (_bboxStart != null && _bboxEnd != null) {
          layers.add(
            PolygonLayer(
              polygons: [
                Polygon(
                  points: [
                    LatLng(_bboxStart!.latitude, _bboxStart!.longitude),
                    LatLng(_bboxStart!.latitude, _bboxEnd!.longitude),
                    LatLng(_bboxEnd!.latitude, _bboxEnd!.longitude),
                    LatLng(_bboxEnd!.latitude, _bboxStart!.longitude),
                  ],
                  color: Colors.green.withValues(alpha: 0.3),
                  borderColor: Colors.green,
                  borderStrokeWidth: 2,
                  isFilled: true,
                ),
              ],
            ),
          );
        } else if (_bboxStart != null) {
          layers.add(
            MarkerLayer(
              markers: [
                Marker(
                  point: _bboxStart!,
                  width: 30,
                  height: 30,
                  child: const Icon(
                    Icons.crop_square,
                    color: Colors.green,
                    size: 30,
                  ),
                ),
              ],
            ),
          );
        }
        break;

      case MapSelectionMode.polygon:
        if (_polygonPoints.length >= 3) {
          layers.add(
            PolygonLayer(
              polygons: [
                Polygon(
                  points: _polygonPoints,
                  color: Colors.purple.withValues(alpha: 0.3),
                  borderColor: Colors.purple,
                  borderStrokeWidth: 2,
                  isFilled: true,
                ),
              ],
            ),
          );
        }
        if (_polygonPoints.isNotEmpty) {
          layers.add(
            MarkerLayer(
              markers: _polygonPoints
                  .asMap()
                  .entries
                  .map(
                    (entry) => Marker(
                      point: entry.value,
                      width: 30,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        }
        break;
    }

    return layers;
  }

  Widget _buildResultMarkers() {
    return MarkerLayer(
      markers: _searchResults
          .map(
            (img) => Marker(
              point: LatLng(img.latitude, img.longitude),
              width: 20,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  void _showResultsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '検索結果: ${_searchResults.length}件',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // AI Analysis button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BatchAnalysisScreen(
                          images: _searchResults,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.psychology),
                  label: const Text('AI一括分析を実行'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final image = _searchResults[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.image),
                        title: Text('ID: ${image.id.substring(0, 12)}...'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location: ${image.latitude.toStringAsFixed(6)}, ${image.longitude.toStringAsFixed(6)}',
                            ),
                            Text('Captured: ${image.capturedAt.toString().split('.')[0]}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () {
                            // Open image in new tab
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
