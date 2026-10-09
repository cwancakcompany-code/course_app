# EduMaster — Database Design Document

| | |
|---|---|
| **Project** | EduMaster (Online Learning App) |
| **Platform** | Flutter + **Supabase** |
| **Database** | PostgreSQL 15+ (Supabase) |
| **Auth** | Supabase Auth (`auth.users`) |
| **Version** | 2.0 |
| **Scope** | Learning platform — **no social / chat features** |

---

## 1. Design Principles

1. **Auth is owned by Supabase** — email, password, OTP, session, reset password لە `auth.users` دەمێننەوە. ئێمە تەنها **profile** دروست دەکەین.
2. **No social layer** — چات، نامە، conversation، gift، و پەیوەندی کۆمەڵایەتی لە schemaدا نین.
3. **Normalize for write, denormalize carefully for read** — countersی وەک `rating_avg` و `enrollments_count` وەک cached value دەهێڵدرێنەوە (بۆ لیستە خێراکان).
4. **UUID everywhere** — هەموو PKـکان `uuid`ـن، هاوڕێ لەگەڵ Supabase.
5. **Soft delete بۆ user data** — `profiles.deleted_at`؛ ناوەڕۆکی کۆرس بە `is_published` کۆنتڕۆڵ دەکرێت.
6. **Never store secrets** — password، CVV، full card number لە `public` schemaدا نابن. کارت تەنها token + last4.

---

## 2. What We Keep / What We Drop

| Feature in App UI | In Database? | Notes |
|-------------------|--------------|-------|
| Sign Up / Sign In / OTP / Forgot Password | ✅ via **Supabase Auth** | No custom `otp` / `password_hash` tables |
| Profile edit | ✅ `profiles` | Extends `auth.users` |
| Categories, Courses, Lessons, Reviews | ✅ | Core domain |
| Favourites, Enrollments, Progress | ✅ | Core domain |
| Orders, Payments, Coupons, Cards | ✅ | Commerce |
| Notifications | ✅ | Transactional only (payment, course…) |
| Search history | ✅ | Per user |
| CMS (About / Privacy / Terms) | ✅ | Static pages |
| Onboarding slides | ✅ | Optional CMS |
| **Chat / Messages** | ❌ Removed | Out of scope |
| **Instructor Message / Call social** | ❌ Removed | Keep only public instructor profile + website |
| Students list as “social feed” | ❌ | Derived from `enrollments` if needed |

---

## 3. High-Level Architecture

```
┌─────────────────────────────────────────────┐
│              SUPABASE AUTH                  │
│  auth.users  (email, password, phone, OTP)  │
└────────────────────┬────────────────────────┘
                     │ 1:1  (id = auth.uid())
                     ▼
┌─────────────────────────────────────────────┐
│                 PUBLIC SCHEMA               │
│                                             │
│  profiles                                   │
│     │                                       │
│     ├── favorites ──────────────┐           │
│     ├── enrollments ────────────┤           │
│     ├── lesson_progress ────────┤           │
│     ├── reviews ────────────────┤           │
│     ├── notifications           │           │
│     ├── search_history          │           │
│     ├── payment_methods         │           │
│     └── orders ─────────────────┤           │
│                                 ▼           │
│  instructors ─────────────── courses        │
│                                 │           │
│                    ┌────────────┼────────┐  │
│                    ▼            ▼        ▼  │
│              categories   sections   key_points
│                                 │           │
│                                 ▼           │
│                              lessons        │
│                                             │
│  coupons / coupon_redemptions / payments    │
│  onboarding_slides / cms_pages / settings   │
└─────────────────────────────────────────────┘
```

---

## 4. Entity Relationship (Logical)

```
auth.users ──1:1── profiles
                      │
                      ├──★ favorites ★── courses ★── instructors
                      │                    │
                      ├──★ enrollments ★───┤
                      │         │          │
                      │         └── lesson_progress ★── lessons
                      │                    │
                      ├──★ reviews ★───────┤
                      ├──★ orders ★────────┤── categories
                      │         │
                      │         └── payments
                      ├── payment_methods
                      ├── notifications
                      └── search_history

courses ──★ course_sections ──★ lessons
courses ──★ course_key_points
orders  ──? coupons
coupons ──★ coupon_redemptions
```

`★` = one-to-many · `?` = optional FK

---

## 5. Naming Conventions

| Rule | Example |
|------|---------|
| Tables | `snake_case`, plural: `courses`, `profiles` |
| Columns | `snake_case`: `first_name`, `created_at` |
| Primary key | `id uuid` |
| Foreign key | `{table_singular}_id` → `course_id` |
| Booleans | `is_` / `has_` → `is_published`, `has_certificate` |
| Timestamps | `*_at` → `created_at`, `enrolled_at` |
| Money | `DECIMAL(10,2)` + `currency char(3)` ISO 4217 |
| Enums | PostgreSQL `CREATE TYPE` یان `text` + CHECK |

