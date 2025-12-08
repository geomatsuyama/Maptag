enum SearchAreaType {
  pointRadius,
  boundingBox,
  polygon,
}

class SearchArea {
  final SearchAreaType type;
  final Map<String, dynamic> parameters;

  SearchArea({
    required this.type,
    required this.parameters,
  });

  // Point + Radius search
  factory SearchArea.pointRadius({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) {
    return SearchArea(
      type: SearchAreaType.pointRadius,
      parameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radiusMeters,
      },
    );
  }

  // Bounding Box search
  factory SearchArea.boundingBox({
    required double minLongitude,
    required double minLatitude,
    required double maxLongitude,
    required double maxLatitude,
  }) {
    return SearchArea(
      type: SearchAreaType.boundingBox,
      parameters: {
        'min_longitude': minLongitude,
        'min_latitude': minLatitude,
        'max_longitude': maxLongitude,
        'max_latitude': maxLatitude,
      },
    );
  }

  // Polygon search (custom area)
  factory SearchArea.polygon({
    required List<List<double>> coordinates,
  }) {
    return SearchArea(
      type: SearchAreaType.polygon,
      parameters: {
        'coordinates': coordinates,
      },
    );
  }

  String get description {
    switch (type) {
      case SearchAreaType.pointRadius:
        return 'Point: (${parameters['latitude']}, ${parameters['longitude']}) + ${parameters['radius']}m';
      case SearchAreaType.boundingBox:
        return 'BBox: [${parameters['min_longitude']}, ${parameters['min_latitude']}, ${parameters['max_longitude']}, ${parameters['max_latitude']}]';
      case SearchAreaType.polygon:
        final coords = parameters['coordinates'] as List;
        return 'Polygon: ${coords.length} vertices';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'parameters': parameters,
    };
  }
}
