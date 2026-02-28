const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { onRequest } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const crypto = require('crypto');

admin.initializeApp();

const db = admin.firestore();

async function assertSuperAdmin(context) {
  if (!context.auth) {
    throw new HttpsError('unauthenticated', 'Authentication required.');
  }

  const userSnap = await db.collection('users').doc(context.auth.uid).get();
  if (!userSnap.exists) {
    throw new HttpsError('permission-denied', 'User profile missing.');
  }

  const roleName = userSnap.get('role_name');
  if (roleName !== 'super_admin') {
    throw new HttpsError('permission-denied', 'Super admin privileges required.');
  }
}

exports.createRestaurantAdmin = onCall(async (request) => {
  const { data, auth } = request;
  const context = { auth };

  await assertSuperAdmin(context);

  const restaurantId = (data?.restaurantId ?? '').toString();
  const email = (data?.email ?? '').toString().trim();
  const password = (data?.password ?? '').toString();
  const name = (data?.name ?? '').toString().trim();

  if (!restaurantId || !email || !password || !name) {
    throw new HttpsError('invalid-argument', 'restaurantId, email, password, and name are required.');
  }

  // Ensure restaurant exists
  const restaurantSnap = await db.collection('restaurants').doc(restaurantId).get();
  if (!restaurantSnap.exists) {
    throw new HttpsError('not-found', 'Restaurant not found.');
  }

  // Create auth user
  let userRecord;
  try {
    userRecord = await admin.auth().createUser({
      email,
      password,
      displayName: name,
    });
  } catch (e) {
    if (e?.code === 'auth/email-already-exists') {
      throw new HttpsError('already-exists', 'Email already in use.');
    }
    throw new HttpsError('internal', `Failed to create auth user: ${e?.message ?? e}`);
  }

  // Set claims (optional but useful)
  await admin.auth().setCustomUserClaims(userRecord.uid, {
    role: 'restaurant_admin',
    restaurant_id: restaurantId,
  });

  // Create Firestore user profile (flat /users)
  await db.collection('users').doc(userRecord.uid).set({
    email,
    name,
    restaurant_id: restaurantId,
    role_id: 'restaurant_admin_role',
    role_name: 'restaurant_admin',
    roles: { name: 'restaurant_admin' },
    created_at: new Date().toISOString(),
  });

  return { uid: userRecord.uid };
});

function requireWebhookSecret(req) {
  const configured = process.env.AGGREGATOR_WEBHOOK_SECRET;
  if (!configured) return;

  const provided = req.get('x-webhook-secret');
  if (!provided || provided !== configured) {
    throw new HttpsError('permission-denied', 'Invalid webhook secret.');
  }
}

function mapExternalToOrderItems(externalItems) {
  const items = Array.isArray(externalItems) ? externalItems : [];
  return items.map((it) => {
    const modifiers = Array.isArray(it.modifiers)
      ? it.modifiers.map((m) => ({
          group_name: (m.group ?? m.group_name ?? 'Modifier').toString(),
          name: (m.name ?? m.title ?? '').toString(),
          price_adjustment: Number(m.price_adjustment ?? m.price ?? 0),
        }))
      : [];

    return {
      menu_item_id: (it.menu_item_id ?? it.sku ?? it.id ?? 'external').toString(),
      name: (it.name ?? it.title ?? 'Item').toString(),
      quantity: Number(it.quantity ?? 1),
      unit_price: Number(it.unit_price ?? it.price ?? 0),
      notes: it.notes ? it.notes.toString() : null,
      modifiers,
      is_combo: Boolean(it.is_combo ?? false),
      combo_id: it.combo_id ? it.combo_id.toString() : null,
    };
  });
}

function mapOrderItemsToKdsItems(orderItems) {
  const items = Array.isArray(orderItems) ? orderItems : [];
  return items.map((it) => ({
    menu_item_id: it.menu_item_id,
    name: it.name,
    quantity: it.quantity,
    modifiers: Array.isArray(it.modifiers)
      ? it.modifiers.map((m) => m.name).filter(Boolean)
      : [],
    notes: it.notes ?? null,
    station: it.station ?? null,
    status: 'pending',
    status_updated_at: null,
  }));
}