---

## 6. Tables — Detailed Spec

### 6.1 `profiles`
پڕۆفایلی ئەپ. **PK = `auth.users.id`**.  
Sign Up/Sign In لە Supabase Auth؛ ئەم تەیبڵە تەنها داتای زیادە دەگرێت.

| Column | Type | Null | Default | Notes |
|--------|------|------|---------|-------|
| `id` | `uuid` | NO | — | **PK**, FK → `auth.users(id)` ON DELETE CASCADE |
| `user_name` | `text` | NO | — | UNIQUE |
| `first_name` | `text` | NO | — | |
| `last_name` | `text` | NO | — | |
| `phone_country_code` | `text` | YES | — | e.g. `+91` |
| `phone_number` | `text` | YES | — | |
| `avatar_url` | `text` | YES | — | Supabase Storage path/URL |
| `country_iso` | `char(2)` | YES | — | e.g. `IN` |
| `timezone` | `text` | YES | `'UTC'` | IANA name |
| `preferred_currency` | `char(3)` | YES | `'USD'` | ISO 4217 |
| `role` | `user_role` | NO | `'student'` | enum: `student` \| `admin` |
| `is_active` | `boolean` | NO | `true` | |
| `created_at` | `timestamptz` | NO | `now()` | |
| `updated_at` | `timestamptz` | NO | `now()` | |
| `deleted_at` | `timestamptz` | YES | — | soft delete |

**Indexes**
- `UNIQUE (user_name)`
- `INDEX (phone_country_code, phone_number)` WHERE phone not null

**Auth flow**
1. Client: `supabase.auth.signUp({ email, password })`
2. Trigger `on_auth_user_created` → insert row into `profiles` (لە metadataی signup: first_name, last_name, …)
3. Client: `supabase.auth.signInWithPassword` / `resetPasswordForEmail` / phone OTP — هەمووی Auth API

> **دروست ناکرێت:** `password_hash`, `otp_verifications`, `is_verified` — ئەمانە لە Authدا هەن.

---

### 6.2 `instructors`
مامۆستای کۆرس (ناوەڕۆکی public). بێ چات / call.

| Column | Type | Null | Default | Notes |
|--------|------|------|---------|-------|
| `id` | `uuid` | NO | `gen_random_uuid()` | PK |
| `profile_id` | `uuid` | YES | — | FK → `profiles(id)`, UNIQUE — ئەگەر مامۆستا لۆگینی هەبێت |
| `full_name` | `text` | NO | — | |
| `avatar_url` | `text` | YES | — | |
| `headline` | `text` | YES | — | e.g. `Design expert` |
| `bio` | `text` | YES | — | |
| `website_url` | `text` | YES | — | تەنها لینکی وێبسایت |
| `is_active` | `boolean` | NO | `true` | |
| `created_at` | `timestamptz` | NO | `now()` | |
| `updated_at` | `timestamptz` | NO | `now()` | |

**Derived (view یان RPC، نهێشتن وەک columnی نووسین):**
- `courses_count` = `COUNT(courses)`
- `students_count` = `COUNT(DISTINCT enrollments.user_id)` لە کۆرسەکانی ئەو مامۆستا
- `reviews_count` = `COUNT(reviews)` لەسەر کۆرسەکانی

ئەگەر performance پێویستی کرد، counterی materialized دەکرێت؛ لە v1 باشترە **view** بەکاربهێنرێت.

---

### 6.3 `categories`

| Column | Type | Null | Default | Notes |
|--------|------|------|---------|-------|
| `id` | `uuid` | NO | `gen_random_uuid()` | PK |
| `name` | `text` | NO | — | UNIQUE |
| `icon_url` | `text` | YES | — | SVG/PNG |
| `color_hex` | `text` | YES | — | e.g. `#4F46E5` |
| `sort_order` | `int` | NO | `0` | |
| `is_active` | `boolean` | NO | `true` | |
| `created_at` | `timestamptz` | NO | `now()` | |

---

### 6.4 `courses`
یەکەی سەرەکی ناوەڕۆک.

| Column | Type | Null | Default | Notes |
|--------|------|------|---------|-------|
| `id` | `uuid` | NO | `gen_random_uuid()` | PK |
| `instructor_id` | `uuid` | NO | — | FK → `instructors(id)` |
| `category_id` | `uuid` | NO | — | FK → `categories(id)` |
| `title` | `text` | NO | — | |
| `subtitle` | `text` | YES | — | |
| `description` | `text` | YES | — | About tab |
| `thumbnail_url` | `text` | YES | — | |
| `preview_video_url` | `text` | YES | — | |
| `price` | `numeric(10,2)` | NO | `0` | CHECK >= 0 |
| `currency` | `char(3)` | NO | `'USD'` | |
| `level` | `course_level` | NO | `'beginner'` | `beginner` \| `intermediate` \| `advanced` |
| `language` | `text` | NO | `'English'` | |
| `has_certificate` | `boolean` | NO | `true` | |
| `total_duration_minutes` | `int` | NO | `0` | CHECK >= 0 |
| `lessons_count` | `int` | NO | `0` | cached |
| `rating_avg` | `numeric(3,2)` | NO | `0` | cached, 0–5 |
| `rating_count` | `int` | NO | `0` | cached |
| `enrollments_count` | `int` | NO | `0` | cached — بۆ sort: most popular |
| `is_recommended` | `boolean` | NO | `false` | Home: Recommended |
| `is_popular` | `boolean` | NO | `false` | Home: Popular (یان تەنها لە count) |
| `is_published` | `boolean` | NO | `false` | |
| `published_at` | `timestamptz` | YES | — | Recently Added = ORDER BY this |
| `created_at` | `timestamptz` | NO | `now()` | |
| `updated_at` | `timestamptz` | NO | `now()` | |

