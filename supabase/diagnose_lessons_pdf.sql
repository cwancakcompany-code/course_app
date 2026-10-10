-- Admin PDFs live in lesson_resources (storage path), not lessons.pdf_url
SELECT e.enumlabel
FROM pg_enum e
JOIN pg_type t ON e.enumtypid = t.oid
WHERE t.typname = 'lesson_type'
ORDER BY e.enumsortorder;

SELECT
  l.id,
  l.title,
  l.lesson_type::text AS lesson_type,
  left(COALESCE(l.video_url, ''), 40) AS video_url,
  lr.file_url AS pdf_storage_path,
  lr.file_type
FROM public.lessons l
LEFT JOIN public.lesson_resources lr ON lr.lesson_id = l.id
ORDER BY l.created_at DESC
LIMIT 100;

SELECT
  count(*) AS total_lessons,
  count(*) FILTER (WHERE lesson_type::text = 'pdf') AS typed_pdf,
  (SELECT count(*) FROM public.lesson_resources) AS resource_rows,
  (SELECT count(*) FROM public.lesson_resources
   WHERE file_type = 'application/pdf'
      OR file_url LIKE '%.pdf'
      OR file_url LIKE 'lesson_resources/%') AS pdf_resource_rows
FROM public.lessons;
