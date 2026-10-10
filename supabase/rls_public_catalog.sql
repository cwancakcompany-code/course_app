-- ============================================================
-- EduMaster: allow the Flutter app (anon key) to READ catalog
-- Run ALL of this in: Supabase Dashboard → SQL Editor → Run
-- ============================================================

-- 1) See what you currently have (service role / SQL editor bypasses RLS)
SELECT id, title, is_published, status, is_recommended, is_popular, thumbnail_url
FROM public.courses
ORDER BY created_at DESC
LIMIT 20;

-- 2) If courses exist but are drafts, publish them:
UPDATE public.courses
SET
  is_published = true,
  status = 'published',
  published_at = COALESCE(published_at, now())
WHERE is_published IS DISTINCT FROM true
   OR status IS DISTINCT FROM 'published';

-- Optional flags for Home sections:
UPDATE public.courses
SET is_recommended = true
WHERE is_recommended IS DISTINCT FROM true;

UPDATE public.courses
SET is_popular = true
WHERE is_popular IS DISTINCT FROM true;

-- 3) RLS policies (public read)
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read published courses" ON public.courses;
DROP POLICY IF EXISTS "Public read all courses temp" ON public.courses;

-- Temporary broad read so the app can load the catalog.
-- Tighten later to only published if you want.
CREATE POLICY "Public read all courses temp"
ON public.courses
FOR SELECT
TO anon, authenticated
USING (true);

ALTER TABLE public.course_sections ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read sections of published courses" ON public.course_sections;
DROP POLICY IF EXISTS "Public read all sections temp" ON public.course_sections;
CREATE POLICY "Public read all sections temp"
ON public.course_sections
FOR SELECT
TO anon, authenticated
USING (true);

ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read lessons of published courses" ON public.lessons;
DROP POLICY IF EXISTS "Public read all lessons temp" ON public.lessons;
CREATE POLICY "Public read all lessons temp"
ON public.lessons
FOR SELECT
TO anon, authenticated
USING (true);

-- 4) Verify policies exist
SELECT schemaname, tablename, policyname, roles, cmd, qual
FROM pg_policies
WHERE tablename IN ('courses', 'course_sections', 'lessons');
