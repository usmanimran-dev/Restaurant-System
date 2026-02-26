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
    final menuCategories = {
      'cat-1': 'Main Course',
      'cat-2': 'Appetizers',
      'cat-3': 'Desserts',
      'cat-4': 'Beverages',
      'cat-5': 'Specials',
    };
    for (var entry in menuCategories.entries) {
      await firestore.collection('menu_categories').doc(entry.key).set({
        'restaurant_id': demoRid,
        'name': entry.value,
      }, SetOptions(merge: true));
    }

    // 4. Seed Menu Items
    final menuItems = [
      {'id': 'item-1', 'cat': 'cat-1', 'name': 'Wagyu Steak', 'price': 45.0, 'desc': 'Premium wagyu beef served with truffle mash'},
      {'id': 'item-2', 'cat': 'cat-1', 'name': 'Atlantic Salmon', 'price': 32.0, 'desc': 'Fresh salmon with lemon butter sauce'},
      {'id': 'item-3', 'cat': 'cat-2', 'name': 'Truffle Fries', 'price': 12.0, 'desc': 'Crispy fries tossed in truffle oil and parmesan'},
      {'id': 'item-4', 'cat': 'cat-2', 'name': 'Calamari Rings', 'price': 14.0, 'desc': 'Lightly breaded squid rings with aioli'},
      {'id': 'item-5', 'cat': 'cat-3', 'name': 'Tiramisu', 'price': 9.0, 'desc': 'Classic Italian dessert with mascarpone and espresso'},
      {'id': 'item-6', 'cat': 'cat-3', 'name': 'Lava Cake', 'price': 11.0, 'desc': 'Warm chocolate cake with a gooey center'},
      {'id': 'item-7', 'cat': 'cat-4', 'name': 'Craft Cola', 'price': 5.0, 'desc': 'Artisan sparkling cola'},
      {'id': 'item-8', 'cat': 'cat-4', 'name': 'Matcha Latte', 'price': 6.0, 'desc': 'Premium matcha green tea with steamed milk'},
      {'id': 'item-9', 'cat': 'cat-5', 'name': 'Chef\'s Tasting Menu', 'price': 120.0, 'desc': 'A 7-course curated dining experience'},
      {'id': 'item-10', 'cat': 'cat-1', 'name': 'Truffle Risotto', 'price': 28.0, 'desc': 'Creamy risotto with wild mushrooms and truffle shavings'},
      {'id': 'item-11', 'cat': 'cat-2', 'name': 'Caprese Salad', 'price': 13.0, 'desc': 'Fresh mozzarella, tomatoes, and basil with balsamic glaze'},
      {'id': 'item-12', 'cat': 'cat-3', 'name': 'Panna Cotta', 'price': 8.0, 'desc': 'Vanilla bean panna cotta with berry compote'},
      {'id': 'item-13', 'cat': 'cat-4', 'name': 'Fresh Lemonade', 'price': 4.5, 'desc': 'House-made lemonade with mint'},
      {'id': 'item-14', 'cat': 'cat-1', 'name': 'Lobster Ravioli', 'price': 34.0, 'desc': 'Hand-made ravioli stuffed with butter-poached lobster'},
      {'id': 'item-15', 'cat': 'cat-5', 'name': 'Tomahawk Ribeye', 'price': 85.0, 'desc': '32oz bone-in ribeye, perfect for sharing'},
    ];

    for (var item in menuItems) {
      await firestore.collection('menu_items').doc(item['id'] as String).set({
        'restaurant_id': demoRid,
        'category_id': item['cat'],
        'name': item['name'],
        'price': item['price'],
        'description': item['desc'],
        'is_available': true,
      }, SetOptions(merge: true));
    }

    // 5. Seed Inventory Categories
    final invCategories = {
      'inv-cat-1': 'Meat & Seafood',
      'inv-cat-2': 'Produce',
      'inv-cat-3': 'Dairy',
      'inv-cat-4': 'Dry Goods',
      'inv-cat-5': 'Beverages',
    };
    for (var entry in invCategories.entries) {
      await firestore.collection('inventory_categories').doc(entry.key).set({
        'restaurant_id': demoRid,
        'name': entry.value,
      }, SetOptions(merge: true));
    }

    // 6. Seed Inventory Items
    final invItems = [
      {'id': 'inv-item-1', 'cat': 'inv-cat-1', 'name': 'Premium Wagyu Beef', 'unit': 'kg', 'qty': 25.0, 'min': 5.0},
      {'id': 'inv-item-2', 'cat': 'inv-cat-1', 'name': 'Atlantic Salmon Fillets', 'unit': 'kg', 'qty': 15.0, 'min': 4.0},
      {'id': 'inv-item-3', 'cat': 'inv-cat-2', 'name': 'Truffle Mushrooms', 'unit': 'kg', 'qty': 2.0, 'min': 0.5},
      {'id': 'inv-item-4', 'cat': 'inv-cat-2', 'name': 'Fresh Lemons', 'unit': 'kg', 'qty': 10.0, 'min': 3.0},
      {'id': 'inv-item-5', 'cat': 'inv-cat-3', 'name': 'Mascarpone Cheese', 'unit': 'kg', 'qty': 8.0, 'min': 2.0},
      {'id': 'inv-item-6', 'cat': 'inv-cat-3', 'name': 'Whole Milk', 'unit': 'L', 'qty': 40.0, 'min': 10.0},
      {'id': 'inv-item-7', 'cat': 'inv-cat-4', 'name': 'Espresso Beans', 'unit': 'kg', 'qty': 12.0, 'min': 3.0},
      {'id': 'inv-item-8', 'cat': 'inv-cat-4', 'name': 'Arborio Rice', 'unit': 'kg', 'qty': 20.0, 'min': 5.0},
      {'id': 'inv-item-9', 'cat': 'inv-cat-5', 'name': 'Sparkling Water', 'unit': 'bottles', 'qty': 100.0, 'min': 24.0},
      {'id': 'inv-item-10', 'cat': 'inv-cat-1', 'name': 'Lobster Tails', 'unit': 'kg', 'qty': 5.0, 'min': 2.0},
      {'id': 'inv-item-11', 'cat': 'inv-cat-3', 'name': 'Butter', 'unit': 'kg', 'qty': 15.0, 'min': 4.0},
      {'id': 'inv-item-12', 'cat': 'inv-cat-2', 'name': 'Potatoes', 'unit': 'kg', 'qty': 50.0, 'min': 15.0},
      {'id': 'inv-item-13', 'cat': 'inv-cat-5', 'name': 'Matcha Powder', 'unit': 'kg', 'qty': 1.5, 'min': 0.5},
      {'id': 'inv-item-14', 'cat': 'inv-cat-4', 'name': 'Flour', 'unit': 'kg', 'qty': 30.0, 'min': 10.0},
      {'id': 'inv-item-15', 'cat': 'inv-cat-2', 'name': 'Tomatoes', 'unit': 'kg', 'qty': 20.0, 'min': 5.0},
    ];

    for (var item in invItems) {
      await firestore.collection('inventory_items').doc(item['id'] as String).set({
        'restaurant_id': demoRid,
        'category_id': item['cat'],
        'name': item['name'],
        'unit': item['unit'],
        'quantity': item['qty'],
        'minimum_stock': item['min'],
      }, SetOptions(merge: true));
    }

    // 7. Seed Roles
    final roles = [
      {
        'id': 'role-chef', 'name': 'Head Chef',
        'permissions': {
          'menu.view': true, 'menu.create': true, 'menu.edit': true, 'menu.delete': false,
          'orders.view': true, 'orders.create': true, 'orders.edit': true, 'orders.delete': false,
          'inventory.view': true, 'inventory.create': true, 'inventory.edit': true, 'inventory.delete': false,
          'employees.view': false, 'employees.create': false, 'employees.edit': false, 'employees.delete': false,
          'roles.view': false, 'roles.create': false, 'roles.edit': false, 'roles.delete': false,
          'salary.view': false, 'salary.create': false, 'salary.edit': false, 'salary.delete': false,
          'reports.view': true, 'reports.create': false, 'reports.edit': false, 'reports.delete': false,
        },
      },
      {
        'id': 'role-manager', 'name': 'Floor Manager',
        'permissions': {
          'menu.view': true, 'menu.create': true, 'menu.edit': true, 'menu.delete': true,
          'orders.view': true, 'orders.create': true, 'orders.edit': true, 'orders.delete': true,
          'inventory.view': true, 'inventory.create': true, 'inventory.edit': true, 'inventory.delete': false,
          'employees.view': true, 'employees.create': true, 'employees.edit': true, 'employees.delete': false,
          'roles.view': true, 'roles.create': false, 'roles.edit': false, 'roles.delete': false,
          'salary.view': true, 'salary.create': false, 'salary.edit': false, 'salary.delete': false,
          'reports.view': true, 'reports.create': true, 'reports.edit': false, 'reports.delete': false,
        },
      },
      {
        'id': 'role-waiter', 'name': 'Waiter',
        'permissions': {
          'menu.view': true, 'menu.create': false, 'menu.edit': false, 'menu.delete': false,
          'orders.view': true, 'orders.create': true, 'orders.edit': true, 'orders.delete': false,
          'inventory.view': false, 'inventory.create': false, 'inventory.edit': false, 'inventory.delete': false,
          'employees.view': false, 'employees.create': false, 'employees.edit': false, 'employees.delete': false,
          'roles.view': false, 'roles.create': false, 'roles.edit': false, 'roles.delete': false,
          'salary.view': false, 'salary.create': false, 'salary.edit': false, 'salary.delete': false,
          'reports.view': false, 'reports.create': false, 'reports.edit': false, 'reports.delete': false,
        },
      },
    ];

    for (var role in roles) {
      await firestore.collection('roles').doc(role['id'] as String).set({
        'restaurant_id': demoRid,
        'name': role['name'],
        'permissions': role['permissions'],
        'created_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    }

    // 8. Seed Employees
    final employees = [
      {'id': 'emp-1', 'name': 'John Doe', 'email': 'john@zyfloatix.com', 'phone': '+1 555 100 001', 'role_id': 'role-chef', 'role_name': 'Head Chef', 'salary': 5500.0, 'join': '2023-01-15'},
      {'id': 'emp-2', 'name': 'Alice Smith', 'email': 'alice@zyfloatix.com', 'phone': '+1 555 100 002', 'role_id': 'role-chef', 'role_name': 'Sous Chef', 'salary': 4000.0, 'join': '2023-03-10'},
      {'id': 'emp-3', 'name': 'Robert Johnson', 'email': 'robert@zyfloatix.com', 'phone': '+1 555 100 003', 'role_id': 'role-waiter', 'role_name': 'Waiter', 'salary': 2500.0, 'join': '2023-06-01'},
      {'id': 'emp-4', 'name': 'Emily Davis', 'email': 'emily@zyfloatix.com', 'phone': '+1 555 100 004', 'role_id': 'role-waiter', 'role_name': 'Waitress', 'salary': 2500.0, 'join': '2023-08-20'},
      {'id': 'emp-5', 'name': 'Michael Brown', 'email': 'michael@zyfloatix.com', 'phone': '+1 555 100 005', 'role_id': 'role-manager', 'role_name': 'Bartender', 'salary': 3000.0, 'join': '2023-11-05'},
      {'id': 'emp-6', 'name': 'Sarah Wilson', 'email': 'sarah@zyfloatix.com', 'phone': '+1 555 100 006', 'role_id': 'role-manager', 'role_name': 'Manager', 'salary': 4500.0, 'join': '2022-12-01'},
    ];

    for (var emp in employees) {
      await firestore.collection('employees').doc(emp['id'] as String).set({
        'restaurant_id': demoRid,
        'name': emp['name'],
        'email': emp['email'],
        'phone': emp['phone'],
        'role_id': emp['role_id'],
        'role_name': emp['role_name'],
        'base_salary': emp['salary'],
        'joining_date': emp['join'],
        'created_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    }

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