**Indexes**
- `(category_id)`
- `(instructor_id)`
- `(is_published, published_at DESC)`
- `(is_published, is_recommended)` WHERE published
- `(is_published, price)`
- `(is_published, rating_avg DESC)`
- `(is_published, enrollments_count DESC)`
- GIN / `pg_trgm` لەسەر `title` بۆ search (ئۆپشناڵ)

---

### 6.5 `course_key_points`
خاڵەکانی About → Key Points.

| Column | Type | Null | Default |
|--------|------|------|---------|
| `id` | `uuid` | NO | `gen_random_uuid()` |
| `course_id` | `uuid` | NO | FK → `courses(id)` ON DELETE CASCADE |
| `title` | `text` | NO | — |
| `sort_order` | `int` | NO | `0` |

---

### 6.6 `course_sections`

| Column | Type | Null | Default |
|--------|------|------|---------|
| `id` | `uuid` | NO | `gen_random_uuid()` |
| `course_id` | `uuid` | NO | FK → `courses(id)` ON DELETE CASCADE |
| `title` | `text` | NO | — | e.g. `Section 1 - Introduction` |
| `sort_order` | `int` | NO | `0` |
| `duration_minutes` | `int` | NO | `0` |

**Unique:** `(course_id, sort_order)`

---

### 6.7 `lessons`

| Column | Type | Null | Default |
|--------|------|------|---------|
| `id` | `uuid` | NO | `gen_random_uuid()` |
| `section_id` | `uuid` | NO | FK → `course_sections(id)` ON DELETE CASCADE |
| `course_id` | `uuid` | NO | FK → `courses(id)` ON DELETE CASCADE |
| `title` | `text` | NO | — |
| `video_url` | `text` | YES | — | Storage یان CDN |
| `duration_seconds` | `int` | NO | `0` |
| `sort_order` | `int` | NO | `0` |
| `is_free_preview` | `boolean` | NO | `false` | پێش کڕین |
| `created_at` | `timestamptz` | NO | `now()` |

**Unique:** `(section_id, sort_order)`  
**Index:** `(course_id, sort_order)`

---

### 6.8 `reviews`
یەک ڕیڤیو بۆ هەر بەکارهێنەر لەسەر هەر کۆرسێک.

| Column | Type | Null | Default |
|--------|------|------|---------|
| `id` | `uuid` | NO | `gen_random_uuid()` |
| `course_id` | `uuid` | NO | FK → `courses` |
| `user_id` | `uuid` | NO | FK → `profiles(id)` |
| `rating` | `numeric(2,1)` | NO | CHECK `1.0`–`5.0` |
| `comment` | `text` | YES | — |
| `created_at` | `timestamptz` | NO | `now()` |
| `updated_at` | `timestamptz` | NO | `now()` |

**Unique:** `(course_id, user_id)`  
**Rule:** تەنها ئەگەر `enrollments` بوونی هەبێت (enforce لە trigger یان RLS policy + RPC).

دوای INSERT/UPDATE/DELETE → نوێکردنەوەی `courses.rating_avg` و `rating_count`.

---

### 6.9 `enrollments`
My Courses: Ongoing / Completed.

| Column | Type | Null | Default |
|--------|------|------|---------|
| `id` | `uuid` | NO | `gen_random_uuid()` |
| `user_id` | `uuid` | NO | FK → `profiles(id)` |
| `course_id` | `uuid` | NO | FK → `courses(id)` |
| `order_id` | `uuid` | YES | FK → `orders(id)` |
| `status` | `enrollment_status` | NO | `'ongoing'` | `ongoing` \| `completed` \| `cancelled` |
| `progress_percent` | `numeric(5,2)` | NO | `0` | 0–100 |
| `completed_lessons` | `int` | NO | `0` |
| `total_lessons` | `int` | NO | `0` | snapshot لە کاتی enroll |
| `enrolled_at` | `timestamptz` | NO | `now()` |
| `completed_at` | `timestamptz` | YES | — |
| `last_accessed_at` | `timestamptz` | YES | — |

