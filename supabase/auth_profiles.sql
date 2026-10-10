-- ============================================================
-- EduMaster Auth: add missing profile columns + signup trigger
-- Run in: Supabase Dashboard → SQL Editor → Run (all of it)
-- Also: Authentication → Providers → Email → Confirm email = OFF
-- ============================================================

-- 1) Enum
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE public.user_role AS ENUM ('student', 'admin');
  END IF;
END$$;

-- 2) Add columns that may be missing on the live profiles table
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS user_name text,
  ADD COLUMN IF NOT EXISTS first_name text,
  ADD COLUMN IF NOT EXISTS last_name text,
  ADD COLUMN IF NOT EXISTS phone_country_code text,
  ADD COLUMN IF NOT EXISTS phone_number text,
  ADD COLUMN IF NOT EXISTS avatar_url text,
  ADD COLUMN IF NOT EXISTS country_iso char(2),
  ADD COLUMN IF NOT EXISTS timezone text DEFAULT 'UTC',
  ADD COLUMN IF NOT EXISTS preferred_currency char(3) DEFAULT 'IQD',
  ADD COLUMN IF NOT EXISTS is_active boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

-- role (enum) — ADD COLUMN IF NOT EXISTS works for enum types in PG
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS role public.user_role NOT NULL DEFAULT 'student';

-- Backfill any nulls (older rows)
UPDATE public.profiles
SET role = 'student'
WHERE role IS NULL;

ALTER TABLE public.profiles
  ALTER COLUMN role SET DEFAULT 'student',
  ALTER COLUMN role SET NOT NULL;

-- Soft unique on user_name if not already unique and values exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'profiles_user_name_key'
      AND conrelid = 'public.profiles'::regclass
  ) THEN
    -- Only add unique if no duplicates
    IF NOT EXISTS (
      SELECT user_name FROM public.profiles
      WHERE user_name IS NOT NULL
      GROUP BY user_name HAVING COUNT(*) > 1
    ) THEN
      ALTER TABLE public.profiles
        ADD CONSTRAINT profiles_user_name_key UNIQUE (user_name);
    END IF;
  END IF;
END$$;

-- 3) Auto-create profile on signup (default role = student)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_name text;
BEGIN
  v_user_name := COALESCE(
    NULLIF(trim(NEW.raw_user_meta_data->>'user_name'), ''),
    NULLIF(split_part(COALESCE(NEW.email, ''), '@', 1), ''),
    'student_' || substr(NEW.id::text, 1, 8)
  );

  INSERT INTO public.profiles (
    id,
    user_name,
    first_name,
    last_name,
    phone_country_code,
    phone_number,
    role,
    preferred_currency,
    is_active
  )
  VALUES (
    NEW.id,
    v_user_name,
    COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
    NEW.raw_user_meta_data->>'phone_country_code',
    NEW.raw_user_meta_data->>'phone_number',
    'student',
    'IQD',
    true
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- 4) RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users read own profile" ON public.profiles;
CREATE POLICY "Users read own profile"
ON public.profiles
FOR SELECT
TO authenticated
USING (auth.uid() = id AND deleted_at IS NULL);

DROP POLICY IF EXISTS "Users update own profile" ON public.profiles;
CREATE POLICY "Users update own profile"
ON public.profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id AND deleted_at IS NULL)
WITH CHECK (
  auth.uid() = id
  -- Block role escalation from the client
  AND role = (SELECT p.role FROM public.profiles p WHERE p.id = auth.uid())
);

DROP POLICY IF EXISTS "Users insert own profile" ON public.profiles;
CREATE POLICY "Users insert own profile"
ON public.profiles
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id AND role = 'student');

-- 5) Quick verify
SELECT column_name, data_type, udt_name, column_default
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'profiles'
ORDER BY ordinal_position;
