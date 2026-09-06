import 'dart:async';

import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catch_notice.g.dart';

enum CatchNoticeTone { status, success, warning, danger, event }

class CatchNoticeData {
  const CatchNoticeData({
    required this.id,
    required this.title,
    this.message,
    IconData? icon,
    this.person,
    this.accentColor,
    this.tone = CatchNoticeTone.status,
    this.actionLabel,
    this.onAction,
    this.duration = CatchMotion.noticeAutoDismiss,
    this.dedupeKey,
    this.priority = 0,
    this.dismissible = true,
    // Keep the public argument `icon`; an initializing formal would expose
    // the private backing field instead of the caller-configurable input.
    // ignore: prefer_initializing_formals
  }) : _icon = icon,
       onOpen = null;

  /// Arrival notifications are one action, not an inline message with buttons.
  const CatchNoticeData.arrival({
    required this.id,
    required this.title,
    required VoidCallback this.onOpen,
    this.message,
    IconData? icon,
    this.person,
    this.accentColor,
    this.tone = CatchNoticeTone.event,
    this.duration = CatchMotion.noticeAutoDismiss,
    this.dedupeKey,
    this.priority = 0,
    // Keep the public icon argument rather than exposing its backing field.
    // ignore: prefer_initializing_formals
  }) : _icon = icon,
       actionLabel = null,
       onAction = null,
       dismissible = true;

  final String id;
  final String title;
  final String? message;

  /// Feature adapters own copy, identity and semantic color. The renderer owns
  /// geometry, text roles, palette derivation and image-failure fallback.
  final IconData? _icon;
  final CatchPersonAvatarItem? person;
  final Color? accentColor;
  final CatchNoticeTone tone;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onOpen;
  final Duration? duration;
  final String? dedupeKey;
  final int priority;
  final bool dismissible;

  IconData get icon => _icon ?? CatchIcons.infoOutlineRounded;

  bool get isPersistent => duration == null;
}

@immutable
class CatchNoticeQueue {
  const CatchNoticeQueue([this.notices = const <CatchNoticeData>[]]);

  final List<CatchNoticeData> notices;

  CatchNoticeData? get current => notices.isEmpty ? null : notices.first;
}

// keepalive: notice queue is app-wide UI state that must survive route
// transitions until dismissed.
@Riverpod(keepAlive: true)
class CatchNoticeController extends _$CatchNoticeController {
  @override
  CatchNoticeQueue build() => const CatchNoticeQueue();

  void show(CatchNoticeData notice) {
    final dedupeKey = notice.dedupeKey;
    final notices = [
      for (final item in state.notices)
        if (item.id != notice.id &&
            (dedupeKey == null || item.dedupeKey != dedupeKey))
          item,
    ];
    // Stable FIFO within a priority; a burst cannot create an unbounded backlog.
    final index = notices.indexWhere((item) => item.priority < notice.priority);
    notices.insert(index < 0 ? notices.length : index, notice);
    state = CatchNoticeQueue(List.unmodifiable(notices.take(8)));
  }

  void dismiss(String id) {
    state = CatchNoticeQueue(
      List.unmodifiable(state.notices.where((notice) => notice.id != id)),
    );
  }

  void clear() {
    state = const CatchNoticeQueue();
  }

  void dismissByDedupeKey(String key) {
    final remaining = state.notices
        .where((notice) => notice.dedupeKey != key)
        .toList();
    if (remaining.length == state.notices.length) return;
    state = CatchNoticeQueue(List.unmodifiable(remaining));
  }
}

class CatchNoticeHost extends ConsumerStatefulWidget {
  const CatchNoticeHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<CatchNoticeHost> createState() => _CatchNoticeHostState();
}

class _CatchNoticeHostState extends ConsumerState<CatchNoticeHost> {
  Timer? _dismissTimer;
  CatchNoticeData? _scheduledNotice;
  bool _pointerDown = false;
  bool _hovered = false;
  bool _focused = false;
  bool _accessibleNavigation = false;

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventNotice = ref.watch(
      catchNoticeControllerProvider.select((queue) => queue.current),
    );
    _scheduleAutoDismiss(eventNotice);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final entryInset = MediaQuery.paddingOf(context).top + CatchSpacing.s3;