**Unique:** `(user_id, course_id)`  
کاتێک `progress_percent = 100` → `status = completed`, `completed_at = now()`.

---

### 6.10 `lesson_progress`

| Column | Type | Null | Default |
|--------|------|------|---------|
| `id` | `uuid` | NO | `gen_random_uuid()` |
| `enrollment_id` | `uuid` | NO | FK → `enrollments(id)` ON DELETE CASCADE |
| `lesson_id` | `uuid` | NO | FK → `lessons(id)` ON DELETE CASCADE |
| `user_id` | `uuid` | NO | FK → `profiles(id)` |
| `watched_seconds` | `int` | NO | `0` |
| `is_completed` | `boolean` | NO | `false` |
| `completed_at` | `timestamptz` | YES | — |
| `updated_at` | `timestamptz` | NO | `now()` |

**Unique:** `(user_id, lesson_id)`

---

### 6.11 `favorites`

| Column | Type | Null | Default |
|--------|------|------|---------|
| `id` | `uuid` | NO | `gen_random_uuid()` |
| `user_id` | `uuid` | NO | FK → `profiles(id)` ON DELETE CASCADE |
| `course_id` | `uuid` | NO | FK → `courses(id)` ON DELETE CASCADE |
| `created_at` | `timestamptz` | NO | `now()` |

**Unique:** `(user_id, course_id)`

---

### 6.12 `notifications`
تەنها ئاگاداری سیستەم / پارەدان / کۆرس — بێ social.

| Column | Type | Null | Default |
|--------|------|------|---------|
| `id` | `uuid` | NO | `gen_random_uuid()` |
| `user_id` | `uuid` | NO | FK → `profiles(id)` ON DELETE CASCADE |
| `title` | `text` | NO | — |
| `body` | `text` | YES | — |
| `type` | `notification_type` | NO | `'system'` | `payment` \| `promo` \| `course` \| `account` \| `system` |
| `reference_type` | `text` | YES | — | e.g. `order`, `course` |
| `reference_id` | `uuid` | YES | — | |
| `is_read` | `boolean` | NO | `false` |
| `created_at` | `timestamptz` | NO | `now()` |

**Index:** `(user_id, created_at DESC)`

---

### 6.13 `payment_methods`
کارتە پاشەکەوتکراوەکان (tokenized). Paypal/Apple/Google وەک enum لە `orders` دەمێننەوە، پێویستیان بە rowی هەمیشەیی نییە.

| Column | Type | Null | Default |
|--------|------|------|---------|
| `id` | `uuid` | NO | `gen_random_uuid()` |
| `user_id` | `uuid` | NO | FK → `profiles(id)` ON DELETE CASCADE |
| `provider` | `text` | NO | — | e.g. `stripe` |
| `card_holder_name` | `text` | NO | — |
| `card_last4` | `char(4)` | NO | — |
| `card_brand` | `text` | YES | — | visa / mastercard |
| `expiry_month` | `smallint` | NO | — | 1–12 |
| `expiry_year` | `smallint` | NO | — | |
| `payment_token` | `text` | NO | — | gateway token — **never CVV** |
| `is_default` | `boolean` | NO | `false` |
| `created_at` | `timestamptz` | NO | `now()` |

---

### 6.14 `coupons`

| Column | Type | Null | Default |
|--------|------|------|---------|
| `id` | `uuid` | NO | `gen_random_uuid()` |
| `code` | `text` | NO | UNIQUE, UPPERCASE recommended |
| `discount_type` | `discount_type` | NO | — | `percent` \| `fixed` |
| `discount_value` | `numeric(10,2)` | NO | — | CHECK > 0 |
| `min_order_amount` | `numeric(10,2)` | NO | `0` |
| `max_uses` | `int` | YES | — | NULL = unlimited |
| `used_count` | `int` | NO | `0` |
| `starts_at` | `timestamptz` | YES | — |
| `expires_at` | `timestamptz` | YES | — |
| `is_active` | `boolean` | NO | `true` |
| `created_at` | `timestamptz` | NO | `now()` |

---

### 6.15 `coupon_redemptions`

| Column | Type | Null | Default |
|--------|------|------|---------|
| `id` | `uuid` | NO | `gen_random_uuid()` |
| `coupon_id` | `uuid` | NO | FK → `coupons` |
| `user_id` | `uuid` | NO | FK → `profiles` |
| `order_id` | `uuid` | YES | FK → `orders` |
| `redeemed_at` | `timestamptz` | NO | `now()` |

**Unique:** `(coupon_id, user_id)` — یەک جار بۆ هەر یوزەر (دەتوانرێت لاببرێت ئەگەر فرە-بەکارهێنان بڕیار بدرێت).

---

### 6.16 `orders`
کڕینی کۆرس + بنەمای E-Receipt.

