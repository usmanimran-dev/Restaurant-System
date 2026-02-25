import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/domain/blocs/auth/auth_bloc.dart';
import 'package:restaurant/domain/blocs/auth/auth_state.dart';

/// Hides or disables a UI component based on the user's role permissions.
///
/// If [permissionKey] is provided, it checks the role's permissions map.
/// If [requiredRole] is provided, it strictly checks the user's role.
class PermissionGuard extends StatelessWidget {
  const PermissionGuard({
    super.key,
    required this.child,
    this.permissionKey,
    this.requiredRole,
    this.fallback = const SizedBox.shrink(),
    this.disableInsteadOfHide = false,
  });

  final Widget child;
  /// Example: 'inventory.view' or 'employees.create'
  final String? permissionKey;
  /// Provide this to restrict to 'superAdmin', 'restaurantAdmin', or 'employee'
  final String? requiredRole;
  
  /// What to render if the user lacks permission
  final Widget fallback;
  
  /// If true, renders the child inside an AbsorbPointer + Opacity instead of hiding it
  final bool disableInsteadOfHide;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) return fallback;

        bool hasAccess = true;

        if (requiredRole != null) {
          hasAccess = state.role.value == requiredRole;
        } else if (permissionKey != null) {
          // In a real app, state.user or state.roleModel should hold the actual permissions JSON.
          // For now, if the user is a superAdmin or restaurantAdmin, they get access to everything.
          // Employees only get access if they specifically have the permission.
          if (state.role.value == 'super_admin' || state.role.value == 'restaurant_admin') {
            hasAccess = true;
          } else {
            // Placeholder: Assume Employee lacks restricted keys unless granted.
            // This requires the RoleModel payload to be available in the AuthBloc state.
            hasAccess = false; 
          }
        }

        if (hasAccess) return child;

        if (disableInsteadOfHide) {
          return Opacity(
            opacity: 0.5,
            child: AbsorbPointer(child: child),
          );
        }

        return fallback;
      },
    );
  }
}