// ── Seed Data (callable by super_admin only) ─────────────────────────────────
exports.seedRestaurantData = onCall(async (request) => {
  const { data, auth } = request;
  const context = { auth };

  await assertSuperAdmin(context);

  const restaurantId = (data?.restaurantId ?? '').toString();
  if (!restaurantId) {
    throw new HttpsError('invalid-argument', 'restaurantId is required.');
  }

  const restaurantSnap = await db.collection('restaurants').doc(restaurantId).get();
  if (!restaurantSnap.exists) {
    throw new HttpsError('not-found', 'Restaurant not found. Create it first via Super Admin.');
  }

  const now = new Date().toISOString();
  const u = () => crypto.randomUUID();

  // 1. Roles
  const roleIds = { admin: u(), cashier: u(), chef: u(), driver: u() };
  await Promise.all([
    db.collection('roles').doc(roleIds.admin).set({
      id: roleIds.admin, restaurant_id: restaurantId, name: 'restaurant_admin',
      permissions: { pos: true, reports: true, employees: true, inventory: true, settings: true },
      created_at: now,
    }),
    db.collection('roles').doc(roleIds.cashier).set({
      id: roleIds.cashier, restaurant_id: restaurantId, name: 'cashier',
      permissions: { pos: true, reports: false, employees: false, inventory: false, settings: false },
      created_at: now,
    }),
    db.collection('roles').doc(roleIds.chef).set({
      id: roleIds.chef, restaurant_id: restaurantId, name: 'chef',
      permissions: { pos: false, kds: true, inventory: false, settings: false },
      created_at: now,
    }),
    db.collection('roles').doc(roleIds.driver).set({
      id: roleIds.driver, restaurant_id: restaurantId, name: 'driver',
      permissions: { delivery: true, pos: false, kds: false },
      created_at: now,
    }),
  ]);

  // 2. Menu categories
  const catIds = { burgers: u(), pizzas: u(), drinks: u(), sides: u(), desserts: u() };
  await Promise.all([
    db.collection('menu_categories').doc(catIds.burgers).set({
      id: catIds.burgers, restaurant_id: restaurantId, name: 'Burgers', sort_order: 0,
    }),
    db.collection('menu_categories').doc(catIds.pizzas).set({
      id: catIds.pizzas, restaurant_id: restaurantId, name: 'Pizzas', sort_order: 1,
    }),
    db.collection('menu_categories').doc(catIds.drinks).set({
      id: catIds.drinks, restaurant_id: restaurantId, name: 'Drinks', sort_order: 2,
    }),
    db.collection('menu_categories').doc(catIds.sides).set({
      id: catIds.sides, restaurant_id: restaurantId, name: 'Sides', sort_order: 3,
    }),
    db.collection('menu_categories').doc(catIds.desserts).set({
      id: catIds.desserts, restaurant_id: restaurantId, name: 'Desserts', sort_order: 4,
    }),
  ]);

  // 3. Menu items
  const itemIds = {
    classic_burger: u(), cheese_burger: u(), bbq_burger: u(), veggie_burger: u(),
    margherita: u(), pepperoni: u(), bbq_chicken: u(), veggie_pizza: u(),
    coke: u(), sprite: u(), water: u(), lemonade: u(), iced_tea: u(),
    fries: u(), onion_rings: u(), coleslaw: u(), salad: u(),
    brownie: u(), ice_cream: u(), cheesecake: u(),
  };
  const menuItems = [
    { id: itemIds.classic_burger, category_id: catIds.burgers, name: 'Classic Burger', price: 450, description: 'Juicy beef patty with fresh lettuce, tomato & our special sauce' },
    { id: itemIds.cheese_burger, category_id: catIds.burgers, name: 'Cheese Burger', price: 520, description: 'Classic burger topped with melted cheddar' },
    { id: itemIds.bbq_burger, category_id: catIds.burgers, name: 'BBQ Ranch Burger', price: 580, description: 'Smoky BBQ sauce, crispy onion, ranch dressing' },
    { id: itemIds.veggie_burger, category_id: catIds.burgers, name: 'Veggie Burger', price: 480, description: 'Plant-based patty with avocado and greens' },
    { id: itemIds.margherita, category_id: catIds.pizzas, name: 'Margherita Pizza', price: 750, description: 'Classic tomato sauce, mozzarella, fresh basil' },
    { id: itemIds.pepperoni, category_id: catIds.pizzas, name: 'Pepperoni Pizza', price: 850, description: 'Loaded with pepperoni and mozzarella' },
    { id: itemIds.bbq_chicken, category_id: catIds.pizzas, name: 'BBQ Chicken Pizza', price: 920, description: 'BBQ sauce, grilled chicken, red onion' },
    { id: itemIds.veggie_pizza, category_id: catIds.pizzas, name: 'Veggie Supreme', price: 880, description: 'Bell peppers, olives, mushrooms, onions' },
    { id: itemIds.coke, category_id: catIds.drinks, name: 'Coca Cola', price: 80, description: '330ml' },
    { id: itemIds.sprite, category_id: catIds.drinks, name: 'Sprite', price: 80, description: '330ml' },
    { id: itemIds.water, category_id: catIds.drinks, name: 'Mineral Water', price: 50, description: '500ml' },
    { id: itemIds.lemonade, category_id: catIds.drinks, name: 'Fresh Lemonade', price: 120, description: 'House-made' },
    { id: itemIds.iced_tea, category_id: catIds.drinks, name: 'Iced Tea', price: 100, description: 'Peach or lemon' },
    { id: itemIds.fries, category_id: catIds.sides, name: 'French Fries', price: 150, description: 'Crispy golden fries' },
    { id: itemIds.onion_rings, category_id: catIds.sides, name: 'Onion Rings', price: 180, description: 'Beer-battered' },
    { id: itemIds.coleslaw, category_id: catIds.sides, name: 'Coleslaw', price: 90, description: 'Creamy slaw' },
    { id: itemIds.salad, category_id: catIds.sides, name: 'House Salad', price: 200, description: 'Mixed greens, feta, vinaigrette' },
    { id: itemIds.brownie, category_id: catIds.desserts, name: 'Chocolate Brownie', price: 180, description: 'Warm with vanilla ice cream' },
    { id: itemIds.ice_cream, category_id: catIds.desserts, name: 'Ice Cream Scoop', price: 120, description: 'Vanilla, chocolate, or strawberry' },
    { id: itemIds.cheesecake, category_id: catIds.desserts, name: 'New York Cheesecake', price: 250, description: 'Creamy classic slice' },
  ];
  for (const m of menuItems) {
    await db.collection('menu_items').doc(m.id).set({
      id: m.id, category_id: m.category_id, restaurant_id: restaurantId,
      name: m.name, price: m.price, description: m.description || null,
      image_url: null, is_available: true,
    });
  }

  // 4. Modifier groups & items (for Classic Burger, Cheese Burger, Margherita, Drinks)
  const modGroupSize = u(), modGroupToppings = u(), modGroupDrinkSize = u();
  await db.collection('modifier_groups').doc(modGroupSize).set({
    id: modGroupSize, restaurant_id: restaurantId, menu_item_id: itemIds.classic_burger,
    name: 'Size', is_required: true, max_selections: 1, min_selections: 1, sort_order: 0,
  });
  await db.collection('modifier_groups').doc(modGroupToppings).set({
    id: modGroupToppings, restaurant_id: restaurantId, menu_item_id: itemIds.classic_burger,
    name: 'Extra Toppings', is_required: false, max_selections: 3, min_selections: 0, sort_order: 1,
  });
  await db.collection('modifier_groups').doc(modGroupDrinkSize).set({
    id: modGroupDrinkSize, restaurant_id: restaurantId, menu_item_id: itemIds.coke,
    name: 'Size', is_required: true, max_selections: 1, min_selections: 1, sort_order: 0,
  });

  const modItems = [
    { id: u(), group_id: modGroupSize, name: 'Regular', price_adj: 0, is_default: true, restaurant_id: restaurantId },
    { id: u(), group_id: modGroupSize, name: 'Large', price_adj: 80, is_default: false, restaurant_id: restaurantId },
    { id: u(), group_id: modGroupSize, name: 'Double Patty', price_adj: 150, is_default: false, restaurant_id: restaurantId },
    { id: u(), group_id: modGroupToppings, name: 'Extra Cheese', price_adj: 50, is_default: false, restaurant_id: restaurantId },
    { id: u(), group_id: modGroupToppings, name: 'Bacon', price_adj: 80, is_default: false, restaurant_id: restaurantId },
    { id: u(), group_id: modGroupToppings, name: 'Jalapeños', price_adj: 40, is_default: false, restaurant_id: restaurantId },
    { id: u(), group_id: modGroupDrinkSize, name: '330ml', price_adj: 0, is_default: true, restaurant_id: restaurantId },
    { id: u(), group_id: modGroupDrinkSize, name: '500ml', price_adj: 30, is_default: false, restaurant_id: restaurantId },
    { id: u(), group_id: modGroupDrinkSize, name: '1L', price_adj: 60, is_default: false, restaurant_id: restaurantId },
  ];
  for (const mi of modItems) {
    await db.collection('modifier_items').doc(mi.id).set({
      id: mi.id, group_id: mi.group_id, restaurant_id: mi.restaurant_id,
      name: mi.name, price_adjustment: mi.price_adj, is_default: mi.is_default, sort_order: 0,
    });
  }

  // 5. Tax config
  const taxId = u();
  await db.collection('tax_configurations').doc(taxId).set({
    id: taxId, restaurant_id: restaurantId, name: 'GST',
    rate: 17, is_default: true, is_active: true,
    ntn: null, business_name: null, business_address: null, fbr_pos_id: null,
  });

  // 6. Discounts
  const discountIds = { happy10: u(), first50: u(), weekend20: u() };
  await Promise.all([
    db.collection('discounts').doc(discountIds.happy10).set({
      id: discountIds.happy10, restaurant_id: restaurantId, name: 'Happy Hour 10%',
      type: 'percentage', value: 10, code: 'HAPPY10',
      min_order_amount: 500, max_discount_amount: 200,
      is_active: true, usage_limit: 100, usage_count: 0,
      start_date: null, end_date: null, created_at: now,
    }),
    db.collection('discounts').doc(discountIds.first50).set({
      id: discountIds.first50, restaurant_id: restaurantId, name: 'First Order Rs 50 Off',
      type: 'fixed_amount', value: 50, code: 'FIRST50',
      min_order_amount: 300, max_discount_amount: null,
      is_active: true, usage_limit: 500, usage_count: 0,
      start_date: null, end_date: null, created_at: now,
    }),
    db.collection('discounts').doc(discountIds.weekend20).set({
      id: discountIds.weekend20, restaurant_id: restaurantId, name: 'Weekend Special 20%',
      type: 'percentage', value: 20, code: 'WEEKEND20',
      min_order_amount: 1000, max_discount_amount: 500,
      is_active: true, usage_limit: null, usage_count: 0,
      start_date: null, end_date: null, created_at: now,
    }),
  ]);

  // 7. Inventory categories & items
  const invCatIds = { dairy: u(), meats: u(), produce: u(), dry: u(), beverages: u() };
  await Promise.all([
    db.collection('inventory_categories').doc(invCatIds.dairy).set({ id: invCatIds.dairy, restaurant_id: restaurantId, name: 'Dairy' }),
    db.collection('inventory_categories').doc(invCatIds.meats).set({ id: invCatIds.meats, restaurant_id: restaurantId, name: 'Meats' }),
    db.collection('inventory_categories').doc(invCatIds.produce).set({ id: invCatIds.produce, restaurant_id: restaurantId, name: 'Produce' }),
    db.collection('inventory_categories').doc(invCatIds.dry).set({ id: invCatIds.dry, restaurant_id: restaurantId, name: 'Dry Goods' }),
    db.collection('inventory_categories').doc(invCatIds.beverages).set({ id: invCatIds.beverages, restaurant_id: restaurantId, name: 'Beverages' }),
  ]);

  const invIds = { beef: u(), cheese: u(), lettuce: u(), tomato: u(), buns: u(), coke_stock: u(), fries_raw: u() };
  const invItems = [
    { id: invIds.beef, cat: invCatIds.meats, name: 'Beef Patty', unit: 'kg', qty: 25, min: 5 },
    { id: invIds.cheese, cat: invCatIds.dairy, name: 'Cheddar Cheese', unit: 'kg', qty: 8, min: 2 },
    { id: invIds.lettuce, cat: invCatIds.produce, name: 'Lettuce', unit: 'kg', qty: 5, min: 1 },
    { id: invIds.tomato, cat: invCatIds.produce, name: 'Tomatoes', unit: 'kg', qty: 10, min: 3 },
    { id: invIds.buns, cat: invCatIds.dry, name: 'Burger Buns', unit: 'pack', qty: 50, min: 10 },
    { id: invIds.coke_stock, cat: invCatIds.beverages, name: 'Coca Cola 330ml', unit: 'case', qty: 20, min: 5 },
    { id: invIds.fries_raw, cat: invCatIds.dry, name: 'Frozen Fries', unit: 'kg', qty: 30, min: 8 },
  ];
  for (const i of invItems) {
    await db.collection('inventory_items').doc(i.id).set({
      id: i.id, restaurant_id: restaurantId, category_id: i.cat,
      name: i.name, unit: i.unit, quantity: i.qty, minimum_stock: i.min,
    });
  }

  // 8. Suppliers
  const supplierIds = { fresh: u(), beverage: u(), dry: u() };
  await Promise.all([
    db.collection('suppliers').doc(supplierIds.fresh).set({
      id: supplierIds.fresh, restaurant_id: restaurantId, name: 'Fresh Foods Ltd',
      phone: '+92-300-1234567', email: 'orders@freshfoods.pk', address: 'Industrial Area, Karachi',
      payment_terms: 'Net 15', lead_time_days: 2, quality_rating: 4.8, reliability_rating: 4.5, is_active: true,
    }),
    db.collection('suppliers').doc(supplierIds.beverage).set({
      id: supplierIds.beverage, restaurant_id: restaurantId, name: 'Beverage Distributors',
      phone: '+92-321-9876543', email: null, address: 'Gulberg, Lahore',
      payment_terms: 'Net 7', lead_time_days: 1, quality_rating: 5.0, reliability_rating: 5.0, is_active: true,
    }),
    db.collection('suppliers').doc(supplierIds.dry).set({
      id: supplierIds.dry, restaurant_id: restaurantId, name: 'Metro Cash & Carry',
      phone: '+92-42-111628638', email: 'b2b@metro.pk', address: 'Multiple locations',
      payment_terms: 'Cash/Card', lead_time_days: 0, quality_rating: 4.5, reliability_rating: 4.2, is_active: true,
    }),
  ]);

  // 9. Kitchen stations
  const stationIds = { grill: u(), pizza: u(), cold: u(), expo: u() };
  const stationsRef = db.collection('restaurants').doc(restaurantId).collection('stations');
  await Promise.all([
    stationsRef.doc(stationIds.grill).set({ id: stationIds.grill, restaurant_id: restaurantId, name: 'Grill', color: '#E53935', sort_order: 0 }),
    stationsRef.doc(stationIds.pizza).set({ id: stationIds.pizza, restaurant_id: restaurantId, name: 'Pizza', color: '#FB8C00', sort_order: 1 }),
    stationsRef.doc(stationIds.cold).set({ id: stationIds.cold, restaurant_id: restaurantId, name: 'Cold Prep', color: '#43A047', sort_order: 2 }),
    stationsRef.doc(stationIds.expo).set({ id: stationIds.expo, restaurant_id: restaurantId, name: 'Expo', color: '#1E88E5', sort_order: 3 }),
  ]);

  // 10. Sample orders (and KDS entries)
  const empPlaceholder = 'pos_cashier';
  const sampleOrders = [
    { type: 'dine-in', payment: 'card', cust: 'Ahmed K.', items: [{ mid: itemIds.classic_burger, name: 'Classic Burger', qty: 2, price: 450 }, { mid: itemIds.coke, name: 'Coca Cola', qty: 2, price: 80 }] },
    { type: 'takeaway', payment: 'cash', cust: null, items: [{ mid: itemIds.pepperoni, name: 'Pepperoni Pizza', qty: 1, price: 850 }, { mid: itemIds.fries, name: 'French Fries', qty: 1, price: 150 }] },
    { type: 'delivery', payment: 'jazzcash', cust: 'Sara M.', items: [{ mid: itemIds.margherita, name: 'Margherita Pizza', qty: 1, price: 750 }, { mid: itemIds.lemonade, name: 'Fresh Lemonade', qty: 2, price: 120 }] },
  ];
  let deliveryOrderId = null;
  for (let i = 0; i < sampleOrders.length; i++) {
    const so = sampleOrders[i];
    const orderId = u();
    if (so.type === 'delivery') deliveryOrderId = orderId;

    const items = so.items.map(it => ({
      menu_item_id: it.mid, name: it.name, quantity: it.qty, unit_price: it.price,
      notes: null, modifiers: [], is_combo: false, combo_id: null,
    }));
    const subtotal = items.reduce((s, it) => s + it.unit_price * it.quantity, 0);
    const taxAmount = Math.round(subtotal * 0.17 * 100) / 100;
    const total = subtotal + taxAmount;

    await db.collection('orders').doc(orderId).set({
      id: orderId, restaurant_id: restaurantId, employee_id: empPlaceholder,
      type: so.type, payment_method: so.payment, status: i < 2 ? 'completed' : 'pending',
      items, subtotal, tax_amount: taxAmount, total,
      discount_amount: 0, discount_id: null, discount_name: null, fbr_invoice_number: null,
      customer_name: so.cust, customer_phone: null,
      created_at: now,
    });

    const kdsItems = items.map(it => ({
      menu_item_id: it.menu_item_id, name: it.name, quantity: it.quantity,
      modifiers: [], notes: null, station: null, status: i < 2 ? 'ready' : 'pending', status_updated_at: i < 2 ? now : null,
    }));
    await db.collection('restaurants').doc(restaurantId).collection('kds_orders').doc(orderId).set({
      restaurant_id: restaurantId, order_id: orderId, order_number: orderId.substring(0, 8).toUpperCase(),
      order_type: so.type, items: kdsItems, customer_name: so.cust, table_number: null, special_instructions: null,
      priority: 'normal', is_on_hold: false, estimated_prep_minutes: 15,
      created_at: now, completed_at: i < 2 ? now : null,
    });
  }

  // 11. Sample customers
  const custIds = [u(), u(), u()];
  const customers = [
    { name: 'Ahmed Khan', phone: '+92-300-1112233', email: 'ahmed@example.com', orders: 12, spent: 8500, tier: 'silver' },
    { name: 'Sara Malik', phone: '+92-321-4445566', email: 'sara@example.com', orders: 5, spent: 3200, tier: 'bronze' },
    { name: 'Usman Ali', phone: '+92-333-7778899', email: null, orders: 25, spent: 18200, tier: 'gold' },
  ];
  for (let j = 0; j < custIds.length; j++) {
    const c = customers[j];
    await db.collection('customers').doc(custIds[j]).set({
      id: custIds[j], restaurant_id: restaurantId, name: c.name, phone: c.phone, email: c.email || null,
      address: null, customer_type: 'regular', total_orders: c.orders, total_spent: c.spent,
      loyalty_points: c.orders * 10, loyalty_tier: c.tier,
      created_at: now, last_order_at: now,
    });
  }

  // 12. Sample delivery (for the pending delivery order)
  if (deliveryOrderId) {
    const delId = u();
    await db.collection('deliveries').doc(delId).set({
      id: delId, order_id: deliveryOrderId, restaurant_id: restaurantId,
      driver_id: null, driver_name: null, customer_name: 'Sara M.', customer_phone: '+92-321-4445566',
      delivery_address: 'House 42, Block D, DHA Phase 5, Lahore', delivery_fee: 150,
      status: 'ready', estimated_minutes: 35, actual_minutes: null, zone_id: null,
      created_at: now, delivered_at: null,
    });
  }

  return { ok: true, message: 'Seed data added successfully.', restaurantId };
});

