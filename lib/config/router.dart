import 'package:flutter/material.dart';
import 'package:restaurant/config/constants.dart';
import 'package:restaurant/presentation/screens/employee_dashboard.dart';
import 'package:restaurant/presentation/screens/login_screen.dart';
import 'package:restaurant/presentation/screens/restaurant_admin_dashboard.dart';
import 'package:restaurant/presentation/screens/super_admin_dashboard.dart';

/// Application route names.
class Routes {
  Routes._();

  static const String login = '/login';
  static const String superAdmin = '/super-admin';
  static const String restaurantAdmin = '/restaurant-admin';
  static const String employee = '/employee';
}

/// Central router that generates routes and handles role‑based redirection.
class AppRouter {
  /// Returns the initial route name based on the user's [role].
  /// If [role] is null the user is unauthenticated → login.
  static String initialRouteForRole(UserRole? role) {
    if (role == null) return Routes.login;
    switch (role) {
      case UserRole.superAdmin:
        return Routes.superAdmin;
      case UserRole.restaurantAdmin:
        return Routes.restaurantAdmin;
      case UserRole.employee:
        return Routes.employee;
    }
  }

  /// Standard [onGenerateRoute] callback for [MaterialApp].
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.login:
        return _buildRoute(const LoginScreen(), settings);
      case Routes.superAdmin:
        return _buildRoute(const SuperAdminDashboard(), settings);
      case Routes.restaurantAdmin:
        return _buildRoute(const RestaurantAdminDashboard(), settings);
      case Routes.employee:
        return _buildRoute(const EmployeeDashboard(), settings);
      default:
        return _buildRoute(const LoginScreen(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => page,
      settings: settings,
    );
  }
}
