-- ============================================================
-- Enable Supabase Realtime for EduMaster public tables
-- Run in Supabase SQL Editor (idempotent)
-- RLS still filters which row events each client receives.
-- ============================================================

DO $$
DECLARE
  t text;
  tables text[] := ARRAY[
    'courses',
    'categories',
    'instructors',
    'course_sections',
    'lessons',
    'lesson_resources',
    'lesson_progress',
    'enrollments',
    'reviews',
    'instructor_reviews',
    'profiles',
    'course_instructors',
    'course_key_points'
  ];
BEGIN
  FOREACH t IN ARRAY tables
  LOOP
    IF to_regclass(format('public.%I', t)) IS NULL THEN
      CONTINUE;
    END IF;
    BEGIN
      EXECUTE format(
        'ALTER PUBLICATION supabase_realtime ADD TABLE public.%I',
        t
      );
    EXCEPTION
      WHEN duplicate_object THEN
        NULL;
      WHEN undefined_object THEN
        NULL;
    END;
  END LOOP;
END $$;

-- Needed so UPDATE/DELETE payloads include old row keys for clients.
DO $$
DECLARE
  t text;
  tables text[] := ARRAY[
    'courses',
    'enrollments',
    'reviews',
    'instructor_reviews',
    'lessons',
    'lesson_progress',
    'lesson_resources',
    'course_sections',
    'profiles'
  ];
BEGIN
  FOREACH t IN ARRAY tables
  LOOP
    IF to_regclass(format('public.%I', t)) IS NULL THEN
      CONTINUE;
    END IF;
    EXECUTE format(
      'ALTER TABLE public.%I REPLICA IDENTITY FULL',
      t
    );
  END LOOP;
END $$;
