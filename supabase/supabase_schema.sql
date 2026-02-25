-- ============================================================================
-- Multi-Tenant Restaurant Management SaaS — Supabase Schema
-- ============================================================================
-- Run this migration inside your Supabase SQL editor (or via `supabase db push`).
-- It creates the four core tables plus Row Level Security (RLS) policies that
-- enforce per‑tenant isolation.
-- ============================================================================

-- Enable UUID generation if not already enabled.
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ──────────────────────────────────────────────────────────────────────────────
-- 1. RESTAURANTS (tenants)
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.restaurants (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name         TEXT        NOT NULL,
  address      TEXT,
  contact      TEXT,
  enabled_modules JSONB   NOT NULL DEFAULT '{}'::jsonb,
  settings     JSONB       NOT NULL DEFAULT '{}'::jsonb,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.restaurants ENABLE ROW LEVEL SECURITY;

-- Super admins can see all restaurants.
CREATE POLICY "Super admins can manage restaurants"
  ON public.restaurants
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users u
      JOIN public.roles r ON r.id = u.role_id
      WHERE u.id = auth.uid() AND r.name = 'super_admin'
    )
  );

-- Restaurant members can read their own restaurant.
CREATE POLICY "Members can view own restaurant"
  ON public.restaurants
  FOR SELECT
  USING (
    id IN (
      SELECT restaurant_id FROM public.users WHERE id = auth.uid()
    )
  );

-- ──────────────────────────────────────────────────────────────────────────────
-- 2. ROLES
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.roles (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          TEXT        NOT NULL,
  restaurant_id UUID        REFERENCES public.restaurants(id) ON DELETE CASCADE,
  permissions   JSONB       NOT NULL DEFAULT '{}'::jsonb,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;

-- Super admins can manage all roles.
CREATE POLICY "Super admins can manage roles"
  ON public.roles
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users u
      JOIN public.roles r ON r.id = u.role_id
      WHERE u.id = auth.uid() AND r.name = 'super_admin'
    )
  );

-- Tenant members can view roles within their restaurant.
CREATE POLICY "Tenant members can view roles"
  ON public.roles
  FOR SELECT
  USING (
    restaurant_id IN (
      SELECT restaurant_id FROM public.users WHERE id = auth.uid()
    )
  );

-- ──────────────────────────────────────────────────────────────────────────────
-- 3. USERS (profiles, linked to Supabase Auth)
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.users (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email         TEXT        NOT NULL,
  name          TEXT        NOT NULL,
  restaurant_id UUID        REFERENCES public.restaurants(id) ON DELETE SET NULL,
  role_id       UUID        REFERENCES public.roles(id) ON DELETE SET NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Users can read their own profile.
CREATE POLICY "Users can read own profile"
  ON public.users
  FOR SELECT
  USING (id = auth.uid());

-- Super admins can manage all users.
CREATE POLICY "Super admins can manage users"
  ON public.users
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users u
      JOIN public.roles r ON r.id = u.role_id
      WHERE u.id = auth.uid() AND r.name = 'super_admin'
    )
  );

-- Restaurant admins can view users within their restaurant.
CREATE POLICY "Restaurant admins can view tenant users"
  ON public.users
  FOR SELECT
  USING (
    restaurant_id IN (
      SELECT restaurant_id FROM public.users WHERE id = auth.uid()
    )
  );

-- ──────────────────────────────────────────────────────────────────────────────
-- 4. FEATURE FLAGS
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.feature_flags (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name            TEXT        NOT NULL,
  description     TEXT,
  default_enabled BOOLEAN     NOT NULL DEFAULT false,
  restaurant_id   UUID        REFERENCES public.restaurants(id) ON DELETE CASCADE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.feature_flags ENABLE ROW LEVEL SECURITY;

-- Super admins can manage all feature flags.
CREATE POLICY "Super admins can manage feature flags"
  ON public.feature_flags
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users u
      JOIN public.roles r ON r.id = u.role_id
      WHERE u.id = auth.uid() AND r.name = 'super_admin'
    )
  );

-- Tenant members can view their own feature flags.
CREATE POLICY "Tenant members can view feature flags"
  ON public.feature_flags
  FOR SELECT
  USING (
    restaurant_id IN (
      SELECT restaurant_id FROM public.users WHERE id = auth.uid()
    )
    OR restaurant_id IS NULL  -- Global flags visible to everyone
  );

-- ──────────────────────────────────────────────────────────────────────────────
-- 5. SEED DATA — Super Admin role & placeholder restaurant
-- ──────────────────────────────────────────────────────────────────────────────
-- NOTE: After running this migration, create a Supabase Auth user via the
-- dashboard or `supabase auth create-user`, then insert the matching row into
-- `public.users` with the super_admin role_id.
-- ──────────────────────────────────────────────────────────────────────────────

INSERT INTO public.roles (id, name, permissions)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'super_admin',
  '{"all": true}'::jsonb
)
ON CONFLICT (id) DO NOTHING;

-- Convenience: a "restaurant_admin" and "employee" role template
INSERT INTO public.roles (id, name, permissions)
VALUES
  (
    '00000000-0000-0000-0000-000000000002',
    'restaurant_admin',
    '{"menu": true, "staff": true, "orders": true, "analytics": true, "settings": true}'::jsonb
  ),
  (
    '00000000-0000-0000-0000-000000000003',
    'employee',
    '{"orders": true}'::jsonb
  )
ON CONFLICT (id) DO NOTHING;
