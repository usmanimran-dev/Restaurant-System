/// Application-wide constants and Firebase configuration.
library;

class AppConstants {
  AppConstants._();

  // ── App Info ──────────────────────────────────────────────────────────────
  static const String appName = 'Restaurant SaaS';
  static const String appVersion = '1.0.0';

  // ── Firestore Collection Names ────────────────────────────────────────────
  static const String restaurantsTable = 'restaurants';
  static const String usersTable = 'users';
  static const String rolesTable = 'roles';
  static const String featureFlagsTable = 'feature_flags';
}

/// Available user roles in the system.
enum UserRole {
  superAdmin('super_admin'),
  restaurantAdmin('restaurant_admin'),
  employee('employee');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.employee,
    );
  }
}