    return CallbackShortcuts(
      bindings: {
        if (eventNotice?.onOpen != null)
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              _dismiss(eventNotice!),
      },
      child: Stack(
        children: [
          widget.child,
          if (eventNotice != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                minimum: const EdgeInsets.symmetric(
                  horizontal: CatchSpacing.s4,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: CatchSpacing.s3),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: CatchLayout.noticeMaxWidth,
                      ),
                      child: TweenAnimationBuilder<double>(
                        key: ObjectKey(eventNotice),
                        tween: Tween(begin: reduceMotion ? 0 : -1, end: 0),
                        duration: reduceMotion
                            ? Duration.zero
                            : CatchMotion.base,
                        curve: CatchMotion.standardCurve,
                        builder: (context, offset, child) =>
                            Transform.translate(
                              offset: Offset(0, offset * entryInset),
                              child: FractionalTranslation(
                                translation: Offset(0, offset),
                                child: child,
                              ),
                            ),
                        child: eventNotice.onOpen == null
                            ? CatchNotice(
                                key: ValueKey('app_notice.${eventNotice.id}'),
                                notice: eventNotice,
                                onDismiss: eventNotice.dismissible
                                    ? () => _dismiss(eventNotice)
                                    : null,
                              )
                            : MouseRegion(
                                onEnter: (_) {
                                  _hovered = true;
                                  _restartTimer();
                                },
                                onExit: (_) {
                                  _hovered = false;
                                  _restartTimer();
                                },
                                child: Listener(
                                  onPointerDown: (_) {
                                    _pointerDown = true;
                                    _restartTimer();
                                  },
                                  onPointerUp: (_) {
                                    _pointerDown = false;
                                    _restartTimer();
                                  },
                                  onPointerCancel: (_) {
                                    _pointerDown = false;
                                    _restartTimer();
                                  },
                                  child: Focus(
                                    canRequestFocus: false,
                                    onFocusChange: (focused) {
                                      _focused = focused;
                                      _restartTimer();
                                    },
                                    child: CallbackShortcuts(
                                      bindings: {
                                        const SingleActivator(
                                          LogicalKeyboardKey.escape,
                                        ): () =>
                                            _dismiss(eventNotice),
                                      },
                                      child: Dismissible(
                                        key: ValueKey(
                                          'notice.side.${eventNotice.id}',
                                        ),
                                        resizeDuration: null,
                                        movementDuration: reduceMotion
                                            ? Duration.zero
                                            : CatchMotion.fast,
                                        onDismissed: (_) =>
                                            _dismiss(eventNotice),
                                        child: Dismissible(
                                          key: ValueKey(
                                            'notice.up.${eventNotice.id}',
                                          ),
                                          direction: DismissDirection.up,
                                          resizeDuration: null,
                                          movementDuration: reduceMotion
                                              ? Duration.zero
                                              : CatchMotion.fast,
                                          onDismissed: (_) =>
                                              _dismiss(eventNotice),
                                          child: CatchNotice(
                                            key: ValueKey(
                                              'app_notice.${eventNotice.id}',
                                            ),
                                            notice: eventNotice,
                                            onDismiss: () =>
                                                _dismiss(eventNotice),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _scheduleAutoDismiss(CatchNoticeData? notice) {
    final accessible = MediaQuery.accessibleNavigationOf(context);
    if (identical(_scheduledNotice, notice) &&
        _accessibleNavigation == accessible) {
      return;
    }
    if (!identical(_scheduledNotice, notice)) {
      _pointerDown = _hovered = _focused = false;
    }
    _scheduledNotice = notice;
    _accessibleNavigation = accessible;
    _restartTimer();
  }

  void _restartTimer() {
    _dismissTimer?.cancel();
    if (!mounted) return;
    final notice = _scheduledNotice;
    final duration = notice?.duration;
    if (notice == null ||
        duration == null ||
        _accessibleNavigation ||
        _pointerDown ||
        _hovered ||
        _focused) {
      return;
    }

    _dismissTimer = Timer(duration, () {
      if (!mounted) return;
      _dismiss(notice);
    });
  }

  void _dismiss(CatchNoticeData notice) {
    // An old animation/timer must not dismiss a replacement with the same id.
    if (!identical(ref.read(catchNoticeControllerProvider).current, notice)) {
      return;
    }
    ref.read(catchNoticeControllerProvider.notifier).dismiss(notice.id);
  }
}

class CatchNotice extends StatelessWidget {
  const CatchNotice({super.key, required this.notice, this.onDismiss});

  final CatchNoticeData notice;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final palette = _NoticePalette.from(
      CatchTokens.of(context),
      notice.tone,
      accentColor: notice.accentColor,
    );
    final person = notice.person;
    final actionLabel = notice.actionLabel;
    final onAction = notice.onAction;

    return Semantics(
      container: true,
      liveRegion: true,
      onDismiss: notice.onOpen != null ? onDismiss : null,
      label: [
        notice.title,
        if (notice.message != null) notice.message!,
      ].join('. '),
      child: CatchSurface(
        onTap: notice.onOpen == null
            ? null
            : () {
                onDismiss?.call();
                notice.onOpen!();
              },
        elevation: CatchSurfaceElevation.overlay,
        borderColor: palette.border,
        backgroundColor: palette.background,
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s3,
          vertical: CatchSpacing.s3,
        ),
        child: Row(
          children: [
            if (person != null)
              CatchPersonAvatar(
                size: CatchLayout.noticeIconExtent,
                name: person.name,
                imageUrl: person.imageUrl,
                initials: person.initials,
              )
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.iconBackground,
                  borderRadius: BorderRadius.circular(CatchRadius.pill),
                ),
                child: SizedBox.square(
                  dimension: CatchLayout.noticeIconExtent,
                  child: Icon(
                    notice.icon,
                    color: palette.icon,
                    size: CatchIcon.control,
                  ),
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
                    const SizedBox(height: CatchLayout.noticeTitleMessageGap),
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
            if (onDismiss != null && notice.onOpen == null) ...[
              const SizedBox(width: CatchSpacing.s1),
              IconButton(
                tooltip: context.l10n.coreCatchNoticeTooltipDismiss,
                onPressed: onDismiss,
                icon: Icon(
                  CatchIcons.closeRounded,
                  color: palette.secondary,
                  size: CatchIcon.md,
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

  factory _NoticePalette.from(
    CatchTokens t,
    CatchNoticeTone tone, {
    Color? accentColor,
  }) {
    final toneColor =
        accentColor ??
        switch (tone) {
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
