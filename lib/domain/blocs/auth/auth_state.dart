import 'package:equatable/equatable.dart';
import 'package:restaurant/config/constants.dart';
import 'package:restaurant/data/models/user_model.dart';

/// Base class for all authentication states.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial / unknown state before any auth check.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// An auth operation is in progress.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// The user is authenticated.
final class Authenticated extends AuthState {
  const Authenticated({required this.user, required this.role});

  final UserModel user;
  final UserRole role;

  @override
  List<Object?> get props => [user, role];
}

/// The user is **not** authenticated.
final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Authentication failed with an error message.
final class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
