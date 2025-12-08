class MapillaryImage {
  final String id;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? compassAngle;
  final DateTime capturedAt;
  final String? sequenceId;
  final String? creatorUsername;
  final String? creatorId;
  final String imageUrl;
  final String thumbUrl;
  
  // Camera EXIF data
  final String? cameraMake;
  final String? cameraModel;
  final int? width;
  final int? height;
  
  // Additional metadata
  final bool? isPano;
  final String? organizationId;
  final Map<String, dynamic>? additionalProperties;

  MapillaryImage({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.compassAngle,
    required this.capturedAt,
    this.sequenceId,
    this.creatorUsername,
    this.creatorId,
    required this.imageUrl,
    required this.thumbUrl,
    this.cameraMake,
    this.cameraModel,
    this.width,
    this.height,
    this.isPano,
    this.organizationId,
    this.additionalProperties,
  });

  factory MapillaryImage.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'];
    final coordinates = geometry['coordinates'] as List;
    final properties = json['properties'] ?? {};
    
    return MapillaryImage(
      id: json['id']?.toString() ?? '',
      longitude: (coordinates[0] as num).toDouble(),
      latitude: (coordinates[1] as num).toDouble(),
      altitude: coordinates.length > 2 ? (coordinates[2] as num?)?.toDouble() : null,
      compassAngle: properties['compass_angle'] != null 
          ? (properties['compass_angle'] as num).toDouble() 
          : null,
      capturedAt: DateTime.parse(properties['captured_at'] ?? DateTime.now().toIso8601String()),
      sequenceId: properties['sequence_id']?.toString(),
      creatorUsername: properties['creator_username']?.toString(),
      creatorId: properties['creator_id']?.toString(),
      imageUrl: 'https://graph.mapillary.com/${json['id']}/thumb_2048',
      thumbUrl: 'https://graph.mapillary.com/${json['id']}/thumb_256',
      cameraMake: properties['camera_make']?.toString(),
      cameraModel: properties['camera_model']?.toString(),
      width: properties['width'] as int?,
      height: properties['height'] as int?,
      isPano: properties['is_pano'] as bool?,
      organizationId: properties['organization_id']?.toString(),
      additionalProperties: properties,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'compass_angle': compassAngle,
      'captured_at': capturedAt.toIso8601String(),
      'sequence_id': sequenceId,
      'creator_username': creatorUsername,
      'creator_id': creatorId,
      'image_url': imageUrl,
      'thumb_url': thumbUrl,
      'camera_make': cameraMake,
      'camera_model': cameraModel,
      'width': width,
      'height': height,
      'is_pano': isPano,
      'organization_id': organizationId,
      ...?additionalProperties,
    };
  }

  Map<String, dynamic> toExcelRow() {
    return {
      'Image ID': id,
      'Latitude': latitude,
      'Longitude': longitude,
      'Altitude': altitude ?? '',
      'Compass Angle': compassAngle ?? '',
      'Captured At': capturedAt.toIso8601String(),
      'Sequence ID': sequenceId ?? '',
      'Creator Username': creatorUsername ?? '',
      'Creator ID': creatorId ?? '',
      'Image URL': imageUrl,
      'Thumbnail URL': thumbUrl,
      'Camera Make': cameraMake ?? '',
      'Camera Model': cameraModel ?? '',
      'Width': width ?? '',
      'Height': height ?? '',
      'Is Panorama': isPano ?? false,
      'Organization ID': organizationId ?? '',
    };
  }
}
