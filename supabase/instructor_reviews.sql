-- ============================================================
-- Instructor reviews (students enrolled in ≥1 of their courses)
-- Run in Supabase SQL Editor
-- ============================================================

CREATE TABLE IF NOT EXISTS public.instructor_reviews (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  instructor_id  uuid NOT NULL REFERENCES public.instructors(id) ON DELETE CASCADE,
  user_id        uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  rating         numeric(2,1) NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment        text,
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now(),
  UNIQUE (instructor_id, user_id)
);

CREATE INDEX IF NOT EXISTS instructor_reviews_instructor_idx
  ON public.instructor_reviews (instructor_id, created_at DESC);

ALTER TABLE public.instructor_reviews ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.user_enrolled_with_instructor(p_instructor_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.enrollments e
    WHERE e.user_id = auth.uid()
      AND e.status IN ('ongoing', 'completed')
      AND (
        EXISTS (
          SELECT 1 FROM public.courses c
          WHERE c.id = e.course_id
            AND c.instructor_id = p_instructor_id
        )
        OR EXISTS (
          SELECT 1 FROM public.course_instructors ci
          WHERE ci.course_id = e.course_id
            AND ci.instructor_id = p_instructor_id
        )
      )
  );
$$;

REVOKE ALL ON FUNCTION public.user_enrolled_with_instructor(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.user_enrolled_with_instructor(uuid) TO authenticated;

DROP POLICY IF EXISTS "Public read instructor reviews" ON public.instructor_reviews;
CREATE POLICY "Public read instructor reviews"
ON public.instructor_reviews
FOR SELECT
TO anon, authenticated
USING (true);

DROP POLICY IF EXISTS "Enrolled students insert instructor reviews" ON public.instructor_reviews;
CREATE POLICY "Enrolled students insert instructor reviews"
ON public.instructor_reviews
FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = user_id
  AND public.user_enrolled_with_instructor(instructor_id)
);

DROP POLICY IF EXISTS "Enrolled students update own instructor reviews" ON public.instructor_reviews;
CREATE POLICY "Enrolled students update own instructor reviews"
ON public.instructor_reviews
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (
  auth.uid() = user_id
  AND public.user_enrolled_with_instructor(instructor_id)
);

DROP POLICY IF EXISTS "Users delete own instructor reviews" ON public.instructor_reviews;
CREATE POLICY "Users delete own instructor reviews"
ON public.instructor_reviews
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Stats: reviews_count from instructor_reviews (not course reviews)
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
    (
      SELECT COUNT(DISTINCT c.id)
      FROM public.courses c
      WHERE c.is_published IS TRUE
        AND (
          c.instructor_id = i.id
          OR EXISTS (
            SELECT 1 FROM public.course_instructors ci
            WHERE ci.course_id = c.id AND ci.instructor_id = i.id
          )
        )
    ) AS courses_count,
    (
      SELECT COUNT(DISTINCT e.user_id)
      FROM public.enrollments e
      WHERE e.status IN ('ongoing', 'completed')
        AND (
          EXISTS (
            SELECT 1 FROM public.courses c
            WHERE c.id = e.course_id AND c.instructor_id = i.id
          )
          OR EXISTS (
            SELECT 1 FROM public.course_instructors ci
            WHERE ci.course_id = e.course_id AND ci.instructor_id = i.id
          )
        )
    ) AS students_count,
    (
      SELECT COUNT(*)::bigint
      FROM public.instructor_reviews ir
      WHERE ir.instructor_id = i.id
    ) AS reviews_count
  FROM public.instructors i
  WHERE i.is_active IS TRUE;
$$;

REVOKE ALL ON FUNCTION public.list_instructor_stats() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.list_instructor_stats() TO anon, authenticated;
