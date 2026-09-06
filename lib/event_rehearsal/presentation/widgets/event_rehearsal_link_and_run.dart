import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EventRehearsalGuestLinkSection extends StatelessWidget {
  const EventRehearsalGuestLinkSection({
    super.key,
    required this.guestUrl,
    required this.isLoading,
    required this.onCopy,
    required this.onShare,
    required this.onRotate,
  });

  final String guestUrl;
  final bool isLoading;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onRotate;

  @override
  Widget build(BuildContext context) => CatchSection.fieldRows(
    title: context.l10n.hostEventRehearsalGuestLinkTitle,
    children: [
      CatchField.control(
        title: context.l10n.hostEventRehearsalGuestLinkTitle,
        body: context.l10n.hostEventRehearsalGuestLinkBody,
        icon: CatchIcons.qrCode2Rounded,
        contractExemption:
            'The callable returns this opaque practice-only guest URL.',
        initiallyOpen: true,
        control: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ColoredBox(
              color: CatchTokens.editorialWhite,
              child: Padding(
                padding: CatchInsets.iconChipContent,
                child: QrImageView(
                  data: guestUrl,
                  size: CatchLayout.eventSuccessVenueQrExtent,
                  padding: EdgeInsets.zero,
                  backgroundColor: CatchTokens.editorialWhite,
                ),
              ),
            ),
            gapH12,
            SelectableText(
              guestUrl,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            gapH12,
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                CatchButton(
                  label: context.l10n.hostEventRehearsalCopyLink,
                  icon: Icon(CatchIcons.contentCopyRounded),
                  size: CatchButtonSize.sm,
                  variant: CatchButtonVariant.secondary,
                  onPressed: isLoading ? null : onCopy,
                ),
                CatchButton(
                  label: context.l10n.hostEventRehearsalShareLink,
                  icon: Icon(CatchIcons.share),
                  size: CatchButtonSize.sm,
                  variant: CatchButtonVariant.secondary,
                  onPressed: isLoading ? null : onShare,
                ),
                CatchButton(
                  label: context.l10n.hostEventRehearsalRotateLink,
                  icon: Icon(CatchIcons.refresh),
                  size: CatchButtonSize.sm,
                  variant: CatchButtonVariant.ghost,
                  onPressed: isLoading ? null : onRotate,
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

class EventRehearsalRunSection extends StatelessWidget {
  const EventRehearsalRunSection({
    super.key,
    required this.session,
    required this.isLoading,
    required this.onControl,
  });

  final EventRehearsalSession session;
  final bool isLoading;
  final void Function(EventRehearsalControlAction action, int? minutes)
  onControl;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.jm(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return CatchSection.fieldRows(
      title: context.l10n.hostEventRehearsalRunTitle,
      children: [
        CatchField.control(
          title: context.l10n.hostEventRehearsalMoment(
            current: session.activeStepIndex + 1,
            total: EventRehearsalGuestMoment.values.length,
          ),
          body: context.l10n.hostEventRehearsalClock(
            time: formatter.format(session.virtualNow),
          ),
          icon: CatchIcons.timerOutlined,
          contractExemption:
              'Virtual rehearsal clock controls are callable-owned commands.',
          initiallyOpen: true,
          control: Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              ...switch (session.status) {
                EventRehearsalStatus.draft || EventRehearsalStatus.ready => [
                  _EventRehearsalControlButton(
                    label: context.l10n.hostEventRehearsalStart,
                    action: EventRehearsalControlAction.start,
                    variant: CatchButtonVariant.primary,
                    isLoading: isLoading,
                    onControl: onControl,
                  ),
                ],
                EventRehearsalStatus.running => [
                  _EventRehearsalControlButton(
                    label: context.l10n.hostEventRehearsalPause,
                    action: EventRehearsalControlAction.pause,
                    variant: CatchButtonVariant.secondary,
                    isLoading: isLoading,
                    onControl: onControl,
                  ),
                ],
                EventRehearsalStatus.paused => [
                  _EventRehearsalControlButton(
                    label: context.l10n.hostEventRehearsalResume,
                    action: EventRehearsalControlAction.resume,
                    variant: CatchButtonVariant.primary,
                    isLoading: isLoading,
                    onControl: onControl,
                  ),
                ],
                EventRehearsalStatus.complete ||
                EventRehearsalStatus.expired => <Widget>[],
              },
              if (session.hasStarted &&
                  session.status != EventRehearsalStatus.complete) ...[
                _EventRehearsalControlButton(
                  label: context.l10n.hostEventRehearsalPrevious,
                  action: EventRehearsalControlAction.previous,
                  variant: CatchButtonVariant.ghost,
                  isLoading: isLoading,
                  onControl: onControl,
                ),
                _EventRehearsalControlButton(
                  label: context.l10n.hostEventRehearsalNext,
                  action: EventRehearsalControlAction.advance,
                  variant: CatchButtonVariant.secondary,
                  isLoading: isLoading,
                  onControl: onControl,
                ),
                CatchButton(
                  label: context.l10n.hostEventRehearsalAdvanceFive,
                  size: CatchButtonSize.sm,
                  variant: CatchButtonVariant.secondary,
                  onPressed: isLoading
                      ? null
                      : () => onControl(
                          EventRehearsalControlAction.advanceClock,
                          5,
                        ),
                ),
                CatchButton(
                  label: context.l10n.hostEventRehearsalAdvanceFifteen,
                  size: CatchButtonSize.sm,
                  variant: CatchButtonVariant.secondary,
                  onPressed: isLoading
                      ? null
                      : () => onControl(
                          EventRehearsalControlAction.advanceClock,
                          15,
                        ),
                  semanticsLabel: context.l10n.hostEventRehearsalAdvanceFifteen,
                ),
                _EventRehearsalControlButton(
                  label: context.l10n.hostEventRehearsalComplete,
                  action: EventRehearsalControlAction.complete,
                  variant: CatchButtonVariant.danger,
                  isLoading: isLoading,
                  onControl: onControl,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EventRehearsalControlButton extends StatelessWidget {
  const _EventRehearsalControlButton({
    required this.label,
    required this.action,
    required this.variant,
    required this.isLoading,
    required this.onControl,
  });

  final String label;
  final EventRehearsalControlAction action;
  final CatchButtonVariant variant;
  final bool isLoading;
  final void Function(EventRehearsalControlAction action, int? minutes)
  onControl;

  @override
  Widget build(BuildContext context) => CatchButton(
    label: label,
    size: CatchButtonSize.sm,
    variant: variant,
    isLoading: isLoading,
    onPressed: isLoading ? null : () => onControl(action, null),
  );
}
