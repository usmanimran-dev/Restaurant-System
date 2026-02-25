import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:restaurant/config/constants.dart';
import 'package:restaurant/data/models/user_model.dart';
import 'package:restaurant/data/repositories/auth_repository.dart';
import 'package:restaurant/domain/blocs/auth/auth_event.dart';
import 'package:restaurant/domain/blocs/auth/auth_state.dart';

/// Manages authentication state across the application.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SwitchRestaurantContext>(_onSwitchRestaurantContext);
  }

  final AuthRepository _authRepository;

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );

      emit(Authenticated(
        user: user,
        role: _resolveRole(user),
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(const Unauthenticated());
  }

  // ── Session Check ─────────────────────────────────────────────────────────

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(
          user: user,
          role: _resolveRole(user),
        ));
      } else {
        emit(const Unauthenticated());
      }
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  // ── Switch Restaurant Context (Super Admin → Restaurant Admin) ────────────

  void _onSwitchRestaurantContext(
    SwitchRestaurantContext event,
    Emitter<AuthState> emit,
  ) {
    final currentState = state;
    if (currentState is Authenticated) {
      // Create a modified user with the selected restaurant's context
      final modifiedUser = currentState.user.copyWith(
        restaurantId: event.restaurantId,
        roleName: 'restaurant_admin',
      );
      emit(Authenticated(
        user: modifiedUser,
        role: UserRole.restaurantAdmin,
      ));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  UserRole _resolveRole(UserModel user) {
    return UserRole.fromString(user.roleName ?? 'employee');
  }
}