| Column | Type | Null | Default | Maps to UI |
|--------|------|------|---------|------------|
| `id` | `uuid` | NO | `gen_random_uuid()` | |
| `order_number` | `text` | NO | UNIQUE | Transaction ID `#RE…` |
| `user_id` | `uuid` | NO | FK → `profiles` | |
| `course_id` | `uuid` | NO | FK → `courses` | یەک کۆرس / ئۆردەر (وەک UI) |
| `instructor_id` | `uuid` | NO | FK → `instructors` | snapshot relation |
| `amount` | `numeric(10,2)` | NO | — | Amount |
| `tax_amount` | `numeric(10,2)` | NO | `0` | Tax |
| `discount_amount` | `numeric(10,2)` | NO | `0` | Coupon |
| `total_amount` | `numeric(10,2)` | NO | — | Total |
| `currency` | `char(3)` | NO | `'USD'` | |
| `coupon_id` | `uuid` | YES | FK → `coupons` | |
| `payment_method` | `payment_method` | NO | — | `paypal` \| `apple_pay` \| `google_pay` \| `card` |
| `payment_status` | `payment_status` | NO | `'pending'` | `pending` \| `paid` \| `failed` \| `refunded` |
| `payment_method_id` | `uuid` | YES | FK → `payment_methods` | تەنها بۆ card |
| `receipt_barcode` | `text` | YES | — | payload بۆ barcode |
| `paid_at` | `timestamptz` | YES | — | Purchase Date |
| `created_at` | `timestamptz` | NO | `now()` | |
| `updated_at` | `timestamptz` | NO | `now()` | |

**Business rule:** کاتێک `payment_status` دەبێتە `paid`:
1. دروستکردنی / نوێکردنەوەی `enrollments`
2. دروستکردنی `notifications` (Payment successful)
3. زیادکردنی `courses.enrollments_count`

---

### 6.17 `payments`
Audit trailی gateway.

| Column | Type | Null | Default |
|--------|------|------|---------|
| `id` | `uuid` | NO | `gen_random_uuid()` |
| `order_id` | `uuid` | NO | FK → `orders(id)` |
| `provider` | `text` | NO | — | paypal / stripe / … |
| `provider_txn_id` | `text` | YES | — | |
| `amount` | `numeric(10,2)` | NO | — |
| `status` | `text` | NO | — | `initiated` \| `succeeded` \| `failed` |
| `raw_response` | `jsonb` | YES | — | |
| `created_at` | `timestamptz` | NO | `now()` |

---

### 6.18 `search_history`

| Column | Type | Null | Default |
|--------|------|------|---------|
| `id` | `uuid` | NO | `gen_random_uuid()` |
| `user_id` | `uuid` | NO | FK → `profiles(id)` ON DELETE CASCADE |
| `query` | `text` | NO | — |
| `created_at` | `timestamptz` | NO | `now()` |

**Index:** `(user_id, created_at DESC)`  
پێشنیار: کۆنترینەکان بسڕەوە یان LIMIT 20 لە لایەن API.

---

### 6.19 `onboarding_slides`

| Column | Type | Null | Default |
|--------|------|------|---------|
| `id` | `uuid` | NO | `gen_random_uuid()` |
| `image_url` | `text` | NO | — |
| `title` | `text` | NO | — |
| `subtitle` | `text` | YES | — |
| `sort_order` | `int` | NO | `0` |
| `is_active` | `boolean` | NO | `true` |

---

### 6.20 `cms_pages`

| Column | Type | Null | Default |
|--------|------|------|---------|
| `id` | `uuid` | NO | `gen_random_uuid()` |
| `slug` | `text` | NO | UNIQUE | `about-us`, `privacy-policy`, `terms` |
| `title` | `text` | NO | — |
| `content` | `text` | NO | — | Markdown/HTML |
| `updated_at` | `timestamptz` | NO | `now()` |

---

### 6.21 `app_settings`

| Column | Type | Null | Default |
|--------|------|------|---------|
| `id` | `uuid` | NO | `gen_random_uuid()` |
| `key` | `text` | NO | UNIQUE |
| `value` | `text` | NO | — |
| `updated_at` | `timestamptz` | NO | `now()` |

**Seed examples**
| key | value |
|-----|-------|
| `default_tax_amount` | `5.00` |
| `default_currency` | `USD` |

---

## 7. Enum Types

```sql
CREATE TYPE user_role AS ENUM ('student', 'admin');
CREATE TYPE course_level AS ENUM ('beginner', 'intermediate', 'advanced');
CREATE TYPE enrollment_status AS ENUM ('ongoing', 'completed', 'cancelled');
CREATE TYPE payment_method AS ENUM ('paypal', 'apple_pay', 'google_pay', 'card');
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');
CREATE TYPE discount_type AS ENUM ('percent', 'fixed');
CREATE TYPE notification_type AS ENUM ('payment', 'promo', 'course', 'account', 'system');
```

> `instructor` وەک role لە `profiles` دانەنرا — مامۆستا لە تەیبڵی `instructors` جیاکراوەتەوە (ناوەڕۆک، نەک auth role). ئەگەر دواتر مامۆستا پێویستی بە داشبۆردی لۆگین هەبوو، `profile_id` بەکاردێت.

