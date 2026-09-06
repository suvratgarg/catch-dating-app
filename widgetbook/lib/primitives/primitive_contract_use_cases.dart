// ignore_for_file: invalid_use_of_internal_member

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_input_bar.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_detail_dock.dart';
import 'package:catch_dating_app/clubs/shared/catch_club_cover.dart';
import 'package:catch_dating_app/clubs/shared/catch_organizer_poster.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_art.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_map_pin.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_picker.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_action.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_detail_hero_backdrop.dart';
import 'package:catch_dating_app/core/widgets/catch_distance_ring.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_event_activity_cards.dart';
import 'package:catch_dating_app/core/widgets/catch_event_thumbnail.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_host_row.dart';
import 'package:catch_dating_app/core/widgets/catch_index_row.dart';
import 'package:catch_dating_app/core/widgets/catch_journey_steps.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_meta_row.dart';
import 'package:catch_dating_app/core/widgets/catch_metric_strip.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/core/widgets/catch_number_stepper.dart';
import 'package:catch_dating_app/core/widgets/catch_option_card.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_otp_code_field.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_person_polaroid.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:catch_dating_app/core/widgets/catch_privacy_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_selection_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_skeletonized.dart';
import 'package:catch_dating_app/core/widgets/catch_startup_loading_screen.dart';
import 'package:catch_dating_app/core/widgets/catch_status_bar.dart';
import 'package:catch_dating_app/core/widgets/catch_status_strip.dart';
import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_bar.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/core/widgets/event_visual_atoms.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/activity_section.dart';
import 'package:catch_dating_app/explore/presentation/widgets/catch_cover_story.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/catch_roster_board.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/locations/shared/catch_map_preview.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../preview_layout_contracts.dart';

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchSectionLabel,
  path: '[Core primitives]/Typography',
)
Widget catchSectionLabelContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchSectionLabel',
    contractId: 'catch.ui_label',
    states: const [
      'eyebrow',
      'metadata-label',
      'with-icon',
      'accented',
      'truncated',
    ],
    children: [
      const _StateCard(
        label: 'eyebrow',
        child: CatchSectionLabel(label: 'How it works'),
      ),
      const _StateCard(
        label: 'metadata-label',
        child: CatchSectionLabel(label: 'Source and freshness'),
      ),
      _StateCard(
        label: 'with-icon',
        child: CatchSectionLabel(
          label: 'Social run format',
          icon: CatchIcons.directionsRunRounded,
        ),
      ),
      _StateCard(
        label: 'accented',
        child: CatchSectionLabel(
          label: 'Needs review',
          icon: CatchIcons.infoOutlineRounded,
          accentColor: t.warning,
        ),
      ),
      const _StateCard(
        label: 'truncated',
        child: SizedBox(
          width: WidgetbookPreviewLayout.compactLabelWidth,
          child: CatchSectionLabel(
            label: 'A deliberately long structural context label',
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchMetaRow,
  path: '[Core primitives]/Metadata',
)
Widget catchMetaRowContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchMetaRow',
    contractId: 'catch.meta_row',
    states: const ['default', 'semantic-icon', 'semantic-label', 'truncated'],
    children: [
      _StateCard(
        label: 'default',
        child: CatchMetaRow(
          icon: CatchIcons.locationOnRounded,
          label: '2.4 km away',
        ),
      ),
      _StateCard(
        label: 'semantic-icon',
        child: CatchMetaRow(
          icon: CatchIcons.directionsRunRounded,
          label: 'Social run',
          color: t.success,
        ),
      ),
      _StateCard(
        label: 'semantic-label',
        child: CatchMetaRow(
          icon: CatchIcons.infoOutlineRounded,
          label: 'Host confirmation required',
          color: t.warning,
          labelColor: t.warning,
        ),
      ),
      _StateCard(
        label: 'truncated',
        child: CatchMetaRow(
          icon: CatchIcons.locationOnRounded,
          label:
              'A deliberately long venue description that demonstrates the single-line truncation contract in the review surface',
        ),
      ),
    ],
  );
}

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
    states: const [
      'metadata',
      'functional',
      'semantic-tones',
      'solid',
      'live',
      'on-dark',
      'privacy',
      'truncated',
      'readable-status',
    ],
    children: [
      const _StateCard(
        label: 'readable-status',
        child: _InlineWrap(
          children: [
            CatchBadge.status(label: 'Regular', tone: CatchBadgeTone.affinity),
            CatchBadge.status(label: 'New', tone: CatchBadgeTone.success),
            CatchBadge.status(label: 'At risk', tone: CatchBadgeTone.warning),
          ],
        ),
      ),
      _StateCard(
        label: 'metadata / sentence case',
        child: _InlineWrap(
          children: const [
            CatchBadge(label: 'Queued'),
            CatchBadge(label: 'Action', size: CatchBadgeSize.action),
          ],
        ),
      ),
      _StateCard(
        label: 'functional / uppercase mono',
        child: const _InlineWrap(
          children: [
            CatchBadge.functional(label: 'Ready', tone: CatchBadgeTone.success),
            CatchBadge.solidStatus(label: 'Owner'),
          ],
        ),
      ),
      _StateCard(
        label: 'semantic-tones',
        child: const _InlineWrap(
          children: [
            CatchBadge(label: 'Brand', tone: CatchBadgeTone.brand),
            CatchBadge(label: 'Success', tone: CatchBadgeTone.success),
            CatchBadge(label: 'Warning', tone: CatchBadgeTone.warning),
            CatchBadge(label: 'Danger', tone: CatchBadgeTone.danger),
            CatchBadge(label: 'Gold', tone: CatchBadgeTone.gold),
          ],
        ),
      ),
      const _StateCard(
        label: 'solid metadata',
        child: CatchBadge.solid(label: '412 members'),
      ),
      const _StateCard(
        label: 'live status',
        child: CatchBadge.live(label: 'Live now'),
      ),
      _StateCard(
        label: 'on-dark metadata / status',
        child: CatchSurface(
          backgroundColor: t.ink,
          borderWidth: 0,
          padding: CatchInsets.content,
          child: _InlineWrap(
            children: [
              CatchBadge.onDark(label: 'Starts in 2 hours'),
              CatchBadge.onDarkStatus(
                label: 'Preview only',
                icon: CatchIcons.visibilityOutlined,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'privacy',
        child: CatchBadge.privacy(
          label: 'Private to you',
          icon: CatchIcons.lockOutline,
        ),
      ),
      _StateCard(
        label: 'truncated',
        child: SizedBox(
          width: WidgetbookPreviewLayout.compactBadgeWidth,
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
  type: CatchCountBadge,
  path: '[Core primitives]/Status',
)
Widget catchCountBadgeContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchCountBadge',
    contractId: 'catch.badge.count_badge',
    states: const [
      'hidden',
      'count',
      '99-boundary',
      'overflow-count',
      'standalone',
    ],
    children: [
      _StateCard(
        label: 'hidden',
        child: CatchCountBadge(
          count: 0,
          child: Icon(CatchIcons.chatBubbleOutlineRounded),
        ),
      ),
      _StateCard(
        label: 'count',
        child: CatchCountBadge(
          count: 7,
          child: Icon(CatchIcons.chatBubbleOutlineRounded),
        ),
      ),
      _StateCard(
        label: '99-boundary',
        child: CatchCountBadge(
          count: 99,
          child: Icon(CatchIcons.notificationsOutlined),
        ),
      ),
      _StateCard(
        label: 'overflow-count',
        child: CatchCountBadge(
          count: 104,
          child: Icon(CatchIcons.notificationsOutlined),
        ),
      ),
      const _StateCard(
        label: 'standalone',
        child: CatchCountBadge.label(count: 12),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchInlineStatus,
  path: '[Core primitives]/Status',
)
Widget catchInlineStatusContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchInlineStatus',
    contractId: 'catch.badge.inline_status',
    states: const ['neutral', 'success', 'warning', 'danger', 'live', 'scaled'],
    children: [
      const _StateCard(
        label: 'semantic tones',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CatchInlineStatus(label: 'Draft saved locally'),
            gapH8,
            CatchInlineStatus(
              label: 'Changes saved',
              tone: CatchInlineStatusTone.success,
            ),
            gapH8,
            CatchInlineStatus(
              label: 'Unsaved changes',
              tone: CatchInlineStatusTone.warning,
            ),
            gapH8,
            CatchInlineStatus(
              label: 'Connection lost',
              tone: CatchInlineStatusTone.danger,
            ),
            gapH8,
            CatchInlineStatus(
              label: 'Updating live',
              tone: CatchInlineStatusTone.live,
            ),
          ],
        ),
      ),
      _StateCard(
        label: '2x text / wrapped copy',
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: const SizedBox(
            width: WidgetbookPreviewLayout.scaledStatusWidth,
            child: CatchInlineStatus(
              label: 'Unsaved changes with longer localized supporting copy',
              tone: CatchInlineStatusTone.warning,
            ),
          ),
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
          height: WidgetbookPreviewLayout.stateViewportHeight,
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
          height: WidgetbookPreviewLayout.routeViewportHeight,
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
          height: WidgetbookPreviewLayout.routeViewportHeight,
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
  type: CatchErrorBody,
  path: '[Core primitives]/Feedback',
)
Widget catchErrorBodyContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchErrorBody',
    contractId: 'catch.error_state.error_body',
    states: const ['full-screen', 'inline', 'compact', 'secondary-action'],
    children: [
      _StateCard(
        label: 'full-screen',
        child: SizedBox(
          height: WidgetbookPreviewLayout.stateViewportHeight,
          child: CatchErrorBody(
            title: 'Unable to load events',
            message: 'Check your connection and try again.',
            onRetry: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'inline',
        child: CatchErrorBody(
          title: 'Section failed',
          message: 'The recommendations rail could not refresh.',
          mode: CatchErrorStateMode.inline,
          onRetry: _noop,
        ),
      ),
      const _StateCard(
        label: 'compact',
        child: CatchErrorBody(
          title: 'Not available',
          message: 'This event is no longer open.',
          mode: CatchErrorStateMode.compact,
        ),
      ),
      _StateCard(
        label: 'secondary-action',
        child: CatchErrorBody(
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
Widget catchSkeletonContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchSkeleton',
    contractId: 'catch.skeleton',
    states: const [
      'card',
      'box',
      'text',
      'text-block',
      'circle',
      'custom',
      'derived-content',
      'list',
      'async-screen',
      'async-sliver',
    ],
    children: [
      _StateCard(
        label: 'card',
        child: CatchSkeleton.card(
          height: WidgetbookPreviewLayout.skeletonCardHeight,
        ),
      ),
      _StateCard(
        label: 'box',
        child: CatchSkeleton.box(
          width: WidgetbookPreviewLayout.skeletonBoxWidth,
          height: CatchSpacing.s5,
          radius: CatchRadius.pill,
        ),
      ),
      _StateCard(
        label: 'text',
        child: CatchSkeleton.text(
          width: WidgetbookPreviewLayout.skeletonTextWidth,
        ),
      ),
      _StateCard(label: 'text-block', child: CatchSkeleton.textBlock(lines: 3)),
      _StateCard(
        label: 'circle',
        child: CatchSkeleton.circle(
          size: WidgetbookPreviewLayout.skeletonCircleExtent,
        ),
      ),
      _StateCard(
        label: 'custom',
        child: CatchSkeleton.custom(
          child: Container(
            height: WidgetbookPreviewLayout.skeletonCustomHeight,
            decoration: BoxDecoration(
              color: CatchTokens.of(context).surface,
              borderRadius: BorderRadius.circular(CatchRadius.pill),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'derived-content',
        child: CatchSkeletonized(
          child: CatchSection.containedFieldRows(
            title: 'Customer details',
            children: const [
              CatchField.read(title: 'Name', body: 'Customer name'),
              CatchField.read(title: 'Mobile number', body: '+919876543210'),
            ],
          ),
        ),
      ),
      const _StateCard(
        label: 'list',
        child: CatchSkeletonList(
          count: 3,
          height: WidgetbookPreviewLayout.skeletonListItemHeight,
        ),
      ),
      const _StateCard(
        label: 'async-screen',
        child: SizedBox(
          height: WidgetbookPreviewLayout.routeViewportHeight,
          child: CatchAsyncScreenLoading(
            count: 2,
            itemHeight: WidgetbookPreviewLayout.skeletonListItemHeight,
          ),
        ),
      ),
      const _StateCard(
        label: 'async-sliver',
        child: SizedBox(
          height: WidgetbookPreviewLayout.routeViewportHeight,
          child: CustomScrollView(
            slivers: [
              CatchAsyncSliverLoading(
                count: 2,
                itemHeight: WidgetbookPreviewLayout.skeletonListItemHeight,
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
  type: CatchLoadingIndicator,
  path: '[Core primitives]/Loading',
)
Widget catchLoadingIndicatorContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchLoadingIndicator',
    contractId: 'catch.loading_indicator',
    states: const ['default', 'small', 'tinted'],
    children: [
      const _StateCard(
        label: 'default',
        child: SizedBox.square(
          dimension: WidgetbookPreviewLayout.loadingIndicatorExtent,
          child: CatchLoadingIndicator(),
        ),
      ),
      const _StateCard(
        label: 'small',
        child: SizedBox.square(
          dimension: WidgetbookPreviewLayout.loadingIndicatorSmallExtent,
          child: CatchLoadingIndicator(
            strokeWidth: CatchStroke.progressIndicator,
          ),
        ),
      ),
      _StateCard(
        label: 'tinted',
        child: SizedBox.square(
          dimension: WidgetbookPreviewLayout.loadingIndicatorExtent,
          child: CatchLoadingIndicator(color: t.primary),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchAsyncValueView,
  path: '[Core primitives]/Loading',
)
Widget catchAsyncValueContractStates(BuildContext context) {
  // Riverpod exposes these combined states to consumers but keeps the
  // constructor helper package-internal.
  final retrying = const AsyncLoading<String>().copyWithPrevious(
    AsyncError<String>(Exception('Earlier attempt failed'), StackTrace.empty),
  );
  final refreshing = const AsyncLoading<String>().copyWithPrevious(
    const AsyncData<String>('Existing data remains visible while refreshing'),
  );
  final staleDataWithError =
      AsyncError<String>(
        Exception('Refresh failed'),
        StackTrace.empty,
      ).copyWithPrevious(
        const AsyncData<String>('Credible stale data remains visible'),
      );

  return _ContractScreen(
    title: 'CatchAsyncValueView',
    contractId: 'catch.async_value',
    states: const [
      'data',
      'initial-loading',
      'retrying',
      'refreshing',
      'stale-data-with-error',
      'terminal-error',
      'skip-loading-on-refresh',
      'custom-builders',
    ],
    children: [
      _StateCard(
        label: 'data',
        child: CatchAsyncValueView<String>(
          value: const AsyncValue.data('3 events ready'),
          builder: (context, value) => CatchSurface.card(child: Text(value)),
        ),
      ),
      _StateCard(
        label: 'initial-loading',
        child: SizedBox(
          height: WidgetbookPreviewLayout.loadingSlotHeight,
          child: CatchAsyncValueView<String>(
            value: const AsyncValue.loading(),
            builder: (context, value) => Text(value),
          ),
        ),
      ),
      _StateCard(
        label: 'retrying',
        child: SizedBox(
          height: WidgetbookPreviewLayout.loadingSlotHeight,
          child: CatchAsyncValueView<String>(
            value: retrying,
            builder: (context, value) => Text(value),
            loadingBuilder: (context) => const CatchInlineStatus(
              label: 'Retrying without replaying the previous error',
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'refreshing',
        child: CatchAsyncValueView<String>(
          value: refreshing,
          builder: (context, value) => CatchSurface.card(child: Text(value)),
        ),
      ),
      _StateCard(
        label: 'stale-data-with-error',
        child: CatchAsyncValueView<String>(
          value: staleDataWithError,
          builder: (context, value) => CatchSurface.card(child: Text(value)),
          skipError: true,
        ),
      ),
      _StateCard(
        label: 'terminal-error',
        child: SizedBox(
          height: WidgetbookPreviewLayout.stateViewportHeight,
          child: CatchAsyncValueView<String>(
            value: AsyncValue.error(
              Exception('Could not load events'),
              StackTrace.current,
            ),
            builder: (context, value) => Text(value),
            onRetry: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'skip-loading-on-refresh',
        child: CatchAsyncValueView<String>(
          value: const AsyncValue.data('Existing data remains visible'),
          builder: (context, value) => CatchSurface.card(child: Text(value)),
          skipLoadingOnRefresh: true,
        ),
      ),
      _StateCard(
        label: 'custom-builders',
        child: CatchAsyncValueView<String>(
          value: const AsyncValue.loading(),
          builder: (context, value) => Text(value),
          loadingBuilder: (context) =>
              const CatchInlineStatus(label: 'Custom loading state'),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchStartupLoadingScreen,
  path: '[Core primitives]/Loading',
)
Widget catchStartupLoadingScreenContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchStartupLoadingScreen',
    contractId: 'catch.startup_loading_screen',
    states: const ['startup', 'safe-area', 'primary-fill', 'bounded-spinner'],
    children: const [
      _StateCard(
        label: 'startup',
        child: SizedBox(
          height: WidgetbookPreviewLayout.startupViewportHeight,
          child: CatchStartupLoadingScreen(),
        ),
      ),
      _StateCard(
        label: 'safe-area',
        child: SizedBox(
          height: WidgetbookPreviewLayout.startupViewportHeight,
          child: CatchStartupLoadingScreen(),
        ),
      ),
      _StateCard(
        label: 'primary-fill',
        child: SizedBox(
          height: WidgetbookPreviewLayout.startupViewportHeight,
          child: CatchStartupLoadingScreen(),
        ),
      ),
      _StateCard(
        label: 'bounded-spinner',
        child: SizedBox(
          height: WidgetbookPreviewLayout.startupViewportHeight,
          child: CatchStartupLoadingScreen(),
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
      'kicker-field-section',
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
      const _StateCard(
        label: 'kicker-field-section',
        child: CatchKicker(
          label: 'About you',
          size: CatchKickerSize.fieldSection,
        ),
      ),
      _StateCard(
        label: 'tinted',
        child: CatchKicker(label: 'Social run format', color: t.primary),
      ),
      const _StateCard(
        label: 'truncated',
        child: SizedBox(
          width: WidgetbookPreviewLayout.kickerTruncationWidth,
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
              width: WidgetbookPreviewLayout.monoLabelTruncationWidth,
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
  type: CatchIndexRow,
  path: '[Core primitives]/Lists',
)
Widget catchIndexRowContractStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _ContractScreen(
    title: 'CatchIndexRow',
    contractId: 'catch.index_row',
    states: const ['default', 'selected', 'leading', 'trailing', 'disabled'],
    children: [
      _StateCard(
        label: 'default',
        child: CatchIndexRow(title: 'Dinner', onTap: _noop),
      ),
      _StateCard(
        label: 'selected with leading and trailing',
        child: CatchIndexRow(
          title: 'Social run',
          selected: true,
          leading: CatchStatusDot(color: t.accent),
          trailing: const Text('12'),
          onTap: _noop,
        ),
      ),
      const _StateCard(
        label: 'disabled',
        child: CatchIndexRow(title: 'Coming soon', onTap: null),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchClubCover,
  path: '[Core primitives]/Media',
)
Widget catchClubCoverContractStates(BuildContext context) {
  final fallbackClub = Club(
    id: 'contract-cover-fallback',
    name: 'Sea Face Social',
    description: 'A social movement club.',
    location: 'Mumbai',
    area: 'Bandra',
    createdAt: DateTime(2026),
  );
  final photoClub = fallbackClub.copyWith(
    id: 'contract-cover-photo',
    imageUrl:
        'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=720&q=80',
  );
  return _ContractScreen(
    title: 'CatchClubCover',
    contractId: 'catch.club_cover',
    states: const ['photo', 'fallback', 'compact', 'error-fallback'],
    children: [
      _StateCard(
        label: 'photo',
        child: SizedBox(
          width: WidgetbookPreviewLayout.clubCoverWidth,
          height: WidgetbookPreviewLayout.clubCoverHeight,
          child: CatchClubCover(club: photoClub),
        ),
      ),
      _StateCard(
        label: 'fallback',
        child: SizedBox(
          width: WidgetbookPreviewLayout.clubCoverWidth,
          height: WidgetbookPreviewLayout.clubCoverHeight,
          child: CatchClubCover(club: fallbackClub),
        ),
      ),
      _StateCard(
        label: 'compact',
        child: SizedBox.square(
          dimension: WidgetbookPreviewLayout.clubCoverCompactExtent,
          child: CatchClubCover(club: fallbackClub, compact: true),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchOrganizerPoster,
  path: '[Core primitives]/Media',
)
Widget catchOrganizerPosterContractStates(BuildContext context) {
  final club = Club(
    id: 'contract-organizer-poster',
    name: 'Sea Face Social',
    description: 'Bombay moves together.',
    location: 'Mumbai',
    area: 'Bandra',
    createdAt: DateTime(2026),
  );
  Widget poster({
    OrganizerPosterLayout layout = OrganizerPosterLayout.editorial,
    OrganizerPosterTreatment treatment = OrganizerPosterTreatment.paper,
  }) {
    return CatchOrganizerPoster(
      media: OrganizerPosterArtwork(club: club),
      kicker: 'Run club · Mumbai',
      title: club.name,
      tagline: club.description,
      meta: 'Every Saturday · 6:30 AM',
      layout: layout,
      treatment: treatment,
    );
  }

  return _ContractScreen(
    title: 'CatchOrganizerPoster',
    contractId: 'catch.organizer_poster',
    states: const [
      'editorial-paper',
      'photo-ink',
      'split-signal',
      'minimal-paper',
      'photo',
      'fallback-artwork',
      'with-footer',
      'long-copy',
    ],
    children: [
      _StateCard(label: 'editorial-paper', child: poster()),
      _StateCard(
        label: 'photo-ink',
        child: poster(
          layout: OrganizerPosterLayout.photo,
          treatment: OrganizerPosterTreatment.ink,
        ),
      ),
      _StateCard(
        label: 'split-signal',
        child: poster(
          layout: OrganizerPosterLayout.split,
          treatment: OrganizerPosterTreatment.signal,
        ),
      ),
      _StateCard(
        label: 'minimal-paper',
        child: poster(layout: OrganizerPosterLayout.minimal),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchPersonPolaroid,
  path: '[Core primitives]/Media',
)
Widget catchPersonPolaroidContractStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _ContractScreen(
    title: 'CatchPersonPolaroid',
    contractId: 'catch.person_polaroid',
    states: const [
      'photo',
      'fallback-artwork',
      'read-only',
      'reactable',
      'long-copy',
      'text-scale',
    ],
    children: [
      _StateCard(
        label: 'read-only',
        child: CatchPersonPolaroid(
          media: ColoredBox(
            color: t.primarySoft,
            child: Icon(
              CatchIcons.personRounded,
              size: CatchSpacing.s16,
              color: t.primary,
            ),
          ),
          kicker: 'Was at · Sundowner 5K',
          name: 'Maya, 29',
          meta: 'Designer · Bandra',
        ),
      ),
      _StateCard(
        label: 'reactable',
        child: CatchPersonPolaroid(
          media: ColoredBox(
            color: t.raised,
            child: Icon(
              CatchIcons.personRounded,
              size: CatchSpacing.s16,
              color: t.ink3,
            ),
          ),
          mediaOverlay: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: CatchInsets.contentDense,
              child: CatchBadge.solid(label: 'LIKE'),
            ),
          ),
          kicker: 'Crossed paths',
          name: 'A long profile name, 31',
          meta: 'Runner · Lower Parel',
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
  type: CatchEmptyStateContent,
  path: '[Core primitives]/Feedback',
)
Widget catchEmptyStateContentContractStates(BuildContext context) {
  final t = CatchTokens.of(context);
  final titleStyle = CatchTextStyles.sectionTitle(context);
  final messageStyle = CatchTextStyles.supporting(context, color: t.ink2);

  return _ContractScreen(
    title: 'CatchEmptyStateContent',
    contractId: 'catch.empty_state.content',
    states: const ['stacked', 'inline', 'with-action'],
    children: [
      _StateCard(
        label: 'stacked',
        child: CatchEmptyStateContent(
          layout: CatchEmptyStateLayout.stacked,
          icon: CatchIcons.eventOutlined,
          title: 'No events yet',
          message: 'Follow a host to see upcoming plans.',
          titleStyle: titleStyle,
          messageStyle: messageStyle,
        ),
      ),
      _StateCard(
        label: 'inline',
        child: CatchEmptyStateContent(
          layout: CatchEmptyStateLayout.inline,
          icon: CatchIcons.search,
          title: 'No matches',
          message: 'Try widening your filters.',
          titleStyle: titleStyle,
          messageStyle: messageStyle,
        ),
      ),
      _StateCard(
        label: 'with-action',
        child: CatchEmptyStateContent(
          layout: CatchEmptyStateLayout.stacked,
          icon: CatchIcons.eventOutlined,
          iconStyle: CatchEmptyStateIconStyle.bubble,
          title: 'No events yet',
          message: 'Follow a host to see upcoming plans.',
          action: CatchButton(label: 'Explore hosts', onPressed: _noop),
          titleStyle: titleStyle,
          messageStyle: messageStyle,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchEmptyStateIcon,
  path: '[Core primitives]/Feedback',
)
Widget catchEmptyStateIconContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchEmptyStateIcon',
    contractId: 'catch.empty_state.icon',
    states: const ['plain', 'bubble', 'sized'],
    children: [
      _StateCard(
        label: 'icon styles',
        child: _InlineWrap(
          children: [
            CatchEmptyStateIcon(
              icon: CatchIcons.eventOutlined,
              style: CatchEmptyStateIconStyle.plain,
            ),
            CatchEmptyStateIcon(
              icon: CatchIcons.group,
              style: CatchEmptyStateIconStyle.bubble,
            ),
            CatchEmptyStateIcon(
              icon: CatchIcons.search,
              style: CatchEmptyStateIconStyle.bubble,
              size: 24,
              containerSize: 56,
            ),
          ],
        ),
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
      'dismissible',
      'arrival-tap-to-open',
      'arrival-swipe-to-dismiss',
      'arrival-reduced-motion',
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
        child: CatchNotice(
          notice: CatchNoticeData(
            id: 'warning',
            title: 'Update paused',
            tone: CatchNoticeTone.warning,
          ),
        ),
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
      _StateCard(
        label: 'arrival-tap-to-open',
        child: CatchNotice(
          notice: CatchNoticeData.arrival(
            id: 'arrival-open',
            title: 'Ananya Rao',
            message: 'I’ll bring two friends next Sunday.',
            onOpen: _noop,
          ),
          onDismiss: _noop,
        ),
      ),
      _StateCard(
        label: 'arrival-swipe-to-dismiss',
        child: CatchNotice(
          notice: CatchNoticeData.arrival(
            id: 'arrival-dismiss',
            title: 'New message',
            message: 'Swipe this notice to dismiss it.',
            onOpen: _noop,
          ),
          onDismiss: _noop,
        ),
      ),
      _StateCard(
        label: 'arrival-reduced-motion',
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: CatchNotice(
            notice: CatchNoticeData.arrival(
              id: 'arrival-reduced-motion',
              title: 'New message',
              message: 'Reduced motion uses the same accessible actions.',
              onOpen: _noop,
            ),
            onDismiss: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchStatusStrip,
  path: '[Core primitives]/Feedback',
)
Widget catchStatusStripContractStates(BuildContext context) {
  final t = CatchTokens.of(context);
  final offline = CatchStatusStripData(
    id: 'offline',
    label: context.l10n.sharedOfflineTitle,
    message: context.l10n.sharedOfflineBody,
    icon: CatchIcons.cloudOffRounded,
    color: t.warning,
  );
  final rehearsal = CatchStatusStripData(
    id: 'rehearsal',
    label: context.l10n.hostEventRehearsalBadge,
    message: context.l10n.hostEventRehearsalSyntheticGuests,
    icon: CatchIcons.groupsOutlined,
    color: t.danger,
    actions: [
      CatchStatusStripAction(
        label: context.l10n.hostEventRehearsalClockPill(time: '5:00 PM'),
        onPressed: _noop,
      ),
      CatchStatusStripAction(
        label: context.l10n.hostEventRehearsalPracticeTools,
        icon: CatchIcons.more,
        onPressed: _noop,
      ),
    ],
  );
  return _ContractScreen(
    title: 'CatchStatusStrip',
    contractId: 'catch.status_strip',
    states: const ['offline', 'rehearsal', 'stacked', 'empty'],
    children: [
      _StateCard(
        label: 'offline',
        child: CatchStatusStrip(statuses: [offline]),
      ),
      _StateCard(
        label: 'rehearsal',
        child: CatchStatusStrip(statuses: [rehearsal]),
      ),
      _StateCard(
        label: 'stacked',
        child: CatchStatusStrip(statuses: [rehearsal, offline]),
      ),
      const _StateCard(
        label: 'empty',
        child: CatchStatusStrip(statuses: []),
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
      'focused',
      'disabled',
      'loading',
      'full-width',
      'with-icon',
      'rounded',
      'large-text',
      'reduced-motion',
      'command',
      'selection',
    ],
    children: [
      _StateCard(
        label: 'selection',
        child: SizedBox(
          width: 132,
          child: CatchButton.selection(
            label: 'Thiruvananthapuram',
            icon: Icon(CatchIcons.locationOnOutlined),
            onPressed: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'command',
        child: CatchButton.command(
          label: 'Sort: Last seen',
          icon: Icon(CatchIcons.expandMoreRounded),
          iconAtEnd: true,
          onPressed: () {},
        ),
      ),
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
        label: 'focused',
        description:
            'Use keyboard traversal to inspect the semantic focus ring.',
        child: CatchButton(label: 'Keyboard focus target', onPressed: _noop),
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
      _StateCard(
        label: 'rounded editorial bar',
        child: CatchButton(
          label: 'Review & publish',
          shape: CatchButtonShape.rounded,
          fullWidth: true,
          onPressed: _noop,
        ),
      ),
      _StateCard(
        label: 'large-text',
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: CatchButton(
            label: 'Review every submitted response',
            fullWidth: true,
            onPressed: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'reduced-motion',
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: CatchButton(label: 'Continue', onPressed: _noop),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchButtonLabel,
  path: '[Core primitives]/Actions',
)
Widget catchButtonLabelContractStates(BuildContext context) {
  final t = CatchTokens.of(context);
  final textStyle = CatchTextStyles.buttonMd(context);

  return _ContractScreen(
    title: 'CatchButtonLabel',
    contractId: 'catch.button.label',
    states: const ['label', 'with-icon', 'full-width'],
    children: [
      _StateCard(
        label: 'label / icon',
        child: _InlineWrap(
          children: [
            CatchButtonLabel(
              label: 'Continue',
              color: t.primary,
              textStyle: textStyle,
            ),
            CatchButtonLabel(
              label: 'Add to calendar',
              color: t.ink,
              icon: Icon(CatchIcons.calendarAdd),
              textStyle: textStyle,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'full-width bounded label',
        child: SizedBox(
          width: WidgetbookPreviewLayout.fullWidthButtonWidth,
          child: CatchButtonLabel(
            label: 'Very long call to action label',
            color: t.primary,
            icon: Icon(CatchIcons.sparkle),
            fullWidth: true,
            textStyle: textStyle,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchButtonLoadingDots,
  path: '[Core primitives]/Actions',
)
Widget catchButtonLoadingDotsContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchButtonLoadingDots',
    contractId: 'catch.button.loading_dots',
    states: const ['primary', 'light'],
    children: [
      _StateCard(
        label: 'dot tones',
        child: _InlineWrap(
          children: [
            CatchButtonLoadingDots(color: t.primary),
            const CatchButtonLoadingDots(color: CatchTokens.editorialWhite),
          ],
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
      'tag',
      'selectable-resting',
      'selectable-selected',
      'selectable-disabled',
      'selectable-focused',
      'selectable-accented',
      'selectable-with-leading',
      'removable',
      'activity-soft',
      'activity-solid',
      'activity-tappable',
      'truncated',
    ],
    children: [
      _StateCard(
        label: 'tag',
        description: 'Passive metadata: neutral, tinted, and icon-leading.',
        child: _InlineWrap(
          children: [
            const CatchChip.tag(label: 'Tonight'),
            CatchChip.tag(
              label: 'Low key',
              tintColor: t.primarySoft,
              inkColor: t.primary,
            ),
            CatchChip.tag(label: 'Weekend', leading: Icon(CatchIcons.weekend)),
          ],
        ),
      ),
      _StateCard(
        label: 'selectable states',
        description: 'Resting, selected, and disabled shown side by side.',
        child: _InlineWrap(
          children: [
            CatchChip.selectable(
              label: 'Resting',
              selected: false,
              onChanged: _ignoreBool,
            ),
            CatchChip.selectable(
              label: 'Selected',
              selected: true,
              onChanged: _ignoreBool,
            ),
            CatchChip.selectable(
              label: 'Disabled',
              selected: false,
              enabled: false,
              onChanged: _ignoreBool,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'selectable options',
        description: 'Optional accent and leading icon stay semantic.',
        child: _InlineWrap(
          children: [
            CatchChip.selectable(
              label: 'Accent',
              selected: true,
              accent: t.like,
              onChanged: _ignoreBool,
            ),
            CatchChip.selectable(
              label: 'With icon',
              selected: false,
              leading: Icon(CatchIcons.favoriteOutlineRounded),
              onChanged: _ignoreBool,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'selectable-focused',
        description:
            'Use keyboard traversal to inspect the semantic focus ring.',
        child: CatchChip.selectable(
          label: 'Keyboard focus target',
          selected: false,
          onChanged: _ignoreBool,
        ),
      ),
      _StateCard(
        label: 'removable',
        description: 'One full-chip removal action; disabled is visibly inert.',
        child: _InlineWrap(
          children: [
            CatchChip.removable(
              label: 'Rooftop',
              leading: Icon(CatchIcons.pinOutlined),
              onRemove: _noop,
            ),
            CatchChip.removable(
              label: 'Disabled',
              enabled: false,
              onRemove: _noop,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'activity emphasis',
        description: 'Soft, solid, and tappable activity identity.',
        child: _InlineWrap(
          children: [
            const CatchChip.activity(activityKind: ActivityKind.socialRun),
            const CatchChip.activity(
              activityKind: ActivityKind.pickleball,
              emphasis: CatchChipEmphasis.solid,
            ),
            CatchChip.activity(activityKind: ActivityKind.dinner, onTap: _noop),
          ],
        ),
      ),
      const _StateCard(
        label: 'truncated',
        description: 'Long labels ellipsize inside constrained hosts.',
        child: _InlineWrap(
          children: [
            SizedBox(
              width: WidgetbookPreviewLayout.passiveChipTruncationWidth,
              child: CatchChip.tag(label: 'A very long passive metadata label'),
            ),
            SizedBox(
              width: WidgetbookPreviewLayout.activityChipTruncationWidth,
              child: CatchChip.activity(
                activityKind: ActivityKind.strengthTraining,
                label: 'Strength training after work',
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
  type: CatchFormFieldOptionalBadge,
  path: '[Core primitives]/Inputs',
)
Widget catchFormFieldOptionalBadgeContractStates(BuildContext context) {
  return const _ContractScreen(
    title: 'CatchFormFieldOptionalBadge',
    contractId: 'catch.field.form_field_label.optional_badge',
    states: ['default', 'error'],
    children: [
      _StateCard(
        label: 'badge states',
        child: _InlineWrap(
          children: [
            CatchFormFieldOptionalBadge(),
            CatchFormFieldOptionalBadge(hasError: true),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchRecordRow,
  path: '[Core primitives]/Content',
)
Widget catchRecordRowContractStates(BuildContext context) => _ContractScreen(
  title: 'CatchRecordRow',
  contractId: 'catch.record_row',
  states: const ['read-only', 'navigable', 'multiline', 'facts'],
  children: [
    _StateCard(
      label: 'facts',
      child: CatchRecordRow(
        title: 'Friday Evening Trivia Night at The Daily Bar',
        icon: CatchIcons.eventAvailable,
        facts: const ['8:00 PM · The Daily Bar', '24 of 30 registered'],
        onTap: _noop,
      ),
    ),
    _StateCard(
      label: 'read-only',
      child: CatchRecordRow(
        title: 'WhatsApp permission',
        description: 'No participant permission is recorded.',
        icon: CatchIcons.verifiedUserOutlined,
      ),
    ),
    _StateCard(
      label: 'navigable',
      child: CatchRecordRow(
        title: 'Sunday Run sign-up',
        metadata: 'Form response · 20 May 2026',
        icon: CatchIcons.descriptionOutlined,
        onTap: _noop,
      ),
    ),
    _StateCard(
      label: 'multiline',
      child: CatchRecordRow(
        title: 'Message received',
        metadata: 'Catch · 18 June 2026',
        description:
            'I’ll bring two friends next week. We would prefer the smaller weekend event, if there is space.',
        icon: CatchIcons.tabChats,
      ),
    ),
  ],
);

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchRowPressSurface,
  path: '[Core primitives]/Inputs',
)
Widget catchRowPressSurfaceContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  Widget previewRow({
    required Widget leading,
    required String title,
    required String body,
    String? trailing,
  }) {
    return SizedBox(
      width: WidgetbookPreviewLayout.standardContractWidth,
      child: CatchRowPressSurface(
        onTap: _noop,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: CatchSpacing.micro14),
          child: Row(
            children: [
              leading,
              gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: CatchTextStyles.fieldRowTitle(context)),
                    gapH4,
                    Text(
                      body,
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                gapW10,
                Text(
                  trailing,
                  style: CatchTextStyles.monoLabelS(context, color: t.ink3),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  return _ContractScreen(
    title: 'CatchRowPressSurface',
    contractId: 'catch.row_press_surface',
    states: const ['field-row', 'chat-row'],
    children: [
      _StateCard(
        label: 'field-row',
        child: previewRow(
          leading: Icon(CatchIcons.notificationsNoneRounded, color: t.ink2),
          title: 'Event starts soon',
          body: 'Your 5 km event starts in about 15 minutes.',
          trailing: '26D',
        ),
      ),
      _StateCard(
        label: 'chat-row',
        child: previewRow(
          leading: const CatchPersonAvatar(name: 'Taylor Kim', size: 48),
          title: 'Taylor Kim',
          body: 'See you at the event',
          trailing: '2M',
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
      'custom-leading',
      'sortable-inline-metadata',
      'content-row-2-3-clamp',
      'value-line',
      'chevron',
      'toggle-on',
      'toggle-off',
      'toggle-helper-badge',
      'control-collapsed',
      'control-open',
      'disclosure-active-pressed',
      'choices-wrapped',
      'choices-clearable',
      'choices-retain-final-selection',
      'choices-derived-summary',
      'choices-explicit-summary',
      'choices-helper-accent',
      'option-cards-explanatory',
      'stepper-open',
      'direct-input-one-tap',
      'direct-input-focused-cursor',
      'read-only-row',
      'editable-row',
      'saving',
      'saved',
      'explicit-save-collapsed',
      'explicit-save-focused',
      'explicit-save-saving',
      'explicit-save-error',
      'editable-empty-at-rest',
      'editable-empty-focused',
      'empty-add-capability-matrix',
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
        label: 'custom-leading',
        description:
            'Caller-owned semantic leading content stays inside canonical field geometry.',
        child: CatchField.nav(
          leading: Semantics(
            label: '27 May',
            excludeSemantics: true,
            child: const SizedBox(
              width: WidgetbookPreviewLayout.fieldLeadingWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [Text('27'), Text('MAY')],
              ),
            ),
          ),
          leadingExtent: 48,
          title: 'Wednesday Evening Run',
          body: '2 attended · 20% full · free',
          emphasis: CatchFieldEmphasis.title,
          onTap: _noop,
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
        label: 'sortable-inline-metadata',
        description:
            'A drag target sits beside a wrapping title with metadata on its own line.',
        child: CatchField.sortable(
          title: 'Why do you want to join?',
          metadata: 'Long text · Required',
          reorderHandle: SizedBox.square(
            dimension: CatchSpacing.s11,
            child: Icon(CatchIcons.dragIndicatorRounded),
          ),
          onTap: _noop,
        ),
      ),
      fieldState(
        label: 'content-row-2-3-clamp',
        description:
            'Dedicated content semantics: 14/600 title (two lines), 13/400 supporting body (three lines), and a 3px gap without changing legacy value rows.',
        child: CatchField.content(
          title: 'Event starts tomorrow near Carter Road Jetty',
          body:
              'Sundowner 5K meets by the promenade before the group heads out together.',
          icon: CatchIcons.notificationsNoneRounded,
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
        description:
            'The trailing affordance uses one caption reserve and stays centered on the value line.',
        child: CatchField.nav(
          title: 'Location',
          body: 'Fort Greene Park',
          icon: CatchIcons.pinOutlined,
          onTap: _noop,
        ),
      ),
      fieldState(label: 'toggle-on', child: const _ToggleFieldDemo()),
      fieldState(
        label: 'toggle-off',
        child: const _ToggleFieldDemo(initialValue: false),
      ),
      fieldState(
        label: 'toggle-helper-badge',
        description:
            'Recommendation metadata stays in the title row while guidance uses the canonical support lane.',
        child: CatchField.toggle(
          title: 'Live guide',
          body: 'Enable the run-of-show companion.',
          helperText: 'You can change this before the event.',
          badgeLabel: 'Recommended',
          badgeTone: CatchBadgeTone.success,
          value: true,
          onChanged: (_) {},
        ),
      ),
      fieldState(
        label: 'control-collapsed',
        description:
            'At rest, the caption uses semantic ink3 and the caret stays centered on the value line with canonical divider clearance.',
        child: const _ChoiceFieldDemo(),
      ),
      fieldState(
        label: 'control-open',
        description:
            'Opening promotes the field-name caption to semantic ink while Optional copy stays ink3; the caret keeps the same value-line center and only rotates.',
        child: const _ChoiceFieldDemo(initiallyOpen: true, isOptional: true),
      ),
      fieldState(
        label: 'disclosure-active-pressed',
        description:
            'The standalone open field holds rounded active chrome. Press and hold its row to verify that pointer-down retains one rounded outline before release.',
        child: const _ChoiceFieldDemo(initiallyOpen: true),
      ),
      fieldState(
        label: 'choices-wrapped',
        description:
            'Selected and unselected chips share the canonical 8px wrap gap.',
        child: const _ChoiceFieldDemo(initiallyOpen: true),
      ),
      fieldState(
        label: 'choices-clearable',
        description:
            'Selection policy allows the final selected value to be removed independently from Optional presentation copy.',
        child: const _ChoiceFieldDemo(
          initiallyOpen: true,
          allowEmptySelection: true,
          initialSelection: {'English'},
        ),
      ),
      fieldState(
        label: 'choices-retain-final-selection',
        description:
            'Required selection policy keeps the final selected value active.',
        child: const _ChoiceFieldDemo(
          initiallyOpen: true,
          initialSelection: {'English'},
        ),
      ),
      fieldState(
        label: 'choices-derived-summary',
        description:
            'Without an explicit body, the primitive derives its summary in source-option order.',
        child: const _ChoiceFieldDemo(initialSelection: {'Marathi', 'English'}),
      ),
      fieldState(
        label: 'choices-explicit-summary',
        description:
            'An explicit body remains available when product copy should override the derived selection summary.',
        child: const _ChoiceFieldDemo(body: 'Three languages selected'),
      ),
      fieldState(
        label: 'choices-helper-accent',
        description:
            'Choice guidance uses the support lane and product-owned option color is forwarded to the canonical selectable chip.',
        child: CatchField.choices<String>(
          title: 'Run format',
          helperText: 'Pick the format guests will see.',
          values: const ['Social', 'Competitive'],
          itemLabel: (value) => value,
          itemAccent: (value) =>
              value == 'Social' ? CatchTokens.of(context).primary : null,
          selected: const {'Social'},
          initiallyOpen: true,
          onSelectionChanged: (_) {},
        ),
      ),
      fieldState(
        label: 'option-cards-explanatory',
        description:
            'Policies with per-option guidance use one full-width title-and-description target per choice instead of chips plus detached selected copy.',
        child: CatchField.optionCards<String>(
          title: 'Admission format',
          values: const ['open', 'request'],
          itemTitle: (value) =>
              value == 'open' ? 'Open capacity' : 'Request to join',
          itemDescription: (value) => value == 'open'
              ? 'Anyone eligible can book until the event reaches capacity.'
              : 'People request a spot and a host approves each booking.',
          selected: 'open',
          initiallyOpen: true,
          onChanged: (_) {},
          icon: CatchIcons.howToRegOutlined,
        ),
      ),
      fieldState(
        label: 'stepper-open',
        description:
            'The 44px repeat targets flank one centered value without a nested tile; the shared open state promotes its caption to semantic ink while its caret remains in the value-line trailing lane.',
        child: const _StepperFieldDemo(),
      ),
      fieldState(
        label: 'direct-input-one-tap',
        description:
            'Tap anywhere in the row once: the native input receives focus and positions its cursor. No edit caret is synthesized.',
        child: const _TextEntryFieldDemo(),
      ),
      fieldState(
        label: 'direct-input-focused-cursor',
        description:
            'Autofocus makes the native insertion cursor deterministic for visual review.',
        child: const _TextEntryFieldDemo(autofocus: true),
      ),
      fieldState(
        label: 'read-only-row',
        description: 'Static profile data never receives an edit chevron.',
        child: CatchField.read(
          title: 'Date of birth',
          body: '16/07/1994 (31 years)',
          icon: CatchIcons.cakeOutlined,
        ),
      ),
      fieldState(
        label: 'editable-row',
        description:
            'Editable rows expose the native text cursor on tap, not a synthesized trailing chevron.',
        child: CatchField.input(
          title: 'Display name',
          initialValue: 'Suvrat',
          icon: CatchIcons.personOutlined,
        ),
      ),
      fieldState(
        label: 'saving',
        description:
            'Auto-save fields without a visible commit bar use one 16px in-flight indicator in the value-line trailing lane.',
        child: CatchField.read(
          title: 'Display name',
          body: 'Suvrat',
          icon: CatchIcons.personOutlined,
          status: CatchFieldStatus.saving,
        ),
      ),
      fieldState(
        label: 'saved',
        description:
            'The value-line trailing lane owns and centers the transient saved tick.',
        child: CatchField.read(
          title: 'Display name',
          body: 'Suvrat',
          icon: CatchIcons.personOutlined,
          status: CatchFieldStatus.saved,
        ),
      ),
      fieldState(
        label: 'explicit-save-collapsed',
        child: const _ExplicitSaveFieldDemo(),
      ),
      fieldState(
        label: 'explicit-save-focused',
        description:
            'The root active label uses semantic ink while answer, counter, secondary action, and commit footer keep one order.',
        child: const _ExplicitSaveFieldDemo(initiallyExpanded: true),
      ),
      fieldState(
        label: 'explicit-save-saving',
        description:
            'The visible commit bar owns the sole 13px saving indicator inside Done; the header keeps its disclosure caret.',
        child: const _ExplicitSaveFieldDemo(
          initiallyExpanded: true,
          isLoading: true,
        ),
      ),
      fieldState(
        label: 'explicit-save-error',
        child: const _ExplicitSaveFieldDemo(
          initiallyExpanded: true,
          error: 'Keep the answer under 300 characters.',
        ),
      ),
      fieldState(
        label: 'editable-empty-at-rest',
        description:
            'One localized Add line replaces the inactive caption while the same native TextField stays mounted.',
        child: const CatchField.input(
          title: 'Public name',
          inputHint: 'e.g. Aanya',
        ),
      ),
      fieldState(
        label: 'editable-empty-focused',
        description:
            'The initiating tap expands the same input, restores its caption, and gives the Add line to the input-only hint.',
        child: const CatchField.input(
          title: 'Public name',
          inputHint: 'e.g. Aanya',
          focused: true,
        ),
      ),
      fieldState(
        label: 'empty-add-capability-matrix',
        description:
            'Empty direct inputs and addable disclosures share one-line Add typography, Optional composition, row height, and leading-slot centering.',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CatchField.input(
              title: 'Job title',
              icon: CatchIcons.workOutline,
              isOptional: true,
            ),
            CatchField.choices<String>(
              title: 'Workout',
              values: const ['Never', 'Often'],
              itemLabel: (value) => value,
              selected: const {},
              onSelectionChanged: (_) {},
              addable: true,
              isOptional: true,
              icon: CatchIcons.fitnessCenterOutlined,
            ),
          ],
        ),
      ),
      fieldState(
        label: 'edit-empty',
        child: const CatchField.input(
          title: 'Name',
          emptyValueText: 'Add a public name',
          inputHint: 'e.g. Aanya',
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
        description:
            'Native text focus uses the same root semantic-ink label state as an open disclosure.',
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
        description:
            'The menu trigger shares the same caption reserve and value-line-centered caret geometry.',
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
  type: CatchFieldContentRow,
  path: '[Core primitives]/Inputs',
)
Widget catchFieldContentRowContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchFieldContentRow',
    contractId: 'catch.field.content_row',
    states: const ['title-body', 'optional', 'empty-body', 'two-three-clamp'],
    children: const [
      _StateCard(
        label: 'title-body',
        child: CatchFieldContentRow(
          title: 'Weekend route update',
          body: 'The start point moved closer to the east gate.',
        ),
      ),
      _StateCard(
        label: 'optional',
        child: CatchFieldContentRow(
          title: 'Race notes',
          body: 'Shared with runners before the event.',
          isOptional: true,
        ),
      ),
      _StateCard(
        label: 'empty-body',
        child: CatchFieldContentRow(title: 'Registration confirmed', body: ''),
      ),
      _StateCard(
        label: 'two-three-clamp',
        child: SizedBox(
          width: WidgetbookPreviewLayout.fieldContentClampWidth,
          child: CatchFieldContentRow(
            title: 'A deliberately long title that reaches the second line',
            body:
                'Supporting copy may use three complete lines before the field truncates the remainder.',
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchFieldSupportRow,
  path: '[Core primitives]/Inputs',
)
Widget catchFieldSupportRowContractStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _ContractScreen(
    title: 'CatchFieldSupportRow',
    contractId: 'catch.field.support_row',
    states: const ['helper', 'counter', 'error'],
    children: [
      _StateCard(
        label: 'helper',
        child: CatchFieldSupportRow(
          text: 'Shown on your public profile.',
          color: t.ink3,
        ),
      ),
      _StateCard(
        label: 'counter',
        child: CatchFieldSupportRow(
          text: 'Keep it concise.',
          counter: '19 / 300',
          color: t.ink3,
        ),
      ),
      _StateCard(
        label: 'error',
        child: CatchFieldSupportRow(
          text: 'Choose at least one option.',
          color: t.danger,
          showErrorIcon: true,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchFieldExplicitSaveControl,
  path: '[Core primitives]/Inputs',
)
Widget catchFieldExplicitSaveControlContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchFieldExplicitSaveControl',
    contractId: 'catch.field.explicit_save_control',
    states: const ['supporting', 'feedback', 'secondary-action'],
    children: [
      const _StateCard(
        label: 'supporting',
        child: CatchFieldExplicitSaveControl(supporting: Text('19 / 300')),
      ),
      const _StateCard(
        label: 'feedback',
        child: CatchFieldExplicitSaveControl(feedback: Text('Draft restored.')),
      ),
      _StateCard(
        label: 'secondary-action',
        child: CatchFieldExplicitSaveControl(
          secondaryAction: CatchTextButton(
            label: 'Change prompt',
            onPressed: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchFieldActionBar,
  path: '[Core primitives]/Inputs',
)
Widget catchFieldActionBarContractStates(BuildContext context) {
  final textScale = MediaQuery.textScalerOf(context).scale(1);

  return _ContractScreen(
    title: 'CatchFieldActionBar',
    contractId: 'catch.field.action_bar',
    states: const ['ready', 'saving', 'leading', 'wrapped'],
    children: [
      _StateCard(
        label: 'ready',
        child: CatchFieldActionBar(onCancel: _noop, onSubmit: _noop),
      ),
      _StateCard(
        label: 'saving',
        child: CatchFieldActionBar(
          loading: true,
          onCancel: _noop,
          onSubmit: _noop,
        ),
      ),
      _StateCard(
        label: 'leading',
        child: CatchFieldActionBar(
          actionLeading: const Text('19 / 300'),
          onCancel: _noop,
          onSubmit: _noop,
        ),
      ),
      _StateCard(
        label: 'wrapped',
        child: SizedBox(
          width: textScale >= 2
              ? WidgetbookPreviewLayout.standardContractWidth
              : WidgetbookPreviewLayout.fieldActionBarWrapWidth,
          child: CatchFieldActionBar(
            actionLeading: const Text('19 / 300'),
            onCancel: _noop,
            onSubmit: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchFieldDisclosureDrawer,
  path: '[Core primitives]/Inputs',
)
Widget catchFieldDisclosureDrawerContractStates(BuildContext context) {
  CatchFieldDisclosureDrawer drawer({required bool open}) {
    return CatchFieldDisclosureDrawer(
      open: open,
      offstage: !open,
      control: const Text('Disclosure control'),
      startPadding: CatchSpacing.s4,
      endPadding: CatchSpacing.s4,
      bottomPadding: CatchFieldTokens.rowVerticalPadding,
      revealDuration: Duration.zero,
      opacityDuration: Duration.zero,
      onRevealEnd: _noop,
    );
  }

  return _ContractScreen(
    title: 'CatchFieldDisclosureDrawer',
    contractId: 'catch.field.disclosure_drawer',
    states: const ['closed', 'open'],
    children: [
      _StateCard(label: 'closed', child: drawer(open: false)),
      _StateCard(label: 'open', child: drawer(open: true)),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchFieldSpinner,
  path: '[Core primitives]/Inputs',
)
Widget catchFieldSpinnerContractStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _ContractScreen(
    title: 'CatchFieldSpinner',
    contractId: 'catch.field.spinner',
    states: const ['field', 'commit'],
    children: [
      _StateCard(
        label: 'field',
        child: CatchFieldSpinner(color: t.ink3),
      ),
      _StateCard(
        label: 'commit',
        child: CatchFieldSpinner(
          size: CatchFieldTokens.actionSpinnerExtent,
          color: t.ink,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchFieldFocusOutline,
  path: '[Core primitives]/Inputs',
)
Widget catchFieldFocusOutlineContractStates(BuildContext context) {
  Widget sample({required bool show, required String label}) {
    return CatchFieldFocusOutline(
      debugKey: ValueKey('catch-field-focus-outline-$label'),
      show: show,
      borderRadius: BorderRadius.circular(CatchRadius.pill),
      child: const SizedBox(
        width: WidgetbookPreviewLayout.fieldFocusTargetWidth,
        height: WidgetbookPreviewLayout.fieldFocusTargetHeight,
        child: Center(child: Text('Target')),
      ),
    );
  }

  return _ContractScreen(
    title: 'CatchFieldFocusOutline',
    contractId: 'catch.field.focus_outline',
    states: const ['hidden', 'visible'],
    children: [
      _StateCard(
        label: 'hidden',
        child: sample(show: false, label: 'hidden'),
      ),
      _StateCard(
        label: 'visible',
        child: sample(show: true, label: 'visible'),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchFieldChoiceChip,
  path: '[Core primitives]/Inputs',
)
Widget catchFieldChoiceChipContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchFieldChoiceChip',
    contractId: 'catch.field.choice_chip',
    states: const [
      'selected',
      'unselected',
      'disabled',
      'pressed',
      'keyboard-focused',
    ],
    children: [
      _StateCard(
        label: 'selected / unselected / disabled',
        child: _InlineWrap(
          children: [
            CatchFieldChoiceChip(
              label: 'English',
              selected: true,
              multi: true,
              enabled: true,
              onPressed: _noop,
            ),
            CatchFieldChoiceChip(
              label: 'Hindi',
              selected: false,
              multi: true,
              enabled: true,
              onPressed: _noop,
            ),
            CatchFieldChoiceChip(
              label: 'Tamil',
              selected: false,
              multi: true,
              enabled: false,
              onPressed: _noop,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'pressed · press and hold',
        child: CatchFieldChoiceChip(
          label: 'Race prep',
          selected: false,
          multi: true,
          enabled: true,
          onPressed: _noop,
        ),
      ),
      _StateCard(
        label: 'keyboard-focused · use Tab',
        child: CatchFieldChoiceChip(
          label: 'Social miles',
          selected: true,
          multi: true,
          enabled: true,
          onPressed: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchFieldOptionCardControl,
  path: '[Core primitives]/Inputs',
)
Widget catchFieldOptionCardControlContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchFieldOptionCardControl',
    contractId: 'catch.field.option_card_control',
    states: const ['selected', 'unselected', 'disabled'],
    children: [
      _StateCard(
        label: 'selected / unselected',
        child: CatchFieldOptionCardControl<String>(
          values: const ['open', 'invite'],
          itemTitle: (value) =>
              value == 'open' ? 'Open capacity' : 'Invite only',
          itemDescription: (value) => value == 'open'
              ? 'Anyone eligible can book until capacity.'
              : 'Only people with the invite code can book.',
          selected: 'open',
          onChanged: (_) {},
        ),
      ),
      _StateCard(
        label: 'disabled',
        child: CatchFieldOptionCardControl<String>(
          values: const ['standard'],
          itemTitle: (_) => 'Standard',
          itemDescription: (_) => 'Refunds step down as the event approaches.',
          selected: 'standard',
          enabled: false,
          onChanged: null,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchFieldStepper,
  path: '[Core primitives]/Inputs',
)
Widget catchFieldStepperContractStates(BuildContext context) {
  CatchFieldStepper stepper(num value, {num? min, num? max}) {
    return CatchFieldStepper(
      value: value,
      min: min,
      max: max,
      unit: 'cm',
      decreaseSemanticLabel: 'Decrease height',
      increaseSemanticLabel: 'Increase height',
      onChanged: (_) {},
    );
  }

  return _ContractScreen(
    title: 'CatchFieldStepper',
    contractId: 'catch.field.stepper',
    states: const [
      'default',
      'minimum',
      'maximum',
      'repeating',
      'keyboard-focused',
    ],
    children: [
      _StateCard(label: 'default', child: stepper(168, min: 120, max: 220)),
      _StateCard(label: 'minimum', child: stepper(120, min: 120, max: 220)),
      _StateCard(label: 'maximum', child: stepper(220, min: 120, max: 220)),
      _StateCard(
        label: 'repeating · press and hold',
        child: stepper(168, min: 120, max: 220),
      ),
      _StateCard(
        label: 'keyboard-focused · use Tab',
        child: stepper(168, min: 120, max: 220),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchFieldCommitButton,
  path: '[Core primitives]/Inputs',
)
Widget catchFieldCommitButtonContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchFieldCommitButton',
    contractId: 'catch.field.commit_button',
    states: const ['cancel', 'done', 'saving', 'disabled', 'keyboard-focused'],
    children: [
      _StateCard(
        label: 'cancel / done / saving / disabled',
        child: _InlineWrap(
          children: [
            CatchFieldCommitButton(label: 'Cancel', onPressed: _noop),
            CatchFieldCommitButton(
              label: 'Done',
              primary: true,
              onPressed: _noop,
            ),
            const CatchFieldCommitButton(
              label: 'Saving…',
              primary: true,
              loading: true,
              onPressed: null,
            ),
            const CatchFieldCommitButton(
              label: 'Done',
              primary: true,
              onPressed: null,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'keyboard-focused · use Tab',
        child: CatchFieldCommitButton(
          label: 'Done',
          primary: true,
          onPressed: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchFieldToggle,
  path: '[Core primitives]/Inputs',
)
Widget catchFieldToggleContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchFieldToggle',
    contractId: 'catch.field.toggle',
    states: const ['off', 'on', 'saving', 'disabled', 'keyboard-focused'],
    children: [
      _StateCard(
        label: 'off / on / saving / disabled',
        child: _InlineWrap(
          children: [
            CatchFieldToggle(value: false, onChanged: (_) {}),
            CatchFieldToggle(value: true, onChanged: (_) {}),
            const CatchFieldToggle(value: true, onChanged: null),
            const CatchFieldToggle(value: false, onChanged: null),
          ],
        ),
      ),
      _StateCard(
        label: 'keyboard-focused · use Tab',
        child: CatchFieldToggle(value: true, onChanged: (_) {}),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchFieldRepeatButton,
  path: '[Core primitives]/Inputs',
)
Widget catchFieldRepeatButtonContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchFieldRepeatButton',
    contractId: 'catch.field.repeat_button',
    states: const [
      'enabled',
      'disabled',
      'pressed',
      'repeating',
      'keyboard-focused',
    ],
    children: [
      _StateCard(
        label: 'enabled / disabled / press / hold to repeat',
        child: _InlineWrap(
          children: [
            CatchFieldRepeatButton(
              icon: CatchIcons.removeRounded,
              semanticLabel: 'Decrease',
              enabled: true,
              onStep: _noop,
            ),
            CatchFieldRepeatButton(
              icon: CatchIcons.addRounded,
              semanticLabel: 'Increase',
              enabled: true,
              onStep: _noop,
            ),
            CatchFieldRepeatButton(
              icon: CatchIcons.addRounded,
              semanticLabel: 'Increase disabled',
              enabled: false,
              onStep: _noop,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'keyboard-focused · use Tab',
        child: CatchFieldRepeatButton(
          icon: CatchIcons.addRounded,
          semanticLabel: 'Increase from keyboard',
          enabled: true,
          onStep: _noop,
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
      'status',
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
        label: 'status',
        child: CatchFieldTrailing.status(status: CatchFieldStatus.saved),
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
      'divided-field-rows',
      'divided-field-rows-full-bleed',
      'divided-field-rows-rounded-tile',
      'divided-field-rows-full-bleed-keyboard-focus',
      'contained-field-rows-external-header',
      'contained-field-rows-internal-header',
      'contained-field-groups',
      'contained-field-rows-child-active',
      'contained-field-rows-explicit-focused',
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
        label: 'divided-field-rows',
        child: _FieldWidth(
          child: CatchSection.fieldRows(
            title: 'About you',
            count: '3 fields',
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
        label: 'divided-field-rows-full-bleed',
        description:
            'The section-wide compact default reaches the nearest page interaction plane.',
        child: _FieldWidth(
          child: CatchScreenBody(
            scrollable: false,
            padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s4),
            child: CatchSection.fieldRows(
              title: 'Notifications',
              interaction: CatchDividedFieldInteraction.fullBleed,
              children: [
                CatchField.nav(
                  title: 'Reminder timing',
                  body: 'Two hours before',
                  icon: CatchIcons.clock,
                  onTap: _noop,
                ),
              ],
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'divided-field-rows-rounded-tile',
        description:
            'The retained section-level alternative uses one inset perimeter.',
        child: _FieldWidth(
          child: CatchScreenBody(
            scrollable: false,
            padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s4),
            child: CatchSection.fieldRows(
              title: 'Notifications',
              interaction: CatchDividedFieldInteraction.roundedTile,
              children: [
                CatchField.nav(
                  title: 'Reminder timing',
                  body: 'Two hours before',
                  icon: CatchIcons.clock,
                  onTap: _noop,
                ),
              ],
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'divided-field-rows-full-bleed-keyboard-focus',
        description:
            'Keyboard focus adds the approved 2 px inset perimeter to the same full-bleed plane.',
        child: _FieldWidth(
          child: CatchScreenBody(
            scrollable: false,
            padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s4),
            child: CatchSection.fieldRows(
              title: 'Profile',
              interaction: CatchDividedFieldInteraction.fullBleed,
              children: [
                CatchField.input(
                  title: 'Public name',
                  initialValue: 'Suvrat',
                  icon: CatchIcons.personOutlined,
                  autofocus: true,
                ),
              ],
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'contained-field-rows-external-header',
        child: _FieldWidth(
          child: CatchSectionList(
            emptyStateOmitted: true,
            gap: CatchSpacing.s6,
            children: [
              CatchSection.fieldRows(
                title: 'Divided fields',
                count: '1 field',
                trailing: Icon(CatchIcons.infoOutlineRounded),
                footer: const Text('8 px divided footer top inset'),
                children: const [
                  CatchField.read(title: 'Name', body: 'Suvrat'),
                ],
              ),
              CatchSection.containedFieldRows(
                title: 'Contained fields',
                count: '1 field',
                trailing: Icon(CatchIcons.infoOutlineRounded),
                footer: const Text('2 px contained footer top inset'),
                children: const [
                  CatchField.read(title: 'Height', body: '168 cm'),
                ],
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'contained-field-rows-internal-header',
        child: _FieldWidth(
          child: CatchSection.containedFieldRows(
            title: 'Event settings',
            count: '2 fields',
            trailing: Icon(CatchIcons.infoOutlineRounded),
            headerPlacement: CatchSectionHeaderPlacement.inside,
            children: [
              CatchField.read(
                title: 'Host',
                body: 'Catch Hosts',
                icon: CatchIcons.hosted,
              ),
              CatchField.nav(
                title: 'Location',
                body: 'Carter Road promenade',
                icon: CatchIcons.pinOutlined,
                onTap: _noop,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'contained-field-groups',
        child: _FieldWidth(
          child: CatchSection.containedFieldGroups(
            groups: [
              CatchSectionFieldGroup(
                title: 'Continue',
                children: [
                  CatchField.action(
                    title: 'Continue draft',
                    body: '5km · Carter Road Jetty · 24/6',
                    icon: CatchIcons.editNoteRounded,
                    onTap: _noop,
                  ),
                  CatchField.action(
                    title: 'Repeat last event',
                    body: 'Reuse Monday Evening Run',
                    icon: CatchIcons.refresh,
                    onTap: _noop,
                  ),
                ],
              ),
              CatchSectionFieldGroup(
                title: 'Start new',
                children: [
                  CatchField.action(
                    title: 'Sell tickets with Catch',
                    body: 'Tickets, waitlist, and payments in one place.',
                    icon: CatchIcons.confirmationNumberOutlined,
                    onTap: _noop,
                  ),
                  CatchField.action(
                    title: 'Use guest list',
                    body: 'Import CSV or XLSX.',
                    icon: CatchIcons.cloudUploadOutlined,
                    onTap: _noop,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'contained-field-rows-child-active',
        child: _FieldWidth(
          child: CatchSection.containedFieldRows(
            children: [
              CatchField.choices<String>(
                title: 'Languages',
                body: 'English · Hindi · Marathi',
                icon: CatchIcons.languageOutlined,
                values: const [
                  'English',
                  'Hindi',
                  'Marathi',
                  'Tamil',
                  'Gujarati',
                ],
                itemLabel: (value) => value,
                selected: const {'English', 'Hindi', 'Marathi'},
                multi: true,
                initiallyOpen: true,
                onSelectionChanged: (_) {},
                onCancel: _noop,
                onSubmit: _noop,
              ),
              const CatchField.input(
                title: 'Answer',
                initialValue: 'Social miles and good coffee.',
                maxLines: null,
                minLines: 1,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'contained-field-rows-explicit-focused',
        child: _FieldWidth(
          child: CatchSection.containedFieldRows(
            focused: true,
            children: [
              CatchField.read(
                title: 'Section-owned validation state',
                body: 'The outer perimeter is explicitly focused.',
                icon: CatchIcons.infoOutlineRounded,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'field-list',
        child: _FieldWidth(
          child: CatchSectionList(
            emptyStateOmitted: true,
            gap: CatchSpacing.s4,
            children: [
              CatchSection.fieldRows(
                title: 'First section',
                children: [CatchField.read(title: 'Name', body: 'Suvrat')],
              ),
              CatchSection.fieldRows(
                title: 'Second section',
                children: [CatchField.read(title: 'City', body: 'Delhi NCR')],
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'long-copy',
        child: SizedBox(
          width: WidgetbookPreviewLayout.standardContractWidth,
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
    states: const [
      'default',
      'focused',
      'error',
      'field-rows-child-active',
      'field-rows-explicit-focused',
    ],
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
      _StateCard(
        label: 'field-rows-child-active',
        child: _FieldWidth(
          child: CatchSectionFocusSurface(
            padding: EdgeInsets.zero,
            focused: false,
            hasError: false,
            fieldRows: true,
            child: CatchField.input(
              title: 'Answer',
              initialValue: 'The child owns this focus ring.',
              focused: true,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'field-rows-explicit-focused',
        child: _FieldWidth(
          child: CatchSectionFocusSurface(
            padding: EdgeInsets.zero,
            focused: true,
            hasError: false,
            fieldRows: true,
            child: CatchField.read(
              title: 'Section validation',
              body: 'Explicit focus belongs to the outer perimeter.',
            ),
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
      'focused',
      'disabled',
      'bordered',
      'float',
      'plain',
      'counted',
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
        label: 'focused',
        description:
            'Use keyboard traversal to inspect the semantic focus ring.',
        child: CatchIconButton.icon(
          icon: CatchIcons.search,
          tooltip: 'Keyboard focus target',
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
      _StateCard(
        label: 'counted / zero / overflow',
        child: _InlineWrap(
          children: [
            CatchIconButton.counted(
              icon: CatchIcons.notificationsNoneRounded,
              count: 0,
              tooltip: 'Notifications',
              onTap: _noop,
            ),
            CatchIconButton.counted(
              icon: CatchIcons.notificationsRounded,
              count: 3,
              tooltip: 'Notifications, 3 unread',
              onTap: _noop,
            ),
            CatchIconButton.counted(
              icon: CatchIcons.notificationsRounded,
              count: 124,
              tooltip: 'Notifications, 124 unread',
              onTap: _noop,
            ),
          ],
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
      width: WidgetbookPreviewLayout.controlShellWidth,
      child: CatchControlShell(
        size: size,
        shape: shape,
        tone: tone,
        enabled: enabled,
        hasError: hasError,
        focused: focused,
        onTap: onTap,
        semanticButton: semanticButton,
        child: Text(
          label,
          style: CatchTextStyles.fieldLabel(context, color: t.ink),
        ),
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
    states: const ['default', 'selected', 'focused', 'disabled-by-null-action'],
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
        label: 'focused',
        description:
            'Use keyboard traversal to inspect the semantic focus ring.',
        child: _OptionWidth(
          child: CatchOptionCard(
            title: 'Keyboard focus target',
            description: 'The focus border is thicker without changing layout.',
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
      'semantic-border',
      'focused',
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
        label: 'semantic-border',
        child: CatchSurface(
          borderRole: CatchBorderRole.boundary,
          padding: CatchInsets.contentRelaxed,
          child: Text(
            'Boundary role resolves color and width together.',
            style: CatchTextStyles.proseM(context),
          ),
        ),
      ),
      _StateCard(
        label: 'focused',
        child: CatchSurface(
          borderRole: CatchBorderRole.focus,
          padding: CatchInsets.contentRelaxed,
          child: Text(
            'Focus role is intentionally thicker and geometry-stable.',
            style: CatchTextStyles.proseM(context),
          ),
        ),
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
          width: WidgetbookPreviewLayout.surfaceCardWidth,
          child: Text(
            'Default bounded group',
            style: CatchTextStyles.proseM(context),
          ),
        ),
      ),
      _StateCard(
        label: 'tinted',
        child: CatchSurface.tinted(
          child: Text(
            'Only attendees can see this matching detail.',
            style: CatchTextStyles.supporting(context),
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
      'large-text-reflow',
    ],
    children: [
      _StateCard(
        label: 'default',
        child: CatchMetricStrip(
          items: [
            CatchMetricStripItem(value: '24', label: 'going'),
            CatchMetricStripItem(value: '4', label: 'left'),
            CatchMetricStripItem(value: '8:30', label: 'starts'),
          ],
        ),
      ),
      _StateCard(
        label: 'with-unit',
        child: CatchMetricStrip(
          items: [
            CatchMetricStripItem(value: '2.4', unit: 'km', label: 'away'),
            CatchMetricStripItem(value: '12', unit: 'min', label: 'walk'),
            CatchMetricStripItem(value: '6', unit: 'pm', label: 'meet'),
          ],
        ),
      ),
      _StateCard(
        label: 'four-items',
        child: CatchMetricStrip(
          items: [
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
          width: WidgetbookPreviewLayout.metricStripLongCopyWidth,
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
          items: [
            CatchMetricStripItem(value: '8', label: 'matched'),
            CatchMetricStripItem(value: '2', label: 'pending'),
            CatchMetricStripItem(value: '1', label: 'open'),
          ],
        ),
      ),
      _StateCard(
        label: 'large-text-reflow',
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: CatchMetricStrip(
            items: const [
              CatchMetricStripItem(value: '12', label: 'responses'),
              CatchMetricStripItem(value: '6', label: 'questions'),
              CatchMetricStripItem(value: '1', label: 'published version'),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchMetricStripCell,
  path: '[Core primitives]/Data display',
)
Widget catchMetricStripCellContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchMetricStripCell',
    contractId: 'catch.metric_strip.cell',
    states: const ['default', 'with-unit', 'long-label', 'color-overrides'],
    children: [
      const _StateCard(
        label: 'default',
        child: SizedBox(
          width: WidgetbookPreviewLayout.metricStripCellWidth,
          child: CatchMetricStripCell(
            item: CatchMetricStripItem(value: '24', label: 'going'),
          ),
        ),
      ),
      const _StateCard(
        label: 'with-unit',
        child: SizedBox(
          width: WidgetbookPreviewLayout.metricStripCellWidth,
          child: CatchMetricStripCell(
            item: CatchMetricStripItem(value: '2.4', unit: 'km', label: 'away'),
          ),
        ),
      ),
      const _StateCard(
        label: 'long-label',
        child: SizedBox(
          width: WidgetbookPreviewLayout.metricStripCellWidth,
          child: CatchMetricStripCell(
            item: CatchMetricStripItem(
              value: '98%',
              label: 'historical show rate',
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'color-overrides',
        child: SizedBox(
          width: WidgetbookPreviewLayout.metricStripCellWidth,
          child: CatchMetricStripCell(
            valueColor: t.primary,
            unitColor: t.accent,
            labelColor: t.ink2,
            item: const CatchMetricStripItem(
              value: '12',
              unit: 'min',
              label: 'walk',
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchMetricStripDivider,
  path: '[Core primitives]/Data display',
)
Widget catchMetricStripDividerContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchMetricStripDivider',
    contractId: 'catch.metric_strip.divider',
    states: const ['default', 'color-override'],
    children: [
      _StateCard(
        label: 'divider colors',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CatchMetricStripDivider(),
            const SizedBox(width: CatchSpacing.s2),
            CatchMetricStripDivider(color: t.primary),
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
      'divider',
      'plain-actions',
    ],
    children: [
      _StateCard(
        label: 'compact',
        child: const _TopBarFrame(
          child: CatchTopBar(
            title: 'Events',
            subtitle: 'Tonight nearby',
            allowContentHeightExpansion: true,
          ),
        ),
      ),
      _StateCard(
        label: 'large',
        child: const _TopBarFrame(
          child: CatchTopBar(
            kicker: 'HOST MODE',
            title: 'Upcoming events',
            subtitle: 'Review requests and keep the room balanced.',
            allowContentHeightExpansion: true,
          ),
        ),
      ),
      _StateCard(
        label: 'with-leading',
        child: _TopBarFrame(
          child: CatchTopBar(
            title: 'Event details',
            allowContentHeightExpansion: true,
            leadingType: CatchTopBarLeading.back,
            onBack: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'plain-actions',
        child: _TopBarFrame(
          child: CatchTopBar(
            title: 'Form builder',
            allowContentHeightExpansion: true,
            leadingType: CatchTopBarLeading.back,
            leadingActionVariant: CatchIconButtonVariant.plain,
            onBack: _noop,
            actions: [
              CatchTopBarTextAction(label: 'Preview', onPressed: _noop),
              CatchTopBarMenuAction<String>(
                tooltip: 'Form actions',
                variant: CatchIconButtonVariant.plain,
                items: const [
                  CatchActionMenuItem(value: 'share', label: 'Share form'),
                ],
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'with-action-icon',
        child: _TopBarFrame(
          child: CatchTopBar(
            title: 'Chats',
            allowContentHeightExpansion: true,
            actions: [
              CatchIconAction(
                icon: CatchIcons.moreHorizRounded,
                tooltip: 'More',
                onPressed: _noop,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'with-action-text',
        child: _TopBarFrame(
          child: CatchTopBar(
            title: 'Preview',
            allowContentHeightExpansion: true,
            actions: [CatchTopBarTextAction(label: 'Done', onPressed: _noop)],
          ),
        ),
      ),
      _StateCard(
        label: 'with-search',
        description: 'Use the search icon to review the expanded search state.',
        child: _TopBarFrame(
          child: CatchTopBar(
            title: 'Clubs',
            allowContentHeightExpansion: true,
            search: CatchTopBarSearch(
              value: 'run',
              placeholder: 'Search clubs',
              tooltip: 'Search clubs',
              onChanged: _ignoreString,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'conversation-title',
        child: _TopBarFrame(
          child: CatchTopBar.identity(
            identityName: 'Taylor from Sunday Social',
            allowContentHeightExpansion: true,
            identityPhotoUrl: null,
            onIdentityTap: _noop,
            surface: true,
            divider: true,
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
          child: CatchTopBar(
            title: 'Surface',
            surface: true,
            allowContentHeightExpansion: true,
          ),
        ),
      ),
      _StateCard(
        label: 'divider',
        child: const _TopBarFrame(
          child: CatchTopBar(
            title: 'Divider',
            divider: true,
            allowContentHeightExpansion: true,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchMenu,
  path: '[Core primitives]/Navigation',
)
Widget catchMenuContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchMenu',
    contractId: 'catch.menu',
    states: const [
      'default',
      'action-row',
      'choice-row',
      'choice-row-selected',
      'disabled-row',
      'danger-row',
      'with-icons',
      'with-sublabels',
      'sectioned',
      'scrolling',
      'compact-selection-sheet',
      'anchored-selection',
    ],
    children: [
      _StateCard(
        label: 'panel rows',
        child: CatchMenu<String>(
          width: WidgetbookPreviewLayout.mediumComponentWidth,
          onSelected: (value, _) => _ignoreString(value),
          items: [
            CatchMenuItem(
              value: 'share',
              label: 'Share card',
              sublabel: 'Send the event link',
              icon: CatchIcons.iosShareRounded,
            ),
            CatchMenuItem(
              value: 'going',
              label: 'Going',
              selected: true,
              role: CatchMenuItemRole.choice,
              icon: CatchIcons.checkCircle,
              startsSection: true,
            ),
            CatchMenuItem(
              value: 'host-only',
              label: 'Host controls',
              enabled: false,
              icon: CatchIcons.lockOutlineRounded,
            ),
            CatchMenuItem(
              value: 'remove',
              label: 'Remove from event',
              danger: true,
              icon: CatchIcons.deleteOutline,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'command overflow',
        child: CatchActionMenu<String>(
          tooltip: 'More actions',
          onSelected: _ignoreString,
          items: [
            CatchActionMenuItem(
              value: 'share',
              label: 'Share',
              icon: CatchIcons.iosShareRounded,
            ),
            CatchActionMenuItem(
              value: 'report',
              label: 'Report',
              sublabel: 'Send to safety',
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
      ),
      _StateCard(
        label: 'adaptive selection',
        description:
            'Open on compact and wider viewports to compare sheet and anchor.',
        child: CatchAdaptiveSelectionControl<String>(
          title: 'Sort customers',
          subtitle: 'Choose how customers are ordered.',
          tooltip: 'Sort customers',
          value: 'last-seen',
          items: const [
            CatchSelectionMenuItem(value: 'last-seen', label: 'Last seen'),
            CatchSelectionMenuItem(
              value: 'most-attended',
              label: 'Most attended',
            ),
            CatchSelectionMenuItem(value: 'name', label: 'Name'),
          ],
          triggerLabel: (item) => 'Sort: ${item.label}',
          onSelected: _ignoreString,
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
        child: CatchPrivacyBadge(kind: CatchPrivacyBadgeKind.hostCanSee),
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
          width: WidgetbookPreviewLayout.standardContractWidth,
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
  type: CatchJourneyStepNode,
  path: '[Core primitives]/Sections',
)
Widget catchJourneyStepNodeContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchJourneyStepNode',
    contractId: 'catch.journey_steps.node',
    states: const ['default', 'accented'],
    children: [
      _StateCard(
        label: 'node colors',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CatchJourneyStepNode(),
            const SizedBox(width: CatchSpacing.s4),
            CatchJourneyStepNode(accent: t.like),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchScreenScaffold,
  path: '[Core primitives]/Sections',
)
Widget catchScreenScaffoldContractStates(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);
  final t = CatchTokens.of(context);

  return CatchScreenScaffold.standalone(
    body: _ContractScreen(
      title: 'CatchScreenScaffold',
      contractId: 'catch.screen_body.screen_scaffold',
      states: const [
        'standalone-safe-area',
        'step-flow-safe-area',
        'workspace-owned-insets',
        'keyboard-resize',
      ],
      children: [
        const _StateCard(
          label: 'role-owned surface',
          child: _BodySpec(
            label: 'The named constructor owns surface and safe-area policy.',
          ),
        ),
        _StateCard(
          label: 'keyboard-resize',
          description:
              'A simulated keyboard inset shortens the scaffold body so its '
              'bottom action remains above the obstruction.',
          child: _BodyFrame(
            child: MediaQuery(
              data: mediaQuery.copyWith(
                viewInsets: const EdgeInsets.only(
                  bottom: WidgetbookPreviewLayout.compactPanelHeight,
                ),
              ),
              child: CatchScreenScaffold.standalone(
                safeArea: CatchScreenSafeArea.none,
                resizeToAvoidBottomInset: true,
                body: ColoredBox(
                  color: t.surface,
                  child: const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: CatchInsets.content,
                      child: _BodySpec(
                        label: 'Bottom action clears the keyboard inset.',
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
              emptyStateOmitted: true,
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
          width: WidgetbookPreviewLayout.standardContractWidth,
          child: CatchSectionList(
            emptyStateOmitted: true,
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
          width: WidgetbookPreviewLayout.standardContractWidth,
          child: CatchSectionList(
            emptyStateOmitted: true,
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
          width: WidgetbookPreviewLayout.standardContractWidth,
          child: CatchSectionList(
            emptyStateOmitted: true,
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
          width: WidgetbookPreviewLayout.standardContractWidth,
          child: CatchSectionList(
            emptyStateOmitted: true,
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
          width: WidgetbookPreviewLayout.standardContractWidth,
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
              width: WidgetbookPreviewLayout.activityArtPairWidth,
              child: CatchActivityArt(
                activityKind: ActivityKind.pickleball,
                height: WidgetbookPreviewLayout.activityArtPairHeight,
              ),
            ),
            SizedBox(
              width: WidgetbookPreviewLayout.activityArtPairWidth,
              child: CatchActivityArt(
                activityKind: ActivityKind.dinner,
                height: WidgetbookPreviewLayout.activityArtPairHeight,
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
          width: WidgetbookPreviewLayout.activityArtCustomWidth,
          child: CatchActivityArt(
            activityKind: ActivityKind.yoga,
            height: WidgetbookPreviewLayout.activityArtCustomHeight,
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
            width: WidgetbookPreviewLayout.networkIconExtent,
            height: WidgetbookPreviewLayout.networkIconExtent,
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
            width: WidgetbookPreviewLayout.networkLandscapeWidth,
            height: WidgetbookPreviewLayout.networkLandscapeHeight,
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
            width: WidgetbookPreviewLayout.networkLandscapeWidth,
            height: WidgetbookPreviewLayout.networkLandscapeHeight,
            child: CatchNetworkImage('assets/branding/not-found.png'),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchNetworkImageFallback,
  path: '[Core primitives]/Media',
)
Widget catchNetworkImageFallbackContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchNetworkImageFallback',
    contractId: 'catch.network_image.fallback',
    states: const ['default', 'custom-icon', 'custom-color'],
    children: [
      const _StateCard(
        label: 'default',
        child: SizedBox.square(
          dimension: WidgetbookPreviewLayout.networkFallbackExtent,
          child: CatchNetworkImageFallback(),
        ),
      ),
      _StateCard(
        label: 'custom-icon',
        child: SizedBox.square(
          dimension: WidgetbookPreviewLayout.networkFallbackExtent,
          child: CatchNetworkImageFallback(
            icon: CatchIcons.photoLibraryOutlined,
          ),
        ),
      ),
      _StateCard(
        label: 'custom-color',
        child: SizedBox.square(
          dimension: WidgetbookPreviewLayout.networkFallbackExtent,
          child: CatchNetworkImageFallback(
            backgroundColor: t.primarySoft,
            iconColor: t.primary,
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
          width: WidgetbookPreviewLayout.distanceRingLongLabelWidth,
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
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputWidth,
          child: CatchCodeInput(),
        ),
      ),
      _StateCard(
        label: 'partial',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputWidth,
          child: CatchCodeInput(value: '482'),
        ),
      ),
      _StateCard(
        label: 'active-caret',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputWidth,
          child: CatchCodeInput(value: '48', active: 4),
        ),
      ),
      _StateCard(
        label: 'complete',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputWidth,
          child: CatchCodeInput(value: '482913'),
        ),
      ),
      _StateCard(
        label: 'custom-length',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputShortWidth,
          child: CatchCodeInput(length: 4, value: '82'),
        ),
      ),
      _StateCard(
        label: 'no-caret',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputWidth,
          child: CatchCodeInput(value: '48', caret: false),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchCodeInputRow,
  path: '[Core primitives]/Inputs',
)
Widget catchCodeInputRowContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchCodeInputRow',
    contractId: 'catch.code_input.row',
    states: const ['empty', 'partial', 'custom-prefix'],
    children: const [
      _StateCard(
        label: 'empty',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputWidth,
          child: CatchCodeInputRow(),
        ),
      ),
      _StateCard(
        label: 'partial',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputWidth,
          child: CatchCodeInputRow(value: '421', active: 3),
        ),
      ),
      _StateCard(
        label: 'custom-prefix',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputShortWidth,
          child: CatchCodeInputRow(
            length: 4,
            value: '90',
            cellKeyPrefix: 'handoff_digit',
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchCodeInputCell,
  path: '[Core primitives]/Inputs',
)
Widget catchCodeInputCellContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchCodeInputCell',
    contractId: 'catch.code_input.cell',
    states: const ['digit', 'active-caret', 'inactive-empty'],
    children: const [
      _StateCard(
        label: 'digit',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputCellWidth,
          child: CatchCodeInputCell(digit: '8', isActive: false),
        ),
      ),
      _StateCard(
        label: 'active-caret',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputCellWidth,
          child: CatchCodeInputCell(digit: '', isActive: true),
        ),
      ),
      _StateCard(
        label: 'inactive-empty',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputCellWidth,
          child: CatchCodeInputCell(digit: '', isActive: false),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchCodeInputCaret,
  path: '[Core primitives]/Inputs',
)
Widget catchCodeInputCaretContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchCodeInputCaret',
    contractId: 'catch.code_input.caret',
    states: const ['default', 'accent'],
    children: [
      const _StateCard(
        label: 'default',
        child: Padding(
          padding: EdgeInsets.all(CatchSpacing.s6),
          child: CatchCodeInputCaret(),
        ),
      ),
      _StateCard(
        label: 'accent',
        child: Padding(
          padding: const EdgeInsets.all(CatchSpacing.s6),
          child: CatchCodeInputCaret(color: t.primary),
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
      'operational',
      'selected',
      'disabled',
      'accented',
      'trailing',
      'overflow',
      'summary',
    ],
    children: [
      _StateCard(
        label: 'summary',
        child: CatchOptionGroup<int>(
          options: const [
            CatchOption(value: 0, label: 'All 214'),
            CatchOption(value: 1, label: 'Returning 148'),
            CatchOption(value: 2, label: 'New 19'),
          ],
          selected: 0,
          variant: CatchOptionGroupVariant.summary,
          contractExemption: 'Local Widgetbook scope preview.',
          onChanged: (_) {},
        ),
      ),
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
      _StateCard(
        label: 'operational',
        child: _FieldWidth(
          child: CatchOptionGroup<String>(
            options: [
              CatchOption(
                value: 'now',
                label: 'Now',
                icon: CatchIcons.scheduleRounded,
              ),
              CatchOption(
                value: 'guests',
                label: 'Guests',
                icon: CatchIcons.groupsOutlined,
              ),
              CatchOption(
                value: 'room',
                label: 'Room',
                icon: CatchIcons.gridViewRounded,
              ),
            ],
            selected: 'room',
            variant: CatchOptionGroupVariant.operational,
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
          width: WidgetbookPreviewLayout.compactComponentWidth,
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
  type: CatchOptionGroupItem,
  path: '[Core primitives]/Selection',
)
Widget catchOptionGroupItemContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchOptionGroupItem',
    contractId: 'catch.option_group.item',
    states: const ['selected', 'unselected', 'mono', 'operational', 'summary'],
    children: [
      _StateCard(
        label: 'summary',
        child: CatchOptionGroupItem<int>(
          option: const CatchOption(value: 1, label: 'Returning 148'),
          selected: true,
          variant: CatchOptionGroupVariant.summary,
          onTap: () {},
        ),
      ),
      _StateCard(
        label: 'selected',
        child: CatchOptionGroupItem<String>(
          option: const CatchOption(value: 'all', label: 'All'),
          selected: true,
          selectedRule: t.ink,
          variant: CatchOptionGroupVariant.label,
          onTap: _noop,
        ),
      ),
      _StateCard(
        label: 'unselected',
        child: CatchOptionGroupItem<String>(
          option: const CatchOption(value: 'saved', label: 'Saved'),
          selected: false,
          selectedRule: t.ink,
          variant: CatchOptionGroupVariant.label,
          onTap: _noop,
        ),
      ),
      _StateCard(
        label: 'mono',
        child: CatchOptionGroupItem<String>(
          option: const CatchOption(value: 'nearby', label: 'Nearby'),
          selected: true,
          selectedRule: t.primary,
          variant: CatchOptionGroupVariant.mono,
          onTap: _noop,
        ),
      ),
      _StateCard(
        label: 'operational',
        child: CatchOptionGroupItem<String>(
          option: CatchOption(
            value: 'room',
            label: 'Room',
            icon: CatchIcons.gridViewRounded,
          ),
          selected: true,
          selectedRule: t.ink,
          variant: CatchOptionGroupVariant.operational,
          onTap: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchTabRail,
  path: '[Core primitives]/Selection',
)
Widget catchTabRailContractStates(BuildContext context) {
  const hostOptions = [
    CatchOption(value: 'organizer', label: 'Organizer'),
    CatchOption(value: 'edit', label: 'Edit'),
    CatchOption(value: 'insights', label: 'Insights'),
    CatchOption(value: 'preview', label: 'Preview'),
  ];
  const settingsOptions = [
    CatchOption(value: 'edit', label: 'Edit'),
    CatchOption(value: 'preview', label: 'Preview'),
  ];

  return _ContractScreen(
    title: 'CatchTabRail',
    contractId: 'catch.tab_rail',
    states: const [
      'two-option',
      'four-option',
      'selected-middle',
      'operational',
    ],
    children: [
      _StateCard(
        label: 'two-option',
        child: _FieldWidth(
          child: CatchTabRail<String>(
            selected: 'edit',
            onChanged: _ignoreString,
            options: settingsOptions,
          ),
        ),
      ),
      _StateCard(
        label: 'four-option',
        child: _FieldWidth(
          child: CatchTabRail<String>(
            selected: 'organizer',
            onChanged: _ignoreString,
            options: hostOptions,
          ),
        ),
      ),
      _StateCard(
        label: 'selected-middle',
        child: _FieldWidth(
          child: CatchTabRail<String>(
            selected: 'insights',
            onChanged: _ignoreString,
            options: hostOptions,
          ),
        ),
      ),
      _StateCard(
        label: 'operational',
        child: _FieldWidth(
          child: CatchTabRail<String>(
            selected: 'room',
            onChanged: _ignoreString,
            variant: CatchOptionGroupVariant.operational,
            options: [
              CatchOption(
                value: 'now',
                label: 'Now',
                icon: CatchIcons.scheduleRounded,
              ),
              CatchOption(
                value: 'guests',
                label: 'Guests',
                icon: CatchIcons.groupsOutlined,
              ),
              CatchOption(
                value: 'room',
                label: 'Room',
                icon: CatchIcons.gridViewRounded,
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
        label: 'expanding-collapsed',
        child: _FieldWidth(
          child: CatchSearchField.expanding(
            expanded: false,
            maxWidth: 420,
            onOpenSearch: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'expanding-expanded',
        child: _FieldWidth(
          child: CatchSearchField.expanded(
            value: 'run club',
            onChanged: _ignoreString,
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
          width: WidgetbookPreviewLayout.standardContractWidth,
          child: CatchRangeSlider(
            values: const RangeValues(20, 80),
            onChanged: (_) {},
          ),
        ),
      ),
      _StateCard(
        label: 'with-endpoint-labels',
        child: SizedBox(
          width: WidgetbookPreviewLayout.standardContractWidth,
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
          width: WidgetbookPreviewLayout.standardContractWidth,
          child: CatchRangeSlider(values: RangeValues(25, 75), onChanged: null),
        ),
      ),
      _StateCard(
        label: 'divided-tickless',
        child: SizedBox(
          width: WidgetbookPreviewLayout.standardContractWidth,
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
          width: WidgetbookPreviewLayout.standardContractWidth,
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
    states: const [
      'off',
      'on',
      'disabled',
      'semantic-labelled',
      'keyboard-focused',
    ],
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
      _StateCard(
        label: 'keyboard-focused · use Tab',
        child: CatchToggle(value: true, onChanged: (_) {}),
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
        child: SizedBox(
          width: WidgetbookPreviewLayout.phoneChromeWidth,
          child: CatchStatusBar(),
        ),
      ),
      _StateCard(
        label: 'dark',
        child: SizedBox(
          width: WidgetbookPreviewLayout.phoneChromeWidth,
          child: CatchStatusBar(tone: CatchStatusBarTone.dark),
        ),
      ),
      _StateCard(
        label: 'surface',
        child: SizedBox(
          width: WidgetbookPreviewLayout.phoneChromeWidth,
          child: CatchStatusBar(surface: true),
        ),
      ),
      _StateCard(
        label: 'custom-time',
        child: SizedBox(
          width: WidgetbookPreviewLayout.phoneChromeWidth,
          child: CatchStatusBar(time: '7:24'),
        ),
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
      'with-close',
      'interactive-step-overview',
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
      _StateCard(
        label: 'with-close',
        child: _TopBarFrame(
          child: CatchStepHeader(
            title: 'Create event',
            leadingType: CatchTopBarLeading.close,
            onBack: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'interactive-step-overview',
        child: _TopBarFrame(
          child: CatchStepHeader(
            title: 'Create event',
            step: 3,
            total: 5,
            onStepOverview: _noop,
            stepOverviewSemanticsLabel: 'Review all event sections',
          ),
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
      'scrollable',
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
      _StateCard(
        label: 'scrollable',
        child: SizedBox(
          height: WidgetbookPreviewLayout.stateViewportHeight,
          child: CatchBottomSheetScaffold(
            title: 'Review answers',
            scrollable: true,
            child: Column(
              children: [
                for (var i = 0; i < 12; i++)
                  CatchField.read(
                    title: 'Question ${i + 1}',
                    body: 'Submitted answer',
                  ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchPlainSheetHeader,
  path: '[Core primitives]/Sheets and footers',
)
Widget catchPlainSheetHeaderContractStates(BuildContext context) {
  return const _ContractScreen(
    title: 'CatchPlainSheetHeader',
    contractId: 'catch.sheet.plain_header',
    states: ['title-subtitle', 'trailing', 'title-only'],
    children: [
      _StateCard(
        label: 'title-subtitle',
        child: CatchPlainSheetHeader(
          title: 'Invite guests',
          subtitle: 'Share this event with people who fit the format.',
        ),
      ),
      _StateCard(
        label: 'trailing',
        child: CatchPlainSheetHeader(
          title: 'Filters',
          subtitle: 'Tune what shows up first.',
          trailing: CatchBadge(label: '2', tone: CatchBadgeTone.gold),
        ),
      ),
      _StateCard(
        label: 'title-only',
        child: CatchPlainSheetHeader(title: 'Embedded sheet'),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchBrandedSheetHeader,
  path: '[Core primitives]/Sheets and footers',
)
Widget catchBrandedSheetHeaderContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchBrandedSheetHeader',
    contractId: 'catch.sheet.branded_header',
    states: const ['title-subtitle', 'trailing', 'title-only'],
    children: [
      _StateCard(
        label: 'title-subtitle',
        child: CatchBrandedSheetHeader(
          glyph: CatchIcons.sparkle,
          title: 'Good fit',
          subtitle: 'Guests will see this before joining.',
        ),
      ),
      _StateCard(
        label: 'trailing',
        child: CatchBrandedSheetHeader(
          glyph: CatchIcons.hostBadge,
          title: 'Set up payouts',
          subtitle: 'Powered by Stripe',
          trailing: Text('Soon'),
        ),
      ),
      _StateCard(
        label: 'title-only',
        child: CatchBrandedSheetHeader(
          glyph: CatchIcons.settingsOutlined,
          title: 'Sheet settings',
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchTabBar,
  path: '[Core primitives]/Navigation',
)
Widget catchTabDockContractStates(BuildContext context) {
  var transitionActive = 'clubs';
  return _ContractScreen(
    title: 'CatchTabBar',
    contractId: 'catch.tab_bar',
    states: const [
      'selected',
      'unselected',
      'with-active-icon',
      'with-badge',
      'disabled-readonly',
      'safe-area',
      'text-scale',
      'reduced-motion',
      'with-four-tabs',
      'first-selected',
      'last-selected',
      'selection-transition',
      'contact-preview',
      'press-and-slide',
      'pointer-focus',
      'long-press-secondary-action',
    ],
    children: [
      _StateCard(
        label: 'selected',
        child: SizedBox(
          width: WidgetbookPreviewLayout.wideContractWidth,
          child: CatchTabBar<String>(
            items: _contractTabBarItems,
            active: 'explore',
            onChanged: _ignoreString,
          ),
        ),
      ),
      _StateCard(
        label: 'unselected',
        child: SizedBox(
          width: WidgetbookPreviewLayout.wideContractWidth,
          child: CatchTabBar<String>(
            items: _contractTabBarItems,
            active: 'clubs',
            onChanged: _ignoreString,
          ),
        ),
      ),
      _StateCard(
        label: 'with-active-icon',
        child: SizedBox(
          width: WidgetbookPreviewLayout.wideContractWidth,
          child: CatchTabBar<String>(
            items: _contractTabBarItems,
            active: 'matches',
            onChanged: _ignoreString,
          ),
        ),
      ),
      _StateCard(
        label: 'with-badge',
        child: SizedBox(
          width: WidgetbookPreviewLayout.wideContractWidth,
          child: CatchTabBar<String>(
            items: _contractTabBarItems,
            active: 'matches',
            onChanged: _ignoreString,
          ),
        ),
      ),
      _StateCard(
        label: 'disabled-readonly',
        child: SizedBox(
          width: WidgetbookPreviewLayout.wideContractWidth,
          child: CatchTabBar<String>(
            items: _contractTabBarItems,
            active: 'explore',
          ),
        ),
      ),
      _StateCard(
        label: 'safe-area',
        child: SizedBox(
          width: WidgetbookPreviewLayout.wideContractWidth,
          child: CatchTabBar<String>(
            items: _contractTabBarItems,
            active: 'clubs',
            onChanged: _ignoreString,
          ),
        ),
      ),
      _StateCard(
        label: 'text-scale',
        child: SizedBox(
          width: WidgetbookPreviewLayout.wideContractWidth,
          child: MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: CatchTabBar<String>(
              items: _contractTabBarItems,
              active: 'explore',
              onChanged: _ignoreString,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced-motion',
        child: SizedBox(
          width: WidgetbookPreviewLayout.wideContractWidth,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: CatchTabBar<String>(
              items: _contractTabBarItems,
              active: 'explore',
              onChanged: _ignoreString,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'with-four-tabs',
        child: SizedBox(
          width: WidgetbookPreviewLayout.wideContractWidth,
          child: CatchTabBar<String>(
            items: _contractFourTabBarItems,
            active: 'explore',
            onChanged: _ignoreString,
          ),
        ),
      ),
      _StateCard(
        label: 'first-selected',
        child: SizedBox(
          width: WidgetbookPreviewLayout.wideContractWidth,
          child: CatchTabBar<String>(
            items: _contractFourTabBarItems,
            active: _contractFourTabBarItems.first.id,
            onChanged: _ignoreString,
          ),
        ),
      ),
      _StateCard(
        label: 'last-selected',
        child: SizedBox(
          width: WidgetbookPreviewLayout.wideContractWidth,
          child: CatchTabBar<String>(
            items: _contractFourTabBarItems,
            active: _contractFourTabBarItems.last.id,
            onChanged: _ignoreString,
          ),
        ),
      ),
      _StateCard(
        label:
            'selection-transition · contact-preview · press-and-slide · pointer-focus',
        child: SizedBox(
          width: WidgetbookPreviewLayout.wideContractWidth,
          child: StatefulBuilder(
            builder: (context, setState) => CatchTabBar<String>(
              items: _contractFourTabBarItems,
              active: transitionActive,
              onChanged: (next) => setState(() => transitionActive = next),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'long-press-secondary-action',
        child: SizedBox(
          width: WidgetbookPreviewLayout.wideContractWidth,
          child: CatchTabBar<String>(
            items: [
              ..._contractTabBarItems,
              CatchTabBarItem<String>(
                id: 'organizer',
                icon: CatchIcons.personOutlined,
                activeIcon: CatchIcons.personRounded,
                label: 'Organizer',
                onLongPress: _noop,
                semanticHint: 'Hold to switch organizer',
              ),
            ],
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
  type: CatchTabBarButton,
  path: '[Core primitives]/Navigation',
)
Widget catchTabDockButtonContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchTabBarButton',
    contractId: 'catch.tab_bar.button',
    states: const [
      'selected',
      'unselected',
      'badge',
      'pressed',
      'hovered',
      'focused',
    ],
    children: [
      _StateCard(
        label: 'button states',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: WidgetbookPreviewLayout.compactItemWidth,
              child: CatchTabBarButton<String>(
                item: _contractTabBarItems[0],
                selected: true,
                onTap: _noop,
              ),
            ),
            const SizedBox(width: CatchSpacing.s4),
            SizedBox(
              width: WidgetbookPreviewLayout.compactItemWidth,
              child: CatchTabBarButton<String>(
                item: _contractTabBarItems[1],
                selected: false,
                onTap: _noop,
              ),
            ),
            const SizedBox(width: CatchSpacing.s4),
            SizedBox(
              width: WidgetbookPreviewLayout.compactItemWidth,
              child: CatchTabBarButton<String>(
                item: _contractTabBarItems[2],
                selected: true,
                onTap: _noop,
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
  type: CatchTabBarIcon,
  path: '[Core primitives]/Navigation',
)
Widget catchTabDockIconContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchTabBarIcon',
    contractId: 'catch.tab_bar.icon',
    states: const ['plain', 'badge', 'large-badge'],
    children: [
      _StateCard(
        label: 'icon badges',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CatchTabBarIcon(icon: Icons.explore_outlined, color: t.ink),
            const SizedBox(width: CatchSpacing.s4),
            CatchTabBarIcon(
              icon: Icons.chat_bubble_outline,
              color: t.ink,
              badgeCount: 7,
            ),
            const SizedBox(width: CatchSpacing.s4),
            CatchTabBarIcon(
              icon: Icons.chat_bubble_outline,
              color: t.ink,
              badgeCount: 104,
            ),
          ],
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
      'label',
      'label-with-icon',
      'label-with-value',
      'with-count',
      'focused',
      'semantic-label',
      'text-scale-reflow',
    ],
    children: [
      _StateCard(
        label: 'label',
        child: CatchCountPill.label(label: '24 places', onPressed: _noop),
      ),
      _StateCard(
        label: 'label-with-icon',
        child: CatchCountPill.label(
          icon: CatchIcons.tuneRounded,
          label: 'Filters',
          onPressed: _noop,
        ),
      ),
      _StateCard(
        label: 'label-with-value',
        child: CatchCountPill.label(
          icon: CatchIcons.map,
          label: 'Map',
          value: '12 events',
          onPressed: _noop,
        ),
      ),
      _StateCard(
        label: 'with-count',
        child: CatchCountPill.label(
          icon: CatchIcons.tuneRounded,
          label: 'Filters',
          count: 3,
          onPressed: _noop,
        ),
      ),
      _StateCard(
        label: 'focused',
        description:
            'Use keyboard traversal to inspect the semantic focus ring.',
        child: CatchCountPill.label(
          icon: CatchIcons.tuneRounded,
          label: 'Keyboard focus target',
          onPressed: _noop,
        ),
      ),
      _StateCard(
        label: 'semantic-label',
        child: CatchCountPill.label(
          icon: CatchIcons.listRounded,
          label: 'List',
          semanticLabel: 'Show list view',
          onPressed: _noop,
        ),
      ),
      _StateCard(
        label: 'text-scale-reflow',
        child: SizedBox(
          width: WidgetbookPreviewLayout.compactControlWidth,
          child: CatchCountPill.label(
            icon: CatchIcons.tuneRounded,
            label: 'Very specific active filters',
            count: 12,
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
  type: ChatInputBar,
  path: '[Core primitives]/Product composites',
)
Widget chatInputBarContractStates(BuildContext context) {
  return const _ContractScreen(
    title: 'ChatInputBar',
    contractId: 'catch.chat_composer',
    states: [
      'empty-unfocused',
      'empty-focused',
      'draft-unfocused',
      'draft-focused',
      'multiline',
      'sending-text',
      'uploading-image',
      'disabled',
      'text-only',
    ],
    children: [
      _StateCard(
        label: 'empty-unfocused',
        child: _ChatComposerContractPreview(),
      ),
      _StateCard(
        label: 'draft-unfocused',
        child: _ChatComposerContractPreview(
          initialText: 'That last loop was fun.',
        ),
      ),
      _StateCard(
        label: 'multiline',
        child: _ChatComposerContractPreview(
          initialText: 'A message that can wrap onto more than one line.',
        ),
      ),
      _StateCard(
        label: 'sending-text',
        child: _ChatComposerContractPreview(
          initialText: 'Sending this now...',
          sending: true,
        ),
      ),
      _StateCard(
        label: 'uploading-image',
        child: _ChatComposerContractPreview(sendingImage: true),
      ),
      _StateCard(
        label: 'disabled',
        child: _ChatComposerContractPreview(
          disabledReason: 'This chat is closed.',
        ),
      ),
      _StateCard(
        label: 'text-only',
        child: _ChatComposerContractPreview(showImageButton: false),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Focused empty',
  type: ChatInputBar,
  path: '[Core primitives]/Product composites',
)
Widget chatInputBarFocusedEmpty(BuildContext context) {
  return const Scaffold(
    body: Align(
      alignment: Alignment.bottomCenter,
      child: _ChatComposerContractPreview(autofocus: true),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Focused draft',
  type: ChatInputBar,
  path: '[Core primitives]/Product composites',
)
Widget chatInputBarFocusedDraft(BuildContext context) {
  return const Scaffold(
    body: Align(
      alignment: Alignment.bottomCenter,
      child: _ChatComposerContractPreview(
        initialText: 'That last loop was fun.',
        autofocus: true,
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchRootScreenScaffold,
  path: '[Core primitives]/Navigation',
)
Widget catchRootScreenPrimaryRailContractStates(BuildContext context) {
  return const _RootScreenContractUseCase();
}

@widgetbook.UseCase(
  name: 'Root page with primary rail',
  type: CatchRootScreenPageScrollView,
  path: '[Core primitives]/Navigation',
)
Widget catchRootScreenPageContractStates(BuildContext context) {
  return const _RootScreenContractUseCase();
}

@widgetbook.UseCase(
  name: 'Readable sliver width',
  type: CatchSliverContentWidth,
  path: '[Core primitives]/Navigation',
)
Widget catchSliverContentWidthContractStates(BuildContext context) {
  return const _RootScreenContractUseCase();
}

@widgetbook.UseCase(
  name: 'Controller-backed rail',
  type: CatchTabControllerRail,
  path: '[Core primitives]/Navigation',
)
Widget catchTabControllerRailContractStates(BuildContext context) {
  return const _RootScreenContractUseCase();
}

class _RootScreenContractUseCase extends StatelessWidget {
  const _RootScreenContractUseCase();

  @override
  Widget build(BuildContext context) {
    return const _ContractScreen(
      title: 'CatchRootScreenScaffold',
      contractId: 'catch.screen_body.root_screen_scaffold',
      states: [
        'standard',
        'full-bleed',
        'primary-rail',
        'paged-primary-rail',
        'responsive-width',
        'floating-bottom-navigation',
        'side-navigation',
      ],
      children: [
        _StateCard(
          label: 'shared shell',
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: _RootScreenPrimaryRailContractDemo(),
          ),
        ),
      ],
    );
  }
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchHostRow,
  path: '[Core primitives]/Product composites',
)
Widget catchHostRowContractStates(BuildContext context) {
  return const _ContractScreen(
    title: 'CatchHostRow',
    contractId: 'catch.host_row',
    states: [
      'identity-only',
      'navigable',
      'message-enabled',
      'verified',
      'divider',
      'long-copy',
    ],
    children: [
      _StateCard(
        label: 'identity-only',
        child: CatchHostRow(
          activityKind: ActivityKind.socialRun,
          name: 'Sunday sea-face crew',
          meta: 'HOSTING SINCE FEB 2026',
        ),
      ),
      _StateCard(
        label: 'navigable / message / verified / divider',
        child: CatchHostRow(
          activityKind: ActivityKind.dinner,
          name: 'Catch supper club',
          meta: 'HOSTING SINCE MAR 2026 · REPLIES FAST',
          verified: true,
          divider: true,
          messageTooltip: 'Message host',
          onMessage: _noop,
          onTap: _noop,
        ),
      ),
      _StateCard(
        label: 'long-copy',
        child: CatchHostRow(
          activityKind: ActivityKind.openActivity,
          name: 'A deliberately long organizer identity for text-scale review',
          meta: 'LONG LOCATION AND RESPONSE METADATA',
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchMapPreview,
  path: '[Core primitives]/Product composites',
)
Widget catchMapPreviewContractStates(BuildContext context) {
  return const _ContractScreen(
    title: 'CatchMapPreview',
    contractId: 'catch.map_preview',
    states: [
      'exact-location',
      'missing-coordinate',
      'network-disabled',
      'android-lite-mode',
    ],
    children: [
      _StateCard(
        label: 'exact-location / network-disabled',
        child: SizedBox(
          height: WidgetbookPreviewLayout.mediaPanelHeight,
          child: CatchMapPreview(
            coordinate: LocationCoordinate(19.076, 72.8777),
            fallbackLabel: 'Bandra meeting point',
            enableNetworkTiles: false,
          ),
        ),
      ),
      _StateCard(
        label: 'missing-coordinate',
        child: SizedBox(
          height: WidgetbookPreviewLayout.mediaPanelHeight,
          child: CatchMapPreview(
            coordinate: null,
            fallbackLabel: 'Location unavailable',
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
    states: const ['custom', 'custom-no-safe-area'],
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
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchBottomAction,
  path: '[Core primitives]/Product composites',
)
Widget catchBottomActionContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchBottomAction',
    contractId: 'catch.bottom_action',
    states: const [
      'ios-floating',
      'android-anchored',
      'leading-content',
      'catch-line',
      'footnote',
      'scroll-overlay',
      'loading',
      'disabled',
      'rounded-button',
    ],
    children: [
      _StateCard(
        label: 'default',
        child: _DockFrame(
          child: CatchBottomAction(label: 'Book your spot', onPressed: _noop),
        ),
      ),
      _StateCard(
        label: 'leading-content',
        child: _DockFrame(
          child: CatchBottomAction(
            label: 'Join waitlist',
            leadingContent: const CatchBadge(label: '4 left'),
            onPressed: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'rounded-button',
        child: _DockFrame(
          child: CatchBottomAction(
            label: 'Review & publish',
            buttonShape: CatchButtonShape.rounded,
            onPressed: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'catch-line-footnote',
        child: _DockFrame(
          child: CatchBottomAction(
            label: 'Confirm',
            catchLine: 'FREE TO JOIN',
            footnote: 'No charge until the host approves.',
            onPressed: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'scroll-overlay',
        child: SizedBox(
          width: WidgetbookPreviewLayout.dockFrameWidth,
          height: WidgetbookPreviewLayout.bodyFrameExtent,
          child: CatchBottomActionOverlay(
            body: ListView(
              padding: CatchInsets.formStepBodyWithBottomActions,
              children: [
                for (var index = 0; index < 5; index++) ...[
                  Text('Scrolling form row ${index + 1}'),
                  const Divider(),
                  const SizedBox(height: CatchSpacing.s6),
                ],
              ],
            ),
            actions: Row(
              children: [
                Expanded(
                  child: CatchButton(
                    label: 'Save Draft',
                    variant: CatchButtonVariant.ghost,
                    size: CatchButtonSize.lg,
                    onPressed: _noop,
                  ),
                ),
                const SizedBox(width: CatchSpacing.s3),
                Expanded(
                  child: CatchButton(
                    label: 'Next',
                    size: CatchButtonSize.lg,
                    fullWidth: true,
                    onPressed: _noop,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const _StateCard(
        label: 'loading',
        child: _DockFrame(
          child: CatchBottomAction(
            label: 'Saving',
            isLoading: true,
            onPressed: null,
          ),
        ),
      ),
      const _StateCard(
        label: 'disabled',
        child: _DockFrame(
          child: CatchBottomAction(label: 'Sold out', onPressed: null),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: ClubDetailDock,
  path: '[Core primitives]/Product composites',
)
Widget clubDetailDockContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'ClubDetailDock',
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
          child: ClubDetailDock(
            state: ClubDetailDockRole.guest,
            activityKind: ActivityKind.socialRun,
            footnote: 'Sign in to request access.',
            onSignIn: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'visitor',
        child: _DockFrame(
          child: ClubDetailDock(
            state: ClubDetailDockRole.visitor,
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
          child: ClubDetailDock(
            state: ClubDetailDockRole.visitor,
            activityKind: ActivityKind.dinner,
            members: 42,
            isJoinLoading: true,
          ),
        ),
      ),
      _StateCard(
        label: 'member',
        child: _DockFrame(
          child: ClubDetailDock(
            state: ClubDetailDockRole.member,
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
          child: ClubDetailDock(
            state: ClubDetailDockRole.member,
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
          child: ClubDetailDock(
            state: ClubDetailDockRole.owner,
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
  type: CatchEventCard,
  path: '[Core primitives]/Product composites',
)
Widget catchEventCardContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchEventCard',
    contractId: 'catch.event_card',
    states: const ['ticket', 'ticket-status', 'long-copy'],
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
        label: 'long-copy',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputWidth,
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
  type: CatchGradedImage,
  path: '[Core primitives]/Media',
)
Widget catchGradedImageContractStates(BuildContext context) {
  final t = CatchTokens.of(context);
  final dinner = ActivityPalette.of(context).forKind(ActivityKind.dinner);

  Widget swatch(Color color) => SizedBox(
    width: WidgetbookPreviewLayout.surfaceCardWidth,
    height: WidgetbookPreviewLayout.compactPanelHeight,
    child: DecoratedBox(decoration: BoxDecoration(color: color)),
  );

  return _ContractScreen(
    title: 'CatchGradedImage',
    contractId: 'catch.graded_image',
    states: const ['enabled', 'disabled', 'light-image', 'dark-image'],
    children: [
      _StateCard(
        label: 'enabled',
        child: CatchGradedImage(child: swatch(dinner.accent)),
      ),
      _StateCard(
        label: 'disabled',
        child: CatchGradedImage(enabled: false, child: swatch(dinner.accent)),
      ),
      _StateCard(
        label: 'light-image',
        child: CatchGradedImage(child: swatch(t.raised)),
      ),
      _StateCard(
        label: 'dark-image',
        child: CatchGradedImage(child: swatch(CatchTokens.editorialBlack)),
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
          width: WidgetbookPreviewLayout.mediaPanelWidth,
          height: WidgetbookPreviewLayout.mediaPanelHeight,
          child: CatchDetailHeroBackdrop(
            imageUrl: 'https://example.invalid/catch-detail-photo.jpg',
            semanticLabel: 'Event photo',
          ),
        ),
      ),
      _StateCard(
        label: 'fallback-gradient',
        child: SizedBox(
          width: WidgetbookPreviewLayout.mediaPanelWidth,
          height: WidgetbookPreviewLayout.mediaPanelHeight,
          child: CatchDetailHeroBackdrop(),
        ),
      ),
      _StateCard(
        label: 'scrim',
        child: SizedBox(
          width: WidgetbookPreviewLayout.mediaPanelWidth,
          height: WidgetbookPreviewLayout.mediaPanelHeight,
          child: CatchDetailHeroBackdrop(showScrim: true),
        ),
      ),
      _StateCard(
        label: 'no-scrim',
        child: SizedBox(
          width: WidgetbookPreviewLayout.mediaPanelWidth,
          height: WidgetbookPreviewLayout.mediaPanelHeight,
          child: CatchDetailHeroBackdrop(showScrim: false),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchDetailHeroFallback,
  path: '[Core primitives]/Media',
)
Widget catchDetailHeroFallbackContractStates(BuildContext context) {
  return const _ContractScreen(
    title: 'CatchDetailHeroFallback',
    contractId: 'catch.detail_media.fallback',
    states: ['gradient'],
    children: [
      _StateCard(
        label: 'gradient',
        child: SizedBox(
          width: WidgetbookPreviewLayout.mediaPanelWidth,
          height: WidgetbookPreviewLayout.mediaPanelHeight,
          child: CatchDetailHeroFallback(),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchScrim,
  path: '[Core primitives]/Media',
)
Widget catchScrimContractStates(BuildContext context) {
  final t = CatchTokens.of(context);
  final walking = ActivityPalette.of(context).forKind(ActivityKind.walking);

  return _ContractScreen(
    title: 'CatchScrim',
    contractId: 'catch.detail_media.scrim',
    states: ['detail-hero', 'photo-frame', 'hero-tint'],
    children: [
      _StateCard(
        label: 'detail hero',
        child: SizedBox(
          width: WidgetbookPreviewLayout.mediaPanelWidth,
          height: WidgetbookPreviewLayout.mediaPanelHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(color: CatchTokens.editorialBlack),
            child: CatchScrim.detailHero(),
          ),
        ),
      ),
      _StateCard(
        label: 'photo frame',
        child: SizedBox(
          width: WidgetbookPreviewLayout.narrowComponentWidth,
          height: WidgetbookPreviewLayout.stateViewportHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [walking.accent, CatchTokens.editorialBlack],
              ),
            ),
            child: CatchScrim.photoFrame(),
          ),
        ),
      ),
      _StateCard(
        label: 'profile hero tint',
        child: SizedBox(
          width: WidgetbookPreviewLayout.narrowComponentWidth,
          height: WidgetbookPreviewLayout.tallNarrowPanelHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(color: t.ink),
            child: CatchScrim.heroTint(base: t.ink),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchEventThumbnailActivityFallback,
  path: '[Core primitives]/Media',
)
Widget catchEventThumbnailActivityFallbackContractStates(BuildContext context) {
  return const _ContractScreen(
    title: 'CatchEventThumbnailActivityFallback',
    contractId: 'catch.event_card.event_thumbnail.activity_fallback',
    states: ['run', 'dinner', 'large-icon'],
    children: [
      _StateCard(
        label: 'activity fallbacks',
        child: _InlineWrap(
          children: [
            SizedBox(
              width: WidgetbookPreviewLayout.thumbnailWidth,
              height: WidgetbookPreviewLayout.thumbnailHeight,
              child: CatchEventThumbnailActivityFallback(
                activityKind: ActivityKind.socialRun,
              ),
            ),
            SizedBox(
              width: WidgetbookPreviewLayout.thumbnailWidth,
              height: WidgetbookPreviewLayout.thumbnailHeight,
              child: CatchEventThumbnailActivityFallback(
                activityKind: ActivityKind.dinner,
              ),
            ),
            SizedBox(
              width: WidgetbookPreviewLayout.thumbnailWidth,
              height: WidgetbookPreviewLayout.thumbnailHeight,
              child: CatchEventThumbnailActivityFallback(
                activityKind: ActivityKind.pickleball,
                iconSize: 92,
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
  type: CatchEventThumbnailScrimOverlay,
  path: '[Core primitives]/Media',
)
Widget catchEventThumbnailScrimOverlayContractStates(BuildContext context) {
  return const _ContractScreen(
    title: 'CatchEventThumbnailScrimOverlay',
    contractId: 'catch.event_card.event_thumbnail.scrim',
    states: ['bottom', 'full'],
    children: [
      _StateCard(
        label: 'scrim styles',
        child: _InlineWrap(
          children: [
            SizedBox(
              width: WidgetbookPreviewLayout.thumbnailWidth,
              height: WidgetbookPreviewLayout.thumbnailHeight,
              child: CatchEventThumbnailScrimOverlay(
                style: CatchEventThumbnailScrim.bottom,
              ),
            ),
            SizedBox(
              width: WidgetbookPreviewLayout.thumbnailWidth,
              height: WidgetbookPreviewLayout.thumbnailHeight,
              child: CatchEventThumbnailScrimOverlay(
                style: CatchEventThumbnailScrim.full,
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
          width: WidgetbookPreviewLayout.standardContractWidth,
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
          width: WidgetbookPreviewLayout.standardContractWidth,
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
          width: WidgetbookPreviewLayout.standardContractWidth,
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
          width: WidgetbookPreviewLayout.standardContractWidth,
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
          width: WidgetbookPreviewLayout.standardContractWidth,
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
          width: WidgetbookPreviewLayout.standardContractWidth,
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
          borderWidth: CatchStroke.avatarRing,
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
  type: CatchPersonAvatarShell,
  path: '[Core primitives]/People',
)
Widget catchPersonAvatarShellContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchPersonAvatarShell',
    contractId: 'catch.person_avatar.shell',
    states: const ['circle', 'square'],
    children: [
      _StateCard(
        label: 'circle',
        child: CatchPersonAvatarShell(
          size: 56,
          child: ColoredBox(color: t.primarySoft),
        ),
      ),
      _StateCard(
        label: 'square',
        child: CatchPersonAvatarShell(
          size: 56,
          shape: CatchPersonAvatarShape.square,
          child: ColoredBox(color: t.raised),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchObscuredAvatarContent,
  path: '[Core primitives]/People',
)
Widget catchObscuredAvatarContentContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchObscuredAvatarContent',
    contractId: 'catch.person_avatar.obscured_content',
    states: const ['default'],
    children: [
      _StateCard(
        label: 'default',
        child: SizedBox.square(
          dimension: WidgetbookPreviewLayout.avatarPreviewExtent,
          child: CatchObscuredAvatarContent(
            child: ColoredBox(color: t.primarySoft),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchVeiledPersonAvatar,
  path: '[Core primitives]/People',
)
Widget catchVeiledPersonAvatarContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchVeiledPersonAvatar',
    contractId: 'catch.person_avatar.veiled',
    states: const ['run', 'dinner'],
    children: [
      _StateCard(
        label: 'run',
        child: CatchVeiledPersonAvatar(
          size: 48,
          activityKind: ActivityKind.socialRun,
          borderWidth: CatchStroke.avatarRing,
          borderColor: t.surface,
        ),
      ),
      _StateCard(
        label: 'dinner',
        child: CatchVeiledPersonAvatar(
          size: 48,
          activityKind: ActivityKind.dinner,
          borderWidth: CatchStroke.avatarRing,
          borderColor: t.surface,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchActivityInitialsPlaceholder,
  path: '[Core primitives]/People',
)
Widget catchActivityInitialsPlaceholderContractStates(BuildContext context) {
  return const _ContractScreen(
    title: 'CatchActivityInitialsPlaceholder',
    contractId: 'catch.person_avatar.activity_initials',
    states: ['initials', 'dim', 'empty'],
    children: [
      _StateCard(
        label: 'initials',
        child: SizedBox.square(
          dimension: WidgetbookPreviewLayout.avatarPreviewExtent,
          child: CatchActivityInitialsPlaceholder(
            kind: ActivityKind.socialRun,
            initials: 'SR',
            size: 56,
          ),
        ),
      ),
      _StateCard(
        label: 'dim',
        child: SizedBox.square(
          dimension: WidgetbookPreviewLayout.avatarPreviewExtent,
          child: CatchActivityInitialsPlaceholder(
            kind: ActivityKind.dinner,
            initials: 'DN',
            size: 56,
            dim: true,
          ),
        ),
      ),
      _StateCard(
        label: 'empty',
        child: SizedBox.square(
          dimension: WidgetbookPreviewLayout.avatarPreviewExtent,
          child: CatchActivityInitialsPlaceholder(
            kind: ActivityKind.yoga,
            initials: '',
            size: 56,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchInitialsAvatarPlaceholder,
  path: '[Core primitives]/People',
)
Widget catchInitialsAvatarPlaceholderContractStates(BuildContext context) {
  return const _ContractScreen(
    title: 'CatchInitialsAvatarPlaceholder',
    contractId: 'catch.person_avatar.initials',
    states: ['derived', 'explicit', 'empty'],
    children: [
      _StateCard(
        label: 'derived',
        child: SizedBox.square(
          dimension: WidgetbookPreviewLayout.avatarPreviewExtent,
          child: CatchInitialsAvatarPlaceholder(name: 'Aanya Rao', size: 56),
        ),
      ),
      _StateCard(
        label: 'explicit',
        child: SizedBox.square(
          dimension: WidgetbookPreviewLayout.avatarPreviewExtent,
          child: CatchInitialsAvatarPlaceholder(
            name: 'Host team',
            initials: 'HT',
            size: 56,
          ),
        ),
      ),
      _StateCard(
        label: 'empty',
        child: SizedBox.square(
          dimension: WidgetbookPreviewLayout.avatarPreviewExtent,
          child: CatchInitialsAvatarPlaceholder(name: '', size: 56),
        ),
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
      'directory',
      'directory-large-text',
    ],
    children: [
      _StateCard(
        label: 'directory',
        child: CatchPersonRow.directory(
          data: const CatchPersonRowData(name: 'Ananya Rao'),
          metadata: const Text('8 events · Last seen 18 June'),
          contextContent: const Text('Returning customer'),
          status: const CatchBadge.status(
            label: 'Regular',
            tone: CatchBadgeTone.affinity,
          ),
          onTap: () {},
        ),
      ),
      _StateCard(
        label: 'directory-large-text',
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: CatchPersonRow.directory(
            data: const CatchPersonRowData(
              name: 'Ananya Rao with a longer family name',
            ),
            metadata: const Text('8 events · Last seen 18 June'),
            contextContent: const Text(
              'Returning customer with complete contextual information',
            ),
            status: const CatchBadge.status(
              label: 'Needs identity review',
              tone: CatchBadgeTone.warning,
            ),
            onTap: () {},
          ),
        ),
      ),
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
  type: CatchPersonChatLayout,
  path: '[Core primitives]/Product composites',
)
Widget catchPersonChatLayoutContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchPersonChatLayout',
    contractId: 'catch.person_row.chat_layout',
    states: const ['default', 'context', 'typing', 'unread', 'long-copy'],
    children: const [
      _StateCard(
        label: 'default',
        child: SizedBox(
          width: WidgetbookPreviewLayout.mediumComponentWidth,
          child: CatchPersonChatLayout(
            data: CatchPersonRowData(
              name: 'Isha Mehta',
              lastMessage: 'See you by the host stand.',
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'context',
        child: SizedBox(
          width: WidgetbookPreviewLayout.mediumComponentWidth,
          child: CatchPersonChatLayout(
            data: CatchPersonRowData(
              name: 'Isha Mehta',
              contextLine: 'Sundowner 5K',
              lastMessage: 'See you by the host stand.',
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'typing',
        child: SizedBox(
          width: WidgetbookPreviewLayout.mediumComponentWidth,
          child: CatchPersonChatLayout(
            data: CatchPersonRowData(
              name: 'Isha Mehta',
              lastMessage: 'Draft message',
              isTyping: true,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'unread',
        child: SizedBox(
          width: WidgetbookPreviewLayout.mediumComponentWidth,
          child: CatchPersonChatLayout(
            data: CatchPersonRowData(
              name: 'Isha Mehta',
              lastMessage: 'I just joined the event.',
              unreadCount: 2,
              isFresh: true,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'long-copy',
        child: SizedBox(
          width: WidgetbookPreviewLayout.mediumComponentWidth,
          child: CatchPersonChatLayout(
            data: CatchPersonRowData(
              name: 'A very long display name that should ellipsize',
              lastMessage:
                  'This is a very long latest message preview that should truncate cleanly inside the inbox row.',
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchPersonChatTrailing,
  path: '[Core primitives]/Product composites',
)
Widget catchPersonChatTrailingContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchPersonChatTrailing',
    contractId: 'catch.person_row.chat_trailing',
    states: const ['timestamp', 'unread', 'new-dot'],
    children: const [
      _StateCard(
        label: 'timestamp',
        child: CatchPersonChatTrailing(
          data: CatchPersonRowData(
            name: 'Isha Mehta',
            lastMessage: 'See you there.',
            timestamp: '9m',
          ),
        ),
      ),
      _StateCard(
        label: 'unread',
        child: CatchPersonChatTrailing(
          data: CatchPersonRowData(
            name: 'Isha Mehta',
            lastMessage: 'I just joined the event.',
            timestamp: '1h',
            unreadCount: 2,
            isFresh: true,
          ),
        ),
      ),
      _StateCard(
        label: 'new-dot',
        child: CatchPersonChatTrailing(
          data: CatchPersonRowData(
            name: 'Isha Mehta',
            lastMessage: 'You matched!',
            timestamp: '2m',
            showFreshDot: true,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchPersonUnreadCountPill,
  path: '[Core primitives]/Product composites',
)
Widget catchPersonUnreadCountPillContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchPersonUnreadCountPill',
    contractId: 'catch.person_row.unread_count_pill',
    states: const ['single', 'many', 'capped'],
    children: const [
      _StateCard(label: 'single', child: CatchPersonUnreadCountPill(count: 1)),
      _StateCard(label: 'many', child: CatchPersonUnreadCountPill(count: 12)),
      _StateCard(
        label: 'capped',
        child: CatchPersonUnreadCountPill(count: 118),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchPersonNewMatchDot,
  path: '[Core primitives]/Product composites',
)
Widget catchPersonNewMatchDotContractStates(BuildContext context) {
  return const _ContractScreen(
    title: 'CatchPersonNewMatchDot',
    contractId: 'catch.person_row.new_match_dot',
    states: ['default'],
    children: [
      _StateCard(
        label: 'default',
        child: Padding(
          padding: EdgeInsets.all(CatchSpacing.s6),
          child: CatchPersonNewMatchDot(),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchPersonRosterLayout,
  path: '[Core primitives]/Product composites',
)
Widget catchPersonRosterLayoutContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchPersonRosterLayout',
    contractId: 'catch.person_row.roster_layout',
    states: const ['meta', 'context', 'long-copy'],
    children: const [
      _StateCard(
        label: 'meta',
        child: SizedBox(
          width: WidgetbookPreviewLayout.mediumComponentWidth,
          child: CatchPersonRosterLayout(
            data: CatchPersonRowData(name: 'Aanya Rao', metaLine: '5:20 /km'),
          ),
        ),
      ),
      _StateCard(
        label: 'context',
        child: SizedBox(
          width: WidgetbookPreviewLayout.mediumComponentWidth,
          child: CatchPersonRosterLayout(
            data: CatchPersonRowData(
              name: 'Aanya Rao',
              metaLine: '5:20 /km',
              contextLine: 'Sundowner 5K',
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'long-copy',
        child: SizedBox(
          width: WidgetbookPreviewLayout.mediumComponentWidth,
          child: CatchPersonRosterLayout(
            data: CatchPersonRowData(
              name: 'A very long roster name that should ellipsize',
              metaLine:
                  'A very long roster metadata line that should truncate inside the row.',
              contextLine:
                  'A very long event context that should stay inside the available width.',
            ),
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
        label: 'waitlist promotion',
        child: _NotificationFrame(
          child: NotificationRow(
            type: ActivityNotificationType.waitlistPromotion,
            title: 'You are off the waitlist',
            time: '1d',
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

void _ignoreBool(bool _) {}

void _ignoreString(String value) {}

final _contractTabBarItems = [
  CatchTabBarItem<String>(
    id: 'explore',
    icon: CatchIcons.homeOutlined,
    activeIcon: CatchIcons.homeRounded,
    label: 'Explore',
  ),
  CatchTabBarItem<String>(
    id: 'clubs',
    icon: CatchIcons.groupsOutlined,
    activeIcon: CatchIcons.groupsRounded,
    label: 'Clubs',
  ),
  CatchTabBarItem<String>(
    id: 'matches',
    icon: CatchIcons.chatBubbleOutlineRounded,
    activeIcon: CatchIcons.chatBubbleRounded,
    label: 'Chats',
    badgeCount: 3,
  ),
];

final _contractFourTabBarItems = [
  CatchTabBarItem<String>(
    id: 'home',
    icon: CatchIcons.homeOutlined,
    activeIcon: CatchIcons.homeRounded,
    label: 'Home',
  ),
  ..._contractTabBarItems,
];

const _contractDialogActions = [
  CatchDialogAction(label: 'Cancel', value: false),
  CatchDialogAction(label: 'Confirm', value: true, isDefault: true),
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
                CatchBadge.functional(label: behaviorId),
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
    return SizedBox(
      width: WidgetbookPreviewLayout.dockFrameWidth,
      child: child,
    );
  }
}

class _ChatTileFrame extends StatelessWidget {
  const _ChatTileFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      width: WidgetbookPreviewLayout.wideContractWidth,
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
      width: WidgetbookPreviewLayout.wideContractWidth,
      tone: CatchSurfaceTone.surface,
      borderColor: t.line,
      padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s4),
      child: child,
    );
  }
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchFadeScaleViewport,
  path: '[Core primitives]/Motion',
)
Widget catchMotionViewportContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'Motion viewport',
    contractId: 'catch.motion_viewport',
    states: const ['initial', 'mid-transition', 'settled'],
    children: [
      for (final pose in const [
        ('initial', 0.0),
        ('mid-transition', 0.5),
        ('settled', 1.0),
      ])
        _StateCard(
          label: pose.$1,
          child: CatchFadeScaleViewport(
            animation: AlwaysStoppedAnimation<double>(pose.$2),
            child: CatchSurface.card(
              child: Text(
                'Route content',
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
  type: CatchTimestampedMessageText,
  path: '[Core primitives]/Data display',
)
Widget catchTimestampedMessageContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'Timestamped message',
    contractId: 'catch.timestamped_message',
    states: const [
      'inline-timestamp',
      'stacked-timestamp',
      'empty-message',
      'large-text',
    ],
    children: [
      for (final example in const [
        ('inline-timestamp', 'Hi!', '19:30', 240.0),
        ('stacked-timestamp', 'See you', '19:30', 80.0),
        ('empty-message', '', '19:30', 240.0),
      ])
        _StateCard(
          label: example.$1,
          child: SizedBox(
            width: example.$4,
            child: CatchTimestampedMessageText(
              text: example.$2,
              timestamp: example.$3,
              textStyle: CatchTextStyles.bodyM(context),
              timestampStyle: CatchTextStyles.numericMeta(context),
            ),
          ),
        ),
    ],
  );
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
                CatchBadge.functional(label: contractId),
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
          Text(label, style: CatchTextStyles.labelM(context, color: t.primary)),
          if (description != null) ...[
            const SizedBox(height: CatchSpacing.s2),
            Text(
              description!,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ],
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
            CatchBadge.functional(label: label),
            if (description != null) ...[
              const SizedBox(width: CatchSpacing.s3),
              Expanded(
                child: Text(
                  description!,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
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
    return SizedBox(
      width: WidgetbookPreviewLayout.wideContractWidth,
      child: child,
    );
  }
}

class _OptionWidth extends StatelessWidget {
  const _OptionWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: WidgetbookPreviewLayout.standardContractWidth,
      child: child,
    );
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
      width: WidgetbookPreviewLayout.wideContractWidth,
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
      width: WidgetbookPreviewLayout.standardContractWidth,
      borderColor: t.line,
      padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s4),
      child: SizedBox(
        height: WidgetbookPreviewLayout.navigationBarHeight,
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
      width: WidgetbookPreviewLayout.compactComponentWidth,
      height: MediaQuery.textScalerOf(context).scale(1) >= 2
          ? WidgetbookPreviewLayout.tallNarrowPanelHeight
          : WidgetbookPreviewLayout.photoLikePanelHeight,
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
      width: WidgetbookPreviewLayout.standardContractWidth,
      height: WidgetbookPreviewLayout.bodyFrameExtent,
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
      child: Text(label, style: CatchTextStyles.supporting(context)),
    );
  }
}

class _ToggleFieldDemo extends StatefulWidget {
  const _ToggleFieldDemo({this.initialValue = true});

  final bool initialValue;

  @override
  State<_ToggleFieldDemo> createState() => _ToggleFieldDemoState();
}

class _ToggleFieldDemoState extends State<_ToggleFieldDemo> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.initialValue;
  }

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
  const _TextEntryFieldDemo({this.autofocus = false});

  final bool autofocus;

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
      emptyValueText: 'Add a public name',
      inputHint: 'e.g. Aanya',
      autofocus: widget.autofocus,
      showClearButton: true,
      onChanged: (_) => setState(() {}),
    );
  }
}

class _ChoiceFieldDemo extends StatefulWidget {
  const _ChoiceFieldDemo({
    this.initiallyOpen = false,
    this.allowEmptySelection = false,
    this.initialSelection = const {'English', 'Hindi', 'Marathi'},
    this.body,
    this.isOptional = false,
  });

  final bool initiallyOpen;
  final bool allowEmptySelection;
  final Set<String> initialSelection;
  final String? body;
  final bool isOptional;

  @override
  State<_ChoiceFieldDemo> createState() => _ChoiceFieldDemoState();
}

class _ChoiceFieldDemoState extends State<_ChoiceFieldDemo> {
  static const _values = ['English', 'Hindi', 'Marathi', 'Tamil', 'Gujarati'];
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.of(widget.initialSelection);
  }

  @override
  void didUpdateWidget(covariant _ChoiceFieldDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!setEquals(oldWidget.initialSelection, widget.initialSelection)) {
      _selected = Set<String>.of(widget.initialSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CatchField.choices<String>(
      title: 'Languages',
      body: widget.body,
      icon: CatchIcons.languageOutlined,
      values: _values,
      itemLabel: (value) => value,
      selected: _selected,
      multi: true,
      allowEmptySelection: widget.allowEmptySelection,
      isOptional: widget.isOptional,
      initiallyOpen: widget.initiallyOpen,
      onSelectionChanged: (selection) {
        setState(() => _selected = selection);
      },
      onCancel: _noop,
      onSubmit: _noop,
    );
  }
}

class _StepperFieldDemo extends StatefulWidget {
  const _StepperFieldDemo();

  @override
  State<_StepperFieldDemo> createState() => _StepperFieldDemoState();
}

class _StepperFieldDemoState extends State<_StepperFieldDemo> {
  num _value = 168;

  @override
  Widget build(BuildContext context) {
    return CatchField.stepper(
      title: 'Height',
      body: '${_value.toInt()} cm',
      icon: CatchIcons.heightOutlined,
      value: _value,
      min: 120,
      max: 220,
      unit: 'cm',
      initiallyOpen: true,
      decreaseSemanticLabel: 'Decrease height',
      increaseSemanticLabel: 'Increase height',
      onChanged: (value) => setState(() => _value = value),
      onCancel: _noop,
      onSubmit: _noop,
    );
  }
}

class _ExplicitSaveFieldDemo extends StatefulWidget {
  const _ExplicitSaveFieldDemo({
    this.initiallyExpanded = false,
    this.isLoading = false,
    this.error,
  });

  final bool initiallyExpanded;
  final bool isLoading;
  final String? error;

  @override
  State<_ExplicitSaveFieldDemo> createState() => _ExplicitSaveFieldDemoState();
}

class _ExplicitSaveFieldDemoState extends State<_ExplicitSaveFieldDemo> {
  late final TextEditingController _controller;
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: 'Catch me if you can');
    _expanded = widget.initiallyExpanded;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CatchField.inputActions(
      title: 'A perfect event with me looks like...',
      controller: _controller,
      icon: CatchIcons.formatQuoteRounded,
      open: _expanded,
      onOpenChanged: (expanded) => setState(() => _expanded = expanded),
      supporting: const Text('19 / 300'),
      secondaryAction: CatchTextButton(
        label: 'Change prompt',
        onPressed: _noop,
        padding: EdgeInsets.zero,
      ),
      error: widget.error,
      isLoading: widget.isLoading,
      onCancel: () => setState(() => _expanded = false),
      onSubmit: _noop,
      maxLines: null,
      textInputAction: TextInputAction.newline,
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

class _ChatComposerContractPreview extends StatefulWidget {
  const _ChatComposerContractPreview({
    this.initialText = '',
    this.sending = false,
    this.sendingImage = false,
    this.disabledReason,
    this.showImageButton = true,
    this.autofocus = false,
  });

  final String initialText;
  final bool sending;
  final bool sendingImage;
  final String? disabledReason;
  final bool showImageButton;
  final bool autofocus;

  @override
  State<_ChatComposerContractPreview> createState() =>
      _ChatComposerContractPreviewState();
}

class _ChatComposerContractPreviewState
    extends State<_ChatComposerContractPreview> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChatInputBar(
      controller: _controller,
      sending: widget.sending,
      sendingImage: widget.sendingImage,
      disabledReason: widget.disabledReason,
      showImageButton: widget.showImageButton,
      autofocus: widget.autofocus,
      onSend: widget.disabledReason == null ? _noop : null,
      onSendImage: widget.disabledReason == null ? _noop : null,
    );
  }
}

class _RootScreenPrimaryRailContractDemo extends StatefulWidget {
  const _RootScreenPrimaryRailContractDemo();

  @override
  State<_RootScreenPrimaryRailContractDemo> createState() =>
      _RootScreenPrimaryRailContractDemoState();
}

class _RootScreenPrimaryRailContractDemoState
    extends State<_RootScreenPrimaryRailContractDemo>
    with SingleTickerProviderStateMixin {
  late final TabController _controller = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CatchRootScreenScaffold.withPrimaryRail(
      header: const CatchRootScreenHeader.title(
        eyebrow: 'YOUR SPACE',
        title: 'Root workspace',
        subtitle: 'Independent page scroll state',
      ),
      semanticsLabel: 'Root primary-rail contract preview',
      primaryRail: CatchTabControllerRail<String>(
        controller: _controller,
        options: const [
          CatchOption(value: 'edit', label: 'Edit'),
          CatchOption(value: 'preview', label: 'Preview'),
        ],
      ),
      body: CatchRootScreenBody.paged(
        controller: _controller,
        pages: const [
          CatchRootScreenPageSpec.scroll(
            page: CatchRootScreenPageScrollView.standard(
              scrollKey: PageStorageKey<String>('contract-tab-edit'),
              slivers: [
                SliverToBoxAdapter(
                  child: Text('Edit owns this scroll position.'),
                ),
              ],
            ),
          ),
          CatchRootScreenPageSpec.scroll(
            page: CatchRootScreenPageScrollView.standard(
              scrollKey: PageStorageKey<String>('contract-tab-preview'),
              slivers: [
                SliverToBoxAdapter(
                  child: Text('Preview owns a separate scroll position.'),
                ),
              ],
            ),
          ),
        ],
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
      width: MediaQuery.textScalerOf(context).scale(1) >= 2
          ? WidgetbookPreviewLayout.mediumComponentWidth
          : WidgetbookPreviewLayout.surfaceSpecWidth,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: CatchTextStyles.fieldRowTitle(context, color: color),
          ),
          const SizedBox(height: CatchSpacing.s2),
          Text(
            onTap == null ? 'Static panel' : 'Tap target',
            style: CatchTextStyles.supporting(
              context,
              color: color.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}
