-- ============================================================
-- Reviews RLS: everyone can READ; only logged-in users can WRITE
-- Run in Supabase SQL Editor
-- ============================================================

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Public read (guests + signed-in)
DROP POLICY IF EXISTS "Public read reviews" ON public.reviews;
CREATE POLICY "Public read reviews"
ON public.reviews
FOR SELECT
TO anon, authenticated
USING (true);

-- Insert own review only (must be logged in)
DROP POLICY IF EXISTS "Users insert own reviews" ON public.reviews;
CREATE POLICY "Users insert own reviews"
ON public.reviews
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Update own review only
DROP POLICY IF EXISTS "Users update own reviews" ON public.reviews;
CREATE POLICY "Users update own reviews"
ON public.reviews
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Delete own review only
DROP POLICY IF EXISTS "Users delete own reviews" ON public.reviews;
CREATE POLICY "Users delete own reviews"
ON public.reviews
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Guests (anon) have NO insert/update/delete policies → write denied.
