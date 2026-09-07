import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/data/initial_load_policy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_builders.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_deadline.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sliver equivalent of the CatchAsyncValueView box boundary.
class CatchAsyncValueSliver<T> extends StatefulWidget {
  const CatchAsyncValueSliver({
    super.key,
    required this.value,
    required this.builder,
    this.loadingBuilder,
    this.sliverLoadingBuilder,
    this.errorBuilder,
    this.sliverErrorBuilder,
    this.errorBuilderWithRetry,
    this.sliverErrorBuilderWithRetry,
    this.errorContext = AppErrorContext.generic,
    this.onRetry,
    this.fillErrorRemaining = true,
    this.skipLoadingOnReload = false,
    this.skipLoadingOnRefresh = true,
    this.skipError = false,
    this.initialLoadTimeout = InitialLoadPolicy.standard,
  }) : assert(errorBuilder == null || errorBuilderWithRetry == null),
       assert(
         sliverErrorBuilder == null || sliverErrorBuilderWithRetry == null,
       );

  final AsyncValue<T> value;
  final CatchAsyncValueDataBuilder<T> builder;
  final CatchAsyncValueLoadingBuilder? loadingBuilder;
  final WidgetBuilder? sliverLoadingBuilder;
  final CatchAsyncValueErrorBuilder? errorBuilder;
  final CatchAsyncValueErrorBuilder? sliverErrorBuilder;
  final CatchAsyncValueErrorBuilderWithRetry? errorBuilderWithRetry;
  final CatchAsyncValueErrorBuilderWithRetry? sliverErrorBuilderWithRetry;
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
    if (!isCatchAsyncBlockingLoading(widget.value)) {
      _deadline?.cancel();
      _deadline = null;
      _timedOut = false;
      return;
    }
    if (_timedOut || _deadline != null || widget.initialLoadTimeout == null) {
      return;
    }
    _deadline = Timer(widget.initialLoadTimeout!, () {
      if (!mounted || !isCatchAsyncBlockingLoading(widget.value)) return;
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
    final branch = _timedOut
        ? CatchAsyncRenderBranch.error
        : catchAsyncRenderBranchFromAsyncValue(
            value,
            skipLoadingOnReload: widget.skipLoadingOnReload,
            skipLoadingOnRefresh: widget.skipLoadingOnRefresh,
            skipError: widget.skipError,
          );
    switch (branch) {
      case CatchAsyncRenderBranch.data:
        return widget.builder(context, value.requireValue);
      case CatchAsyncRenderBranch.loading:
        final loadingSliver = widget.sliverLoadingBuilder?.call(context);
        if (loadingSliver != null) return loadingSliver;
        return SliverToBoxAdapter(
          child:
              widget.loadingBuilder?.call(context) ??
              const CatchLoadingIndicator(),
        );
      case CatchAsyncRenderBranch.error:
        final error = _timedOut
            ? catchAsyncInitialLoadTimeoutException
            : value.error!;
        final stack = _timedOut
            ? StackTrace.current
            : value.stackTrace ?? StackTrace.current;
        final retry = widget.onRetry == null ? null : _retry;
        final customSliver =
            widget.sliverErrorBuilderWithRetry?.call(
              context,
              error,
              stack,
              retry,
            ) ??
            widget.sliverErrorBuilder?.call(context, error, stack);
        if (customSliver != null) return customSliver;
        final customBuilder =
            widget.errorBuilderWithRetry?.call(context, error, stack, retry) ??
            widget.errorBuilder?.call(context, error, stack);
        if (customBuilder != null) {
          return SliverToBoxAdapter(child: customBuilder);
        }
        return CatchSliverErrorState.fromError(
          error,
          context: widget.errorContext,
          onRetry: retry,
          fillRemaining: widget.fillErrorRemaining,
        );
    }
  }
}
