-- ============================================================
-- Fix: courses.instructor_id missing → list_instructor_stats fails
-- Run this if enrollments_access.sql stopped at the stats function
-- ============================================================

ALTER TABLE public.courses
  ADD COLUMN IF NOT EXISTS instructor_id uuid REFERENCES public.instructors(id);

CREATE INDEX IF NOT EXISTS courses_instructor_id_idx
  ON public.courses (instructor_id);

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

-- Finish policies/helpers if the previous script stopped mid-way
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

-- Optional (dev): assign every course to the first instructor
-- UPDATE public.courses
-- SET instructor_id = (SELECT id FROM public.instructors WHERE is_active LIMIT 1)
-- WHERE instructor_id IS NULL;
