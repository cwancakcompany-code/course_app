-- ============================================================
-- Keep courses.rating_avg / rating_count in sync with reviews
-- Run in Supabase SQL Editor
-- ============================================================

CREATE OR REPLACE FUNCTION public.refresh_course_rating(p_course_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.courses c
  SET
    rating_avg = COALESCE((
      SELECT ROUND(AVG(r.rating)::numeric, 2)
      FROM public.reviews r
      WHERE r.course_id = p_course_id
    ), 0),
    rating_count = COALESCE((
      SELECT COUNT(*)::int
      FROM public.reviews r
      WHERE r.course_id = p_course_id
    ), 0)
  WHERE c.id = p_course_id;
END;
$$;

REVOKE ALL ON FUNCTION public.refresh_course_rating(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.refresh_course_rating(uuid) TO authenticated;

CREATE OR REPLACE FUNCTION public.trg_reviews_refresh_course_rating()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_course uuid;
BEGIN
  v_course := COALESCE(NEW.course_id, OLD.course_id);
  IF v_course IS NOT NULL THEN
    PERFORM public.refresh_course_rating(v_course);
  END IF;
  -- If course_id changed on UPDATE, refresh both.
  IF TG_OP = 'UPDATE'
     AND OLD.course_id IS DISTINCT FROM NEW.course_id
     AND OLD.course_id IS NOT NULL THEN
    PERFORM public.refresh_course_rating(OLD.course_id);
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS reviews_refresh_course_rating ON public.reviews;
CREATE TRIGGER reviews_refresh_course_rating
AFTER INSERT OR UPDATE OR DELETE ON public.reviews
FOR EACH ROW
EXECUTE FUNCTION public.trg_reviews_refresh_course_rating();

-- One-time backfill for existing reviews
UPDATE public.courses c
SET
  rating_avg = COALESCE(s.avg_rating, 0),
  rating_count = COALESCE(s.cnt, 0)
FROM (
  SELECT
    course_id,
    ROUND(AVG(rating)::numeric, 2) AS avg_rating,
    COUNT(*)::int AS cnt
  FROM public.reviews
  GROUP BY course_id
) s
WHERE c.id = s.course_id;

-- Zero out courses with no reviews
UPDATE public.courses c
SET rating_avg = 0, rating_count = 0
WHERE NOT EXISTS (
  SELECT 1 FROM public.reviews r WHERE r.course_id = c.id
)
AND (c.rating_count IS DISTINCT FROM 0 OR c.rating_avg IS DISTINCT FROM 0);
