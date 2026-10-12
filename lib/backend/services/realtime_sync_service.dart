import 'dart:async';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/app_state.dart';
import '/backend/services/auth_service.dart';
import '/backend/services/catalog_service.dart';
import '/backend/services/enrollment_service.dart';
import '/backend/supabase/supabase_bootstrap.dart';
import '/custom_code/actions/load_catalog.dart';
import '/custom_code/actions/sync_auth_session.dart';

/// Central real-time sync service for Supabase.
///
/// Listens to Postgres changes via Supabase Realtime Channels for:
/// - `courses`
/// - `categories`
/// - `instructors`
/// - `enrollments`
/// - `reviews`
/// - `instructor_reviews`
/// - `lessons`
/// - `course_sections`
/// - `profiles`
///
/// Automatically updates [FFAppState] in real-time without requiring a page reload.
class RealtimeSyncService {
  static final RealtimeSyncService _instance = RealtimeSyncService._internal();
  factory RealtimeSyncService() => _instance;
  RealtimeSyncService._internal();

  RealtimeChannel? _channel;
  Timer? _pollingTimer;
  bool _isStarted = false;

  /// Notifier to notify individual detail screens (e.g. CourseDetailPage)
  /// with the ID of the course that changed.
  final ValueNotifier<String?> courseUpdateNotifier = ValueNotifier<String?>(null);

  /// Notifier to notify review tabs when reviews change.
  final ValueNotifier<String?> reviewsUpdateNotifier = ValueNotifier<String?>(null);

  /// Notifier to notify curriculum tabs when lessons or sections change.
  final ValueNotifier<String?> curriculumUpdateNotifier = ValueNotifier<String?>(null);

  bool get isStarted => _isStarted;

  /// Starts real-time subscriptions and polling fallback.
  void start() {
    if (_isStarted) return;
    _isStarted = true;

    _subscribeToRealtime();
    _startPollingFallback();
  }

  /// Stops all subscriptions and timers.
  void stop() {
    _isStarted = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    if (_channel != null) {
      try {
        SupabaseBootstrap.client.removeChannel(_channel!);
      } catch (_) {}
      _channel = null;
    }
  }

  void _subscribeToRealtime() {
    try {
      final client = SupabaseBootstrap.client;
      _channel = client.channel('public_db_realtime_sync');

      _channel!
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'courses',
            callback: (payload) {
              final newId = payload.newRecord['id'] as String?;
              final oldId = payload.oldRecord['id'] as String?;
              final courseId = newId ?? oldId;
              debugPrint('⚡ [Realtime] courses changed (${payload.eventType}): $courseId');
              _onCatalogChanged(courseId: courseId);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'categories',
            callback: (payload) {
              debugPrint('⚡ [Realtime] categories changed (${payload.eventType})');
              _onCatalogChanged();
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'instructors',
            callback: (payload) {
              debugPrint('⚡ [Realtime] instructors changed (${payload.eventType})');
              _onCatalogChanged();
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'enrollments',
            callback: (payload) {
              debugPrint('⚡ [Realtime] enrollments changed (${payload.eventType})');
              _onEnrollmentChanged();
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'reviews',
            callback: (payload) {
              final courseId = (payload.newRecord['course_id'] ?? payload.oldRecord['course_id']) as String?;
              debugPrint('⚡ [Realtime] reviews changed (${payload.eventType}) for course: $courseId');
              _onReviewsChanged(courseId: courseId);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'instructor_reviews',
            callback: (payload) {
              debugPrint('⚡ [Realtime] instructor_reviews changed (${payload.eventType})');
              _onReviewsChanged();
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'lessons',
            callback: (payload) {
              final courseId = (payload.newRecord['course_id'] ?? payload.oldRecord['course_id']) as String?;
              debugPrint('⚡ [Realtime] lessons changed (${payload.eventType}) for course: $courseId');
              _onCurriculumChanged(courseId: courseId);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'course_sections',
            callback: (payload) {
              final courseId = (payload.newRecord['course_id'] ?? payload.oldRecord['course_id']) as String?;
              debugPrint('⚡ [Realtime] course_sections changed (${payload.eventType}) for course: $courseId');
              _onCurriculumChanged(courseId: courseId);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'profiles',
            callback: (payload) {
              final profileId = (payload.newRecord['id'] ?? payload.oldRecord['id']) as String?;
              debugPrint('⚡ [Realtime] profiles changed (${payload.eventType}) for profile: $profileId');
              _onProfileChanged(userId: profileId);
            },
          )
          .subscribe((status, [error]) {
            debugPrint('⚡ [Realtime] Subscription status: $status ${error != null ? 'Error: $error' : ''}');
          });
    } catch (e) {
      debugPrint('Realtime subscription setup failed: $e');
    }
  }

  void _onCatalogChanged({String? courseId}) {
    EasyDebounce.debounce(
      'realtime-catalog-sync',
      const Duration(milliseconds: 300),
      () async {
        try {
          CatalogService().clearCache();
          await loadCatalog(forceRefresh: true);
          courseUpdateNotifier.value = courseId;
        } catch (e) {
          debugPrint('Realtime catalog reload error: $e');
        }
      },
    );
  }

  void _onEnrollmentChanged() {
    EasyDebounce.debounce(
      'realtime-enrollment-sync',
      const Duration(milliseconds: 300),
      () async {
        try {
          if (AuthService().isSignedIn) {
            await EnrollmentService().loadMyCourses(syncAppState: true);
          }
        } catch (e) {
          debugPrint('Realtime enrollment reload error: $e');
        }
      },
    );
  }

  void _onReviewsChanged({String? courseId}) {
    EasyDebounce.debounce(
      'realtime-reviews-sync',
      const Duration(milliseconds: 300),
      () async {
        try {
          CatalogService().clearCache();
          await loadCatalog(forceRefresh: true);
          reviewsUpdateNotifier.value = courseId;
          courseUpdateNotifier.value = courseId;
        } catch (e) {
          debugPrint('Realtime reviews reload error: $e');
        }
      },
    );
  }

  void _onCurriculumChanged({String? courseId}) {
    EasyDebounce.debounce(
      'realtime-curriculum-sync',
      const Duration(milliseconds: 300),
      () {
        curriculumUpdateNotifier.value = courseId;
        courseUpdateNotifier.value = courseId;
      },
    );
  }

  void _onProfileChanged({String? userId}) {
    final currentUserId = AuthService().currentUser?.id;
    if (userId != null && currentUserId != null && userId == currentUserId) {
      EasyDebounce.debounce(
        'realtime-profile-sync',
        const Duration(milliseconds: 300),
        () async {
          try {
            await syncAuthSession();
          } catch (e) {
            debugPrint('Realtime profile reload error: $e');
          }
        },
      );
    }
  }

  /// Fallback polling mechanism:
  /// Ensures that even if the websocket temporarily disconnects or a table
  /// does not have Supabase Realtime publication enabled, all screens still
  /// automatically update seamlessly without the user reloading.
  void _startPollingFallback() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 12), (_) async {
      if (!FFAppState().connected) return;
      try {
        CatalogService().clearCache();
        await loadCatalog(forceRefresh: true);
        if (AuthService().isSignedIn) {
          await EnrollmentService().loadMyCourses(syncAppState: true);
        }
      } catch (_) {}
    });
  }
}