exports.aggregatorWebhook = onRequest(async (req, res) => {
  try {
    if (req.method !== 'POST') {
      res.status(405).send('Method Not Allowed');
      return;
    }

    requireWebhookSecret(req);

    const payload = req.body ?? {};
    const source = (payload.source ?? req.get('x-aggregator-source') ?? 'aggregator').toString().toLowerCase();
    const restaurantId = (payload.restaurantId ?? payload.restaurant_id ?? '').toString();
    if (!restaurantId) {
      throw new HttpsError('invalid-argument', 'restaurantId is required in payload.');
    }

    const restaurantSnap = await db.collection('restaurants').doc(restaurantId).get();
    if (!restaurantSnap.exists) {
      throw new HttpsError('not-found', 'Restaurant not found.');
    }

    const orderId = crypto.randomUUID();
    const nowIso = new Date().toISOString();
    const orderType = (payload.orderType ?? payload.order_type ?? 'delivery').toString();
    const orderNumber = (payload.orderNumber ?? payload.order_number ?? orderId.substring(0, 8).toUpperCase()).toString();

    const orderItems = mapExternalToOrderItems(payload.items);
    const subtotal = orderItems.reduce((sum, it) => sum + Number(it.unit_price) * Number(it.quantity), 0);
    const taxAmount = Number(payload.tax_amount ?? payload.taxAmount ?? 0);
    const discountAmount = Number(payload.discount_amount ?? payload.discountAmount ?? 0);
    const total = Math.max(0, subtotal - discountAmount + taxAmount);

    const orderDoc = {
      id: orderId,
      restaurant_id: restaurantId,
      employee_id: 'aggregator_webhook',
      type: orderType,
      payment_method: (payload.payment_method ?? payload.paymentMethod ?? 'cash').toString(),
      status: (payload.status ?? 'pending').toString(),
      items: orderItems,
      subtotal,
      tax_amount: taxAmount,
      total,
      discount_amount: discountAmount,
      discount_id: payload.discount_id ?? null,
      discount_name: payload.discount_name ?? null,
      fbr_invoice_number: payload.fbr_invoice_number ?? null,
      customer_name: payload.customer_name ?? payload.customerName ?? null,
      customer_phone: payload.customer_phone ?? payload.customerPhone ?? null,
      created_at: nowIso,
      source,
      external_payload: payload.external_payload ?? null,
    };

    const kdsDoc = {
      restaurant_id: restaurantId,
      order_number: orderNumber,
      order_type: orderType,
      items: mapOrderItemsToKdsItems(orderItems),
      customer_name: orderDoc.customer_name,
      table_number: payload.table_number ?? payload.tableNumber ?? null,
      special_instructions: payload.special_instructions ?? payload.specialInstructions ?? null,
      priority: (payload.priority ?? 'normal').toString(),
      is_on_hold: Boolean(payload.is_on_hold ?? payload.isOnHold ?? false),
      estimated_prep_minutes: Number(payload.estimated_prep_minutes ?? payload.estimatedPrepMinutes ?? 15),
      created_at: nowIso,
      completed_at: null,
    };

    // Write order + KDS entry
    await Promise.all([
      db.collection('orders').doc(orderId).set(orderDoc),
      db.collection('restaurants').doc(restaurantId).collection('kds_orders').doc(orderId).set(kdsDoc),
    ]);

    res.status(200).json({ ok: true, orderId });
  } catch (e) {
    const status = e instanceof HttpsError ? 400 : 500;
    res.status(status).json({ ok: false, error: e?.message ?? String(e) });
  }
});
