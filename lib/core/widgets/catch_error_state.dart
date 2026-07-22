import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_icon.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

enum CatchErrorStateMode { fullScreen, inline, compact }

/// Canonical exit affordance for terminal error states where retry is not a
/// truthful action (for example a deleted event or an unauthorized route).
class CatchErrorBackAction extends StatelessWidget {
  const CatchErrorBackAction({super.key, this.label, this.onPressed});

  final String? label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CatchButton(
      label: label ?? MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      variant: CatchButtonVariant.secondary,
      icon: Icon(CatchIcons.arrowBackIosNewRounded),
    );
  }
}

class CatchErrorState extends StatelessWidget {
  const CatchErrorState({
    super.key,
    required this.title,
    required this.message,
    this.icon = CatchIcons.errorOutlineRounded,
    this.onRetry,
    this.retryLabel,
    this.secondaryAction,
    this.mode = CatchErrorStateMode.fullScreen,
  });

  factory CatchErrorState.fromError(
    Object error, {
    Key? key,
    AppErrorContext context = AppErrorContext.generic,
    VoidCallback? onRetry,
    String? retryLabel,
    Widget? secondaryAction,
    CatchErrorStateMode mode = CatchErrorStateMode.fullScreen,
    IconData? icon,
  }) {
    return _LocalizedCatchErrorState(
      key: key,
      error: error,
      errorContext: context,
      onRetry: onRetry,
      retryLabel: retryLabel,
      icon: icon,
      secondaryAction: secondaryAction,
      mode: mode,
    );
  }

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final Widget? secondaryAction;
  final CatchErrorStateMode mode;

  @override
  Widget build(BuildContext context) {
    return CatchErrorBody(
      title: title,
      message: message,
      icon: icon,
      onRetry: onRetry,
      retryLabel: retryLabel,
      secondaryAction: secondaryAction,
      mode: mode,
    );
  }
}

class CatchErrorBody extends StatelessWidget {
  const CatchErrorBody({
    super.key,
    required this.title,
    required this.message,
    this.icon = CatchIcons.errorOutlineRounded,
    this.onRetry,
    this.retryLabel,
    this.secondaryAction,
    this.mode = CatchErrorStateMode.fullScreen,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final Widget? secondaryAction;
  final CatchErrorStateMode mode;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final isCompact = mode == CatchErrorStateMode.compact;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CatchErrorIcon(
          icon: icon,
          extent: isCompact ? 48 : 64,
          iconSize: isCompact ? 24 : 30,
        ),
        SizedBox(height: isCompact ? CatchSpacing.s3 : CatchSpacing.s4),
        Text(
          title,
          style: isCompact
              ? CatchTextStyles.sectionTitle(context)
              : CatchTextStyles.titleL(context),
          textAlign: TextAlign.center,
        ),
        gapH8,
        Text(
          message,
          style: CatchTextStyles.bodyLead(context, color: t.ink2),
          textAlign: TextAlign.center,
          // Cap message lines because unhandled exceptions can serialize stack
          // traces into `error.toString()` and otherwise consume the viewport.
          maxLines: isCompact ? 4 : 8,
          overflow: TextOverflow.ellipsis,
        ),
        if (onRetry != null || secondaryAction != null) ...[
          SizedBox(height: isCompact ? CatchSpacing.s3 : CatchSpacing.s4),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: CatchSpacing.s3,
            runSpacing: CatchSpacing.s2,
            children: [
              if (onRetry != null)
                CatchButton(
                  label: retryLabel ?? context.l10n.sharedActionTryAgain,
                  onPressed: onRetry,
                  size: isCompact ? CatchButtonSize.sm : CatchButtonSize.md,
                  icon: Icon(CatchIcons.refreshRounded),
                ),
              ?secondaryAction,
            ],
          ),
        ],
      ],
    );

    if (mode == CatchErrorStateMode.inline ||
        mode == CatchErrorStateMode.compact) {
      return CatchSurface(
        padding: EdgeInsets.all(isCompact ? CatchSpacing.s4 : CatchSpacing.s5),
        borderColor: t.line,
        child: content,
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(CatchSpacing.s5),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: content,
        ),
      ),
    );
  }
}

@immutable
class _CatchErrorSpec {
  const _CatchErrorSpec({
    required this.title,
    required this.message,
    required this.icon,
    required this.retryLabel,
    this.onRetry,
    this.secondaryAction,
  });

