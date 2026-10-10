import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '/backend/media/media_url_resolver.dart';
import '/backend/models/review_entity.dart';
import '/backend/services/auth_service.dart';
import '/backend/services/catalog_service.dart';
import '/backend/services/enrollment_service.dart';
import '/backend/ui/app_notify.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/pages/components/review_component/review_component_widget.dart';

class CourseReviewsTab extends StatefulWidget {
  const CourseReviewsTab({
    super.key,
    required this.courseId,
    required this.reviews,
    required this.loading,
    required this.onChanged,
    this.isEnrolled = false,
  });

  final String courseId;
  final List<ReviewEntity> reviews;
  final bool loading;
  final Future<void> Function() onChanged;
  final bool isEnrolled;

  @override
  State<CourseReviewsTab> createState() => _CourseReviewsTabState();
}

class _CourseReviewsTabState extends State<CourseReviewsTab> {
  double _rating = 5;
  final _commentController = TextEditingController();
  bool _submitting = false;
  static const _media = MediaUrlResolver();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!FFAppState().isLogin || AuthService().currentUser == null) {
      AppNotify.warning(context, 'Sign in to write a review');
      if (!mounted) return;
      context.pushNamed(
        SignInPageWidget.routeName,
        queryParameters: {
          'isInner': serializeParam(true, ParamType.bool),
        }.withoutNulls,
      );
      return;
    }
    if (widget.courseId.isEmpty) return;

    final enrolled = widget.isEnrolled ||
        await EnrollmentService().isEnrolled(widget.courseId);
    if (!enrolled) {
      if (!mounted) return;
      AppNotify.warning(
        context,
        'تەنها دوای چالاککردنی کۆرسەکە دەتوانیت ڕیڤیو بنووسیت',
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await CatalogService().submitCourseReview(
        courseId: widget.courseId,
        userId: AuthService().currentUser!.id,
        rating: _rating,
        comment: _commentController.text,
      );
      _commentController.clear();
      await widget.onChanged();
      if (!mounted) return;
      AppNotify.success(context, 'Review submitted');
    } catch (e) {
      debugPrint('submit review failed: $e');
      if (!mounted) return;
      AppNotify.error(
        context,
        'Could not save review. Enrollment may be required.',
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final loggedIn = FFAppState().isLogin && AuthService().currentUser != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
      primary: false,
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Reviews (${widget.reviews.length})',
            style: theme.bodyMedium.override(
              fontFamily: 'SF Pro Display',
              fontSize: 16,
              letterSpacing: 0,
              lineHeight: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.black20),
            ),
            child: loggedIn
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Write a review',
                        style: theme.bodyMedium.override(
                          fontFamily: 'SF Pro Display',
                          fontSize: 15,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: List.generate(5, (i) {
                          final star = i + 1;
                          return IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            onPressed: () => setState(() => _rating = star.toDouble()),
                            icon: Icon(
                              star <= _rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: theme.primary,
                            ),
                          );
                        }),
                      ),
                      TextField(
                        controller: _commentController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Share your experience…',
                          filled: true,
                          fillColor: theme.lightGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FFButtonWidget(
                        onPressed: _submitting ? null : _submit,
                        text: _submitting ? 'Saving…' : 'Submit review',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 48,
                          color: theme.primary,
                          textStyle: theme.titleSmall.override(
                            fontFamily: 'SF Pro Display',
                            color: Colors.white,
                            fontSize: 15,
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold,
                          ),
                          elevation: 0,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign in to write a review. Guests can only read reviews.',
                        style: theme.bodyMedium.override(
                          fontFamily: 'SF Pro Display',
                          fontSize: 14,
                          letterSpacing: 0,
                          color: theme.secondaryText,
                          lineHeight: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FFButtonWidget(
                        onPressed: () {
                          context.pushNamed(
                            SignInPageWidget.routeName,
                            queryParameters: {
                              'isInner': serializeParam(true, ParamType.bool),
                            }.withoutNulls,
                          );
                        },
                        text: 'Sign in',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 48,
                          color: theme.primary,
                          textStyle: theme.titleSmall.override(
                            fontFamily: 'SF Pro Display',
                            color: Colors.white,
                            fontSize: 15,
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold,
                          ),
                          elevation: 0,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),
        if (widget.loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (widget.reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'No reviews yet.',
              style: theme.bodyMedium.override(
                fontFamily: 'SF Pro Display',
                color: theme.secondaryText,
                fontSize: 15,
                letterSpacing: 0,
              ),
            ),
          )
        else
          ...widget.reviews.map((review) {
            final when = review.createdAt != null
                ? timeago.format(review.createdAt!)
                : '';
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: ReviewComponentWidget(
                image: _media.resolveImage(review.authorAvatarUrl),
                title: review.authorName,
                createAt: when,
                averageRate: review.rating,
                description: review.comment ?? '',
              ),
            );
          }),
      ],
    );
  }
}
