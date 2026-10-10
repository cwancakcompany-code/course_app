-- ============================================================
-- Lessons PDF — STEP 2/2 (run AFTER lessons_pdf.sql succeeds)
-- ============================================================

UPDATE public.lessons
SET
  lesson_type = 'pdf',
  pdf_url = COALESCE(NULLIF(BTRIM(pdf_url), ''), video_url)
WHERE (
  lower(COALESCE(video_url, '')) LIKE '%.pdf%'
  OR lower(COALESCE(pdf_url, '')) LIKE '%.pdf%'
)
AND lesson_type::text = 'video';