  factory _CatchErrorSpec.fromError(
    Object error, {
    required AppLocalizations l10n,
    AppErrorContext context = AppErrorContext.generic,
    VoidCallback? onRetry,
    String? retryLabel,
    IconData? icon,
    Widget? secondaryAction,
  }) {
    final descriptor = appErrorDescriptor(error, l10n: l10n, context: context);
    return _CatchErrorSpec(
      title: descriptor.title,
      message: descriptor.message,
      icon: icon ?? descriptor.icon,
      // An explicit recovery callback is authoritative. Error metadata still
      // controls inferred actions, but must never silently discard a recovery
      // path the caller knows is safe (for example reloading after rules or
      // deployment configuration catches up).
      onRetry: onRetry,
      retryLabel: retryLabel ?? descriptor.retryLabel,
      secondaryAction: secondaryAction,
    );
  }

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String retryLabel;
  final Widget? secondaryAction;
}

class _LocalizedCatchErrorState extends CatchErrorState {
  const _LocalizedCatchErrorState({
    super.key,
    required this.error,
    required this.errorContext,
    VoidCallback? onRetry,
    String? retryLabel,
    IconData? icon,
    Widget? secondaryAction,
    required super.mode,
  }) : retry = onRetry,
       retryLabelOverride = retryLabel,
       iconOverride = icon,
       secondaryActionOverride = secondaryAction,
       super(title: '', message: '');

  final Object error;
  final AppErrorContext errorContext;
  final VoidCallback? retry;
  final String? retryLabelOverride;
  final IconData? iconOverride;
  final Widget? secondaryActionOverride;

  @override
  Widget build(BuildContext context) {
    final spec = _CatchErrorSpec.fromError(
      error,
      l10n: context.l10n,
      context: errorContext,
      onRetry: retry,
      retryLabel: retryLabelOverride,
      icon: iconOverride,
      secondaryAction: secondaryActionOverride,
    );
    return CatchErrorBody(
      title: spec.title,
      message: spec.message,
      icon: spec.icon,
      onRetry: spec.onRetry,
      retryLabel: spec.retryLabel,
      secondaryAction: spec.secondaryAction,
      mode: mode,
    );
  }
}

class CatchErrorScaffold extends StatelessWidget {
  const CatchErrorScaffold({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel,
    this.secondaryAction,
    this.icon = CatchIcons.errorOutlineRounded,
    this.backgroundColor,
  });

  factory CatchErrorScaffold.fromError(
    Object error, {
    Key? key,
    AppErrorContext context = AppErrorContext.generic,
    VoidCallback? onRetry,
    String? retryLabel,
    IconData? icon,
    Widget? secondaryAction,
  }) {
    return _LocalizedCatchErrorScaffold(
      key: key,
      error: error,
      errorContext: context,
      retry: onRetry,
      retryLabelOverride: retryLabel,
      iconOverride: icon,
      secondaryActionOverride: secondaryAction,
    );
  }

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final Widget? secondaryAction;
  final IconData icon;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? CatchTokens.of(context).bg,
      body: SafeArea(
        child: CatchErrorBody(
          title: title,
          message: message,
          icon: icon,
          onRetry: onRetry,
          retryLabel: retryLabel,
          secondaryAction: secondaryAction,
        ),
      ),
    );
  }
}

class _LocalizedCatchErrorScaffold extends CatchErrorScaffold {
  const _LocalizedCatchErrorScaffold({
    super.key,
    required this.error,
    required this.errorContext,
    required this.retry,
    required this.retryLabelOverride,
    required this.iconOverride,
    required this.secondaryActionOverride,
  }) : super(title: '', message: '');

  final Object error;
  final AppErrorContext errorContext;
  final VoidCallback? retry;
  final String? retryLabelOverride;
  final IconData? iconOverride;
  final Widget? secondaryActionOverride;

  @override
  Widget build(BuildContext context) {
    final spec = _CatchErrorSpec.fromError(
      error,
      l10n: context.l10n,
      context: errorContext,
      onRetry: retry,
      retryLabel: retryLabelOverride,
      icon: iconOverride,
      secondaryAction: secondaryActionOverride,
    );
    return Scaffold(
      backgroundColor: CatchTokens.of(context).bg,
      body: SafeArea(
        child: CatchErrorBody(
          title: spec.title,
          message: spec.message,
          icon: spec.icon,
          onRetry: spec.onRetry,
          retryLabel: spec.retryLabel,
          secondaryAction: spec.secondaryAction,
        ),
      ),
    );
  }
}

