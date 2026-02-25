/// Application-wide constants and Supabase configuration.
library;

class AppConstants {
  AppConstants._();

  // ── Supabase ──────────────────────────────────────────────────────────────
  // Replace these with your actual Supabase project credentials.
  static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';

  // ── App Info ──────────────────────────────────────────────────────────────
  static const String appName = 'Restaurant SaaS';
  static const String appVersion = '1.0.0';

  // ── Table Names ───────────────────────────────────────────────────────────
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
