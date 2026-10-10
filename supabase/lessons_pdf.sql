-- ============================================================
-- Lessons PDF — STEP 1/2
-- Live column lesson_type is ENUM (not text). No 'mixed' value.
-- Run this, then run lessons_pdf_backfill.sql
-- ============================================================

SELECT e.enumlabel AS lesson_type_value
FROM pg_enum e
JOIN pg_type t ON e.enumtypid = t.oid
JOIN pg_namespace n ON n.oid = t.typnamespace
WHERE n.nspname = 'public' AND t.typname = 'lesson_type'
ORDER BY e.enumsortorder;

ALTER TABLE public.lessons
  ADD COLUMN IF NOT EXISTS pdf_url text;

ALTER TYPE public.lesson_type ADD VALUE IF NOT EXISTS 'pdf';

COMMENT ON COLUMN public.lessons.pdf_url IS 'Public or storage URL to lesson PDF';
