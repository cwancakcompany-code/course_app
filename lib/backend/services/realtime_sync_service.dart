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

/// Central Supabase Realtime sync for catalog, enrollments, reviews, curriculum.
class RealtimeSyncService {
  static final RealtimeSyncService _instance = RealtimeSyncService._internal();
  factory RealtimeSyncService() => _instance;
  RealtimeSyncService._internal();

  RealtimeChannel? _channel;
  Timer? _pollingTimer;
  StreamSubscription<AuthState>? _authSub;
  bool _isStarted = false;
  int _eventTick = 0;

  /// Course id that changed (null = refresh all / unknown).
  final ValueNotifier<String?> courseUpdateNotifier = ValueNotifier<String?>(null);

  /// Course id whose reviews changed.
  final ValueNotifier<String?> reviewsUpdateNotifier = ValueNotifier<String?>(null);

  /// Instructor id whose reviews changed.
  final ValueNotifier<String?> instructorReviewsUpdateNotifier =
      ValueNotifier<String?>(null);

  /// Course id whose lessons/sections/resources changed.
  final ValueNotifier<String?> curriculumUpdateNotifier =
      ValueNotifier<String?>(null);

  /// Bumps whenever My Course enrollments/progress should refresh.
  final ValueNotifier<int> enrollmentUpdateNotifier = ValueNotifier<int>(0);

  bool get isStarted => _isStarted;

  void start() {
    if (_isStarted) return;
    _isStarted = true;
    _subscribeToRealtime();
    _startPollingFallback();
    _authSub ??=
        SupabaseBootstrap.client.auth.onAuthStateChange.listen((data) {
      // Re-subscribe so RLS-scoped events use the new JWT.
      if (!_isStarted) return;
      debugPrint('⚡ [Realtime] auth changed → resubscribe (${data.event})');
      _resubscribe();
      if (data.session != null) {
        _onEnrollmentChanged();
      }
    });
  }

  void stop() {
    _isStarted = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _authSub?.cancel();
    _authSub = null;
    _removeChannel();
  }

  void _resubscribe() {
    _removeChannel();
    _subscribeToRealtime();
  }

  void _removeChannel() {
    if (_channel == null) return;
    try {
      SupabaseBootstrap.client.removeChannel(_channel!);
    } catch (_) {}
    _channel = null;
  }

  /// Force notify even when the same id is set twice.
  void _bump(ValueNotifier<String?> notifier, String? id) {
    notifier.value = null;
    notifier.value = id;
  }

