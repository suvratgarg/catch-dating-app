import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catch_notice.g.dart';

enum CatchNoticeTone { status, success, warning, danger, event }

class AppNotice {
  const AppNotice({
    required this.id,
    required this.title,
    this.message,
    this.icon = Icons.info_outline_rounded,
    this.tone = CatchNoticeTone.status,
    this.actionLabel,
    this.onAction,
    this.duration = const Duration(seconds: 6),
    this.dedupeKey,
    this.priority = 0,
    this.dismissible = true,
  });

  const AppNotice.offline()
    : id = 'connectivity.offline',
      title = "You're offline",
      message = 'Some content may be out of date.',
      icon = Icons.cloud_off_rounded,
      tone = CatchNoticeTone.warning,
      actionLabel = null,
      onAction = null,
      duration = null,
      dedupeKey = 'connectivity.offline',
      priority = 100,
      dismissible = false;

  final String id;
  final String title;
  final String? message;
  final IconData icon;
  final CatchNoticeTone tone;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration? duration;
  final String? dedupeKey;
  final int priority;
  final bool dismissible;

  bool get isPersistent => duration == null;
}

@immutable
class AppNoticeQueue {
  const AppNoticeQueue([this.notices = const <AppNotice>[]]);

  final List<AppNotice> notices;

  AppNotice? get current => notices.isEmpty ? null : notices.first;
}

@Riverpod(keepAlive: true)
class AppNoticeController extends _$AppNoticeController {
  @override
  AppNoticeQueue build() => const AppNoticeQueue();

  void show(AppNotice notice) {
    final dedupeKey = notice.dedupeKey;
    final notices = [
      for (final item in state.notices)
        if (dedupeKey == null || item.dedupeKey != dedupeKey) item,
      notice,
    ]..sort((a, b) => b.priority.compareTo(a.priority));

    state = AppNoticeQueue(List.unmodifiable(notices));
  }

  void dismiss(String id) {
    state = AppNoticeQueue(
      List.unmodifiable(state.notices.where((notice) => notice.id != id)),
    );
  }

  void clear() {
    state = const AppNoticeQueue();
  }
}

class CatchNoticeHost extends ConsumerStatefulWidget {
  const CatchNoticeHost({
    super.key,
    required this.child,
    this.persistentNotices = const <AppNotice>[],
  });

  final Widget child;
  final List<AppNotice> persistentNotices;

  @override
  ConsumerState<CatchNoticeHost> createState() => _CatchNoticeHostState();
}

class _CatchNoticeHostState extends ConsumerState<CatchNoticeHost> {
  Timer? _dismissTimer;
  String? _scheduledNoticeId;

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AppNotice?>(
      appNoticeControllerProvider.select((queue) => queue.current),
      (previous, next) => _scheduleAutoDismiss(next),
    );

    final eventNotice = ref.watch(
      appNoticeControllerProvider.select((queue) => queue.current),
    );
    final notices = <AppNotice>[...widget.persistentNotices, ?eventNotice];

    return Stack(
      children: [
        widget.child,
        if (notices.isNotEmpty)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              minimum: const EdgeInsets.symmetric(horizontal: CatchSpacing.s4),
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: CatchSpacing.s3),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final notice in notices) ...[
                          CatchNotice(
                            key: ValueKey('app_notice.${notice.id}'),
                            notice: notice,
                            onDismiss: notice.dismissible
                                ? () => ref
                                      .read(
                                        appNoticeControllerProvider.notifier,
                                      )
                                      .dismiss(notice.id)
                                : null,
                          ),
                          if (notice != notices.last)
                            const SizedBox(height: CatchSpacing.s2),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _scheduleAutoDismiss(AppNotice? notice) {
    if (_scheduledNoticeId == notice?.id) return;

    _dismissTimer?.cancel();
    _scheduledNoticeId = notice?.id;

    final duration = notice?.duration;
    if (notice == null || duration == null) return;

    _dismissTimer = Timer(duration, () {
      if (!mounted) return;
      ref.read(appNoticeControllerProvider.notifier).dismiss(notice.id);
    });
  }
}

class CatchNotice extends StatelessWidget {
  const CatchNotice({super.key, required this.notice, this.onDismiss});

  final AppNotice notice;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final palette = _NoticePalette.from(CatchTokens.of(context), notice.tone);
    final actionLabel = notice.actionLabel;
    final onAction = notice.onAction;

    return Semantics(
      container: true,
      liveRegion: true,
      label: [
        notice.title,
        if (notice.message != null) notice.message!,
      ].join('. '),
      child: CatchSurface(
        elevation: CatchSurfaceElevation.overlay,
        radius: CatchRadius.lg,
        borderColor: palette.border,
        backgroundColor: palette.background,
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s3,
          vertical: CatchSpacing.s3,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: palette.iconBackground,
                borderRadius: BorderRadius.circular(CatchRadius.pill),
              ),
              child: SizedBox.square(
                dimension: 36,
                child: Icon(notice.icon, color: palette.icon, size: 20),
              ),
            ),
            const SizedBox(width: CatchSpacing.s3),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.labelL(
                      context,
                      color: palette.foreground,
                    ),
                  ),
                  if (notice.message != null) ...[
                    const SizedBox(height: CatchSpacing.s1 / 2),
                    Text(
                      notice.message!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.supporting(
                        context,
                        color: palette.secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: CatchSpacing.s2),
              CatchButton(
                label: actionLabel,
                onPressed: onAction,
                size: CatchButtonSize.sm,
                variant: CatchButtonVariant.secondary,
              ),
            ],
            if (onDismiss != null) ...[
              const SizedBox(width: CatchSpacing.s1),
              IconButton(
                tooltip: 'Dismiss',
                onPressed: onDismiss,
                icon: Icon(
                  Icons.close_rounded,
                  color: palette.secondary,
                  size: 18,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NoticePalette {
  const _NoticePalette({
    required this.background,
    required this.foreground,
    required this.secondary,
    required this.icon,
    required this.iconBackground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color secondary;
  final Color icon;
  final Color iconBackground;
  final Color border;

  factory _NoticePalette.from(CatchTokens t, CatchNoticeTone tone) {
    final toneColor = switch (tone) {
      CatchNoticeTone.status => t.accent,
      CatchNoticeTone.success => t.success,
      CatchNoticeTone.warning => t.warning,
      CatchNoticeTone.danger => t.danger,
      CatchNoticeTone.event => t.primary,
    };

    return _NoticePalette(
      background: Color.lerp(t.surface, toneColor, 0.08)!,
      foreground: t.ink,
      secondary: t.ink2,
      icon: toneColor,
      iconBackground: Color.lerp(t.surface, toneColor, 0.16)!,
      border: Color.lerp(t.line, toneColor, 0.32)!,
    );
  }
}
