import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

enum CatchErrorStateMode { fullScreen, inline, compact }

class CatchErrorState extends StatelessWidget {
  const CatchErrorState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline_rounded,
    this.onRetry,
    this.retryLabel = 'Try again',
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
    final descriptor = appErrorDescriptor(error, context: context);
    return CatchErrorState(
      key: key,
      title: descriptor.title,
      message: descriptor.message,
      icon: icon ?? descriptor.icon,
      onRetry: descriptor.retryable ? onRetry : null,
      retryLabel: retryLabel ?? descriptor.retryLabel,
      secondaryAction: secondaryAction,
      mode: mode,
    );
  }

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String retryLabel;
  final Widget? secondaryAction;
  final CatchErrorStateMode mode;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final isCompact = mode == CatchErrorStateMode.compact;
    final secondaryAction = this.secondaryAction;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ErrorIcon(icon: icon, compact: isCompact),
        SizedBox(height: isCompact ? CatchSpacing.s3 : CatchSpacing.s4),
        Text(
          title,
          style: isCompact
              ? CatchTextStyles.titleM(context)
              : CatchTextStyles.displayS(context),
          textAlign: TextAlign.center,
        ),
        gapH8,
        Text(
          message,
          style: CatchTextStyles.bodyLead(context, color: t.ink2),
          textAlign: TextAlign.center,
          // Cap message lines — unhandled exceptions can serialise their full
          // stack trace into `error.toString()`, and an unbounded `Text`
          // here makes the error surface eat the whole viewport (which can
          // hide subsequent slivers from sliver layout altogether).
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
                  label: retryLabel,
                  onPressed: onRetry,
                  size: isCompact ? CatchButtonSize.sm : CatchButtonSize.md,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ...?(secondaryAction == null ? null : [secondaryAction]),
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

class CatchErrorScaffold extends StatelessWidget {
  const CatchErrorScaffold({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.icon = Icons.error_outline_rounded,
    this.backgroundColor,
  });

  factory CatchErrorScaffold.fromError(
    Object error, {
    Key? key,
    AppErrorContext context = AppErrorContext.generic,
    VoidCallback? onRetry,
    String? retryLabel,
    IconData? icon,
  }) {
    final descriptor = appErrorDescriptor(error, context: context);
    return CatchErrorScaffold(
      key: key,
      title: descriptor.title,
      message: descriptor.message,
      onRetry: descriptor.retryable ? onRetry : null,
      retryLabel: retryLabel ?? descriptor.retryLabel,
      icon: icon ?? descriptor.icon,
    );
  }

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? CatchTokens.of(context).bg,
      body: SafeArea(
        child: CatchErrorState(
          title: title,
          message: message,
          icon: icon,
          onRetry: onRetry,
          retryLabel: retryLabel,
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
    this.retryLabel = 'Try again',
    this.icon = Icons.error_outline_rounded,
    this.fillRemaining = true,
  });

  factory CatchSliverErrorState.fromError(
    Object error, {
    Key? key,
    AppErrorContext context = AppErrorContext.generic,
    VoidCallback? onRetry,
    String? retryLabel,
    IconData? icon,
    bool fillRemaining = true,
  }) {
    final descriptor = appErrorDescriptor(error, context: context);
    return CatchSliverErrorState(
      key: key,
      title: descriptor.title,
      message: descriptor.message,
      onRetry: descriptor.retryable ? onRetry : null,
      retryLabel: retryLabel ?? descriptor.retryLabel,
      icon: icon ?? descriptor.icon,
      fillRemaining: fillRemaining,
    );
  }

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;
  final bool fillRemaining;

  @override
  Widget build(BuildContext context) {
    final child = CatchErrorState(
      title: title,
      message: message,
      icon: icon,
      onRetry: onRetry,
      retryLabel: retryLabel,
    );

    if (fillRemaining) {
      return SliverFillRemaining(hasScrollBody: false, child: child);
    }

    return SliverToBoxAdapter(child: child);
  }
}

class CatchInlineErrorState extends StatelessWidget {
  const CatchInlineErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.icon = Icons.error_outline_rounded,
    this.compact = false,
  });

  factory CatchInlineErrorState.fromError(
    Object error, {
    Key? key,
    AppErrorContext context = AppErrorContext.generic,
    VoidCallback? onRetry,
    String? retryLabel,
    IconData? icon,
    bool compact = false,
  }) {
    final descriptor = appErrorDescriptor(error, context: context);
    return CatchInlineErrorState(
      key: key,
      title: descriptor.title,
      message: descriptor.message,
      onRetry: descriptor.retryable ? onRetry : null,
      retryLabel: retryLabel ?? descriptor.retryLabel,
      icon: icon ?? descriptor.icon,
      compact: compact,
    );
  }

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return CatchErrorState(
      title: title,
      message: message,
      icon: icon,
      onRetry: onRetry,
      retryLabel: retryLabel,
      mode: compact ? CatchErrorStateMode.compact : CatchErrorStateMode.inline,
    );
  }
}

class _ErrorIcon extends StatelessWidget {
  const _ErrorIcon({required this.icon, required this.compact});

  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final size = compact ? 48.0 : 64.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: t.primarySoft, shape: BoxShape.circle),
      child: Icon(icon, color: t.danger, size: compact ? 24 : 30),
    );
  }
}
