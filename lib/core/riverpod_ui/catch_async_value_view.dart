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

/// Generic widget that exhaustively resolves the overlapping loading, retry,
/// refresh, error, and data states of an [AsyncValue].
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
    this.errorBuilderWithRetry,
    this.errorContext = AppErrorContext.generic,
    this.onRetry,
    this.skipLoadingOnReload = false,
    this.skipLoadingOnRefresh = true,
    this.skipError = false,
    this.initialLoadTimeout = InitialLoadPolicy.standard,
  }) : assert(errorBuilder == null || errorBuilderWithRetry == null);

  final AsyncValue<T> value;
  final CatchAsyncValueDataBuilder<T> builder;

  /// Optional custom loading widget. Defaults to [CatchLoadingIndicator].
  final CatchAsyncValueLoadingBuilder? loadingBuilder;

  /// Optional custom error widget. Defaults to [CatchErrorState].
  final CatchAsyncValueErrorBuilder? errorBuilder;

  /// Optional custom error widget that receives the retry callback owned by
  /// this async boundary. Use this when custom error chrome must recover from
  /// both provider failures and the initial-load timeout.
  final CatchAsyncValueErrorBuilderWithRetry? errorBuilderWithRetry;
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
    if (_timedOut) {
      return widget.errorBuilderWithRetry?.call(
            context,
            catchAsyncInitialLoadTimeoutException,
            StackTrace.current,
            widget.onRetry == null ? null : _retry,
          ) ??
          widget.errorBuilder?.call(
            context,
            catchAsyncInitialLoadTimeoutException,
            StackTrace.current,
          ) ??
          CatchErrorState.fromError(
            catchAsyncInitialLoadTimeoutException,
            context: widget.errorContext,
            onRetry: widget.onRetry == null ? null : _retry,
          );
    }
    return switch (catchAsyncRenderBranchFromAsyncValue(
      value,
      skipLoadingOnReload: widget.skipLoadingOnReload,
      skipLoadingOnRefresh: widget.skipLoadingOnRefresh,
      skipError: widget.skipError,
    )) {
      CatchAsyncRenderBranch.data => widget.builder(
        context,
        value.requireValue,
      ),
      CatchAsyncRenderBranch.loading =>
        widget.loadingBuilder?.call(context) ?? const CatchLoadingIndicator(),
      CatchAsyncRenderBranch.error =>
        widget.errorBuilderWithRetry?.call(
              context,
              value.error!,
              value.stackTrace ?? StackTrace.current,
              widget.onRetry == null ? null : _retry,
            ) ??
            widget.errorBuilder?.call(
              context,
              value.error!,
              value.stackTrace ?? StackTrace.current,
            ) ??
            CatchErrorState.fromError(
              value.error!,
              context: widget.errorContext,
              onRetry: widget.onRetry == null ? null : _retry,
            ),
    };
  }
}
