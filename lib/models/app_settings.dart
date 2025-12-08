class AppSettings {
  String? mapillaryApiKey;
  String? geminiApiKey;
  bool isPremiumMode;
  
  // Free mode limits
  static const int freeModeImageLimit = 100;
  static const int premiumModeImageLimit = 200000;

  AppSettings({
    this.mapillaryApiKey,
    this.geminiApiKey,
    this.isPremiumMode = false,
  });

  int get imageLimit => isPremiumMode ? premiumModeImageLimit : freeModeImageLimit;

  bool get hasMapillaryKey => mapillaryApiKey != null && mapillaryApiKey!.isNotEmpty;
  bool get hasGeminiKey => geminiApiKey != null && geminiApiKey!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'mapillary_api_key': mapillaryApiKey,
      'gemini_api_key': geminiApiKey,
      'is_premium_mode': isPremiumMode,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      mapillaryApiKey: json['mapillary_api_key'] as String?,
      geminiApiKey: json['gemini_api_key'] as String?,
      isPremiumMode: json['is_premium_mode'] as bool? ?? false,
    );
  }

  AppSettings copyWith({
    String? mapillaryApiKey,
    String? geminiApiKey,
    bool? isPremiumMode,
  }) {
    return AppSettings(
      mapillaryApiKey: mapillaryApiKey ?? this.mapillaryApiKey,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      isPremiumMode: isPremiumMode ?? this.isPremiumMode,
    );
  }
}
