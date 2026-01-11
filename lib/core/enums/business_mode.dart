/// Business mode enum
/// Represents the current mode of the application for business accounts
enum BusinessMode {
  /// Normal user mode - standard app features
  normal,

  /// Business mode - business management features
  business;

  /// Get display name for the mode
  String get displayName {
    switch (this) {
      case BusinessMode.normal:
        return 'Normal Kullanıcı';
      case BusinessMode.business:
        return 'İşletme Modu';
    }
  }

  /// Get description for the mode
  String get description {
    switch (this) {
      case BusinessMode.normal:
        return 'Mekanları keşfet, favorile ve randevu al';
      case BusinessMode.business:
        return 'İşletmeni yönet, kampanya oluştur ve müşterilerinle iletişime geç';
    }
  }

  /// Convert to string for storage
  String toStorageString() {
    return name;
  }

  /// Create from storage string
  static BusinessMode fromStorageString(String value) {
    return BusinessMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => BusinessMode.normal,
    );
  }
}
