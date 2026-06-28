import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_icon.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

enum CatchErrorStateMode { fullScreen, inline, compact }

class CatchErrorState extends StatelessWidget {
  const CatchErrorState({
    super.key,
    required this.title,
    required this.message,
    this.icon = CatchIcons.errorOutlineRounded,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.secondaryAction,
    this.mode = CatchErrorStateMode.fullScreen,
  });

  CatchErrorState._fromSpec({
    super.key,
    required _CatchErrorSpec spec,
    this.mode = CatchErrorStateMode.fullScreen,
  }) : title = spec.title,
       message = spec.message,
       icon = spec.icon,
       onRetry = spec.onRetry,
       retryLabel = spec.retryLabel,
       secondaryAction = spec.secondaryAction;

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
    return CatchErrorState._fromSpec(
      key: key,
      spec: _CatchErrorSpec.fromError(
        error,
        context: context,
        onRetry: onRetry,
        retryLabel: retryLabel,
        icon: icon,
        secondaryAction: secondaryAction,
      ),
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
    return _buildCatchErrorBody(
      context,
      spec: _CatchErrorSpec(
        title: title,
        message: message,
        icon: icon,
        onRetry: onRetry,
        retryLabel: retryLabel,
        secondaryAction: secondaryAction,
      ),
      mode: mode,
    );
  }
}

Widget _buildCatchErrorBody(
  BuildContext context, {
  required _CatchErrorSpec spec,
  required CatchErrorStateMode mode,
}) {
  final t = CatchTokens.of(context);
  final isCompact = mode == CatchErrorStateMode.compact;
  final secondaryAction = spec.secondaryAction;
  final content = Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      CatchErrorIcon(
        icon: spec.icon,
        extent: isCompact ? 48 : 64,
        iconSize: isCompact ? 24 : 30,
      ),
      SizedBox(height: isCompact ? CatchSpacing.s3 : CatchSpacing.s4),
      Text(
        spec.title,
        style: isCompact
            ? CatchTextStyles.sectionTitle(context)
            : CatchTextStyles.titleL(context),
        textAlign: TextAlign.center,
      ),
      gapH8,
      Text(
        spec.message,
        style: CatchTextStyles.bodyLead(context, color: t.ink2),
        textAlign: TextAlign.center,
        // Cap message lines because unhandled exceptions can serialize stack
        // traces into `error.toString()` and otherwise consume the viewport.
        maxLines: isCompact ? 4 : 8,
        overflow: TextOverflow.ellipsis,
      ),
      if (spec.onRetry != null || secondaryAction != null) ...[
        SizedBox(height: isCompact ? CatchSpacing.s3 : CatchSpacing.s4),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: CatchSpacing.s3,
          runSpacing: CatchSpacing.s2,
          children: [
            if (spec.onRetry != null)
              CatchButton(
                label: spec.retryLabel,
                onPressed: spec.onRetry,
                size: isCompact ? CatchButtonSize.sm : CatchButtonSize.md,
                icon: Icon(CatchIcons.refreshRounded),
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
    AppErrorContext context = AppErrorContext.generic,
    VoidCallback? onRetry,
    String? retryLabel,
    IconData? icon,
    Widget? secondaryAction,
  }) {
    final descriptor = appErrorDescriptor(error, context: context);
    return _CatchErrorSpec(
      title: descriptor.title,
      message: descriptor.message,
      icon: icon ?? descriptor.icon,
      onRetry: descriptor.retryable ? onRetry : null,
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

class CatchErrorScaffold extends StatelessWidget {
  const CatchErrorScaffold({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.icon = CatchIcons.errorOutlineRounded,
    this.backgroundColor,
  });

  CatchErrorScaffold._fromSpec({super.key, required _CatchErrorSpec spec})
    : backgroundColor = null,
      title = spec.title,
      message = spec.message,
      onRetry = spec.onRetry,
      retryLabel = spec.retryLabel,
      icon = spec.icon;

  factory CatchErrorScaffold.fromError(
    Object error, {
    Key? key,
    AppErrorContext context = AppErrorContext.generic,
    VoidCallback? onRetry,
    String? retryLabel,
    IconData? icon,
  }) {
    return CatchErrorScaffold._fromSpec(
      key: key,
      spec: _CatchErrorSpec.fromError(
        error,
        context: context,
        onRetry: onRetry,
        retryLabel: retryLabel,
        icon: icon,
      ),
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
        child: _buildCatchErrorBody(
          context,
          spec: _CatchErrorSpec(
            title: title,
            message: message,
            icon: icon,
            onRetry: onRetry,
            retryLabel: retryLabel,
          ),
          mode: CatchErrorStateMode.fullScreen,
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
    this.icon = CatchIcons.errorOutlineRounded,
    this.fillRemaining = true,
  });

  CatchSliverErrorState._fromSpec({
    super.key,
    required _CatchErrorSpec spec,
    this.fillRemaining = true,
  }) : title = spec.title,
       message = spec.message,
       onRetry = spec.onRetry,
       retryLabel = spec.retryLabel,
       icon = spec.icon;

  factory CatchSliverErrorState.fromError(
    Object error, {
    Key? key,
    AppErrorContext context = AppErrorContext.generic,
    VoidCallback? onRetry,
    String? retryLabel,
    IconData? icon,
    bool fillRemaining = true,
  }) {
    return CatchSliverErrorState._fromSpec(
      key: key,
      spec: _CatchErrorSpec.fromError(
        error,
        context: context,
        onRetry: onRetry,
        retryLabel: retryLabel,
        icon: icon,
      ),
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
    final child = _buildCatchErrorBody(
      context,
      spec: _CatchErrorSpec(
        title: title,
        message: message,
        icon: icon,
        onRetry: onRetry,
        retryLabel: retryLabel,
      ),
      mode: CatchErrorStateMode.fullScreen,
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
    this.icon = CatchIcons.errorOutlineRounded,
    this.compact = false,
  });

  CatchInlineErrorState._fromSpec({
    super.key,
    required _CatchErrorSpec spec,
    this.compact = false,
  }) : title = spec.title,
       message = spec.message,
       onRetry = spec.onRetry,
       retryLabel = spec.retryLabel,
       icon = spec.icon;

  factory CatchInlineErrorState.fromError(
    Object error, {
    Key? key,
    AppErrorContext context = AppErrorContext.generic,
    VoidCallback? onRetry,
    String? retryLabel,
    IconData? icon,
    bool compact = false,
  }) {
    return CatchInlineErrorState._fromSpec(
      key: key,
      spec: _CatchErrorSpec.fromError(
        error,
        context: context,
        onRetry: onRetry,
        retryLabel: retryLabel,
        icon: icon,
      ),
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
    return _buildCatchErrorBody(
      context,
      spec: _CatchErrorSpec(
        title: title,
        message: message,
        icon: icon,
        onRetry: onRetry,
        retryLabel: retryLabel,
      ),
      mode: compact ? CatchErrorStateMode.compact : CatchErrorStateMode.inline,
    );
  }
}
