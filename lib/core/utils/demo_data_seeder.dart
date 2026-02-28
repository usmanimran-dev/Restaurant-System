import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Seeds realistic demo data matching our Firestore models.
/// Call from Restaurant Admin dashboard (requires restaurant_id).
class DemoDataSeeder {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const Uuid _uuid = Uuid();

  static Future<void> seedRestaurantData(String restaurantId, BuildContext context) async {
    if (restaurantId.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No restaurant selected.'), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      final batch = _db.batch();

      // 1. Menu categories (matching MenuCategoryModel)
      final catBurgersId = _uuid.v4();
      final catPizzasId = _uuid.v4();
      final catDrinksId = _uuid.v4();
      final catSidesId = _uuid.v4();

      batch.set(_db.collection('menu_categories').doc(catBurgersId), {
        'id': catBurgersId,
        'restaurant_id': restaurantId,
        'name': 'Burgers',
        'sort_order': 0,
      });
      batch.set(_db.collection('menu_categories').doc(catPizzasId), {
        'id': catPizzasId,
        'restaurant_id': restaurantId,
        'name': 'Pizzas',
        'sort_order': 1,
      });
      batch.set(_db.collection('menu_categories').doc(catDrinksId), {
        'id': catDrinksId,
        'restaurant_id': restaurantId,
        'name': 'Drinks',
        'sort_order': 2,
      });
      batch.set(_db.collection('menu_categories').doc(catSidesId), {
        'id': catSidesId,
        'restaurant_id': restaurantId,
        'name': 'Sides',
        'sort_order': 3,
      });

      // 2. Menu items (matching MenuItemModel)
      final itemClassicId = _uuid.v4();
      final itemCheeseId = _uuid.v4();
      final itemMargheritaId = _uuid.v4();
      final itemCokeId = _uuid.v4();
      final itemFriesId = _uuid.v4();

      batch.set(_db.collection('menu_items').doc(itemClassicId), {
        'id': itemClassicId,
        'restaurant_id': restaurantId,
        'category_id': catBurgersId,
        'name': 'Classic Burger',
        'description': 'Juicy beef patty with lettuce, tomato & special sauce',
        'price': 450,
        'is_available': true,
        'image_url': null,
      });
      batch.set(_db.collection('menu_items').doc(itemCheeseId), {
        'id': itemCheeseId,
        'restaurant_id': restaurantId,
        'category_id': catBurgersId,
        'name': 'Cheese Burger',
        'description': 'Classic burger with melted cheddar',
        'price': 520,
        'is_available': true,
        'image_url': null,
      });
      batch.set(_db.collection('menu_items').doc(itemMargheritaId), {
        'id': itemMargheritaId,
        'restaurant_id': restaurantId,
        'category_id': catPizzasId,
        'name': 'Margherita Pizza',
        'description': 'Tomato, mozzarella, fresh basil',
        'price': 750,
        'is_available': true,
        'image_url': null,
      });
      batch.set(_db.collection('menu_items').doc(itemCokeId), {
        'id': itemCokeId,
        'restaurant_id': restaurantId,
        'category_id': catDrinksId,
        'name': 'Coca Cola',
        'description': '330ml',
        'price': 80,
        'is_available': true,
        'image_url': null,
      });
      batch.set(_db.collection('menu_items').doc(itemFriesId), {
        'id': itemFriesId,
        'restaurant_id': restaurantId,
        'category_id': catSidesId,
        'name': 'French Fries',
        'description': 'Crispy golden fries',
        'price': 150,
        'is_available': true,
        'image_url': null,
      });

      // 3. Modifier groups & items (matching ModifierGroupModel, ModifierItemModel)
      final modGroupSize = _uuid.v4();
      final modGroupToppings = _uuid.v4();

      batch.set(_db.collection('modifier_groups').doc(modGroupSize), {
        'id': modGroupSize,
        'restaurant_id': restaurantId,
        'menu_item_id': itemClassicId,
        'name': 'Size',
        'is_required': true,
        'max_selections': 1,
        'min_selections': 1,
        'sort_order': 0,
      });
      batch.set(_db.collection('modifier_groups').doc(modGroupToppings), {
        'id': modGroupToppings,
        'restaurant_id': restaurantId,
        'menu_item_id': itemClassicId,
        'name': 'Extra Toppings',
        'is_required': false,
        'max_selections': 3,
        'min_selections': 0,
        'sort_order': 1,
      });

      final modLarge = _uuid.v4();
      final modExtraCheese = _uuid.v4();
      final modBacon = _uuid.v4();

      batch.set(_db.collection('modifier_items').doc(modLarge), {
        'id': modLarge,
        'group_id': modGroupSize,
        'restaurant_id': restaurantId,
        'name': 'Large',
        'price_adjustment': 80,
        'is_default': false,
        'sort_order': 1,
      });
      batch.set(_db.collection('modifier_items').doc(modExtraCheese), {
        'id': modExtraCheese,
        'group_id': modGroupToppings,
        'restaurant_id': restaurantId,
        'name': 'Extra Cheese',
        'price_adjustment': 50,
        'is_default': false,
        'sort_order': 0,
      });
      batch.set(_db.collection('modifier_items').doc(modBacon), {
        'id': modBacon,
        'group_id': modGroupToppings,
        'restaurant_id': restaurantId,
        'name': 'Bacon',
        'price_adjustment': 80,
        'is_default': false,
        'sort_order': 1,
      });

      // 4. Tax configuration (matching TaxConfigurationModel)
      final taxId = _uuid.v4();
      batch.set(_db.collection('tax_configurations').doc(taxId), {
        'id': taxId,
        'restaurant_id': restaurantId,
        'name': 'GST',
        'rate': 17,
        'is_default': true,
        'is_active': true,
      });

      // 5. Discounts (matching DiscountModel)
      final discountId = _uuid.v4();
      batch.set(_db.collection('discounts').doc(discountId), {
        'id': discountId,
        'restaurant_id': restaurantId,
        'name': 'Happy Hour 10%',
        'type': 'percentage',
        'value': 10,
        'code': 'HAPPY10',
        'min_order_amount': 500,
        'max_discount_amount': 200,
        'is_active': true,
        'usage_limit': 100,
        'usage_count': 0,
      });

      // 6. Inventory categories & items (matching InventoryCategoryModel, InventoryItemModel)
      final invCatId = _uuid.v4();
      batch.set(_db.collection('inventory_categories').doc(invCatId), {
        'id': invCatId,
        'restaurant_id': restaurantId,
        'name': 'Dry Goods',
      });

      final invBunsId = _uuid.v4();
      final invBeefId = _uuid.v4();
      batch.set(_db.collection('inventory_items').doc(invBunsId), {
        'id': invBunsId,
        'restaurant_id': restaurantId,
        'category_id': invCatId,
        'name': 'Burger Buns',
        'unit': 'pack',
        'quantity': 50,
        'minimum_stock': 10,
      });
      batch.set(_db.collection('inventory_items').doc(invBeefId), {
        'id': invBeefId,
        'restaurant_id': restaurantId,
        'category_id': invCatId,
        'name': 'Beef Patty',
        'unit': 'kg',
        'quantity': 25,
        'minimum_stock': 5,
      });

      // 7. Suppliers (matching SupplierModel)
      final supplierId = _uuid.v4();
      batch.set(_db.collection('suppliers').doc(supplierId), {
        'id': supplierId,
        'restaurant_id': restaurantId,
        'name': 'Fresh Foods Ltd',
        'phone': '+92-300-1234567',
        'email': 'orders@freshfoods.pk',
        'address': 'Industrial Area, Karachi',
        'payment_terms': 'Net 15',
        'lead_time_days': 2,
        'quality_rating': 4.8,
        'reliability_rating': 4.5,
        'is_active': true,
      });

      // 8. Customers (matching CustomerModel)
      final customerId = _uuid.v4();
      final now = DateTime.now();
      batch.set(_db.collection('customers').doc(customerId), {
        'id': customerId,
        'restaurant_id': restaurantId,
        'name': 'Ahmed Khan',
        'phone': '+92-300-1112233',
        'email': 'ahmed@example.com',
        'address': null,
        'customer_type': 'regular',
        'total_orders': 12,
        'total_spent': 8500,
        'loyalty_points': 120,
        'loyalty_tier': 'silver',
        'created_at': now.toIso8601String(),
        'last_order_at': now.toIso8601String(),
      });

      // 9. Kitchen stations (matching StationModel)
      final stationId = _uuid.v4();
      batch.set(_db.collection('restaurants').doc(restaurantId).collection('stations').doc(stationId), {
        'id': stationId,
        'restaurant_id': restaurantId,
        'name': 'Main Grill',
        'color': '#E53935',
        'sort_order': 0,
      });

      // 10. Sample order & KDS (matching OrderModel, KdsOrderModel)
      final orderId = _uuid.v4();
      final orderItems = [
        {
          'menu_item_id': itemClassicId,
          'name': 'Classic Burger',
          'quantity': 2,
          'unit_price': 450,
          'notes': null,
          'modifiers': [
            {'group_name': 'Extra Toppings', 'name': 'Extra Cheese', 'price_adjustment': 50}
          ],
          'is_combo': false,
          'combo_id': null,
        },
        {
          'menu_item_id': itemCokeId,
          'name': 'Coca Cola',
          'quantity': 2,
          'unit_price': 80,
          'notes': null,
          'modifiers': [],
          'is_combo': false,
          'combo_id': null,
        },
      ];
      const subtotal = 1060.0; // 450*2 + 50*2 + 80*2
      const taxAmount = 180.2;
      const total = 1240.2;

      batch.set(_db.collection('orders').doc(orderId), {
        'id': orderId,
        'restaurant_id': restaurantId,
        'employee_id': 'pos_cashier',
        'type': 'dine-in',
        'payment_method': 'cash',
        'status': 'pending',
        'items': orderItems,
        'subtotal': subtotal,
        'tax_amount': taxAmount,
        'total': total,
        'discount_amount': 0,
        'discount_id': null,
        'discount_name': null,
        'fbr_invoice_number': null,
        'customer_name': 'Ahmed Khan',
        'customer_phone': '+92-300-1112233',
        'created_at': now.toIso8601String(),
      });

      final kdsItems = [
        {
          'menu_item_id': itemClassicId,
          'name': 'Classic Burger',
          'quantity': 2,
          'modifiers': ['Extra Cheese'],
          'notes': null,
          'station': null,
          'status': 'pending',
          'status_updated_at': null,
        },
        {
          'menu_item_id': itemCokeId,
          'name': 'Coca Cola',
          'quantity': 2,
          'modifiers': [],
          'notes': null,
          'station': null,
          'status': 'pending',
          'status_updated_at': null,
        },
      ];
      batch.set(_db.collection('restaurants').doc(restaurantId).collection('kds_orders').doc(orderId), {
        'restaurant_id': restaurantId,
        'order_id': orderId,
        'order_number': orderId.substring(0, 8).toUpperCase(),
        'order_type': 'dine-in',
        'items': kdsItems,
        'customer_name': 'Ahmed Khan',
        'table_number': null,
        'special_instructions': null,
        'priority': 'normal',
        'is_on_hold': false,
        'estimated_prep_minutes': 15,
        'created_at': now.toIso8601String(),
        'completed_at': null,
      });

      await batch.commit();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Demo data seeded! Check Menu, Orders, KDS, Inventory, Suppliers & Customers.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error seeding data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
