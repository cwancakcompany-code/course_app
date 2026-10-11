-- ============================================================
-- Lesson progress → enrollment progress_percent / completed_lessons
-- Run in Supabase SQL Editor
-- ============================================================

CREATE TABLE IF NOT EXISTS public.lesson_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  enrollment_id uuid NOT NULL REFERENCES public.enrollments(id) ON DELETE CASCADE,
  lesson_id uuid NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  watched_seconds int NOT NULL DEFAULT 0 CHECK (watched_seconds >= 0),
  is_completed boolean NOT NULL DEFAULT false,
  completed_at timestamptz,
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, lesson_id)
);

ALTER TABLE public.lesson_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS progress_own ON public.lesson_progress;
DROP POLICY IF EXISTS "Users read own lesson progress" ON public.lesson_progress;
CREATE POLICY "Users read own lesson progress"
ON public.lesson_progress
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users write own lesson progress" ON public.lesson_progress;
CREATE POLICY "Users write own lesson progress"
ON public.lesson_progress
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION public.sync_enrollment_progress(p_enrollment_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_course uuid;
  v_total int;
  v_done int;
  v_pct numeric(5,2);
BEGIN
  SELECT course_id INTO v_course
  FROM public.enrollments
  WHERE id = p_enrollment_id;

  IF v_course IS NULL THEN
    RETURN;
  END IF;

  SELECT COUNT(*)::int INTO v_total
  FROM public.lessons
  WHERE course_id = v_course;

  SELECT COUNT(*)::int INTO v_done
  FROM public.lesson_progress
  WHERE enrollment_id = p_enrollment_id
    AND is_completed IS TRUE;

  v_total := GREATEST(v_total, 1);
  v_pct := LEAST(100, ROUND((v_done::numeric / v_total) * 100, 2));

  UPDATE public.enrollments
  SET
    completed_lessons = v_done,
    total_lessons = v_total,
    progress_percent = v_pct,
    status = CASE
      WHEN v_done >= v_total THEN 'completed'::public.enrollment_status
      WHEN status = 'cancelled' THEN status
      ELSE 'ongoing'::public.enrollment_status
    END,
    completed_at = CASE
      WHEN v_done >= v_total THEN COALESCE(completed_at, now())
      ELSE NULL
    END,
    updated_at = now()
  WHERE id = p_enrollment_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.mark_lesson_completed(p_lesson_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user uuid := auth.uid();
  v_course uuid;
  v_enrollment uuid;
  v_done int;
  v_total int;
  v_pct numeric(5,2);
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT course_id INTO v_course
  FROM public.lessons
  WHERE id = p_lesson_id;

  IF v_course IS NULL THEN
    RAISE EXCEPTION 'Lesson not found';
  END IF;

  SELECT id INTO v_enrollment
  FROM public.enrollments
  WHERE user_id = v_user
    AND course_id = v_course
    AND status IN ('ongoing', 'completed')
  LIMIT 1;

  IF v_enrollment IS NULL THEN
    RAISE EXCEPTION 'Not enrolled in this course';
  END IF;

  INSERT INTO public.lesson_progress (
    enrollment_id, lesson_id, user_id, watched_seconds,
    is_completed, completed_at, updated_at
  )
  VALUES (
    v_enrollment, p_lesson_id, v_user, 0,
    true, now(), now()
  )
  ON CONFLICT (user_id, lesson_id) DO UPDATE
  SET
    is_completed = true,
    completed_at = COALESCE(public.lesson_progress.completed_at, now()),
    updated_at = now();

  PERFORM public.sync_enrollment_progress(v_enrollment);

  SELECT completed_lessons, total_lessons, progress_percent
  INTO v_done, v_total, v_pct
  FROM public.enrollments
  WHERE id = v_enrollment;

  RETURN jsonb_build_object(
    'enrollment_id', v_enrollment,
    'completed_lessons', v_done,
    'total_lessons', v_total,
    'progress_percent', v_pct
  );
END;
$$;

REVOKE ALL ON FUNCTION public.mark_lesson_completed(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.mark_lesson_completed(uuid) TO authenticated;

REVOKE ALL ON FUNCTION public.sync_enrollment_progress(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.sync_enrollment_progress(uuid) TO authenticated;
