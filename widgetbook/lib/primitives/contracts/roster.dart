import 'package:catch_dating_app/hosts/presentation/widgets/catch_roster_board.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/contract_preview.dart';

import '../../preview_layout_contracts.dart';

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchRosterRow,
  path: '[Core primitives]/Host operations',
)
Widget catchRosterRowContractStates(BuildContext context) {
  return WidgetbookContractFrame(
    title: 'CatchRosterRow',
    contractId: 'catch.roster_row',
    states: const [
      'button-action',
      'decision-action',
      'badge-action',
      'text-action',
      'empty-signal',
      'disabled-action',
      'truncated',
    ],
    children: [
      WidgetbookContractStateCard(
        label: 'button-action',
        child: CatchRosterRow(
          person: 'Aanya Rao',
          meta: 'Paid - arrives 7:40 PM',
          signal: 'Checked in',
          tone: CatchBadgeTone.success,
          action: CatchRosterButtonAction(
            label: 'View',
            icon: CatchIcons.eye,
            onPressed: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'decision-action',
        child: CatchRosterRow(
          person: 'Dev Malhotra',
          meta: 'Request to join - first event',
          signal: 'Review',
          tone: CatchBadgeTone.warning,
          action: CatchRosterDecideAction(
            onProfile: widgetbookNoop,
            onApprove: widgetbookNoop,
            onDecline: widgetbookNoop,
          ),
        ),
      ),
      const WidgetbookContractStateCard(
        label: 'badge-action',
        child: CatchRosterRow(
          person: 'Kabir Mehta',
          meta: 'Guest invite - +1',
          signal: 'Hosted',
          tone: CatchBadgeTone.gold,
          action: CatchRosterBadgeAction(
            label: 'VIP',
            tone: CatchBadgeTone.gold,
          ),
        ),
      ),
      const WidgetbookContractStateCard(
        label: 'text-action',
        child: CatchRosterRow(
          person: 'Mira Shah',
          meta: 'Ticket refunded',
          signal: 'Cancelled',
          tone: CatchBadgeTone.danger,
          action: CatchRosterTextAction('Done'),
        ),
      ),
      const WidgetbookContractStateCard(
        label: 'empty-signal',
        child: CatchRosterRow(
          person: 'Noor Khan',
          meta: 'Invite pending',
          action: CatchRosterTextAction('Waiting'),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'disabled-action',
        child: CatchRosterRow(
          person: 'Naina Bose',
          meta: 'Reminder already sent',
          signal: 'Pending',
          action: CatchRosterButtonAction(
            label: 'Sent',
            disabled: true,
            onPressed: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'truncated',
        child: SizedBox(
          width: WidgetbookPreviewLayout.standardContractWidth,
          child: CatchRosterRow(
            person: 'A very long guest name that should ellipsize cleanly',
            meta: 'VIP invite with a very long arrival note and payment status',
            signal: 'Needs help',
            tone: CatchBadgeTone.warning,
            action: CatchRosterButtonAction(
              label: 'Open',
              onPressed: widgetbookNoop,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchRosterTable,
  path: '[Core primitives]/Host operations',
)
Widget catchRosterTableContractStates(BuildContext context) {
  return WidgetbookContractFrame(
    title: 'CatchRosterTable',
    contractId: 'catch.roster_table',
    states: const ['populated', 'empty', 'partial-columns', 'long-copy'],
    children: [
      WidgetbookContractStateCard(
        label: 'populated',
        child: CatchRosterTable(
          columns: const ['Guest', 'Signal', 'Action'],
          rows: [
            CatchRosterRow(
              person: 'Aanya Rao',
              meta: 'Paid - checked in 7:42 PM',
              signal: 'Here',
              tone: CatchBadgeTone.success,
              action: CatchRosterButtonAction(
                label: 'Open',
                icon: CatchIcons.eye,
                onPressed: widgetbookNoop,
              ),
            ),
            CatchRosterRow(
              person: 'Dev Malhotra',
              meta: 'Request to join',
              signal: 'Review',
              tone: CatchBadgeTone.warning,
              action: CatchRosterDecideAction(
                onProfile: widgetbookNoop,
                onApprove: widgetbookNoop,
                onDecline: widgetbookNoop,
              ),
            ),
            const CatchRosterRow(
              person: 'Mira Shah',
              meta: 'Ticket refunded',
              signal: 'Cancelled',
              tone: CatchBadgeTone.danger,
              action: CatchRosterBadgeAction(label: 'Closed'),
            ),
          ],
        ),
      ),
      const WidgetbookContractStateCard(
        label: 'empty',
        child: CatchRosterTable(
          columns: ['Guest', 'Signal', 'Action'],
          showEmpty: true,
          emptyTitle: 'No guests in this view',
          emptyMessage:
              'Change the roster filter or wait for guests to join this event.',
        ),
      ),
      const WidgetbookContractStateCard(
        label: 'partial-columns',
        child: CatchRosterTable(
          columns: ['Guest', 'Signal'],
          rows: [
            CatchRosterRow(
              person: 'Noor Khan',
              meta: 'Invite pending',
              signal: 'Pending',
              action: CatchRosterTextAction('Waiting'),
            ),
          ],
        ),
      ),
      WidgetbookContractStateCard(
        label: 'long-copy',
        child: CatchRosterTable(
          columns: const ['Guest', 'Signal', 'Action'],
          rows: [
            CatchRosterRow(
              person: 'A very long guest name that should ellipsize cleanly',
              meta:
                  'VIP invite with a very long arrival note and payment status',
              signal: 'Needs help',
              tone: CatchBadgeTone.warning,
              action: CatchRosterButtonAction(
                label: 'Open',
                onPressed: widgetbookNoop,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