class CatchSliverErrorState extends StatelessWidget {
  const CatchSliverErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel,
    this.secondaryAction,
    this.icon = CatchIcons.errorOutlineRounded,
    this.fillRemaining = true,
  });

  factory CatchSliverErrorState.fromError(
    Object error, {
    Key? key,
    AppErrorContext context = AppErrorContext.generic,
    VoidCallback? onRetry,
    String? retryLabel,
    IconData? icon,
    Widget? secondaryAction,
    bool fillRemaining = true,
  }) {
    return _LocalizedCatchSliverErrorState(
      key: key,
      error: error,
      errorContext: context,
      retry: onRetry,
      retryLabelOverride: retryLabel,
      iconOverride: icon,
      secondaryActionOverride: secondaryAction,
      fillRemaining: fillRemaining,
    );
  }

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final Widget? secondaryAction;
  final IconData icon;
  final bool fillRemaining;

  @override
  Widget build(BuildContext context) {
    final child = CatchErrorBody(
      title: title,
      message: message,
      icon: icon,
      onRetry: onRetry,
      retryLabel: retryLabel,
      secondaryAction: secondaryAction,
    );

    if (fillRemaining) {
      return CatchSliverStateViewport(child: child);
    }

    return SliverToBoxAdapter(child: child);
  }
}

class _LocalizedCatchSliverErrorState extends CatchSliverErrorState {
  const _LocalizedCatchSliverErrorState({
    super.key,
    required this.error,
    required this.errorContext,
    required this.retry,
    required this.retryLabelOverride,
    required this.iconOverride,
    required this.secondaryActionOverride,
    required super.fillRemaining,
  }) : super(title: '', message: '');

  final Object error;
  final AppErrorContext errorContext;
  final VoidCallback? retry;
  final String? retryLabelOverride;
  final IconData? iconOverride;
  final Widget? secondaryActionOverride;

  @override
  Widget build(BuildContext context) {
    final spec = _CatchErrorSpec.fromError(
      error,
      l10n: context.l10n,
      context: errorContext,
      onRetry: retry,
      retryLabel: retryLabelOverride,
      icon: iconOverride,
      secondaryAction: secondaryActionOverride,
    );
    final child = CatchErrorBody(
      title: spec.title,
      message: spec.message,
      icon: spec.icon,
      onRetry: spec.onRetry,
      retryLabel: spec.retryLabel,
      secondaryAction: spec.secondaryAction,
    );
    return fillRemaining
        ? CatchSliverStateViewport(child: child)
        : SliverToBoxAdapter(child: child);
  }
}

class CatchInlineErrorState extends StatelessWidget {
  const CatchInlineErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel,
    this.secondaryAction,
    this.icon = CatchIcons.errorOutlineRounded,
    this.compact = false,
  });

  factory CatchInlineErrorState.fromError(
    Object error, {
    Key? key,
    AppErrorContext context = AppErrorContext.generic,
    VoidCallback? onRetry,
    String? retryLabel,
    IconData? icon,
    Widget? secondaryAction,
    bool compact = false,
  }) {
    return _LocalizedCatchInlineErrorState(
      key: key,
      error: error,
      errorContext: context,
      retry: onRetry,
      retryLabelOverride: retryLabel,
      iconOverride: icon,
      secondaryActionOverride: secondaryAction,
      compact: compact,
    );
  }

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final Widget? secondaryAction;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return CatchErrorBody(
      title: title,
      message: message,
      icon: icon,
      onRetry: onRetry,
      retryLabel: retryLabel,
      secondaryAction: secondaryAction,
      mode: compact ? CatchErrorStateMode.compact : CatchErrorStateMode.inline,
    );
  }
}

class _LocalizedCatchInlineErrorState extends CatchInlineErrorState {
  const _LocalizedCatchInlineErrorState({
    super.key,
    required this.error,
    required this.errorContext,
    required this.retry,
    required this.retryLabelOverride,
    required this.iconOverride,
    required this.secondaryActionOverride,
    required super.compact,
  }) : super(title: '', message: '');

  final Object error;
  final AppErrorContext errorContext;
  final VoidCallback? retry;
  final String? retryLabelOverride;
  final IconData? iconOverride;
  final Widget? secondaryActionOverride;

  @override
  Widget build(BuildContext context) {
    final spec = _CatchErrorSpec.fromError(
      error,
      l10n: context.l10n,
      context: errorContext,
      onRetry: retry,
      retryLabel: retryLabelOverride,
      icon: iconOverride,
      secondaryAction: secondaryActionOverride,
    );
    return CatchErrorBody(
      title: spec.title,
      message: spec.message,
      icon: spec.icon,
      onRetry: spec.onRetry,
      retryLabel: spec.retryLabel,
      secondaryAction: spec.secondaryAction,
      mode: compact ? CatchErrorStateMode.compact : CatchErrorStateMode.inline,
    );
  }
}
