import 'package:catch_dating_app/hosts/presentation/forms/host_form_response_detail_screen.dart';
import 'package:flutter/widgets.dart';

/// Compatibility entry for saved application URLs; all detail UI has one owner.
class HostApplicationDetailScreen extends StatelessWidget {
  const HostApplicationDetailScreen({
    super.key,
    required this.organizerId,
    required this.applicationId,
    this.queue,
  });
  final String organizerId;
  final String applicationId;
  final HostResponseReviewQueue? queue;
  @override
  Widget build(BuildContext context) =>
      HostFormResponseDetailScreen.application(
        organizerId: organizerId,
        applicationId: applicationId,
        queue: queue,
      );
}