---

## 8. Table Inventory (Final)

| # | Table | Purpose |
|---|-------|---------|
| 1 | `profiles` | User profile (extends Auth) |
| 2 | `instructors` | Course authors |
| 3 | `categories` | Course taxonomy |
| 4 | `courses` | Catalog |
| 5 | `course_key_points` | About highlights |
| 6 | `course_sections` | Curriculum sections |
| 7 | `lessons` | Videos |
| 8 | `reviews` | Ratings & comments |
| 9 | `enrollments` | Access + My Courses |
| 10 | `lesson_progress` | Watch progress |
| 11 | `favorites` | Wishlist |
| 12 | `notifications` | In-app alerts |
| 13 | `payment_methods` | Saved cards |
| 14 | `coupons` | Promo codes |
| 15 | `coupon_redemptions` | Coupon usage |
| 16 | `orders` | Purchases / receipts |
| 17 | `payments` | Gateway audit |
| 18 | `search_history` | Recent searches |
| 19 | `onboarding_slides` | Intro screens |
| 20 | `cms_pages` | Legal / about |
| 21 | `app_settings` | Global config |

**Total: 21 tables** in `public` (+ Supabase `auth.users`).

**Removed vs previous draft:** `conversations`, `conversation_members`, `messages`, `otp_verifications`, custom password fields, social student-feed table.

---

## 9. Query Mapping (UI → SQL intent)

| Screen / Filter | Intent |
|-----------------|--------|
| Recommended For You | `courses WHERE is_published AND is_recommended` |
| Popular Courses | `ORDER BY enrollments_count DESC` یان `is_popular` |
| Recently Added | `ORDER BY published_at DESC` |
| Category Related | `WHERE category_id = :id` |
| Filter: Most popular | `ORDER BY enrollments_count DESC` |
| Filter: Low / High price | `ORDER BY price ASC/DESC` |
| Filter: Price range | `WHERE price BETWEEN :min AND :max` |
| Search | `title ILIKE` / `pg_trgm` |
| My Courses → Ongoing | `enrollments WHERE status = 'ongoing'` |
| My Courses → Completed | `enrollments WHERE status = 'completed'` |
| Favourites | `favorites ⨝ courses` |
| E-Receipt | `orders` (+ join course/instructor) |

---

## 10. Supabase-Specific Design

### 10.1 Profile auto-create trigger

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, user_name, first_name, last_name, phone_country_code, phone_number)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'user_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
    NEW.raw_user_meta_data->>'phone_country_code',
    NEW.raw_user_meta_data->>'phone_number'
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

### 10.2 RLS — Policy Matrix (summary)

| Table | SELECT | INSERT | UPDATE | DELETE |
|-------|--------|--------|--------|--------|
| `profiles` | own row; public fields for display if needed | via trigger only | own row | soft-delete own |
| `categories`, `courses` (published), `sections`, `lessons`, `key_points`, `instructors`, `cms`, `onboarding` | **anon + authenticated** (read published) | admin only | admin only | admin only |
| `reviews` | all (for course page) | enrolled user | own | own |
| `favorites`, `enrollments`, `lesson_progress`, `notifications`, `search_history`, `payment_methods` | own (`auth.uid() = user_id`) | own | own | own |
| `orders`, `payments`, `coupon_redemptions` | own | via secure RPC / service role | service role | — |
| `coupons` | authenticated read active | admin | admin | admin |
| `app_settings` | authenticated read | admin | admin | admin |

> پارەدان و enroll دوای payment **لە Edge Function / service role** جێبەجێ بکرێت، نەک ڕاستەوخۆ لە client.

### 10.3 Storage buckets (پێشنیار)

| Bucket | Content | Access |
|--------|---------|--------|
| `avatars` | User profile images | owner write; public read |
| `course-thumbnails` | Course covers | admin write; public read |
| `lesson-videos` | Lesson media | enrolled users read (signed URL) |
| `instructor-avatars` | Instructor photos | admin write; public read |

---

## 11. Purchase Flow (Canonical)

```
1. User authenticated (Supabase Auth session)
2. Select payment_method (paypal | apple_pay | google_pay | card)
3. Optional: validate coupon → compute discount
4. Create order (pending) + call payment provider
5. On success:
   - payments.status = succeeded
   - orders.payment_status = paid, paid_at = now()
   - INSERT enrollments (ongoing, total_lessons = courses.lessons_count)
   - INSERT notification (payment)
   - INCREMENT courses.enrollments_count
6. Client shows Success → E-Receipt from orders row
```

---

## 12. Integrity Rules (Checklist)

