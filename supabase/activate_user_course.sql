-- ============================================================
-- Activate a course for a user by email (run in SQL Editor)
-- Replace email / course id as needed
-- ============================================================

-- 1) Find user id
SELECT id, email FROM auth.users WHERE email = 'zryan@gmail.com';

-- 2) List courses
SELECT id, title, is_published FROM public.courses ORDER BY created_at DESC;

-- 3) Activate (example — paste real UUIDs from steps 1–2)
-- SELECT public.activate_course_for_user(
--   '<user_uuid_from_step_1>',
--   '<course_uuid_from_step_2>',
--   'ongoing'
-- );

-- Or direct insert matching LIVE columns:
-- INSERT INTO public.enrollments (user_id, course_id, status, total_lessons)
-- SELECT u.id, c.id, 'ongoing', COALESCE(c.lessons_count, 0)
-- FROM auth.users u
-- CROSS JOIN public.courses c
-- WHERE u.email = 'zryan@gmail.com'
--   AND c.id = '<course_uuid>'
-- ON CONFLICT (user_id, course_id) DO UPDATE
-- SET status = 'ongoing', total_lessons = EXCLUDED.total_lessons;

-- 4) Verify
SELECT e.id, e.status, e.user_id, e.course_id, c.title, e.created_at
FROM public.enrollments e
JOIN public.courses c ON c.id = e.course_id
JOIN auth.users u ON u.id = e.user_id
WHERE u.email = 'zryan@gmail.com';
