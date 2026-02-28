import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:restaurant/config/constants.dart';
import 'package:restaurant/config/router.dart';
import 'package:restaurant/config/theme.dart';
import 'package:restaurant/core/di/injection_container.dart';
import 'package:restaurant/domain/blocs/auth/auth_bloc.dart';
import 'package:restaurant/domain/blocs/auth/auth_event.dart';
import 'package:restaurant/domain/blocs/auth/auth_state.dart';
import 'package:restaurant/domain/blocs/delivery/delivery_bloc.dart';
import 'package:restaurant/domain/blocs/supplier/supplier_bloc.dart';
import 'package:restaurant/domain/blocs/customer/customer_bloc.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase ──────────────────────────────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── One-Time Bootstrap ────────────────────────────────────────────────────
  // Automatically creates the initial Super Admin account if it doesn't exist.
  // This only runs once — on subsequent launches it detects the account and skips.
  await _bootstrapSuperAdmin();

  // ── Dependency Injection ──────────────────────────────────────────────────
  setupDependencies();

  runApp(const RestaurantSaasApp());
}

/// Creates the initial Super Admin user in Firebase Auth + Firestore
/// if no super admin exists yet. Runs silently on every launch.
Future<void> _bootstrapSuperAdmin() async {
  const String adminEmail = 'admin@zyfloatix.com';
  const String adminPassword = 'admin123';
  const String adminName = 'Super Admin';

  try {
    final firestore = FirebaseFirestore.instance;
    final auth = fb_auth.FirebaseAuth.instance;

    // Firestore rules block unauthenticated reads. So we do not query for
    // an existing super admin doc. Instead, we try to sign in (if exists)
    // or create the user (first run), then ensure /users/{uid} exists.
    fb_auth.UserCredential cred;
    try {
      cred = await auth.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
      debugPrint('✅ Super Admin auth account exists — ensuring profile.');
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        debugPrint('🔧 No Super Admin auth account found. Creating initial admin account...');
        cred = await auth.createUserWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
      } else if (e.code == 'wrong-password') {
        debugPrint('⚠️ Bootstrap skipped: wrong password for $adminEmail.');
        return;
      } else {
        rethrow;
      }
    }

    final uid = cred.user!.uid;

    // Wait for FirebaseAuth singleton to reflect the signed-in user.
    await auth.authStateChanges().firstWhere((user) => user?.uid == uid);
    await auth.currentUser?.getIdToken(true);

    debugPrint('🔐 Bootstrap auth uid: ${auth.currentUser?.uid} (expected $uid)');

    // Create/merge the Super Admin user document in Firestore
    // (allowed because we are authenticated as that user).
    final superAdminData = {
      'email': adminEmail,
      'name': adminName,
      'restaurant_id': null,
      'role_id': 'super_admin_role',
      'role_name': 'super_admin',
      'roles': {'name': 'super_admin'},
      'created_at': DateTime.now().toIso8601String(),
    };

    Exception? lastError;
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        await firestore.collection('users').doc(uid).set(
              superAdminData,
              SetOptions(merge: true),
            );
        lastError = null;
        break;
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        debugPrint('⚠️ Super Admin profile write failed (attempt ${attempt + 1}/3): $e');
        await Future.delayed(const Duration(milliseconds: 400));
        await auth.currentUser?.getIdToken(true);
      }
    }
    if (lastError != null) throw lastError;

    // Sign out so the user can log in fresh from the login screen
    await auth.signOut();

    debugPrint('✅ Super Admin bootstrap ensured ($adminEmail).');
  } catch (e) {
    debugPrint('⚠️ Bootstrap skipped: $e');
  }
}

/// Root widget of the Restaurant SaaS platform.
class RestaurantSaasApp extends StatelessWidget {
  const RestaurantSaasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<DeliveryBloc>(
          create: (_) => sl<DeliveryBloc>(),
        ),
        BlocProvider<SupplierBloc>(
          create: (_) => sl<SupplierBloc>(),
        ),
        BlocProvider<CustomerBloc>(
          create: (_) => sl<CustomerBloc>(),
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          // Determine the initial route based on auth state.
          String initialRoute = Routes.login;
          if (state is Authenticated) {
            initialRoute = AppRouter.initialRouteForRole(state.role);
          }

          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: initialRoute,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
