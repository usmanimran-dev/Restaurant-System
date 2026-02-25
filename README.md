# Setup Instructions for Multi-Tenant POS SaaS

This repository contains a full-stack Flutter Web application managed via Supabase.

## 1. Supabase Backend Setup
1. Create a new Supabase project.
2. Go to the Database -> SQL Editor side menu.
3. Run the scripts in the following order:
   - `supabase/supabase_schema.sql` (Creates core tables, RLS, and seeds initial super_admin user)
   - `supabase/expansion_01_tenant_rpc.sql` (Adds custom RPC for Super Admins to provision restaurants)
   - `supabase/expansion_02_schema.sql` (Creates tables and RLS for Menu, Orders, and Salary Records)
4. Go to Authentication -> Providers, ensure Email provider is enabled.
5. In your project settings, locate your Project URL and anon key.

## 2. Flutter Configuration
1. Open `lib/config/constants.dart`.
2. Replace `supabaseUrlPlaceholder` and `supabaseAnonKeyPlaceholder` with your actual Supabase credentials.
3. Keep the `AppConstants` values updated.

## 3. Running the App
1. Run `flutter pub get`
2. Run `flutter run -d chrome`

## 4. Bootstrapping
- **Super Admin**: Log in using `admin@Zyfloatix.com` / `admin123` (configured via the initial seed script).
- Create a new Restaurant/Tenant. The app will log a request to provision an admin (requires real auth pipeline completion in prod).
- Log in as a newly created Restaurant Admin to test Employee CRUD, Menu building, and the Point of Sale.
- Log in as an Employee to see localized Active Orders.
