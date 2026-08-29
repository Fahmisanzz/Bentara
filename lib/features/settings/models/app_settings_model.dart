class AppSettingsModel {
  final double ttsSpeed;
  final double ttsPitch;
  final bool enableHighContrast;
  final bool enableHaptics;
  final double textScaleFactor;
  final String preferredLanguage;

  const AppSettingsModel({
    this.ttsSpeed = 0.5,
    this.ttsPitch = 1.0,
    this.enableHighContrast = false,
    this.enableHaptics = true,
    this.textScaleFactor = 1.0,
    this.preferredLanguage = 'id-ID',
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      ttsSpeed: json['ttsSpeed']?.toDouble() ?? 0.5,
      ttsPitch: json['ttsPitch']?.toDouble() ?? 1.0,
      enableHighContrast: json['enableHighContrast'] ?? false,
      enableHaptics: json['enableHaptics'] ?? true,
      textScaleFactor: json['textScaleFactor']?.toDouble() ?? 1.0,
      preferredLanguage: json['preferredLanguage'] ?? 'id-ID',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ttsSpeed': ttsSpeed,
      'ttsPitch': ttsPitch,
      'enableHighContrast': enableHighContrast,
      'enableHaptics': enableHaptics,
      'textScaleFactor': textScaleFactor,
      'preferredLanguage': preferredLanguage,
    };
  }

  AppSettingsModel copyWith({
    double? ttsSpeed,
    double? ttsPitch,
    bool? enableHighContrast,
    bool? enableHaptics,
    double? textScaleFactor,
    String? preferredLanguage,
  }) {
    return AppSettingsModel(
      ttsSpeed: ttsSpeed ?? this.ttsSpeed,
      ttsPitch: ttsPitch ?? this.ttsPitch,
      enableHighContrast: enableHighContrast ?? this.enableHighContrast,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }
}
