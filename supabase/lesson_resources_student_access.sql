-- ============================================================
-- Students can read lesson_resources for enrolled / free-preview
-- (Admin panel stores PDFs here — not on lessons.pdf_url)
-- Run in Supabase SQL Editor
-- ============================================================

ALTER TABLE public.lesson_resources ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Students read enrolled lesson resources" ON public.lesson_resources;
CREATE POLICY "Students read enrolled lesson resources"
ON public.lesson_resources
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public.lessons l
    JOIN public.enrollments e ON e.course_id = l.course_id
    WHERE l.id = lesson_resources.lesson_id
      AND e.user_id = auth.uid()
      AND e.status IN ('ongoing', 'completed')
  )
  OR EXISTS (
    SELECT 1
    FROM public.lessons l
    WHERE l.id = lesson_resources.lesson_id
      AND l.is_free_preview IS TRUE
  )
);

-- Free-preview: allow storage download when lesson is free preview
DROP POLICY IF EXISTS course_resources_select_free_preview ON storage.objects;
CREATE POLICY course_resources_select_free_preview ON storage.objects
FOR SELECT
TO authenticated
USING (
  bucket_id = 'course-resources'
  AND EXISTS (
    SELECT 1
    FROM public.lessons l
    WHERE l.is_free_preview IS TRUE
      AND l.course_id = public.storage_course_id_from_path(name)
      AND (
        -- path: lesson_resources/{courseId}/{lessonId}/file
        (storage.foldername(name))[3] = l.id::text
      )
  )
);
