-- ============================================================
-- Avatars bucket: public read, owner write only under {auth.uid()}/
-- Run in Supabase SQL Editor
-- ============================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars',
  true,
  524288, -- 512 KB hard limit at storage layer
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Public read
DROP POLICY IF EXISTS "Avatar public read" ON storage.objects;
CREATE POLICY "Avatar public read"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- Authenticated users may upload/replace only in their own folder
DROP POLICY IF EXISTS "Avatar owner upload" ON storage.objects;
CREATE POLICY "Avatar owner upload"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

DROP POLICY IF EXISTS "Avatar owner update" ON storage.objects;
CREATE POLICY "Avatar owner update"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

DROP POLICY IF EXISTS "Avatar owner delete" ON storage.objects;
CREATE POLICY "Avatar owner delete"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Harden profiles UPDATE (block role change from client)
DROP POLICY IF EXISTS "Users update own profile" ON public.profiles;
CREATE POLICY "Users update own profile"
ON public.profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id AND deleted_at IS NULL)
WITH CHECK (
  auth.uid() = id
  AND role = (SELECT p.role FROM public.profiles p WHERE p.id = auth.uid())
);
