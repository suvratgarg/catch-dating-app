import 'package:catch_ui/src/components/catch_field_copy.dart';
import 'package:catch_ui/src/patterns/catch_form_save.dart';
import 'package:catch_ui/src/patterns/catch_form_text_commit_mode.dart';
import 'package:flutter/foundation.dart';

/// Field-local access to the list's shared accordion and save pipeline.
class CatchFormRowScope<P> {
  const CatchFormRowScope({
    required this.fieldCopy,
    required this.isExpanded,
    required this.toggle,
    required this.collapse,
    required this.save,
    required this.textCommitMode,
  });

  final bool isExpanded;
  final VoidCallback toggle;
  final VoidCallback collapse;
  final CatchFormSave<P> save;
  final CatchFormTextCommitMode textCommitMode;
  final CatchFieldCopy fieldCopy;
}