- [ ] `profiles.id` هەمیشە = `auth.users.id`
- [ ] ناتوانرێت review بنووسرێت بێ enrollment
- [ ] ناتوانرێت lesson_progress بۆ وانەی کۆرسێک بێ enrollmentی ئەو کۆرسە
- [ ] `orders.total_amount` = `amount + tax_amount - discount_amount`
- [ ] CVV / full PAN هەرگیز لە DBدا نەبێت
- [ ] Published courses تەنها ئەوانەن کە `is_published = true` و `published_at IS NOT NULL`
- [ ] Soft-deleted profiles ناتوانن لۆگین بکەن (پشکنین لە App / Auth hook)

---

## 13. DDL Skeleton (PostgreSQL / Supabase)

```sql
-- ENUMS
CREATE TYPE user_role AS ENUM ('student', 'admin');
CREATE TYPE course_level AS ENUM ('beginner', 'intermediate', 'advanced');
CREATE TYPE enrollment_status AS ENUM ('ongoing', 'completed', 'cancelled');
CREATE TYPE payment_method AS ENUM ('paypal', 'apple_pay', 'google_pay', 'card');
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');
CREATE TYPE discount_type AS ENUM ('percent', 'fixed');
CREATE TYPE notification_type AS ENUM ('payment', 'promo', 'course', 'account', 'system');

-- PROFILES
CREATE TABLE public.profiles (
  id                   uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  user_name            text NOT NULL UNIQUE,
  first_name           text NOT NULL,
  last_name            text NOT NULL,
  phone_country_code   text,
  phone_number         text,
  avatar_url           text,
  country_iso          char(2),
  timezone             text DEFAULT 'UTC',
  preferred_currency   char(3) DEFAULT 'USD',
  role                 user_role NOT NULL DEFAULT 'student',
  is_active            boolean NOT NULL DEFAULT true,
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now(),
  deleted_at           timestamptz
);

CREATE TABLE public.instructors (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id   uuid UNIQUE REFERENCES public.profiles(id),
  full_name    text NOT NULL,
  avatar_url   text,
  headline     text,
  bio          text,
  website_url  text,
  is_active    boolean NOT NULL DEFAULT true,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.categories (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL UNIQUE,
  icon_url    text,
  color_hex   text,
  sort_order  int NOT NULL DEFAULT 0,
  is_active   boolean NOT NULL DEFAULT true,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.courses (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  instructor_id           uuid NOT NULL REFERENCES public.instructors(id),
  category_id             uuid NOT NULL REFERENCES public.categories(id),
  title                   text NOT NULL,
  subtitle                text,
  description             text,
  thumbnail_url           text,
  preview_video_url       text,
  price                   numeric(10,2) NOT NULL DEFAULT 0 CHECK (price >= 0),
  currency                char(3) NOT NULL DEFAULT 'USD',
  level                   course_level NOT NULL DEFAULT 'beginner',
  language                text NOT NULL DEFAULT 'English',
  has_certificate         boolean NOT NULL DEFAULT true,
  total_duration_minutes  int NOT NULL DEFAULT 0 CHECK (total_duration_minutes >= 0),
  lessons_count           int NOT NULL DEFAULT 0,
  rating_avg              numeric(3,2) NOT NULL DEFAULT 0,
  rating_count            int NOT NULL DEFAULT 0,
  enrollments_count       int NOT NULL DEFAULT 0,
  is_recommended          boolean NOT NULL DEFAULT false,
  is_popular              boolean NOT NULL DEFAULT false,
  is_published            boolean NOT NULL DEFAULT false,
  published_at            timestamptz,
  created_at              timestamptz NOT NULL DEFAULT now(),
  updated_at              timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.course_key_points (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id   uuid NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  title       text NOT NULL,
  sort_order  int NOT NULL DEFAULT 0
);

CREATE TABLE public.course_sections (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id         uuid NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  title             text NOT NULL,
  sort_order        int NOT NULL DEFAULT 0,
  duration_minutes  int NOT NULL DEFAULT 0,
  UNIQUE (course_id, sort_order)
);

CREATE TABLE public.lessons (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  section_id        uuid NOT NULL REFERENCES public.course_sections(id) ON DELETE CASCADE,
  course_id         uuid NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  title             text NOT NULL,
  video_url         text,
  duration_seconds  int NOT NULL DEFAULT 0,
  sort_order        int NOT NULL DEFAULT 0,
  is_free_preview   boolean NOT NULL DEFAULT false,
  created_at        timestamptz NOT NULL DEFAULT now(),
  UNIQUE (section_id, sort_order)
);

CREATE TABLE public.reviews (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id   uuid NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  user_id     uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  rating      numeric(2,1) NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment     text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (course_id, user_id)
);

CREATE TABLE public.coupons (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code               text NOT NULL UNIQUE,
  discount_type      discount_type NOT NULL,
  discount_value     numeric(10,2) NOT NULL CHECK (discount_value > 0),
  min_order_amount   numeric(10,2) NOT NULL DEFAULT 0,
  max_uses           int,
  used_count         int NOT NULL DEFAULT 0,
  starts_at          timestamptz,
  expires_at         timestamptz,
  is_active          boolean NOT NULL DEFAULT true,
  created_at         timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.payment_methods (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id            uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  provider           text NOT NULL,
  card_holder_name   text NOT NULL,
  card_last4         char(4) NOT NULL,
  card_brand         text,
  expiry_month       smallint NOT NULL CHECK (expiry_month BETWEEN 1 AND 12),
  expiry_year        smallint NOT NULL,
  payment_token      text NOT NULL,
  is_default         boolean NOT NULL DEFAULT false,
  created_at         timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.orders (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number        text NOT NULL UNIQUE,
  user_id             uuid NOT NULL REFERENCES public.profiles(id),
  course_id           uuid NOT NULL REFERENCES public.courses(id),
  instructor_id       uuid NOT NULL REFERENCES public.instructors(id),
  amount              numeric(10,2) NOT NULL,
  tax_amount          numeric(10,2) NOT NULL DEFAULT 0,
  discount_amount     numeric(10,2) NOT NULL DEFAULT 0,
  total_amount        numeric(10,2) NOT NULL,
  currency            char(3) NOT NULL DEFAULT 'USD',
  coupon_id           uuid REFERENCES public.coupons(id),
  payment_method      payment_method NOT NULL,
  payment_status      payment_status NOT NULL DEFAULT 'pending',
  payment_method_id   uuid REFERENCES public.payment_methods(id),
  receipt_barcode     text,
  paid_at             timestamptz,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now(),
  CHECK (total_amount = amount + tax_amount - discount_amount)
);

CREATE TABLE public.payments (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id         uuid NOT NULL REFERENCES public.orders(id),
  provider         text NOT NULL,
  provider_txn_id  text,
  amount           numeric(10,2) NOT NULL,
  status           text NOT NULL,
  raw_response     jsonb,
  created_at       timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.coupon_redemptions (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  coupon_id    uuid NOT NULL REFERENCES public.coupons(id),
  user_id      uuid NOT NULL REFERENCES public.profiles(id),
  order_id     uuid REFERENCES public.orders(id),
  redeemed_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (coupon_id, user_id)
);

CREATE TABLE public.enrollments (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             uuid NOT NULL REFERENCES public.profiles(id),
  course_id           uuid NOT NULL REFERENCES public.courses(id),
  order_id            uuid REFERENCES public.orders(id),
  status              enrollment_status NOT NULL DEFAULT 'ongoing',
  progress_percent    numeric(5,2) NOT NULL DEFAULT 0 CHECK (progress_percent BETWEEN 0 AND 100),
  completed_lessons   int NOT NULL DEFAULT 0,
  total_lessons       int NOT NULL DEFAULT 0,
  enrolled_at         timestamptz NOT NULL DEFAULT now(),
  completed_at        timestamptz,
  last_accessed_at    timestamptz,
  UNIQUE (user_id, course_id)
);

CREATE TABLE public.lesson_progress (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  enrollment_id    uuid NOT NULL REFERENCES public.enrollments(id) ON DELETE CASCADE,
  lesson_id        uuid NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  user_id          uuid NOT NULL REFERENCES public.profiles(id),
  watched_seconds  int NOT NULL DEFAULT 0,
  is_completed     boolean NOT NULL DEFAULT false,
  completed_at     timestamptz,
  updated_at       timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, lesson_id)
);

CREATE TABLE public.favorites (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  course_id   uuid NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  created_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, course_id)
);

CREATE TABLE public.notifications (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title            text NOT NULL,
  body             text,
  type             notification_type NOT NULL DEFAULT 'system',
  reference_type   text,
  reference_id     uuid,
  is_read          boolean NOT NULL DEFAULT false,
  created_at       timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.search_history (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  query       text NOT NULL,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.onboarding_slides (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  image_url   text NOT NULL,
  title       text NOT NULL,
  subtitle    text,
  sort_order  int NOT NULL DEFAULT 0,
  is_active   boolean NOT NULL DEFAULT true
);

CREATE TABLE public.cms_pages (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug        text NOT NULL UNIQUE,
  title       text NOT NULL,
  content     text NOT NULL,
  updated_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.app_settings (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  key         text NOT NULL UNIQUE,
  value       text NOT NULL,
  updated_at  timestamptz NOT NULL DEFAULT now()
);
```

---

## 14. Out of Scope (Explicit)

ئەمانە **ناکرێن** لەم داتابەیسەدا:

- Chat / DM / conversation / message threads  
- Social feed، follow، gift، friend  
- Custom OTP / password storage (Supabase Auth دەیکات)  
- Multi-item cart (UIی ئێستا یەک کۆرس / کڕینە)

ئەگەر دواتر پێویست بوو، وەک **ڕوکاری جیا** زیاد دەکرێت، نەک تێکەڵ بە core schema.

---

*Document rewritten for Supabase Auth, non-social learning platform, production-oriented PostgreSQL design.*
