import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/catch_club_dock.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_art.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_map_pin.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_picker.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_corner_sash.dart';
import 'package:catch_dating_app/core/widgets/catch_count_pill.dart';
import 'package:catch_dating_app/core/widgets/catch_detail_hero_backdrop.dart';
import 'package:catch_dating_app/core/widgets/catch_distance_ring.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_icon.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_event_activity_cards.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_graded_image.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_journey_steps.dart';
import 'package:catch_dating_app/core/widgets/catch_kicker.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_metric_strip.dart';
import 'package:catch_dating_app/core/widgets/catch_mini_bar_chart.dart';
import 'package:catch_dating_app/core/widgets/catch_mono_label.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/core/widgets/catch_number_stepper.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_option_card.dart';
import 'package:catch_dating_app/core/widgets/catch_otp_code_field.dart';
import 'package:catch_dating_app/core/widgets/catch_page_dots.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:catch_dating_app/core/widgets/catch_privacy_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_segmented_control.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_status_dot.dart';
import 'package:catch_dating_app/core/widgets/catch_status_bar.dart';
import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/core/widgets/event_ticket_surface.dart';
import 'package:catch_dating_app/core/widgets/event_visual_atoms.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/activity_section.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/quick_actions.dart';
import 'package:catch_dating_app/explore/presentation/widgets/catch_cover_story.dart';
import 'package:catch_dating_app/explore/presentation/widgets/catch_cross_paths_card.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/catch_roster_board.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchBadge,
  path: '[Core primitives]/Status',
)
Widget catchBadgeContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchBadge',
    contractId: 'catch.badge',
    states: const ['default', 'live', 'with-icon', 'truncated'],
    children: [
      _StateCard(
        label: 'default',
        child: _InlineWrap(
          children: const [
            CatchBadge(label: 'Queued'),
            CatchBadge(label: 'Brand', tone: CatchBadgeTone.brand),
            CatchBadge(label: 'Gold', tone: CatchBadgeTone.gold),
            CatchBadge(label: 'Action', size: CatchBadgeSize.action),
          ],
        ),
      ),
      _StateCard(
        label: 'live',
        child: const CatchBadge(label: 'Live now', tone: CatchBadgeTone.live),
      ),
      _StateCard(
        label: 'with-icon',
        child: CatchBadge(
          label: 'Verified',
          tone: CatchBadgeTone.success,
          icon: CatchIcons.checkCircle,
        ),
      ),
      _StateCard(
        label: 'truncated',
        child: SizedBox(
          width: 124,
          child: CatchBadge(
            label: 'Very long review pending label',
            tone: CatchBadgeTone.warning,
            icon: CatchIcons.infoOutlineRounded,
            borderColor: t.warning,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchIconBadge,
  path: '[Core primitives]/Status',
)
Widget catchIconBadgeContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchIconBadge',
    contractId: 'catch.badge.icon_badge',
    states: const ['count', 'overflow-count', 'hidden', 'custom-colors'],
    children: [
      _StateCard(
        label: 'count',
        child: _InlineWrap(
          children: [
            CatchIconBadge(
              label: '3',
              child: Icon(CatchIcons.chatBubbleOutlineRounded),
            ),
            CatchIconBadge(label: '9', child: Icon(CatchIcons.group)),
          ],
        ),
      ),
      _StateCard(
        label: 'overflow-count',
        child: CatchIconBadge(
          label: '99+',
          child: Icon(CatchIcons.notificationsOutlined),
        ),
      ),
      _StateCard(
        label: 'hidden',
        child: CatchIconBadge(
          label: '0',
          isLabelVisible: false,
          child: Icon(CatchIcons.savedOutlined),
        ),
      ),
      _StateCard(
        label: 'custom-colors',
        child: CatchIconBadge(
          label: '!',
          backgroundColor: t.danger,
          foregroundColor: t.surface,
          child: Icon(CatchIcons.warningAmberRounded, color: t.ink),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchStatusDot,
  path: '[Core primitives]/Status',
)
Widget catchStatusDotContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchStatusDot',
    contractId: 'catch.badge.status_dot',
    states: const ['default', 'success', 'warning', 'danger', 'bordered'],
    children: [
      _StateCard(
        label: 'tones',
        child: _InlineWrap(
          children: [
            const CatchStatusDot(),
            CatchStatusDot(color: t.success),
            CatchStatusDot(color: t.warning),
            CatchStatusDot(color: t.danger),
          ],
        ),
      ),
      _StateCard(
        label: 'bordered',
        child: CatchStatusDot(
          color: t.primary,
          size: 10,
          borderColor: t.surface,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchErrorState,
  path: '[Core primitives]/Feedback',
)
Widget catchErrorStateContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchErrorState',
    contractId: 'catch.error_state',
    states: const [
      'full-screen',
      'inline',
      'compact',
      'from-error',
      'with-retry',
      'secondary-action',
      'scaffold',
      'sliver',
      'icon',
    ],
    children: [
      _StateCard(
        label: 'full-screen',
        child: SizedBox(
          height: 220,
          child: CatchErrorState(
            title: 'Unable to load events',
            message: 'Check your connection and try again.',
            onRetry: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'inline',
        child: CatchErrorState(
          title: 'Section failed',
          message: 'The recommendations rail could not refresh.',
          mode: CatchErrorStateMode.inline,
          onRetry: _noop,
        ),
      ),
      const _StateCard(
        label: 'compact',
        child: CatchErrorState(
          title: 'Not available',
          message: 'This event is no longer open.',
          mode: CatchErrorStateMode.compact,
        ),
      ),
      _StateCard(
        label: 'from-error',
        child: CatchErrorState.fromError(
          StateError('No connection'),
          mode: CatchErrorStateMode.inline,
          onRetry: _noop,
        ),
      ),
      _StateCard(
        label: 'with-retry',
        child: CatchErrorState(
          title: 'Feed unavailable',
          message: 'Try refreshing the feed.',
          mode: CatchErrorStateMode.inline,
          onRetry: _noop,
        ),
      ),
      _StateCard(
        label: 'secondary-action',
        child: CatchErrorState(
          title: 'Could not save',
          message: 'Your changes are still local.',
          mode: CatchErrorStateMode.inline,
          onRetry: _noop,
          secondaryAction: CatchButton(
            label: 'Dismiss',
            variant: CatchButtonVariant.secondary,
            onPressed: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'scaffold',
        child: SizedBox(
          height: 260,
          child: CatchErrorScaffold(
            title: 'Profile unavailable',
            message: 'We could not load this profile right now.',
            onRetry: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'sliver',
        child: SizedBox(
          height: 260,
          child: CustomScrollView(
            slivers: [
              CatchSliverErrorState(
                title: 'Feed unavailable',
                message: 'Try refreshing the feed.',
                onRetry: _noop,
                fillRemaining: false,
              ),
            ],
          ),
        ),
      ),
      const _StateCard(label: 'icon', child: CatchErrorIcon()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchErrorIcon,
  path: '[Core primitives]/Feedback',
)
Widget catchErrorIconContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchErrorIcon',
    contractId: 'catch.error_state.icon',
    states: const ['default', 'custom-icon', 'compact'],
    children: [
      const _StateCard(label: 'default', child: CatchErrorIcon()),
      _StateCard(
        label: 'custom-icon',
        child: CatchErrorIcon(icon: CatchIcons.infoOutlineRounded),
      ),
      const _StateCard(
        label: 'compact',
        child: CatchErrorIcon(extent: 40, iconSize: 20),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchSkeleton,
  path: '[Core primitives]/Loading',
)
Widget catchLoadingContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchLoading',
    contractId: 'catch.loading',
    states: const [
      'card',
      'box',
      'text',
      'text-block',
      'circle',
      'custom',
      'list',
      'spinner',
      'async-screen',
      'async-sliver',
    ],
    children: [
      _StateCard(label: 'card', child: CatchSkeleton.card(height: 84)),
      _StateCard(
        label: 'box',
        child: CatchSkeleton.box(
          width: 96,
          height: CatchSpacing.s5,
          radius: CatchRadius.pill,
        ),
      ),
      _StateCard(label: 'text', child: CatchSkeleton.text(width: 180)),
      _StateCard(label: 'text-block', child: CatchSkeleton.textBlock(lines: 3)),
      _StateCard(label: 'circle', child: CatchSkeleton.circle(size: 48)),
      _StateCard(
        label: 'custom',
        child: CatchSkeleton.custom(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(CatchRadius.pill),
            ),
          ),
        ),
      ),
      const _StateCard(
        label: 'list',
        child: CatchSkeletonList(count: 3, height: 72),
      ),
      _StateCard(
        label: 'spinner',
        child: _InlineWrap(
          children: [
            const SizedBox.square(
              dimension: 48,
              child: CatchLoadingIndicator(),
            ),
            const SizedBox.square(
              dimension: 32,
              child: CatchLoadingIndicator(strokeWidth: 2),
            ),
            SizedBox.square(
              dimension: 48,
              child: CatchLoadingIndicator(color: t.primary),
            ),
          ],
        ),
      ),
      const _StateCard(
        label: 'async-screen',
        child: SizedBox(
          height: 260,
          child: CatchAsyncScreenLoading(count: 2, itemHeight: 72),
        ),
      ),
      const _StateCard(
        label: 'async-sliver',
        child: SizedBox(
          height: 260,
          child: CustomScrollView(
            slivers: [CatchAsyncSliverLoading(count: 2, itemHeight: 72)],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchKicker,
  path: '[Core primitives]/Typography',
)
Widget catchTypographyContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchTypography',
    contractId: 'catch.typography',
    states: const [
      'kicker-md',
      'kicker-lg',
      'tinted',
      'truncated',
      'mono-label',
    ],
    children: [
      const _StateCard(
        label: 'kicker-md',
        child: CatchKicker(label: 'Today'),
      ),
      _StateCard(
        label: 'kicker-lg',
        child: CatchKicker(label: 'Featured format', size: CatchKickerSize.lg),
      ),
      _StateCard(
        label: 'tinted',
        child: CatchKicker(label: 'Social run format', color: t.primary),
      ),
      const _StateCard(
        label: 'truncated',
        child: SizedBox(
          width: 120,
          child: CatchKicker(label: 'Very long metadata label'),
        ),
      ),
      _StateCard(
        label: 'mono-label',
        child: _InlineWrap(
          children: [
            CatchMonoLabel('6 going', color: t.ink2),
            CatchMonoLabel('2.4 km away', color: t.primary),
            SizedBox(
              width: 110,
              child: CatchMonoLabel(
                'A very long metadata label',
                color: t.ink3,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchEmptyState,
  path: '[Core primitives]/Feedback',
)
Widget catchEmptyStateContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchEmptyState',
    contractId: 'catch.empty_state',
    states: const [
      'stacked',
      'inline',
      'surface',
      'bubble-icon',
      'with-action',
      'title-only',
      'message-only',
    ],
    children: [
      _StateCard(
        label: 'stacked',
        child: CatchEmptyState(
          icon: CatchIcons.eventOutlined,
          title: 'No events yet',
          message: 'Follow a host to see upcoming plans.',
        ),
      ),
      _StateCard(
        label: 'inline',
        child: CatchEmptyState(
          icon: CatchIcons.search,
          title: 'No matches',
          message: 'Try widening your filters.',
          layout: CatchEmptyStateLayout.inline,
        ),
      ),
      _StateCard(
        label: 'surface',
        child: CatchEmptyState(
          icon: CatchIcons.group,
          title: 'Private roster',
          message: 'Attendees appear after you join.',
          surface: true,
        ),
      ),
      _StateCard(
        label: 'bubble-icon',
        child: CatchEmptyState(
          icon: CatchIcons.group,
          title: 'Private roster',
          iconStyle: CatchEmptyStateIconStyle.bubble,
        ),
      ),
      _StateCard(
        label: 'with-action',
        child: CatchEmptyState(
          icon: CatchIcons.eventOutlined,
          title: 'No events yet',
          message: 'Follow a host to see upcoming plans.',
          action: CatchButton(label: 'Explore hosts', onPressed: _noop),
        ),
      ),
      const _StateCard(
        label: 'title-only',
        child: CatchEmptyState(title: 'Nothing here yet'),
      ),
      const _StateCard(
        label: 'message-only',
        child: CatchEmptyState(message: 'Try changing your filters.'),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchErrorBanner,
  path: '[Core primitives]/Feedback',
)
Widget catchErrorBannerContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchErrorBanner',
    contractId: 'catch.error_banner',
    states: const ['inline', 'from-error', 'with-retry'],
    children: [
      const _StateCard(
        label: 'inline',
        child: CatchErrorBanner(message: 'Card details could not be saved.'),
      ),
      _StateCard(
        label: 'from-error',
        child: CatchErrorBanner.fromError(Exception('Booking failed.')),
      ),
      _StateCard(
        label: 'with-retry',
        child: CatchErrorBanner.fromError(
          Exception('Booking failed. Try once more.'),
          onRetry: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchNotice,
  path: '[Core primitives]/Feedback',
)
Widget catchNoticeContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchNotice',
    contractId: 'catch.notice',
    states: const [
      'status',
      'success',
      'warning',
      'danger',
      'event',
      'with-action',
      'persistent-offline',
      'dismissible',
    ],
    children: [
      const _StateCard(
        label: 'status',
        child: CatchNotice(
          notice: CatchNoticeData(
            id: 'status',
            title: 'Event updated',
            message: 'The start time moved to 7:30 PM.',
          ),
        ),
      ),
      const _StateCard(
        label: 'success',
        child: CatchNotice(
          notice: CatchNoticeData(
            id: 'success',
            title: 'Booking confirmed',
            tone: CatchNoticeTone.success,
          ),
        ),
      ),
      const _StateCard(
        label: 'warning',
        child: CatchNotice(notice: CatchNoticeData.offline()),
      ),
      const _StateCard(
        label: 'danger',
        child: CatchNotice(
          notice: CatchNoticeData(
            id: 'danger',
            title: 'Payment failed',
            message: 'Try a different card.',
            tone: CatchNoticeTone.danger,
          ),
        ),
      ),
      const _StateCard(
        label: 'event',
        child: CatchNotice(
          notice: CatchNoticeData(
            id: 'event',
            title: 'Event starts soon',
            message: 'Arrive by 7:20 PM.',
            tone: CatchNoticeTone.event,
          ),
        ),
      ),
      _StateCard(
        label: 'with-action',
        child: CatchNotice(
          notice: CatchNoticeData(
            id: 'action',
            title: 'Event updated',
            message: 'Review the latest details.',
            actionLabel: 'View',
            onAction: _noop,
          ),
        ),
      ),
      const _StateCard(
        label: 'persistent-offline',
        child: CatchNotice(notice: CatchNoticeData.offline()),
      ),
      _StateCard(
        label: 'dismissible',
        child: CatchNotice(
          notice: const CatchNoticeData(
            id: 'dismissible',
            title: 'Preferences saved',
            tone: CatchNoticeTone.success,
          ),
          onDismiss: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchCornerSash,
  path: '[Core primitives]/Status',
)
Widget catchCornerSashContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchCornerSash',
    contractId: 'catch.badge.corner_sash',
    states: const ['brand', 'success', 'solid', 'surface', 'top-end'],
    children: [
      _StateCard(
        label: 'tones',
        child: _InlineWrap(
          children: [
            CatchCornerSash(label: "You're in", icon: CatchIcons.checkCircle),
            CatchCornerSash(
              label: 'Hosted',
              tone: CatchSashTone.success,
              icon: CatchIcons.hosted,
            ),
            CatchCornerSash(label: 'Saved', tone: CatchSashTone.solid),
            CatchCornerSash(label: 'Private', tone: CatchSashTone.surface),
          ],
        ),
      ),
      _StateCard(
        label: 'top-end',
        child: Align(
          alignment: Alignment.centerRight,
          child: CatchCornerSash(
            label: 'Featured',
            icon: CatchIcons.sparkle,
            alignment: CatchSashAlignment.topEnd,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchButton,
  path: '[Core primitives]/Actions',
)
Widget catchButtonContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchButton',
    contractId: 'catch.button',
    states: const [
      'default',
      'pressed',
      'hovered',
      'disabled',
      'loading',
      'full-width',
      'with-icon',
    ],
    children: [
      _StateCard(
        label: 'default',
        child: _InlineWrap(
          children: [
            CatchButton(label: 'Continue', onPressed: _noop),
            CatchButton(
              label: 'Secondary',
              variant: CatchButtonVariant.secondary,
              onPressed: _noop,
            ),
            CatchButton(
              label: 'Ghost',
              variant: CatchButtonVariant.ghost,
              onPressed: _noop,
            ),
            CatchButton(
              label: 'Danger',
              variant: CatchButtonVariant.danger,
              onPressed: _noop,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'pressed / hovered',
        description: 'Hover or press this target to review transient overlays.',
        child: CatchButton(
          label: 'Interactive target',
          accentColor: t.like,
          onPressed: _noop,
        ),
      ),
      _StateCard(
        label: 'disabled',
        child: const CatchButton(label: 'Unavailable', onPressed: null),
      ),
      _StateCard(
        label: 'loading',
        child: CatchButton(label: 'Joining', isLoading: true, onPressed: _noop),
      ),
      _StateCard(
        label: 'full-width',
        child: CatchButton(
          label: 'Create event',
          fullWidth: true,
          onPressed: _noop,
        ),
      ),
      _StateCard(
        label: 'with-icon',
        child: CatchButton(
          label: 'Add to calendar',
          icon: Icon(CatchIcons.calendarAdd),
          onPressed: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchChip,
  path: '[Core primitives]/Selection',
)
Widget catchChipContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchChip',
    contractId: 'catch.chip',
    states: const [
      'default',
      'active',
      'disabled',
      'with-icon',
      'removable',
      'activity-tinted',
    ],
    children: [
      _StateCard(
        label: 'default',
        child: _InlineWrap(
          children: [
            CatchChip(label: 'Tonight', onTap: _noop),
            CatchChip(label: 'Low key', onTap: _noop),
          ],
        ),
      ),
      _StateCard(
        label: 'active',
        child: CatchChip(label: 'Selected', active: true, onTap: _noop),
      ),
      _StateCard(
        label: 'disabled',
        child: const CatchChip(label: 'Sold out', enabled: false),
      ),
      _StateCard(
        label: 'with-icon',
        child: CatchChip(
          label: 'Weekend',
          icon: Icon(CatchIcons.weekend),
          onTap: _noop,
        ),
      ),
      _StateCard(
        label: 'removable',
        child: CatchChip(
          label: 'Rooftop',
          icon: Icon(CatchIcons.pinOutlined),
          onRemove: _noop,
        ),
      ),
      _StateCard(
        label: 'activity-tinted',
        child: CatchChip(
          label: 'Run club',
          tintColor: t.like.withValues(alpha: CatchOpacity.subtleFill),
          inkColor: t.like,
          icon: Icon(CatchIcons.directionsRunRounded),
          onTap: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchField,
  path: '[Core primitives]/Inputs',
)
Widget catchFieldContractStates(BuildContext context) {
  Widget fieldState({
    required String label,
    required Widget child,
    String? description,
  }) {
    return _CatchFieldStatePreview(
      label: label,
      description: description,
      child: child,
    );
  }

  return _ContractScreen(
    title: 'CatchField',
    contractId: 'catch.field',
    states: const [
      'row-value',
      'row-title',
      'value-line',
      'chevron',
      'toggle',
      'expanded-control',
      'text-entry',
      'edit-empty',
      'edit-filled',
      'edit-focused',
      'edit-disabled',
      'edit-read-only',
      'edit-helper',
      'edit-success-helper',
      'edit-multiline',
      'edit-clearable',
      'valid',
      'error',
      'focused',
      'select',
      'select-disabled',
      'select-error',
      'add',
    ],
    children: [
      fieldState(
        label: 'row-value',
        description: 'Default row: label above, value emphasized.',
        child: CatchField.read(
          title: 'Host',
          body: 'Catch Hosts',
          icon: CatchIcons.hosted,
        ),
      ),
      fieldState(
        label: 'row-title',
        description: 'Title-emphasis row: title primary, value supporting.',
        child: CatchField.read(
          title: 'Visibility',
          body: 'Private to attendees',
          icon: CatchIcons.lockOutlineRounded,
          emphasis: CatchFieldEmphasis.title,
        ),
      ),
      fieldState(
        label: 'value-line',
        child: CatchField.read(
          title: 'Phone',
          valueText: '+91 98765 43210',
          icon: CatchIcons.phoneOutlined,
        ),
      ),
      fieldState(
        label: 'chevron',
        child: CatchField.nav(
          title: 'Location',
          body: 'Fort Greene Park',
          icon: CatchIcons.pinOutlined,
          onTap: _noop,
        ),
      ),
      fieldState(label: 'toggle', child: const _ToggleFieldDemo()),
      fieldState(
        label: 'expanded-control',
        child: CatchField.expanding(
          title: 'Capacity',
          body: '24 seats',
          icon: CatchIcons.group,
          initiallyExpanded: true,
          control: _InlineWrap(
            children: [
              CatchChip(label: '16', onTap: _noop),
              CatchChip(label: '24', active: true, onTap: _noop),
              CatchChip(label: '32', onTap: _noop),
            ],
          ),
        ),
      ),
      fieldState(
        label: 'text-entry',
        description: 'Tap the collapsed label; focus reveals the value line.',
        child: const _TextEntryFieldDemo(),
      ),
      fieldState(
        label: 'edit-empty',
        child: const CatchField.input(
          title: 'Name',
          placeholder: 'Add a public name',
        ),
      ),
      fieldState(
        label: 'edit-filled',
        child: const CatchField.input(
          title: 'Club',
          initialValue: 'Fort Greene Run Club',
        ),
      ),
      fieldState(
        label: 'edit-focused',
        child: CatchField.input(
          title: 'Search',
          initialValue: 'social run',
          focused: true,
          prefixIcon: Icon(CatchIcons.search),
        ),
      ),
      fieldState(
        label: 'edit-disabled',
        child: const CatchField.input(
          title: 'Email',
          initialValue: 'team@catch.events',
          enabled: false,
        ),
      ),
      fieldState(
        label: 'edit-read-only',
        child: const CatchField.input(
          title: 'Handle',
          initialValue: '@catch-hosts',
          readOnly: true,
        ),
      ),
      fieldState(
        label: 'edit-helper',
        description: 'Expanded helper/info state.',
        child: const CatchField.input(
          title: 'Invite note',
          placeholder: 'Add an invite note',
          helperText: 'Shown before guests request a spot.',
          helperTone: CatchFieldSupportTone.brand,
          focused: true,
        ),
      ),
      fieldState(
        label: 'edit-success-helper',
        description: 'Success helper state.',
        child: const CatchField.input(
          title: 'Invite code',
          initialValue: 'RUNCLUB',
          helperText: 'Invite code is available.',
          helperTone: CatchFieldSupportTone.success,
          focused: true,
        ),
      ),
      fieldState(
        label: 'edit-multiline',
        child: const CatchField.input(
          title: 'Description',
          initialValue: 'Meet by the fountain, then we will head out together.',
          maxLines: 4,
          minLines: 3,
        ),
      ),
      fieldState(
        label: 'edit-clearable',
        child: CatchField.input(
          title: 'Search hosts',
          initialValue: 'Run',
          showClearButton: true,
          suffixIcon: Icon(CatchIcons.search),
        ),
      ),
      fieldState(
        label: 'valid',
        child: CatchField.read(
          title: 'Invite code',
          body: 'RUNCLUB',
          icon: CatchIcons.keyOutlined,
          valid: true,
        ),
      ),
      fieldState(
        label: 'error',
        child: CatchField.input(
          title: 'Invite code',
          initialValue: 'ABC',
          icon: CatchIcons.keyOutlined,
          error: 'Use a six character invite code.',
        ),
      ),
      fieldState(
        label: 'focused',
        child: const CatchField.input(
          title: 'Handle',
          initialValue: 'catch-hosts',
          leadingUnit: '@',
          focused: true,
        ),
      ),
      fieldState(
        label: 'select',
        child: CatchField.select<String>(
          title: 'Activity',
          values: const ['Run', 'Dinner', 'Pickleball'],
          value: 'Run',
          itemLabel: (value) => value,
          prefixIcon: Icon(CatchIcons.eventOutlined),
          onChanged: (_) {},
        ),
      ),
      fieldState(
        label: 'select-disabled',
        child: CatchField.select<String>(
          title: 'Activity',
          values: const ['Run', 'Dinner', 'Pickleball'],
          value: 'Run',
          itemLabel: (value) => value,
          prefixIcon: Icon(CatchIcons.eventOutlined),
          enabled: false,
          onChanged: (_) {},
        ),
      ),
      fieldState(label: 'select-error', child: const _SelectErrorFieldDemo()),
      fieldState(
        label: 'add',
        child: CatchField.add(
          title: 'Add another time',
          icon: CatchIcons.add,
          onTap: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchFieldRow,
  path: '[Core primitives]/Inputs',
)
Widget catchFieldRowContractStates(BuildContext context) {
  final t = CatchTokens.of(context);
  final textStyle = CatchTextStyles.bodyLead(context, color: t.ink);

  return _ContractScreen(
    title: 'CatchFieldRow',
    contractId: 'catch.field.row',
    states: const [
      'standard',
      'with-leading',
      'with-trailing',
      'add',
      'tappable',
    ],
    children: [
      _StateCard(
        label: 'standard',
        child: _FieldWidth(
          child: CatchFieldRow.standard(
            content: Text('Plain row content', style: textStyle),
          ),
        ),
      ),
      _StateCard(
        label: 'with-leading',
        child: _FieldWidth(
          child: CatchFieldRow.standard(
            leading: Icon(CatchIcons.hosted, color: t.ink2),
            content: Text('Leading icon row', style: textStyle),
          ),
        ),
      ),
      _StateCard(
        label: 'with-trailing',
        child: _FieldWidth(
          child: CatchFieldRow.standard(
            content: Text('Trailing value row', style: textStyle),
            trailing: CatchFieldTrailing.valueText(text: 'Private'),
          ),
        ),
      ),
      _StateCard(
        label: 'add',
        child: _FieldWidth(
          child: CatchFieldRow.add(
            leading: Icon(CatchIcons.add, color: t.primary),
            content: Text(
              'Add another time',
              style: CatchTextStyles.fieldRowTitle(context, color: t.primary),
            ),
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'tappable',
        child: _FieldWidth(
          child: CatchFieldRow.standard(
            content: Text('Tap target row', style: textStyle),
            trailing: CatchFieldTrailing.fixedChevron(),
            onTap: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchFieldTrailing,
  path: '[Core primitives]/Inputs',
)
Widget catchFieldTrailingContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchFieldTrailing',
    contractId: 'catch.field.trailing',
    states: const [
      'value-text',
      'fixed-chevron',
      'rotating-chevron',
      'toggle',
      'clear',
      'valid',
      'custom',
    ],
    children: [
      _StateCard(
        label: 'value-text',
        child: CatchFieldTrailing.valueText(text: 'Private'),
      ),
      _StateCard(
        label: 'fixed-chevron',
        child: CatchFieldTrailing.fixedChevron(),
      ),
      _StateCard(
        label: 'rotating-chevron',
        child: _InlineWrap(
          children: [
            CatchFieldTrailing.rotatingChevron(open: false),
            CatchFieldTrailing.rotatingChevron(open: true),
          ],
        ),
      ),
      _StateCard(
        label: 'toggle',
        child: CatchFieldTrailing.toggle(
          value: true,
          onChanged: (_) {},
          semanticLabel: 'Allow reminders',
        ),
      ),
      _StateCard(
        label: 'clear',
        child: CatchFieldTrailing.clear(
          tooltip: 'Clear field',
          onPressed: _noop,
        ),
      ),
      _StateCard(label: 'valid', child: CatchFieldTrailing.valid()),
      _StateCard(
        label: 'custom',
        child: CatchFieldTrailing.custom(
          color: t.primary,
          child: const Text('Edit'),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchSection,
  path: '[Core primitives]/Sections',
)
Widget catchSectionContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchSection',
    contractId: 'catch.section',
    states: const [
      'divided-section',
      'contained-section',
      'plain-section',
      'field-list',
      'mixed-modes',
      'single-field',
      'long-copy',
      'lead-accent',
      'contained-focused',
      'contained-error',
    ],
    children: [
      _StateCard(
        label: 'contained-section',
        child: _FieldWidth(
          child: CatchSection.contained(
            children: [
              CatchField.read(
                title: 'Host',
                body: 'Catch Hosts',
                icon: CatchIcons.hosted,
              ),
              CatchField.nav(
                title: 'Visibility',
                body: 'Private to attendees',
                icon: CatchIcons.lockOutlineRounded,
                onTap: _noop,
              ),
              CatchField.toggle(
                title: 'Allow reminders',
                body: 'Push and email',
                icon: CatchIcons.notificationsOutlined,
                value: true,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'contained-focused',
        child: _FieldWidth(
          child: CatchSection.contained(
            focused: true,
            children: [
              CatchField.input(
                title: 'Public name',
                initialValue: 'Bandra Social Run',
                icon: CatchIcons.groupsOutlined,
                focused: true,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'contained-error',
        child: _FieldWidth(
          child: CatchSection.contained(
            hasError: true,
            children: [
              CatchField.input(
                title: 'Invite code',
                initialValue: 'ABC',
                icon: CatchIcons.lockOutlineRounded,
                errorText: 'Use a 6-character invite code',
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'mixed-modes',
        child: _FieldWidth(
          child: CatchSection.contained(
            children: [
              CatchField.input(
                title: 'Display name',
                initialValue: 'Suvrat',
                icon: CatchIcons.personOutlined,
              ),
              CatchField.input(
                title: 'Invite code',
                initialValue: 'ABC',
                icon: CatchIcons.keyOutlined,
                error: 'Use a six character invite code.',
              ),
              CatchField.add(
                title: 'Add another time',
                icon: CatchIcons.add,
                onTap: _noop,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'single-field',
        child: _FieldWidth(
          child: CatchSection.contained(
            children: [
              CatchField.read(
                title: 'Event type',
                body: 'Dinner',
                icon: CatchIcons.dinner,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'divided-section',
        child: CatchSection.divided(
          title: 'Account',
          children: [
            CatchField.read(
              icon: CatchIcons.phoneOutlined,
              title: 'Phone',
              body: '+91 98765 43210',
            ),
            CatchField.nav(
              icon: CatchIcons.lockOutlineRounded,
              title: 'Privacy',
              body: 'Private',
              onTap: _noop,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'field-list',
        child: _FieldWidth(
          child: CatchSection.contained(
            title: 'Profile basics',
            children: [
              CatchField.input(
                title: 'Public name',
                initialValue: 'Suvrat',
                icon: CatchIcons.personOutlined,
              ),
              CatchField.nav(
                title: 'Home base',
                body: 'Bandra West',
                icon: CatchIcons.pinOutlined,
                onTap: _noop,
              ),
              CatchField.input(
                title: 'Instagram',
                initialValue: '@catchapp',
                icon: CatchIcons.alternateEmailOutlined,
                showClearButton: true,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'long-copy',
        child: SizedBox(
          width: 360,
          child: CatchSection.contained(
            children: [
              CatchField.read(
                title: 'Long public field label that should wrap cleanly',
                body:
                    'A very long value that needs to wrap without breaking the row group surface.',
                icon: CatchIcons.infoOutlineRounded,
              ),
              CatchField.nav(
                title: 'Detailed location',
                body: 'The east entrance by the fountain near the market',
                icon: CatchIcons.pinOutlined,
                onTap: _noop,
              ),
            ],
          ),
        ),
      ),
      const _StateCard(
        label: 'lead-accent',
        child: CatchSection.divided(
          title: 'The plan',
          activityKind: ActivityKind.socialRun,
          lead: true,
          first: true,
          child: Text('Lead sections may carry the activity accent.'),
        ),
      ),
      const _StateCard(
        label: 'plain-section',
        child: CatchSection.plain(
          title: 'Inline note',
          child: Text('Plain sections keep title rhythm without a container.'),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchSectionFocusSurface,
  path: '[Core primitives]/Sections',
)
Widget catchSectionFocusSurfaceContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchSectionFocusSurface',
    contractId: 'catch.section.focus_surface',
    states: const ['default', 'focused', 'error'],
    children: [
      _StateCard(
        label: 'default',
        child: _FieldWidth(
          child: CatchSectionFocusSurface(
            padding: CatchInsets.content,
            focused: false,
            hasError: false,
            child: const Text('Contained section content'),
          ),
        ),
      ),
      _StateCard(
        label: 'focused',
        child: _FieldWidth(
          child: CatchSectionFocusSurface(
            padding: CatchInsets.content,
            focused: true,
            hasError: false,
            child: const Text('Focused contained section content'),
          ),
        ),
      ),
      _StateCard(
        label: 'error',
        child: _FieldWidth(
          child: CatchSectionFocusSurface(
            padding: CatchInsets.content,
            focused: false,
            hasError: true,
            child: const Text('Error contained section content'),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchIconButton,
  path: '[Core primitives]/Actions',
)
Widget catchIconButtonContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchIconButton',
    contractId: 'catch.icon_button',
    states: const [
      'default',
      'active',
      'disabled',
      'bordered',
      'float',
      'plain',
    ],
    children: [
      _StateCard(
        label: 'default / bordered',
        child: _InlineWrap(
          children: [
            CatchIconButton.icon(icon: CatchIcons.search, onTap: _noop),
            CatchIconButton.icon(
              icon: CatchIcons.notificationsOutlined,
              onTap: _noop,
            ),
            CatchIconButton.icon(
              icon: CatchIcons.moreHorizRounded,
              onTap: _noop,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'active',
        child: CatchIconButton.icon(
          icon: CatchIcons.checkCircle,
          active: true,
          accent: t.like,
          onTap: _noop,
        ),
      ),
      _StateCard(
        label: 'disabled',
        child: CatchIconButton.icon(
          icon: CatchIcons.close,
          disabled: true,
          onTap: _noop,
        ),
      ),
      _StateCard(
        label: 'float',
        child: _PhotoLikePanel(
          child: CatchIconButton.icon(
            icon: CatchIcons.close,
            variant: CatchIconButtonVariant.float,
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'plain',
        child: CatchIconButton.icon(
          icon: CatchIcons.tuneRounded,
          variant: CatchIconButtonVariant.plain,
          onTap: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchIconTile,
  path: '[Core primitives]/Icon atoms',
)
Widget catchIconTileContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchIconTile',
    contractId: 'catch.icon_tile',
    states: const ['default', 'tinted', 'compact'],
    children: [
      _StateCard(
        label: 'default',
        child: CatchIconTile(
          icon: CatchIcons.eventOutlined,
          iconColor: t.primary,
        ),
      ),
      _StateCard(
        label: 'tinted',
        child: CatchIconTile(
          icon: CatchIcons.lockOutlineRounded,
          iconColor: t.danger,
          backgroundColor: t.primarySoft,
        ),
      ),
      _StateCard(
        label: 'compact',
        child: CatchIconTile(
          icon: CatchIcons.sparkle,
          iconColor: t.ink,
          size: 32,
          iconSize: 16,
          radius: CatchRadius.sm,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchControlShell,
  path: '[Core primitives]/Inputs',
)
Widget catchControlShellContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  Widget shell({
    required String label,
    CatchControlSize size = CatchControlSize.md,
    CatchControlShape shape = CatchControlShape.rounded,
    CatchControlTone tone = CatchControlTone.surface,
    bool enabled = true,
    bool hasError = false,
    bool focused = false,
    VoidCallback? onTap,
    bool semanticButton = false,
  }) {
    return SizedBox(
      width: 180,
      child: CatchControlShell(
        size: size,
        shape: shape,
        tone: tone,
        enabled: enabled,
        hasError: hasError,
        focused: focused,
        onTap: onTap,
        semanticButton: semanticButton,
        child: Text(label, style: CatchTextStyles.bodyM(context, color: t.ink)),
      ),
    );
  }

  return _ContractScreen(
    title: 'CatchControlShell',
    contractId: 'catch.control_shell',
    states: const [
      'surface-md',
      'raised-compact',
      'pill',
      'focused',
      'error',
      'disabled',
      'semantic-button',
    ],
    children: [
      _StateCard(
        label: 'surface-md',
        child: shell(label: 'Regular field'),
      ),
      _StateCard(
        label: 'raised-compact',
        child: shell(
          label: 'Compact raised',
          size: CatchControlSize.compact,
          tone: CatchControlTone.raised,
        ),
      ),
      _StateCard(
        label: 'pill',
        child: shell(
          label: 'Pill trigger',
          size: CatchControlSize.compact,
          shape: CatchControlShape.pill,
        ),
      ),
      _StateCard(
        label: 'focused',
        child: shell(label: 'Focused', focused: true),
      ),
      _StateCard(
        label: 'error',
        child: shell(label: 'Error', hasError: true),
      ),
      _StateCard(
        label: 'disabled',
        child: shell(label: 'Disabled', enabled: false),
      ),
      _StateCard(
        label: 'semantic-button',
        child: shell(label: 'Open picker', onTap: _noop, semanticButton: true),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchNumberStepper,
  path: '[Core primitives]/Inputs',
)
Widget catchNumberStepperContractStates(BuildContext context) {
  String whole(num value) => value.toStringAsFixed(0);

  return _ContractScreen(
    title: 'CatchNumberStepper',
    contractId: 'catch.number_stepper',
    states: const [
      'interactive',
      'min-bound',
      'max-bound',
      'disabled',
      'custom-step',
      'custom-format',
    ],
    children: [
      _StateCard(
        label: 'interactive',
        child: CatchNumberStepper(
          value: 2,
          min: 1,
          max: 5,
          formatValue: whole,
          onChanged: (_) {},
        ),
      ),
      _StateCard(
        label: 'min-bound',
        child: CatchNumberStepper(
          value: 1,
          min: 1,
          max: 5,
          formatValue: whole,
          onChanged: (_) {},
        ),
      ),
      _StateCard(
        label: 'max-bound',
        child: CatchNumberStepper(
          value: 5,
          min: 1,
          max: 5,
          formatValue: whole,
          onChanged: (_) {},
        ),
      ),
      _StateCard(
        label: 'disabled',
        child: CatchNumberStepper(
          value: 2,
          formatValue: whole,
          enabled: false,
          onChanged: (_) {},
        ),
      ),
      _StateCard(
        label: 'custom-step',
        child: CatchNumberStepper(
          value: 30,
          min: 0,
          max: 90,
          step: 15,
          formatValue: (value) => '${value.toStringAsFixed(0)} min',
          onChanged: (_) {},
        ),
      ),
      _StateCard(
        label: 'custom-format',
        child: CatchNumberStepper(
          value: 1499,
          step: 100,
          formatValue: (value) => 'Rs ${value.toStringAsFixed(0)}',
          onChanged: (_) {},
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchOptionCard,
  path: '[Core primitives]/Selection',
)
Widget catchOptionCardContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchOptionCard',
    contractId: 'catch.option_card',
    states: const ['default', 'selected', 'disabled-by-null-action'],
    children: [
      _StateCard(
        label: 'default',
        child: _OptionWidth(
          child: CatchOptionCard(
            title: 'Casual',
            description: 'Low commitment attendance with flexible arrival.',
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'selected',
        child: _OptionWidth(
          child: CatchOptionCard(
            title: 'Curated',
            description: 'Host approves each request before the event.',
            selected: true,
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'disabled-by-null-action',
        child: const _OptionWidth(
          child: CatchOptionCard(
            title: 'Application only',
            description: 'Visible but not currently selectable.',
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchSegmentedControl,
  path: '[Core primitives]/Selection',
)
Widget catchSegmentedControlContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchSegmentedControl',
    contractId: 'catch.segmented_control',
    states: const [
      'default',
      'selected',
      'expanded',
      'with-icons',
      'surface-style',
    ],
    children: [
      _StateCard(
        label: 'default / selected',
        child: _SegmentedControlDemo<String>(
          initialValue: 'day',
          segments: const [
            CatchSegment(value: 'day', label: 'Day'),
            CatchSegment(value: 'agenda', label: 'Agenda'),
            CatchSegment(value: 'list', label: 'List'),
          ],
        ),
      ),
      _StateCard(
        label: 'expanded',
        child: const _SegmentedWidth(
          child: _SegmentedControlDemo<String>(
            initialValue: 'hosts',
            expanded: true,
            segments: [
              CatchSegment(value: 'hosts', label: 'Hosts'),
              CatchSegment(value: 'guests', label: 'Guests'),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'with-icons',
        child: _SegmentedControlDemo<String>(
          initialValue: 'grid',
          segments: [
            CatchSegment(
              value: 'grid',
              label: 'Grid',
              icon: CatchIcons.gridViewRounded,
            ),
            CatchSegment(
              value: 'list',
              label: 'List',
              icon: CatchIcons.listRounded,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'surface-style',
        child: const _SegmentedControlDemo<String>(
          initialValue: 'now',
          style: CatchSegmentedControlStyle.surface,
          segments: [
            CatchSegment(value: 'now', label: 'Now'),
            CatchSegment(value: 'later', label: 'Later'),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchSurface,
  path: '[Core primitives]/Surfaces',
)
Widget catchSurfaceContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchSurface',
    contractId: 'catch.surface',
    states: const [
      'surface',
      'raised',
      'primary-soft',
      'transparent',
      'tappable',
      'elevated',
      'card',
      'tinted',
      'message',
    ],
    children: [
      _StateCard(
        label: 'surface',
        child: _SurfaceSpec(tone: CatchSurfaceTone.surface),
      ),
      _StateCard(
        label: 'raised',
        child: _SurfaceSpec(tone: CatchSurfaceTone.raised),
      ),
      _StateCard(
        label: 'primary-soft',
        child: _SurfaceSpec(tone: CatchSurfaceTone.primarySoft),
      ),
      _StateCard(
        label: 'transparent',
        child: _PhotoLikePanel(
          child: _SurfaceSpec(
            tone: CatchSurfaceTone.transparent,
            borderColor: t.surface,
            foregroundColor: t.surface,
          ),
        ),
      ),
      _StateCard(
        label: 'tappable',
        child: _SurfaceSpec(tone: CatchSurfaceTone.surface, onTap: _noop),
      ),
      _StateCard(
        label: 'elevated',
        child: const _InlineWrap(
          children: [
            _SurfaceSpec(label: 'Card', elevation: CatchSurfaceElevation.card),
            _SurfaceSpec(
              label: 'Raised',
              elevation: CatchSurfaceElevation.raised,
            ),
            _SurfaceSpec(
              label: 'Overlay',
              elevation: CatchSurfaceElevation.overlay,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'card',
        child: CatchSurface.card(
          width: 220,
          child: Text(
            'Default bounded group',
            style: CatchTextStyles.bodyM(context),
          ),
        ),
      ),
      _StateCard(
        label: 'tinted',
        child: CatchSurface.tinted(
          child: Text(
            'Only attendees can see this matching detail.',
            style: CatchTextStyles.bodyS(context),
          ),
        ),
      ),
      _StateCard(
        label: 'message',
        child: Column(
          children: const [
            CatchSurface.message(
              title: 'Host tip',
              message: 'Keep the first message short and specific.',
            ),
            SizedBox(height: CatchSpacing.s3),
            CatchSurface.message(
              message: 'This event is nearly full.',
              messageTone: CatchSurfaceMessageTone.warning,
            ),
            SizedBox(height: CatchSpacing.s3),
            CatchSurface.message(
              message: 'Payment details are encrypted.',
              messageTone: CatchSurfaceMessageTone.success,
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchMiniBarChart,
  path: '[Core primitives]/Data display',
)
Widget catchMiniBarChartContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchMiniBarChart',
    contractId: 'catch.mini_bar_chart',
    states: const [
      'default',
      'empty',
      'zero-values',
      'color-override',
      'semantic-label',
    ],
    children: [
      const _StateCard(
        label: 'default',
        child: CatchMiniBarChart(values: [2, 6, 3, 8, 5, 9, 7]),
      ),
      const _StateCard(
        label: 'empty',
        child: CatchMiniBarChart(values: []),
      ),
      const _StateCard(
        label: 'zero-values',
        child: CatchMiniBarChart(values: [0, 0, 0, 0], maxValue: 10),
      ),
      _StateCard(
        label: 'color-override',
        child: CatchMiniBarChart(
          values: const [1, 3, 6, 4, 8],
          filledColor: t.primary,
          emptyColor: t.primarySoft,
          backgroundColor: t.raised,
          borderColor: t.primary.withValues(alpha: CatchOpacity.mutedBorder),
        ),
      ),
      const _StateCard(
        label: 'semantic-label',
        child: CatchMiniBarChart(
          values: [4, 5, 7, 8, 6],
          semanticLabel: 'Weekly attendance trend',
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchMetricStrip,
  path: '[Core primitives]/Data display',
)
Widget catchMetricStripContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchMetricStrip',
    contractId: 'catch.metric_strip',
    states: const [
      'default',
      'with-unit',
      'four-items',
      'long-copy',
      'surface-overrides',
    ],
    children: [
      _StateCard(
        label: 'default',
        child: CatchMetricStrip(
          items: const [
            CatchMetricStripItem(value: '24', label: 'going'),
            CatchMetricStripItem(value: '4', label: 'left'),
            CatchMetricStripItem(value: '8:30', label: 'starts'),
          ],
        ),
      ),
      _StateCard(
        label: 'with-unit',
        child: CatchMetricStrip(
          items: const [
            CatchMetricStripItem(value: '2.4', unit: 'km', label: 'away'),
            CatchMetricStripItem(value: '12', unit: 'min', label: 'walk'),
            CatchMetricStripItem(value: '6', unit: 'pm', label: 'meet'),
          ],
        ),
      ),
      _StateCard(
        label: 'four-items',
        child: CatchMetricStrip(
          items: const [
            CatchMetricStripItem(value: '126', label: 'members'),
            CatchMetricStripItem(value: '4.8', label: 'rating'),
            CatchMetricStripItem(value: '12', label: 'reviews'),
            CatchMetricStripItem(value: 'JAN 25', label: 'est.'),
          ],
        ),
      ),
      _StateCard(
        label: 'long-copy',
        child: SizedBox(
          width: 260,
          child: CatchMetricStrip(
            items: const [
              CatchMetricStripItem(
                value: '128',
                label: 'confirmed members attending',
              ),
              CatchMetricStripItem(value: '98%', label: 'historical show rate'),
              CatchMetricStripItem(
                value: '12',
                label: 'waitlist seats remaining',
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'surface-overrides',
        child: CatchMetricStrip(
          backgroundColor: t.primary,
          borderColor: t.primary,
          dividerColor: t.primaryInk.withValues(alpha: 0.32),
          valueColor: t.primaryInk,
          unitColor: t.primaryInk.withValues(alpha: 0.78),
          labelColor: t.primaryInk.withValues(alpha: 0.72),
          items: const [
            CatchMetricStripItem(value: '8', label: 'matched'),
            CatchMetricStripItem(value: '2', label: 'pending'),
            CatchMetricStripItem(value: '1', label: 'open'),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchTopBar,
  path: '[Core primitives]/Navigation',
)
Widget catchTopBarContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchTopBar',
    contractId: 'catch.top_bar',
    states: const [
      'compact',
      'large',
      'with-leading',
      'with-action-icon',
      'with-action-text',
      'with-search',
      'conversation-title',
      'surface',
      'bordered',
    ],
    children: [
      _StateCard(
        label: 'compact',
        child: const _TopBarFrame(
          child: CatchTopBar(title: 'Events', subtitle: 'Tonight nearby'),
        ),
      ),
      _StateCard(
        label: 'large',
        child: const _TopBarFrame(
          child: CatchTopBar(
            kicker: 'HOST MODE',
            title: 'Upcoming events',
            subtitle: 'Review requests and keep the room balanced.',
          ),
        ),
      ),
      _StateCard(
        label: 'with-leading',
        child: _TopBarFrame(
          child: CatchTopBar(
            title: 'Event details',
            leadingType: CatchTopBarLeading.back,
            onBack: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'with-action-icon',
        child: _TopBarFrame(
          child: CatchTopBar(
            title: 'Chats',
            actionIcon: CatchIcons.moreHorizRounded,
            actionLabel: 'More',
            onAction: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'with-action-text',
        child: _TopBarFrame(
          child: CatchTopBar(
            title: 'Preview',
            actionText: 'Done',
            onAction: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'with-search',
        description: 'Use the search icon to review the expanded search state.',
        child: _TopBarFrame(
          child: CatchTopBar(
            title: 'Clubs',
            searchValue: 'run',
            searchPlaceholder: 'Search clubs',
            onSearch: _ignoreString,
          ),
        ),
      ),
      _StateCard(
        label: 'conversation-title',
        child: _TopBarFrame(
          child: CatchTopBar.identity(
            identityName: 'Taylor from Sunday Social',
            identityPhotoUrl: null,
            onIdentityTap: _noop,
            surface: true,
            border: true,
            actions: [
              CatchTopBarMenuAction<String>(
                tooltip: 'Chat actions',
                onSelected: _ignoreString,
                items: [
                  CatchActionMenuItem(
                    value: 'share',
                    label: 'Share card',
                    icon: CatchIcons.platformShare(
                      platform: Theme.of(context).platform,
                    ),
                  ),
                  CatchActionMenuItem(
                    value: 'report',
                    label: 'Report',
                    icon: CatchIcons.flagOutlined,
                  ),
                  CatchActionMenuItem(
                    value: 'block',
                    label: 'Block',
                    icon: CatchIcons.blockRounded,
                    isDestructive: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'surface',
        child: const _TopBarFrame(
          child: CatchTopBar(title: 'Surface', surface: true),
        ),
      ),
      _StateCard(
        label: 'bordered',
        child: const _TopBarFrame(
          child: CatchTopBar(title: 'Bordered', border: true),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchCollapsedSliverTitle,
  path: '[Core primitives]/Navigation',
)
Widget catchCollapsedSliverTitleContractStates(BuildContext context) {
  return const _ContractScreen(
    title: 'CatchCollapsedSliverTitle',
    contractId: 'catch.top_bar.collapsed_sliver_title',
    states: ['collapsed', 'mid-scroll', 'expanded', 'no-settings'],
    children: [
      _StateCard(
        label: 'collapsed',
        child: _CollapsedTitleFrame(title: 'Sundowner 5K', currentExtent: 56),
      ),
      _StateCard(
        label: 'mid-scroll',
        child: _CollapsedTitleFrame(title: 'Sundowner 5K', currentExtent: 72),
      ),
      _StateCard(
        label: 'expanded',
        child: _CollapsedTitleFrame(title: 'Sundowner 5K', currentExtent: 160),
      ),
      _StateCard(
        label: 'no-settings',
        child: _CollapsedTitleFrame(
          title: 'Standalone preview title',
          currentExtent: null,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchPrivacyBadge,
  path: '[Core primitives]/Status',
)
Widget catchPrivacyBadgeContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchPrivacyBadge',
    contractId: 'catch.privacy_badge',
    states: const ['private-to-you', 'catch-private', 'host-visible'],
    children: [
      _StateCard(label: 'private-to-you', child: CatchPrivacyBadge()),
      _StateCard(
        label: 'catch-private',
        child: CatchPrivacyBadge(kind: CatchPrivacyBadgeKind.catchPrivate),
      ),
      _StateCard(
        label: 'host-visible',
        child: CatchPrivacyBadge(kind: CatchPrivacyBadgeKind.host),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchJourneySteps,
  path: '[Core primitives]/Sections',
)
Widget catchJourneyStepsContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchJourneySteps',
    contractId: 'catch.journey_steps',
    states: const ['numbered-trace', 'titles-only', 'accented', 'long-copy'],
    children: [
      const _StateCard(
        label: 'numbered-trace',
        child: CatchJourneySteps(
          steps: [
            CatchJourneyStep(
              title: 'Pick your room',
              body: 'Choose the event format and guest count.',
            ),
            CatchJourneyStep(
              title: 'Confirm the guest list',
              body: 'Review attendance, private access, and reminders.',
            ),
            CatchJourneyStep(
              title: 'Host the moment',
              body: 'Use check-in and post-event tools from the same flow.',
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'titles-only',
        child: CatchJourneySteps(
          accent: t.success,
          steps: const [
            CatchJourneyStep(title: 'Arrive'),
            CatchJourneyStep(title: 'Check in'),
            CatchJourneyStep(title: 'Start matching'),
          ],
        ),
      ),
      _StateCard(
        label: 'accented',
        child: CatchJourneySteps(
          accent: t.like,
          steps: const [
            CatchJourneyStep(
              title: 'Open requests',
              body: 'Let the host approve a balanced room.',
            ),
            CatchJourneyStep(
              title: 'Send reminders',
              body: 'Guests receive the final timing and arrival notes.',
            ),
          ],
        ),
      ),
      const _StateCard(
        label: 'long-copy',
        child: SizedBox(
          width: 360,
          child: CatchJourneySteps(
            steps: [
              CatchJourneyStep(
                title:
                    'A longer step title that should wrap without pushing the trace out of alignment',
                body:
                    'Long supporting copy stays in the content column while the numbered rail keeps a stable width.',
              ),
              CatchJourneyStep(
                title: 'A concise final step',
                body: 'The trace ends without a dangling connector.',
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchScreenBody,
  path: '[Core primitives]/Sections',
)
Widget catchScreenBodyContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchScreenBody',
    contractId: 'catch.screen_body',
    states: const [
      'scrolling-gutter',
      'non-scroll',
      'no-gutter',
      'custom-padding',
    ],
    children: [
      _StateCard(
        label: 'scrolling-gutter',
        child: _BodyFrame(
          child: CatchScreenBody(
            child: CatchSectionList(
              gap: CatchGaps.section,
              children: const [
                _BodySpec(label: 'Top section'),
                _BodySpec(label: 'Scrollable body content'),
                _BodySpec(label: 'Bottom padding remains tokenized'),
              ],
            ),
          ),
        ),
      ),
      const _StateCard(
        label: 'non-scroll',
        child: _BodyFrame(
          child: CatchScreenBody(
            scrollable: false,
            child: _BodySpec(label: 'Static body with standard gutter'),
          ),
        ),
      ),
      const _StateCard(
        label: 'no-gutter',
        child: _BodyFrame(
          child: CatchScreenBody(
            gutter: false,
            scrollable: false,
            pt: 0,
            pb: 0,
            child: _BodySpec(label: 'Embedded body without page gutter'),
          ),
        ),
      ),
      const _StateCard(
        label: 'custom-padding',
        child: _BodyFrame(
          child: CatchScreenBody(
            scrollable: false,
            padding: EdgeInsets.all(CatchSpacing.s4),
            child: _BodySpec(label: 'Body with explicit inset override'),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchSectionStack,
  path: '[Core primitives]/Sections',
)
Widget catchSectionStackContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchSectionStack',
    contractId: 'catch.section_stack',
    states: const [
      'handoff-sections',
      'plain-sections',
      'custom-gap',
      'zero-padding',
    ],
    children: [
      const _StateCard(
        label: 'handoff-sections',
        child: CatchSectionStack(
          padding: EdgeInsets.zero,
          children: [
            CatchSection.divided(
              first: true,
              lead: true,
              title: 'Room',
              count: 2,
              child: _BodySpec(label: 'Lead section keeps no top rule.'),
            ),
            CatchSection.divided(
              title: 'Guests',
              count: 24,
              child: _BodySpec(label: 'Next sections own the divider.'),
            ),
            CatchSection.divided(
              title: 'Follow up',
              child: _BodySpec(label: 'No ad-hoc gaps needed.'),
            ),
          ],
        ),
      ),
      const _StateCard(
        label: 'plain-sections',
        child: CatchSectionStack(
          padding: EdgeInsets.zero,
          children: [
            _BodySpec(label: 'First plain section block'),
            _BodySpec(label: 'Second block follows stack rhythm'),
          ],
        ),
      ),
      const _StateCard(
        label: 'custom-gap',
        child: CatchSectionStack(
          padding: EdgeInsets.zero,
          gap: CatchSpacing.s3,
          children: [
            _BodySpec(label: 'First block'),
            _BodySpec(label: 'Second block with explicit gap'),
          ],
        ),
      ),
      const _StateCard(
        label: 'zero-padding',
        child: CatchSectionStack(
          padding: EdgeInsets.zero,
          children: [
            CatchSection.contained(
              children: [
                CatchField.read(
                  title: 'Nested field',
                  body: 'Section stack can hold contracted primitives.',
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchSectionList,
  path: '[Core primitives]/Sections',
)
Widget catchSectionListContractStates(BuildContext context) {
  return const _ContractScreen(
    title: 'CatchSectionList',
    contractId: 'catch.section_stack.section_list',
    states: ['default-gap', 'zero-gap', 'custom-gap', 'main-min'],
    children: [
      _StateCard(
        label: 'default-gap',
        child: SizedBox(
          width: 360,
          child: CatchSectionList(
            children: [
              _BodySpec(label: 'First semantic section'),
              _BodySpec(label: 'Second semantic section'),
              _BodySpec(label: 'Third semantic section'),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'zero-gap',
        child: SizedBox(
          width: 360,
          child: CatchSectionList(
            gap: 0,
            children: [
              _BodySpec(label: 'A'),
              _BodySpec(label: 'B follows without inserted rhythm'),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'custom-gap',
        child: SizedBox(
          width: 360,
          child: CatchSectionList(
            gap: CatchSpacing.s3,
            children: [
              _BodySpec(label: 'Compact section'),
              _BodySpec(label: 'Compact section'),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'main-min',
        child: SizedBox(
          width: 360,
          child: CatchSectionList(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BodySpec(label: 'Content-sized list'),
              _BodySpec(label: 'No expanded main axis'),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchDetailSliverSectionList,
  path: '[Core primitives]/Sections',
)
Widget catchDetailSliverSectionListContractStates(BuildContext context) {
  return const _ContractScreen(
    title: 'CatchDetailSliverSectionList',
    contractId: 'catch.section_stack.detail_sliver_section_list',
    states: ['detail-gutter', 'section-owned-rhythm', 'custom-gap'],
    children: [
      _StateCard(
        label: 'detail-gutter',
        child: _BodyFrame(
          child: CustomScrollView(
            slivers: [
              CatchDetailSliverSectionList(
                sections: [
                  CatchSection.divided(
                    first: true,
                    lead: true,
                    title: 'Overview',
                    child: _BodySpec(label: 'Detail body starts inset.'),
                  ),
                  CatchSection.divided(
                    title: 'Plan',
                    child: _BodySpec(label: 'Section owns its divider rhythm.'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'custom-gap',
        child: _BodyFrame(
          child: CustomScrollView(
            slivers: [
              CatchDetailSliverSectionList(
                gap: CatchSpacing.s4,
                topPadding: CatchSpacing.s4,
                bottomPadding: CatchSpacing.s4,
                sections: [
                  CatchSection.contained(
                    child: _BodySpec(label: 'Contained card section'),
                  ),
                  CatchSection.plain(
                    title: 'Notes',
                    child: _BodySpec(label: 'Custom sliver gap.'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchRosterTiles,
  path: '[Core primitives]/Host operations',
)
Widget catchRosterTilesContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchRosterTiles',
    contractId: 'catch.roster_tiles',
    states: const ['default', 'selected', 'read-only', 'warning', 'danger'],
    children: [
      _StateCard(
        label: 'default / selected',
        child: CatchRosterTiles(
          selected: 'checked',
          onSelect: _ignoreString,
          items: const [
            CatchRosterTile(id: 'booked', value: '24', label: 'Booked'),
            CatchRosterTile(
              id: 'checked',
              value: '18',
              label: 'Checked',
              tone: CatchBadgeTone.success,
            ),
            CatchRosterTile(
              id: 'waiting',
              value: '5',
              label: 'Waiting',
              tone: CatchBadgeTone.gold,
            ),
          ],
        ),
      ),
      const _StateCard(
        label: 'read-only',
        child: CatchRosterTiles(
          selected: 'all',
          items: [
            CatchRosterTile(id: 'all', value: '31', label: 'All'),
            CatchRosterTile(id: 'vip', value: '4', label: 'VIP'),
            CatchRosterTile(id: 'late', value: '2', label: 'Late'),
          ],
        ),
      ),
      const _StateCard(
        label: 'warning / danger',
        child: CatchRosterTiles(
          selected: 'attention',
          items: [
            CatchRosterTile(
              id: 'attention',
              value: '3',
              label: 'Needs help',
              tone: CatchBadgeTone.warning,
            ),
            CatchRosterTile(
              id: 'declined',
              value: '2',
              label: 'Declined',
              tone: CatchBadgeTone.danger,
            ),
            CatchRosterTile(
              id: 'noshow',
              value: '1',
              label: 'No-show',
              tone: CatchBadgeTone.neutral,
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchRosterRow,
  path: '[Core primitives]/Host operations',
)
Widget catchRosterRowContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchRosterRow',
    contractId: 'catch.roster_row',
    states: const [
      'button-action',
      'decision-action',
      'badge-action',
      'text-action',
      'empty-signal',
      'disabled-action',
      'truncated',
    ],
    children: [
      _StateCard(
        label: 'button-action',
        child: CatchRosterRow(
          person: 'Aanya Rao',
          meta: 'Paid - arrives 7:40 PM',
          signal: 'Checked in',
          tone: CatchBadgeTone.success,
          action: CatchRosterButtonAction(
            label: 'View',
            icon: CatchIcons.eye,
            onPressed: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'decision-action',
        child: CatchRosterRow(
          person: 'Dev Malhotra',
          meta: 'Request to join - first event',
          signal: 'Review',
          tone: CatchBadgeTone.warning,
          action: CatchRosterDecideAction(
            onProfile: _noop,
            onApprove: _noop,
            onDecline: _noop,
          ),
        ),
      ),
      const _StateCard(
        label: 'badge-action',
        child: CatchRosterRow(
          person: 'Kabir Mehta',
          meta: 'Guest invite - +1',
          signal: 'Hosted',
          tone: CatchBadgeTone.gold,
          action: CatchRosterBadgeAction(
            label: 'VIP',
            tone: CatchBadgeTone.gold,
          ),
        ),
      ),
      const _StateCard(
        label: 'text-action',
        child: CatchRosterRow(
          person: 'Mira Shah',
          meta: 'Ticket refunded',
          signal: 'Cancelled',
          tone: CatchBadgeTone.danger,
          action: CatchRosterTextAction('Done'),
        ),
      ),
      const _StateCard(
        label: 'empty-signal',
        child: CatchRosterRow(
          person: 'Noor Khan',
          meta: 'Invite pending',
          action: CatchRosterTextAction('Waiting'),
        ),
      ),
      _StateCard(
        label: 'disabled-action',
        child: CatchRosterRow(
          person: 'Naina Bose',
          meta: 'Reminder already sent',
          signal: 'Pending',
          action: CatchRosterButtonAction(
            label: 'Sent',
            disabled: true,
            onPressed: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'truncated',
        child: SizedBox(
          width: 360,
          child: CatchRosterRow(
            person: 'A very long guest name that should ellipsize cleanly',
            meta: 'VIP invite with a very long arrival note and payment status',
            signal: 'Needs help',
            tone: CatchBadgeTone.warning,
            action: CatchRosterButtonAction(label: 'Open', onPressed: _noop),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchRosterTable,
  path: '[Core primitives]/Host operations',
)
Widget catchRosterTableContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchRosterTable',
    contractId: 'catch.roster_table',
    states: const ['populated', 'empty', 'partial-columns', 'long-copy'],
    children: [
      _StateCard(
        label: 'populated',
        child: CatchRosterTable(
          columns: const ['Guest', 'Signal', 'Action'],
          rows: [
            CatchRosterRow(
              person: 'Aanya Rao',
              meta: 'Paid - checked in 7:42 PM',
              signal: 'Here',
              tone: CatchBadgeTone.success,
              action: CatchRosterButtonAction(
                label: 'Open',
                icon: CatchIcons.eye,
                onPressed: _noop,
              ),
            ),
            CatchRosterRow(
              person: 'Dev Malhotra',
              meta: 'Request to join',
              signal: 'Review',
              tone: CatchBadgeTone.warning,
              action: CatchRosterDecideAction(
                onProfile: _noop,
                onApprove: _noop,
                onDecline: _noop,
              ),
            ),
            const CatchRosterRow(
              person: 'Mira Shah',
              meta: 'Ticket refunded',
              signal: 'Cancelled',
              tone: CatchBadgeTone.danger,
              action: CatchRosterBadgeAction(label: 'Closed'),
            ),
          ],
        ),
      ),
      const _StateCard(
        label: 'empty',
        child: CatchRosterTable(
          columns: ['Guest', 'Signal', 'Action'],
          showEmpty: true,
          emptyTitle: 'No guests in this view',
          emptyMessage:
              'Change the roster filter or wait for guests to join this event.',
        ),
      ),
      const _StateCard(
        label: 'partial-columns',
        child: CatchRosterTable(
          columns: ['Guest', 'Signal'],
          rows: [
            CatchRosterRow(
              person: 'Noor Khan',
              meta: 'Invite pending',
              signal: 'Pending',
              action: CatchRosterTextAction('Waiting'),
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'long-copy',
        child: CatchRosterTable(
          columns: const ['Guest', 'Signal', 'Action'],
          rows: [
            CatchRosterRow(
              person: 'A very long guest name that should ellipsize cleanly',
              meta:
                  'VIP invite with a very long arrival note and payment status',
              signal: 'Needs help',
              tone: CatchBadgeTone.warning,
              action: CatchRosterButtonAction(label: 'Open', onPressed: _noop),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchActivityArt,
  path: '[Core primitives]/Activity',
)
Widget catchActivityArtContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchActivityArt',
    contractId: 'catch.activity_art',
    states: const [
      'default',
      'activity-kind-variants',
      'dim',
      'with-overlay-child',
      'custom-size',
    ],
    children: [
      const _StateCard(
        label: 'default',
        child: CatchActivityArt(activityKind: ActivityKind.socialRun),
      ),
      const _StateCard(
        label: 'activity-kind-variants',
        child: _InlineWrap(
          children: [
            SizedBox(
              width: 180,
              child: CatchActivityArt(
                activityKind: ActivityKind.pickleball,
                height: 96,
              ),
            ),
            SizedBox(
              width: 180,
              child: CatchActivityArt(
                activityKind: ActivityKind.dinner,
                height: 96,
              ),
            ),
          ],
        ),
      ),
      const _StateCard(
        label: 'dim',
        child: CatchActivityArt(activityKind: ActivityKind.pubQuiz, dim: true),
      ),
      _StateCard(
        label: 'with-overlay-child',
        child: CatchActivityArt(
          activityKind: ActivityKind.cycling,
          dim: true,
          child: Padding(
            padding: CatchInsets.content,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: CatchBadge(label: 'Tonight', tone: CatchBadgeTone.gold),
            ),
          ),
        ),
      ),
      const _StateCard(
        label: 'custom-size',
        child: SizedBox(
          width: 280,
          child: CatchActivityArt(
            activityKind: ActivityKind.yoga,
            height: 88,
            radius: CatchRadius.md,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchNetworkImage,
  path: '[Core primitives]/Media',
)
Widget catchNetworkImageContractStates(BuildContext context) {
  return const _ContractScreen(
    title: 'CatchNetworkImage',
    contractId: 'catch.network_image',
    states: ['bundled-asset', 'fitted', 'fallback', 'semantic-label'],
    children: [
      _StateCard(
        label: 'bundled-asset',
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(CatchRadius.md)),
          child: SizedBox(
            width: 128,
            height: 128,
            child: CatchNetworkImage(
              'assets/branding/catch_icon.png',
              fit: BoxFit.contain,
              semanticLabel: 'Catch app icon',
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'fitted',
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(CatchRadius.md)),
          child: SizedBox(
            width: 220,
            height: 124,
            child: CatchNetworkImage(
              'assets/branding/catch_icon.png',
              fit: BoxFit.cover,
              cacheWidth: 440,
              cacheHeight: 248,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'fallback',
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(CatchRadius.md)),
          child: SizedBox(
            width: 220,
            height: 124,
            child: CatchNetworkImage('assets/branding/not-found.png'),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchActivityChip,
  path: '[Core primitives]/Activity',
)
Widget catchActivityChipContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchActivityChip',
    contractId: 'catch.activity_chip',
    states: const ['soft', 'primary', 'tappable', 'custom-label', 'truncated'],
    children: [
      const _StateCard(
        label: 'soft',
        child: CatchActivityChip(activityKind: ActivityKind.socialRun),
      ),
      const _StateCard(
        label: 'primary',
        child: CatchActivityChip(
          activityKind: ActivityKind.pickleball,
          primary: true,
        ),
      ),
      _StateCard(
        label: 'tappable',
        child: CatchActivityChip(
          activityKind: ActivityKind.dinner,
          onTap: _noop,
        ),
      ),
      const _StateCard(
        label: 'custom-label',
        child: CatchActivityChip(
          activityKind: ActivityKind.openActivity,
          label: 'Anything social',
        ),
      ),
      const _StateCard(
        label: 'truncated',
        child: SizedBox(
          width: 160,
          child: CatchActivityChip(
            activityKind: ActivityKind.strengthTraining,
            label: 'Strength training after work',
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchDistanceRing,
  path: '[Core primitives]/Activity',
)
Widget catchDistanceRingContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchDistanceRing',
    contractId: 'catch.distance_ring',
    states: const [
      'ring-only',
      'with-label',
      'tappable-label',
      'custom-size',
      'long-label',
    ],
    children: [
      const _StateCard(label: 'ring-only', child: CatchDistanceRing()),
      const _StateCard(
        label: 'with-label',
        child: CatchDistanceRing(label: '2 km'),
      ),
      _StateCard(
        label: 'tappable-label',
        child: CatchDistanceRing(label: '3 km', onTap: _noop),
      ),
      const _StateCard(
        label: 'custom-size',
        child: CatchDistanceRing(size: 132, label: '5 km'),
      ),
      const _StateCard(
        label: 'long-label',
        child: SizedBox(
          width: 150,
          child: CatchDistanceRing(label: 'within walking distance'),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchCodeInput,
  path: '[Core primitives]/Inputs',
)
Widget catchCodeInputContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchCodeInput',
    contractId: 'catch.code_input',
    states: const [
      'empty',
      'partial',
      'active-caret',
      'complete',
      'custom-length',
      'no-caret',
    ],
    children: const [
      _StateCard(
        label: 'empty',
        child: SizedBox(width: 320, child: CatchCodeInput()),
      ),
      _StateCard(
        label: 'partial',
        child: SizedBox(width: 320, child: CatchCodeInput(value: '482')),
      ),
      _StateCard(
        label: 'active-caret',
        child: SizedBox(
          width: 320,
          child: CatchCodeInput(value: '48', active: 4),
        ),
      ),
      _StateCard(
        label: 'complete',
        child: SizedBox(width: 320, child: CatchCodeInput(value: '482913')),
      ),
      _StateCard(
        label: 'custom-length',
        child: SizedBox(
          width: 240,
          child: CatchCodeInput(length: 4, value: '82'),
        ),
      ),
      _StateCard(
        label: 'no-caret',
        child: SizedBox(
          width: 320,
          child: CatchCodeInput(value: '48', caret: false),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchOptionGroup,
  path: '[Core primitives]/Selection',
)
Widget catchOptionGroupContractStates(BuildContext context) {
  final t = CatchTokens.of(context);
  const options = [
    CatchOption(value: 'all', label: 'All'),
    CatchOption(value: 'going', label: 'Going'),
    CatchOption(value: 'hosting', label: 'Hosting'),
  ];

  return _ContractScreen(
    title: 'CatchOptionGroup',
    contractId: 'catch.option_group',
    states: const [
      'label',
      'mono',
      'selected',
      'disabled',
      'accented',
      'trailing',
      'overflow',
    ],
    children: [
      _StateCard(
        label: 'label',
        child: _FieldWidth(
          child: CatchOptionGroup<String>(
            options: options,
            selected: 'all',
            onChanged: _ignoreString,
          ),
        ),
      ),
      _StateCard(
        label: 'mono',
        child: _FieldWidth(
          child: CatchOptionGroup<String>(
            options: options,
            selected: 'going',
            variant: CatchOptionGroupVariant.mono,
            onChanged: _ignoreString,
          ),
        ),
      ),
      _StateCard(
        label: 'selected',
        child: _FieldWidth(
          child: CatchOptionGroup<String>(
            options: options,
            selected: 'hosting',
            onChanged: _ignoreString,
          ),
        ),
      ),
      const _StateCard(
        label: 'disabled',
        child: _FieldWidth(
          child: CatchOptionGroup<String>(options: options, selected: 'all'),
        ),
      ),
      _StateCard(
        label: 'accented',
        child: _FieldWidth(
          child: CatchOptionGroup<String>(
            options: options,
            selected: 'going',
            accent: t.primary,
            onChanged: _ignoreString,
          ),
        ),
      ),
      _StateCard(
        label: 'trailing',
        child: _FieldWidth(
          child: CatchOptionGroup<String>(
            options: options,
            selected: 'all',
            trailing: const CatchBadge(label: '12'),
            onChanged: _ignoreString,
          ),
        ),
      ),
      _StateCard(
        label: 'overflow',
        child: SizedBox(
          width: 260,
          child: CatchOptionGroup<String>(
            options: const [
              CatchOption(value: 'attending', label: 'Attending tonight'),
              CatchOption(value: 'waitlist', label: 'Waitlist'),
              CatchOption(value: 'declined', label: 'Declined invites'),
            ],
            selected: 'attending',
            onChanged: _ignoreString,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchSearchField,
  path: '[Core primitives]/Inputs',
)
Widget catchSearchFieldContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchSearchField',
    contractId: 'catch.search_field',
    states: const [
      'field-empty',
      'field-filled',
      'focused',
      'disabled',
      'clearable',
      'empty-trailing-action',
      'expanding-collapsed',
      'expanding-expanded',
    ],
    children: [
      const _StateCard(
        label: 'field-empty',
        child: _FieldWidth(child: CatchSearchField()),
      ),
      const _StateCard(
        label: 'field-filled',
        child: _FieldWidth(child: CatchSearchField(value: 'pickleball')),
      ),
      const _StateCard(
        label: 'focused',
        child: _FieldWidth(child: CatchSearchField(autofocus: true)),
      ),
      const _StateCard(
        label: 'disabled',
        child: _FieldWidth(child: CatchSearchField(enabled: false)),
      ),
      const _StateCard(
        label: 'clearable',
        child: _FieldWidth(child: CatchSearchField(value: 'dinner')),
      ),
      _StateCard(
        label: 'empty-trailing-action',
        child: _FieldWidth(
          child: CatchSearchField(
            emptyTrailingIcon: CatchIcons.tuneRounded,
            emptyTrailingTooltip: 'Filters',
            onEmptyTrailingPressed: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'expanding-collapsed',
        child: _FieldWidth(
          child: CatchSearchField(
            mode: CatchSearchFieldMode.expanding,
            expanded: false,
            maxWidth: 420,
            onOpenSearch: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'expanding-expanded',
        child: _FieldWidth(
          child: CatchSearchField(
            mode: CatchSearchFieldMode.expanded,
            value: 'run club',
            maxWidth: 420,
            onChanged: _ignoreString,
            onCloseSearch: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchRangeSlider,
  path: '[Core primitives]/Inputs',
)
Widget catchRangeSliderContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchRangeSlider',
    contractId: 'catch.range_slider',
    states: const [
      'default',
      'with-endpoint-labels',
      'disabled',
      'divided-tickless',
      'semantic-values',
    ],
    children: [
      _StateCard(
        label: 'default',
        child: SizedBox(
          width: 360,
          child: CatchRangeSlider(
            values: const RangeValues(20, 80),
            onChanged: (_) {},
          ),
        ),
      ),
      _StateCard(
        label: 'with-endpoint-labels',
        child: SizedBox(
          width: 360,
          child: CatchRangeSlider(
            min: 1,
            max: 10,
            values: const RangeValues(2, 6),
            minLabel: '1 km',
            maxLabel: '10 km',
            onChanged: (_) {},
          ),
        ),
      ),
      const _StateCard(
        label: 'disabled',
        child: SizedBox(
          width: 360,
          child: CatchRangeSlider(values: RangeValues(25, 75), onChanged: null),
        ),
      ),
      _StateCard(
        label: 'divided-tickless',
        child: SizedBox(
          width: 360,
          child: CatchRangeSlider(
            values: const RangeValues(3, 7),
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (_) {},
          ),
        ),
      ),
      _StateCard(
        label: 'semantic-values',
        child: SizedBox(
          width: 360,
          child: CatchRangeSlider(
            values: const RangeValues(18, 30),
            min: 18,
            max: 60,
            semanticFormatterCallback: (value) => '${value.round()} years',
            onChanged: (_) {},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchToggle,
  path: '[Core primitives]/Inputs',
)
Widget catchToggleContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchToggle',
    contractId: 'catch.toggle',
    states: const ['off', 'on', 'disabled', 'semantic-labelled'],
    children: [
      _StateCard(
        label: 'off',
        child: CatchToggle(value: false, onChanged: (_) {}),
      ),
      _StateCard(
        label: 'on',
        child: CatchToggle(value: true, onChanged: (_) {}),
      ),
      const _StateCard(
        label: 'disabled',
        child: CatchToggle(value: true, onChanged: null),
      ),
      _StateCard(
        label: 'semantic-labelled',
        child: CatchToggle(
          value: true,
          semanticLabel: 'Allow reminders',
          onChanged: (_) {},
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchStatusBar,
  path: '[Core primitives]/Device chrome',
)
Widget catchStatusBarContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchStatusBar',
    contractId: 'catch.status_bar',
    states: const ['light', 'dark', 'surface', 'custom-time'],
    children: const [
      _StateCard(
        label: 'light',
        child: SizedBox(width: 390, child: CatchStatusBar()),
      ),
      _StateCard(
        label: 'dark',
        child: SizedBox(
          width: 390,
          child: CatchStatusBar(tone: CatchStatusBarTone.dark),
        ),
      ),
      _StateCard(
        label: 'surface',
        child: SizedBox(width: 390, child: CatchStatusBar(surface: true)),
      ),
      _StateCard(
        label: 'custom-time',
        child: SizedBox(width: 390, child: CatchStatusBar(time: '7:24')),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchStepHeader,
  path: '[Core primitives]/Navigation',
)
Widget catchStepHeaderContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchStepHeader',
    contractId: 'catch.step_header',
    states: const [
      'with-progress',
      'without-progress',
      'with-back',
      'no-back',
      'custom-trailing',
      'no-gutter',
    ],
    children: [
      _StateCard(
        label: 'with-progress',
        child: _TopBarFrame(
          child: CatchStepHeader(
            title: 'Create event',
            subtitle: 'Set up the room',
            step: 2,
            total: 5,
            onBack: _noop,
          ),
        ),
      ),
      const _StateCard(
        label: 'without-progress',
        child: _TopBarFrame(child: CatchStepHeader(title: 'Preferences')),
      ),
      _StateCard(
        label: 'with-back',
        child: _TopBarFrame(
          child: CatchStepHeader(title: 'Guest list', onBack: _noop),
        ),
      ),
      const _StateCard(
        label: 'no-back',
        child: _TopBarFrame(
          child: CatchStepHeader(title: 'Finished', showBack: false),
        ),
      ),
      const _StateCard(
        label: 'custom-trailing',
        child: _TopBarFrame(
          child: CatchStepHeader(
            title: 'Review',
            trailing: CatchBadge(label: 'DRAFT'),
          ),
        ),
      ),
      const _StateCard(
        label: 'no-gutter',
        child: _TopBarFrame(
          child: CatchStepHeader(title: 'Embedded', gutter: false),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchBottomSheetScaffold,
  path: '[Core primitives]/Sheets and footers',
)
Widget catchSheetContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchSheet',
    contractId: 'catch.sheet',
    states: const [
      'plain',
      'branded',
      'badge',
      'action',
      'keyboard-safe',
      'without-grabber',
    ],
    children: [
      const _StateCard(
        label: 'plain',
        child: CatchBottomSheetScaffold(
          title: 'Invite guests',
          subtitle: 'Share this event with people who fit the format.',
          child: CatchSurface.tinted(child: Text('Invites close at 6 PM.')),
        ),
      ),
      _StateCard(
        label: 'branded',
        child: CatchBottomSheetScaffold(
          glyph: CatchIcons.sparkle,
          title: 'Good fit',
          subtitle: 'Guests will see this before joining.',
          child: Text('Keep it social, specific, and short.'),
        ),
      ),
      const _StateCard(
        label: 'badge',
        child: CatchBottomSheetScaffold(
          title: 'Invite guests',
          badge: 'Host',
          child: Text('Host-only invite controls.'),
        ),
      ),
      _StateCard(
        label: 'action',
        child: CatchBottomSheetScaffold(
          title: 'Invite guests',
          action: CatchButton(
            label: 'Copy invite link',
            fullWidth: true,
            onPressed: _noop,
          ),
          child: const Text('Copy a shareable invite link.'),
        ),
      ),
      const _StateCard(
        label: 'keyboard-safe',
        child: CatchBottomSheetScaffold(
          title: 'Arrival note',
          keyboardSafe: true,
          child: CatchField.input(
            title: 'Note',
            initialValue: 'Meet beside the cafe entrance.',
          ),
        ),
      ),
      const _StateCard(
        label: 'without-grabber',
        child: CatchBottomSheetScaffold(
          title: 'Embedded sheet',
          grabber: false,
          child: Text('Used when a parent already owns the grab handle.'),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchTabDock,
  path: '[Core primitives]/Navigation',
)
Widget catchTabDockContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchTabDock',
    contractId: 'catch.tab_dock',
    states: const [
      'selected',
      'unselected',
      'with-active-icon',
      'with-badge',
      'disabled-readonly',
      'safe-area',
      'radius',
    ],
    children: [
      _StateCard(
        label: 'selected',
        child: SizedBox(
          width: 420,
          child: CatchTabDock<String>(
            items: _contractTabDockItems,
            active: 'explore',
            onChanged: _ignoreString,
          ),
        ),
      ),
      _StateCard(
        label: 'unselected',
        child: SizedBox(
          width: 420,
          child: CatchTabDock<String>(
            items: _contractTabDockItems,
            active: 'clubs',
            onChanged: _ignoreString,
          ),
        ),
      ),
      _StateCard(
        label: 'with-active-icon',
        child: SizedBox(
          width: 420,
          child: CatchTabDock<String>(
            items: _contractTabDockItems,
            active: 'matches',
            onChanged: _ignoreString,
          ),
        ),
      ),
      _StateCard(
        label: 'with-badge',
        child: SizedBox(
          width: 420,
          child: CatchTabDock<String>(
            items: _contractTabDockItems,
            active: 'matches',
            onChanged: _ignoreString,
          ),
        ),
      ),
      _StateCard(
        label: 'disabled-readonly',
        child: SizedBox(
          width: 420,
          child: CatchTabDock<String>(
            items: _contractTabDockItems,
            active: 'explore',
          ),
        ),
      ),
      _StateCard(
        label: 'safe-area',
        child: SizedBox(
          width: 420,
          child: CatchTabDock<String>(
            items: _contractTabDockItems,
            active: 'clubs',
            onChanged: _ignoreString,
          ),
        ),
      ),
      _StateCard(
        label: 'radius',
        child: SizedBox(
          width: 420,
          child: CatchTabDock<String>(
            radius: const BorderRadius.vertical(top: Radius.circular(20)),
            items: _contractTabDockItems,
            active: 'explore',
            onChanged: _ignoreString,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchConfirmDialog,
  path: '[Core primitives]/Dialogs',
)
Widget catchConfirmDialogContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchConfirmDialog',
    contractId: 'catch.confirm_dialog',
    states: const [
      'default',
      'destructive',
      'no-message',
      'two-actions',
      'multi-action-stack',
      'adaptive-material',
    ],
    children: [
      _StateCard(
        label: 'default',
        child: CatchConfirmDialog<bool>(
          title: 'Join this event?',
          message: 'The host will review your request.',
          actions: _contractDialogActions,
        ),
      ),
      _StateCard(
        label: 'destructive',
        child: CatchConfirmDialog<bool>(
          title: 'Leave club?',
          message: 'You will stop receiving member-only updates.',
          actions: const [
            CatchDialogAction(label: 'Cancel', value: false),
            CatchDialogAction(label: 'Leave', value: true, isDestructive: true),
          ],
        ),
      ),
      _StateCard(
        label: 'no-message',
        child: CatchConfirmDialog<bool>(
          title: 'Confirm?',
          message: '',
          actions: _contractDialogActions,
        ),
      ),
      _StateCard(
        label: 'two-actions',
        child: CatchConfirmDialog<bool>(
          title: 'Save changes?',
          message: 'This updates your public event page.',
          actions: _contractDialogActions,
        ),
      ),
      const _StateCard(
        label: 'multi-action-stack',
        child: CatchConfirmDialog<String>(
          title: 'Chat actions',
          message: 'Choose how to handle this conversation.',
          actions: [
            CatchDialogAction(label: 'Share', value: 'share'),
            CatchDialogAction(label: 'Mute', value: 'mute'),
            CatchDialogAction(
              label: 'Block',
              value: 'block',
              isDestructive: true,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'adaptive-material',
        description:
            'Runtime presentation should go through showCatchAdaptiveDialog.',
        child: CatchConfirmDialog<bool>(
          title: 'Material fallback',
          message: 'This is the non-Cupertino dialog body.',
          actions: _contractDialogActions,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchFormDialog,
  path: '[Core primitives]/Dialogs',
)
Widget catchFormDialogContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchFormDialog',
    contractId: 'catch.form_dialog',
    states: const ['short-form', 'multiline-form', 'actions', 'no-actions'],
    children: [
      _StateCard(
        label: 'short-form',
        child: CatchFormDialog(
          title: 'Create invite link',
          actions: [
            CatchButton(
              label: 'Cancel',
              variant: CatchButtonVariant.secondary,
              onPressed: _noop,
            ),
            CatchButton(label: 'Create', onPressed: _noop),
          ],
          child: const CatchField.input(
            title: 'Invite name',
            initialValue: 'Early access friends',
          ),
        ),
      ),
      _StateCard(
        label: 'multiline-form',
        child: CatchFormDialog(
          title: 'Host note',
          actions: [CatchButton(label: 'Save note', onPressed: _noop)],
          child: const CatchField.input(
            title: 'Arrival note',
            initialValue: 'Meet beside the cafe entrance at 7:20 PM.',
            minLines: 3,
            maxLines: 4,
          ),
        ),
      ),
      const _StateCard(
        label: 'no-actions',
        child: CatchFormDialog(
          title: 'Read-only form',
          actions: [],
          child: CatchField.read(title: 'Club', body: 'Bandra Social Run'),
        ),
      ),
    ],
  );
}

Widget catchAdaptivePickerBehaviorStates(BuildContext context) {
  return const CatchAdaptivePickerHarness();
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchCountPill,
  path: '[Core primitives]/Actions',
)
Widget catchCountPillContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchCountPill',
    contractId: 'catch.count_pill',
    states: const [
      'icon-only',
      'label',
      'label-with-icon',
      'with-badge',
      'semantic-label',
      'text-scale-truncation',
    ],
    children: [
      _StateCard(
        label: 'icon-only',
        child: CatchCountPill(icon: CatchIcons.mapOutlined, onPressed: _noop),
      ),
      _StateCard(
        label: 'label',
        child: CatchCountPill(label: '24 places', onPressed: _noop),
      ),
      _StateCard(
        label: 'label-with-icon',
        child: CatchCountPill(
          icon: CatchIcons.tuneRounded,
          label: 'Filters',
          onPressed: _noop,
        ),
      ),
      _StateCard(
        label: 'with-badge',
        child: CatchCountPill(
          icon: CatchIcons.tuneRounded,
          label: 'Filters',
          badge: '3',
          onPressed: _noop,
        ),
      ),
      _StateCard(
        label: 'semantic-label',
        child: CatchCountPill(
          icon: CatchIcons.listRounded,
          semanticLabel: 'Show list view',
          onPressed: _noop,
        ),
      ),
      _StateCard(
        label: 'text-scale-truncation',
        child: SizedBox(
          width: 160,
          child: CatchCountPill(
            icon: CatchIcons.tuneRounded,
            label: 'Very specific active filters',
            badge: '12',
            onPressed: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchPageDots,
  path: '[Core primitives]/Navigation',
)
Widget catchPageDotsContractStates(BuildContext context) {
  return const _ContractScreen(
    title: 'CatchPageDots',
    contractId: 'catch.page_dots',
    states: [
      'first-selected',
      'middle-selected',
      'semantic-label',
      'custom-size',
    ],
    children: [
      _StateCard(
        label: 'first-selected',
        child: CatchPageDots(selectedIndex: 0, itemCount: 4),
      ),
      _StateCard(
        label: 'middle-selected',
        child: CatchPageDots(selectedIndex: 2, itemCount: 4),
      ),
      _StateCard(
        label: 'semantic-label',
        child: CatchPageDots(
          selectedIndex: 1,
          itemCount: 3,
          semanticLabel: 'Page 2 of 3',
        ),
      ),
      _StateCard(
        label: 'custom-size',
        child: CatchPageDots(
          selectedIndex: 1,
          itemCount: 3,
          selectedWidth: 32,
          dotWidth: 8,
          dotHeight: 8,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchClubDock,
  path: '[Core primitives]/Product composites',
)
Widget catchClubDockContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchClubDock',
    contractId: 'catch.club_dock',
    states: const [
      'guest',
      'visitor',
      'visitor-pending',
      'member',
      'member-bell-pending',
      'owner',
    ],
    children: [
      _StateCard(
        label: 'guest',
        child: _DockFrame(
          child: CatchClubDock(
            state: CatchClubDockState.guest,
            activityKind: ActivityKind.socialRun,
            footnote: 'Sign in to request access.',
            onSignIn: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'visitor',
        child: _DockFrame(
          child: CatchClubDock(
            state: CatchClubDockState.visitor,
            activityKind: ActivityKind.pickleball,
            members: 128,
            footnote: 'Requests are approved by the host.',
            onJoin: _noop,
          ),
        ),
      ),
      const _StateCard(
        label: 'visitor-pending',
        child: _DockFrame(
          child: CatchClubDock(
            state: CatchClubDockState.visitor,
            activityKind: ActivityKind.dinner,
            members: 42,
            isJoinLoading: true,
          ),
        ),
      ),
      _StateCard(
        label: 'member',
        child: _DockFrame(
          child: CatchClubDock(
            state: CatchClubDockState.member,
            activityKind: ActivityKind.yoga,
            members: 76,
            footnote: 'You are a member.',
            onBell: _noop,
            onManage: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'member-bell-pending',
        child: _DockFrame(
          child: CatchClubDock(
            state: CatchClubDockState.member,
            activityKind: ActivityKind.socialRun,
            members: 76,
            notificationsEnabled: false,
            isBellLoading: true,
            onBell: _noop,
            onManage: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'owner',
        child: _DockFrame(
          child: CatchClubDock(
            state: CatchClubDockState.owner,
            activityKind: ActivityKind.pubQuiz,
            onManage: _noop,
            onCreate: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchBottomDock,
  path: '[Core primitives]/Product composites',
)
Widget catchBottomDockContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchBottomDock',
    contractId: 'catch.bottom_dock',
    states: const [
      'custom',
      'custom-no-safe-area',
      'cta',
      'cta-leading-content',
      'cta-catch-line',
      'cta-footnote',
      'loading',
      'disabled',
    ],
    children: [
      _StateCard(
        label: 'custom',
        child: _DockFrame(
          child: CatchBottomDock(
            child: CatchButton(label: 'Continue', onPressed: _noop),
          ),
        ),
      ),
      _StateCard(
        label: 'custom-no-safe-area',
        child: _DockFrame(
          child: CatchBottomDock(
            includeSafeArea: false,
            child: CatchButton(label: 'Apply filters', onPressed: _noop),
          ),
        ),
      ),
      _StateCard(
        label: 'cta',
        child: _DockFrame(
          child: CatchBottomDock.cta(label: 'Book your spot', onPressed: _noop),
        ),
      ),
      _StateCard(
        label: 'cta-leading-content',
        child: _DockFrame(
          child: CatchBottomDock.cta(
            label: 'Join waitlist',
            leadingContent: const CatchBadge(label: '4 left'),
            onPressed: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'cta-catch-line',
        child: _DockFrame(
          child: CatchBottomDock.cta(
            label: 'Book free',
            catchLine: 'FREE TO JOIN',
            onPressed: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'cta-footnote',
        child: _DockFrame(
          child: CatchBottomDock.cta(
            label: 'Confirm',
            footnote: 'No charge until the host approves.',
            onPressed: _noop,
          ),
        ),
      ),
      const _StateCard(
        label: 'loading',
        child: _DockFrame(
          child: CatchBottomDock.cta(
            label: 'Saving',
            isLoading: true,
            onPressed: null,
          ),
        ),
      ),
      const _StateCard(
        label: 'disabled',
        child: _DockFrame(
          child: CatchBottomDock.cta(label: 'Sold out', onPressed: null),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchEventCard,
  path: '[Core primitives]/Product composites',
)
Widget catchEventCardContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchEventCard',
    contractId: 'catch.event_card',
    states: const [
      'ticket',
      'ticket-status',
      'spotlight',
      'compact',
      'long-copy',
      'hero-transition',
      'activity-art',
    ],
    children: [
      const _StateCard(
        label: 'ticket',
        child: CatchEventCard.ticket(
          title: 'Sundowner 5K',
          subtitle: 'Marine Drive',
          timeLabel: '7:30 PM',
          countdownLabel: 'Tonight',
          priceLabel: 'Free',
          capacityLabel: '18 going',
          activityKind: ActivityKind.socialRun,
        ),
      ),
      const _StateCard(
        label: 'ticket-status',
        child: CatchEventCard.ticket(
          title: 'Doubles ladder',
          subtitle: 'Versova Padel',
          timeLabel: '9:00 AM',
          countdownLabel: 'Tomorrow',
          priceLabel: '₹900',
          capacityLabel: '4 left',
          activityKind: ActivityKind.padel,
          statusLabel: 'Booked',
        ),
      ),
      const _StateCard(
        label: 'spotlight',
        child: CatchEventCard.spotlight(
          title: 'Trivia without awkward tables',
          supportingLabel: 'The Daily, Bandra',
          timeLabel: '8:00 PM',
          countdownLabel: 'Tuesday',
          priceLabel: '₹600',
          capacityLabel: '12 going',
          activityKind: ActivityKind.pubQuiz,
        ),
      ),
      const _StateCard(
        label: 'compact',
        child: CatchEventCard.compact(
          title: 'Sunday flow',
          subtitle: 'Yoga House',
          timeLabel: '10:00 AM',
          countdownLabel: 'Sun',
          priceLabel: '₹500',
          capacityLabel: '8 left',
          activityKind: ActivityKind.yoga,
        ),
      ),
      const _StateCard(
        label: 'long-copy',
        child: SizedBox(
          width: 320,
          child: CatchEventCard.ticket(
            title: 'A very long event name that should wrap without clipping',
            subtitle: 'A long venue name near the waterfront',
            timeLabel: '7:30 PM',
            countdownLabel: 'This weekend',
            priceLabel: 'Free',
            capacityLabel: '18 going',
            activityKind: ActivityKind.socialRun,
          ),
        ),
      ),
      const _StateCard(
        label: 'hero-transition',
        child: CatchEventCard.spotlight(
          title: 'Dinner at the long table',
          supportingLabel: 'Bandra',
          timeLabel: '8:30 PM',
          countdownLabel: 'Friday',
          priceLabel: '₹1,200',
          capacityLabel: '2 left',
          activityKind: ActivityKind.dinner,
          heroTag: 'contract-event-card',
          visualHeroTag: 'contract-event-card-visual',
        ),
      ),
      const _StateCard(
        label: 'activity-art',
        child: CatchEventCard.compact(
          title: 'Open court',
          subtitle: 'Padel ladder',
          timeLabel: '6:00 PM',
          countdownLabel: 'Today',
          priceLabel: '₹800',
          capacityLabel: '6 left',
          activityKind: ActivityKind.pickleball,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: EventActivityStamp,
  path: '[Core primitives]/Product composites',
)
Widget eventActivityStampContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'EventActivityStamp',
    contractId: 'catch.event_card.activity_stamp',
    states: const ['default', 'custom-size', 'activity-variants'],
    children: [
      _StateCard(
        label: 'default',
        child: EventActivityStamp(
          visual: eventActivityVisual(ActivityKind.socialRun, context: context),
        ),
      ),
      _StateCard(
        label: 'custom-size',
        child: EventActivityStamp(
          visual: eventActivityVisual(ActivityKind.dinner, context: context),
          size: 64,
          iconSize: 30,
        ),
      ),
      _StateCard(
        label: 'activity-variants',
        child: _InlineWrap(
          children: [
            EventActivityStamp(
              visual: eventActivityVisual(
                ActivityKind.socialRun,
                context: context,
              ),
            ),
            EventActivityStamp(
              visual: eventActivityVisual(
                ActivityKind.dinner,
                context: context,
              ),
            ),
            EventActivityStamp(
              visual: eventActivityVisual(
                ActivityKind.pickleball,
                context: context,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: EventHeroSurface,
  path: '[Core primitives]/Product composites',
)
Widget eventHeroSurfaceContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'EventHeroSurface',
    contractId: 'catch.event_card.hero_surface',
    states: const ['wrapper'],
    children: [
      _StateCard(
        label: 'wrapper',
        child: EventHeroSurface(
          tag: 'contract-event-hero-surface',
          child: CatchSurface.card(
            child: Text(
              'Shared ticket Hero wrapper',
              style: CatchTextStyles.bodyM(context),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchGradedImage,
  path: '[Core primitives]/Media',
)
Widget catchGradedImageContractStates(BuildContext context) {
  Widget swatch(Color color) => SizedBox(
    width: 220,
    height: 140,
    child: DecoratedBox(decoration: BoxDecoration(color: color)),
  );

  return _ContractScreen(
    title: 'CatchGradedImage',
    contractId: 'catch.graded_image',
    states: const ['enabled', 'disabled', 'light-image', 'dark-image'],
    children: [
      _StateCard(
        label: 'enabled',
        child: CatchGradedImage(child: swatch(const Color(0xFFE67E45))),
      ),
      _StateCard(
        label: 'disabled',
        child: CatchGradedImage(
          enabled: false,
          child: swatch(const Color(0xFFE67E45)),
        ),
      ),
      _StateCard(
        label: 'light-image',
        child: CatchGradedImage(child: swatch(const Color(0xFFF1EEE6))),
      ),
      _StateCard(
        label: 'dark-image',
        child: CatchGradedImage(child: swatch(CatchTokens.editorialDark)),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchDetailHeroBackdrop,
  path: '[Core primitives]/Media',
)
Widget catchDetailHeroBackdropContractStates(BuildContext context) {
  return const _ContractScreen(
    title: 'CatchDetailHeroBackdrop',
    contractId: 'catch.detail_media',
    states: ['photo', 'fallback-gradient', 'scrim', 'no-scrim'],
    children: [
      _StateCard(
        label: 'photo',
        child: SizedBox(
          width: 340,
          height: 180,
          child: CatchDetailHeroBackdrop(
            imageUrl: 'https://example.invalid/catch-detail-photo.jpg',
            semanticLabel: 'Event photo',
          ),
        ),
      ),
      _StateCard(
        label: 'fallback-gradient',
        child: SizedBox(
          width: 340,
          height: 180,
          child: CatchDetailHeroBackdrop(),
        ),
      ),
      _StateCard(
        label: 'scrim',
        child: SizedBox(
          width: 340,
          height: 180,
          child: CatchDetailHeroBackdrop(showScrim: true),
        ),
      ),
      _StateCard(
        label: 'no-scrim',
        child: SizedBox(
          width: 340,
          height: 180,
          child: CatchDetailHeroBackdrop(showScrim: false),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchActivityMapPin,
  path: '[Core primitives]/Activity',
)
Widget catchActivityMapPinContractStates(BuildContext context) {
  return const _ContractScreen(
    title: 'CatchActivityMapPin',
    contractId: 'catch.activity_map_pin',
    states: ['resting', 'selected', 'selected-label', 'custom-size'],
    children: [
      _StateCard(
        label: 'resting',
        child: CatchActivityMapPin(activityKind: ActivityKind.socialRun),
      ),
      _StateCard(
        label: 'selected',
        child: CatchActivityMapPin(
          activityKind: ActivityKind.pickleball,
          selected: true,
        ),
      ),
      _StateCard(
        label: 'selected-label',
        child: CatchActivityMapPin(
          activityKind: ActivityKind.dinner,
          selected: true,
          label: 'Dinner',
        ),
      ),
      _StateCard(
        label: 'custom-size',
        child: CatchActivityMapPin(
          activityKind: ActivityKind.pubQuiz,
          size: 44,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: QuickActions,
  path: '[Core primitives]/Product composites',
)
Widget quickActionsContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'QuickActions',
    contractId: 'catch.quick_actions',
    states: const [
      'two-actions',
      'disabled-action',
      'payment-confirmation',
      'multi-action-wrap',
      'long-copy',
      'empty',
    ],
    children: [
      _StateCard(
        label: 'two-actions',
        child: SizedBox(
          width: 360,
          child: QuickActions(actions: _contractQuickActions.take(2).toList()),
        ),
      ),
      _StateCard(
        label: 'disabled-action',
        child: SizedBox(
          width: 360,
          child: QuickActions(
            actions: [
              DashboardQuickAction(
                icon: CatchIcons.calendarMonthOutlined,
                label: 'Calendar',
              ),
              DashboardQuickAction(
                icon: CatchIcons.bookmarkBorderRounded,
                label: 'Saved events',
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'payment-confirmation',
        child: SizedBox(
          width: 360,
          child: QuickActions(
            actions: [
              DashboardQuickAction(
                icon: CatchIcons.calendarMonthOutlined,
                label: 'Add to calendar',
                onPressed: _noop,
              ),
              DashboardQuickAction(
                icon: CatchIcons.directionsOutlined,
                label: 'Get directions',
                onPressed: _noop,
              ),
              DashboardQuickAction(
                icon: CatchIcons.platformShare(
                  platform: Theme.of(context).platform,
                ),
                label: 'Invite friend',
                onPressed: _noop,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'multi-action-wrap',
        child: SizedBox(
          width: 360,
          child: QuickActions(actions: _contractQuickActions),
        ),
      ),
      _StateCard(
        label: 'long-copy',
        child: SizedBox(
          width: 260,
          child: QuickActions(
            actions: [
              DashboardQuickAction(
                icon: CatchIcons.calendarMonthOutlined,
                label: 'A very long dashboard action label',
                onPressed: _noop,
              ),
              DashboardQuickAction(
                icon: CatchIcons.bookmarkBorderRounded,
                label: 'Saved events',
                onPressed: _noop,
              ),
            ],
          ),
        ),
      ),
      const _StateCard(
        label: 'empty',
        child: SizedBox(width: 360, child: QuickActions(actions: [])),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchCoverStory,
  path: '[Core primitives]/Product composites',
)
Widget catchCoverStoryContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchCoverStory',
    contractId: 'catch.cover_story',
    states: const [
      'event-cover',
      'brand-cover',
      'with-chrome',
      'with-cta',
      'body-copy',
      'no-ghost-glyph',
    ],
    children: [
      const _StateCard(
        label: 'event-cover',
        child: SizedBox(
          width: 360,
          child: CatchCoverStory(
            activityKind: ActivityKind.socialRun,
            kicker: 'Tonight',
            title: 'Run the bridge before dinner',
            data: '7:30 PM - Free',
            data2: '18 going - 4 left',
          ),
        ),
      ),
      const _StateCard(
        label: 'brand-cover',
        child: SizedBox(
          width: 360,
          child: CatchCoverStory(
            title: 'Find the room where you actually talk',
            body: 'Hosted evenings, clubs, and small-group events.',
            showGhostGlyph: false,
          ),
        ),
      ),
      _StateCard(
        label: 'with-chrome',
        child: SizedBox(
          width: 360,
          child: CatchCoverStory(
            activityKind: ActivityKind.dinner,
            title: 'Supper club after work',
            location: 'Mumbai',
            onLocation: _noop,
            showSearch: true,
            onSearch: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'with-cta',
        child: SizedBox(
          width: 360,
          child: CatchCoverStory(
            activityKind: ActivityKind.pickleball,
            kicker: 'Open court',
            title: 'Meet your next doubles partner',
            cta: 'Join the game',
            onCta: _noop,
          ),
        ),
      ),
      const _StateCard(
        label: 'body-copy',
        child: SizedBox(
          width: 360,
          child: CatchCoverStory(
            activityKind: ActivityKind.pubQuiz,
            title: 'Trivia without the awkward table',
            body: 'Small teams rotate every round so everyone gets a turn.',
          ),
        ),
      ),
      const _StateCard(
        label: 'no-ghost-glyph',
        child: SizedBox(
          width: 360,
          child: CatchCoverStory(
            activityKind: ActivityKind.yoga,
            title: 'Stretch into Sunday',
            showGhostGlyph: false,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchCrossPathsCard,
  path: '[Core primitives]/Product composites',
)
Widget catchCrossPathsCardContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchCrossPathsCard',
    contractId: 'catch.cross_paths_card',
    states: const [
      'postcard',
      'photo-row',
      'no-photo-fallback',
      'with-like',
      'long-copy',
    ],
    children: [
      _StateCard(
        label: 'postcard',
        child: SizedBox(
          width: 420,
          child: CatchCrossPathsCard(
            activityKind: ActivityKind.socialRun,
            kicker: 'Crossed paths',
            quote: 'I am going for coffee after the run.',
            displayName: 'Isha',
            age: 29,
            meta: '2 km away',
            onJoin: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'photo-row',
        child: SizedBox(
          width: 420,
          child: CatchCrossPathsCard(
            activityKind: ActivityKind.dinner,
            variant: CatchCrossPathsVariant.photo,
            quote: 'The host saved two seats at the long table.',
            displayName: 'Maya',
            age: 31,
            meta: 'Tonight',
            onJoin: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'no-photo-fallback',
        child: SizedBox(
          width: 420,
          child: CatchCrossPathsCard(
            activityKind: ActivityKind.pickleball,
            variant: CatchCrossPathsVariant.photo,
            quote: 'Come hit a warm-up set.',
            displayName: 'Naina',
            onJoin: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'with-like',
        child: SizedBox(
          width: 420,
          child: CatchCrossPathsCard(
            activityKind: ActivityKind.pubQuiz,
            quote: 'I need one more teammate for music trivia.',
            displayName: 'Dev',
            onJoin: _noop,
            onLike: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'long-copy',
        child: SizedBox(
          width: 340,
          child: CatchCrossPathsCard(
            activityKind: ActivityKind.yoga,
            quote:
                'I am trying the longer beginner-friendly class before brunch if you want to join the same table afterwards.',
            displayName: 'Aanya',
            age: 28,
            meta: 'Sunday morning near Bandra',
            onJoin: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchPersonAvatar,
  path: '[Core primitives]/People',
)
Widget catchPersonAvatarContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchPersonAvatar',
    contractId: 'catch.person_avatar',
    states: const [
      'photo',
      'fallback-initials',
      'activity-context',
      'activity-dim',
      'ring',
      'status-dot',
      'obscured',
      'square',
      'count',
    ],
    children: [
      const _StateCard(
        label: 'photo',
        child: CatchPersonAvatar(
          size: 56,
          name: 'Aanya Rao',
          imageUrl: 'https://example.invalid/avatar-aanya.jpg',
        ),
      ),
      const _StateCard(
        label: 'fallback-initials',
        child: CatchPersonAvatar(size: 56, name: 'Dev Malhotra'),
      ),
      const _StateCard(
        label: 'activity-context',
        child: CatchPersonAvatar(
          size: 56,
          name: 'Run club',
          initials: 'RC',
          activityKind: ActivityKind.socialRun,
        ),
      ),
      const _StateCard(
        label: 'activity-dim',
        child: CatchPersonAvatar(
          size: 56,
          name: 'Dinner',
          initials: 'DN',
          activityKind: ActivityKind.dinner,
          activityDim: true,
        ),
      ),
      _StateCard(
        label: 'ring',
        child: CatchPersonAvatar(
          size: 64,
          name: 'Mira Shah',
          borderWidth: 3,
          borderColor: t.primary,
        ),
      ),
      const _StateCard(
        label: 'status-dot',
        child: CatchPersonAvatar(
          size: 56,
          name: 'Noor Khan',
          showStatusDot: true,
        ),
      ),
      const _StateCard(
        label: 'obscured',
        child: CatchPersonAvatar(
          size: 56,
          name: 'Private guest',
          obscured: true,
        ),
      ),
      const _StateCard(
        label: 'square',
        child: CatchPersonAvatar(
          size: 56,
          name: 'Host team',
          shape: CatchPersonAvatarShape.square,
        ),
      ),
      const _StateCard(
        label: 'count',
        child: CatchPersonAvatar.count(size: 48, count: 19),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchPersonRow,
  path: '[Core primitives]/Product composites',
)
Widget catchPersonRowChatPreviewContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchPersonRow states',
    contractId: 'catch.person_row',
    states: const [
      'roster',
      'roster-trailing',
      'chat-preview',
      'chat-preview-new',
      'chat-preview-unread',
      'chat-preview-square-avatar',
      'divider',
      'long-copy',
    ],
    children: [
      _StateCard(
        label: 'roster',
        child: _ChatTileFrame(
          child: CatchPersonRow(
            data: const CatchPersonRowData(
              name: 'Aanya Rao',
              metaLine: '5:20 /km · 29',
              contextLine: 'Sundowner 5K',
            ),
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'roster-trailing',
        child: _ChatTileFrame(
          child: CatchPersonRow(
            data: const CatchPersonRowData(
              name: 'Dev Malhotra',
              metaLine: 'Checked in',
              contextLine: 'Versova Padel',
            ),
            trailing: const CatchBadge(
              label: 'Host',
              tone: CatchBadgeTone.gold,
            ),
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'chat-preview',
        child: _ChatTileFrame(
          child: CatchPersonRow(
            data: const CatchPersonRowData(
              name: 'Isha Mehta',
              lastMessage: 'You: See you by the host stand.',
              timestamp: '9m',
            ),
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'chat-preview-new',
        child: _ChatTileFrame(
          child: CatchPersonRow(
            data: const CatchPersonRowData(
              name: 'Isha Mehta',
              lastMessage: 'You matched!',
              timestamp: '2m',
              isFresh: true,
              showFreshDot: true,
            ),
            showFreshBackground: false,
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'chat-preview-unread',
        child: _ChatTileFrame(
          child: CatchPersonRow(
            data: const CatchPersonRowData(
              name: 'Isha Mehta',
              lastMessage: 'I just joined the event.',
              timestamp: '1h',
              unreadCount: 2,
              isFresh: true,
            ),
            showFreshBackground: false,
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'chat-preview-square-avatar',
        child: _ChatTileFrame(
          child: CatchPersonRow(
            data: const CatchPersonRowData(
              name: 'Catch Hosts',
              lastMessage: 'Can I bring a friend?',
              timestamp: '3h',
              unreadCount: 1,
              isFresh: true,
              avatarShape: CatchPersonAvatarShape.square,
            ),
            showFreshBackground: false,
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'divider',
        child: _ChatTileFrame(
          child: CatchPersonRow(
            data: const CatchPersonRowData(
              name: 'Isha Mehta',
              lastMessage: 'You: See you there.',
              timestamp: '1d',
            ),
            divider: true,
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'long-copy',
        child: _ChatTileFrame(
          child: CatchPersonRow(
            data: const CatchPersonRowData(
              name: 'A very long display name that should ellipsize',
              lastMessage:
                  'This is a very long latest message preview that should truncate cleanly inside the inbox row.',
              timestamp: '4d',
            ),
            onTap: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: NotificationRow,
  path: '[Core primitives]/Product composites',
)
Widget notificationRowContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'NotificationRow',
    contractId: 'catch.notification_row',
    states: const [
      'unread',
      'read',
      'with-body',
      'divider',
      'non-navigable',
      'long-copy',
    ],
    children: [
      _StateCard(
        label: 'unread',
        child: _NotificationFrame(
          child: NotificationRow(
            type: ActivityNotificationType.eventReminder,
            title: 'Event starts soon',
            time: '8m',
            body: 'Head to the south gate for check-in.',
            unread: true,
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'read',
        child: _NotificationFrame(
          child: NotificationRow(
            type: ActivityNotificationType.clubUpdate,
            title: 'Run club posted an update',
            time: '2h',
            body: 'Sunday route changed to the waterfront.',
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'with-body',
        child: _NotificationFrame(
          child: NotificationRow(
            type: ActivityNotificationType.match,
            title: 'You matched',
            time: 'now',
            body: 'Start with a specific note about the event.',
            unread: true,
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'divider',
        child: _NotificationFrame(
          child: NotificationRow(
            type: ActivityNotificationType.waitlistPromotion,
            title: 'You are off the waitlist',
            time: '1d',
            divider: true,
            onTap: _noop,
          ),
        ),
      ),
      const _StateCard(
        label: 'non-navigable',
        child: _NotificationFrame(
          child: NotificationRow(
            type: ActivityNotificationType.eventCancelled,
            title: 'Event cancelled',
            time: '3d',
            body: 'No action is available for this update.',
          ),
        ),
      ),
      _StateCard(
        label: 'long-copy',
        child: _NotificationFrame(
          child: NotificationRow(
            type: ActivityNotificationType.eventUpdated,
            title:
                'A very long notification title that should wrap across lines',
            time: '11:42',
            body:
                'A long notification body should remain readable and avoid pushing the timestamp out of the row.',
            unread: true,
            onTap: _noop,
          ),
        ),
      ),
    ],
  );
}

void _noop() {}

void _ignoreString(String value) {}

final _contractTabDockItems = [
  CatchTabDockItem<String>(
    id: 'explore',
    icon: CatchIcons.homeOutlined,
    activeIcon: CatchIcons.homeRounded,
    label: 'Explore',
  ),
  CatchTabDockItem<String>(
    id: 'clubs',
    icon: CatchIcons.groupsOutlined,
    activeIcon: CatchIcons.groupsRounded,
    label: 'Clubs',
  ),
  CatchTabDockItem<String>(
    id: 'matches',
    icon: CatchIcons.chatBubbleOutlineRounded,
    activeIcon: CatchIcons.chatBubbleRounded,
    label: 'Chats',
    badgeCount: 3,
  ),
];

const _contractDialogActions = [
  CatchDialogAction(label: 'Cancel', value: false),
  CatchDialogAction(label: 'Confirm', value: true, isDefault: true),
];

final _contractQuickActions = [
  DashboardQuickAction(
    icon: CatchIcons.calendarMonthOutlined,
    label: 'Calendar',
    onPressed: _noop,
  ),
  DashboardQuickAction(
    icon: CatchIcons.bookmarkBorderRounded,
    label: 'Saved events',
    onPressed: _noop,
  ),
  DashboardQuickAction(
    icon: CatchIcons.groupAddOutlined,
    label: 'Invite friends',
    onPressed: _noop,
  ),
  DashboardQuickAction(
    icon: CatchIcons.tuneRounded,
    label: 'Preferences',
    onPressed: _noop,
  ),
];

class CatchAdaptivePickerHarness extends StatefulWidget {
  const CatchAdaptivePickerHarness({super.key});

  @override
  State<CatchAdaptivePickerHarness> createState() =>
      _CatchAdaptivePickerHarnessState();
}

class _CatchAdaptivePickerHarnessState
    extends State<CatchAdaptivePickerHarness> {
  DateTime? _selectedDate = DateTime(2026, 6, 26);
  TimeOfDay? _selectedTime = const TimeOfDay(hour: 19, minute: 30);

  @override
  Widget build(BuildContext context) {
    final date = _selectedDate;
    final time = _selectedTime;

    return _BehaviorScreen(
      title: 'CatchAdaptivePicker behavior',
      behaviorId: 'catch.adaptive_picker.behavior',
      states: const ['date-picker', 'time-picker', 'public-api'],
      children: [
        _StateCard(
          label: 'launchers',
          description:
              'Uses showCatchDatePicker and showCatchTimePicker; Cupertino sheet rendering still depends on the runtime platform.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InlineWrap(
                children: [
                  CatchButton(
                    label: 'Choose date',
                    onPressed: () => _pickDate(context),
                  ),
                  CatchButton(
                    label: 'Choose time',
                    variant: CatchButtonVariant.secondary,
                    onPressed: () => _pickTime(context),
                  ),
                ],
              ),
              const SizedBox(height: CatchSpacing.s4),
              CatchSection.contained(
                children: [
                  CatchField.read(
                    title: 'Date',
                    body: date == null
                        ? 'No date selected'
                        : MaterialLocalizations.of(
                            context,
                          ).formatShortDate(date),
                  ),
                  CatchField.read(
                    title: 'Time',
                    body: time == null
                        ? 'No time selected'
                        : time.format(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final result = await showCatchDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2026, 6, 26),
      firstDate: DateTime(2026),
      lastDate: DateTime(2026, 12, 31),
      title: 'Event date',
    );
    if (!mounted || result == null) return;
    setState(() => _selectedDate = result);
  }

  Future<void> _pickTime(BuildContext context) async {
    final result = await showCatchTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 19, minute: 30),
      title: 'Event time',
    );
    if (!mounted || result == null) return;
    setState(() => _selectedTime = result);
  }
}

class _BehaviorScreen extends StatelessWidget {
  const _BehaviorScreen({
    required this.title,
    required this.behaviorId,
    required this.states,
    required this.children,
  });

  final String title;
  final String behaviorId;
  final List<String> states;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return ColoredBox(
      color: t.bg,
      child: SingleChildScrollView(
        padding: CatchInsets.pageBodyRelaxed,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatchBadge(label: behaviorId, uppercase: true),
                const SizedBox(height: CatchSpacing.s3),
                Text(title, style: CatchTextStyles.headlineS(context)),
                const SizedBox(height: CatchSpacing.s3),
                _InlineWrap(
                  children: [
                    for (final state in states)
                      CatchBadge(
                        label: state,
                        size: CatchBadgeSize.md,
                        tone: CatchBadgeTone.neutral,
                      ),
                  ],
                ),
                const SizedBox(height: CatchSpacing.s6),
                ...children.map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(bottom: CatchSpacing.s4),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DockFrame extends StatelessWidget {
  const _DockFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 430, child: child);
  }
}

class _ChatTileFrame extends StatelessWidget {
  const _ChatTileFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      width: 420,
      tone: CatchSurfaceTone.surface,
      borderColor: t.line,
      padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s4),
      child: child,
    );
  }
}

class _NotificationFrame extends StatelessWidget {
  const _NotificationFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      width: 420,
      tone: CatchSurfaceTone.surface,
      borderColor: t.line,
      padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s4),
      child: child,
    );
  }
}

class _ContractScreen extends StatelessWidget {
  const _ContractScreen({
    required this.title,
    required this.contractId,
    required this.states,
    required this.children,
  });

  final String title;
  final String contractId;
  final List<String> states;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return ColoredBox(
      color: t.bg,
      child: SingleChildScrollView(
        padding: CatchInsets.pageBodyRelaxed,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatchBadge(label: contractId, uppercase: true),
                const SizedBox(height: CatchSpacing.s3),
                Text(title, style: CatchTextStyles.headlineS(context)),
                const SizedBox(height: CatchSpacing.s3),
                _InlineWrap(
                  children: [
                    for (final state in states)
                      CatchBadge(
                        label: state,
                        size: CatchBadgeSize.md,
                        tone: CatchBadgeTone.neutral,
                      ),
                  ],
                ),
                const SizedBox(height: CatchSpacing.s6),
                ...children.map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(bottom: CatchSpacing.s4),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.label,
    required this.child,
    this.description,
  });

  final String label;
  final String? description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      tone: CatchSurfaceTone.surface,
      borderColor: t.line,
      radius: CatchRadius.lg,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CatchBadge(label: label, uppercase: true),
              if (description != null) ...[
                const SizedBox(width: CatchSpacing.s3),
                Expanded(
                  child: Text(
                    description!,
                    style: CatchTextStyles.bodyS(context, color: t.ink2),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: CatchSpacing.s4),
          child,
        ],
      ),
    );
  }
}

class _CatchFieldStatePreview extends StatelessWidget {
  const _CatchFieldStatePreview({
    required this.label,
    required this.child,
    this.description,
  });

  final String label;
  final Widget child;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CatchBadge(label: label, uppercase: true),
            if (description != null) ...[
              const SizedBox(width: CatchSpacing.s3),
              Expanded(
                child: Text(
                  description!,
                  style: CatchTextStyles.bodyS(context, color: t.ink2),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: CatchSpacing.s3),
        _FieldWidth(child: child),
      ],
    );
  }
}

class _InlineWrap extends StatelessWidget {
  const _InlineWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s3,
      runSpacing: CatchSpacing.s3,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

class _FieldWidth extends StatelessWidget {
  const _FieldWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 420, child: child);
  }
}

class _OptionWidth extends StatelessWidget {
  const _OptionWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 360, child: child);
  }
}

class _SegmentedWidth extends StatelessWidget {
  const _SegmentedWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 420, child: child);
  }
}

class _TopBarFrame extends StatelessWidget {
  const _TopBarFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      borderColor: t.line,
      clipBehavior: Clip.antiAlias,
      width: 420,
      child: child,
    );
  }
}

class _CollapsedTitleFrame extends StatelessWidget {
  const _CollapsedTitleFrame({
    required this.title,
    required this.currentExtent,
  });

  final String title;
  final double? currentExtent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    Widget titleWidget = CatchCollapsedSliverTitle(title: title);

    final extent = currentExtent;
    if (extent != null) {
      titleWidget = FlexibleSpaceBarSettings(
        toolbarOpacity: 1,
        minExtent: 56,
        maxExtent: 160,
        currentExtent: extent,
        child: titleWidget,
      );
    }

    return CatchSurface(
      width: 360,
      borderColor: t.line,
      padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s4),
      child: SizedBox(
        height: 56,
        child: Align(alignment: Alignment.centerLeft, child: titleWidget),
      ),
    );
  }
}

class _PhotoLikePanel extends StatelessWidget {
  const _PhotoLikePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Container(
      width: 260,
      height: 132,
      padding: CatchInsets.content,
      alignment: Alignment.topRight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            t.like.withValues(alpha: 0.76),
            t.pass.withValues(alpha: 0.68),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(CatchRadius.lg),
      ),
      child: child,
    );
  }
}

class _BodyFrame extends StatelessWidget {
  const _BodyFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Container(
      width: 360,
      height: 360,
      decoration: BoxDecoration(
        color: t.bg,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(CatchRadius.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _BodySpec extends StatelessWidget {
  const _BodySpec({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      tone: CatchSurfaceTone.surface,
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Text(label, style: CatchTextStyles.bodyS(context)),
    );
  }
}

class _SegmentedControlDemo<T> extends StatefulWidget {
  const _SegmentedControlDemo({
    required this.initialValue,
    required this.segments,
    this.expanded = false,
    this.style = CatchSegmentedControlStyle.filled,
  });

  final T initialValue;
  final List<CatchSegment<T>> segments;
  final bool expanded;
  final CatchSegmentedControlStyle style;

  @override
  State<_SegmentedControlDemo<T>> createState() =>
      _SegmentedControlDemoState<T>();
}

class _SegmentedControlDemoState<T> extends State<_SegmentedControlDemo<T>> {
  late T _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant _SegmentedControlDemo<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _value = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CatchSegmentedControl<T>(
      segments: widget.segments,
      selected: _value,
      expanded: widget.expanded,
      style: widget.style,
      onChanged: (value) => setState(() => _value = value),
    );
  }
}

class _ToggleFieldDemo extends StatefulWidget {
  const _ToggleFieldDemo();

  @override
  State<_ToggleFieldDemo> createState() => _ToggleFieldDemoState();
}

class _ToggleFieldDemoState extends State<_ToggleFieldDemo> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return CatchField.toggle(
      title: 'Allow requests',
      body: _enabled ? 'Open' : 'Closed',
      icon: CatchIcons.notificationsOutlined,
      value: _enabled,
      onChanged: (enabled) => setState(() => _enabled = enabled),
    );
  }
}

class _TextEntryFieldDemo extends StatefulWidget {
  const _TextEntryFieldDemo();

  @override
  State<_TextEntryFieldDemo> createState() => _TextEntryFieldDemoState();
}

class _TextEntryFieldDemoState extends State<_TextEntryFieldDemo> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CatchField.input(
      title: 'Public name',
      controller: _controller,
      icon: CatchIcons.personOutlined,
      placeholder: 'Add a public name',
      showClearButton: true,
      onChanged: (_) => setState(() {}),
    );
  }
}

class _SelectErrorFieldDemo extends StatefulWidget {
  const _SelectErrorFieldDemo();

  @override
  State<_SelectErrorFieldDemo> createState() => _SelectErrorFieldDemoState();
}

class _SelectErrorFieldDemoState extends State<_SelectErrorFieldDemo> {
  final _formKey = GlobalKey<FormState>();
  bool _validated = false;

  @override
  Widget build(BuildContext context) {
    if (!_validated) {
      _validated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _formKey.currentState?.validate();
      });
    }

    return Form(
      key: _formKey,
      child: CatchField.select<String>(
        title: 'Activity',
        values: const ['Run', 'Dinner', 'Pickleball'],
        itemLabel: (value) => value,
        prefixIcon: Icon(CatchIcons.eventOutlined),
        validator: (value) => value == null ? 'Choose an activity.' : null,
        onChanged: (_) {},
      ),
    );
  }
}

class _SurfaceSpec extends StatelessWidget {
  const _SurfaceSpec({
    this.label = 'Preview surface',
    this.tone = CatchSurfaceTone.surface,
    this.elevation = CatchSurfaceElevation.none,
    this.borderColor,
    this.foregroundColor,
    this.onTap,
  });

  final String label;
  final CatchSurfaceTone tone;
  final CatchSurfaceElevation elevation;
  final Color? borderColor;
  final Color? foregroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = foregroundColor ?? t.ink;

    return CatchSurface(
      tone: tone,
      elevation: elevation,
      borderColor: borderColor ?? t.line,
      onTap: onTap,
      width: 188,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: CatchTextStyles.titleS(context, color: color)),
          const SizedBox(height: CatchSpacing.s2),
          Text(
            onTap == null ? 'Static panel' : 'Tap target',
            style: CatchTextStyles.bodyS(
              context,
              color: color.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}
