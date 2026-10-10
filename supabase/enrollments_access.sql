-- ============================================================
-- EduMaster: enrollments + lesson access + instructor counts
-- Run in Supabase SQL Editor (all of it)
-- Admin activates a course for a student by INSERT into enrollments.
-- ============================================================

-- 1) Enum
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enrollment_status') THEN
    CREATE TYPE public.enrollment_status AS ENUM ('ongoing', 'completed', 'cancelled');
  END IF;
END$$;

-- 2) Table
CREATE TABLE IF NOT EXISTS public.enrollments (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             uuid NOT NULL REFERENCES public.profiles(id),
  course_id           uuid NOT NULL REFERENCES public.courses(id),
  order_id            uuid,
  status              public.enrollment_status NOT NULL DEFAULT 'ongoing',
  progress_percent    numeric(5,2) NOT NULL DEFAULT 0
                        CHECK (progress_percent BETWEEN 0 AND 100),
  completed_lessons   int NOT NULL DEFAULT 0,
  total_lessons       int NOT NULL DEFAULT 0,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now(),
  completed_at        timestamptz,
  UNIQUE (user_id, course_id)
);

-- Align older schema docs that used enrolled_at
ALTER TABLE public.enrollments
  ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

CREATE INDEX IF NOT EXISTS enrollments_user_status_idx
  ON public.enrollments (user_id, status);

CREATE INDEX IF NOT EXISTS enrollments_course_status_idx
  ON public.enrollments (course_id, status)
  WHERE status IN ('ongoing', 'completed');

-- 3) RLS — students see only their own active enrollments
ALTER TABLE public.enrollments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users read own enrollments" ON public.enrollments;
CREATE POLICY "Users read own enrollments"
ON public.enrollments
FOR SELECT
TO authenticated
USING (
  auth.uid() = user_id
  AND status IN ('ongoing', 'completed')
);

-- No INSERT/UPDATE/DELETE for anon/authenticated clients.
-- Activate via SQL Editor / service role, e.g.:
-- INSERT INTO public.enrollments (user_id, course_id, status, total_lessons)
-- VALUES ('<profile_uuid>', '<course_uuid>', 'ongoing', 10)
-- ON CONFLICT (user_id, course_id) DO UPDATE
-- SET status = EXCLUDED.status, total_lessons = EXCLUDED.total_lessons;

-- 4) Lessons: free preview for everyone; full lessons only if enrolled
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read all lessons temp" ON public.lessons;
DROP POLICY IF EXISTS "Public read lessons of published courses" ON public.lessons;
DROP POLICY IF EXISTS "Read free preview lessons" ON public.lessons;
DROP POLICY IF EXISTS "Read enrolled lessons" ON public.lessons;

CREATE POLICY "Read free preview lessons"
ON public.lessons
FOR SELECT
TO anon, authenticated
USING (COALESCE(is_free_preview, false) = true);

CREATE POLICY "Read enrolled lessons"
ON public.lessons
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public.enrollments e
    WHERE e.course_id = lessons.course_id
      AND e.user_id = auth.uid()
      AND e.status IN ('ongoing', 'completed')
  )
);

-- 5) Live DB was missing courses.instructor_id — add it, then stats RPC
ALTER TABLE public.courses
  ADD COLUMN IF NOT EXISTS instructor_id uuid REFERENCES public.instructors(id);

CREATE INDEX IF NOT EXISTS courses_instructor_id_idx
  ON public.courses (instructor_id);

-- Assign each course to an instructor (edit as needed):
-- UPDATE public.courses SET instructor_id = '<instructor_uuid>' WHERE id = '<course_uuid>';

CREATE OR REPLACE FUNCTION public.list_instructor_stats()
RETURNS TABLE (
  instructor_id uuid,
  courses_count bigint,
  students_count bigint,
  reviews_count bigint
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    i.id AS instructor_id,
    COUNT(DISTINCT c.id) FILTER (
      WHERE c.is_published IS TRUE
    ) AS courses_count,
    COUNT(DISTINCT e.user_id) FILTER (
      WHERE e.status IN ('ongoing', 'completed')
    ) AS students_count,
    COUNT(DISTINCT r.id) AS reviews_count
  FROM public.instructors i
  LEFT JOIN public.courses c ON c.instructor_id = i.id
  LEFT JOIN public.enrollments e ON e.course_id = c.id
  LEFT JOIN public.reviews r ON r.course_id = c.id
  WHERE i.is_active IS TRUE
  GROUP BY i.id;
$$;

REVOKE ALL ON FUNCTION public.list_instructor_stats() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.list_instructor_stats() TO anon, authenticated;

-- 6) Reviews write only when enrolled (read stays public)
DROP POLICY IF EXISTS "Users insert own reviews" ON public.reviews;
CREATE POLICY "Users insert own reviews"
ON public.reviews
FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = user_id
  AND EXISTS (
    SELECT 1 FROM public.enrollments e
    WHERE e.course_id = reviews.course_id
      AND e.user_id = auth.uid()
      AND e.status IN ('ongoing', 'completed')
  )
);

-- 7) Helper: activate course for a student (run as postgres / service role)
CREATE OR REPLACE FUNCTION public.activate_course_for_user(
  p_user_id uuid,
  p_course_id uuid,
  p_status public.enrollment_status DEFAULT 'ongoing'
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_id uuid;
  v_lessons int;
BEGIN
  SELECT COALESCE(lessons_count, 0) INTO v_lessons
  FROM public.courses WHERE id = p_course_id;

  INSERT INTO public.enrollments (user_id, course_id, status, total_lessons)
  VALUES (p_user_id, p_course_id, p_status, COALESCE(v_lessons, 0))
  ON CONFLICT (user_id, course_id) DO UPDATE
  SET
    status = EXCLUDED.status,
    total_lessons = EXCLUDED.total_lessons,
    completed_at = CASE
      WHEN EXCLUDED.status = 'completed' THEN COALESCE(enrollments.completed_at, now())
      ELSE NULL
    END
  RETURNING id INTO v_id;

  UPDATE public.courses c
  SET enrollments_count = (
    SELECT COUNT(*)::int FROM public.enrollments e
    WHERE e.course_id = c.id AND e.status IN ('ongoing', 'completed')
  )
  WHERE c.id = p_course_id;

  RETURN v_id;
END;
$$;

REVOKE ALL ON FUNCTION public.activate_course_for_user(uuid, uuid, public.enrollment_status)
  FROM PUBLIC;
-- Call from SQL Editor only (not exposed to anon key).
