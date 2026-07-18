import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef CatchAsyncValueDataBuilder<T> =
    Widget Function(BuildContext context, T value);
typedef CatchAsyncValueLoadingBuilder = Widget Function(BuildContext context);
typedef CatchAsyncValueErrorBuilder =
    Widget Function(BuildContext context, Object error, StackTrace stackTrace);

/// Generic widget that handles the three states of an [AsyncValue]:
/// loading, error, and data.
///
/// Usage:
/// ```dart
/// CatchAsyncValueView<List<Club>>(
///   value: ref.watch(watchClubsProvider),
///   builder: (context, clubs) => ListView(...),
/// )
/// ```
class CatchAsyncValueView<T> extends StatelessWidget {
  const CatchAsyncValueView({
    super.key,
    required this.value,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.errorContext = AppErrorContext.generic,
    this.onRetry,
    this.skipLoadingOnReload = false,
    this.skipLoadingOnRefresh = true,
    this.skipError = false,
  });

  final AsyncValue<T> value;
  final CatchAsyncValueDataBuilder<T> builder;

  /// Optional custom loading widget. Defaults to [CatchLoadingIndicator].
  final CatchAsyncValueLoadingBuilder? loadingBuilder;

  /// Optional custom error widget. Defaults to [CatchErrorState].
  final CatchAsyncValueErrorBuilder? errorBuilder;
  final AppErrorContext errorContext;
  final VoidCallback? onRetry;
  final bool skipLoadingOnReload;
  final bool skipLoadingOnRefresh;
  final bool skipError;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnReload: skipLoadingOnReload,
      skipLoadingOnRefresh: skipLoadingOnRefresh,
      skipError: skipError,
      data: (value) => builder(context, value),
      loading: () =>
          loadingBuilder?.call(context) ?? const CatchLoadingIndicator(),
      error: (e, st) =>
          errorBuilder?.call(context, e, st) ??
          CatchErrorState.fromError(e, context: errorContext, onRetry: onRetry),
    );
  }
}

/// Sliver equivalent of [CatchAsyncValueView].
class CatchAsyncValueSliver<T> extends StatelessWidget {
  const CatchAsyncValueSliver({
    super.key,
    required this.value,
    required this.builder,
    this.loadingBuilder,
    this.sliverLoadingBuilder,
    this.errorBuilder,
    this.sliverErrorBuilder,
    this.errorContext = AppErrorContext.generic,
    this.onRetry,
    this.fillErrorRemaining = true,
    this.skipLoadingOnReload = false,
    this.skipLoadingOnRefresh = true,
    this.skipError = false,
  });

  final AsyncValue<T> value;
  final CatchAsyncValueDataBuilder<T> builder;
  final CatchAsyncValueLoadingBuilder? loadingBuilder;
  final WidgetBuilder? sliverLoadingBuilder;
  final CatchAsyncValueErrorBuilder? errorBuilder;
  final CatchAsyncValueErrorBuilder? sliverErrorBuilder;
  final AppErrorContext errorContext;
  final VoidCallback? onRetry;
  final bool fillErrorRemaining;
  final bool skipLoadingOnReload;
  final bool skipLoadingOnRefresh;
  final bool skipError;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnReload: skipLoadingOnReload,
      skipLoadingOnRefresh: skipLoadingOnRefresh,
      skipError: skipError,
      data: (value) => builder(context, value),
      loading: () {
        final customSliver = sliverLoadingBuilder?.call(context);
        if (customSliver != null) return customSliver;
        return SliverToBoxAdapter(
          child: loadingBuilder?.call(context) ?? const CatchLoadingIndicator(),
        );
      },
      error: (e, st) {
        final customSliver = sliverErrorBuilder?.call(context, e, st);
        if (customSliver != null) return customSliver;
        final customBuilder = errorBuilder?.call(context, e, st);
        if (customBuilder != null) {
          return SliverToBoxAdapter(child: customBuilder);
        }
        return CatchSliverErrorState.fromError(
          e,
          context: errorContext,
          onRetry: onRetry,
          fillRemaining: fillErrorRemaining,
        );
      },
    );
  }
}

class CatchAsyncScreenLoading extends StatelessWidget {
  const CatchAsyncScreenLoading({
    super.key,
    this.count = 3,
    this.itemHeight,
    this.scrollable = true,
  });

  final int count;
  final double? itemHeight;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return CatchScreenBody(
      scrollable: scrollable,
      child: CatchSkeletonList(
        count: count,
        height: itemHeight ?? CatchLayout.skeletonCardHeight,
      ),
    );
  }
}

class CatchAsyncSliverLoading extends StatelessWidget {
  const CatchAsyncSliverLoading({
    super.key,
    this.count = 3,
    this.itemHeight,
    this.padding = CatchInsets.pageBody,
  });

  final int count;
  final double? itemHeight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return CatchSliverPageBody(
      padding: padding,
      sliver: SliverToBoxAdapter(
        child: CatchSkeletonList(
          count: count,
          height: itemHeight ?? CatchLayout.skeletonCardHeight,
        ),
      ),
    );
  }
}
