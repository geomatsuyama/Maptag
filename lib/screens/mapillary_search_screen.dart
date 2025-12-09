import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/search_area.dart';
import '../models/mapillary_image.dart';
import '../services/mapillary_service.dart';

class MapillarySearchScreen extends StatefulWidget {
  const MapillarySearchScreen({super.key});

  @override
  State<MapillarySearchScreen> createState() => _MapillarySearchScreenState();
}

class _MapillarySearchScreenState extends State<MapillarySearchScreen> {
  SearchAreaType _selectedSearchType = SearchAreaType.pointRadius;
  
  // Point + Radius
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _radiusController = TextEditingController(text: '1000');
  
  // Bounding Box
  final _minLonController = TextEditingController();
  final _minLatController = TextEditingController();
  final _maxLonController = TextEditingController();
  final _maxLatController = TextEditingController();
  
  // Polygon
  final _polygonController = TextEditingController();
  
  List<MapillaryImage> _searchResults = [];
  bool _isSearching = false;
  double _searchProgress = 0.0;
  String? _errorMessage;

  @override
  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    _radiusController.dispose();
    _minLonController.dispose();
    _minLatController.dispose();
    _maxLonController.dispose();
    _maxLatController.dispose();
    _polygonController.dispose();
    super.dispose();
  }

  void _loadTokyoExample() {
    setState(() {
      _latController.text = '35.6812';
      _lonController.text = '139.7671';
      _radiusController.text = '500';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Loaded Tokyo coordinates')),
    );
  }

  Future<void> _performSearch() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final settings = settingsProvider.settings;

    if (!settings.hasMapillaryKey) {
      setState(() {
        _errorMessage = 'Please configure Mapillary API key in Settings';
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

      switch (_selectedSearchType) {
        case SearchAreaType.pointRadius:
          final lat = double.tryParse(_latController.text);
          final lon = double.tryParse(_lonController.text);
          final radius = double.tryParse(_radiusController.text);

          if (lat == null || lon == null || radius == null) {
            throw Exception('Invalid coordinates or radius');
          }

          searchArea = SearchArea.pointRadius(
            latitude: lat,
            longitude: lon,
            radiusMeters: radius,
          );
          break;

        case SearchAreaType.boundingBox:
          final minLon = double.tryParse(_minLonController.text);
          final minLat = double.tryParse(_minLatController.text);
          final maxLon = double.tryParse(_maxLonController.text);
          final maxLat = double.tryParse(_maxLatController.text);

          if (minLon == null || minLat == null || maxLon == null || maxLat == null) {
            throw Exception('Invalid bounding box coordinates');
          }

          searchArea = SearchArea.boundingBox(
            minLongitude: minLon,
            minLatitude: minLat,
            maxLongitude: maxLon,
            maxLatitude: maxLat,
          );
          break;

        case SearchAreaType.polygon:
          // Parse polygon coordinates from text
          // Format: "lon1,lat1;lon2,lat2;lon3,lat3"
          final coordsText = _polygonController.text.trim();
          final coordPairs = coordsText.split(';');
          
          final coordinates = <List<double>>[];
          for (var pair in coordPairs) {
            final parts = pair.split(',');
            if (parts.length != 2) {
              throw Exception('Invalid polygon format. Use: lon1,lat1;lon2,lat2;...');
            }
            final lon = double.tryParse(parts[0].trim());
            final lat = double.tryParse(parts[1].trim());
            if (lon == null || lat == null) {
              throw Exception('Invalid polygon coordinates');
            }
            coordinates.add([lon, lat]);
          }

          if (coordinates.length < 3) {
            throw Exception('Polygon must have at least 3 vertices');
          }

          searchArea = SearchArea.polygon(coordinates: coordinates);
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
          SnackBar(content: Text('Found ${results.length} images')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isSearching = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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
        title: const Text('Mapillary Search'),
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
                    // Search Type Selection
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Search Type',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            SegmentedButton<SearchAreaType>(
                              segments: const [
                                ButtonSegment(
                                  value: SearchAreaType.pointRadius,
                                  label: Text('Point'),
                                  icon: Icon(Icons.location_on, size: 16),
                                ),
                                ButtonSegment(
                                  value: SearchAreaType.boundingBox,
                                  label: Text('BBox'),
                                  icon: Icon(Icons.crop_square, size: 16),
                                ),
                                ButtonSegment(
                                  value: SearchAreaType.polygon,
                                  label: Text('Polygon'),
                                  icon: Icon(Icons.polyline, size: 16),
                                ),
                              ],
                              selected: {_selectedSearchType},
                              onSelectionChanged: (Set<SearchAreaType> newSelection) {
                                setState(() {
                                  _selectedSearchType = newSelection.first;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search Parameters
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildSearchParametersForm(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Error Message
                    if (_errorMessage != null)
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

                    // Search Progress
                    if (_isSearching)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                'Searching... ${(_searchProgress * 100).toStringAsFixed(0)}%',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(value: _searchProgress),
                            ],
                          ),
                        ),
                      ),

                    // Search Results
                    if (_searchResults.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Results (${_searchResults.length} images)',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mode: ${settings.isPremiumMode ? "Premium (${settings.imageLimit} max)" : "Free (${settings.imageLimit} max)"}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final image = _searchResults[index];
                          return Card(
                            child: ListTile(
                              title: Text('ID: ${image.id}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Location: ${image.latitude.toStringAsFixed(6)}, ${image.longitude.toStringAsFixed(6)}'),
                                  Text('Captured: ${image.capturedAt.toString().split('.')[0]}'),
                                  if (image.cameraMake != null)
                                    Text('Camera: ${image.cameraMake} ${image.cameraModel ?? ""}'),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Search Button
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
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSearching ? null : _performSearch,
                    icon: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isSearching ? 'Searching...' : 'Search Images'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchParametersForm() {
    switch (_selectedSearchType) {
      case SearchAreaType.pointRadius:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Point + Radius Search',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      hintText: 'e.g., 35.6812',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.location_city),
                  tooltip: 'Load Tokyo example',
                  onPressed: _loadTokyoExample,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lonController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                hintText: 'e.g., 139.7671',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _radiusController,
              decoration: const InputDecoration(
                labelText: 'Radius (meters)',
                hintText: 'e.g., 1000',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        );

      case SearchAreaType.boundingBox:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bounding Box Search',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minLonController,
                    decoration: const InputDecoration(
                      labelText: 'Min Longitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _minLatController,
                    decoration: const InputDecoration(
                      labelText: 'Min Latitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _maxLonController,
                    decoration: const InputDecoration(
                      labelText: 'Max Longitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _maxLatController,
                    decoration: const InputDecoration(
                      labelText: 'Max Latitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        );

      case SearchAreaType.polygon:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Polygon Search',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _polygonController,
              decoration: const InputDecoration(
                labelText: 'Polygon Coordinates',
                hintText: 'lon1,lat1;lon2,lat2;lon3,lat3',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Text(
              'Format: longitude,latitude separated by semicolons',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        );
    }
  }
}
