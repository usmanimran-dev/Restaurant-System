-- ============================================================================
-- Expansion 2: Table Definitions for Modules 3 & 4 (Operations & Finance)
-- ============================================================================

-- 1. Menu Categories
CREATE TABLE public.menu_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Multi-tenant isolation constraint (optional but good practice)
  CONSTRAINT uq_menu_category_name_per_restaurant UNIQUE (restaurant_id, name)
);

ALTER TABLE public.menu_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view categories of their restaurant"
  ON public.menu_categories FOR SELECT
  USING (restaurant_id IN (
    SELECT restaurant_id FROM public.users WHERE id = auth.uid()
  ));

CREATE POLICY "Users can insert categories to their restaurant"
  ON public.menu_categories FOR INSERT
  WITH CHECK (restaurant_id IN (
    SELECT restaurant_id FROM public.users WHERE id = auth.uid()
  ));

CREATE POLICY "Users can update categories of their restaurant"
  ON public.menu_categories FOR UPDATE
  USING (restaurant_id IN (
    SELECT restaurant_id FROM public.users WHERE id = auth.uid()
  ));

  
-- 2. Menu Items
CREATE TABLE public.menu_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES public.menu_categories(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  price NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
  image_url TEXT,
  is_available BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view items of their restaurant"
  ON public.menu_items FOR SELECT
  USING (restaurant_id IN (
    SELECT restaurant_id FROM public.users WHERE id = auth.uid()
  ));

CREATE POLICY "Users can insert items to their restaurant"
  ON public.menu_items FOR INSERT
  WITH CHECK (restaurant_id IN (
    SELECT restaurant_id FROM public.users WHERE id = auth.uid()
  ));

CREATE POLICY "Users can update items of their restaurant"
  ON public.menu_items FOR UPDATE
  USING (restaurant_id IN (
    SELECT restaurant_id FROM public.users WHERE id = auth.uid()
  ));


-- 3. Orders (POS)
CREATE TABLE public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  employee_id UUID NOT NULL REFERENCES public.users(id),
  type TEXT NOT NULL, -- 'dine-in', 'takeaway', 'delivery'
  payment_method TEXT NOT NULL, -- 'cash', 'card'
  status TEXT NOT NULL DEFAULT 'completed', -- 'pending', 'completed', 'cancelled'
  items JSONB NOT NULL, -- Stores array of order items {menuItemId, name, quantity, unitPrice}
  subtotal NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
  tax_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
  total NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
  fbr_invoice_number TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view orders of their restaurant"
  ON public.orders FOR SELECT
  USING (restaurant_id IN (
    SELECT restaurant_id FROM public.users WHERE id = auth.uid()
  ));

CREATE POLICY "Users can create orders in their restaurant"
  ON public.orders FOR INSERT
  WITH CHECK (restaurant_id IN (
    SELECT restaurant_id FROM public.users WHERE id = auth.uid()
  ));

CREATE POLICY "Users can update orders of their restaurant"
  ON public.orders FOR UPDATE
  USING (restaurant_id IN (
    SELECT restaurant_id FROM public.users WHERE id = auth.uid()
  ));


-- 4. Salary & Payroll (Finance)
CREATE TABLE public.salary_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  employee_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  month TEXT NOT NULL, -- YYYY-MM
  base_salary NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
  bonus NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
  loan_deduction NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
  tax_deduction NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
  reason TEXT,
  net_salary NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
  status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'paid'
  payment_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Prevent duplicate salary generation for same employee/month
  CONSTRAINT uq_salary_employee_month UNIQUE (employee_id, month)
);

ALTER TABLE public.salary_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view salary records of their restaurant"
  ON public.salary_records FOR SELECT
  USING (restaurant_id IN (
    SELECT restaurant_id FROM public.users WHERE id = auth.uid()
  ));

CREATE POLICY "Users can create salary records in their restaurant"
  ON public.salary_records FOR INSERT
  WITH CHECK (restaurant_id IN (
    SELECT restaurant_id FROM public.users WHERE id = auth.uid()
  ));

CREATE POLICY "Users can update salary records of their restaurant"
  ON public.salary_records FOR UPDATE
  USING (restaurant_id IN (
    SELECT restaurant_id FROM public.users WHERE id = auth.uid()
  ));
