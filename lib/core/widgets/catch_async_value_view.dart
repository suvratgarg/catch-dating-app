import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/data/initial_load_policy.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
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
class CatchAsyncValueView<T> extends StatefulWidget {
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
    this.initialLoadTimeout = InitialLoadPolicy.standard,
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
  final Duration? initialLoadTimeout;

  @override
  State<CatchAsyncValueView<T>> createState() => _CatchAsyncValueViewState<T>();
}

class _CatchAsyncValueViewState<T> extends State<CatchAsyncValueView<T>> {
  Timer? _deadline;
  bool _timedOut = false;

  @override
  void initState() {
    super.initState();
    _syncDeadline();
  }

  @override
  void didUpdateWidget(CatchAsyncValueView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncDeadline();
  }

  @override
  void dispose() {
    _deadline?.cancel();
    super.dispose();
  }

  void _syncDeadline() {
    if (!_isInitialLoading(widget.value)) {
      _deadline?.cancel();
      _deadline = null;
      _timedOut = false;
      return;
    }
    if (_timedOut || _deadline != null || widget.initialLoadTimeout == null) {
      return;
    }
    _deadline = Timer(widget.initialLoadTimeout!, () {
      if (!mounted || !_isInitialLoading(widget.value)) return;
      setState(() => _timedOut = true);
    });
  }

  void _retry() {
    _deadline?.cancel();
    _deadline = null;
    setState(() => _timedOut = false);
    widget.onRetry?.call();
    _syncDeadline();
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    if (value.hasError && !widget.skipError) {
      return widget.errorBuilder?.call(
            context,
            value.error!,
            value.stackTrace ?? StackTrace.current,
          ) ??
          CatchErrorState.fromError(
            value.error!,
            context: widget.errorContext,
            onRetry: widget.onRetry == null ? null : _retry,
          );
    }
    if (_timedOut) {
      return CatchErrorState.fromError(
        _initialLoadTimeoutException,
        context: widget.errorContext,
        onRetry: widget.onRetry == null ? null : _retry,
      );
    }
    return value.when(
      skipLoadingOnReload: widget.skipLoadingOnReload,
      skipLoadingOnRefresh: widget.skipLoadingOnRefresh,
      skipError: widget.skipError,
      data: (value) => widget.builder(context, value),
      loading: () =>
          widget.loadingBuilder?.call(context) ?? const CatchLoadingIndicator(),
      error: (e, st) =>
          widget.errorBuilder?.call(context, e, st) ??
          CatchErrorState.fromError(
            e,
            context: widget.errorContext,
            onRetry: widget.onRetry == null ? null : _retry,
          ),
    );
  }
}

/// Sliver equivalent of [CatchAsyncValueView].
class CatchAsyncValueSliver<T> extends StatefulWidget {
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
    this.initialLoadTimeout = InitialLoadPolicy.standard,
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
  final Duration? initialLoadTimeout;

  @override
  State<CatchAsyncValueSliver<T>> createState() =>
      _CatchAsyncValueSliverState<T>();
}

class _CatchAsyncValueSliverState<T> extends State<CatchAsyncValueSliver<T>> {
  Timer? _deadline;
  bool _timedOut = false;

  @override
  void initState() {
    super.initState();
    _syncDeadline();
  }

  @override
  void didUpdateWidget(CatchAsyncValueSliver<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncDeadline();
  }

  @override
  void dispose() {
    _deadline?.cancel();
    super.dispose();
  }

  void _syncDeadline() {
    if (!_isInitialLoading(widget.value)) {
      _deadline?.cancel();
      _deadline = null;
      _timedOut = false;
      return;
    }
    if (_timedOut || _deadline != null || widget.initialLoadTimeout == null) {
      return;
    }
    _deadline = Timer(widget.initialLoadTimeout!, () {
      if (!mounted || !_isInitialLoading(widget.value)) return;
      setState(() => _timedOut = true);
    });
  }

  void _retry() {
    _deadline?.cancel();
    _deadline = null;
    setState(() => _timedOut = false);
    widget.onRetry?.call();
    _syncDeadline();
  }

  Widget _errorSliver(BuildContext context, Object error, StackTrace stack) {
    final customSliver = widget.sliverErrorBuilder?.call(context, error, stack);
    if (customSliver != null) return customSliver;
    final customBuilder = widget.errorBuilder?.call(context, error, stack);
    if (customBuilder != null) return SliverToBoxAdapter(child: customBuilder);
    return CatchSliverErrorState.fromError(
      error,
      context: widget.errorContext,
      onRetry: widget.onRetry == null ? null : _retry,
      fillRemaining: widget.fillErrorRemaining,
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    if (value.hasError && !widget.skipError) {
      return _errorSliver(
        context,
        value.error!,
        value.stackTrace ?? StackTrace.current,
      );
    }
    if (_timedOut) {
      return _errorSliver(
        context,
        _initialLoadTimeoutException,
        StackTrace.current,
      );
    }
    return value.when(
      skipLoadingOnReload: widget.skipLoadingOnReload,
      skipLoadingOnRefresh: widget.skipLoadingOnRefresh,
      skipError: widget.skipError,
      data: (value) => widget.builder(context, value),
      loading: () {
        final customSliver = widget.sliverLoadingBuilder?.call(context);
        if (customSliver != null) return customSliver;
        return SliverToBoxAdapter(
          child:
              widget.loadingBuilder?.call(context) ??
              const CatchLoadingIndicator(),
        );
      },
      error: (e, st) => _errorSliver(context, e, st),
    );
  }
}

bool _isInitialLoading(AsyncValue<Object?> value) =>
    value.isLoading && !value.hasValue && !value.hasError;

const _initialLoadTimeoutException = NetworkException(
  'timeout',
  'This is taking longer than expected. Please try again.',
);

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
