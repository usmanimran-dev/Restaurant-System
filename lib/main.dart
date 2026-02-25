import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:restaurant/config/constants.dart';
import 'package:restaurant/config/router.dart';
import 'package:restaurant/config/theme.dart';
import 'package:restaurant/core/di/injection_container.dart';
import 'package:restaurant/domain/blocs/auth/auth_bloc.dart';
import 'package:restaurant/domain/blocs/auth/auth_event.dart';
import 'package:restaurant/domain/blocs/auth/auth_state.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase ──────────────────────────────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── Dependency Injection ──────────────────────────────────────────────────
  setupDependencies();

  // ── Database Seeding ──────────────────────────────────────────────────
  try {
    final firestore = FirebaseFirestore.instance;
    final String demoUid = 'Zvt5eVRmM2MPeFR8Sj9WnghLjdW2'; // Your master UID
    final String demoRid = 'demo-restaurant-123';

    // 1. Ensure Restaurant exists
    await firestore.collection('restaurants').doc(demoRid).set({
      'name': 'Zyfloatix Luxury Dining',
      'address': '123 Elite Street, Tech City',
      'contact': '+1 234 567 890',
      'enabled_modules': {
        'pos': true,
        'inventory': true,
        'salary': true,
        'reports': true,
      },
      'settings': {'currency': 'USD', 'tax_rate': 0.16},
      'created_at': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

    // 2. Ensure User (Super Admin) exists
    await firestore.collection('users').doc(demoUid).set({
      'email': 'admin@zyfloatix.com',
      'name': 'Master Admin',
      'restaurant_id': null, 
      'role_id': 'super_admin_role',
      'role_name': 'super_admin',
      'roles': {'name': 'super_admin'}, 
      'created_at': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

    // 3. Seed Menu Categories
    await firestore.collection('menu_categories').doc('cat-1').set({
      'restaurant_id': demoRid,
      'name': 'Main Course',
    }, SetOptions(merge: true));

    // 4. Seed Menu Items
    await firestore.collection('menu_items').doc('item-1').set({
      'restaurant_id': demoRid,
      'category_id': 'cat-1',
      'name': 'Wagyu Steak',
      'price': 45.0,
      'description': 'Premium wagyu beef served with truffle mash',
      'is_available': true,
    }, SetOptions(merge: true));
    await firestore.collection('menu_items').doc('item-2').set({
      'restaurant_id': demoRid,
      'category_id': 'cat-1',
      'name': 'Atlantic Salmon',
      'price': 32.0,
      'description': 'Fresh salmon with lemon butter sauce',
      'is_available': true,
    }, SetOptions(merge: true));

    // 5. Seed Inventory Categories
    await firestore.collection('inventory_categories').doc('inv-cat-1').set({
      'restaurant_id': demoRid,
      'name': 'Kitchen Supplies',
    }, SetOptions(merge: true));

    // 6. Seed Inventory Items
    await firestore.collection('inventory_items').doc('inv-item-1').set({
      'restaurant_id': demoRid,
      'category_id': 'inv-cat-1',
      'name': 'Premium Beef',
      'unit': 'kg',
      'quantity': 25.0,
      'minimum_stock': 5.0,
    }, SetOptions(merge: true));

    // 7. Seed Employees
    await firestore.collection('employees').doc('emp-1').set({
      'restaurant_id': demoRid,
      'name': 'John Doe',
      'role': 'Chef',
      'base_salary': 3500.0,
      'joining_date': '2024-01-15',
    }, SetOptions(merge: true));

  } catch (e) {
    debugPrint('Seeding failed: $e');
  }

  runApp(const RestaurantSaasApp());
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
            theme: AppTheme.darkTheme,
            initialRoute: initialRoute,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
