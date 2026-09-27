import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_admission_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Review and confirm are distinct actions; preview never admits a guest.
class HostFormAdmissionSection extends StatefulWidget {
  const HostFormAdmissionSection({
    super.key,
    required this.createController,
    required this.onAdmitted,
  });
  final HostFormAdmissionController Function() createController;
  final Future<void> Function() onAdmitted;

  @override
  State<HostFormAdmissionSection> createState() =>
      _HostFormAdmissionSectionState();
}

class _HostFormAdmissionSectionState extends State<HostFormAdmissionSection> {
  late final HostFormAdmissionController _controller;
  bool _notifiedAdmission = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.createController()..addListener(_changed);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.review();
    });
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _confirm() async {
    await _controller.confirm();
    if (mounted && !_notifiedAdmission && _controller.receipt != null) {
      _notifiedAdmission = true;
      await widget.onAdmitted();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_changed);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final preview = _controller.preview;
    final pending = _controller.pending;
    final done = _controller.receipt != null;
    return CatchSection.content(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.hostFormAdmissionTitle,
            style: CatchTextStyles.sectionTitle(context),
          ),
          gapH8,
          Text(
            done
                ? l10n.hostFormAdmissionComplete
                : pending != null
                ? l10n.hostFormAdmissionSaved
                : preview?.canCommit == true
                ? (preview!.seatAlreadyOccupied == true
                      ? l10n.hostFormAdmissionRetain
                      : l10n.hostFormAdmissionReady)
                : l10n.hostFormAdmissionReview,
            style: CatchTextStyles.supporting(context),
          ),
          if (preview?.blocker case final blocker?) ...[
            gapH8,
            CatchBanner.error(message: blocker),
          ],
          if (_controller.error case final error?) ...[
            gapH8,
            CatchBanner.error(
              message: appErrorMessage(
                error,
                l10n: l10n,
                context: AppErrorContext.forms,
              ),
            ),
          ],
          if (!done) ...[
            gapH16,
            CatchButton(
              label: pending?.needsReview == true
                  ? l10n.hostFormAdmissionReviewAgain
                  : pending != null
                  ? l10n.hostFormAdmissionRetry
                  : preview?.canCommit == true
                  ? l10n.hostFormAdmissionConfirm
                  : l10n.hostFormAdmissionCheck,
              status: _controller.busy
                  ? CatchButtonStatus.loading
                  : CatchButtonStatus.idle,
              onPressed: _controller.busy
                  ? null
                  : pending?.needsReview == true
                  ? _controller.reviewAgain
                  : pending != null || preview?.canCommit == true
                  ? _confirm
                  : _controller.review,
            ),
          ],
        ],
      ),
    );
  }
}
