import 'package:catch_ui/src/components/catch_step_list.dart';

/// One step in a [CatchStepList] sequence.
class CatchStepRowData {
  const CatchStepRowData({required this.title, this.body});

  final String title;
  final String? body;
}
