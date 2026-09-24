part of '../host_operations_screen.dart';

class HostClubEventDefaultsScreen extends ConsumerStatefulWidget {
  const HostClubEventDefaultsScreen({
    super.key,
    required this.clubId,
    this.managerEventSetupPreferences,
    this.onManagerEventSetupPreferencesChanged,
  });

  final String clubId;
  /// Supplied only by a manager-authorized preferences read.
  final ManagerEventSetupPreferences? managerEventSetupPreferences;
  /// Supplied only after a revision-fenced manager settings writer exists.
  final ValueChanged<ManagerEventSetupPreferences>?
      onManagerEventSetupPreferencesChanged;

  @override
  ConsumerState<HostClubEventDefaultsScreen> createState() =>
      _HostClubEventDefaultsScreenState();
}

class _HostClubEventDefaultsScreenState
    extends ConsumerState<HostClubEventDefaultsScreen> {
  HostManagerEventSetupDefaultsController? _managerController;
  String? _managerUid;

  void _bindManager(String uid) {
    if (_managerUid == uid && _managerController != null) return;
    _managerController?.removeListener(_onManagerChanged);
    _managerController?.dispose();
    _managerUid = uid;
    final repository = ManagerEventSetupDefaultsRepository(
      ref.read(firebaseFunctionsProvider),
    );
    final controller = HostManagerEventSetupDefaultsController(
      organizerId: widget.clubId,
      userId: uid,
      read: repository.get,
      write: repository.update,
    );
    _managerController = controller;
    controller.addListener(_onManagerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && identical(_managerController, controller)) {
        unawaited(controller.load());
      }
    });
  }

  void _onManagerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _managerController?.removeListener(_onManagerChanged);
    _managerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HostClubSpokeResolver._(
      clubId: widget.clubId,
      title: context.l10n.hostsHostClubEditTabLabelEventDefaults,
      builder: (context, club, uid, isOwner) {
        if (_progressiveEventDefaultsAvailable() && isOwner &&
            widget.managerEventSetupPreferences == null) {
          _bindManager(uid);
        }
        return isOwner
          ? HostClubDefaultsEditor._(
              club: club,
              builder: (context, defaults, apply, errorMessage, _) =>
                  CatchSectionList(
                    emptyStateOmitted: true,
                    children: [
                      if (_progressiveEventDefaultsAvailable())
                        CatchSection.fieldRows(
                        first: true,
                        title: context.l10n.hostsEventDefaultsBasics,
                        children: [
                          CatchField.read(
                            copy: catchFieldCopy(context.l10n),
                            title: context.l10n.hostsPrivateEventCity,
                            body: club.location,
                            icon: CatchIcons.locationOnOutlined,
                          ),
                          CatchFieldSupportRow(
                            text: context.l10n.hostsEventDefaultsCitySource,
                            color: CatchTokens.of(context).ink2,
                          ),
                          CatchField.read(
                            copy: catchFieldCopy(context.l10n),
                            title: context.l10n.hostsPrivateEventTimezone,
                            body: _managerController?.current?.timezone ??
                                context.l10n.hostsEventDefaultsChooseEachEvent,
                            icon: CatchIcons.languageOutlined,
                          ),
                          CatchFieldSupportRow(
                            text: context.l10n.hostsEventDefaultsTimezoneSource,
                            color: CatchTokens.of(context).ink2,
                          ),
                        ],
                      ),
                      ClubPolicyDefaultsCard(
                        defaults: defaults.eventPolicy,
                        currencyCode: currencyCodeForCityName(club.location),
                        activityKind: defaults.primaryActivityKind,
                        onActivityChanged: (activityKind) => apply(
                          (current) =>
                              _hostDefaultsWithActivity(current, activityKind),
                        ),
                        onChanged: (update) => apply(
                          (current) => current.copyWith(
                            eventPolicy: update(current.eventPolicy),
                          ),
                        ),
                      ),
                      if (_progressiveEventDefaultsAvailable())
                        if (widget.managerEventSetupPreferences != null)
                          HostManagerEventSetupPreferencesSection(
                            preferences: widget.managerEventSetupPreferences!,
                            onChanged: widget.onManagerEventSetupPreferencesChanged,
                          )
                        else if (_managerController?.current != null)
                          CatchSectionList(
                            emptyStateOmitted: true,
                            children: [
                              HostManagerEventSetupPreferencesSection(
                                preferences: _managerController!.current!.preferences,
                                onChanged: _managerController!.canEdit
                                    ? (next) => unawaited(
                                        _managerController!.save(next))
                                    : null,
                              ),
                              if (_managerController!.pending != null)
                                CatchSection.fieldRows(
                                  title: context.l10n.hostsEventDefaultsPendingUpdate,
                                  children: [
                                    CatchField.read(
                                      copy: catchFieldCopy(context.l10n),
                                      title: context.l10n.hostsEventDefaultsPendingUpdate,
                                      body: context.l10n.hostsEventDefaultsPendingUpdateBody,
                                      icon: CatchIcons.lockOutline,
                                    ),
                                    CatchField.action(
                                      copy: catchFieldCopy(context.l10n),
                                      title: context.l10n.hostsEventDefaultsRetryUpdate,
                                      onTap: _managerController!.saving
                                          ? null
                                          : () => unawaited(
                                              _managerController!.retryPending()),
                                    ),
                                  ],
                                ),
                              if (_managerController!.error != null)
                                CatchFieldSupportRow(
                                  text: context.l10n.hostsEventDefaultsManagerUnavailableBody,
                                  color: CatchTokens.of(context).danger,
                                  showErrorIcon: true,
                                ),
                            ],
                          )
                        else
                          CatchSection.fieldRows(
                            title: context.l10n.hostsEventDefaultsPaymentHeading,
                            children: [
                              CatchField.read(
                                copy: catchFieldCopy(context.l10n),
                                title: context.l10n.hostsEventDefaultsManagerUnavailable,
                                body: context.l10n.hostsEventDefaultsManagerUnavailableBody,
                                icon: CatchIcons.lockOutline,
                              ),
                              if (_managerController?.pending != null)
                                CatchField.action(
                                  copy: catchFieldCopy(context.l10n),
                                  title: context.l10n.hostsEventDefaultsRetryUpdate,
                                  body: context.l10n.hostsEventDefaultsPendingUpdateBody,
                                  onTap: _managerController!.saving
                                      ? null
                                      : () => unawaited(
                                          _managerController!.retryPending()),
                                ),
                            ],
                          ),
                      if (errorMessage != null)
                        CatchFieldSupportRow(
                          text: errorMessage,
                          color: CatchTokens.of(context).danger,
                          showErrorIcon: true,
                        ),
                    ],
                  ),
            )
          : HostClubReadOnlyEventDefaults._(club: club);
      },
    );
  }
}
