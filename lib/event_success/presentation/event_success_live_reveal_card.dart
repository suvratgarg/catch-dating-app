import 'dart:async';
import 'dart:math' as math;

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/responsive/component_breakpoints.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_preference.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_reveal_card_state.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:flutter/material.dart';

export 'package:catch_dating_app/event_success/presentation/event_success_live_reveal_card_state.dart';

part 'live_reveal_parts/event_success_live_reveal_host.dart';
part 'live_reveal_parts/event_success_live_reveal_attendee.dart';
part 'live_reveal_parts/event_success_live_reveal_actions.dart';
part 'live_reveal_parts/event_success_live_reveal_widgets.dart';
part 'live_reveal_parts/event_success_live_reveal_copy.dart';

enum EventSuccessRevealAssignmentKind {
  microPods,
  rotations;

  String get label => switch (this) {
    EventSuccessRevealAssignmentKind.microPods => 'Pod reveal',
    EventSuccessRevealAssignmentKind.rotations => 'Rotation reveal',
  };

  String get assignmentNoun => switch (this) {
    EventSuccessRevealAssignmentKind.microPods => 'pod',
    EventSuccessRevealAssignmentKind.rotations => 'rotation',
  };

  String get assignmentNounPlural => switch (this) {
    EventSuccessRevealAssignmentKind.microPods => 'pods',
    EventSuccessRevealAssignmentKind.rotations => 'rotations',
  };

  IconData get icon => switch (this) {
    EventSuccessRevealAssignmentKind.microPods => CatchIcons.groups2Outlined,
    EventSuccessRevealAssignmentKind.rotations => CatchIcons.syncAltRounded,
  };
}
