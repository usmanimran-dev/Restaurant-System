import 'package:equatable/equatable.dart';

/// Base class for all authentication events.
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the user taps the login button.
final class LoginRequested extends AuthEvent {
  const LoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Fired when the user taps logout.
final class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Fired on app start to check for an existing session.
final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Fired when Super Admin clicks "Manage" on a restaurant card.
/// Temporarily switches the auth context to act as that restaurant's admin.
final class SwitchRestaurantContext extends AuthEvent {
  const SwitchRestaurantContext({required this.restaurantId, required this.restaurantName});

  final String restaurantId;
  final String restaurantName;

  @override
  List<Object?> get props => [restaurantId, restaurantName];
}
