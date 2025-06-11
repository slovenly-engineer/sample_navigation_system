enum SettingsTab {
  general,
  notifications,
  privacy,
  about;
}

class SettingsData {
  final bool darkMode;
  final String language;
  final bool notificationsEnabled;

  const SettingsData({
    this.darkMode = false,
    this.language = 'ja',
    this.notificationsEnabled = true,
  });

  SettingsData copyWith({
    bool? darkMode,
    String? language,
    bool? notificationsEnabled,
  }) {
    return SettingsData(
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}