  void _subscribeToRealtime() {
    try {
      final client = SupabaseBootstrap.client;
      _channel = client.channel('edumaster_public_realtime_v1');

      void bind(String table, void Function(PostgresChangePayload) onData) {
        _channel!.onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          callback: onData,
        );
      }

      bind('courses', (payload) {
        final courseId = _rowId(payload);
        debugPrint('⚡ [Realtime] courses ${payload.eventType}: $courseId');
        _onCatalogChanged(courseId: courseId);
      });

      bind('categories', (payload) {
        debugPrint('⚡ [Realtime] categories ${payload.eventType}');
        _onCatalogChanged();
      });

      bind('instructors', (payload) {
        debugPrint('⚡ [Realtime] instructors ${payload.eventType}');
        _onCatalogChanged();
      });

      bind('course_instructors', (payload) {
        debugPrint('⚡ [Realtime] course_instructors ${payload.eventType}');
        _onCatalogChanged();
      });

      bind('enrollments', (payload) {
        debugPrint('⚡ [Realtime] enrollments ${payload.eventType}');
        _onEnrollmentChanged();
      });

      bind('lesson_progress', (payload) {
        debugPrint('⚡ [Realtime] lesson_progress ${payload.eventType}');
        _onEnrollmentChanged();
      });

      bind('reviews', (payload) {
        final courseId = _field(payload, 'course_id');
        debugPrint('⚡ [Realtime] reviews ${payload.eventType}: $courseId');
        _onCourseReviewsChanged(courseId: courseId);
      });

      bind('instructor_reviews', (payload) {
        final instructorId = _field(payload, 'instructor_id');
        debugPrint(
          '⚡ [Realtime] instructor_reviews ${payload.eventType}: $instructorId',
        );
        _onInstructorReviewsChanged(instructorId: instructorId);
      });

      bind('lessons', (payload) {
        final courseId = _field(payload, 'course_id');
        debugPrint('⚡ [Realtime] lessons ${payload.eventType}: $courseId');
        _onCurriculumChanged(courseId: courseId);
      });

      bind('course_sections', (payload) {
        final courseId = _field(payload, 'course_id');
        debugPrint(
          '⚡ [Realtime] course_sections ${payload.eventType}: $courseId',
        );
        _onCurriculumChanged(courseId: courseId);
      });

      bind('lesson_resources', (payload) {
        debugPrint('⚡ [Realtime] lesson_resources ${payload.eventType}');
        // Resources nest under lessons — refresh open course curriculum.
        _onCurriculumChanged(courseId: null);
      });

      bind('profiles', (payload) {
        final profileId = _rowId(payload);
        debugPrint('⚡ [Realtime] profiles ${payload.eventType}: $profileId');
        _onProfileChanged(userId: profileId);
      });

      _channel!.subscribe((status, [error]) {
        debugPrint(
          '⚡ [Realtime] status=$status${error != null ? ' err=$error' : ''}',
        );
      });
    } catch (e) {
      debugPrint('Realtime subscription setup failed: $e');
    }
  }

  String? _rowId(PostgresChangePayload payload) =>
      (payload.newRecord['id'] ?? payload.oldRecord['id']) as String?;

  String? _field(PostgresChangePayload payload, String key) =>
      (payload.newRecord[key] ?? payload.oldRecord[key]) as String?;

  void _onCatalogChanged({String? courseId}) {
    EasyDebounce.debounce(
      'realtime-catalog-sync',
      const Duration(milliseconds: 350),
      () async {
        try {
          CatalogService().clearCache();
          await loadCatalog(forceRefresh: true);
          _bump(courseUpdateNotifier, courseId);
        } catch (e) {
          debugPrint('Realtime catalog reload error: $e');
        }
      },
    );
  }

  void _onEnrollmentChanged() {
    EasyDebounce.debounce(
      'realtime-enrollment-sync',
      const Duration(milliseconds: 350),
      () async {
        try {
          if (AuthService().isSignedIn) {
            await EnrollmentService().loadMyCourses(syncAppState: true);
          }
          enrollmentUpdateNotifier.value = ++_eventTick;
        } catch (e) {
          debugPrint('Realtime enrollment reload error: $e');
        }
      },
    );
  }

  void _onCourseReviewsChanged({String? courseId}) {
    EasyDebounce.debounce(
      'realtime-course-reviews-sync',
      const Duration(milliseconds: 350),
      () async {
        try {
          CatalogService().clearCache();
          await loadCatalog(forceRefresh: true);
          _bump(reviewsUpdateNotifier, courseId);
          _bump(courseUpdateNotifier, courseId);
        } catch (e) {
          debugPrint('Realtime course reviews reload error: $e');
        }
      },
    );
  }

  void _onInstructorReviewsChanged({String? instructorId}) {
    EasyDebounce.debounce(
      'realtime-instructor-reviews-sync',
      const Duration(milliseconds: 350),
      () async {
        try {
          CatalogService().clearCache();
          await loadCatalog(forceRefresh: true);
          _bump(instructorReviewsUpdateNotifier, instructorId);
        } catch (e) {
          debugPrint('Realtime instructor reviews reload error: $e');
        }
      },
    );
  }

  void _onCurriculumChanged({String? courseId}) {
    EasyDebounce.debounce(
      'realtime-curriculum-sync',
      const Duration(milliseconds: 350),
      () {
        _bump(curriculumUpdateNotifier, courseId);
        _bump(courseUpdateNotifier, courseId);
      },
    );
  }

  void _onProfileChanged({String? userId}) {
    final currentUserId = AuthService().currentUser?.id;
    if (userId != null &&
        currentUserId != null &&
        userId == currentUserId) {
      EasyDebounce.debounce(
        'realtime-profile-sync',
        const Duration(milliseconds: 350),
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

  /// Safety net if websocket drops or a table is missing from publication.
  void _startPollingFallback() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      if (!FFAppState().connected) return;
      try {
        CatalogService().clearCache();
        await loadCatalog(forceRefresh: true);
        if (AuthService().isSignedIn) {
          await EnrollmentService().loadMyCourses(syncAppState: true);
          enrollmentUpdateNotifier.value = ++_eventTick;
        }
      } catch (_) {}
    });
  }
}
