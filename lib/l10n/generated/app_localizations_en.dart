// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitleConsumer => 'Catch';

  @override
  String get appTitleHost => 'Catch Host';

  @override
  String get sharedActionTryAgain => 'Try again';

  @override
  String get sharedOfflineTitle => 'You\'re offline';

  @override
  String get sharedOfflineBody => 'Some content may be out of date.';

  @override
  String get sharedForceUpdateCheckErrorTitle => 'Could not verify app version';

  @override
  String get sharedForceUpdateCheckErrorBody =>
      'Check your connection and try again.';

  @override
  String get consumerAuthContinueWithPhone => 'Continue with phone';

  @override
  String get consumerNavigationHome => 'Home';

  @override
  String get consumerNavigationExplore => 'Explore';

  @override
  String get consumerNavigationChats => 'Chats';

  @override
  String get consumerNavigationProfile => 'You';

  @override
  String get hostNavigationToday => 'Today';

  @override
  String get hostNavigationEvents => 'Events';

  @override
  String get hostNavigationInbox => 'Inbox';

  @override
  String get hostNavigationOrganizer => 'Organizer';

  @override
  String hostInboxUnreadCount({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Unread · $count',
      one: 'Unread · 1',
      zero: 'Unread',
    );
    return '$_temp0';
  }

  @override
  String get authPhoneTitle => 'What\'s your number?';

  @override
  String get authPhoneSubtitle => 'We\'ll send you a one-time code to verify.';

  @override
  String get authPhoneFieldLabel => 'Mobile number';

  @override
  String get authSearchCountryHint => 'Search country';

  @override
  String get authSendCodeAction => 'Send code';

  @override
  String get authInvalidPhoneNumber => 'Please enter a valid phone number.';

  @override
  String get authOtpTitle => 'Enter the code';

  @override
  String authOtpSentTo({required String phoneNumber}) {
    return 'Sent to $phoneNumber';
  }

  @override
  String get authYourNumber => 'your number';

  @override
  String get authVerifyAction => 'Verify';

  @override
  String get authChangeNumberAction => 'Change number';

  @override
  String get authResendNowStatus => 'RESEND NOW';

  @override
  String authResendCountdownStatus({
    required int minutes,
    required String seconds,
  }) {
    return 'RESEND IN $minutes:$seconds';
  }

  @override
  String get authResendCodeAction => 'Resend OTP';

  @override
  String get authSendingCodeAction => 'Sending OTP...';

  @override
  String get consumerChatsTitle => 'Chats';

  @override
  String get hostInboxTitle => 'Inbox';

  @override
  String get hostInboxSubtitle => 'Attendee queries';

  @override
  String get sharedSearchByNameHint => 'Search by name';

  @override
  String get consumerSearchChatsAction => 'Search chats';

  @override
  String get hostSearchAttendeesAction => 'Search attendees';

  @override
  String get hostInboxAllFilter => 'All';

  @override
  String get chatsChatScreenLabelShareCard => 'Share card';

  @override
  String get chatsChatScreenLabelReport => 'Report';

  @override
  String get chatsChatScreenLabelBlock => 'Block';

  @override
  String get chatsChatScreenTooltipChatActions => 'Chat actions';

  @override
  String get chatsChatScreenTitleMessagesUnavailable => 'Messages unavailable';

  @override
  String get chatsChatScreenCatcherrorstateReloadMessages => 'Reload messages';

  @override
  String get chatsChatInboxScreenTextNewBlast => 'New blast';

  @override
  String get chatsChatInboxScreenTextBroadcastSendingIsNot =>
      'Broadcast sending is not connected yet. Use this as the review surface for audience and template states.';

  @override
  String get chatsChatInboxScreenTextReminder => 'Reminder';

  @override
  String get chatsChatInboxScreenTextSeeYouTonightAt =>
      'See you tonight at 8. Doors open at 7:45.';

  @override
  String get chatsChatInboxScreenTextMeetingPoint => 'Meeting point';

  @override
  String get chatsChatInboxScreenTextShareArrivalNotesParking =>
      'Share arrival notes, parking, or table details.';

  @override
  String get chatsChatsListBodySubtitleRemindersTheMeetingPoint =>
      'Reminders, the meeting point, changes';

  @override
  String get chatsChatEventContextHeaderTitleTheSameEvent => 'the same event';

  @override
  String get chatsChatInputBarMessageSendAnImage => 'Send an image';

  @override
  String get chatsChatInputBarTitleMessage => 'Message';

  @override
  String get chatsChatInputBarPlaceholderMessage => 'Message...';

  @override
  String get chatsChatInputBarMessageSendMessage => 'Send message';

  @override
  String get chatsChatInputBarLabelUploadingImage => 'Uploading image';

  @override
  String get chatsChatInputBarLabelSendingMessage => 'Sending message';

  @override
  String get chatsChatMessageListTitleMessagesUnavailable =>
      'Messages unavailable';

  @override
  String get chatsChatMessageListMessageUnableToLoadMessages =>
      'Unable to load messages.';

  @override
  String get chatsChatMessageListTitleSayHi => 'Say hi';

  @override
  String get chatsChatShareCardTextSharedFromCatch => 'Shared from Catch.';

  @override
  String get chatsSuvbotActionBarTextSuvbotControls => 'Suvbot controls';

  @override
  String get chatsSuvbotActionBarTextNoTypingNeeded => 'No typing needed';

  @override
  String get chatsSuvbotActionBarLabelRefreshAll => 'Refresh all';

  @override
  String get chatsSuvbotActionBarTextCreateATestState => 'Create a test state';

  @override
  String get chatsSuvbotActionBarLabelReset => 'Reset...';

  @override
  String get chatsSuvbotActionBarLabelReloadControls => 'Reload controls';

  @override
  String get chatsSuvbotActionBarTitleResetDemoState => 'Reset demo state';

  @override
  String get chatsSuvbotActionBarSubtitleTheseActionsOnlyTouch =>
      'These actions only touch demo-owned data.';

  @override
  String get chatsSuvbotActionBarTextMatchTester => 'Match tester';

  @override
  String get chatsSuvbotActionBarTextEnterAnAllowlistedBeta =>
      'Enter an allowlisted beta tester phone number.';

  @override
  String get chatsSuvbotActionBarTitlePhoneNumber => 'Phone number';

  @override
  String get chatsSuvbotActionBarLabelCreateMatch => 'Create match';

  @override
  String get clubsClubDetailScreenBodyClubid => 'clubId';

  @override
  String get clubsClubDetailScreenBodyEventid => 'eventId';

  @override
  String get clubsClubDetailScreenBodyUid => 'uid';

  @override
  String get clubsClubDetailScreenTitleClubNotFound => 'Organizer not found';

  @override
  String get clubsClubDetailScreenMessageThisClubIsNo =>
      'This organizer is no longer available.';

  @override
  String get clubsClubContactSectionTitleContact => 'Contact';

  @override
  String get clubsClubDetailBodyTitleAbout => 'About';

  @override
  String get clubsClubDetailBodyTitleWhatWeDo => 'What we do';

  @override
  String get clubsClubDetailBodyTitleFromTheClub => 'From the organizer';

  @override
  String get clubsClubDetailBodyTitleYourHosts => 'Your hosts';

  @override
  String get clubsClubDetailBodyTitleReviews => 'Reviews';

  @override
  String get clubsClubDetailBodyTitleGetInTouch => 'Get in touch';

  @override
  String get clubsClubDetailDockLabelDisableClubPushNotifications =>
      'Disable organizer push notifications';

  @override
  String get clubsClubDetailDockLabelEnableClubPushNotifications =>
      'Enable organizer push notifications';

  @override
  String get clubsClubHeroAppBarTooltipBack => 'Back';

  @override
  String get clubsClubHeroAppBarTooltipShareClub => 'Share organizer';

  @override
  String get clubsClubHostSectionMessageMessageHost => 'Message host';

  @override
  String get clubsClubPhotoStripTextFromTheClub => 'FROM THE ORGANIZER';

  @override
  String get clubsClubScheduleSectionTitleNoEventsScheduled =>
      'No events scheduled';

  @override
  String get clubsClubScheduleSectionMessageFutureEventsWillAppear =>
      'Future events will appear here once the host publishes one.';

  @override
  String get clubsClubAvatarRailTitleYourClubs => 'Your organizers';

  @override
  String get clubsClubDiscoverListTitleClubDirectory => 'Organizer directory';

  @override
  String get clubsClubIdentityAtomsLabelOwner => 'Owner';

  @override
  String get clubsClubIdentityAtomsLabelHost => 'Host';

  @override
  String get coreCatchAdaptivePickerTextCancel => 'Cancel';

  @override
  String get coreCatchAdaptivePickerTextDone => 'Done';

  @override
  String get coreCatchErrorBannerLabelTryAgain => 'Try again';

  @override
  String get coreCatchFieldTooltipField => 'field';

  @override
  String get coreCatchFieldLabelCancel => 'Cancel';

  @override
  String get coreCatchFieldLabelDone => 'Done';

  @override
  String get coreCatchFieldLabelSaving => 'Saving…';

  @override
  String get coreCatchFieldTextOptionalSuffix => ' · Optional';

  @override
  String get coreCatchFieldSemanticSaving => 'Saving';

  @override
  String get coreCatchFieldSemanticSaved => 'Saved';

  @override
  String get coreCatchFormFieldLabelTextOptional => 'Optional';

  @override
  String coreCatchFormValidationRequired({required String field}) {
    return '$field is required';
  }

  @override
  String coreCatchFormValidationMinLength({
    required String field,
    required int minLength,
  }) {
    return '$field must be at least $minLength characters';
  }

  @override
  String coreCatchFormValidationMaxLength({
    required String field,
    required int maxLength,
  }) {
    return '$field must be $maxLength characters or fewer';
  }

  @override
  String coreCatchFormValidationPattern({required String field}) {
    return 'Enter a valid $field';
  }

  @override
  String get coreCatchFrameworkErrorViewTextSomethingWentWrong =>
      'Something went wrong';

  @override
  String get coreCatchFrameworkErrorViewTextDeveloperDetails =>
      'Developer details';

  @override
  String get coreCatchPersonRowTextTyping => 'Typing...';

  @override
  String get coreCatchPersonRowLabelUnreadChat => 'Unread chat';

  @override
  String get coreCatchPersonRowLabelNewMatch => 'New match';

  @override
  String get coreCatchShareCardFooterTextCatch => 'CATCH';

  @override
  String get coreCatchStartupLoadingScreenSemanticlabelCatch => 'Catch';

  @override
  String get coreOrderedPhotoPickerTextCover => 'COVER';

  @override
  String get dashboardActivityScreenTitleActivity => 'Activity';

  @override
  String get dashboardDashboardScreenTooltipCalendar => 'Calendar';

  @override
  String get dashboardDashboardScreenTooltipNotifications => 'Notifications';

  @override
  String get dashboardActivitySectionTitleNoActivityYet => 'No activity yet';

  @override
  String get dashboardActivitySectionMessageSignInAndBook =>
      'Sign in and book an event to start seeing updates here.';

  @override
  String get dashboardActivitySectionTitleActivityUnavailable =>
      'Activity unavailable';

  @override
  String get dashboardActivitySectionMessageCouldNotLoadActivity =>
      'Could not load activity.';

  @override
  String get dashboardActivitySectionTitleNoNewActivity => 'No new activity';

  @override
  String get dashboardActivitySectionMessageNewCatchesBookingsAnd =>
      'New catches, bookings, and event reminders will collect here.';

  @override
  String get dashboardClubPostsHomeSectionTitleClubUpdates =>
      'Organizer updates';

  @override
  String get dashboardClubPostsHomeSectionTextLinkedEvent => 'Linked event';

  @override
  String get dashboardEmptyHeroCardTextWelcomeToCatch => 'WELCOME TO CATCH';

  @override
  String get dashboardEmptyHeroCardTextNoEventsBooked => '● NO EVENTS BOOKED';

  @override
  String get dashboardEmptyHeroCardTextYourCatchesUnlockAfter =>
      'Your catches unlock\nafter your first event.';

  @override
  String get dashboardEmptyHeroCardTextTheDatingAppWhere =>
      'The dating app where you\'ve already met. No cold swiping — just people you actually crossed paths with.';

  @override
  String get dashboardEmptyHeroCardLabelFindAnEventNear =>
      'Find an event near me';

  @override
  String get dashboardEventFocusRailTextEventFocus => 'Event Focus';

  @override
  String get dashboardEventFocusRailLabelEventFocusCarousel =>
      'Event focus carousel';

  @override
  String get eventPoliciesEventPolicyLabScreenLabelInDevelopment =>
      'In development';

  @override
  String get eventPoliciesEventPolicyLabScreenLabelNoLiveWrites =>
      'No live writes';

  @override
  String get eventPoliciesEventPolicyLabScreenLabelCapacity => 'Capacity';

  @override
  String get eventPoliciesEventPolicyLabScreenLabelBase => 'Base';

  @override
  String get eventPoliciesEventPolicyLabScreenLabelBooked => 'Booked';

  @override
  String get eventPoliciesEventPolicyLabScreenLabelWaitlist => 'Waitlist';

  @override
  String get eventPoliciesEventPolicyLabScreenTitleHostConfiguration =>
      'Host configuration';

  @override
  String get eventPoliciesEventPolicyLabScreenTitlePolicyShape =>
      'Policy shape';

  @override
  String get eventPoliciesEventPolicyLabScreenLabelAdmission => 'Admission';

  @override
  String get eventPoliciesEventPolicyLabScreenLabelInvite => 'Invite';

  @override
  String get eventPoliciesEventPolicyLabScreenLabelMembership => 'Membership';

  @override
  String get eventPoliciesEventPolicyLabScreenLabelHostReview => 'Host review';

  @override
  String get eventPoliciesEventPolicyLabScreenLabelCohortCaps => 'Cohort caps';

  @override
  String get eventPoliciesEventPolicyLabScreenLabelRatio => 'Ratio';

  @override
  String get eventPoliciesEventPolicyLabScreenLabelOutOfRatio => 'Out-of-ratio';

  @override
  String get eventPoliciesEventPolicyLabScreenLabelCohortPricing =>
      'Cohort pricing';

  @override
  String get eventPoliciesEventPolicyLabScreenLabelDemandPricing =>
      'Demand pricing';

  @override
  String get eventPoliciesEventPolicyLabScreenLabelCancellation =>
      'Cancellation';

  @override
  String get eventPoliciesEventPolicyLabScreenLabelAttendeeTerms =>
      'Attendee terms';

  @override
  String get eventPoliciesEventPolicyLabScreenLabelHostPayout => 'Host payout';

  @override
  String get eventPoliciesEventPolicyLabScreenTitlePreviewOutcomes =>
      'Preview outcomes';

  @override
  String get eventPoliciesEventPolicyLabScreenTitleCancellationOutcomes =>
      'Cancellation outcomes';

  @override
  String get eventPoliciesEventPolicyLabScreenTitleDebugMap => 'Debug map';

  @override
  String get eventSuccessEventSuccessCompanionScreenTitleEventCompanion =>
      'Event companion';

  @override
  String get eventSuccessEventSuccessEventPreviewBodyScreenLabelPreviewOnly =>
      'Preview only';

  @override
  String get eventSuccessEventSuccessEventPreviewBodyScreenLabelDevStaging =>
      'Dev/staging';

  @override
  String get eventSuccessEventSuccessEventPreviewBodyScreenTextHowThisMapsTo =>
      'How this maps to the live app';

  @override
  String get eventSuccessEventSuccessFeatureBlocksTitleHostSetupFlow =>
      'Host setup flow';

  @override
  String
  get eventSuccessEventSuccessFeatureBlocksSubtitleChooseTheFormatEvent =>
      'Choose the format, event structure, assignment tools, and safety gates before an event goes live.';

  @override
  String get eventSuccessEventSuccessFeatureBlocksTextFormat => 'Format';

  @override
  String get eventSuccessEventSuccessFeatureBlocksTextEventStructure =>
      'Event structure';

  @override
  String get eventSuccessEventSuccessFeatureBlocksTextExperienceArchitecture =>
      'Experience architecture';

  @override
  String get eventSuccessEventSuccessFeatureBlocksTitleLiveHostMode =>
      'Live host mode';

  @override
  String get eventSuccessEventSuccessFeatureBlocksSubtitleAPhoneFriendlyGuide =>
      'A phone-friendly guide for check-in, welcome, the current instruction, and the next social cue.';

  @override
  String get eventSuccessEventSuccessFeatureBlocksLabelCheckedIn =>
      'Checked in';

  @override
  String get eventSuccessEventSuccessFeatureBlocksLabelRunOfShow =>
      'Run of show';

  @override
  String get eventSuccessEventSuccessFeatureBlocksTitleAttendeeCompanion =>
      'Attendee companion';

  @override
  String get eventSuccessEventSuccessFeatureBlocksSubtitleTheAttendeeSeesOnly =>
      'The attendee sees only what helps them participate: check-in, assignment, prompt, and host help.';

  @override
  String get eventSuccessEventSuccessFeatureBlocksLabelCheckIn => 'Check in';

  @override
  String get eventSuccessEventSuccessFeatureBlocksTextAskHostForHelp =>
      'Ask host for help';

  @override
  String get eventSuccessEventSuccessFeatureBlocksTitlePostEventHostReport =>
      'Post-event host report';

  @override
  String
  get eventSuccessEventSuccessFeatureBlocksSubtitleAConcreteReportSurface =>
      'A concrete report surface that turns event outcomes into the next change the host should make.';

  @override
  String get eventSuccessEventSuccessFeatureBlocksLabelCheckIn16e104 =>
      'Check-in';

  @override
  String get eventSuccessEventSuccessFeatureBlocksLabelIntroCoverage =>
      'Intro coverage';

  @override
  String get eventSuccessEventSuccessFeatureBlocksLabelCaughtSomeone =>
      'Caught someone';

  @override
  String get eventSuccessEventSuccessFeatureBlocksLabelHostHelp => 'Host help';

  @override
  String get eventSuccessEventSuccessFeatureBlocksLabelChatStart =>
      'Chat start';

  @override
  String get eventSuccessEventSuccessFeatureBlocksTextWorkingWell =>
      'Working well';

  @override
  String get eventSuccessEventSuccessFeatureBlocksTextImproveNextTime =>
      'Improve next time';

  @override
  String get eventSuccessEventSuccessFeatureBlocksLabelBeforeLaunch =>
      'Before launch';

  @override
  String get eventSuccessEventSuccessFeatureBlocksLabelRequested => 'Requested';

  @override
  String get eventSuccessEventSuccessFeatureBlocksLabelHostVisible =>
      'Host visible';

  @override
  String get eventSuccessEventSuccessLabScreenTitleActualWipFeatureBlocks =>
      'Actual WIP feature blocks';

  @override
  String get eventSuccessEventSuccessLabScreenTitleProductPromise =>
      'Product promise';

  @override
  String get eventSuccessEventSuccessLabScreenTitlePlaybooks => 'Playbooks';

  @override
  String get eventSuccessEventSuccessLabScreenTitleArchitectureLayers =>
      'Architecture layers';

  @override
  String get eventSuccessEventSuccessLabScreenTitleHostCoachSample =>
      'Host coach sample';

  @override
  String get eventSuccessEventSuccessLabScreenLabelWorkInProgress =>
      'Work in progress';

  @override
  String get eventSuccessEventSuccessLabScreenLabelPreviewOnly =>
      'Preview only';

  @override
  String get eventSuccessEventSuccessLabScreenTextEventSuccessLayer =>
      'Event Success Layer';

  @override
  String get eventSuccessEventSuccessLabScreenTextAFirstPassWorkspace =>
      'A first-pass workspace for improving what happens during events: structure, attendance, assignments, live reveal moments, host help, feedback, and coaching.';

  @override
  String get eventSuccessEventSuccessLabScreenTitleAttendees => 'Attendees';

  @override
  String get eventSuccessEventSuccessLabScreenTitleHosts => 'Hosts';

  @override
  String get eventSuccessEventSuccessLabScreenTitleCatch => 'Catch';

  @override
  String get eventSuccessEventSuccessLabScreenBodyLearnWhichLiveStructures =>
      'Learn which live structures improve check-in, mixing, matches, chat starts, repeats, and safety.';

  @override
  String get eventSuccessEventSuccessLabScreenTitleIterationQuestions =>
      'Iteration questions';

  @override
  String get eventSuccessEventSuccessLabScreenTitleAntiPatterns =>
      'Anti-patterns';

  @override
  String get eventSuccessEventSuccessLabScreenTextRunOfShow => 'Run of show';

  @override
  String get eventSuccessEventSuccessLabScreenTextSampleDebrief =>
      'Sample debrief';

  @override
  String get eventSuccessEventSuccessLabScreenLabelCheckIn => 'Check-in';

  @override
  String get eventSuccessEventSuccessLabScreenLabelIntroCoverage =>
      'Intro coverage';

  @override
  String get eventSuccessEventSuccessLabScreenLabelCaughtSomeone =>
      'Caught someone';

  @override
  String get eventSuccessEventSuccessLabScreenLabelHostHelp => 'Host help';

  @override
  String get eventSuccessEventSuccessLabScreenLabelChatStart => 'Chat start';

  @override
  String get eventSuccessEventSuccessLabScreenTitleStrengths => 'Strengths';

  @override
  String get eventSuccessEventSuccessManualQaScreenLabelManualQa => 'Manual QA';

  @override
  String get eventSuccessEventSuccessManualQaScreenLabelFixtureData =>
      'Fixture data';

  @override
  String get eventSuccessEventSuccessManualQaScreenLabelQuestionnaireOff =>
      'Questionnaire off';

  @override
  String get eventSuccessEventSuccessManualQaScreenTextFixtureScenario =>
      'Fixture scenario';

  @override
  String get eventSuccessEventSuccessManualQaScreenTitleHostManage =>
      'Host Manage';

  @override
  String get eventSuccessEventSuccessManualQaScreenTitleAttendeeExperience =>
      'Attendee experience';

  @override
  String get eventSuccessEventSuccessManualQaScreenTitleMicroPodsOptOut =>
      'Micro-pods opt-out';

  @override
  String get eventSuccessEventSuccessManualQaScreenTitleRotationsOptOut =>
      'Rotations opt-out';

  @override
  String get eventSuccessEventSuccessManualQaScreenLabelFirstHelloComplete =>
      'first hello complete';

  @override
  String get eventSuccessEventSuccessManualQaScreenLabelFirstHelloSkipped =>
      'first hello skipped';

  @override
  String get eventSuccessEventSuccessManualQaScreenLabelFirstHelloPending =>
      'first hello pending';

  @override
  String get eventSuccessEventSuccessQuestionnaireConfigEditorTextQuestionSet =>
      'Question set';

  @override
  String get eventSuccessEventSuccessQuestionnaireConfigEditorLabelCustom =>
      'Custom';

  @override
  String
  get eventSuccessEventSuccessQuestionnaireConfigEditorTitleCustomQuestionSetName =>
      'Custom question set name';

  @override
  String
  get eventSuccessEventSuccessQuestionnaireConfigEditorLabelAddQuestion =>
      'Add question';

  @override
  String get eventSuccessEventSuccessQuestionnaireConfigEditorLabelReset =>
      'Reset';

  @override
  String
  get eventSuccessEventSuccessQuestionnaireConfigEditorMessageRemoveQuestion =>
      'Remove question';

  @override
  String get eventSuccessEventSuccessSetupBodyTitleYourGoalForTheEvent =>
      'Your goal for the event';

  @override
  String get eventSuccessEventSuccessSetupBodyTitleMessageToAttendees =>
      'Message to attendees';

  @override
  String
  get eventSuccessEventSuccessSetupBodyPlaceholderSomethingAttendeesSeeBeforeTheEventKicksOff =>
      'Something attendees see before the event kicks off.';

  @override
  String get eventSuccessEventSuccessSetupBodyTitleBeforeTheEvent =>
      'Before the event';

  @override
  String get eventSuccessEventSuccessSetupBodyTitleWhenPeopleArrive =>
      'When people arrive';

  @override
  String get eventSuccessEventSuccessSetupBodyTitleDuringTheEvent =>
      'During the event';

  @override
  String get eventSuccessEventSuccessSetupBodyTitleAfterTheEvent =>
      'After the event';

  @override
  String get eventSuccessEventSuccessSetupBodyLabelSwitchPartnersEvery =>
      'Switch partners every';

  @override
  String get eventSuccessEventSuccessSetupBodyLabelReset => 'Reset';

  @override
  String get eventSuccessEventSuccessSetupBodyTextMatchClueQuestions =>
      'Match clue questions';

  @override
  String get eventSuccessEventSuccessSetupBodyLabelRevealCountdown =>
      'Reveal countdown';

  @override
  String get eventSuccessEventSuccessSetupBodyTitleHowTheRoomIsGrouped =>
      'How the room is grouped';

  @override
  String get eventSuccessEventSuccessSetupBodyLabelOff => 'Off';

  @override
  String get eventSuccessEventSuccessSetupBodyLabelCluesOnly => 'Clues only';

  @override
  String get eventSuccessEventSuccessSetupBodyLabelCluesSoftPairing =>
      'Clues + soft pairing';

  @override
  String get eventSuccessEventSuccessSetupBodyTextOptionalPromptsAreOff =>
      'Optional prompts are off.';

  @override
  String get eventSuccessEventSuccessSetupBodyTextAnswersCreateRevealClues =>
      'Answers create reveal clues.';

  @override
  String
  get eventSuccessEventSuccessSetupBodyTextAnswersCreateCluesAndSoftlyGuidePairings =>
      'Answers create clues and softly guide pairings.';

  @override
  String get eventSuccessEventSuccessStructureConfigEditorTextGroupPeopleInto =>
      'Group people into';

  @override
  String
  get eventSuccessEventSuccessStructureConfigEditorDetailSetTheNumberYourselfOrLetCatchWorkItOutFromAttendance =>
      'Set the number yourself, or let Catch work it out from attendance.';

  @override
  String get eventSuccessEventSuccessStructureConfigEditorLabelAuto => 'Auto';

  @override
  String get eventSuccessEventSuccessStructureConfigEditorLabelFixed => 'Fixed';

  @override
  String
  get eventSuccessEventSuccessStructureConfigEditorTextOneSharedGroupFor =>
      'One shared group for the full event.';

  @override
  String
  get eventSuccessEventSuccessStructureConfigEditorTextCatchUsesThisWhenItBuildsTheGroups =>
      'Catch uses this when it builds the groups.';

  @override
  String
  get eventSuccessEventSuccessStructureConfigEditorTitleSpreadPeopleOutBy =>
      'Spread people out by';

  @override
  String
  get eventSuccessEventSuccessStructureConfigEditorTitleKeepSimilarPeopleTogetherBy =>
      'Keep similar people together by';

  @override
  String
  get eventSuccessEventSuccessStructureConfigEditorTextMeetingTheSamePersonAgain =>
      'Meeting the same person again';

  @override
  String
  get eventSuccessEventSuccessStructureConfigEditorLabelMaxTimesTheSamePairMeets =>
      'Max times the same pair meets';

  @override
  String
  get eventSuccessEventSuccessStructureConfigEditorDetailOnlyUsedWhenThereAreMoreRoundsThanPeopleToMeet =>
      'Only used when there are more rounds than people to meet.';

  @override
  String
  get eventSuccessEventSuccessStructureConfigEditorSemanticDecreasePeoplePerUnit =>
      'Decrease people per unit';

  @override
  String
  get eventSuccessEventSuccessStructureConfigEditorSemanticIncreasePeoplePerUnit =>
      'Increase people per unit';

  @override
  String
  get eventSuccessEventSuccessStructureConfigEditorSemanticDecreaseUnitCount =>
      'Decrease unit count';

  @override
  String
  get eventSuccessEventSuccessStructureConfigEditorSemanticIncreaseUnitCount =>
      'Increase unit count';

  @override
  String
  get eventSuccessEventSuccessStructureConfigEditorSemanticDecreaseMeetingsPerPair =>
      'Decrease meetings per pair';

  @override
  String
  get eventSuccessEventSuccessStructureConfigEditorSemanticIncreaseMeetingsPerPair =>
      'Increase meetings per pair';

  @override
  String
  get eventSuccessEventSuccessStructureConfigEditorTextStructureIsLockedOnce =>
      'Structure is locked once attendance or waitlist activity exists.';

  @override
  String get eventsCalendarScreenLabelCalendarDateHeaderDrag =>
      'Calendar date header. Drag up to collapse the month.';

  @override
  String get eventsCalendarScreenLabelCalendarDateHeaderDrag0f5be6 =>
      'Calendar date header. Drag down to expand the month.';

  @override
  String get eventsCalendarScreenLabelToday => 'Today';

  @override
  String get eventsCalendarScreenLabelPlanned => 'Planned';

  @override
  String get eventsCalendarScreenLabelDistance => 'Distance';

  @override
  String get eventsCalendarScreenLabelNext => 'Next';

  @override
  String get eventsEventDetailScreenBodyEventid => 'eventId';

  @override
  String get eventsEventDetailScreenBodyClubid => 'clubId';

  @override
  String get eventsEventLocationMapBodyScreenLabelGetDirections =>
      'Get directions';

  @override
  String get eventsEventMapScreenTitleNoMappedEventsYet =>
      'No mapped events yet';

  @override
  String get eventsEventMapScreenMessageJoinClubsBookEvents =>
      'Follow organizers, book events, or save future events to see starting points here.';

  @override
  String get eventsLocationPickerScreenTitleSearchForAMeeting =>
      'Search for a meeting point';

  @override
  String get eventsLocationPickerScreenPlaceholderSearchForAMeeting =>
      'Search for a meeting point';

  @override
  String get eventsLocationPickerScreenTitlePinnedLocation => 'Pinned location';

  @override
  String get eventsLocationPickerScreenTitleNoLocationSelected =>
      'No location selected';

  @override
  String get eventsLocationPickerScreenSubtitleConfirmThisMapPin =>
      'Confirm this map pin or tap elsewhere to adjust.';

  @override
  String get eventsLocationPickerScreenSubtitleConfirmThisPlaceOr =>
      'Confirm this place or tap elsewhere to adjust.';

  @override
  String get eventsLocationPickerScreenSubtitleSearchForAPlace =>
      'Search for a place or tap the map to set the meeting point.';

  @override
  String get eventsLocationPickerScreenLabelConfirmLocation =>
      'Confirm location';

  @override
  String get eventsSavedEventsScreenTitleNoSavedEventsYet =>
      'No saved events yet';

  @override
  String get eventsSavedEventsScreenMessageSaveEventsYouWant =>
      'Save events you want to revisit before booking.';

  @override
  String get eventsSavedEventsScreenTextEventsYouSaved => 'Events you saved';

  @override
  String get eventsBookingConflictSheetLabelBookingTimeConflict =>
      'Booking time conflict';

  @override
  String get eventsBookingConflictSheetTextThatSTheSame =>
      'That\'s the same time slot';

  @override
  String get eventsBookingConflictSheetLabelCancelExistingBookThis =>
      'Cancel existing & book this';

  @override
  String get eventsBookingConflictSheetLabelKeepBoth => 'Keep both';

  @override
  String get eventsBookingConflictSheetLabelKeepExistingOnly =>
      'Keep existing only';

  @override
  String get eventsEventDetailBodyTitleBringSomeoneIntoThe =>
      'Bring someone into the room';

  @override
  String get eventsEventDetailBodyBodyYourSpotIsBooked =>
      'Your spot is booked. Invite a friend who would make this event better.';

  @override
  String get eventsEventDetailBodyActionlabelInviteAFriend => 'Invite a friend';

  @override
  String get eventsEventDetailBodyTitleEventCompanion => 'Event companion';

  @override
  String get eventsEventDetailBodyBodyCheckInSeeYour =>
      'Check in, see your social prompt, and handle private follow-up after the event.';

  @override
  String get eventsEventDetailBodyActionlabelOpenCompanion => 'Open companion';

  @override
  String get eventsEventDetailBodyLabelSignInToBook =>
      'Sign in to book this event';

  @override
  String get eventsEventDetailBodyTitleHostedBy => 'Hosted by';

  @override
  String get eventsEventDetailBodyTooltipMessageHost => 'Message host';

  @override
  String get eventsEventDetailCtaLabelYouReIn => 'You\'re in!';

  @override
  String get eventsEventDetailCtaLabelCompleted => 'Completed';

  @override
  String get eventsEventDetailCtaTextPerPerson => 'per person';

  @override
  String get eventsEventDetailCtaLabelDeclining => 'Declining';

  @override
  String get eventsEventDetailCtaLabelDecline => 'Decline';

  @override
  String get eventsEventDetailDesignPrimitivesTextEventPhotos => 'EVENT PHOTOS';

  @override
  String get eventsEventDetailHeroAppBarTooltipBack => 'Back';

  @override
  String get eventsEventDetailHeroAppBarTooltipShareEvent => 'Share event';

  @override
  String get eventsEventDetailHeroAppBarTooltipAddToCalendar =>
      'Add to calendar';

  @override
  String get eventsEventDetailHeroAppBarTooltipUnsaveEvent => 'Unsave event';

  @override
  String get eventsEventDetailHeroAppBarTooltipSaveEvent => 'Save event';

  @override
  String get eventsEventDetailLoadingSkeletonTitleThePlan => 'The plan';

  @override
  String get eventsEventDetailLoadingSkeletonTitleWhyYouMightClick =>
      'Why you might click';

  @override
  String get eventsEventDetailLoadingSkeletonTitleItinerary => 'Itinerary';

  @override
  String get eventsEventDetailLoadingSkeletonTitleWhere => 'Where';

  @override
  String get eventsEventDetailLoadingSkeletonTitleHowSignUpsWork =>
      'How sign-ups work';

  @override
  String get eventsEventDetailLoadingSkeletonTitleWhoSGoing => 'Who\'s going';

  @override
  String get eventsEventDetailOverviewSectionTitleThePlan => 'The plan';

  @override
  String get eventsEventDetailOverviewSectionTitleWhyYouMightClick =>
      'Why you might click';

  @override
  String get eventsEventDetailOverviewSectionTextBasedOnEventFormat =>
      'Based on event format, capacity and booking rules — never shown to the group.';

  @override
  String get eventsEventDetailOverviewSectionTitleItinerary => 'Itinerary';

  @override
  String get eventsEventDetailOverviewSectionTitlePhotos => 'Photos';

  @override
  String get eventsEventDetailOverviewSectionTitleWhere => 'Where';

  @override
  String get eventsEventDetailOverviewSectionTitleHowSignUpsWork =>
      'How sign-ups work';

  @override
  String get eventsEventDetailOverviewSectionTitleGoodToKnow => 'Good to know';

  @override
  String get eventsEventDetailOverviewSectionTextAboutThisEvent =>
      'About this event';

  @override
  String get eventsEventDetailOverviewSectionTitleDemandPricing =>
      'Demand pricing';

  @override
  String get eventsEventDetailSocialSectionTitleWhoSGoing => 'Who\'s going';

  @override
  String get eventsEventDetailSocialSectionTitleReviews => 'Reviews';

  @override
  String get eventsEventDetailSocialSectionTextWhoSGoing => 'Who\'s going';

  @override
  String get eventsEventDetailSocialSectionTextSignInToSee =>
      'Sign in to see who has booked this event.';

  @override
  String get eventsEventPinsMapLabelEventMapPreview => 'Event map preview';

  @override
  String get eventsRequirementsRowTextRequirements => 'Requirements';

  @override
  String get eventsWhoIsGoingTextWhoSGoing => 'Who\'s going';

  @override
  String get eventsWhoIsGoingTitleNoAttendeesYet => 'No attendees yet';

  @override
  String get eventsWhoIsGoingTitleNoAttendeesBooked => 'No attendees booked';

  @override
  String get eventsWhoIsGoingMessageBeTheFirstTo =>
      'Be the first to book this event.';

  @override
  String get eventsWhoIsGoingMessageThisEventDidNot =>
      'This event did not have any booked attendees.';

  @override
  String get eventsWhoIsGoingMessageCatchesUnlockFor24 =>
      'Catches unlock for 24 hours after the event finishes.';

  @override
  String get eventsWhoIsGoingMessageTheCatchWindowIs =>
      'The catch window is open for 24 hours after the event finishes.';

  @override
  String get eventsWhoIsGoingMessageTheCatchWindowFor =>
      'The catch window for this event has closed.';

  @override
  String get eventsEventCheckInCelebrationScreenEyebrowCheckedIn =>
      'Checked in';

  @override
  String get eventsEventCheckInCelebrationScreenTitleCheckedIn => 'Checked in.';

  @override
  String get eventsEventCheckInCelebrationScreenMessageYouReOnThe =>
      'You\'re on the roster. Have a great event.';

  @override
  String get eventsEventCheckInCelebrationScreenLabelEvent => 'Event';

  @override
  String get eventsEventCheckInCelebrationScreenLabelStarts => 'Starts';

  @override
  String get eventsEventCheckInCelebrationScreenLabelMeetPoint => 'Meet point';

  @override
  String get eventsEventCheckInCelebrationScreenLabelViewEvent => 'View event';

  @override
  String get eventsEventCheckInCelebrationScreenLabelBackToHome =>
      'Back to home';

  @override
  String get eventsEventJoinedCelebrationScreenEyebrowBookingConfirmed =>
      'Booking confirmed';

  @override
  String get eventsEventJoinedCelebrationScreenTitleYouReIn => 'You\'re in.';

  @override
  String get eventsEventJoinedCelebrationScreenLabelWhen => 'When';

  @override
  String get eventsEventJoinedCelebrationScreenLabelWhere => 'Where';

  @override
  String get eventsEventJoinedCelebrationScreenLabelEvent => 'Event';

  @override
  String get eventsEventJoinedCelebrationScreenLabelPaid => 'Paid';

  @override
  String get eventsEventJoinedCelebrationScreenLabelPaymentId => 'Payment ID';

  @override
  String get eventsEventJoinedCelebrationScreenNoteArriveByTheMeeting =>
      'Arrive by the meeting time. Catches unlock automatically when the event finishes.';

  @override
  String get eventsEventJoinedCelebrationScreenLabelViewEvent => 'View event';

  @override
  String get eventsEventJoinedCelebrationScreenLabelBackToHome =>
      'Back to home';

  @override
  String get eventsEventShareCardTextCatchInvite => 'CATCH INVITE';

  @override
  String get eventsMapPinTileTitlePinnedLocation => 'Pinned location';

  @override
  String get eventsMapPinTileTitleChooseOnMap => 'Choose on map';

  @override
  String get exploreExploreMapScreenTooltipBackToExplore => 'Back to Explore';

  @override
  String get exploreExploreScreenTooltipSavedEvents => 'Saved events';

  @override
  String get exploreExploreScreenActionLoadMorePlans => 'Load more plans';

  @override
  String get exploreExploreScreenTitleNoClubsMatchThis =>
      'No organizers match this search';

  @override
  String get exploreExploreScreenMessageClearTheSearchOr =>
      'Clear the search or filters to bring nearby organizers back into view.';

  @override
  String get exploreExploreScreenMessageTryAnotherClubNeighborhood =>
      'Try another organizer, neighborhood, host, or tag.';

  @override
  String get exploreExploreScreenTitleNoClubsMatchThese =>
      'No organizers match these filters';

  @override
  String get exploreExploreScreenMessageClearOneOrMore =>
      'Clear one or more filters to bring nearby organizers back into view.';

  @override
  String get exploreExploreScreenLabelClearSearchAndFilters =>
      'Clear search and filters';

  @override
  String get exploreExploreScreenLabelClearSearch => 'Clear search';

  @override
  String get exploreExploreScreenLabelClearFilters => 'Clear filters';

  @override
  String get exploreExploreScreenLabelClear => 'Clear';

  @override
  String get exploreExploreScreenLabelChangeCity => 'Change city';

  @override
  String get exploreCatchCoverStoryMessageChangeLocation => 'Change location';

  @override
  String get exploreCatchCoverStoryTooltipSearch => 'Search';

  @override
  String get exploreExploreCityPickerTextCity => 'City';

  @override
  String get exploreExploreEventRowsTitleThisWeek => 'This week';

  @override
  String get exploreExploreEventTypeBrowseGridTextByActivity => 'BY ACTIVITY';

  @override
  String get exploreExploreFilterRailTitleExploreFilters => 'Explore filters';

  @override
  String get exploreExploreFilterRailSubtitleNarrowTheMapAnd =>
      'Narrow the map and feed without changing your time scope.';

  @override
  String get exploreExploreFilterRailLabelClear => 'Clear';

  @override
  String get exploreExploreFilterRailLabelUpdatingPlans => 'Updating plans';

  @override
  String exploreExploreFilterRailLabelShowPlans({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count plans',
      one: 'Show 1 plan',
    );
    return '$_temp0';
  }

  @override
  String exploreExploreFilterRailLabelShowPlansPlus({required int count}) {
    return 'Show $count+ plans';
  }

  @override
  String get exploreExploreFilterRailTextDistanceEventsOnly =>
      'DISTANCE · EVENTS ONLY';

  @override
  String exploreExploreFilterRailAppliedDistance({required Object distance}) {
    return '$distance · events only';
  }

  @override
  String get exploreExploreFilterRailTextClubs => 'ORGANIZERS';

  @override
  String get exploreExploreFilterRailLabelJoinedClubs => 'Followed organizers';

  @override
  String get exploreExploreFilterRailLabelRated45 => 'Rated 4.5+';

  @override
  String get exploreExploreFilterRailTextActivity => 'ACTIVITY';

  @override
  String get exploreExploreFilterRailTextArea => 'AREA';

  @override
  String get exploreExploreListTitleNoClubsMatchThis =>
      'No organizers match this search';

  @override
  String get exploreExploreListMessageClearTheSearchOr =>
      'Clear the search or filters to bring nearby organizers back into view.';

  @override
  String get exploreExploreListMessageTryAnotherClubNeighborhood =>
      'Try another organizer, neighborhood, host, or tag.';

  @override
  String get exploreExploreListTitleNoClubsMatchThese =>
      'No organizers match these filters';

  @override
  String get exploreExploreListMessageClearOneOrMore =>
      'Clear one or more filters to bring nearby organizers back into view.';

  @override
  String get forceUpdateUpdateRequiredScreenTextUpdateRequired =>
      'Update required';

  @override
  String get forceUpdateUpdateRequiredScreenLabelUpdateNow => 'Update now';

  @override
  String get hostsCreateClubScreenTitleClubBasics => 'Organizer basics';

  @override
  String get hostsCreateClubScreenTitleClubDetails => 'Organizer details';

  @override
  String get hostsCreateClubScreenTitleHostDefaults => 'Host defaults';

  @override
  String get hostsCreateClubScreenTitleEventSuccessDefaults =>
      'Event success defaults';

  @override
  String get hostsClubBasicsStepTitleClubName => 'Organizer name';

  @override
  String get hostsOrganizerTypeLabel => 'Organizer type';

  @override
  String get hostsOrganizerTypeClub => 'Club';

  @override
  String get hostsOrganizerTypeCommunity => 'Community';

  @override
  String get hostsOrganizerTypeIndividual => 'Individual organizer';

  @override
  String get hostsOrganizerTypeEventProducer => 'Event producer';

  @override
  String get hostsOrganizerTypeVenue => 'Venue';

  @override
  String get hostsOrganizerTypeBrand => 'Brand';

  @override
  String get hostsClubBasicsStepTitleCity => 'City';

  @override
  String get hostsClubBasicsStepTitleAreaNeighbourhood =>
      'Area / neighbourhood';

  @override
  String get hostsClubBasicsStepPlaceholderEGBandraKoramangala =>
      'e.g. Bandra, Koramangala';

  @override
  String get hostsClubDetailsStepTitleDescription => 'Description';

  @override
  String get hostsClubEventSuccessDefaultsStepTitleLiveEventGuide =>
      'Live event guide';

  @override
  String
  get hostsClubEventSuccessDefaultsStepSubtitleNewEventsStartWithAReadyToRunPlanForThisActivity =>
      'New events start with a ready-to-run plan for this activity. You can adjust any event\'s plan later.';

  @override
  String get hostsClubHostDefaultsStepTextDefaultActivity => 'Default activity';

  @override
  String get hostsClubHostDefaultsStepTextNewEventsStartFrom =>
      'New events start from this activity. Hosts can still change the activity and override the event-specific setup.';

  @override
  String get hostsClubHostDefaultsStepTextDefaultEventPolicy =>
      'Default event policy';

  @override
  String get hostsClubHostDefaultsStepTextTheseDefaultsPrefillNew =>
      'These defaults prefill new events. Hosts can override them per event before anyone books or joins the waitlist.';

  @override
  String get hostsClubHostDefaultsStepTitleCohortCaps => 'Cohort caps';

  @override
  String get hostsClubHostDefaultsStepBodyOptionallyPrefillStraightMen =>
      'Optionally prefill straight men and straight women caps for open events.';

  @override
  String get hostsClubHostDefaultsStepTitleMaxStraightMen => 'Max straight men';

  @override
  String get hostsClubHostDefaultsStepTitleMaxStraightWomen =>
      'Max straight women';

  @override
  String get hostsClubHostDefaultsStepTitleDemandPricing => 'Demand pricing';

  @override
  String get hostsClubHostDefaultsStepBodyPrefillDynamicPricingControls =>
      'Prefill dynamic pricing controls for balanced singles events.';

  @override
  String get hostsClubHostDefaultsStepTitleStep => 'Step';

  @override
  String get hostsClubHostDefaultsStepTitleMax => 'Max';

  @override
  String get hostsCreateClubContactFieldsTitleInstagramHandle =>
      'Instagram handle';

  @override
  String get hostsCreateClubContactFieldsPlaceholderYourclub => '@yourclub';

  @override
  String get hostsCreateClubContactFieldsTitlePhoneNumber => 'Phone number';

  @override
  String get hostsCreateClubContactFieldsTitleEmail => 'Email';

  @override
  String get hostsCreateClubContactFieldsPlaceholderHelloYourclubCom =>
      'hello@yourclub.com';

  @override
  String get hostsCreateClubPhotosPickerTextDragToReorderThe =>
      'Drag to reorder - the first photo is your cover. Add as many as you like.';

  @override
  String get hostsCreateClubPhotosPickerTextASquareLogoShown =>
      'A square logo, shown on your organizer profile and every event.';

  @override
  String get hostsCreateClubPhotosPickerLabelChangeClubProfileImage =>
      'Change organizer profile image';

  @override
  String get hostsCreateClubPhotosPickerLabelAddClubProfileImage =>
      'Add organizer profile image';

  @override
  String get hostsCreateClubPhotosPickerTextAddImage => 'Add image';

  @override
  String get hostsEditHostedEventScreenBodyDecreaseDuration =>
      'Decrease duration';

  @override
  String get hostsEditHostedEventScreenBodyIncreaseDuration =>
      'Increase duration';

  @override
  String get hostsEditHostedEventScreenTitleLocationName => 'Location name';

  @override
  String get hostsEditHostedEventScreenPlaceholderEGBandstandPromenade =>
      'e.g. Bandstand Promenade, Bandra';

  @override
  String get hostsEditHostedEventScreenHelpertextThisIsWhatAttendees =>
      'This is what attendees see in event cards and details.';

  @override
  String get hostsEditHostedEventScreenBodyRequired => 'Required';

  @override
  String get hostsEditHostedEventScreenTitleExtraDirections =>
      'Extra directions';

  @override
  String get hostsEditHostedEventScreenPlaceholderEGMeetOutside =>
      'e.g. Meet outside the blue gate, third entrance';

  @override
  String get hostsEditHostedEventScreenTitleDistanceKm => 'Distance (km)';

  @override
  String get hostsEditHostedEventScreenBodyDD => '^\\d*\\.?\\d*';

  @override
  String get hostsEditHostedEventScreenBodyInvalid => 'Invalid';

  @override
  String get hostsEditHostedEventScreenBodyMustBe0 => 'Must be > 0';

  @override
  String get hostsEditHostedEventScreenTitleDescription => 'Description';

  @override
  String get hostsEditHostedEventScreenPlaceholderWhatShouldAttendeesExpect =>
      'What should attendees expect? Any tips for the route or venue?';

  @override
  String get hostsEditHostedEventScreenTitleEventDate => 'Event date';

  @override
  String get hostsEditHostedEventScreenTitleStartTime => 'Start time';

  @override
  String get hostsEditHostedEventScreenTitleCancelledEvent => 'Cancelled event';

  @override
  String get hostsEditHostedEventScreenTitleScheduleLocked => 'Schedule locked';

  @override
  String get hostsEditHostedEventScreenTitlePublishedEvent => 'Published event';

  @override
  String get hostsEditHostedEventScreenMessageCancelledEventsCannotBe =>
      'Cancelled events cannot be edited. Create a new event if you need to host this again.';

  @override
  String get hostsEditHostedEventScreenMessageYouCanStillUpdate =>
      'You can still update location and descriptive details. Date, time, and duration stay locked after the event starts or once people have joined.';

  @override
  String get hostsEditHostedEventScreenMessageYouCanEditThe =>
      'You can edit the schedule, location, distance, and description. Capacity, pricing, admission policy, and invite setup are locked by existing event activity.';

  @override
  String get hostsEditHostedEventScreenMessageYouCanEditSchedule =>
      'You can edit schedule, location, event details, capacity, pricing, admission policy, and invite setup until the first booking or waitlist join.';

  @override
  String get hostsEditHostedEventScreenTextEditableUntilTheFirst =>
      'Editable until the first booking or waitlist join.';

  @override
  String get hostsEditHostedEventScreenTitleMaxAttendees => 'Max attendees';

  @override
  String get hostsEditHostedEventScreenTextLoadingCurrentInviteCode =>
      'Loading current invite code...';

  @override
  String get hostsEditHostedEventScreenTitleInviteCode => 'Invite code';

  @override
  String get hostsEditHostedEventScreenPlaceholderCatchDelhi => 'CATCH-DELHI';

  @override
  String get hostsEditHostedEventScreenTitleCohortCaps => 'Cohort caps';

  @override
  String get hostsEditHostedEventScreenBodyOptionallyCapStraightMen =>
      'Optionally cap straight men and straight women without making this a separate admission format.';

  @override
  String get hostsEditHostedEventScreenTitleMaxStraightMen =>
      'Max straight men';

  @override
  String get hostsEditHostedEventScreenTitleMaxStraightWomen =>
      'Max straight women';

  @override
  String get hostsEditHostedEventScreenTextRequestsAppearInHost =>
      'Requests appear in host manage with each person\'s public profile so the host can review fit before confirming spots.';

  @override
  String get hostsEditHostedEventScreenTitleDemandPricing => 'Demand pricing';

  @override
  String get hostsEditHostedEventScreenBodyIncreasePriceForThe =>
      'Increase price for the over-demand cohort while preserving the event balance.';

  @override
  String get hostsEditHostedEventScreenTextPolicyLocked => 'Policy locked';

  @override
  String get hostsEditHostedEventScreenTextCapacityPricingAdmissionAnd =>
      'Capacity, pricing, admission, and cancellation policy lock once the event starts or someone books or joins the waitlist.';

  @override
  String get hostsEditHostedEventScreenLabelCapacity => 'Capacity';

  @override
  String get hostsEditHostedEventScreenLabelPrice => 'Price';

  @override
  String get hostsEditHostedEventScreenLabelAdmission => 'Admission';

  @override
  String get hostsEditHostedEventScreenLabelCancellation => 'Cancellation';

  @override
  String get hostsEditHostedEventScreenTextScheduleChangesAreBlocked =>
      'Schedule changes are blocked here to avoid changing attendee commitments.';

  @override
  String get hostsCreateEventScreenTitleEventDate => 'Event date';

  @override
  String get hostsCreateEventScreenTitleStartTime => 'Start time';

  @override
  String get hostsCreateEventSuccessScreenEyebrowEventCreated =>
      'Event created';

  @override
  String get hostsCreateEventSuccessScreenTitleYourEventIsLive =>
      'Your event is live.';

  @override
  String get hostsCreateEventSuccessScreenLabelWhen => 'When';

  @override
  String get hostsCreateEventSuccessScreenLabelWhere => 'Where';

  @override
  String get hostsCreateEventSuccessScreenLabelEvent => 'Event';

  @override
  String get hostsCreateEventSuccessScreenLabelCapacity => 'Capacity';

  @override
  String get hostsCreateEventSuccessScreenLabelInviteCode => 'Invite code';

  @override
  String get hostsCreateEventSuccessScreenLabelPrivateLink => 'Private link';

  @override
  String get hostsCreateEventSuccessScreenNoteBookingsWaitlistAndAttendance =>
      'Bookings, waitlist, and attendance are tracked from Manage event.';

  @override
  String get hostsCreateEventSuccessScreenLabelManageEvent => 'Manage event';

  @override
  String get hostsCreateEventSuccessScreenLabelBackToClub =>
      'Back to organizer';

  @override
  String get hostsHostCreateEventRouteLoadingScreenTitleEventBasics =>
      'Event basics';

  @override
  String get hostsHostCreateEventRouteLoadingScreenBodyLoadingClub =>
      'Loading organizer';

  @override
  String get hostsDraftPickerSheetTitleResumeADraft => 'Resume a draft?';

  @override
  String get hostsDraftPickerSheetSubtitlePickUpWhereYou =>
      'Pick up where you left off, or start fresh.';

  @override
  String get hostsDraftPickerSheetLabelStartAFreshEvent =>
      'Start a fresh event';

  @override
  String get hostsDraftPickerSheetTitleNoDraftsYet => 'No drafts yet';

  @override
  String get hostsDraftPickerSheetMessageSavedDraftsForThis =>
      'Saved drafts for this organizer will appear here.';

  @override
  String get hostsDraftPickerSheetMessageDeleteDraft => 'Delete draft';

  @override
  String get hostsEventDetailsStepTitleFormatName => 'Format name';

  @override
  String get hostsEventDetailsStepPlaceholderSalsaNight => 'Salsa night';

  @override
  String get hostsEventDetailsStepTitleDistanceKm => 'Distance (km)';

  @override
  String get hostsEventDetailsStepTitleDescription => 'Description';

  @override
  String get hostsEventDetailsStepPlaceholderWhatShouldAttendeesExpect =>
      'What should attendees expect? Any tips for the route or venue?';

  @override
  String get hostsEventPolicyStepTextConfigureWhoCanBook =>
      'Configure who can book, how waitlists open, what attendees pay, and what happens if plans change.';

  @override
  String get hostsEventPolicyStepTitleMaxAttendees => 'Max attendees';

  @override
  String get hostsEventPolicyStepTextTheCodeIsStored =>
      'The code is stored in the host-only private access document. Public event listings only show that an invite is required.';

  @override
  String get hostsEventPolicyStepTitleInviteCode => 'Invite code';

  @override
  String get hostsEventPolicyStepPlaceholderCatchDelhi => 'CATCH-DELHI';

  @override
  String get hostsEventPolicyStepTitleCohortCaps => 'Cohort caps';

  @override
  String get hostsEventPolicyStepBodyOptionallyCapStraightMen =>
      'Optionally cap straight men and straight women without making this a separate admission format.';

  @override
  String get hostsEventPolicyStepTitleMaxStraightMen => 'Max straight men';

  @override
  String get hostsEventPolicyStepPlaceholderMaxMen => 'Max men';

  @override
  String get hostsEventPolicyStepTitleMaxStraightWomen => 'Max straight women';

  @override
  String get hostsEventPolicyStepPlaceholderMaxWomen => 'Max women';

  @override
  String get hostsEventPolicyStepTextRequestsAppearInHost =>
      'Requests appear in host manage with each person\'s public profile so the host can review fit before confirming spots.';

  @override
  String get hostsEventPolicyStepTitleDemandPricing => 'Demand pricing';

  @override
  String get hostsEventPolicyStepBodyIncreaseTheStraightMen =>
      'Increase the straight-men price when that cohort has more booked and waitlisted demand than the balancing cohort.';

  @override
  String get hostsEventPolicyStepTextHostPayoutIsReleased =>
      'Host payout is released after event completion. If the host cancels, attendees are made complete before any host payout.';

  @override
  String get hostsEventSuccessStepTextPrepareTheHostGuide =>
      'Prepare the host guide for this event. You can adjust it again before Live mode starts.';

  @override
  String get hostsEventSuccessStepTitleLiveEventGuide => 'Live event guide';

  @override
  String get hostsEventSuccessStepSubtitleSaveASimplePlan =>
      'Save a simple plan with this event so Live mode is ready when it starts.';

  @override
  String get hostsWhenStepPlaceholderSelectADate => 'Select a date';

  @override
  String get hostsWhenStepPlaceholderSelectStartTime => 'Select start time';

  @override
  String get hostsWhereStepTitleLocationName => 'Location name';

  @override
  String get hostsWhereStepPlaceholderEGBandstandPromenade =>
      'e.g. Bandstand Promenade, Bandra';

  @override
  String get hostsWhereStepHelpertextPickAMapLocation =>
      'Pick a map location first. Google Places fills this when available.';

  @override
  String get hostsWhereStepHelpertextEditThisIfAttendees =>
      'Edit this if attendees need a clearer name.';

  @override
  String get hostsWhereStepTitleExtraDirections => 'Extra directions';

  @override
  String get hostsWhereStepPlaceholderEGMeetOutside =>
      'e.g. Meet outside the blue gate, third entrance';

  @override
  String get hostsWhereStepHelpertextGateEntranceFloorOr =>
      'Gate, entrance, floor, or landmark for the group.';

  @override
  String get hostsHostEventManageScreenTitleCancelThisEvent =>
      'Cancel this event?';

  @override
  String get hostsHostEventManageScreenMessageCancellingRemovesItFrom =>
      'Cancelling removes it from schedules but keeps attendee, payment, and history records. Attendees are notified and refunded per your cancellation policy.';

  @override
  String get hostsHostEventManageScreenTitleDeleteUnusedEvent =>
      'Delete unused event?';

  @override
  String get hostsHostEventManageScreenMessageOnlyEventsWithNo =>
      'Only events with no bookings, waitlist, attendance, payments, or reviews can be deleted. This permanently removes the event.';

  @override
  String get hostsHostEventManageScreenTitleDisableInviteLink =>
      'Disable invite link?';

  @override
  String get hostsHostEventManageScreenTextLoadingInviteAccess =>
      'Loading invite access...';

  @override
  String get hostsHostEventManageScreenTextPrivateAccess => 'Private access';

  @override
  String get hostsHostEventManageScreenLabelCode => 'Code';

  @override
  String get hostsHostEventManageScreenLabelLink => 'Link';

  @override
  String get hostsHostEventManageScreenLabelSharePrivateLink =>
      'Share private link';

  @override
  String get hostsHostEventManageScreenLabelNewLink => 'New link';

  @override
  String get hostsHostEventManageScreenTextNamedInviteLinks =>
      'Named invite links';

  @override
  String get hostsHostEventManageScreenTextTrackWhichChannelsCreate =>
      'Track which channels create demand, bookings, arrivals, catches, and chats.';

  @override
  String get hostsHostEventManageScreenTextLoadingInviteLinks =>
      'Loading invite links...';

  @override
  String get hostsHostEventManageScreenMessageCopyLink => 'Copy link';

  @override
  String get hostsHostEventManageScreenMessageDisableLink => 'Disable link';

  @override
  String get hostsHostEventManageScreenTitleNewInviteLink => 'New invite link';

  @override
  String get hostsHostEventManageScreenLabelCancel => 'Cancel';

  @override
  String get hostsHostEventManageScreenLabelCreate => 'Create';

  @override
  String get hostsHostEventManageScreenTitleLabel => 'Label';

  @override
  String get hostsHostEventManageScreenPlaceholderInstagramBio =>
      'Instagram bio';

  @override
  String get hostsHostEventManageScreenTitleSource => 'Source';

  @override
  String get hostsHostEventManageScreenPlaceholderInstagram => 'instagram';

  @override
  String get hostsHostEventManageScreenLabelBooked => 'Booked';

  @override
  String get hostsHostEventManageScreenLabelWaitlist => 'Waitlist';

  @override
  String get hostsHostEventManageScreenDetail1ToReview => '1 to review';

  @override
  String get hostsHostEventManageScreenLabelRevenueEst => 'Revenue est';

  @override
  String get hostsHostEventManageScreenLabelRefundPolicy => 'Refund policy';

  @override
  String get hostsHostEventManageScreenTextFullCapacityReached =>
      'FULL - CAPACITY REACHED';

  @override
  String get hostsHostEventManageScreenTextWaitlistOpen => 'WAITLIST OPEN';

  @override
  String get hostsHostEventManageScreenTextHostActions => 'HOST ACTIONS';

  @override
  String get hostsHostEventManageScreenLabelEditEventDetails =>
      'Edit event details';

  @override
  String get hostsHostEventManageScreenDetailScheduleLocation =>
      'Schedule · location';

  @override
  String get hostsHostEventManageScreenTextDangerZone => 'DANGER ZONE';

  @override
  String get hostsHostEventManageScreenLabelCancelEvent => 'Cancel event';

  @override
  String get hostsHostEventManageScreenLabelDeleteUnusedEvent =>
      'Delete unused event';

  @override
  String get hostsHostEventManageScreenLabelClub => 'Organizer';

  @override
  String get hostsHostEventManageScreenLabelMeet => 'Meet';

  @override
  String get hostsHostEventManageScreenLabelEvent => 'Event';

  @override
  String get hostsHostEventManageScreenLabelPrice => 'Price';

  @override
  String get hostsHostBroadcastComposerSheetTitleNewBroadcast =>
      'New broadcast';

  @override
  String get hostsHostBroadcastComposerSheetTextAudience => 'Audience';

  @override
  String get hostsHostBroadcastComposerSheetTextTemplate => 'Template';

  @override
  String get hostsHostBroadcastComposerSheetTitleMessage => 'Message';

  @override
  String get hostsHostBroadcastComposerSheetPlaceholderWriteAClearUpdate =>
      'Write a clear update for attendees';

  @override
  String get hostsHostBroadcastComposerSheetTextSendingStaysOffIn =>
      'Sending stays off in this build until the production callable passes the release preflight.';

  @override
  String get hostsHostBroadcastComposerSheetTextThisAudienceHasNo =>
      'This audience has no eligible recipients yet.';

  @override
  String get hostsHostBroadcastComposerSheetLabelSendTo1Person =>
      'Send to 1 person';

  @override
  String get hostsHostInboxScreenLabelInboxScope => 'Inbox scope';

  @override
  String get hostsHostInboxScreenTitleBookedAttendees => 'booked attendees';

  @override
  String get hostsHostInboxScreenTitleProspectiveAttendees =>
      'prospective attendees';

  @override
  String get hostsHostInboxScreenMessagePersonalQuestionsAppearHere =>
      'Personal questions appear here. Broadcast audience size is based on the event roster, not this thread list.';

  @override
  String get hostsHostPaymentAccountCardTitleSetUpPayouts => 'Set up payouts';

  @override
  String get hostsHostPaymentAccountCardSubtitlePoweredByStripe =>
      'Powered by Stripe';

  @override
  String get hostsHostPaymentAccountCardLabelContinueToStripe =>
      'Continue to Stripe';

  @override
  String get hostsHostPaymentAccountCardTextCatchPaysHostsThrough =>
      'Catch pays hosts through Stripe. Finish a short verification on Stripe, then come back here before paid non-INR events can take checkout.';

  @override
  String get hostsHostPaymentAccountCardTitleCountry => 'Country';

  @override
  String get hostsHostPaymentAccountCardTitleDefaultCurrency =>
      'Default currency';

  @override
  String get hostsHostPaymentAccountCardTextWeWillRefreshYour =>
      'We will refresh your payout status when you return.';

  @override
  String get hostsHostPaymentAccountCardLabelSetUpPayouts => 'Set up payouts';

  @override
  String get hostsHostPaymentAccountCardLabelContinueSetup => 'Continue setup';

  @override
  String get hostsHostPaymentAccountCardLabelRefresh => 'Refresh';

  @override
  String get hostsCatchRosterBoardLabelOpenProfile => 'Open profile';

  @override
  String get hostsCatchRosterBoardLabelApproveRequest => 'Approve request';

  @override
  String get hostsCatchRosterBoardLabelDeclineRequest => 'Decline request';

  @override
  String get hostsHostClubToolsTextManageThisClubPublish =>
      'Manage this organizer, publish events, and track upcoming demand.';

  @override
  String get hostsHostClubToolsLabelBooked => 'Booked';

  @override
  String get hostsHostClubToolsLabelWaitlist => 'Waitlist';

  @override
  String get hostsHostClubToolsLabelBaseEst => 'Base est.';

  @override
  String get hostsHostClubToolsLabelRevenue => 'Revenue';

  @override
  String get hostsHostClubToolsTextBaseEstimateUsesStarting =>
      'Base estimate uses starting prices; demand-priced bookings may settle higher.';

  @override
  String get hostsHostClubToolsLabelAddEvent => 'Add event';

  @override
  String get hostsHostClubToolsLabelPostQuotaUsed => 'Post quota used';

  @override
  String get hostsHostClubToolsLabelPostUpdate => 'Post update';

  @override
  String get hostsHostClubToolsLabelEditClub => 'Edit organizer';

  @override
  String get hostsHostClubToolsTitlePostToFollowers => 'Post to followers';

  @override
  String get hostsHostClubToolsLabelPosting => 'Posting...';

  @override
  String get hostsHostClubToolsCatchbuttonPostedToFollowers =>
      'Posted to followers.';

  @override
  String get hostsHostClubToolsTitleUpdate => 'Update';

  @override
  String get hostsHostClubToolsPlaceholderShareARouteNote =>
      'Share a route note, meetup detail, or organizer update.';

  @override
  String get hostsHostClubToolsTextCouldNotPostThis =>
      'Could not post this update. Please try again.';

  @override
  String get hostsHostEventAttendancePanelTitleEventNotFound =>
      'Event not found';

  @override
  String get hostsHostEventAttendancePanelMessageThisEventIsNo =>
      'This event is no longer available.';

  @override
  String get hostsHostEventAttendancePanelTitleParticipation => 'Participation';

  @override
  String get hostsHostEventAttendancePanelSubtitleReviewProfilesAndApprove =>
      'Review profiles and approve requests before launch.';

  @override
  String get hostsHostEventAttendancePanelSubtitleReviewBookingStatusBefore =>
      'Review booking status before launch.';

  @override
  String get hostsHostEventAttendancePanelLabelSearchPeople => 'Search people';

  @override
  String get hostsHostEventAttendancePanelTitleCheckInBoard => 'Check-in board';

  @override
  String get hostsHostEventAttendancePanelSubtitleUseTheStatusTiles =>
      'Use the status tiles to focus the roster as people arrive.';

  @override
  String get hostsHostEventAttendancePanelTitleCheckInQr => 'Check-in QR';

  @override
  String get hostsHostEventAttendancePanelBodyCheckInQr =>
      'Show this code to attendees as they arrive.';

  @override
  String get hostsHostEventAttendancePanelLabelSearchRoster => 'Search roster';

  @override
  String get hostsHostEventAttendancePanelTitleEventReport => 'Event report';

  @override
  String get hostsHostEventAttendancePanelSubtitleAttendancePayoutAndExport =>
      'Attendance, payout, and export-ready roster history.';

  @override
  String get hostsHostEventAttendancePanelLabelOpsCsv => 'Ops CSV';

  @override
  String get hostsHostEventAttendancePanelLabelRevenueCsv => 'Revenue CSV';

  @override
  String get hostsHostEventAttendancePanelLabelExport => 'Export report';

  @override
  String get hostsHostEventAttendancePanelTextWaitlistMovement =>
      'Waitlist movement';

  @override
  String get hostsHostEventToolsLabelHostEventToolsCarousel =>
      'Host event tools carousel';

  @override
  String get hostsHostTeamManagementSectionTitleHostTeam => 'Host team';

  @override
  String get hostsHostTeamManagementSectionTextNoHostTeamMembers =>
      'No host team members yet.';

  @override
  String get hostsHostTeamManagementSectionTooltipHostActions => 'Host actions';

  @override
  String get hostsHostTeamManagementSectionLabelTransferOwnership =>
      'Transfer ownership';

  @override
  String get hostsHostTeamManagementSectionLabelRemoveHost => 'Remove host';

  @override
  String get hostsHostTeamManagementSectionTitleAddHost => 'Add host';

  @override
  String get hostsHostTeamManagementSectionSubtitleEnterThePhoneNumber =>
      'Enter the phone number on their Catch profile.';

  @override
  String get hostsHostTeamManagementSectionLabelAddHost => 'Add host';

  @override
  String get hostsHostTeamManagementSectionTitlePhoneNumber => 'Phone number';

  @override
  String get hostsStepperFooterLabelNext => 'Next';

  @override
  String get hostsStepperFooterLabelSaveDraft => 'Save Draft';

  @override
  String get imageUploadsProfilePhotoEditorScreenTitleDeletePhoto =>
      'Delete photo?';

  @override
  String get imageUploadsProfilePhotoEditorScreenMessageThisRemovesThePhoto =>
      'This removes the photo from your profile.';

  @override
  String get imageUploadsProfilePhotoEditorScreenTitleAddPhoto => 'Add photo';

  @override
  String get imageUploadsProfilePhotoEditorScreenTitleEditPhoto => 'Edit photo';

  @override
  String get imageUploadsProfilePhotoEditorScreenTitlePhotoPrompt =>
      'Photo prompt';

  @override
  String get imageUploadsProfilePhotoEditorScreenLabelSaving => 'Saving';

  @override
  String get imageUploadsProfilePhotoEditorScreenLabelSaveChanges =>
      'Save changes';

  @override
  String get imageUploadsProfilePhotoEditorScreenLabelChoosePhoto =>
      'Choose photo';

  @override
  String get imageUploadsProfilePhotoEditorScreenLabelChangePhoto =>
      'Change photo';

  @override
  String get imageUploadsProfilePhotoEditorScreenLabelDeleting => 'Deleting';

  @override
  String get imageUploadsProfilePhotoEditorScreenLabelDeletePhoto =>
      'Delete photo';

  @override
  String
  get imageUploadsProfilePhotoEditorScreenCatchbuttonDeletePhotoUnavailable =>
      'Delete photo unavailable';

  @override
  String get launchAccessLaunchAccessApplicationScreenTitleAccessGateIsOff =>
      'Access gate is off';

  @override
  String
  get launchAccessLaunchAccessApplicationScreenMessageRemoteConfigHasNot =>
      'Remote Config has not enabled launch access for this build.';

  @override
  String get launchAccessLaunchAccessApplicationScreenTitleVerifyYourPhone =>
      'Verify your phone';

  @override
  String
  get launchAccessLaunchAccessApplicationScreenMessagePhoneVerificationIsRequired =>
      'Phone verification is required before applying for access.';

  @override
  String
  get launchAccessLaunchAccessApplicationScreenMessageAccessIsApprovedProfile =>
      'Access is approved. Profile creation can be unlocked once the router uses this gate.';

  @override
  String
  get launchAccessLaunchAccessApplicationScreenMessageYourApplicationIsSaved =>
      'Your application is saved for the next launch cohort.';

  @override
  String get launchAccessLaunchAccessApplicationScreenTextJoinTheNextCity =>
      'Join the next city drop';

  @override
  String get launchAccessLaunchAccessApplicationScreenTextTellUsWhereYou =>
      'Tell us where you fit so we can open access around real events.';

  @override
  String get launchAccessLaunchAccessApplicationScreenTitleCity => 'City';

  @override
  String get launchAccessLaunchAccessApplicationScreenHinttextSelectCity =>
      'Select city';

  @override
  String get launchAccessLaunchAccessApplicationScreenLabelJoiningAs =>
      'Joining as';

  @override
  String get launchAccessLaunchAccessApplicationScreenLabelEventsYouWouldShow =>
      'Events you would show up for';

  @override
  String get launchAccessLaunchAccessApplicationScreenLabelBestTimes =>
      'Best times';

  @override
  String get launchAccessLaunchAccessApplicationScreenTitleIMightHost =>
      'I might host';

  @override
  String get launchAccessLaunchAccessApplicationScreenBodyUsefulIfYouAlready =>
      'Useful if you already run a club, venue, or social format.';

  @override
  String get launchAccessLaunchAccessApplicationScreenTitleInviteCode =>
      'Invite code';

  @override
  String get launchAccessLaunchAccessApplicationScreenTitleInstagram =>
      'Instagram';

  @override
  String get launchAccessLaunchAccessApplicationScreenTitleWhoReferredYou =>
      'Who referred you?';

  @override
  String get launchAccessLaunchAccessApplicationScreenTitleWhyDoYouWant =>
      'Why do you want to join?';

  @override
  String get launchAccessLaunchAccessApplicationScreenLabelSubmitApplication =>
      'Submit application';

  @override
  String get launchAccessLaunchAccessApplicationScreenLabelUpdateApplication =>
      'Update application';

  @override
  String get matchesMatchCelebrationDialogEyebrowNewCatch => 'New catch';

  @override
  String get matchesMatchCelebrationDialogTitleItSACatch => 'It\'s a Catch.';

  @override
  String get matchesMatchCelebrationDialogLabelMatch => 'Match';

  @override
  String get matchesMatchCelebrationDialogNoteStartWithSomethingSpecific =>
      'Start with something specific from their profile or event history.';

  @override
  String get matchesMatchCelebrationDialogLabelSendAMessage => 'Send a message';

  @override
  String get matchesMatchCelebrationDialogLabelKeepCatching => 'Keep catching';

  @override
  String get onboardingGenderInterestPageLabelContinue => 'Continue';

  @override
  String get onboardingGenderInterestPageLabelIAmA => 'I AM A';

  @override
  String get onboardingGenderInterestPageLabelShowMe => 'SHOW ME';

  @override
  String get onboardingInstagramPageLabelContinue => 'Continue';

  @override
  String get onboardingInstagramPageLabelSkipForNow => 'Skip for now';

  @override
  String get onboardingInstagramPageTitleHandle => 'HANDLE';

  @override
  String get onboardingInstagramPagePlaceholderYourhandle => '@yourhandle';

  @override
  String get onboardingNameDobPageLabelContinue => 'Continue';

  @override
  String get onboardingNameDobPageTitleFirstName => 'FIRST NAME';

  @override
  String get onboardingNameDobPageHelpertextDisplayedOnYourProfile =>
      'Displayed on your profile.';

  @override
  String get onboardingNameDobPageTitleLastName => 'LAST NAME';

  @override
  String get onboardingNameDobPageHelpertextPrivateWeNeverShow =>
      'Private. We never show this on your public profile.';

  @override
  String get onboardingNameDobPageTitleDateOfBirth => 'DATE OF BIRTH';

  @override
  String get onboardingNameDobPageHelpertextWeNeverShowYour =>
      'We never show your birth year.';

  @override
  String get onboardingNameDobPageTitlePhone => 'PHONE';

  @override
  String get onboardingNameDobPageHelpertextVerifiedViaOtp =>
      'Verified via OTP.';

  @override
  String get onboardingPhotosPageLabelContinue => 'Continue';

  @override
  String get onboardingProfilePromptsPageLabelContinue => 'Continue';

  @override
  String get onboardingProfilePromptsPageTitleProfilePrompt => 'Profile prompt';

  @override
  String get onboardingProfilePromptsPageTitleAnswer => 'Answer';

  @override
  String get onboardingRunningPrefsPageTextTypicalPacePerKm =>
      'TYPICAL PACE · PER KM';

  @override
  String onboardingRunningPrefsPageBodyPaceRange({
    required String minPace,
    required String maxPace,
  }) {
    return '$minPace - $maxPace';
  }

  @override
  String get onboardingRunningPrefsPageText400Fast => '4:00 FAST';

  @override
  String get onboardingRunningPrefsPageText900Easy => '9:00 EASY';

  @override
  String get onboardingRunningPrefsPageLabelFavouriteDistances =>
      'FAVOURITE DISTANCES';

  @override
  String get paymentsPaymentConfirmationScreenTitlePaymentNotCompleted =>
      'Payment not completed';

  @override
  String get paymentsPaymentConfirmationScreenTitleCheckoutIsWaiting =>
      'Checkout is waiting';

  @override
  String get paymentsPaymentConfirmationScreenLabelFailed => 'Failed';

  @override
  String get paymentsPaymentConfirmationScreenLabelPending => 'Pending';

  @override
  String get paymentsPaymentConfirmationScreenLabelViewPaymentHistory =>
      'View payment history';

  @override
  String get paymentsPaymentConfirmationScreenLabelBackToEvent =>
      'Back to event';

  @override
  String get paymentsPaymentConfirmationScreenLabelAddToCalendar =>
      'Add to calendar';

  @override
  String get paymentsPaymentConfirmationScreenLabelGetDirections =>
      'Get directions';

  @override
  String get paymentsPaymentConfirmationScreenLabelInviteFriend =>
      'Invite friend';

  @override
  String get paymentsPaymentConfirmationScreenTextHeadsUp => 'HEADS UP';

  @override
  String get paymentsPaymentConfirmationScreenTextBringSomeoneYouActually =>
      'Bring someone you actually want there';

  @override
  String get paymentsPaymentConfirmationScreenTextTheBestInvitesHappen =>
      'The best invites happen while the plan still feels fresh.';

  @override
  String get paymentsPaymentConfirmationScreenTextShare => 'Share';

  @override
  String get paymentsPaymentHistoryScreenTitleSignInRequired =>
      'Sign in required';

  @override
  String get paymentsPaymentHistoryScreenMessageSignInAgainTo =>
      'Sign in again to view payment history.';

  @override
  String get paymentsPaymentHistoryScreenTitleNoPaymentsYet =>
      'No payments yet';

  @override
  String get paymentsPaymentHistoryScreenMessageEventBookingsAndRefunds =>
      'Event bookings and refunds will appear here.';

  @override
  String get paymentsPaymentHistoryScreenTitlePaymentId => 'Payment ID';

  @override
  String get paymentsPaymentHistoryScreenTitleOrderId => 'Order ID';

  @override
  String get paymentsPaymentHistoryScreenTitleEventId => 'Event ID';

  @override
  String get paymentsPaymentHistoryScreenTitleDate => 'Date';

  @override
  String get paymentsPaymentHistoryScreenTitleStatus => 'Status';

  @override
  String get paymentsPaymentHistoryScreenLabelGetHelpWithThis =>
      'Get help with this booking';

  @override
  String get publicProfilePublicProfileScreenTooltipProfileActions =>
      'Profile actions';

  @override
  String get publicProfilePublicProfileScreenLabelReport => 'Report';

  @override
  String get publicProfilePublicProfileScreenLabelBlock => 'Block';

  @override
  String get publicProfilePublicProfileScreenTitleProfileUnavailable =>
      'Profile unavailable';

  @override
  String get publicProfilePublicProfileScreenMessageThisProfileIsNo =>
      'This profile is no longer available on Catch.';

  @override
  String get publicProfilePublicProfileScreenLabelHarassmentOrAbuse =>
      'Harassment or abuse';

  @override
  String get publicProfilePublicProfileScreenLabelFakeOrMisleadingProfile =>
      'Fake or misleading profile';

  @override
  String get publicProfilePublicProfileScreenLabelInappropriateContent =>
      'Inappropriate content';

  @override
  String get publicProfilePublicProfileScreenLabelOtherSafetyConcern =>
      'Other safety concern';

  @override
  String get reviewsReviewsSectionLabelEditYourReview => 'Edit your review';

  @override
  String get reviewsReviewsSectionLabelWriteAReview => 'Write a review';

  @override
  String get reviewsReviewsSectionMessageBeTheFirstToReviewThisEvent =>
      'Be the first to review this event.';

  @override
  String get reviewsReviewsSectionTextReviews => 'Reviews';

  @override
  String get reviewsReviewsSectionTitleNoReviewsYet => 'No reviews yet';

  @override
  String get reviewsReviewsSectionMessageReviewsAppearAfterMembers =>
      'Reviews appear after members attend an event.';

  @override
  String get reviewsReviewsSectionMessageReviewsFromAttendeesWill =>
      'Reviews from attendees will appear here after an event.';

  @override
  String get reviewsReviewsSectionTextYou => 'You';

  @override
  String get reviewsReviewsSectionMessageEditReview => 'Edit review';

  @override
  String get reviewsReviewsSectionMessageRespondAsHost => 'Respond as host';

  @override
  String get reviewsReviewsSectionMessageEditHostResponse =>
      'Edit host response';

  @override
  String get reviewsReviewsSectionTitleRespondToReview => 'Respond to review';

  @override
  String get reviewsReviewsSectionTitleEditResponse => 'Edit response';

  @override
  String get reviewsReviewsSectionLabelSaveResponse => 'Save response';

  @override
  String get reviewsReviewsSectionTitleResponse => 'Response';

  @override
  String get reviewsReviewsSectionPlaceholderThankTheAttendeeOr =>
      'Thank the attendee or clarify what happened';

  @override
  String get reviewsStarRatingMessageS => 's';

  @override
  String get reviewsStarRatingLabelS => 's';

  @override
  String get reviewsWriteReviewSheetTitleDeleteReview => 'Delete review?';

  @override
  String get reviewsWriteReviewSheetMessageThisRemovesYourReview =>
      'This removes your review from this event.';

  @override
  String get reviewsWriteReviewSheetTitleEditReview => 'Edit review';

  @override
  String get reviewsWriteReviewSheetTitleWriteAReview => 'Write a review';

  @override
  String get reviewsWriteReviewSheetLabelDeleteReview => 'Delete review';

  @override
  String get reviewsWriteReviewSheetLabelSave => 'Save';

  @override
  String get reviewsWriteReviewSheetLabelSubmit => 'Submit';

  @override
  String get reviewsWriteReviewSheetTitleReview => 'Review';

  @override
  String get reviewsWriteReviewSheetPlaceholderShareYourExperience =>
      'Share your experience';

  @override
  String get safetySettingsScreenTitleDeleteAccount => 'Delete account?';

  @override
  String get safetySettingsScreenTitleAccount => 'Account';

  @override
  String get safetySettingsScreenTitlePhoneNumber => 'Phone number';

  @override
  String get safetySettingsScreenTitleEmail => 'Email';

  @override
  String get safetySettingsScreenTitleEditProfile => 'Edit profile';

  @override
  String get safetySettingsScreenTitleReviewHistory => 'Review history';

  @override
  String get safetySettingsScreenBodyEventsYouReviewed => 'Events you reviewed';

  @override
  String get safetySettingsScreenTitlePaymentHistory => 'Payment history';

  @override
  String get safetySettingsScreenBodyBookingsAndReceipts =>
      'Bookings and receipts';

  @override
  String get safetySettingsScreenTitleCatchHost => 'Catch Host';

  @override
  String get safetySettingsScreenBodyManageEventsAndClubs =>
      'Manage events and organizers';

  @override
  String get safetySettingsScreenTitleDevelopment => 'Development';

  @override
  String get safetySettingsScreenTitleEventPolicyLab => 'Event policy lab';

  @override
  String get safetySettingsScreenBodyStaticBookingPolicyPreviews =>
      'Static booking policy previews';

  @override
  String get safetySettingsScreenTitleEventSuccessLab => 'Event success lab';

  @override
  String get safetySettingsScreenBodyHostAttendeeAndReport =>
      'Host, attendee, and report previews';

  @override
  String get safetySettingsScreenTitleEventSuccessManualQa =>
      'Event success manual QA';

  @override
  String get safetySettingsScreenBodyHostAndAttendeeSide =>
      'Host and attendee side by side';

  @override
  String get safetySettingsScreenTitleNotifications => 'Notifications';

  @override
  String get safetySettingsScreenTitlePushNotifications => 'Push notifications';

  @override
  String get safetySettingsScreenTitleMessages => 'Messages';

  @override
  String get safetySettingsScreenTitleEventReminders => 'Event reminders';

  @override
  String get safetySettingsScreenTitleEventChangesAndCancellations =>
      'Event changes and cancellations';

  @override
  String get safetySettingsScreenTitleClubAnnouncements =>
      'Organizer announcements';

  @override
  String get safetySettingsScreenTitleEmailUpdates => 'Email updates';

  @override
  String get safetySettingsScreenTitlePrivacySafety => 'Privacy & safety';

  @override
  String get safetySettingsScreenTitleBlockedUsers => 'Blocked users';

  @override
  String get safetySettingsScreenTitleWhoCanSeeYou => 'Who can see you';

  @override
  String get safetySettingsScreenBodyRunnersOnMyEvents =>
      'Runners on my events';

  @override
  String get safetySettingsScreenTitleShowMeOnMap => 'Show me on map';

  @override
  String get safetySettingsScreenTitlePrivacyPolicy => 'Privacy policy';

  @override
  String get safetySettingsScreenBodyHttpsCatchdatesComPrivacy =>
      'https://catchdates.com/privacy';

  @override
  String get safetySettingsScreenTitleDeleteAccount658588 => 'Delete account';

  @override
  String get safetySettingsScreenTitleAbout => 'About';

  @override
  String get safetySettingsScreenTitleHelpSupport => 'Help & support';

  @override
  String get safetySettingsScreenBodyContactUs => 'Contact us';

  @override
  String get safetySettingsScreenBodyHttpsCatchdatesComHelp =>
      'https://catchdates.com/help';

  @override
  String get safetySettingsScreenTitleTerms => 'Terms';

  @override
  String get safetySettingsScreenBodyLegal => 'Legal';

  @override
  String get safetySettingsScreenBodyHttpsCatchdatesComTerms =>
      'https://catchdates.com/terms';

  @override
  String get safetySettingsScreenTitleVersion => 'Version';

  @override
  String get safetySettingsScreenTitleLogOut => 'Log out';

  @override
  String get safetySettingsScreenTextCatch10Made =>
      'Catch 1.0 · made in Bombay';

  @override
  String get safetySettingsScreenTitleNoBlockedAccounts =>
      'No blocked accounts';

  @override
  String get safetySettingsScreenMessagePeopleYouBlockWill =>
      'People you block will appear here.';

  @override
  String get safetySettingsScreenLabelUnblock => 'Unblock';

  @override
  String get swipesEventRecapScreenTitleEventRecap => 'Event recap';

  @override
  String get swipesEventRecapScreenTooltipCloseRecap => 'Close recap';

  @override
  String get swipesEventRecapScreenTextWhoBroughtTheVibe =>
      'Who brought the vibe?';

  @override
  String get swipesEventRecapScreenTextTapPeopleYouRemember =>
      'Tap people you remember. They\'ll be easier to spot when you open the catches deck.';

  @override
  String get swipesEventRecapScreenTitleNoAttendeesToTag =>
      'No attendees to tag';

  @override
  String get swipesEventRecapScreenMessageNoOtherCheckedIn =>
      'No other checked-in attendees are attached to this event yet.';

  @override
  String get swipesEventRecapScreenLabelOpenCatchesDeck => 'Open catches deck';

  @override
  String get swipesEventRecapScreenLabelWhen => 'When';

  @override
  String get swipesEventRecapScreenLabelTime => 'Time';

  @override
  String get swipesEventRecapScreenLabelCatches => 'Catches';

  @override
  String get swipesFiltersScreenTitleFilters => 'Filters';

  @override
  String get swipesFiltersScreenTooltipCloseFilters => 'Close filters';

  @override
  String get swipesFiltersScreenLabelReset => 'Reset';

  @override
  String get swipesFiltersScreenTitleAge => 'Age';

  @override
  String get swipesFiltersScreenTitleInterestedIn => 'Interested in';

  @override
  String get swipesFiltersScreenLabelApplyFilters => 'Apply filters';

  @override
  String get swipesSwipeHubScreenTitleOpenCatchWindows => 'Open catch windows';

  @override
  String get swipesSwipeHubScreenTextAfterTheEvent => 'After the event';

  @override
  String get swipesSwipeHubScreenLabelStartCatching => 'Start catching';

  @override
  String get swipesSwipeHubScreenText24hWindowOpen => '24H WINDOW OPEN';

  @override
  String get swipesSwipeHubScreenTextYouRanTogetherNow =>
      'You ran together. Now you can catch.';

  @override
  String get swipesSwipeHubScreenLabelClosesIn => 'Closes in';

  @override
  String get swipesSwipeHubScreenLabelRoster => 'Roster';

  @override
  String get swipesSwipeHubScreenTitleNoActiveCatches => 'No active catches';

  @override
  String get swipesSwipeHubScreenMessageBookAGroupEvent =>
      'Book a group event, show up, and your 24-hour catch window opens here after check-in.';

  @override
  String get swipesSwipeHubScreenLabelFindAnEvent => 'Find an event';

  @override
  String get swipesSwipeHubScreenTextDatingStaysLockedUntil =>
      'Dating stays locked until you actually run together. No cold stranger browsing.';

  @override
  String get swipesSwipeScreenTooltipBackToCatches => 'Back to Catches';

  @override
  String get swipesSwipeScreenTooltipFilters => 'Filters';

  @override
  String get swipesAttendedEventTileTextOpenCatchWindow => 'OPEN CATCH WINDOW';

  @override
  String get swipesAttendedEventTileLabelRecap => 'Recap';

  @override
  String get swipesCatchesPassButtonMessagePassing => 'Passing';

  @override
  String get swipesCatchesPassButtonMessagePass => 'Pass';

  @override
  String get swipesCatchesPassButtonLabelPassingProfile => 'Passing profile';

  @override
  String get swipesCatchesPassButtonLabelPassProfile => 'Pass profile';

  @override
  String get swipesCatchProfileViewLabelPace => 'PACE';

  @override
  String get swipesCatchProfileViewLabelDistance => 'DISTANCE';

  @override
  String get swipesProfileReactionControlsSubtitleSendACommentWith =>
      'Send a comment with your like.';

  @override
  String get swipesProfileReactionControlsLabelCancel => 'Cancel';

  @override
  String get swipesProfileReactionControlsLabelSendLike => 'Send like';

  @override
  String get swipesProfileReactionControlsTitleComment => 'Comment';

  @override
  String get swipesProfileReactionControlsPlaceholderWriteSomethingSpecific =>
      'Write something specific...';

  @override
  String get userProfileProfileScreenLabelProfileTabs => 'Profile tabs';

  @override
  String get userProfileProfileScreenBodyDragLeftOrRight =>
      'Drag left or right to switch between Edit, Preview, and Insights.';

  @override
  String get userProfileProfileScreenTitleProfileNotAvailable =>
      'Profile not available';

  @override
  String get userProfileProfileScreenMessageFinishOnboardingOrSign =>
      'Finish onboarding or sign in again to load your profile.';

  @override
  String get userProfileInlineEditorHeightTooltipDecreaseHeight =>
      'Decrease height';

  @override
  String get userProfileInlineEditorHeightTooltipIncreaseHeight =>
      'Increase height';

  @override
  String get userProfileProfileSliverHeaderTooltipSettings => 'Settings';

  @override
  String get userProfileProfileTabTitlePrompts => 'Prompts';

  @override
  String get userProfileProfileTabTitleAboutYou => 'About you';

  @override
  String get userProfileProfileTabTitleRunning => 'Running';

  @override
  String get userProfileProfileTabTitleLifestyle => 'Lifestyle';

  @override
  String get userProfileProfileTabTitlePhotos => 'Photos';

  @override
  String get userProfileProfileTabSkeletonTitlePhotos => 'Photos';

  @override
  String get chatsChatInboxScreenLabelSendBroadcast => 'Send broadcast';

  @override
  String get clubsClubDetailSkeletonTitleAbout => 'About';

  @override
  String get clubsClubDetailSkeletonTitleWhatWeDo => 'What we do';

  @override
  String get clubsClubDetailSkeletonTitleYourHosts => 'Your hosts';

  @override
  String get clubsClubDetailSkeletonTitleSchedule => 'Schedule';

  @override
  String get clubsClubHeroAppBarTitleClubDetailCollapsedTitle =>
      'club-detail-collapsed-title';

  @override
  String get clubsClubHeroAppBarTextClubDetailExpandedTitle =>
      'club-detail-expanded-title';

  @override
  String get clubsClubScheduleSectionTitleSchedule => 'Schedule';

  @override
  String get clubsClubShareCardTextClubOnCatch => 'ORGANIZER ON CATCH';

  @override
  String get dashboardDashboardEmptyTitleHowCatchWorks => 'How Catch works';

  @override
  String get dashboardEventFocusRailLabelReviewPending => 'Review pending';

  @override
  String get eventPoliciesEventPolicyLabScreenTitleEventPolicyLab =>
      'Event policy lab';

  @override
  String
  get eventSuccessEventSuccessEventPreviewBodyScreenTitleEventSuccessPreview =>
      'Event success preview';

  @override
  String
  get eventSuccessEventSuccessEventPreviewLoadingScreenTitleEventSuccessPreview =>
      'Event success preview';

  @override
  String get eventSuccessEventSuccessEventPreviewScreenTitleEventNotFound =>
      'Event not found';

  @override
  String get eventSuccessEventSuccessEventPreviewScreenMessageThisEventIsNo =>
      'This event is no longer available for preview.';

  @override
  String get eventSuccessEventSuccessFeatureBlocksLabelHostOnly => 'Host only';

  @override
  String get eventSuccessEventSuccessFeatureBlocksLabelAttendee => 'Attendee';

  @override
  String get eventSuccessEventSuccessLabScreenTitleEventSuccessLab =>
      'Event success lab';

  @override
  String get eventSuccessEventSuccessLabScreenLabelDevStagingRoute =>
      'Dev/staging route';

  @override
  String get eventSuccessEventSuccessLabScreenLabelNoFirestoreWrites =>
      'No Firestore writes';

  @override
  String get eventSuccessEventSuccessLabScreenLabelNoBookingChanges =>
      'No booking changes';

  @override
  String get eventSuccessEventSuccessLabScreenLabelSomeLivePhoneUse =>
      'some live phone use';

  @override
  String get eventSuccessEventSuccessLabScreenLabelLivePhone => 'live phone';

  @override
  String get eventSuccessEventSuccessLabScreenLabelLaterExperiment =>
      'later experiment';

  @override
  String get eventSuccessEventSuccessManualQaScreenTitleEventSuccessManualQa =>
      'Event success manual QA';

  @override
  String get eventSuccessEventSuccessSetupBodyLabelNoTimer => 'No timer';

  @override
  String get eventSuccessEventSuccessSetupBodyLabel10Min => '10 min';

  @override
  String get eventSuccessEventSuccessSetupBodyLabel15Min => '15 min';

  @override
  String get eventSuccessEventSuccessSetupBodyLabel20Min => '20 min';

  @override
  String get eventSuccessEventSuccessSetupBodyLabel30Min => '30 min';

  @override
  String get eventSuccessEventSuccessSetupBodyLabel5s => '5s';

  @override
  String get eventSuccessEventSuccessSetupBodyLabel10s => '10s';

  @override
  String get eventSuccessEventSuccessSetupBodyLabel15s => '15s';

  @override
  String get eventsEventDetailScreenTitleEventNotFound => 'Event not found';

  @override
  String get eventsEventDetailScreenMessageThisEventIsNo =>
      'This event is no longer available.';

  @override
  String get eventsEventLocationMapScreenTitleEventNotFound =>
      'Event not found';

  @override
  String get eventsEventLocationMapScreenMessageThisEventIsNo =>
      'This event is no longer available.';

  @override
  String get eventsSavedEventsScreenTitleSavedEvents => 'Saved events';

  @override
  String get eventsEventDetailHeroAppBarTitleEventDetailCollapsedTitle =>
      'event-detail-collapsed-title';

  @override
  String get exploreExploreMapScreenBodyNoSelectedMapEvent =>
      'no-selected-map-event';

  @override
  String get exploreExploreScreenBodyExploreListScrollView =>
      'explore-list-scroll-view';

  @override
  String get hostsClubHostDefaultsStepLabelAdmissionFormat =>
      'Admission format';

  @override
  String get hostsClubHostDefaultsStepLabelCancellationPolicy =>
      'Cancellation policy';

  @override
  String get hostsCreateClubContactFieldsLabelContact => 'Contact';

  @override
  String get hostsCreateClubPhotosPickerLabelClubPhotos => 'Organizer photos';

  @override
  String get hostsCreateClubPhotosPickerLabelClubProfileImage =>
      'Organizer profile image';

  @override
  String get hostsEditHostedEventScreenTitleEditEvent => 'Edit event';

  @override
  String get hostsEditHostedEventScreenLabelSchedule => 'Schedule';

  @override
  String get hostsEditHostedEventScreenLabelDuration => 'Duration';

  @override
  String get hostsEditHostedEventScreenLabelWhere => 'Where';

  @override
  String get hostsEditHostedEventScreenLabelEventDetails => 'Event details';

  @override
  String get hostsEditHostedEventScreenLabelEventPolicy => 'Event policy';

  @override
  String get hostsEditHostedEventScreenLabelLocked => 'Locked';

  @override
  String get hostsEditHostedEventScreenLabelAdmissionFormat =>
      'Admission format';

  @override
  String get hostsEditHostedEventScreenLabelCancellationPolicy =>
      'Cancellation policy';

  @override
  String get hostsHostCreateEventScreenTitleEventSetupUnavailable =>
      'Event setup unavailable';

  @override
  String get hostsHostCreateEventScreenMessageThatOrganizerDoesNot =>
      'That organizer does not match this event route.';

  @override
  String get hostsHostCreateEventScreenTitleRepeatUnavailable =>
      'Repeat unavailable';

  @override
  String get hostsHostCreateEventScreenMessageThatEventBelongsTo =>
      'That event belongs to a different organizer.';

  @override
  String get hostsHostCreateEventScreenTitleClubNotFound =>
      'Organizer not found';

  @override
  String get hostsHostCreateEventScreenMessageThisClubIsNo =>
      'This organizer is no longer available.';

  @override
  String get hostsHostCreateEventScreenTitleHostAccessRequired =>
      'Host access required';

  @override
  String get hostsHostCreateEventScreenMessageOnlyThisClubS =>
      'Only this organizer\'s host team can create events for this organizer.';

  @override
  String get hostsCreateEventPhotoPickerLabelEventPhotos => 'Event photos';

  @override
  String get hostsEventDetailsStepLabelActivityType => 'Activity type';

  @override
  String get hostsEventDetailsStepLabelFormatStructure => 'Format structure';

  @override
  String get hostsEventDetailsStepLabelPaceLevel => 'Pace level';

  @override
  String get hostsEventPolicyStepLabelAdmissionFormat => 'Admission format';

  @override
  String get hostsEventPolicyStepLabelCancellationPolicy =>
      'Cancellation policy';

  @override
  String get hostsWhenStepLabelDate => 'Date';

  @override
  String get hostsWhenStepLabelStartTime => 'Start time';

  @override
  String get hostsWhenStepLabelDuration => 'Duration';

  @override
  String get hostsWhereStepLabelMeetingLocation => 'Meeting location';

  @override
  String get hostsHostEventManageScreenBodyHostEventManageScroll =>
      'host_event_manage_scroll_view';

  @override
  String get hostsHostEventManageScreenLabelKeepEvent => 'Keep event';

  @override
  String get hostsHostEventManageScreenLabelKeepActive => 'Keep active';

  @override
  String get hostsHostEventManageScreenLabelDisable => 'Disable';

  @override
  String get hostsHostEventManageScreenLabelInvite => 'Invite';

  @override
  String get hostsHostEventManageScreenLabelDisabled => 'Disabled';

  @override
  String get hostsHostEventManageScreenLabelEventCancelled => 'Event cancelled';

  @override
  String get hostsHostEventManageScreenDetailRecordsAreRetained =>
      'Records are retained';

  @override
  String get hostsHostInboxScreenTitleNoGeneralInquiries =>
      'No general inquiries';

  @override
  String get hostsHostInboxScreenMessageQuestionsThatAreNot =>
      'Questions that are not tied to one event will appear here.';

  @override
  String get hostsHostPaymentAccountCardTitlePayouts => 'Payouts';

  @override
  String get hostsHostClubToolsLabelHostTools => 'Host tools';

  @override
  String get hostsHostClubToolsLabelClub => 'Organizer';

  @override
  String get hostsHostEventToolsLabelHostEvent => 'Host event';

  @override
  String chatsChatsListBodyTitleNoAudiencelabelSYet({
    required Object audienceLabel,
  }) {
    return 'No ${audienceLabel}s yet';
  }

  @override
  String chatsChatsListBodyTitleMessageCountlabel({
    required Object countLabel,
  }) {
    return 'Message $countLabel';
  }

  @override
  String chatsChatEventContextHeaderTextTitleDate({
    required Object title,
    required Object date,
  }) {
    return '$title · $date';
  }

  @override
  String clubsClubDetailDockTextMembers({required Object members}) {
    return '$members';
  }

  @override
  String clubsClubHeroAppBarSemanticlabelNameCoverPhoto({
    required Object name,
  }) {
    return '$name cover photo';
  }

  @override
  String clubsClubHostSectionLabelViewDisplaynameProfile({
    required Object displayName,
  }) {
    return 'View $displayName profile';
  }

  @override
  String clubsClubPhotoStripTextLengthPhotos({required Object length}) {
    return '$length PHOTOS';
  }

  @override
  String clubsClubShareCardLabelAreaCitylabel({
    required Object area,
    required Object cityLabel,
  }) {
    return '$area, $cityLabel';
  }

  @override
  String clubsClubShareCardSemanticlabelNameCoverPhoto({required Object name}) {
    return '$name cover photo';
  }

  @override
  String dashboardActivitySectionLabelTitleBody({
    required Object title,
    required Object body,
  }) {
    return '$title. $body';
  }

  @override
  String dashboardEventFocusRailSemanticlabelEventValue1OfLength({
    required Object value1,
    required Object length,
  }) {
    return 'Event $value1 of $length';
  }

  @override
  String dashboardEventFocusRailLabelCatchSwipecountdown({
    required Object swipeCountdown,
  }) {
    return 'Catch · $swipeCountdown';
  }

  @override
  String dashboardEventFocusRailLabelSignedupcountCapacitylimit({
    required Object signedUpCount,
    required Object capacityLimit,
  }) {
    return '$signedUpCount/$capacityLimit';
  }

  @override
  String eventPoliciesEventPolicyLabScreenTextLengthFixtures({
    required Object length,
  }) {
    return '$length fixtures';
  }

  @override
  String eventPoliciesEventPolicyLabScreenTextLengthProbes({
    required Object length,
  }) {
    return '$length probes';
  }

  @override
  String
  eventPoliciesEventPolicyLabScreenTextBaseFormatpaiseCohortFormatsignedpaise({
    required Object formatPaise,
    required Object formatSignedPaise,
    required Object formatSignedPaise2,
  }) {
    return 'Base $formatPaise · cohort $formatSignedPaise · demand $formatSignedPaise2';
  }

  @override
  String
  eventPoliciesEventPolicyLabScreenTextFormatcancellationactorBeforestarthoursHBefore({
    required Object formatCancellationActor,
    required Object beforeStartHours,
  }) {
    return '$formatCancellationActor · ${beforeStartHours}h before start';
  }

  @override
  String eventPoliciesEventPolicyLabScreenLabelRefundFormatpaise({
    required Object formatPaise,
  }) {
    return 'Refund $formatPaise';
  }

  @override
  String eventPoliciesEventPolicyLabScreenLabelCreditFormatpaise({
    required Object formatPaise,
  }) {
    return 'Credit $formatPaise';
  }

  @override
  String eventSuccessEventSuccessEventPreviewBodyScreenTextClubnameTitle({
    required Object clubName,
    required Object title,
  }) {
    return '$clubName · $title';
  }

  @override
  String
  eventSuccessEventSuccessEventPreviewBodyScreenLabelCapacitylimitTarget({
    required Object capacityLimit,
  }) {
    return '$capacityLimit target';
  }

  @override
  String eventSuccessEventSuccessEventPreviewBodyScreenLabelBookedcountBooked({
    required Object bookedCount,
  }) {
    return '$bookedCount booked';
  }

  @override
  String
  eventSuccessEventSuccessEventPreviewBodyScreenLabelCheckedincountCheckedIn({
    required Object checkedInCount,
  }) {
    return '$checkedInCount checked in';
  }

  @override
  String eventSuccessEventSuccessFeatureBlocksDetailCheckedincountBookedcount({
    required Object checkedInCount,
    required Object bookedCount,
  }) {
    return '$checkedInCount/$bookedCount';
  }

  @override
  String eventSuccessEventSuccessFeatureBlocksDetailValue1Length({
    required Object value1,
    required Object length,
  }) {
    return '$value1/$length';
  }

  @override
  String
  eventSuccessEventSuccessFeatureBlocksTextAttendeeExperienceAttendeeexperience({
    required Object attendeeExperience,
  }) {
    return 'Attendee experience: $attendeeExperience';
  }

  @override
  String eventSuccessEventSuccessFeatureBlocksLabelRound({
    required Object round,
  }) {
    return '$round%';
  }

  @override
  String
  eventSuccessEventSuccessFeatureBlocksLabelTargetattendeecountTargetAttendees({
    required Object targetAttendeeCount,
  }) {
    return '$targetAttendeeCount target attendees';
  }

  @override
  String eventSuccessEventSuccessFeatureBlocksLabelLengthLivePhoneTools({
    required Object length,
  }) {
    return '$length live phone tools';
  }

  @override
  String eventSuccessEventSuccessFeatureBlocksLabelTitleTool({
    required Object title,
  }) {
    return '$title tool';
  }

  @override
  String eventSuccessEventSuccessFeatureBlocksTextDurationminutesMinLabel({
    required Object durationMinutes,
    required Object label,
  }) {
    return '$durationMinutes min · $label';
  }

  @override
  String eventSuccessEventSuccessFeatureBlocksTextLabelRound({
    required Object label,
    required Object round,
  }) {
    return '$label $round%';
  }

  @override
  String eventSuccessEventSuccessLabScreenLabelPlaybookcountPlaybooks({
    required Object playbookCount,
  }) {
    return '$playbookCount playbooks';
  }

  @override
  String eventSuccessEventSuccessLabScreenLabelValue1More({
    required Object value1,
  }) {
    return '+$value1 more';
  }

  @override
  String eventSuccessEventSuccessLabScreenTextMinMaxAttendees({
    required Object min,
    required Object max,
  }) {
    return '$min-$max attendees';
  }

  @override
  String eventSuccessEventSuccessLabScreenTextDurationminutes({
    required Object durationMinutes,
  }) {
    return '$durationMinutes';
  }

  @override
  String eventSuccessEventSuccessLabScreenLabelRound({required Object round}) {
    return '$round%';
  }

  @override
  String eventSuccessEventSuccessManualQaScreenTextManualQaFixtureFailed({
    required Object error,
  }) {
    return 'Manual QA fixture failed to load: $error';
  }

  @override
  String eventSuccessEventSuccessManualQaScreenTextTitleLabelLabel2({
    required Object title,
    required Object label,
    required Object label2,
  }) {
    return '$title · $label · $label2';
  }

  @override
  String eventSuccessEventSuccessManualQaScreenLabelBookedcountBooked({
    required Object bookedCount,
  }) {
    return '$bookedCount booked';
  }

  @override
  String eventSuccessEventSuccessManualQaScreenLabelCheckedincountCheckedIn({
    required Object checkedInCount,
  }) {
    return '$checkedInCount checked in';
  }

  @override
  String
  eventSuccessEventSuccessManualQaScreenLabelRevealcountdownsecondsSReveal({
    required Object revealCountdownSeconds,
  }) {
    return '${revealCountdownSeconds}s reveal';
  }

  @override
  String eventSuccessEventSuccessManualQaScreenLabelTitleRanking({
    required Object title,
  }) {
    return '$title · ranking';
  }

  @override
  String eventSuccessEventSuccessManualQaScreenLabelTitleClues({
    required Object title,
  }) {
    return '$title · clues';
  }

  @override
  String
  eventSuccessEventSuccessManualQaScreenSubtitleProductionHostWorkspaceActivesteplabel({
    required Object activeStepLabel,
  }) {
    return 'Production host workspace · $activeStepLabel';
  }

  @override
  String
  eventSuccessEventSuccessManualQaScreenSubtitlePublicdisplaynameNameActivesteplabel({
    required Object publicDisplayName,
    required Object name,
    required Object activeStepLabel,
  }) {
    return '$publicDisplayName · $name · $activeStepLabel';
  }

  @override
  String eventSuccessEventSuccessQuestionnaireConfigEditorLabelLengthQuestions({
    required Object length,
  }) {
    return '$length questions';
  }

  @override
  String eventSuccessEventSuccessQuestionnaireConfigEditorTextQuestionValue1({
    required Object value1,
  }) {
    return 'Question $value1';
  }

  @override
  String eventSuccessEventSuccessQuestionnaireConfigEditorTitleOptionValue1({
    required Object value1,
  }) {
    return 'Option $value1';
  }

  @override
  String eventSuccessEventSuccessSetupBodyTextAttendeesWillSeeText({
    required Object text,
  }) {
    return 'Attendees will see: \"$text\"';
  }

  @override
  String eventSuccessEventSuccessStructureConfigEditorDetailTargetSizeForEach({
    required Object singularLabel,
  }) {
    return 'Target size for each $singularLabel.';
  }

  @override
  String
  eventSuccessEventSuccessStructureConfigEditorTextAutoAboutEstimatedunitcountTolowercase({
    required Object estimatedUnitCount,
    required Object toLowerCase,
    required Object targetAttendeeCount,
  }) {
    return 'Auto: about $estimatedUnitCount $toLowerCase from $targetAttendeeCount target attendees.';
  }

  @override
  String eventsEventDetailDesignPrimitivesTextLengthUploaded({
    required Object length,
  }) {
    return '$length UPLOADED';
  }

  @override
  String eventsEventDetailOverviewSectionTitleTitleCancellation({
    required Object title,
  }) {
    return '$title cancellation';
  }

  @override
  String eventsEventPinsMapLabelLocationnameLocation({
    required Object locationName,
  }) {
    return '$locationName location';
  }

  @override
  String eventsEventPinsMapLabelSelectLocationname({
    required Object locationName,
  }) {
    return 'Select $locationName';
  }

  @override
  String eventsWhoIsGoingTextTotalCapacitylimit({
    required Object total,
    required Object capacityLimit,
  }) {
    return '$total/$capacityLimit';
  }

  @override
  String exploreExploreScreenTitleNoClubsInCitylabel({
    required Object cityLabel,
  }) {
    return 'No organizers in $cityLabel yet';
  }

  @override
  String exploreCatchCoverStoryLabelChangeLocationLocation({
    required Object location,
  }) {
    return 'Change location, $location';
  }

  @override
  String exploreExploreCityPickerLabelSelectLabel({required Object label}) {
    return 'Select $label';
  }

  @override
  String exploreExploreEventTypeBrowseGridLabelLabelCountlabel({
    required Object label,
    required Object countLabel,
  }) {
    return '$label, $countLabel';
  }

  @override
  String exploreExploreEventTypeBrowseGridTextCount({required Object count}) {
    return '$count';
  }

  @override
  String exploreExploreEventTypeBrowseGridLabelRemainingcountMoreTypes({
    required Object remainingCount,
  }) {
    return '+ $remainingCount MORE TYPES';
  }

  @override
  String exploreExploreEventTypeBrowseGridLabelShowRemainingcountMoreActivity({
    required Object remainingCount,
  }) {
    return 'Show $remainingCount more activity types';
  }

  @override
  String exploreExploreListTitleNoClubsInCitylabel({
    required Object cityLabel,
  }) {
    return 'No organizers in $cityLabel yet';
  }

  @override
  String hostsEditHostedEventScreenTitleBasePriceCurrencycode({
    required Object currencyCode,
  }) {
    return 'Base price ($currencyCode)';
  }

  @override
  String hostsEditHostedEventScreenTitleStepCurrencycode({
    required Object currencyCode,
  }) {
    return 'Step ($currencyCode)';
  }

  @override
  String hostsEditHostedEventScreenTitleMaxCurrencycode({
    required Object currencyCode,
  }) {
    return 'Max ($currencyCode)';
  }

  @override
  String hostsCreateEventSuccessScreenMessageDisplaynameIsNowListed({
    required Object displayName,
    required Object name,
  }) {
    return '$displayName is now listed on $name. People can discover it from their home feed.';
  }

  @override
  String hostsCreateEventSuccessScreenMessageDisplaynameIsNowListed244c65({
    required Object displayName,
    required Object name,
  }) {
    return '$displayName is now listed on $name. People can discover it, but only attendees with the invite code or private link can book.';
  }

  @override
  String hostsDraftPickerSheetTextSavedTouppercase({
    required Object toUpperCase,
  }) {
    return 'SAVED $toUpperCase';
  }

  @override
  String hostsEventPolicyStepTitleBasePriceCurrencycode({
    required Object currencyCode,
  }) {
    return 'Base price ($currencyCode)';
  }

  @override
  String hostsEventPolicyStepTitleStepCurrencycode({
    required Object currencyCode,
  }) {
    return 'Step ($currencyCode)';
  }

  @override
  String hostsEventPolicyStepTitleMaxCurrencycode({
    required Object currencyCode,
  }) {
    return 'Max ($currencyCode)';
  }

  @override
  String hostsHostEventManageScreenMessageThisStopsNewAttribution({
    required Object label,
  }) {
    return 'This stops new attribution for $label, but keeps its history in reporting.';
  }

  @override
  String hostsHostEventManageScreenLabelShortdatelabelTime({
    required Object shortDateLabel,
    required Object time,
  }) {
    return '$shortDateLabel · $time';
  }

  @override
  String hostsHostEventManageScreenDetailOpenOpen({required Object open}) {
    return '$open open';
  }

  @override
  String hostsHostEventManageScreenDetailWaitlistedToReview({
    required Object waitlisted,
  }) {
    return '$waitlisted to review';
  }

  @override
  String hostsHostBroadcastComposerSheetLabelBookedBookedcount({
    required Object bookedCount,
  }) {
    return 'Booked · $bookedCount';
  }

  @override
  String hostsHostBroadcastComposerSheetLabelWaitlistProspectivecount({
    required Object prospectiveCount,
  }) {
    return 'Waitlist · $prospectiveCount';
  }

  @override
  String hostsHostBroadcastComposerSheetLabelEveryoneRecipientcount({
    required Object recipientCount,
  }) {
    return 'Everyone · $recipientCount';
  }

  @override
  String hostsHostBroadcastComposerSheetLabelSendToRecipientcountPeople({
    required Object recipientCount,
  }) {
    return 'Send to $recipientCount people';
  }

  @override
  String hostsHostInboxScreenLabelBookedBookedthreadcount({
    required Object bookedThreadCount,
  }) {
    return 'BOOKED · $bookedThreadCount';
  }

  @override
  String hostsHostInboxScreenLabelProspectiveProspectivethreadcount({
    required Object prospectiveThreadCount,
  }) {
    return 'PROSPECTIVE · $prospectiveThreadCount';
  }

  @override
  String hostsHostInboxScreenTitleNoValue1HaveWritten({
    required Object value1,
  }) {
    return 'No $value1 have written yet';
  }

  @override
  String hostsHostClubToolsSubtitleRemainingquotaOfWeeklyquotaPosts({
    required Object remainingQuota,
    required Object weeklyQuota,
  }) {
    return '$remainingQuota of $weeklyQuota posts left this week.';
  }

  @override
  String hostsHostClubToolsHelpertextValue1CharactersLeft({
    required Object value1,
  }) {
    return '$value1 characters left';
  }

  @override
  String hostsHostEventAttendancePanelLabelOfferNextCount({
    required Object count,
  }) {
    return 'Offer next $count';
  }

  @override
  String hostsHostEventToolsLabelHostEventValue1Of({
    required Object value1,
    required Object itemCount,
  }) {
    return 'Host event $value1 of $itemCount';
  }

  @override
  String hostsHostEventToolsTextValue1OfItemcount({
    required Object value1,
    required Object itemCount,
  }) {
    return '$value1 of $itemCount';
  }

  @override
  String hostsHostEventToolsLabelShortdatelabelTimerangelabel({
    required Object shortDateLabel,
    required Object timeRangeLabel,
  }) {
    return '$shortDateLabel · $timeRangeLabel';
  }

  @override
  String coreBlockUserDialogTitleBlockName({required Object name}) {
    return 'Block $name?';
  }

  @override
  String coreCatchFieldTooltipClearValue1({required Object value1}) {
    return 'Clear $value1';
  }

  @override
  String coreCatchFormFieldLabelLabelLabelOptional({required Object label}) {
    return '$label, optional';
  }

  @override
  String get coreCatchNoticeTooltipDismiss => 'Dismiss';

  @override
  String coreCatchPersonAvatarTextCount({required Object count}) {
    return '+$count';
  }

  @override
  String coreCatchPersonRowLabelLabelUnreadChats({required Object label}) {
    return '$label unread chats';
  }

  @override
  String coreCatchSearchFieldTooltipClearPlaceholder({
    required Object placeholder,
  }) {
    return 'Clear $placeholder';
  }

  @override
  String coreCatchSectionLayoutTextDisplaytitleCount({
    required Object displayTitle,
    required Object count,
  }) {
    return '$displayTitle · $count';
  }

  @override
  String get coreCatchStartupLoadingScreenBodyStartupLoadingIndicator =>
      'startup-loading-indicator';

  @override
  String get coreCatchStartupLoadingScreenBodyStartupLoadingDelay =>
      'startup-loading-delay';

  @override
  String coreCatchStepFlowHeaderTextStepClampedstepOfTotal({
    required Object clampedStep,
    required Object total,
  }) {
    return 'STEP $clampedStep OF $total';
  }

  @override
  String coreCatchStepProgressTextValue1Totalsteps({
    required Object value1,
    required Object totalSteps,
  }) {
    return '$value1/$totalSteps';
  }

  @override
  String coreCatchTopBarLabelViewNameProfile({required Object name}) {
    return 'View $name profile';
  }

  @override
  String coreOrderedPhotoPickerLabelPhotoValue1({required Object value1}) {
    return 'Photo $value1';
  }

  @override
  String coreOrderedPhotoPickerMessagePhotoValue1({required Object value1}) {
    return 'Photo $value1';
  }

  @override
  String coreOrderedPhotoPickerMessageRemovePhotoValue1({
    required Object value1,
  }) {
    return 'Remove photo $value1';
  }

  @override
  String eventsEventJoinedCelebrationScreenMessageYourSpotIsConfirmed({
    required Object title,
    required Object value2,
  }) {
    return 'Your spot is confirmed for $title$value2.';
  }

  @override
  String eventsEventDateMarkerLabelDayDay2({
    required Object day,
    required Object day2,
  }) {
    return '$day $day2';
  }

  @override
  String eventsEventDateMarkerTextDay({required Object day}) {
    return '$day';
  }

  @override
  String eventsEventDateMarkerLabelDay({required Object day}) {
    return '$day';
  }

  @override
  String eventsEventDateRailCardTextDay({required Object day}) {
    return '$day';
  }

  @override
  String get eventsEventDateRailCardSemanticsOpensEventDetails =>
      'Opens event details';

  @override
  String imageUploadsPhotoSlotLabelPhotoValue1Uploading({
    required Object value1,
  }) {
    return 'Photo $value1 uploading';
  }

  @override
  String imageUploadsPhotoSlotLabelEditPhotoValue1({required Object value1}) {
    return 'Edit photo $value1';
  }

  @override
  String imageUploadsPhotoSlotLabelAddPhotoValue1({required Object value1}) {
    return 'Add photo $value1';
  }

  @override
  String imageUploadsPhotoSlotLabelPhotoSlotValue1Unavailable({
    required Object value1,
  }) {
    return 'Photo slot $value1 unavailable';
  }

  @override
  String imageUploadsPhotoSlotMessageDeletePhotoValue1({
    required Object value1,
  }) {
    return 'Delete photo $value1';
  }

  @override
  String imageUploadsPhotoSlotTextPhotoPadleft({required Object padLeft}) {
    return 'PHOTO $padLeft';
  }

  @override
  String imageUploadsProfilePhotoEditorScreenCatchbuttonDeletePhotoValue1({
    required Object value1,
  }) {
    return 'Delete photo $value1';
  }

  @override
  String
  imageUploadsProfilePhotoEditorScreenTextKeepAtLeastMinimumprofilephotocount({
    required Object minimumProfilePhotoCount,
  }) {
    return 'Keep at least $minimumProfilePhotoCount photos on your profile.';
  }

  @override
  String get launchAccessLaunchAccessApplicationScreenTitleApplyForAccess =>
      'Apply for access';

  @override
  String matchesMatchCelebrationDialogMessageYouAndNameBoth({
    required Object name,
  }) {
    return 'You and $name both liked each other.';
  }

  @override
  String
  onboardingProfilePromptsPageHelpertextLengthMaximumprofilepromptanswerlength({
    required Object length,
    required Object maximumProfilePromptAnswerLength,
  }) {
    return '$length / $maximumProfilePromptAnswerLength';
  }

  @override
  String get onboardingWelcomePageLabelSkipWelcomeAnimation =>
      'Skip welcome animation';

  @override
  String get onboardingWelcomePageTextCatch => 'Catch';

  @override
  String get onboardingWelcomePageLabelContinueWithPhone =>
      'Continue with phone';

  @override
  String get onboardingWelcomePageLabelSeeWhatSOn => 'See what\'s on';

  @override
  String get paymentsPaymentConfirmationScreenTitleEventNotFound =>
      'Event not found';

  @override
  String get paymentsPaymentConfirmationScreenMessageThisEventIsNo =>
      'This event is no longer available.';

  @override
  String paymentsPaymentConfirmationScreenLabelTryProviderlabelAgain({
    required Object providerLabel,
  }) {
    return 'Try $providerLabel again';
  }

  @override
  String paymentsPaymentConfirmationScreenLabelOpenProviderlabelCheckout({
    required Object providerLabel,
  }) {
    return 'Open $providerLabel checkout';
  }

  @override
  String get paymentsPaymentHistoryScreenTitlePaymentHistory =>
      'Payment history';

  @override
  String paymentsPaymentHistoryScreenLabelPaymentForEventtitle({
    required Object eventTitle,
  }) {
    return 'Payment for $eventTitle';
  }

  @override
  String publicProfilePublicProfileScreenTitleReportProfilename({
    required Object profileName,
  }) {
    return 'Report $profileName';
  }

  @override
  String get reviewsReviewsHistoryScreenTitleSignInToSee =>
      'Sign in to see reviews';

  @override
  String get reviewsReviewsHistoryScreenMessageYourPastEventReviews =>
      'Your past event reviews will appear here.';

  @override
  String get reviewsReviewsHistoryScreenTitleReviewHistory => 'Review history';

  @override
  String reviewsReviewsSectionTitleAllReviewsLength({required Object length}) {
    return 'All reviews ($length)';
  }

  @override
  String reviewsReviewsSectionTextTostringasfixedLength({
    required Object toStringAsFixed,
    required Object length,
  }) {
    return '$toStringAsFixed · $length';
  }

  @override
  String reviewsReviewsSectionLabelSeeAllLengthReviews({
    required Object length,
  }) {
    return 'See all $length reviews';
  }

  @override
  String reviewsReviewsSectionTextHostResponseHostname({
    required Object hostName,
  }) {
    return 'Host response · $hostName';
  }

  @override
  String reviewsStarRatingMessageValueStarValue2({
    required Object value,
    required Object value2,
  }) {
    return '$value star$value2';
  }

  @override
  String reviewsStarRatingLabelRateValueStarValue2({
    required Object value,
    required Object value2,
  }) {
    return 'Rate $value star$value2';
  }

  @override
  String get safetySettingsScreenTitleSettings => 'Settings';

  @override
  String get safetySettingsScreenTitleAccountUnavailable =>
      'Account unavailable';

  @override
  String get safetySettingsScreenMessageSignOutAndSign =>
      'Sign out and sign back in if this keeps happening.';

  @override
  String get swipesEventRecapScreenTitleEventNotFound => 'Event not found';

  @override
  String get swipesEventRecapScreenMessageThisEventIsNo =>
      'This event is no longer available.';

  @override
  String swipesSwipeHubScreenTextLength({required Object length}) {
    return '$length';
  }

  @override
  String get swipesSwipeHubScreenTitleCatches => 'Catches';

  @override
  String swipesSwipeScreenTextCatchesRemainingcountLeft({
    required Object remainingCount,
  }) {
    return 'Catches · $remainingCount left';
  }

  @override
  String get swipesAttendedEventTileLabelCatch => 'Catch';

  @override
  String swipesCatchProfileViewTextNameAge({
    required Object name,
    required Object age,
  }) {
    return '$name, $age';
  }

  @override
  String swipesProfileReactionControlsTooltipLikeLabel({
    required Object label,
  }) {
    return 'Like $label';
  }

  @override
  String swipesProfileReactionControlsTooltipCommentOnLabel({
    required Object label,
  }) {
    return 'Comment on $label';
  }

  @override
  String swipesProfileReactionControlsTitleStartWithLabel({
    required Object label,
  }) {
    return 'Start with $label';
  }

  @override
  String
  swipesProfileReactionControlsHelpertextLengthMaxswipereactioncommentlengthCharacters({
    required Object length,
    required Object maxSwipeReactionCommentLength,
  }) {
    return '$length / $maxSwipeReactionCommentLength characters';
  }

  @override
  String swipesProfileSurfaceLabelProfileOfNameAge({
    required Object name,
    required Object age,
  }) {
    return 'Profile of $name, $age';
  }

  @override
  String get userProfileProfileScreenTitleYourProfile => 'Your profile';

  @override
  String userProfileInlineEditorPromptLabelPromptNumber({
    required Object number,
  }) {
    return 'Prompt $number';
  }

  @override
  String get userProfileInlineEditorPromptLabelAnswer => 'Answer';

  @override
  String get userProfileInlineEditorPromptLabelAddAnotherPrompt =>
      'Add another prompt';

  @override
  String userProfileInlineEditorTextTextDisplayvalue({
    required Object displayValue,
  }) {
    return '+ $displayValue';
  }

  @override
  String userProfileInlineEditorTextTextProfileInlineDisplayLabel({
    required Object label,
    required Object displayValue,
    required Object isAddAffordance,
  }) {
    return 'profile-inline-display-$label-$displayValue-$isAddAffordance';
  }

  @override
  String get userProfileProfileSliverHeaderLabelEdit => 'Edit';

  @override
  String get userProfileProfileSliverHeaderLabelPreview => 'Preview';

  @override
  String get userProfileProfileSliverHeaderLabelInsights => 'Insights';

  @override
  String get userProfileProfileTabSkeletonTitlePrompts => 'Prompts';

  @override
  String get userProfileProfileTabSkeletonTitleAboutYou => 'About you';

  @override
  String get userProfileProfileTabSkeletonTitleRunning => 'Running';

  @override
  String get userProfileProfileTabSkeletonTitleLifestyle => 'Lifestyle';

  @override
  String clubsAvatarChipLabelOpenNameClub({required Object name}) {
    return 'Open $name organizer';
  }

  @override
  String get clubsAvatarChipTextEventSoon => 'Event soon';

  @override
  String clubsDirectoryCardLabelOpenNameClub({required Object name}) {
    return 'Open $name organizer';
  }

  @override
  String get clubsDirectoryCardLabelJoined => 'Following';

  @override
  String get clubsDirectoryCardLabelJoin => 'Follow';

  @override
  String get dashboardDashboardEmptyHomeScreenLabelHome => 'Home';

  @override
  String get dashboardDashboardHomeScreenLabelHome => 'Home';

  @override
  String get eventSuccessEventSuccessCompanionAfterglowLabelPrivateAfterglow =>
      'Private afterglow';

  @override
  String eventSuccessEventSuccessCompanionAfterglowTextYourNightAtTitle({
    required Object title,
  }) {
    return 'Your night at $title';
  }

  @override
  String get eventSuccessEventSuccessCompanionAfterglowTextASmallRecapFor =>
      'A small recap for you, not a public share card.';

  @override
  String get eventSuccessEventSuccessCompanionAfterglowLabelYouShowedUp =>
      'You showed up';

  @override
  String get eventSuccessEventSuccessCompanionAfterglowLabelOpenersReady =>
      'Openers ready';

  @override
  String get eventSuccessEventSuccessCompanionAfterglowLabelMemorySaved =>
      'Memory saved';

  @override
  String get eventSuccessEventSuccessCompanionAfterglowLabelYourRead =>
      'Your read';

  @override
  String get eventSuccessEventSuccessCompanionAfterglowLabelYourReadSaved =>
      'Your read saved';

  @override
  String get eventSuccessEventSuccessCompanionAfterglowTextOnlyYouSeeThis =>
      'Only you see this recap. Hosts get aggregate coaching, never your private notes or individual opener choices.';

  @override
  String get eventSuccessEventSuccessCompanionArrivalMissionLabelFirstHello =>
      'First Hello';

  @override
  String
  get eventSuccessEventSuccessCompanionArrivalMissionTextStartYourFirstHello =>
      'Start your First Hello.';

  @override
  String
  get eventSuccessEventSuccessCompanionArrivalMissionTextWeWillConfirmYou =>
      'We will confirm you are at the venue, then give you one person and one tiny question. Complete it to check in.';

  @override
  String
  get eventSuccessEventSuccessCompanionArrivalMissionTextThisIsAPrivate =>
      'This is a private prompt. It is designed to make the first conversation easier, not to put your answers on display.';

  @override
  String
  get eventSuccessEventSuccessCompanionArrivalMissionLabelStartFirstHello =>
      'Start First Hello';

  @override
  String
  get eventSuccessEventSuccessCompanionArrivalMissionLabelUseNormalCheckIn =>
      'Use normal check-in';

  @override
  String
  eventSuccessEventSuccessCompanionArrivalMissionTextFindTargetdisplayname({
    required Object targetDisplayName,
  }) {
    return 'Find $targetDisplayName.';
  }

  @override
  String
  get eventSuccessEventSuccessCompanionArrivalMissionTextCompleteThisTinyMission =>
      'Complete this tiny mission to check in. If the room is crowded or the person is late, use the fallback.';

  @override
  String
  get eventSuccessEventSuccessCompanionArrivalMissionLabelCompleteCheckIn =>
      'Complete check-in';

  @override
  String get eventSuccessEventSuccessCompanionArrivalMissionLabelCanTFindThem =>
      'Can\'t find them';

  @override
  String get eventSuccessEventSuccessCompanionFeedbackTextHowDidItFeel =>
      'How did it feel?';

  @override
  String get eventSuccessEventSuccessCompanionFeedbackTextYourFeedbackIsSaved =>
      'Your feedback is saved';

  @override
  String get eventSuccessEventSuccessCompanionFeedbackTextThisIsPrivateFirst =>
      'This is private-first: hosts see aggregate trends, while private notes and safety concerns stay with Catch.';

  @override
  String get eventSuccessEventSuccessCompanionFeedbackLabelWelcome => 'Welcome';

  @override
  String get eventSuccessEventSuccessCompanionFeedbackLabelStructure =>
      'Structure';

  @override
  String get eventSuccessEventSuccessCompanionFeedbackTitleIWantCatchTo =>
      'I want Catch to review a safety or comfort concern';

  @override
  String get eventSuccessEventSuccessCompanionFeedbackTitlePrivateNoteToCatch =>
      'Private note to Catch';

  @override
  String get eventSuccessEventSuccessCompanionFeedbackLabelSubmitFeedback =>
      'Submit feedback';

  @override
  String get eventSuccessEventSuccessCompanionFeedbackLabelUpdateFeedback =>
      'Update feedback';

  @override
  String eventSuccessEventSuccessCompanionFeedbackTooltipLabelI({
    required Object label,
    required Object i,
  }) {
    return '$label $i';
  }

  @override
  String get eventSuccessEventSuccessCompanionFeedbackTextPeopleIMet =>
      'People I met';

  @override
  String
  get eventSuccessEventSuccessCompanionFeedbackTooltipDecreasePeopleMet =>
      'Decrease people met';

  @override
  String eventSuccessEventSuccessCompanionFeedbackTextValue({
    required Object value,
  }) {
    return '$value';
  }

  @override
  String
  get eventSuccessEventSuccessCompanionFeedbackTooltipIncreasePeopleMet =>
      'Increase people met';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsLabelStarterGroup =>
      'Starter group';

  @override
  String
  get eventSuccessEventSuccessCompanionLiveCardsTextStarterGroupsPausedFor =>
      'Starter groups paused for you';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsTextYourStarterGroupIs =>
      'Your starter group is forming';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsTextYouWonTBe =>
      'You won\'t be included when the host runs the generator.';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsTextTheHostWillPublish =>
      'The host will publish starter groups once everyone is checked in.';

  @override
  String
  get eventSuccessEventSuccessCompanionLiveCardsLabelLoadingGroupMembers =>
      'Loading group members';

  @override
  String
  get eventSuccessEventSuccessCompanionLiveCardsLabelIncludeMeInStarter =>
      'Include me in starter groups';

  @override
  String eventSuccessEventSuccessCompanionLiveCardsLabelValue1People({
    required Object value1,
  }) {
    return '$value1 people';
  }

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsLabelTimedRotations =>
      'Timed rotations';

  @override
  String
  get eventSuccessEventSuccessCompanionLiveCardsTextTimedRotationsPausedFor =>
      'Timed rotations paused for you';

  @override
  String
  get eventSuccessEventSuccessCompanionLiveCardsTextYourRotationScheduleIs =>
      'Your rotation schedule is forming';

  @override
  String
  get eventSuccessEventSuccessCompanionLiveCardsTextYourTimedPairingsAppear =>
      'Your timed pairings appear once the host generates rotations.';

  @override
  String
  get eventSuccessEventSuccessCompanionLiveCardsLabelLoadingPartnerNames =>
      'Loading partner names';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsLabelIncludeMeInTimed =>
      'Include me in timed rotations';

  @override
  String eventSuccessEventSuccessCompanionLiveCardsTextTimerangePeername({
    required Object timeRange,
    required Object peerName,
  }) {
    return '$timeRange · $peerName';
  }

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsLabelLiveCue =>
      'Live cue';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsTextEventIsLive =>
      'Event is live';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsTextFollowTheHostFor =>
      'Follow the host for the next event moment.';

  @override
  String
  get eventSuccessEventSuccessCompanionLiveCardsTextSmallStarterGroupWhen =>
      'Small starter group when you check in.';

  @override
  String
  get eventSuccessEventSuccessCompanionLiveCardsTextTimedPartnerRotationsDuring =>
      'Timed partner rotations during the event.';

  @override
  String
  get eventSuccessEventSuccessCompanionLiveCardsTextSynchronizedPartnerRevealsAs =>
      'Synchronized partner reveals as the event unfolds.';

  @override
  String
  get eventSuccessEventSuccessCompanionLiveCardsTextLiveConversationPromptsFrom =>
      'Live conversation prompts from the host.';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsTextYouCanAskThe =>
      'You can ask the host for an intro to someone specific.';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsLabelPreview =>
      'Preview';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsTextWhatWeLlGuide =>
      'What we\'ll guide you through';

  @override
  String
  get eventSuccessEventSuccessCompanionLiveCardsTextLivePartnerAndGroup =>
      'Live partner and group details unlock after check-in. Here\'s what to expect at the event:';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsLabelArrival =>
      'Arrival';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsTextArrivalCheckIn =>
      'Arrival check-in';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsTextConfirmYouAreAt =>
      'Confirm you are at the event so post-event follow-up only includes actual attendees.';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsLabelScanHostQr =>
      'Scan host QR';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsLabelCheckIn =>
      'Check in';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsTextScanHostQr =>
      'Scan host QR';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsMessageClose => 'Close';

  @override
  String
  get eventSuccessEventSuccessCompanionLiveCardsTextLocationStillVerifiesThe =>
      'Location still verifies the venue after the QR is scanned.';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsMessageCopyOpener =>
      'Copy opener';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsMessageCopyCue =>
      'Copy cue';

  @override
  String
  get eventSuccessEventSuccessCompanionQuestionnaireTextAFewQuickQuestions =>
      'A few quick questions';

  @override
  String
  get eventSuccessEventSuccessCompanionQuestionnaireLabelCanGuidePairings =>
      'Can guide pairings';

  @override
  String get eventSuccessEventSuccessCompanionQuestionnaireLabelCluesOnly =>
      'Clues only';

  @override
  String get eventSuccessEventSuccessCompanionQuestionnaireLabelSaved =>
      'Saved';

  @override
  String
  get eventSuccessEventSuccessCompanionQuestionnaireTextYourAnswersCanShape =>
      'Your answers can shape reveal clues and help guide pairings. Hosts never see individual answers.';

  @override
  String
  get eventSuccessEventSuccessCompanionQuestionnaireTextYourAnswersCanShape025884 =>
      'Your answers can shape reveal clues. Hosts never see individual answers, and this event will not use them for pairings.';

  @override
  String get eventSuccessEventSuccessCompanionQuestionnaireLabelSaveClues =>
      'Save clues';

  @override
  String get eventSuccessEventSuccessCompanionQuestionnaireLabelUpdateClues =>
      'Update clues';

  @override
  String eventSuccessEventSuccessCompanionQuestionnaireMessageQuestionValue1({
    required Object value1,
  }) {
    return 'Question $value1';
  }

  @override
  String
  eventSuccessEventSuccessCompanionQuestionnaireSemanticlabelQuestionValue1({
    required Object value1,
  }) {
    return 'Question $value1';
  }

  @override
  String eventSuccessEventSuccessCompanionQuestionnaireTextValue1({
    required Object value1,
  }) {
    return '$value1';
  }

  @override
  String get eventSuccessEventSuccessCompanionSharedTextEventCompanion =>
      'Event companion';

  @override
  String eventSuccessEventSuccessCompanionSharedTextPadleftTotalsteps({
    required Object padLeft,
    required Object totalSteps,
  }) {
    return '$padLeft / $totalSteps';
  }

  @override
  String get eventSuccessEventSuccessCompanionSharedTextYourTicketToday =>
      'YOUR TICKET - TODAY';

  @override
  String get eventSuccessEventSuccessCompanionSharedLabelWhen => 'WHEN';

  @override
  String get eventSuccessEventSuccessCompanionSharedLabelWhere => 'WHERE';

  @override
  String get eventSuccessEventSuccessCompanionSharedLabelEntry => 'ENTRY';

  @override
  String eventSuccessEventSuccessCompanionSharedTextTitleLocationname({
    required Object title,
    required Object locationName,
  }) {
    return '$title - $locationName';
  }

  @override
  String get eventSuccessEventSuccessCompanionSharedLabelWhatToExpect =>
      'What to expect';

  @override
  String get eventSuccessEventSuccessCompanionSharedLabelIMHereCheck =>
      'I\'m here - check me in';

  @override
  String get eventSuccessEventSuccessCompanionSharedMessageBack => 'Back';

  @override
  String eventSuccessEventSuccessCompanionSharedTextTitleLocationname29e462({
    required Object title,
    required Object locationName,
  }) {
    return '$title · $locationName';
  }

  @override
  String eventSuccessEventSuccessCompanionSharedTextCheckedincount({
    required Object checkedInCount,
  }) {
    return '$checkedInCount';
  }

  @override
  String get eventSuccessEventSuccessCompanionSharedText1PersonIsChecked =>
      '1 person is checked in alongside you';

  @override
  String eventSuccessEventSuccessCompanionSharedTextCountPeopleInThe({
    required Object count,
  }) {
    return '$count people in the room with you';
  }

  @override
  String get eventSuccessEventSuccessCompanionSharedTextTheHostIsRunning =>
      'The host is running the room';

  @override
  String get eventSuccessEventSuccessCompanionSharedTextYourNextPromptOr =>
      'Your next prompt or partner reveal will show up here.';

  @override
  String get eventSuccessEventSuccessCompanionWingmanTextAskTheHostFor =>
      'Ask the host for an intro';

  @override
  String get eventSuccessEventSuccessCompanionWingmanTextTellTheHostWho =>
      'Tell the host who you\'d like to be introduced to. The host can see this request — the other person is not notified.';

  @override
  String eventSuccessEventSuccessCompanionWingmanTextRequestSentForValue1({
    required Object value1,
  }) {
    return 'Request sent for $value1.';
  }

  @override
  String get eventSuccessEventSuccessCompanionWingmanLabelWithdraw =>
      'Withdraw';

  @override
  String get eventSuccessEventSuccessCompanionWingmanTitlePrivateNoteToHost =>
      'Private note to host';

  @override
  String get eventSuccessEventSuccessCompanionWingmanTextNoCheckedInAttendees =>
      'No checked-in attendees available yet.';

  @override
  String get eventSuccessEventSuccessCompanionWingmanLabelRequested =>
      'Requested';

  @override
  String get eventSuccessEventSuccessCompanionWingmanLabelAskHost => 'Ask host';

  @override
  String get eventSuccessEventSuccessCompanionWingmanLabelSwitch => 'Switch';

  @override
  String get eventSuccessEventSuccessCompanionBodyScreenTitleSocialPrompt =>
      'Social prompt';

  @override
  String
  get eventSuccessEventSuccessCompanionBodyScreenTitleSuggestedFirstMessageOpeners =>
      'Suggested first-message openers';

  @override
  String get eventSuccessEventSuccessCompanionBodyScreenTitleConversationCues =>
      'Conversation cues';

  @override
  String get eventSuccessEventSuccessCompanionBodyScreenSubtitleUseOneAfterA =>
      'Use one after a mutual match opens.';

  @override
  String
  get eventSuccessEventSuccessCompanionBodyScreenSubtitlePickOneWhenThe =>
      'Pick one when the room needs an easy next line.';

  @override
  String get eventSuccessEventSuccessHostLiveTitleLiveModeNeedsSaved =>
      'Live mode needs saved setup';

  @override
  String get eventSuccessEventSuccessHostLiveTitleLiveModeWasNot =>
      'Live mode was not configured';

  @override
  String get eventSuccessEventSuccessHostLiveBodySaveTheLiveGuide =>
      'Save the live guide before the event to enable guided controls. Attendance and check-in stay available from this Live tab.';

  @override
  String get eventSuccessEventSuccessHostLiveBodyThisEventDidNot =>
      'This event did not have a live guide saved before it started. Attendance and check-in remain available; guided live controls stay unavailable for this event.';

  @override
  String get eventSuccessEventSuccessHostLiveTitleNoLiveStepsSelected =>
      'No live steps selected';

  @override
  String get eventSuccessEventSuccessHostLiveBodyThisSavedSetupDoes =>
      'This saved setup does not include any tools the host can use during the event.';

  @override
  String get eventSuccessEventSuccessHostLiveTitleConversationCues =>
      'Conversation cues';

  @override
  String get eventSuccessEventSuccessHostLiveSubtitleUseOneWhenThe =>
      'Use one when the room needs a cleaner next interaction.';

  @override
  String get eventSuccessEventSuccessHostLiveSubtitleCloseWithOneSuggested =>
      'Close with one suggested first message after mutual matches.';

  @override
  String get eventSuccessEventSuccessHostLiveTitleSupportingControls =>
      'Supporting controls';

  @override
  String
  get eventSuccessEventSuccessHostLiveSubtitleControlsThatStayAvailable =>
      'Controls that stay available without competing with the current live step.';

  @override
  String get eventSuccessEventSuccessHostLiveLabelMarkLiveGuideComplete =>
      'Mark live guide complete';

  @override
  String get eventSuccessEventSuccessHostLiveTitleControlsForThisStep =>
      'Controls for this step';

  @override
  String get eventSuccessEventSuccessHostLiveSubtitleHandleTheseBeforeMoving =>
      'Handle these before moving the room forward.';

  @override
  String get eventSuccessEventSuccessHostLiveTextLiveNow => 'Live now';

  @override
  String
  get eventSuccessEventSuccessHostLiveCatchbuttonEventsuccesspreviousstepbutton =>
      'eventSuccessPreviousStepButton';

  @override
  String get eventSuccessEventSuccessHostLiveLabelPrevious => 'Previous';

  @override
  String
  get eventSuccessEventSuccessHostLiveCatchbuttonEventsuccessnextstepbutton =>
      'eventSuccessNextStepButton';

  @override
  String get eventSuccessEventSuccessHostOverridesTextSmallStarterGroups =>
      'Small starter groups';

  @override
  String eventSuccessEventSuccessHostOverridesLabelLengthAssigned({
    required Object length,
  }) {
    return '$length assigned';
  }

  @override
  String eventSuccessEventSuccessHostOverridesLabelOptedoutcountOptedOut({
    required Object optedOutCount,
  }) {
    return '$optedOutCount opted out';
  }

  @override
  String get eventSuccessEventSuccessHostOverridesLabelHostEdited =>
      'Host edited';

  @override
  String get eventSuccessEventSuccessHostOverridesTextRegenerateToRemoveOpted =>
      'Regenerate to remove opted-out attendee cards from the current pod set.';

  @override
  String
  get eventSuccessEventSuccessHostOverridesTextGenerateAttendeePodCards =>
      'Generate attendee pod cards from the roster, excluding opted-out attendees.';

  @override
  String
  get eventSuccessEventSuccessHostOverridesTextGenerateAttendeePodCards4cbcdf =>
      'Generate attendee pod cards from the current booked and checked-in roster.';

  @override
  String
  get eventSuccessEventSuccessHostOverridesCatchbuttonEventsuccessgeneratemicropodsbutton =>
      'eventSuccessGenerateMicroPodsButton';

  @override
  String get eventSuccessEventSuccessHostOverridesLabelGenerateMicroPods =>
      'Generate micro-pods';

  @override
  String get eventSuccessEventSuccessHostOverridesLabelRegenerate =>
      'Regenerate';

  @override
  String get eventSuccessEventSuccessHostOverridesLabelEditGroups =>
      'Edit groups';

  @override
  String get eventSuccessEventSuccessHostOverridesTitleEditGroups =>
      'Edit groups';

  @override
  String get eventSuccessEventSuccessHostOverridesSubtitleHostOverride =>
      'Host override';

  @override
  String get eventSuccessEventSuccessHostOverridesLabelSaveOverrides =>
      'Save overrides';

  @override
  String eventSuccessEventSuccessHostOverridesLabelGroupValue1({
    required Object value1,
  }) {
    return 'Group $value1';
  }

  @override
  String eventSuccessEventSuccessHostOverridesTextRoundValue1({
    required Object value1,
  }) {
    return 'Round $value1';
  }

  @override
  String get eventSuccessEventSuccessHostOverridesLabelAddGroup => 'Add group';

  @override
  String get eventSuccessEventSuccessHostOverridesTextNoGroupsInThis =>
      'No groups in this round.';

  @override
  String get eventSuccessEventSuccessHostOverridesTitleGroupLabel =>
      'Group label';

  @override
  String get eventSuccessEventSuccessHostOverridesTooltipRemoveGroup =>
      'Remove group';

  @override
  String get eventSuccessEventSuccessHostOverridesLabelAddAttendee =>
      'Add attendee';

  @override
  String get eventSuccessEventSuccessHostOverridesTitleGroupAttendee =>
      'Group attendee';

  @override
  String get eventSuccessEventSuccessHostOverridesHinttextAttendee =>
      'Attendee';

  @override
  String get eventSuccessEventSuccessHostOverridesTooltipRemoveAttendee =>
      'Remove attendee';

  @override
  String get eventSuccessEventSuccessHostOverridesTextTimedPartnerRotations =>
      'Timed partner rotations';

  @override
  String eventSuccessEventSuccessHostOverridesLabelRoundcountRounds({
    required Object roundCount,
  }) {
    return '$roundCount rounds';
  }

  @override
  String
  get eventSuccessEventSuccessHostOverridesTextRegenerateToRemoveOpted4eddde =>
      'Regenerate to remove opted-out attendees from timed rotations.';

  @override
  String
  get eventSuccessEventSuccessHostOverridesTextGeneratePairingsFromEvent =>
      'Generate pairings from event duration, saved cadence, checked-in participants, and mutual gender interest.';

  @override
  String
  eventSuccessEventSuccessHostOverridesLabelEventrotationcapacityPossible({
    required Object eventRotationCapacity,
  }) {
    return '$eventRotationCapacity possible';
  }

  @override
  String
  eventSuccessEventSuccessHostOverridesLabelSitoutroundcountPlannedBreaks({
    required Object sitOutRoundCount,
  }) {
    return '$sitOutRoundCount planned breaks';
  }

  @override
  String
  eventSuccessEventSuccessHostOverridesLabelRepeatpeercountRepeatedPeers({
    required Object repeatPeerCount,
  }) {
    return '$repeatPeerCount repeated peers';
  }

  @override
  String
  get eventSuccessEventSuccessHostOverridesCatchbuttonEventsuccessgeneraterotationsbutton =>
      'eventSuccessGenerateRotationsButton';

  @override
  String get eventSuccessEventSuccessHostOverridesLabelGenerateRotations =>
      'Generate rotations';

  @override
  String get eventSuccessEventSuccessHostOverridesLabelEditRotations =>
      'Edit rotations';

  @override
  String get eventSuccessEventSuccessHostOverridesTitleEditRotations =>
      'Edit rotations';

  @override
  String get eventSuccessEventSuccessHostOverridesLabelAddPair => 'Add pair';

  @override
  String get eventSuccessEventSuccessHostOverridesTextNoPairsInThis =>
      'No pairs in this round.';

  @override
  String get eventSuccessEventSuccessHostOverridesTitleFirstRotationAttendee =>
      'First rotation attendee';

  @override
  String get eventSuccessEventSuccessHostOverridesTitleSecondRotationAttendee =>
      'Second rotation attendee';

  @override
  String get eventSuccessEventSuccessHostOverridesHinttextPartner => 'Partner';

  @override
  String get eventSuccessEventSuccessHostOverridesTooltipRemovePair =>
      'Remove pair';

  @override
  String eventSuccessEventSuccessHostOverridesLabelKeyValueAssigned({
    required Object key,
    required Object value,
  }) {
    return '$key · $value assigned';
  }

  @override
  String get eventSuccessEventSuccessHostOverridesTextAssignmentNotes =>
      'Assignment notes';

  @override
  String get eventSuccessEventSuccessHostReportTitleNoEventReportYet =>
      'No event report yet';

  @override
  String get eventSuccessEventSuccessHostReportBodyTheLiveEventGuide =>
      'The live event guide was not saved for this event, so there is no post-event report to review. Attendance reporting remains available on this screen.';

  @override
  String get eventSuccessEventSuccessHostReportTitlePostEventInsightsAre =>
      'Post-event insights are off';

  @override
  String get eventSuccessEventSuccessHostReportBodyThisEventGuideDoes =>
      'This event guide does not include post-event coaching for the host.';

  @override
  String
  get eventSuccessEventSuccessHostReportTitleWaitingForAttendeeFeedback =>
      'Waiting for attendee feedback';

  @override
  String
  eventSuccessEventSuccessHostReportTitleFeedbackcountAttendeeFeedbackResponse({
    required Object feedbackCount,
    required Object value2,
  }) {
    return '$feedbackCount attendee feedback response$value2';
  }

  @override
  String
  get eventSuccessEventSuccessHostReportBodyTheReportCombinesAttendance =>
      'The report combines attendance, safe aggregate feedback, assignment coverage, and explicit host-help requests. Private notes, safety concerns, and individual opener choices are not shown to hosts.';

  @override
  String get eventSuccessEventSuccessHostReportTextHowReliableIsThis =>
      'How reliable is this report?';

  @override
  String get eventSuccessEventSuccessHostReportTextShowsWhetherTheReport =>
      'Shows whether the report is based on enough live data to trust.';

  @override
  String get eventSuccessEventSuccessHostReportLabelFeedback => 'Feedback';

  @override
  String get eventSuccessEventSuccessHostReportLabelCaughtSomeone =>
      'Caught someone';

  @override
  String get eventSuccessEventSuccessHostReportLabelPeopleIncluded =>
      'People included';

  @override
  String get eventSuccessEventSuccessHostReportLabelOptedOut => 'Opted out';

  @override
  String get eventSuccessEventSuccessHostReportLabelWingmanHelp =>
      'Wingman help';

  @override
  String
  eventSuccessEventSuccessHostReportLabelFeedbackresponsecountCheckedincountFeedback({
    required Object feedbackResponseCount,
    required Object checkedInCount,
  }) {
    return '$feedbackResponseCount/$checkedInCount feedback';
  }

  @override
  String
  eventSuccessEventSuccessHostReportLabelAttendeeswhocaughtsomeoneCaughtSomeone({
    required Object attendeesWhoCaughtSomeone,
  }) {
    return '$attendeesWhoCaughtSomeone caught someone';
  }

  @override
  String get eventSuccessEventSuccessHostReportLabelCatchesSent =>
      'Catches sent';

  @override
  String
  eventSuccessEventSuccessHostReportLabelAssignmentparticipantcountAssigned({
    required Object assignmentParticipantCount,
  }) {
    return '$assignmentParticipantCount assigned';
  }

  @override
  String eventSuccessEventSuccessHostReportLabelAssignmentoptoutcountOptedOut({
    required Object assignmentOptOutCount,
  }) {
    return '$assignmentOptOutCount opted out';
  }

  @override
  String
  eventSuccessEventSuccessHostReportLabelWingmanrequestcountHostHelpRequests({
    required Object wingmanRequestCount,
  }) {
    return '$wingmanRequestCount host-help requests';
  }

  @override
  String get eventSuccessEventSuccessHostReportTextEventFunnel =>
      'Event funnel';

  @override
  String get eventSuccessEventSuccessHostReportLabelDemandToBooked =>
      'Demand to booked';

  @override
  String get eventSuccessEventSuccessHostReportLabelRequestsApproved =>
      'Requests approved';

  @override
  String get eventSuccessEventSuccessHostReportLabelOffersAccepted =>
      'Offers accepted';

  @override
  String get eventSuccessEventSuccessHostReportLabelPaymentComplete =>
      'Payment complete';

  @override
  String get eventSuccessEventSuccessHostReportLabelRepeatAttendees =>
      'Repeat attendees';

  @override
  String eventSuccessEventSuccessHostReportLabelTotaldemandcountPeopleInDemand({
    required Object totalDemandCount,
  }) {
    return '$totalDemandCount people in demand';
  }

  @override
  String eventSuccessEventSuccessHostReportLabelWaitlistjoincountWaitlisted({
    required Object waitlistJoinCount,
  }) {
    return '$waitlistJoinCount waitlisted';
  }

  @override
  String eventSuccessEventSuccessHostReportLabelPaymentcompletedcountPaid({
    required Object paymentCompletedCount,
  }) {
    return '$paymentCompletedCount paid';
  }

  @override
  String eventSuccessEventSuccessHostReportLabelChatstartedcountChatsStarted({
    required Object chatStartedCount,
  }) {
    return '$chatStartedCount chats started';
  }

  @override
  String get eventSuccessEventSuccessHostSetupTitleEventStartedWithoutA =>
      'Event started without a saved guide';

  @override
  String get eventSuccessEventSuccessHostSetupTitleLiveGuideCanNo =>
      'Live guide can no longer be saved';

  @override
  String get eventSuccessEventSuccessHostSetupBodyThisEventBeganBefore =>
      'This event began before a live guide was saved. Attendance and check-in still work, but the Live tab won\'t have any guided controls for this event.';

  @override
  String get eventSuccessEventSuccessHostSetupBodyBookingsHaveAlreadyStarted =>
      'Bookings have already started. Attendance and check-in still work, but the Live tab won\'t have guided controls unless a guide was saved first.';

  @override
  String get eventSuccessEventSuccessHostSetupTitleSetupNotSavedYet =>
      'Setup not saved yet';

  @override
  String get eventSuccessEventSuccessHostSetupBodyThisDefaultPlanIs =>
      'This default plan is visible here only. Save it so the Live tab is ready when the event starts.';

  @override
  String get eventSuccessEventSuccessHostSetupTitleSettingsAreLocked =>
      'Settings are locked';

  @override
  String get eventSuccessEventSuccessHostSetupBodyBookingsHaveStartedSo =>
      'Bookings have started, so the saved guide is locked in. Switch to the Live tab to drive the event in real time once it starts.';

  @override
  String get eventSuccessEventSuccessHostSetupBodyTheEventHasStarted =>
      'The event has started — setup is locked. Use the Live tab to control the event right now, and the Report tab afterward.';

  @override
  String get eventSuccessEventSuccessHostSetupTitleYourPlan => 'Your plan';

  @override
  String get eventSuccessEventSuccessHostSetupLabelSaveChanges =>
      'Save changes';

  @override
  String get eventSuccessEventSuccessHostSetupLabelSaveSetup => 'Save setup';

  @override
  String get eventSuccessEventSuccessHostSetupLabelSaveLiveGuide =>
      'Save live guide';

  @override
  String get eventSuccessEventSuccessHostSetupTextTargetAttendees =>
      'Target attendees';

  @override
  String
  eventSuccessEventSuccessHostSetupTextRecommendedRangeRecommendedminRecommendedmax({
    required Object recommendedMin,
    required Object recommendedMax,
  }) {
    return 'Recommended range: $recommendedMin-$recommendedMax';
  }

  @override
  String
  get eventSuccessEventSuccessHostSetupTextAddAGoalSoTheLiveGuideKnowsWhatToAimFor =>
      'Add a goal so the live guide knows what to aim for.';

  @override
  String get eventSuccessEventSuccessHostSetupTitleBeforeLaunch =>
      'Before launch';

  @override
  String get eventSuccessEventSuccessHostSetupTextUnsavedChanges =>
      'Unsaved changes';

  @override
  String eventSuccessEventSuccessHostSharedLabelLengthTools({
    required Object length,
  }) {
    return '$length tools';
  }

  @override
  String get eventSuccessEventSuccessHostSharedLabelNotSaved => 'Not saved';

  @override
  String eventSuccessEventSuccessHostSharedLabelLengthSelected({
    required Object length,
  }) {
    return '$length selected';
  }

  @override
  String get eventSuccessEventSuccessHostSharedTextMatchClueQuestions =>
      'Match clue questions';

  @override
  String get eventSuccessEventSuccessHostSharedLabelCanGuidePairings =>
      'Can guide pairings';

  @override
  String get eventSuccessEventSuccessHostSharedLabelCluesOnly => 'Clues only';

  @override
  String get eventSuccessEventSuccessHostSharedTextSuggestedPairingsCanUse =>
      'Suggested pairings can use shared answers as one light input after interest, safety, and attendee opt-out checks.';

  @override
  String get eventSuccessEventSuccessHostSharedTextAnswersCanStillShape =>
      'Answers can still shape reveal clues, but suggested pairings will not use them.';

  @override
  String get eventSuccessEventSuccessHostSharedTextHelpMeSayHi =>
      '\"Help me say hi\" requests';

  @override
  String eventSuccessEventSuccessHostSharedLabelLengthActive({
    required Object length,
  }) {
    return '$length active';
  }

  @override
  String
  get eventSuccessEventSuccessHostSharedTextAttendeesExplicitlyAskedThe =>
      'Attendees explicitly asked the host for help. Use rotation edits or live facilitation to pair them safely.';

  @override
  String
  get eventSuccessEventSuccessHostSharedTextAttendeesExplicitlyAskedThef44110 =>
      'Attendees explicitly asked the host for help. Use this as live facilitation context.';

  @override
  String get eventSuccessEventSuccessHostSharedTextNoHostHelpRequests =>
      'No host-help requests yet.';

  @override
  String get eventSuccessEventSuccessHostSharedLabelHostVisible =>
      'Host visible';

  @override
  String
  get eventSuccessEventSuccessLiveRevealActionsLabelGenerateAssignmentsFirst =>
      'Generate assignments first';

  @override
  String get eventSuccessEventSuccessLiveRevealActionsLabelRevealNow =>
      'Reveal now';

  @override
  String get eventSuccessEventSuccessLiveRevealActionsLabelReset => 'Reset';

  @override
  String get eventSuccessEventSuccessLiveRevealActionsLabelResetReveal =>
      'Reset reveal';

  @override
  String eventSuccessEventSuccessLiveRevealActionsLabelRevealRoundValue1({
    required Object value1,
  }) {
    return 'Reveal round $value1';
  }

  @override
  String
  eventSuccessEventSuccessLiveRevealActionsLabelDropCountdownsecondsSCountdown({
    required Object countdownSeconds,
  }) {
    return 'Drop ${countdownSeconds}s countdown';
  }

  @override
  String get eventSuccessEventSuccessLiveRevealAttendeeLabelUnlocking =>
      'Unlocking';

  @override
  String get eventSuccessEventSuccessLiveRevealAttendeeLabelRevealed =>
      'Revealed';

  @override
  String get eventSuccessEventSuccessLiveRevealAttendeeLabelWaiting =>
      'Waiting';

  @override
  String
  get eventSuccessEventSuccessLiveRevealHostLabelSynchronizedPartnerReveal =>
      'Synchronized partner reveal';

  @override
  String get eventSuccessEventSuccessLiveRevealHostLabelNoAssignments =>
      'No assignments';

  @override
  String eventSuccessEventSuccessLiveRevealHostLabelValue1RoundcountShown({
    required Object value1,
    required Object roundCount,
  }) {
    return '$value1/$roundCount shown';
  }

  @override
  String get eventSuccessEventSuccessLiveRevealHostCaptionSeconds => 'seconds';

  @override
  String get eventSuccessEventSuccessLiveRevealHostCaptionRevealed =>
      'revealed';

  @override
  String get eventSuccessEventSuccessLiveRevealHostCaptionNextRound =>
      'next round';

  @override
  String get eventSuccessEventSuccessLiveRevealWidgetsLabelRoomHold =>
      'Room hold';

  @override
  String
  eventSuccessEventSuccessLiveRevealWidgetsTextEveryoneGetsThisAssignmentnoun({
    required Object assignmentNoun,
  }) {
    return 'Everyone gets this $assignmentNoun at the same time. No names shown yet.';
  }

  @override
  String eventSuccessEventSuccessLiveRevealWidgetsTextSeconds({
    required Object seconds,
  }) {
    return '$seconds';
  }

  @override
  String get eventSuccessEventSuccessLiveRevealWidgetsTextSeconds3fb8f1 =>
      'SECONDS';

  @override
  String get eventSuccessEventSuccessLiveRevealWidgetsLabelHold => 'Hold';

  @override
  String get eventSuccessEventSuccessLiveRevealWidgetsLabelWatch => 'Watch';

  @override
  String get eventSuccessEventSuccessLiveRevealWidgetsLabelMove => 'Move';

  @override
  String get eventSuccessEventSuccessLiveRevealWidgetsTitleNoNamesShownYet =>
      'No names shown yet';

  @override
  String
  get eventSuccessEventSuccessLiveRevealWidgetsBodyPartnerDetailsStayLocked =>
      'Partner details stay locked until the shared release.';

  @override
  String get eventSuccessEventSuccessLiveRevealWidgetsTitleClueIsLive =>
      'Clue is live';

  @override
  String get eventSuccessEventSuccessLiveRevealWidgetsTextTheRoomIsHolding =>
      'The room is holding for the reveal.';

  @override
  String eventSuccessEventSuccessLiveRevealWidgetsTextTheHostControlsThe({
    required Object assignmentNoun,
  }) {
    return 'The host controls the $assignmentNoun unlock from live mode.';
  }

  @override
  String get eventSuccessEventSuccessLiveRevealWidgetsTitleUnlockedTogether =>
      'Unlocked together';

  @override
  String eventSuccessEventSuccessLiveRevealWidgetsLabelValue1People({
    required Object value1,
  }) {
    return '$value1 people';
  }

  @override
  String get eventSuccessEventSuccessLiveRevealWidgetsLabelLoadingPodmates =>
      'Loading podmates';

  @override
  String get eventSuccessEventSuccessLiveRevealWidgetsLabelLoadingPartners =>
      'Loading partners';

  @override
  String
  get eventSuccessEventSuccessLiveRevealWidgetsLabelLoadingGroupMembers =>
      'Loading group members';

  @override
  String get eventSuccessEventSuccessLiveRevealWidgetsLabelNamesLoading =>
      'Names loading';

  @override
  String eventSuccessEventSuccessLiveRevealWidgetsTextTimerangePeername({
    required Object timeRange,
    required Object peerName,
  }) {
    return '$timeRange · $peerName';
  }

  @override
  String get eventSuccessEventSuccessLiveRevealWidgetsLabelHiddenUntilReveal =>
      'Hidden until reveal';

  @override
  String eventSuccessEventSuccessLiveRevealWidgetsLabelRoundValue1({
    required Object value1,
  }) {
    return 'Round $value1';
  }

  @override
  String eventSuccessEventSuccessLiveRevealWidgetsTextRValue1({
    required Object value1,
  }) {
    return 'R$value1';
  }

  @override
  String eventSuccessEventSuccessLiveRevealWidgetsLabelRValue1({
    required Object value1,
  }) {
    return 'R$value1';
  }

  @override
  String eventsEventJoinedCelebrationScreenMessageWithClubname({
    required Object clubName,
  }) {
    return 'with $clubName';
  }

  @override
  String get hostsEditHostedEventRouteScreenTitleEditEvent => 'Edit event';

  @override
  String get hostsEditHostedEventRouteScreenTitleEventNotFound =>
      'Event not found';

  @override
  String get hostsEditHostedEventRouteScreenMessageThisHostedEventIs =>
      'This hosted event is no longer available.';

  @override
  String get hostsEditHostedEventRouteScreenTitleActionUnavailable =>
      'Action unavailable';

  @override
  String get hostsEditHostedEventRouteScreenMessageYouCanEditOnly =>
      'You can edit only events that you host.';

  @override
  String get hostsHostEventManageRouteScreenTitleManageEvent => 'Manage event';

  @override
  String get hostsHostEventManageRouteScreenTitleEventNotFound =>
      'Event not found';

  @override
  String get hostsHostEventManageRouteScreenMessageThisHostedEventIs =>
      'This hosted event is no longer available.';

  @override
  String get hostsHostEventManageRouteScreenTitleActionUnavailable =>
      'Action unavailable';

  @override
  String get hostsHostEventManageRouteScreenMessageYouCanManageOnly =>
      'You can manage only events that you host.';

  @override
  String get hostsHostClubTeamScreenTitleSignOut => 'Sign out';

  @override
  String get hostsHostClubTeamScreenLabelEdit => 'Edit';

  @override
  String get hostsHostClubTeamScreenLabelPreview => 'Preview';

  @override
  String get hostsHostClubTeamScreenTitleProfile => 'Profile';

  @override
  String get hostsHostClubTeamScreenTitleDisplayName => 'Display name';

  @override
  String get hostsHostClubTeamScreenTitleRoleTitle => 'Role title';

  @override
  String get hostsHostClubTeamScreenTitleStatus => 'Status';

  @override
  String get hostsHostClubTeamScreenTitleAboutYouAsA => 'About you as a host';

  @override
  String get hostsHostClubTeamScreenTitleClubsYouHost => 'Organizers you host';

  @override
  String get hostsHostClubTeamScreenTextNoHostClubsYet =>
      'No hosted organizers yet.';

  @override
  String get hostsHostAnalyticsLabelAllEvents => 'All events';

  @override
  String get hostsHostAnalyticsLabel30Days => '30 days';

  @override
  String get hostsHostAnalyticsLabel90Days => '90 days';

  @override
  String get hostsHostAnalyticsLabel12Months => '12 months';

  @override
  String hostsHostAnalyticsTextUpdatedRelative({required Object relative}) {
    return 'Updated $relative';
  }

  @override
  String get hostsHostAnalyticsTextSomeDataIsStillSyncingNumbersMayUpdate =>
      'Some data is still syncing — numbers may update.';

  @override
  String get hostsHostAnalyticsLabelAllTime => 'All time';

  @override
  String get hostsHostAnalyticsLabelPerformancePeriod => 'Performance period';

  @override
  String get hostsHostAnalyticsLabelPerformance => 'Performance';

  @override
  String get hostsHostAnalyticsLabelProfileAndEventViews =>
      'Profile & event views';

  @override
  String get hostsHostAnalyticsLabelProfileViews => 'Profile views';

  @override
  String get hostsHostAnalyticsLabelEventViews => 'Event views';

  @override
  String get hostsHostAnalyticsLabelAttendanceRate => 'Attendance rate';

  @override
  String get hostsHostAnalyticsLabelRevenue => 'Revenue';

  @override
  String get hostsHostAnalyticsLabelConnections => 'Connections';

  @override
  String get hostsHostAnalyticsLabelCheckoutDropOff => 'Checkout drop-off';

  @override
  String get hostsHostAnalyticsLabelCheckoutConversion => 'Checkout conversion';

  @override
  String get hostsHostAnalyticsLabelChatsStarted => 'Chats started';

  @override
  String get hostsHostAnalyticsLabelMoreMetrics => 'More metrics';

  @override
  String get hostsHostAnalyticsBodyCheckoutChatsAndSaves =>
      'Checkout, chats and saves';

  @override
  String get hostsHostAnalyticsLabelPartial => 'Partial';

  @override
  String get hostsHostAnalyticsLabelMissing => 'Missing';

  @override
  String hostsHostAnalyticsTextDirectionPercentVsPreviousPeriod({
    required Object direction,
    required Object percent,
    required Object period,
  }) {
    return '$direction $percent% vs previous $period';
  }

  @override
  String get hostsHostAnalyticsTextNoAnalyticsInThisRange =>
      'No analytics in this range.';

  @override
  String hostsHostAnalyticsTextPeriodDemandBookings({
    required Object period,
    required Object demand,
    required Object bookings,
  }) {
    return '$period: $demand demand · $bookings bookings';
  }

  @override
  String get hostsHostAnalyticsLabelRecentEvents => 'Recent events';

  @override
  String get hostsHostAnalyticsLabelPaymentIssues => 'Payment issues';

  @override
  String hostsHostAnalyticsTextBookedAttendedMatches({
    required Object booked,
    required Object attended,
    required Object matches,
  }) {
    return '$booked booked · $attended attended · $matches matches';
  }

  @override
  String hostsHostAnalyticsTextEventDateStatus({
    required Object date,
    required Object status,
  }) {
    return '$date · $status';
  }

  @override
  String get hostsHostAnalyticsLabelReviews => 'Reviews';

  @override
  String get hostsHostAnalyticsLabelPublishedReviews => 'Published reviews';

  @override
  String get hostsHostAnalyticsStatusLive => 'Live';

  @override
  String get hostsHostAnalyticsStatusActive => 'Active';

  @override
  String get hostsHostAnalyticsStatusOpen => 'Open';

  @override
  String get hostsHostAnalyticsStatusPublished => 'Published';

  @override
  String get hostsHostAnalyticsStatusCompleted => 'Completed';

  @override
  String get hostsHostAnalyticsStatusPast => 'Past';

  @override
  String get hostsHostAnalyticsStatusDraft => 'Draft';

  @override
  String get hostsHostAnalyticsStatusPending => 'Pending';

  @override
  String get hostsHostAnalyticsStatusScheduled => 'Scheduled';

  @override
  String get hostsHostAnalyticsStatusCancelled => 'Cancelled';

  @override
  String get hostsHostAnalyticsLabelTrendBookingsVsDemand =>
      'Trend · bookings vs demand';

  @override
  String get hostsHostAnalyticsLabelDemand => 'Demand';

  @override
  String get hostsHostAnalyticsLabelBookings => 'Bookings';

  @override
  String get hostsHostAnalyticsTextNoEventsInThis => 'No events in this range.';

  @override
  String get hostsHostAnalyticsLabelNewReviews => 'New reviews';

  @override
  String get hostsHostAnalyticsLabelAverageRating => 'Average rating';

  @override
  String get hostsHostAnalyticsLabelEventSaves => 'Event saves';

  @override
  String get hostsHostAnalyticsLabelResponses => 'Responses';

  @override
  String get hostsHostAnalyticsTitleCoach => 'Coach';

  @override
  String get hostsHostAnalyticsCoachAttendance =>
      'Almost half your bookings didn\'t show. Reminders and check-in help — see how your last event ran.';

  @override
  String get hostsHostAnalyticsCoachCheckoutDropoff =>
      'Lots of people started paying and stopped. Review your price or enable demand pricing.';

  @override
  String hostsHostAnalyticsCoachDemandCapacity({required String event}) {
    return 'Demand outran capacity on $event. Consider a bigger venue or a second date.';
  }

  @override
  String get hostsHostAnalyticsCoachNoRepeatAttendees =>
      'No repeat attendees this period. Organizer posts and follows help people come back.';

  @override
  String get hostsHostAuthRequiredScreenTitleSignInRequired =>
      'Sign in required';

  @override
  String get hostsHostAuthRequiredScreenMessageSignInToManage =>
      'Sign in to manage host operations.';

  @override
  String get hostsHostClubProfileTitleIdentity => 'Identity';

  @override
  String get hostsHostClubProfileTitleMedia => 'Media';

  @override
  String
  hostsHostClubProfileVisiblecopyCompletedcountOfMaximumclubphotocountAdded({
    required Object completedCount,
    required Object maximumClubPhotoCount,
  }) {
    return '$completedCount of $maximumClubPhotoCount added';
  }

  @override
  String get hostsHostClubProfileLabelClubName => 'Organizer name';

  @override
  String get hostsHostClubProfileLabelCity => 'City';

  @override
  String get hostsHostClubProfileLabelAreaNeighbourhood =>
      'Area / neighbourhood';

  @override
  String get hostsHostClubProfileLabelDescription => 'Description';

  @override
  String get hostsHostClubProfileTitleContact => 'Contact';

  @override
  String get hostsHostClubProfileLabelInstagram => 'Instagram';

  @override
  String get hostsHostClubProfilePlaceholderYourclub => '@yourclub';

  @override
  String get hostsHostClubProfileLabelPhone => 'Phone';

  @override
  String get hostsHostClubProfileLabelEmail => 'Email';

  @override
  String get hostsHostClubProfilePlaceholderHelloYourclubCom =>
      'hello@yourclub.com';

  @override
  String get hostsHostClubEditTabTitleClubSettings => 'Organizer settings';

  @override
  String get hostsHostClubEditTabLabelEventDefaults => 'Event defaults';

  @override
  String get hostsHostClubEditTabLabelLiveEventGuide => 'Live event guide';

  @override
  String get hostsHostClubEditTabLabelPayments => 'Payments';

  @override
  String get hostsHostClubEditTabLabelHostTeam => 'Host team';

  @override
  String get hostsHostClubEditTabValueOn => 'On';

  @override
  String get hostsHostClubEditTabValueOff => 'Off';

  @override
  String hostsHostClubEditTabValueHostCount({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hosts',
      one: '1 host',
    );
    return '$_temp0';
  }

  @override
  String get hostsHostClubProfileTitleDefaultActivity => 'Default activity';

  @override
  String get hostsHostClubProfileTitleAdmission => 'Admission';

  @override
  String get hostsHostClubProfileTitleAgeRange => 'Age range';

  @override
  String get hostsHostClubProfileTitleCancellationPolicy =>
      'Cancellation policy';

  @override
  String get hostsHostClubsScaffoldKickerHostClubs => 'HOST ORGANIZERS';

  @override
  String get hostsHostClubsScaffoldLabelClubWorkspaceTabs =>
      'Organizer workspace tabs';

  @override
  String get hostsHostClubsScaffoldBodyDragLeftOrRight =>
      'Drag left or right to switch between Edit, Insights, and Preview.';

  @override
  String get hostsHostClubsScaffoldLabelEdit => 'Edit';

  @override
  String get hostsHostClubsScaffoldLabelInsights => 'Insights';

  @override
  String get hostsHostClubsScaffoldLabelPreview => 'Preview';

  @override
  String get hostsHostClubsScaffoldTooltipSwitchClub => 'Switch organizer';

  @override
  String get hostsHostClubsScaffoldTitleNoHostClubsYet =>
      'No hosted organizers yet';

  @override
  String get hostsHostClubsScaffoldBodyCreateAClubOr =>
      'Create an organizer or accept a host invite to start managing events.';

  @override
  String get hostsHostClubsScaffoldLabelCreateClub => 'Create organizer';

  @override
  String get hostsHostClubsScreenTitleClubs => 'Organizers';

  @override
  String get hostsHostEventsListTextEvents => 'Events';

  @override
  String get hostsHostEventsListLabelNewEvent => 'New event';

  @override
  String get hostsHostEventsListTextLive => 'LIVE';

  @override
  String get hostsHostEventsListTextToday => 'TODAY';

  @override
  String get hostsHostEventsScaffoldTitleCreateYourFirstClub =>
      'Create your first organizer';

  @override
  String get hostsHostEventsScaffoldBodyCreateAClubTo =>
      'Create an organizer to publish events, manage attendees, and run Event Success.';

  @override
  String get hostsHostEventsScaffoldLabelCreateClub => 'Create organizer';

  @override
  String get hostsHostOperationsHomeScreenTitleHostEvents => 'Host events';

  @override
  String get hostsHostOrganizerLabelMembers => 'Followers';

  @override
  String hostsHostOrganizerLabelRatingReviewcountReviews({
    required Object reviewCount,
  }) {
    return 'Rating · $reviewCount reviews';
  }

  @override
  String get hostsHostOrganizerLabelRating => 'Rating';

  @override
  String get hostsHostOrganizerLabelEventsHosted => 'Events hosted';

  @override
  String get hostsHostOrganizerLabelUpcoming => 'Upcoming';

  @override
  String get hostsHostTodayTitleNoActiveEventsYet => 'No active events yet';

  @override
  String hostsHostTodayBodyCreateAnEventFor({required Object name}) {
    return 'Create an event for $name to start filling the host dashboard.';
  }

  @override
  String get hostsHostTodayLabelNewEvent => 'New event';

  @override
  String get hostsHostTodayLabelEvents => 'Events';

  @override
  String get hostsHostTodayTitleNeedsYou => 'Needs you';

  @override
  String get hostsHostTodayTextNothingNeedsYouRight =>
      'Nothing needs you right now.';

  @override
  String get hostsHostTodayTitleLaterThisWeek => 'Later this week';

  @override
  String get hostsHostTodayLabelAllEvents => 'All events';

  @override
  String hostsHostTodayTextLongweekdayDaypart({
    required Object longWeekday,
    required Object daypart,
  }) {
    return '$longWeekday $daypart';
  }

  @override
  String hostsHostTodayTextGoodDaypartHostname({
    required Object daypart,
    required Object hostName,
  }) {
    return 'Good $daypart,\n$hostName';
  }

  @override
  String get hostsHostTodayTooltipSwitchClub => 'Switch organizer';

  @override
  String hostsHostTodayTextEventdaylabelTime({
    required Object eventDayLabel,
    required Object time,
  }) {
    return '$eventDayLabel · $time';
  }

  @override
  String get hostsHostTodayLabelGoing => 'Going';

  @override
  String get hostsHostTodayLabelWaiting => 'Waiting';

  @override
  String get hostsHostTodayLabelNeedsYou => 'Needs you';

  @override
  String get hostsHostTodayLabelOpenRunOfShow => 'Open run-of-show';

  @override
  String get hostsHostTodayLabelSetUpRun => 'Set up & run';

  @override
  String get hostsHostTodayLabelD => 'D';

  @override
  String get hostsHostTodayLabelM => 'M';

  @override
  String get coreBlockUserDialogMessageYouWillStopSeeing =>
      'You will stop seeing each other in chats, matches, Catches, and future event slots where the other person is already booked.';

  @override
  String get coreCatchFrameworkErrorViewTextThisScreenHitA =>
      'This screen hit a temporary app error. Please go back or try again in a moment.';

  @override
  String dashboardEventFocusRailLabelShortweekdayDayShortmonthTimerangelabel({
    required Object shortWeekday,
    required Object day,
    required Object shortMonth,
    required Object timeRangeLabel,
  }) {
    return '$shortWeekday, $day $shortMonth · $timeRangeLabel';
  }

  @override
  String eventSuccessEventSuccessCompanionSharedLabelAdmitOneNoPadleft({
    required Object padLeft,
    required Object capacity,
  }) {
    return 'ADMIT ONE - NO $padLeft / $capacity';
  }

  @override
  String get eventSuccessEventSuccessCompanionWingmanTextThisAttendee =>
      'this attendee';

  @override
  String get eventSuccessEventSuccessHostReportBodyThePostEventReport =>
      'The post-event report appears once checked-in attendees share feedback. There is no signal to summarize yet.';

  @override
  String get eventSuccessEventSuccessHostReportTitleS => 's';

  @override
  String get eventsBookingConflictSheetTextYouReAlreadyBooked =>
      'You\'re already booked for something then. Keep both if you can make it work, or swap one out.';

  @override
  String get exploreExploreScreenMessageTryAnotherCityFrom =>
      'Try another city from the location control, or create the first organizer when you are ready to host.';

  @override
  String get exploreExploreListMessageTryAnotherCityFrom =>
      'Try another city from the location control, or create the first organizer when you are ready to host.';

  @override
  String get forceUpdateUpdateRequiredScreenTextANewVersionOf =>
      'A new version of Catch is available. Please update to continue.';

  @override
  String hostsHostEventToolsLabelSignedupcountCapacitylimitBookedWaitlistcount({
    required Object signedUpCount,
    required Object capacityLimit,
    required Object waitlistCount,
  }) {
    return '$signedUpCount/$capacityLimit booked · $waitlistCount waitlist';
  }

  @override
  String get onboardingWelcomePageTextShowUpToSomething =>
      'Show up to something you\'d do anyway — a long run, a long table, trivia night. Match only with the people who were actually there.';

  @override
  String
  paymentsPaymentConfirmationScreenTextLongdatelabelTimerangelabelLocationnamePriceinpaise({
    required Object longDateLabel,
    required Object timeRangeLabel,
    required Object locationName,
    required Object priceInPaise,
    required Object capacityLimit,
  }) {
    return '$longDateLabel · $timeRangeLabel · $locationName. $priceInPaise · $capacityLimit spots.';
  }

  @override
  String paymentsPaymentConfirmationScreenMessageProviderlabelDidNotComplete({
    required Object providerLabel,
  }) {
    return '$providerLabel did not complete this booking. If money moved, it stays visible in payment history while support resolves it.';
  }

  @override
  String paymentsPaymentConfirmationScreenMessageFinishPaymentInProviderlabel({
    required Object providerLabel,
    required Object providerLabel2,
  }) {
    return 'Finish payment in $providerLabel. Your spot is reserved only after $providerLabel2 confirms the payment and Catch writes the booking.';
  }

  @override
  String get paymentsPaymentConfirmationScreenTextBringAWaterBottle =>
      'Bring a water bottle and arrive by the meeting time. Catches unlock automatically when the event finishes — keep your phone charged.';

  @override
  String get safetySettingsScreenMessageThisRemovesYourPublic =>
      'This removes your public profile, signs you out, and keeps only the minimal records required for safety and payment history.';

  @override
  String get onboardingOnboardingStepTitleWelcome => 'Welcome';

  @override
  String get onboardingOnboardingStepTitleWhatSYourName => 'What\'s your name?';

  @override
  String get onboardingOnboardingStepSubtitleLastNameStaysPrivate =>
      'Last name stays private until you catch.';

  @override
  String get onboardingOnboardingStepTitleHowDoYouIdentify =>
      'How do you identify?';

  @override
  String get onboardingOnboardingStepTitleYourInstagram => 'Your Instagram';

  @override
  String get onboardingOnboardingStepSubtitleHelpsUsVerifyYou =>
      'Helps us verify you for early access. Your handle is never shown to other users.';

  @override
  String get onboardingOnboardingStepTitleCompleteYourProfileFor =>
      'Complete your profile for Catches';

  @override
  String get onboardingOnboardingStepSubtitleCatchesNeedPhotosSo =>
      'Catches need photos so people can decide who they want to meet. You can still book events with your current details.';

  @override
  String get onboardingOnboardingStepTitleShowYourself => 'Show yourself';

  @override
  String get onboardingOnboardingStepSubtitleAddAtLeast2 =>
      'Add at least 2 photos so others can find you.';

  @override
  String get onboardingOnboardingStepTitleAddPromptsToStart =>
      'Add prompts to start catching';

  @override
  String get onboardingOnboardingStepSubtitlePromptsGivePeopleSomething =>
      'Prompts give people something real to respond to before you match.';

  @override
  String get onboardingOnboardingStepTitleShowYourPersonality =>
      'Show your personality';

  @override
  String get onboardingOnboardingStepSubtitleAnswer3PromptsTo =>
      'Answer 3 prompts to complete your profile.';

  @override
  String get onboardingOnboardingStepTitleFinishYourCatchesProfile =>
      'Finish your Catches profile';

  @override
  String get onboardingOnboardingStepSubtitleTheseAreOptionalBut =>
      'These are optional, but they help us rank compatible people in Catches.';

  @override
  String get onboardingOnboardingStepTitleSetYourRunPreferences =>
      'Set your run preferences';

  @override
  String get onboardingOnboardingStepSubtitleWeOnlyAskFor =>
      'We only ask for these before run events so hosts can plan pace groups and distances.';

  @override
  String get onboardingOnboardingStepTitleYourRunningStyle =>
      'Your running style';

  @override
  String get onboardingOnboardingStepSubtitleHelpUsFindCompatible =>
      'Help us find compatible running partners.';

  @override
  String get userProfileSelfProfileEditTabStateLabelDisplayName =>
      'Display name';

  @override
  String get userProfileSelfProfileEditTabStateLabelDateOfBirth =>
      'Date of birth';

  @override
  String userProfileSelfProfileEditTabStateBodyPadleftPadleft2YearAgeon({
    required Object padLeft,
    required Object padLeft2,
    required Object year,
    required Object ageOn,
  }) {
    return '$padLeft/$padLeft2/$year  ($ageOn years)';
  }

  @override
  String get userProfileSelfProfileEditTabStateLabelGender => 'Gender';

  @override
  String get userProfileSelfProfileEditTabStateLabelPhone => 'Phone';

  @override
  String get userProfileSelfProfileEditTabStateLabelEmail => 'Email';

  @override
  String get userProfileSelfProfileEditTabStateLabelInstagram => 'Instagram';

  @override
  String get userProfileSelfProfileEditTabStateLabelHeight => 'Height';

  @override
  String get userProfileSelfProfileEditTabStateLabelCity => 'City';

  @override
  String get userProfileSelfProfileEditTabStateLabelJobTitle => 'Job title';

  @override
  String get userProfileSelfProfileEditTabStateLabelCompany => 'Company';

  @override
  String get userProfileSelfProfileEditTabStateLabelEducation => 'Education';

  @override
  String get userProfileSelfProfileEditTabStateLabelReligion => 'Religion';

  @override
  String get userProfileSelfProfileEditTabStateLabelLanguages => 'Languages';

  @override
  String get userProfileSelfProfileEditTabStateLabelLookingFor => 'Looking for';

  @override
  String get userProfileSelfProfileEditTabStateLabelPaceRange => 'Pace range';

  @override
  String get userProfileSelfProfileEditTabStateLabelPreferredDistances =>
      'Preferred distances';

  @override
  String get userProfileSelfProfileEditTabStateLabelWhyIEvent => 'Why I event';

  @override
  String get userProfileSelfProfileEditTabStateLabelFavoriteEventTimes =>
      'Favorite event times';

  @override
  String get userProfileSelfProfileEditTabStateLabelDrinking => 'Drinking';

  @override
  String get userProfileSelfProfileEditTabStateLabelSmoking => 'Smoking';

  @override
  String get userProfileSelfProfileEditTabStateLabelWorkout => 'Workout';

  @override
  String get userProfileSelfProfileEditTabStateLabelDiet => 'Diet';

  @override
  String get userProfileSelfProfileEditTabStateLabelChildren => 'Children';

  @override
  String get eventsEventDetailScreenStateLabelPaidBookingUnavailable =>
      'Paid booking unavailable';

  @override
  String get eventsEventDetailScreenStateLabelAcceptSpot => 'Accept spot';

  @override
  String get eventsEventDetailScreenStateLabelAcceptSpotAndPay =>
      'Accept spot and pay';

  @override
  String get eventsEventDetailScreenStateLabelSetRunPreferences =>
      'Set run preferences';

  @override
  String get eventsEventDetailScreenStateLabelRequestToJoin =>
      'Request to join';

  @override
  String get eventsEventDetailScreenStateLabelJoinWaitlist => 'Join waitlist';

  @override
  String get eventsEventDetailScreenStateLabelWithdrawRequest =>
      'Withdraw request';

  @override
  String get eventsEventDetailScreenStateLabelLeaveWaitlist => 'Leave waitlist';

  @override
  String get eventsEventDetailScreenStateLabelYouAttendedThisEvent =>
      'You attended this event';

  @override
  String get eventsEventDetailScreenStateLabelThisEventHasEnded =>
      'This event has ended';

  @override
  String eventsEventDetailScreenStateLabelMustBeMinageTo({
    required Object minAge,
  }) {
    return 'Must be $minAge+ to join';
  }

  @override
  String eventsEventDetailScreenStateLabelMustBeMaxageOr({
    required Object maxAge,
  }) {
    return 'Must be $maxAge or younger';
  }

  @override
  String get eventsEventDetailScreenStateLabelInviteRequired =>
      'Invite required';

  @override
  String get eventsEventDetailScreenStateLabelRequestRequired =>
      'Request required';

  @override
  String get eventsEventDetailScreenStateLabelSpotsForYourGender =>
      'Spots for your gender are full';

  @override
  String get eventsEventDetailScreenStateLabelNotEligibleForThis =>
      'Not eligible for this event';

  @override
  String get eventsEventDetailScreenStateLabelJoinApprovedEvent =>
      'Join approved event';

  @override
  String get eventsEventDetailScreenStateLabelCompleteApprovedBooking =>
      'Complete approved booking';

  @override
  String eventsEventDetailScreenStateLabelJoinEventJoinctaavailabilitylabel({
    required Object joinCtaAvailabilityLabel,
  }) {
    return 'Join event — $joinCtaAvailabilityLabel';
  }

  @override
  String get eventsEventDetailScreenStateLabelBookEvent => 'Book event';

  @override
  String get eventsEventDetailScreenStateLabelCancelBooking => 'Cancel booking';

  @override
  String get coreEventActivityVisualsLabelSocialRun => 'Social run';

  @override
  String get coreEventActivityVisualsLabelRunning => 'Running';

  @override
  String get coreEventActivityVisualsLabelWalking => 'Walking';

  @override
  String get coreEventActivityVisualsLabelPickleball => 'Pickleball';

  @override
  String get coreEventActivityVisualsLabelPadel => 'Padel';

  @override
  String get coreEventActivityVisualsLabelTennis => 'Tennis';

  @override
  String get coreEventActivityVisualsLabelBadminton => 'Badminton';

  @override
  String get coreEventActivityVisualsLabelCycling => 'Cycling';

  @override
  String get coreEventActivityVisualsLabelSpinClass => 'Spin class';

  @override
  String get coreEventActivityVisualsLabelYoga => 'Yoga';

  @override
  String get coreEventActivityVisualsLabelStrength => 'Strength';

  @override
  String get coreEventActivityVisualsLabelDinner => 'Dinner';

  @override
  String get coreEventActivityVisualsLabelPubQuiz => 'Pub quiz';

  @override
  String get coreEventActivityVisualsLabelBarCrawl => 'Bar crawl';

  @override
  String get coreEventActivityVisualsLabelSinglesMixer => 'Singles mixer';

  @override
  String get coreEventActivityVisualsLabelOpenFormat => 'Open format';

  @override
  String eventSuccessEventSuccessCompanionScreenStateBodyWhenCheckInOpens({
    required Object locationName,
  }) {
    return 'When check-in opens, this screen turns into the live guide for $locationName.';
  }

  @override
  String get eventSuccessEventSuccessCompanionScreenStateBodyOneTapTellsThe =>
      'One tap tells the host you are in the room and ready for the live flow.';

  @override
  String get eventSuccessEventSuccessCompanionScreenStateBodyFindOnePersonAsk =>
      'Find one person, ask one tiny question, and let the room start with permission instead of pressure.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateBodyQuickAnswersHelpCatch =>
      'Quick answers help Catch shape prompts without turning the event into a form.';

  @override
  String get eventSuccessEventSuccessCompanionScreenStateBodyTheHostIsPacing =>
      'The host is pacing the room from live mode.';

  @override
  String get eventSuccessEventSuccessCompanionScreenStateBodyUseItIfThe =>
      'Use it if the room needs an easy next line.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateBodyTheseAreLightNudges =>
      'These are light nudges for the current event moment.';

  @override
  String get eventSuccessEventSuccessCompanionScreenStateBodyUseItAsA =>
      'Use it as a nudge into the next interaction, then let the room breathe.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateBodyTheHostControlsThe =>
      'The host controls the timing so the room unlocks together instead of leaking awkwardly.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateBodyChooseSomeoneYouWant =>
      'Choose someone you want help meeting and the host can use that as live facilitation context.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateBodyKeepTheUsefulParts =>
      'Keep the useful parts of the room, send private feedback, and use event-specific openers when a match appears.';

  @override
  String get eventSuccessEventSuccessCompanionScreenStateBodyTheHostIsRunning =>
      'The host is running the room. Your next prompt or reveal appears here when it is time.';

  @override
  String get eventSuccessEventSuccessCompanionScreenStateTitleEventNotFound =>
      'Event not found';

  @override
  String get eventSuccessEventSuccessCompanionScreenStateMessageThisEventIsNo =>
      'This event is no longer available.';

  @override
  String get eventSuccessEventSuccessCompanionScreenStateTitleSignInRequired =>
      'Sign in required';

  @override
  String get eventSuccessEventSuccessCompanionScreenStateMessageSignInToOpen =>
      'Sign in to open your event companion.';

  @override
  String get eventSuccessEventSuccessCompanionScreenStateTitleNoBookingFound =>
      'No booking found';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateMessageBookThisEventBefore =>
      'Book this event before opening the companion.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateTitleCompanionNotAvailable =>
      'Companion not available';

  @override
  String get eventSuccessEventSuccessCompanionScreenStateMessageTheHostHasNot =>
      'The host has not enabled the live event guide for this event yet.';

  @override
  String get paymentsPaymentHistoryScreenLabelRefunded => 'Refunded';

  @override
  String get paymentsPaymentHistoryScreenDetailBookingFailedButYour =>
      'Booking failed, but your payment was refunded.';

  @override
  String get paymentsPaymentHistoryScreenLabelRefundPending => 'Refund pending';

  @override
  String get paymentsPaymentHistoryScreenDetailNoSpotWasReserved =>
      'No spot was reserved and the refund needs attention. Please contact support.';

  @override
  String get paymentsPaymentHistoryScreenLabelBookingFailed => 'Booking failed';

  @override
  String get paymentsPaymentHistoryScreenDetailNoSpotWasReservedd0a580 =>
      'No spot was reserved. Refund may still be pending.';

  @override
  String get paymentsPaymentHistoryScreenLabelPaid => 'Paid';

  @override
  String get paymentsPaymentHistoryScreenLabelFailed => 'Failed';

  @override
  String get paymentsPaymentHistoryScreenDetailYourRefundNeedsAttention =>
      'Your refund needs attention. Please contact support.';

  @override
  String get paymentsPaymentHistoryScreenLabelPending => 'Pending';

  @override
  String get swipesSwipeEmptyContentTitleNoMoreAttendees => 'No more attendees';

  @override
  String get swipesSwipeEmptyContentMessageJoinMoreEventsTo =>
      'Join more events to meet new people';

  @override
  String get swipesSwipeEmptyContentTitleCatchUnavailable =>
      'Catch unavailable';

  @override
  String get swipesSwipeEmptyContentMessageThisEventCouldNot =>
      'This event could not be found.';

  @override
  String get swipesSwipeEmptyContentTitleSignInRequired => 'Sign in required';

  @override
  String get swipesSwipeEmptyContentMessageSignInAgainTo =>
      'Sign in again to catch fellow attendees.';

  @override
  String get swipesSwipeEmptyContentMessageYouCanOnlyCatch =>
      'You can only catch attendees from events you attended.';

  @override
  String get swipesSwipeEmptyContentTitleEventInProgress => 'Event in progress';

  @override
  String get swipesSwipeEmptyContentMessageCatchesUnlockFor24 =>
      'Catches unlock for 24 hours after the event finishes.';

  @override
  String get swipesSwipeEmptyContentTitleCatchWindowClosed =>
      'Catch window closed';

  @override
  String get swipesSwipeEmptyContentMessageThisEventIsPast =>
      'This event is past the 24-hour catch window.';

  @override
  String get reviewsReviewsHistoryViewModelTitleSignInToSee =>
      'Sign in to see reviews';

  @override
  String get reviewsReviewsHistoryViewModelMessageYourPastEventReviews =>
      'Your past event reviews will appear here.';

  @override
  String get reviewsReviewsHistoryViewModelTitleReviewsUnavailable =>
      'Reviews unavailable';

  @override
  String get reviewsReviewsHistoryViewModelMessageCouldNotLoadYour =>
      'Could not load your profile.';

  @override
  String get reviewsReviewsHistoryViewModelMessageCouldNotLoadYourb38403 =>
      'Could not load your reviews.';

  @override
  String get reviewsReviewsHistoryViewModelTitleNoReviewsYet =>
      'No reviews yet';

  @override
  String get reviewsReviewsHistoryViewModelMessageAfterYouReviewA =>
      'After you review a completed event, it will appear here.';

  @override
  String get exploreExploreScreenStateLabelMap => 'Map';

  @override
  String exploreExploreScreenStateSemanticsMapEventCount({
    required int mappableEventCount,
  }) {
    String _temp0 = intl.Intl.pluralLogic(
      mappableEventCount,
      locale: localeName,
      other: '$mappableEventCount events',
      one: '1 event',
    );
    return 'Map, $_temp0';
  }

  @override
  String get exploreExploreScreenStateLabelAny => 'Any';

  @override
  String get exploreExploreScreenStateLabel1Km => '1 km';

  @override
  String get exploreExploreScreenStateLabel3Km => '3 km';

  @override
  String get exploreExploreScreenStateLabel5Km => '5 km';

  @override
  String get exploreExploreScreenStateLabel10Km => '10 km';

  @override
  String get exploreExploreScreenStateCtaViewAndBook => 'View and book';

  @override
  String get exploreExploreScreenStateCtaViewAndRequest => 'View and request';

  @override
  String get exploreExploreScreenStateCtaViewWaitlist => 'View waitlist';

  @override
  String get exploreExploreScreenStateCtaViewEvent => 'View event';

  @override
  String get exploreExploreScreenStateActionlabelOpen => 'Open';

  @override
  String get exploreExploreScreenStateActionlabelNoLink => 'No link';

  @override
  String get exploreExploreScreenStateCaptionClubToKnow => 'Organizer to know';

  @override
  String get exploreExploreScreenStateLabelHostedBy => 'Hosted by';

  @override
  String get exploreExploreScreenStateTitleNoEventsMatchThis =>
      'No events match this search';

  @override
  String get exploreExploreScreenStateMessageClearTheSearchAnd =>
      'Clear the search and filters to see every upcoming event.';

  @override
  String get exploreExploreScreenStateActionlabelClearSearchAndFilters =>
      'Clear search and filters';

  @override
  String get exploreExploreScreenStateTitleNothingTonight => 'Nothing tonight';

  @override
  String get exploreExploreScreenStateMessageTheNextGoodFit =>
      'The next good fit may be over the weekend.';

  @override
  String get exploreExploreScreenStateTitleNothingTomorrow =>
      'Nothing tomorrow';

  @override
  String get exploreExploreScreenStateMessageOpenUpTheWeekend =>
      'Open up the weekend to catch more event slots.';

  @override
  String get exploreExploreScreenStateTitleNothingThisWeekend =>
      'Nothing this weekend';

  @override
  String get exploreExploreScreenStateMessageThisWeekHasThe =>
      'This week has the broader event slate.';

  @override
  String get exploreExploreScreenStateActionlabelSeeThisWeek => 'See this week';

  @override
  String get exploreExploreScreenStateTitleNothingThisWeek =>
      'Nothing this week';

  @override
  String get exploreExploreScreenStateMessageRemoveTheTimeWindow =>
      'Remove the time window to see every upcoming event.';

  @override
  String get exploreExploreScreenStateActionlabelSeeAnytime => 'See anytime';

  @override
  String get exploreExploreScreenStateTitleNoUpcomingEventsMatch =>
      'No upcoming events match this view';

  @override
  String get exploreExploreScreenStateMessageTryADifferentArea =>
      'Try a different area, a wider distance, or check the organizer directory below.';

  @override
  String get exploreExploreScreenStateActionlabelClearFilters =>
      'Clear filters';

  @override
  String get hostsHostEventManageScreenStateDescriptionThisEventCanStay =>
      'This event can stay listed; only people with this code or private link can book.';

  @override
  String get hostsHostEventManageScreenStateDescriptionThisEventRequiresAn =>
      'This event requires an invite, but no host-readable access code was found.';

  @override
  String get hostsHostEventManageScreenStateLabelAll => 'All';

  @override
  String get hostsHostEventManageScreenStateLabelBooked => 'Booked';

  @override
  String get hostsHostEventManageScreenStateLabelRequests => 'Requests';

  @override
  String get hostsHostEventManageScreenStateLabelWaitlist => 'Waitlist';

  @override
  String get hostsHostEventManageScreenStateLabelSlots => 'Slots';

  @override
  String get hostsHostEventManageScreenStateEmptytitleNoMatches => 'No matches';

  @override
  String get hostsHostEventManageScreenStateEmptytitleOpenSlotsAreNot =>
      'Open slots are not people';

  @override
  String get hostsHostEventManageScreenStateEmptytitleNoParticipantsYet =>
      'No participants yet';

  @override
  String get hostsHostEventManageScreenStateLabelDue => 'Due';

  @override
  String get hostsHostEventManageScreenStateLabelIn => 'In';

  @override
  String get hostsHostEventManageScreenStateLabelAttended => 'Attended';

  @override
  String get hostsHostEventManageScreenStateLabelNoShow => 'No-show';

  @override
  String get hostsHostEventManageScreenStateLabelSetup => 'Setup';

  @override
  String get hostsHostEventManageScreenStateLabelGuests => 'Guests';

  @override
  String get hostsHostEventManageScreenStateLabelLive => 'Live';

  @override
  String get hostsHostEventManageScreenStateLabelReport => 'Report';

  @override
  String get hostsHostEventManageScreenStateLabelOffered => 'Offered';

  @override
  String get hostsHostEventManageScreenStateLabelAccepted => 'Accepted';

  @override
  String get hostsHostEventManageScreenStateLabelRequest => 'Request';

  @override
  String get hostsHostEventManageScreenStateLabelWait => 'Wait';

  @override
  String get hostsHostEventManageScreenStateLabelExpired => 'Expired';

  @override
  String get hostsHostEventManageScreenStateLabelNew => 'New';

  @override
  String get eventsEventDetailDesignPrimitivesActionViewMap => 'View map';

  @override
  String get eventsEventDetailInformationStateTitleIfItFillsSpotsReopen =>
      'If it fills, spots reopen';

  @override
  String get eventsEventDetailInformationStateBodyEligiblePeopleAreNotified =>
      'Eligible people are notified together; the first completed booking gets the spot.';

  @override
  String get eventsEventDetailInformationStateTitleHostManagedWaitlist =>
      'Host-managed waitlist';

  @override
  String
  get eventsEventDetailInformationStateBodyTheHostReviewsWaitingRequests =>
      'The host reviews waiting requests when capacity opens.';

  @override
  String get eventsEventDetailInformationStateTitleVariablePricing =>
      'Variable pricing';

  @override
  String get eventsEventDetailInformationStateTitlePlansChange =>
      'Plans change?';

  @override
  String get eventsEventDetailInformationStateBodyReleaseYourSpotEarly =>
      'Release your spot early so the waitlist can move.';

  @override
  String get eventsEventDetailDesignPrimitivesLabelWhen => 'When';

  @override
  String get eventsEventDetailDesignPrimitivesLabelWhere => 'Where';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyThisEventIsCurrently =>
      'This event is currently full; the waitlist keeps priority order.';

  @override
  String eventsEventDetailDesignPrimitivesVisiblecopyOnlyRemainingValue2Left({
    required Object remaining,
    required Object value2,
  }) {
    return 'Only $remaining $value2 left before sign-ups move to waitlist.';
  }

  @override
  String eventsEventDetailDesignPrimitivesVisiblecopySpotslabelSpotsAreAlready({
    required Object spotsLabel,
  }) {
    return '$spotsLabel spots are already spoken for.';
  }

  @override
  String eventsEventDetailDesignPrimitivesTitleGatherAtLocationname({
    required Object locationName,
  }) {
    return 'Gather at $locationName';
  }

  @override
  String get eventsEventDetailDesignPrimitivesDetailQuickHellosHostCheck =>
      'Quick hellos, host check-in, and the plan for the group.';

  @override
  String get eventsEventDetailDesignPrimitivesTitleWrapUp => 'Wrap up';

  @override
  String
  get eventsEventDetailDesignPrimitivesDetailAttendeesCanLingerNaturally =>
      'Attendees can linger naturally; private follow-up unlocks after.';

  @override
  String get eventsEventDetailDesignPrimitivesTitleIfItFillsA =>
      'If it fills, a waitlist';

  @override
  String get eventsEventDetailDesignPrimitivesDetailSpotsFreeUpIn =>
      'Spots free up in order as capacity changes or people cancel.';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyTheFormatKeepsThe =>
      'The format keeps the pace conversational, with regroup points so nobody gets stranded.';

  @override
  String
  get eventsEventDetailDesignPrimitivesVisiblecopyRotationsGiveYouNatural =>
      'Rotations give you natural one-on-one moments without managing the room yourself.';

  @override
  String
  get eventsEventDetailDesignPrimitivesVisiblecopyTeamStructureCreatesLow =>
      'Team structure creates low-pressure reasons to talk throughout the event.';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyASeatedFormatAnd =>
      'A seated format and host cues make the first conversation easier.';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyHostNudgesKeepThe =>
      'Host nudges keep the room moving when it needs a little structure.';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyTheHostRunsThe =>
      'The host runs the arc, so you can just show up and follow the moment.';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyTheHostShapesThe =>
      'The host shapes the format around the room and venue.';

  @override
  String eventsEventDetailDesignPrimitivesVisiblecopyDistancekmAtATolowercase({
    required Object distanceKm,
    required Object toLowerCase,
  }) {
    return '$distanceKm at a $toLowerCase pace, with host-led regroup points.';
  }

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyPairedOrCourtBased =>
      'Paired or court-based rotations keep the activity moving and social.';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyHostLedTeamsAnd =>
      'Host-led teams and rotations create a clear rhythm for the group.';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyATableLedFormat =>
      'A table-led format with built-in prompts and host cues.';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyALooserMixerWith =>
      'A looser mixer with host nudges when the room needs direction.';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyAHostLedActivity =>
      'A host-led activity with clear arrival, activity, and follow-up moments.';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyTheHostAdaptsThe =>
      'The host adapts the format to the group and venue.';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyPace => 'Pace';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopySkill => 'Skill';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyIntensity =>
      'Intensity';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyEnergy => 'Energy';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyOpenSignUp =>
      'Open sign-up';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyInviteOnly =>
      'Invite only';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyHostApproval =>
      'Host approval';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyCohortCaps =>
      'Cohort caps';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyBalancedSingles =>
      'Balanced singles';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyMembersOnly =>
      'Members only';

  @override
  String eventsEventDetailDesignPrimitivesVisiblecopyNoApprovalNeededRsvp({
    required Object capacityLimit,
  }) {
    return 'No approval needed; RSVP until $capacityLimit spots are filled.';
  }

  @override
  String
  get eventsEventDetailDesignPrimitivesVisiblecopyBookWithinTotalCapacity =>
      'Book within total capacity while cohort caps keep the room balanced.';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyStraightMenAndWomen =>
      'Straight men and women are balanced within a small tolerance; other cohorts book within total capacity.';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyOnlyAttendeesWithThe =>
      'Only attendees with the host invite can book this event.';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopyRequestASpotFirst =>
      'Request a spot first; the host reviews requests before confirming.';

  @override
  String
  get eventsEventDetailDesignPrimitivesVisiblecopyOnlyActiveClubMembers =>
      'Only active organizer followers can book this event.';

  @override
  String get clubsClubDetailDockVisiblecopyFreeToJoinLeave =>
      'FREE TO JOIN · LEAVE ANYTIME';

  @override
  String get clubsClubDetailDockVisiblecopyMemberManageAnytime =>
      'MEMBER · MANAGE ANYTIME';

  @override
  String get dashboardEventFocusRailVisiblecopy1Event => '1 event';

  @override
  String dashboardEventFocusRailVisiblecopyLengthEvents({
    required Object length,
  }) {
    return '$length events';
  }

  @override
  String dashboardEventFocusRailVisiblecopyEventValue1OfLength({
    required Object value1,
    required Object length,
  }) {
    return 'Event $value1 of $length';
  }

  @override
  String dashboardEventFocusRailVisiblecopyEventSelectedindexOfLength({
    required Object selectedIndex,
    required Object length,
  }) {
    return 'Event $selectedIndex of $length';
  }

  @override
  String dashboardEventFocusRailVisiblecopyValue1Cardcount({
    required Object value1,
    required Object cardCount,
  }) {
    return '$value1/$cardCount';
  }

  @override
  String get hostsHostPaymentAccountCardTitleSetUpInternationalPayouts =>
      'Set up international payouts';

  @override
  String get hostsHostPaymentAccountCardBodyRequiredBeforePaidNon =>
      'Required before paid non-INR events can accept checkout through Stripe.';

  @override
  String get hostsHostPaymentAccountCardTitleInternationalCheckoutIsReady =>
      'International checkout is ready';

  @override
  String get hostsHostPaymentAccountCardBodyNonInrPaidBookings =>
      'Non-INR paid bookings can route through Stripe for this host account.';

  @override
  String get hostsHostPaymentAccountCardTitleStripeNeedsMoreInformation =>
      'Stripe needs more information';

  @override
  String get hostsHostPaymentAccountCardBodyFinishTheOutstandingStripe =>
      'Finish the outstanding Stripe requirements to accept payments.';

  @override
  String get hostsHostPaymentAccountCardTitleStripeOnboardingIsIn =>
      'Stripe onboarding is in progress';

  @override
  String get hostsHostPaymentAccountCardBodyRefreshAfterCompletingStripe =>
      'Refresh after completing Stripe onboarding to update checkout readiness.';

  @override
  String get hostsCreateEventPolicyStateLabelOpen => 'OPEN';

  @override
  String get hostsCreateEventPolicyStateLabelInvite => 'INVITE';

  @override
  String get hostsCreateEventPolicyStateLabelRequest => 'REQUEST';

  @override
  String get hostsCreateEventPolicyStateLabelBalanced => 'BALANCED';

  @override
  String get hostsCreateEventPolicyStateTitleOpenCapacity => 'Open capacity';

  @override
  String get hostsCreateEventPolicyStateTitleInviteOnly => 'Invite only';

  @override
  String get hostsCreateEventPolicyStateTitleRequestToJoin => 'Request to join';

  @override
  String get hostsCreateEventPolicyStateTitleBalancedSingles =>
      'Balanced singles';

  @override
  String get dashboardDashboardEmptyTitleBookAGroupEvent =>
      'Book a group event';

  @override
  String get dashboardDashboardEmptyBodyPickAClubNear =>
      'Pick an organizer near you. Pay the fee — or don\'t; some are free.';

  @override
  String get dashboardDashboardEmptyTitleActuallyShowUp => 'Actually show up';

  @override
  String get dashboardDashboardEmptyBodyMeetTheClubAt =>
      'Meet the organizer at the event. No cold matching happens here.';

  @override
  String get dashboardDashboardEmptyTitleCatchWithin24Hours =>
      'Catch within 24 hours';

  @override
  String get dashboardDashboardEmptyBodyYouGetTheRoster =>
      'You get the roster of who came. Catch anyone who caught your eye.';

  @override
  String get dashboardDashboardEmptyTitleTheyCatchYouBack =>
      'They catch you back?';

  @override
  String get dashboardDashboardEmptyBodyMatchMessagePlanThe =>
      'Match. Message. Plan the next event together.';

  @override
  String get hostsHostTeamManagementSectionTitleRemoveHost => 'Remove host?';

  @override
  String get hostsHostTeamManagementSectionTitleTransferOwnership =>
      'Transfer ownership?';

  @override
  String hostsHostTeamManagementSectionMessageDisplaynameWillStayA({
    required Object displayName,
  }) {
    return '$displayName will stay an organizer follower but will lose host tools.';
  }

  @override
  String hostsHostTeamManagementSectionMessageDisplaynameWillBecomeThe({
    required Object displayName,
  }) {
    return '$displayName will become the organizer owner. You will remain a host.';
  }

  @override
  String get hostsHostTeamManagementSectionLabelCancel => 'Cancel';

  @override
  String get hostsHostTeamManagementSectionLabelRemove => 'Remove';

  @override
  String get hostsHostTeamManagementSectionLabelTransfer => 'Transfer';

  @override
  String hostsHostTeamManagementSectionSuccessmessageDisplaynameRemoved({
    required Object displayName,
  }) {
    return '$displayName removed.';
  }

  @override
  String
  hostsHostTeamManagementSectionSuccessmessageOwnershipTransferredToDisplayname({
    required Object displayName,
  }) {
    return 'Ownership transferred to $displayName.';
  }

  @override
  String get eventSuccessEventSuccessCompanionSharedLabelPostEventFollowUp =>
      'Post-event follow-up opens after attendance is confirmed.';

  @override
  String
  get eventSuccessEventSuccessCompanionSharedLabelConversationStartersStayPrivate =>
      'Conversation starters stay private to your event context.';

  @override
  String eventSuccessEventSuccessCompanionSharedLabelCheckInWhenYou({
    required Object locationName,
  }) {
    return 'Check in when you reach $locationName.';
  }

  @override
  String get eventSuccessEventSuccessCompanionSharedLabelASmallStarterGroup =>
      'A small starter group will form when arrivals open.';

  @override
  String
  get eventSuccessEventSuccessCompanionSharedLabelTimedPartnerRotationsAs =>
      'Timed partner rotations as the event unfolds.';

  @override
  String
  get eventSuccessEventSuccessCompanionSharedLabelConversationCuesAppearWhen =>
      'Conversation cues appear when the room needs an easy opener.';

  @override
  String
  get eventSuccessEventSuccessCompanionSharedLabelOneSynchronizedRevealEvery =>
      'One synchronized reveal - every phone at once.';

  @override
  String
  get eventSuccessEventSuccessCompanionSharedLabelYourGuideStaysPrivate =>
      'Your guide stays private to your ticket and attendance.';

  @override
  String swipesEventRecapScreenStateVisiblecopyCatchesOpenUntilTime({
    required Object time,
  }) {
    return 'Catches open until $time';
  }

  @override
  String get swipesEventRecapScreenStateVisiblecopyCatchWindowClosed =>
      'Catch window closed';

  @override
  String swipesEventRecapScreenStateKickerTouppercaseComplete({
    required Object toUpperCase,
  }) {
    return '$toUpperCase · COMPLETE';
  }

  @override
  String
  swipesEventRecapScreenStateVisiblecopyActivitysummarylabelCheckedincountCheckedIn({
    required Object activitySummaryLabel,
    required Object checkedInCount,
  }) {
    return '$activitySummaryLabel · $checkedInCount checked in';
  }

  @override
  String get swipesEventRecapScreenStateDisplaynameGuest => 'Guest';

  @override
  String get swipesEventRecapScreenStateVisiblecopyGuest => 'guest';

  @override
  String swipesEventRecapScreenStateTooltipRemoveTooltipname({
    required Object tooltipName,
  }) {
    return 'Remove $tooltipName';
  }

  @override
  String swipesEventRecapScreenStateTooltipRememberTooltipname({
    required Object tooltipName,
  }) {
    return 'Remember $tooltipName';
  }

  @override
  String get exploreExploreFilterRailLabelTonight => 'Tonight';

  @override
  String get exploreExploreFilterRailLabelTomorrow => 'Tomorrow';

  @override
  String get exploreExploreFilterRailLabelWeekend => 'Weekend';

  @override
  String get exploreExploreFilterRailLabelThisWeek => 'This week';

  @override
  String get exploreExploreFilterRailLabelAny => 'Any';

  @override
  String exploreExploreFilterRailDateSupply({
    required Object label,
    required int count,
  }) {
    return '$label · $count';
  }

  @override
  String exploreExploreFilterRailDateSupplyPlus({
    required Object label,
    required int count,
  }) {
    return '$label · $count+';
  }

  @override
  String get dashboardNotificationsListStateVisiblecopyMarking => 'Marking...';

  @override
  String get dashboardNotificationsListStateVisiblecopyMarkAllRead =>
      'Mark all read';

  @override
  String get dashboardNotificationsListStateLabelToday => 'Today';

  @override
  String get dashboardNotificationsListStateLabelYesterday => 'Yesterday';

  @override
  String get dashboardNotificationsListStateLabelThisWeek => 'This week';

  @override
  String get dashboardNotificationsListStateLabelEarlier => 'Earlier';

  @override
  String get dashboardNotificationsListStateVisiblecopyNow => 'Now';

  @override
  String dashboardNotificationsListStateVisiblecopyInminutesM({
    required Object inMinutes,
  }) {
    return '${inMinutes}m';
  }

  @override
  String dashboardNotificationsListStateVisiblecopyInhoursH({
    required Object inHours,
  }) {
    return '${inHours}h';
  }

  @override
  String dashboardNotificationsListStateVisiblecopyIndaysD({
    required Object inDays,
  }) {
    return '${inDays}d';
  }

  @override
  String get onboardingNameDobPageStateVisiblecopyDateOfBirth =>
      'Date of birth';

  @override
  String get onboardingNameDobPageStateVisiblecopyFirstName => 'First name';

  @override
  String get onboardingNameDobPageStateVisiblecopyLastName => 'Last name';

  @override
  String get swipesProfileViewMapperTitleProfileSignals => 'Profile signals';

  @override
  String get swipesProfileViewMapperTitleWhyYouMightClick =>
      'Why you might click';

  @override
  String get swipesProfileViewMapperTitleDetails => 'Details';

  @override
  String get swipesProfileViewMapperTitleLifestyle => 'Lifestyle';

  @override
  String get hostsHostClubsScaffoldVisiblecopyOwner => 'Owner';

  @override
  String get hostsHostClubsScaffoldVisiblecopyHostTeam => 'Host team';

  @override
  String hostsHostClubsScaffoldLabelNameRolelabel({
    required Object name,
    required Object roleLabel,
  }) {
    return '$name · $roleLabel';
  }

  @override
  String
  eventSuccessEventSuccessQuestionnaireConfigEditorPromptCustomQuestionQuestionnumber({
    required Object questionNumber,
  }) {
    return 'Custom question $questionNumber';
  }

  @override
  String get eventSuccessEventSuccessQuestionnaireConfigEditorLabelOption1 =>
      'Option 1';

  @override
  String get eventSuccessEventSuccessQuestionnaireConfigEditorLabelOption2 =>
      'Option 2';

  @override
  String get eventSuccessEventSuccessQuestionnaireConfigEditorLabelOption3 =>
      'Option 3';

  @override
  String get hostsHostEventToolsLabelManageEvent => 'Manage event';

  @override
  String get hostsHostEventToolsLabelTakeAttendance => 'Take attendance';

  @override
  String get hostsHostEventToolsLabelViewReport => 'View report';

  @override
  String get hostsHostEventToolsBadgelabelAttendanceOpen => 'Attendance open';

  @override
  String get hostsHostEventToolsBadgelabelUpcoming => 'Upcoming';

  @override
  String get hostsHostEventToolsBadgelabelAttendanceClosed =>
      'Attendance closed';

  @override
  String get hostsHostBroadcastComposerSheetLabelReminder => 'Reminder';

  @override
  String get hostsHostBroadcastComposerSheetLabelMeetingPoint =>
      'Meeting point';

  @override
  String get hostsHostBroadcastComposerSheetLabelChange => 'Change';

  @override
  String get hostsHostBroadcastComposerSheetDescriptionConfirmTimingAndHelp =>
      'Confirm timing and help everyone arrive ready.';

  @override
  String
  get hostsHostBroadcastComposerSheetDescriptionShareArrivalNotesParking =>
      'Share arrival notes, parking, or table details.';

  @override
  String get hostsHostBroadcastComposerSheetDescriptionCallOutAnImportant =>
      'Call out an important update to the plan.';

  @override
  String hostsHostBroadcastComposerSheetBodyforReminderForTitleDoors({
    required Object title,
  }) {
    return 'Reminder for $title: doors open shortly before the start. See you there!';
  }

  @override
  String hostsHostBroadcastComposerSheetBodyforWeAreMeetingAt({
    required Object locationName,
  }) {
    return 'We are meeting at $locationName. Please arrive a few minutes early.';
  }

  @override
  String hostsHostBroadcastComposerSheetBodyforQuickUpdateForTitle({
    required Object title,
  }) {
    return 'Quick update for $title:';
  }

  @override
  String get clubsClubDetailBodyLabelMembers => 'followers';

  @override
  String get clubsClubDetailBodyLabelRating => 'rating';

  @override
  String get clubsClubDetailBodyLabelReviews => 'reviews';

  @override
  String get clubsClubDetailBodyLabelEst => 'est.';

  @override
  String eventsEventDetailOverviewSectionVisiblecopyADistancekmTolowercaseAt({
    required Object distanceKm,
    required Object toLowerCase,
    required Object toLowerCase2,
    required Object locationName,
  }) {
    return 'A $distanceKm $toLowerCase at a $toLowerCase2 pace from $locationName.';
  }

  @override
  String eventsEventDetailOverviewSectionVisiblecopyAHostedTolowercaseBuilt({
    required Object toLowerCase,
  }) {
    return 'A hosted $toLowerCase built around a clear arrival, shared activity, and low-pressure follow-up.';
  }

  @override
  String get eventsEventDetailOverviewSectionTitleAttendanceMatters =>
      'Attendance matters';

  @override
  String get eventsEventDetailOverviewSectionBodyCheckInOrHost =>
      'Check-in or host-marked attendance decides who can use post-event follow-up and feedback.';

  @override
  String
  eventsEventDetailOverviewSectionVisiblecopyTostringasfixedKmTolowercaseTolowercase2({
    required Object toStringAsFixed,
    required Object toLowerCase,
    required Object toLowerCase2,
  }) {
    return '$toStringAsFixed km $toLowerCase $toLowerCase2';
  }

  @override
  String get eventsEventDetailOverviewSectionVisiblecopyArriveReadyForThe =>
      'Arrive ready for the listed pace and route. The host may split attendees into smaller groups if the crowd needs structure.';

  @override
  String get eventsEventDetailOverviewSectionVisiblecopyExpectPairedOrCourt =>
      'Expect paired or court-based rotations so attendees can meet more people without managing the logistics themselves.';

  @override
  String
  get eventsEventDetailOverviewSectionVisiblecopyExpectTeamStructureAnd =>
      'Expect team structure and host-led moments that create natural reasons to talk.';

  @override
  String get eventsEventDetailOverviewSectionVisiblecopyExpectASeatedFormat =>
      'Expect a seated format with table-level structure and host cues for easier conversation.';

  @override
  String get eventsEventDetailOverviewSectionVisiblecopyExpectALooserSocial =>
      'Expect a looser social format with host nudges when the room needs more mixing.';

  @override
  String get eventsEventDetailOverviewSectionVisiblecopyExpectAHostLed =>
      'Expect a host-led activity with clear arrival, activity, and follow-up moments.';

  @override
  String get eventsEventDetailOverviewSectionVisiblecopyExpectTheHostTo =>
      'Expect the host to shape the format around the room and venue.';

  @override
  String get eventsEventDetailOverviewSectionVisiblecopyPriceCanChangeBased =>
      'Price can change based on live demand.';

  @override
  String eventsEventDetailOverviewSectionVisiblecopyPriceCanIncreaseBy({
    required Object step,
    required Object max,
  }) {
    return 'Price can increase by $step per demand step, capped at $max above the base price.';
  }

  @override
  String get dashboardEventFocusRailLabelViewEvent => 'View event';

  @override
  String get dashboardEventFocusRailLabelCheckIn => 'Check in';

  @override
  String get dashboardEventFocusRailLabelDirections => 'Directions';

  @override
  String get dashboardEventFocusRailLabelAddToCalendar => 'Add to calendar';

  @override
  String get dashboardEventFocusRailLabelStartCatching => 'Start catching';

  @override
  String get dashboardEventFocusRailLabelWriteReview => 'Write review';

  @override
  String get dashboardEventFocusRailBadgelabelCheckInOpen => 'Check-in open';

  @override
  String get dashboardEventFocusRailBadgelabelAfterTheEvent =>
      'After the event';

  @override
  String get dashboardEventFocusRailBadgelabelNextEvent => 'Next event';

  @override
  String get clubsClubDetailDockLabelSignInToJoin => 'Sign in to follow';

  @override
  String get clubsClubDetailDockLabelJoinClub => 'Follow organizer';

  @override
  String get clubsClubDetailDockLabelJoined => 'Following';

  @override
  String get clubsClubDetailDockLabelManage => 'Manage';

  @override
  String get clubsClubDetailDockLabelNewEvent => 'New event';

  @override
  String get hostsHostEventAttendancePanelLabelAccepted => 'Accepted';

  @override
  String get hostsHostEventAttendancePanelLabelOffered => 'Offered';

  @override
  String get hostsHostEventAttendancePanelLabelOffer => 'Offer';

  @override
  String get hostsHostEventAttendancePanelLabelProfile => 'Profile';

  @override
  String get hostsClubHostDefaultsStepLabelOpen => 'OPEN';

  @override
  String get hostsClubHostDefaultsStepLabelInvite => 'INVITE';

  @override
  String get hostsClubHostDefaultsStepLabelBalanced => 'BALANCED';

  @override
  String get hostsClubHostDefaultsStepDescriptionAnyoneEligibleCanBook =>
      'Anyone eligible can book until the event reaches capacity.';

  @override
  String get hostsClubHostDefaultsStepDescriptionNewInviteOnlyEvents =>
      'New invite-only events will ask for an event-specific code.';

  @override
  String get hostsClubHostDefaultsStepDescriptionStraightMenAndWomen =>
      'Straight men and women are kept within one spot of each other.';

  @override
  String get hostsClubHostDefaultsStepDescriptionNewEventsStartOpen =>
      'New events start open with optional straight men and straight women caps.';

  @override
  String get hostsCreateEventPolicyStateDescriptionAnyoneEligibleCanBook =>
      'Anyone eligible can book until the event reaches capacity.';

  @override
  String get hostsCreateEventPolicyStateDescriptionOnlyPeopleWithThe =>
      'Only people with the invite code or private link can book. Waitlist is off by default.';

  @override
  String get hostsCreateEventPolicyStateDescriptionPeopleRequestASpot =>
      'People request a spot first. The host reviews their public profile before confirming who gets in.';

  @override
  String get hostsCreateEventPolicyStateDescriptionStraightMenAndWomen =>
      'Straight men and women are kept within one spot of each other. Queer, open, non-binary, and other attendees can book within total capacity.';

  @override
  String get eventsCalendarScreenStateTitleNoPlannedEventsYet =>
      'No planned events yet';

  @override
  String get eventsCalendarScreenStateBodyEventsYouBookOr =>
      'Events you book or save will show up here by day and time.';

  @override
  String get eventsCalendarScreenStateBadgelabelCancelled => 'CANCELLED';

  @override
  String get eventsCalendarScreenStateBadgelabelSaved => 'SAVED';

  @override
  String get eventsCalendarScreenStateBadgelabelJoined => 'JOINED';

  @override
  String get hostsHostHomeScreenStateVisiblecopyRepeatLast => 'Repeat last';

  @override
  String hostsHostHomeScreenStateVisiblecopyRepeatLabel({
    required Object label,
  }) {
    return 'Repeat ‘$label’';
  }

  @override
  String get hostsHostHomeScreenStateEmptytitleNoUpcomingEvents =>
      'No upcoming events';

  @override
  String get hostsHostHomeScreenStateEmptytitleNothingLiveRightNow =>
      'Nothing live right now';

  @override
  String get hostsHostHomeScreenStateEmptytitleNoPastEventsYet =>
      'No past events yet';

  @override
  String get hostsHostHomeScreenStateEmptybodyCreateYourNextEvent =>
      'Create your next event to start filling this list.';

  @override
  String get hostsHostHomeScreenStateEmptybodyYourNextEventAppears =>
      'Your next event appears here when it starts.';

  @override
  String get hostsHostHomeScreenStateEmptybodyCompletedEventsAndTheir =>
      'Completed events and their attendance will appear here.';

  @override
  String hostsHostHomeScreenStateVisiblecopySpotsremainingSpotsOpen({
    required Object spotsRemaining,
  }) {
    return '$spotsRemaining spots open';
  }

  @override
  String get hostsHostHomeScreenStateVisiblecopyEventFull => 'event full';

  @override
  String get hostsHostHomeScreenStateTitleReviewWaitlist => 'Review waitlist';

  @override
  String hostsHostHomeScreenStateBodyTitleWaitlistcountWaitingAvailability({
    required Object title,
    required Object waitlistCount,
    required Object availability,
  }) {
    return '$title\n$waitlistCount waiting · $availability';
  }

  @override
  String get hostsHostHomeScreenStateVisiblecopyReview => 'Review';

  @override
  String get eventSuccessEventSuccessConversationCueCopyLabelLivePrompt =>
      'Live prompt';

  @override
  String get eventSuccessEventSuccessConversationCueCopyLabelPostMatchOpener =>
      'Post-match opener';

  @override
  String get eventSuccessEventSuccessConversationCueCopyTitleSharedRoom =>
      'Shared room';

  @override
  String eventSuccessEventSuccessConversationCueCopyBodyIAmGladWe({
    required Object label,
  }) {
    return 'I am glad we both made it to $label.';
  }

  @override
  String get eventSuccessEventSuccessConversationCueCopyTitleEasyFollowUp =>
      'Easy follow-up';

  @override
  String
  get eventSuccessEventSuccessConversationCueCopyBodyWhatWasYourFavorite =>
      'What was your favorite moment from the event?';

  @override
  String
  get eventSuccessEventSuccessConversationCueCopyVisiblecopyLowPressure =>
      'Low pressure';

  @override
  String
  get eventSuccessEventSuccessConversationCueCopyBodyAskSomeoneWhatRoute =>
      'Ask someone what route, cafe, or park they would do again.';

  @override
  String
  get eventSuccessEventSuccessConversationCueCopyBodyAskYourNextPartner =>
      'Ask your next partner what shot they are trying to improve.';

  @override
  String get eventSuccessEventSuccessConversationCueCopyBodyAskWhatKindOf =>
      'Ask what kind of ride they want to do next.';

  @override
  String get eventSuccessEventSuccessConversationCueCopyBodyAskWhatPartOf =>
      'Ask what part of class helped them switch off.';

  @override
  String get eventSuccessEventSuccessConversationCueCopyBodyAskWhatLiftOr =>
      'Ask what lift or movement they are working on right now.';

  @override
  String get eventSuccessEventSuccessConversationCueCopyBodyAskWhichRoundThey =>
      'Ask which round they wanted more questions from.';

  @override
  String get eventSuccessEventSuccessConversationCueCopyBodyAskWhichStopThey =>
      'Ask which stop they would come back to with friends.';

  @override
  String get eventSuccessEventSuccessConversationCueCopyBodyAskWhatDishThey =>
      'Ask what dish they would order again.';

  @override
  String get eventSuccessEventSuccessConversationCueCopyBodyAskWhatAnswerFrom =>
      'Ask what answer from tonight surprised them.';

  @override
  String get eventSuccessEventSuccessConversationCueCopyBodyAskWhatMadeThem =>
      'Ask what made them say yes to this event.';

  @override
  String get eventSuccessEventSuccessConversationCueCopyTitleFirstLiveCue =>
      'First live cue';

  @override
  String
  get eventSuccessEventSuccessConversationCueCopyBodySwapOnePracticalTip =>
      'Swap one practical tip before the next round or cooldown.';

  @override
  String get eventSuccessEventSuccessConversationCueCopyBodyFindOnePersonYou =>
      'Find one person you have not spoken to and ask one specific follow-up.';

  @override
  String get eventSuccessEventSuccessConversationCueCopyTitleSecondTouch =>
      'Second touch';

  @override
  String get eventSuccessEventSuccessConversationCueCopyVisiblecopyOptional =>
      'Optional';

  @override
  String get eventSuccessEventSuccessConversationCueCopyBodyILikedTalkingOn =>
      'I liked talking on the run. Want to compare routes sometime?';

  @override
  String get eventSuccessEventSuccessConversationCueCopyBodyGoodGameTodayI =>
      'Good game today. I am still thinking about that rally.';

  @override
  String
  get eventSuccessEventSuccessConversationCueCopyBodyThatSessionHadReal =>
      'That session had real energy. What kind of ride do you usually like?';

  @override
  String get eventSuccessEventSuccessConversationCueCopyBodyThatClassWasA =>
      'That class was a good reset. Do you usually go for flow or stretch?';

  @override
  String
  get eventSuccessEventSuccessConversationCueCopyBodyNiceTrainingWithYou =>
      'Nice training with you today. What are you building toward right now?';

  @override
  String get eventSuccessEventSuccessConversationCueCopyBodyILikedBeingOn =>
      'I liked being on a quiz night with you. Which round was your favorite?';

  @override
  String
  get eventSuccessEventSuccessConversationCueCopyBodyFunMeetingYouTonight =>
      'Fun meeting you tonight. Which stop won for you?';

  @override
  String get eventSuccessEventSuccessConversationCueCopyBodyILikedMeetingYou =>
      'I liked meeting you over dinner. What was your favorite dish?';

  @override
  String
  get eventSuccessEventSuccessConversationCueCopyBodyILikedOurConversation =>
      'I liked our conversation tonight. Want to keep it going?';

  @override
  String
  get eventSuccessEventSuccessConversationCueCopyBodyILikedMeetingYou957a50 =>
      'I liked meeting you at the event. What did you think of it?';

  @override
  String
  get eventSuccessEventSuccessConversationCueCopyTitleUseTheSharedMoment =>
      'Use the shared moment';

  @override
  String get chatsChatsListBodyVisiblecopyAttendee => 'attendee';

  @override
  String chatsChatsListBodyVisiblecopy1Audiencelabel({
    required Object audienceLabel,
  }) {
    return '1 $audienceLabel';
  }

  @override
  String chatsChatsListBodyVisiblecopyAudiencecountAudiencelabelS({
    required Object audienceCount,
    required Object audienceLabel,
  }) {
    return '$audienceCount ${audienceLabel}s';
  }

  @override
  String get chatsChatShareCardVisiblecopyCatchChatCardPng =>
      'catch-chat-card.png';

  @override
  String get chatsChatShareCardVisiblecopyShareCard => 'Share card';

  @override
  String get chatsChatShareCardVisiblecopyNamesPhotosAndTimestamps =>
      'Names, photos, and timestamps are hidden.';

  @override
  String get chatsChatShareCardVisiblecopyCatchChatCard => 'Catch chat card';

  @override
  String get chatsMessageBubbleVisiblecopySending => 'Sending...';

  @override
  String get chatsSuvbotActionBarVisiblecopyWarmsignupstate =>
      'warmSignupState';

  @override
  String get chatsSuvbotActionBarVisiblecopyWarmposteventstate =>
      'warmPostEventState';

  @override
  String get chatsSuvbotActionBarVisiblecopyWarmchatstate => 'warmChatState';

  @override
  String get chatsSuvbotActionBarVisiblecopyWarmpaymentstate =>
      'warmPaymentState';

  @override
  String get chatsSuvbotActionBarVisiblecopyResetchats => 'resetChats';

  @override
  String get chatsSuvbotActionBarVisiblecopyResetbookings => 'resetBookings';

  @override
  String get chatsSuvbotActionBarVisiblecopyResetnotifications =>
      'resetNotifications';

  @override
  String get chatsSuvbotActionBarVisiblecopyCleardemostate => 'clearDemoState';

  @override
  String get chatsSuvbotActionBarVisiblecopyCheckdemostate => 'checkDemoState';

  @override
  String get chatsSuvbotActionBarVisiblecopyRefreshdemostate =>
      'refreshDemoState';

  @override
  String get chatsSuvbotActionBarVisiblecopyHelp => 'help';

  @override
  String get chatsSuvbotActionBarVisiblecopyMatchtesterbyphone =>
      'matchTesterByPhone';

  @override
  String get coreBlockUserDialogVisiblecopyBlock => 'Block';

  @override
  String get coreCatchAdaptiveDialogVisiblecopyConfirm => 'Confirm';

  @override
  String get coreCatchAdaptiveDialogVisiblecopyCancel => 'Cancel';

  @override
  String get coreCatchAdaptivePickerVisiblecopySelectDate => 'Select date';

  @override
  String get coreCatchAdaptivePickerVisiblecopySelectTime => 'Select time';

  @override
  String coreCatchEventActivityCardsVisiblecopyTimelabelCountdownlabel({
    required Object timeLabel,
    required Object countdownLabel,
  }) {
    return '$timeLabel / $countdownLabel';
  }

  @override
  String get coreCatchFieldVisiblecopySelect => 'Select';

  @override
  String get coreCatchOtpCodeFieldVisiblecopyOtpDigit => 'otp_digit';

  @override
  String get coreCatchSearchFieldVisiblecopyCloseSearch => 'Close search';

  @override
  String get coreCatchShareCardSheetVisiblecopyUnableToShareThis =>
      'Unable to share this card.';

  @override
  String get dashboardActivityScreenVisiblecopyMarkNotificationsRead =>
      'mark notifications read';

  @override
  String get dashboardActivityScreenVisiblecopyActivityScreen =>
      'activity_screen';

  @override
  String get dashboardDashboardScreenVisiblecopyHeader => 'header';

  @override
  String get dashboardDashboardScreenVisiblecopyCalendar => 'calendar';

  @override
  String dashboardDashboardScreenVisiblecopyStatevalueModule({
    required Object stateValue,
    required Object module,
  }) {
    return '$stateValue:$module';
  }

  @override
  String get dashboardDashboardScreenVisiblecopyClubPosts => 'club_posts';

  @override
  String get dashboardDashboardScreenVisiblecopyHome => 'home';

  @override
  String get dashboardDashboardScreenVisiblecopyNotifications =>
      'notifications';

  @override
  String get dashboardNotificationRouteUtilVisiblecopyCouldNotOpenThis =>
      'Could not open this activity update.';

  @override
  String get dashboardDashboardFullVisiblecopyCatchWindow => 'catch_window';

  @override
  String get dashboardDashboardFullVisiblecopyFocusRail => 'focus_rail';

  @override
  String get dashboardDashboardFullVisiblecopyIdleCta => 'idle_cta';

  @override
  String get dashboardDashboardFullVisiblecopyFindEvent => 'find_event';

  @override
  String get dashboardDashboardFullVisiblecopyClubPosts => 'club_posts';

  @override
  String get dashboardDashboardFullVisiblecopyOpenPost => 'open_post';

  @override
  String get dashboardDashboardFullVisiblecopyViewEvent => 'view_event';

  @override
  String get dashboardDashboardFullVisiblecopyDirections => 'directions';

  @override
  String get dashboardDashboardFullVisiblecopyAddToCalendar =>
      'add_to_calendar';

  @override
  String get dashboardDashboardFullVisiblecopyOpenCatchWindow =>
      'open_catch_window';

  @override
  String get dashboardDashboardFullVisiblecopyWriteReview => 'write_review';

  @override
  String get dashboardDashboardFullVisiblecopyCheckIn => 'check_in';

  @override
  String get dashboardEmptyHeroCardVisiblecopyOpensTheExplorePage =>
      'Opens the explore page to find events near your location.';

  @override
  String
  eventSuccessEventSuccessCompanionAfterglowVisiblecopyLongdatelabelActivitysummarylabel({
    required Object longDateLabel,
    required Object activitySummaryLabel,
  }) {
    return '$longDateLabel | $activitySummaryLabel';
  }

  @override
  String
  get eventSuccessEventSuccessCompanionAfterglowVisiblecopyUseTheSharedEvent =>
      'Use the shared event context when a match opens.';

  @override
  String
  get eventSuccessEventSuccessCompanionAfterglowVisiblecopyKeepTheUsefulParts =>
      'Keep the useful parts of the room for yourself.';

  @override
  String
  get eventSuccessEventSuccessCompanionAfterglowVisiblecopyLeaveAQuickNote =>
      'Leave a quick note while the event is fresh.';

  @override
  String
  get eventSuccessEventSuccessCompanionAfterglowVisiblecopyCatchKeepsThisRecap =>
      'Catch keeps this recap private to you.';

  @override
  String
  eventSuccessEventSuccessCompanionAfterglowVisiblecopyMetnewpeoplecountPeopleRememberedWelcome({
    required Object metNewPeopleCount,
    required Object welcomeRating,
  }) {
    return '$metNewPeopleCount people remembered, welcome $welcomeRating/5.';
  }

  @override
  String get eventSuccessEventSuccessCompanionAfterglowVisiblecopyD => '\\d+';

  @override
  String eventSuccessEventSuccessCompanionLiveCardsVisiblecopyValue1People({
    required Object value1,
  }) {
    return '$value1 people';
  }

  @override
  String
  get eventSuccessEventSuccessCompanionLiveCardsVisiblecopyLoadingGroupMembers =>
      'Loading group members';

  @override
  String eventSuccessEventSuccessCompanionLiveCardsVisiblecopyFormatFormat2({
    required Object format,
    required Object format2,
  }) {
    return '$format-$format2';
  }

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsVisiblecopyPartner =>
      'Partner';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsVisiblecopyThisIsNotA =>
      'This is not a Catch event QR.';

  @override
  String
  get eventSuccessEventSuccessCompanionLiveCardsVisiblecopyThisQrBelongsTo =>
      'This QR belongs to another event.';

  @override
  String
  get eventSuccessEventSuccessCompanionLiveCardsVisiblecopyOpenerCopied =>
      'Opener copied.';

  @override
  String get eventSuccessEventSuccessCompanionLiveCardsVisiblecopyCueCopied =>
      'Cue copied.';

  @override
  String get eventSuccessEventSuccessCompanionSharedVisiblecopyFree => 'Free';

  @override
  String
  get eventSuccessEventSuccessCompanionSharedVisiblecopyPersonHereSoFar =>
      'person here so far';

  @override
  String
  get eventSuccessEventSuccessCompanionSharedVisiblecopyPeopleHereSoFar =>
      'people here so far';

  @override
  String
  get eventSuccessEventSuccessCompanionSharedVisiblecopyWaitingForTheRoom =>
      'waiting for the room to fill';

  @override
  String
  get eventSuccessEventSuccessCompanionWingmanVisiblecopyHostHelpRequestActive =>
      'Host-help request active';

  @override
  String
  get eventSuccessEventSuccessCompanionWingmanVisiblecopyCheckedInToThis =>
      'Checked in to this event';

  @override
  String
  get eventSuccessEventSuccessCompanionBodyScreenVisiblecopySelfCheckIn =>
      'self-check-in';

  @override
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyFirstHello =>
      'first-hello';

  @override
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyPreArrival =>
      'pre-arrival';

  @override
  String
  get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyQuestionnaire =>
      'questionnaire';

  @override
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyPrompt =>
      'prompt';

  @override
  String
  get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyAfterglowRecap =>
      'afterglow-recap';

  @override
  String
  get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyPostOpeners =>
      'post-openers';

  @override
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyLiveCues =>
      'live-cues';

  @override
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyLiveStep =>
      'live-step';

  @override
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyMicroPod =>
      'micro-pod';

  @override
  String
  get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyRotationSchedule =>
      'rotation-schedule';

  @override
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyLiveReveal =>
      'live-reveal';

  @override
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyWingman =>
      'wingman';

  @override
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyFeedback =>
      'feedback';

  @override
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyEmpty =>
      'empty';

  @override
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyStage =>
      'stage';

  @override
  String get eventSuccessEventSuccessCompanionScreenStateVisiblecopyNoStage =>
      'no-stage';

  @override
  String get eventSuccessEventSuccessCompanionScreenStateVisiblecopyNoStep =>
      'no-step';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyBeforeArrival =>
      'Before arrival';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyYourEventGuideIs =>
      'Your event guide is warming up.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyPreEventDetailsStay =>
      'Pre-event details stay informational until the host starts the room.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyArrivalCue =>
      'Arrival cue';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyCheckInWhenYou =>
      'Check in when you reach the venue.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyCheckInOnlyUpdates =>
      'Check-in only updates attendance and the event companion flow.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyFirstHello =>
      'First Hello';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyYourFirstArrivalMission =>
      'Your first arrival mission is live.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyThisChecksYouIn =>
      'This checks you in. Hosts do not see the individual answer.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyMatchClues =>
      'Match clues';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyAddAFewClues =>
      'Add a few clues before the room moves.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyHostsDoNotSee =>
      'Hosts do not see individual match clue answers.';

  @override
  String get eventSuccessEventSuccessCompanionScreenStateVisiblecopyLiveNow =>
      'Live now';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyFollowTheHostFor =>
      'Follow the host for the next beat.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyEveryoneSeesTheSame =>
      'Everyone sees the same room cue; personal details stay scoped to you.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyLivePrompt =>
      'Live prompt';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyAFreshPromptJust =>
      'A fresh prompt just dropped.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyPromptsAreSharedGuidance =>
      'Prompts are shared guidance, not a public record of what you say.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyConversationCues =>
      'Conversation cues';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyPickACueAnd =>
      'Pick a cue and keep the room moving.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyConversationCuesAreSuggestions =>
      'Conversation cues are suggestions only; nothing is sent for you.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyYourNextGroup =>
      'Your next group';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyYourAssignmentIsReady =>
      'Your assignment is ready.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyOnlyYourOwnAssignment =>
      'Only your own assignment details appear on this screen.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopySharedReveal =>
      'Shared reveal';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyYourDetailsStayHidden =>
      'Your details stay hidden on this screen until the shared reveal moment.';

  @override
  String get eventSuccessEventSuccessCompanionScreenStateVisiblecopyHostHelp =>
      'Host help';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyAskForOneSpecific =>
      'Ask for one specific intro.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyOnlyTheHostSees =>
      'Only the host sees this request; the other attendee is not notified.';

  @override
  String get eventSuccessEventSuccessCompanionScreenStateVisiblecopyAfterglow =>
      'Afterglow';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyYourAfterglowIsReady =>
      'Your afterglow is ready.';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyThisRecapIsPrivate =>
      'This recap is private to you. Hosts only see safe aggregate coaching.';

  @override
  String get eventSuccessEventSuccessCompanionScreenStateVisiblecopyWrapped =>
      'Wrapped';

  @override
  String get eventSuccessEventSuccessCompanionScreenStateVisiblecopyBooked =>
      'Booked';

  @override
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyCatchOnlyShowsThe =>
      'Catch only shows the live details that are relevant to this event moment.';

  @override
  String
  get eventSuccessEventSuccessEventPreviewBodyScreenVisiblecopyThisClub =>
      'This organizer';

  @override
  String eventSuccessEventSuccessStructureConfigEditorVisiblecopyTointPeople({
    required Object toInt,
  }) {
    return '$toInt people';
  }

  @override
  String
  eventSuccessEventSuccessStructureConfigEditorVisiblecopyTointTolowercase({
    required Object toInt,
    required Object toLowerCase,
  }) {
    return '$toInt $toLowerCase';
  }

  @override
  String eventSuccessEventSuccessStructureConfigEditorVisiblecopyTointValue2({
    required Object toInt,
    required Object value2,
  }) {
    return '$toInt $value2';
  }

  @override
  String eventSuccessEventSuccessHostLiveVisiblecopyAttendeesAtLocationnameSee({
    required Object locationName,
    required Object attendeeExperience,
  }) {
    return 'Attendees at $locationName see: $attendeeExperience';
  }

  @override
  String eventSuccessEventSuccessHostLiveVisiblecopyStepValue1TotalLabel({
    required Object value1,
    required Object total,
    required Object label,
  }) {
    return 'Step $value1/$total · $label';
  }

  @override
  String get eventSuccessEventSuccessHostLiveVisiblecopyFinalStep =>
      'Final step';

  @override
  String eventSuccessEventSuccessHostLiveVisiblecopyNextTitle({
    required Object title,
  }) {
    return 'Next: $title';
  }

  @override
  String get eventSuccessEventSuccessHostOverridesVisiblecopyHostOverrideV1 =>
      'host_override_v1';

  @override
  String get eventSuccessEventSuccessHostOverridesVisiblecopyAddAtLeastOne =>
      'Add at least one group.';

  @override
  String get eventSuccessEventSuccessHostOverridesVisiblecopyNameEveryGroup =>
      'Name every group.';

  @override
  String
  get eventSuccessEventSuccessHostOverridesVisiblecopyAddAtLeastOne64c0b6 =>
      'Add at least one attendee to every group.';

  @override
  String
  get eventSuccessEventSuccessHostOverridesVisiblecopyChooseEveryAttendeeSlot =>
      'Choose every attendee slot.';

  @override
  String
  get eventSuccessEventSuccessHostOverridesVisiblecopyEachAttendeeCanAppear =>
      'Each attendee can appear once per round.';

  @override
  String
  get eventSuccessEventSuccessHostOverridesVisiblecopyAddAtLeastOne76e783 =>
      'Add at least one pair.';

  @override
  String
  get eventSuccessEventSuccessHostOverridesVisiblecopyChooseBothAttendeesFor =>
      'Choose both attendees for every pair.';

  @override
  String
  get eventSuccessEventSuccessHostOverridesVisiblecopyChooseTwoDifferentAttendees =>
      'Choose two different attendees.';

  @override
  String eventSuccessEventSuccessHostSetupVisiblecopyToint({
    required Object toInt,
  }) {
    return '$toInt';
  }

  @override
  String
  get eventSuccessEventSuccessHostSetupVisiblecopyDecreaseTargetAttendees =>
      'Decrease target attendees';

  @override
  String
  get eventSuccessEventSuccessHostSetupVisiblecopyIncreaseTargetAttendees =>
      'Increase target attendees';

  @override
  String get eventSuccessEventSuccessHostSharedVisiblecopyThisAttendee =>
      'this attendee';

  @override
  String get eventSuccessEventSuccessHostSharedVisiblecopyAttendee =>
      'Attendee';

  @override
  String eventSuccessEventSuccessHostSharedVisiblecopyAskedForHelpMeeting({
    required Object targetName,
  }) {
    return 'Asked for help meeting $targetName';
  }

  @override
  String eventSuccessEventSuccessLiveRevealHostVisiblecopyRemainingseconds({
    required Object remainingSeconds,
  }) {
    return '$remainingSeconds';
  }

  @override
  String get eventSuccessEventSuccessLiveRevealHostVisiblecopyOk => 'OK';

  @override
  String eventSuccessEventSuccessLiveRevealHostVisiblecopyValue1({
    required Object value1,
  }) {
    return '$value1';
  }

  @override
  String get eventSuccessEventSuccessLiveRevealWidgetsVisiblecopyPartner =>
      'Partner';

  @override
  String eventSuccessEventSuccessLiveRevealWidgetsVisiblecopyFormatFormat2({
    required Object format,
    required Object format2,
  }) {
    return '$format-$format2';
  }

  @override
  String get eventSuccessEventSuccessLiveRevealWidgetsVisiblecopyDone => 'Done';

  @override
  String get eventSuccessEventSuccessLiveRevealWidgetsVisiblecopyNow => 'Now';

  @override
  String get eventSuccessEventSuccessLiveRevealWidgetsVisiblecopyHidden =>
      'Hidden';

  @override
  String eventsCalendarScreenVisiblecopyCalendarAgendaDayDatekey({
    required Object dateKey,
  }) {
    return 'calendar-agenda-day-$dateKey';
  }

  @override
  String eventsCalendarScreenVisiblecopyLength({required Object length}) {
    return '$length';
  }

  @override
  String eventsCalendarScreenVisiblecopyRoundKm({required Object round}) {
    return '$round km';
  }

  @override
  String get eventsCalendarScreenVisiblecopyNone => 'None';

  @override
  String get eventsCalendarScreenVisiblecopyS => 'S';

  @override
  String get eventsCalendarScreenVisiblecopyM => 'M';

  @override
  String get eventsCalendarScreenVisiblecopyT => 'T';

  @override
  String get eventsCalendarScreenVisiblecopyW => 'W';

  @override
  String get eventsCalendarScreenVisiblecopyF => 'F';

  @override
  String eventsEventDetailScreenVisiblecopyEventidInvitelinkid({
    required Object eventId,
    required Object inviteLinkId,
  }) {
    return '$eventId:$inviteLinkId';
  }

  @override
  String get eventsEventDetailScreenVisiblecopyBookingConfirmed =>
      'Booking confirmed!';

  @override
  String get eventsEventDetailScreenVisiblecopyBookingCancelled =>
      'Booking cancelled.';

  @override
  String get eventsEventDetailScreenVisiblecopyEventSaved => 'Event saved.';

  @override
  String get eventsEventDetailScreenVisiblecopyEventRemoved => 'Event removed.';

  @override
  String
  get eventsEventDetailScreenVisiblecopyEventdetailscreenTogglesavedeventFailed =>
      'EventDetailScreen._toggleSavedEvent failed';

  @override
  String get eventsEventDetailScreenVisiblecopyCouldNotOpenCalendar =>
      'Could not open calendar.';

  @override
  String get eventsEventDetailScreenVisiblecopyFailedToAddEvent =>
      'Failed to add event to calendar';

  @override
  String get eventsEventDetailScreenVisiblecopyAddEventToCalendar =>
      'add event to calendar';

  @override
  String get eventsEventDetailScreenVisiblecopyCalendarLink => 'calendar_link';

  @override
  String eventsEventDetailScreenStateVisiblecopySpotsremainingSpotsLeft({
    required Object spotsRemaining,
  }) {
    return '$spotsRemaining spots left';
  }

  @override
  String get eventsEventDetailScreenStateVisiblecopyMatchingOpensForEveryone =>
      'Matching opens for everyone who goes';

  @override
  String get eventsLocationPickerScreenVisiblecopySelecting => 'Selecting...';

  @override
  String get eventsLocationPickerScreenVisiblecopySearching => 'Searching...';

  @override
  String get eventsBookingConflictSheetVisiblecopyAlreadyBooked =>
      'Already booked';

  @override
  String get eventsBookingConflictSheetVisiblecopyNew => 'New';

  @override
  String get eventsEventDetailCtaVisiblecopyOfferActive => 'Offer active';

  @override
  String eventsEventDetailCtaVisiblecopyUntilTime({required Object time}) {
    return 'Until $time';
  }

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopySpot => 'spot';

  @override
  String get eventsEventDetailDesignPrimitivesVisiblecopySpots => 'spots';

  @override
  String get eventsEventPinsMapVisiblecopyCatchEventMap => 'catch event map';

  @override
  String get eventsEventPinsMapVisiblecopyBuildingEventMapPin =>
      'building event map pin bitmap';

  @override
  String get exploreExploreScreenVisiblecopyCoverHeader => 'cover_header';

  @override
  String get exploreExploreScreenVisiblecopyExternalSupply => 'external_supply';

  @override
  String get exploreExploreScreenVisiblecopyExternalOutbound =>
      'external_outbound';

  @override
  String get exploreExploreScreenVisiblecopyExternalPlatform =>
      'external_platform';

  @override
  String exploreExploreScreenStateVisiblecopyChooseCityLabel({
    required Object label,
  }) {
    return 'Choose city: $label';
  }

  @override
  String exploreExploreScreenStateVisiblecopyExploreLabel({
    required Object label,
  }) {
    return 'EXPLORE · $label';
  }

  @override
  String get exploreExploreScreenStateVisiblecopyExplore => 'Explore';

  @override
  String get exploreExploreScreenStateVisiblecopySearchEventsOrClubs =>
      'Search events or organizers';

  @override
  String get exploreExploreScreenStateVisiblecopyOpenExploreFilters =>
      'Open explore filters';

  @override
  String exploreExploreScreenStateVisiblecopyOpenExploreFiltersActivecount({
    required Object activeCount,
  }) {
    return 'Open explore filters, $activeCount active';
  }

  @override
  String exploreExploreScreenStateVisiblecopyTimePricelabel({
    required Object time,
    required Object priceLabel,
  }) {
    return '$time - $priceLabel';
  }

  @override
  String exploreExploreScreenStateVisiblecopySignedupcountGoingCoverspotslabel({
    required Object signedUpCount,
    required Object coverSpotsLabel,
  }) {
    return '$signedUpCount going - $coverSpotsLabel';
  }

  @override
  String exploreExploreScreenStateVisiblecopyFromTouppercase({
    required Object toUpperCase,
  }) {
    return 'FROM $toUpperCase';
  }

  @override
  String get exploreExploreScreenStateVisiblecopyExternal => 'External';

  @override
  String exploreExploreScreenStateVisiblecopyTimePricelabelc30029({
    required Object time,
    required Object priceLabel,
  }) {
    return '$time · $priceLabel';
  }

  @override
  String get exploreExploreScreenStateVisiblecopyOpenExternalEventSource =>
      'Open external event source';

  @override
  String get exploreExploreScreenStateVisiblecopyExternalEventLinkUnavailable =>
      'External event link unavailable';

  @override
  String get exploreExploreScreenStateVisiblecopyReadOnlySupplyNo =>
      'READ-ONLY SUPPLY · NO CATCH BOOKING';

  @override
  String get exploreExploreScreenStateVisiblecopyClubToKnow =>
      'ORGANIZER TO KNOW';

  @override
  String get exploreExploreScreenStateVisiblecopyPlan => 'PLAN';

  @override
  String get exploreExploreScreenStateVisiblecopyPlans => 'PLANS';

  @override
  String exploreExploreScreenStateVisiblecopyCountNoun({
    required Object count,
    required Object noun,
  }) {
    return '$count $noun';
  }

  @override
  String exploreExploreScreenStateVisiblecopyCountPlusNoun({
    required Object count,
    required Object noun,
  }) {
    return '$count+ $noun';
  }

  @override
  String exploreExploreScreenStateVisiblecopyCountNounDatespan({
    required Object count,
    required Object noun,
    required Object dateSpan,
  }) {
    return '$count $noun · $dateSpan';
  }

  @override
  String exploreExploreScreenStateVisiblecopyCountPlusNounDatespan({
    required Object count,
    required Object noun,
    required Object dateSpan,
  }) {
    return '$count+ $noun · $dateSpan';
  }

  @override
  String exploreExploreScreenStateVisiblecopyNextNextevent({
    required Object nextEvent,
  }) {
    return 'Next: $nextEvent';
  }

  @override
  String exploreExploreScreenStateVisiblecopyClubmembercountlabelArea({
    required Object clubMemberCountLabel,
    required Object area,
  }) {
    return '$clubMemberCountLabel - $area';
  }

  @override
  String exploreExploreScreenStateVisiblecopyCovertimescopeNameLocationname({
    required Object coverTimeScope,
    required Object name,
    required Object locationName,
  }) {
    return '$coverTimeScope - $name - $locationName';
  }

  @override
  String get exploreExploreScreenStateVisiblecopyTonight => 'Tonight';

  @override
  String get exploreExploreScreenStateVisiblecopyTomorrow => 'Tomorrow';

  @override
  String get exploreExploreScreenStateVisiblecopyThisWeek => 'This week';

  @override
  String get exploreExploreScreenStateVisiblecopy1Left => '1 left';

  @override
  String exploreExploreScreenStateVisiblecopySpotsLeft({
    required Object spots,
  }) {
    return '$spots left';
  }

  @override
  String exploreExploreEventRowsVisiblecopyComingUpLength({
    required Object length,
  }) {
    return 'COMING UP · $length';
  }

  @override
  String get hostsCreateClubScreenVisiblecopyRestoredYourClubDraft =>
      'Restored your organizer draft';

  @override
  String
  get hostsCreateClubScreenVisiblecopyCreateclubscreenRestoresaveddraftFailed =>
      'CreateClubScreen._restoreSavedDraft failed';

  @override
  String get hostsCreateClubScreenVisiblecopyDraftUpdated => 'Draft updated';

  @override
  String get hostsCreateClubScreenVisiblecopyDraftSaved => 'Draft saved';

  @override
  String get hostsCreateClubScreenVisiblecopyCreateclubscreenSubmitFailed =>
      'CreateClubScreen._submit failed';

  @override
  String get hostsClubBasicsStepVisiblecopyPleaseEnterAClub =>
      'Please enter an organizer name';

  @override
  String get hostsClubBasicsStepVisiblecopyPleaseSelectACity =>
      'Please select a city';

  @override
  String get hostsClubBasicsStepVisiblecopyPleaseEnterAnArea =>
      'Please enter an area';

  @override
  String get hostsClubDetailsStepVisiblecopyPleaseAddADescription =>
      'Please add a description';

  @override
  String get hostsCreateClubPhotosPickerVisiblecopyAddPhotos => 'Add photos';

  @override
  String get hostsCreateClubPhotosPickerVisiblecopyAddClubPhotos =>
      'Add organizer photos';

  @override
  String get hostsEditHostedEventScreenVisiblecopyDD => '^\\d*\\.?\\d*';

  @override
  String get hostsEditHostedEventScreenVisiblecopyAZaZ09 => '[A-Za-z0-9_-]';

  @override
  String hostsEditHostedEventScreenVisiblecopyCapacitylimit({
    required Object capacityLimit,
  }) {
    return '$capacityLimit';
  }

  @override
  String get hostsEditHostedEventScreenVisiblecopyFree => 'Free';

  @override
  String get hostsCreateEventScreenVisiblecopyConfiguredin => 'configuredIn';

  @override
  String get hostsCreateEventScreenVisiblecopyCreateEvent => 'create_event';

  @override
  String hostsCreateEventSuccessScreenVisiblecopyCapacitylimitAttendees({
    required Object capacityLimit,
  }) {
    return '$capacityLimit attendees';
  }

  @override
  String get hostsCreateEventPhotoPickerVisiblecopyAddEventPhotos =>
      'Add event photos';

  @override
  String get hostsCreateEventPhotoPickerVisiblecopyAddPhotos => 'Add photos';

  @override
  String get hostsDraftPickerSheetVisiblecopyCouldNotDeleteDraft =>
      'Could not delete draft.';

  @override
  String get hostsEventDetailsStepVisiblecopyRequired => 'Required';

  @override
  String get hostsEventDetailsStepVisiblecopyTooShort => 'Too short';

  @override
  String get hostsEventDetailsStepVisiblecopyTooLong => 'Too long';

  @override
  String get hostsEventDetailsStepVisiblecopyDD => '^\\d*\\.?\\d*';

  @override
  String get hostsEventDetailsStepVisiblecopyInvalid => 'Invalid';

  @override
  String get hostsEventDetailsStepVisiblecopyMustBe0 => 'Must be > 0';

  @override
  String get hostsEventDetailsStepVisiblecopySelectAPace => 'Select a pace';

  @override
  String get hostsEventPolicyStepVisiblecopyRequired => 'Required';

  @override
  String get hostsEventPolicyStepVisiblecopyMin1 => 'Min 1';

  @override
  String get hostsEventPolicyStepVisiblecopyDD => '^\\d*\\.?\\d*';

  @override
  String get hostsEventPolicyStepVisiblecopyInvalid => 'Invalid';

  @override
  String get hostsEventPolicyStepVisiblecopyAZaZ09 => '[A-Za-z0-9_-]';

  @override
  String get hostsWhenStepVisiblecopyPleaseSelectADate =>
      'Please select a date';

  @override
  String get hostsWhenStepVisiblecopyRequired => 'Required';

  @override
  String get hostsWhenStepVisiblecopyDecreaseDuration => 'Decrease duration';

  @override
  String get hostsWhenStepVisiblecopyIncreaseDuration => 'Increase duration';

  @override
  String get hostsWhereStepVisiblecopyChooseAMeetingLocation =>
      'Choose a meeting location';

  @override
  String get hostsWhereStepVisiblecopyAddALocationName => 'Add a location name';

  @override
  String get hostsHostEventManageScreenVisiblecopyEventCancelled =>
      'Event cancelled.';

  @override
  String get hostsHostEventManageScreenVisiblecopyEventDeleted =>
      'Event deleted.';

  @override
  String hostsHostEventManageScreenVisiblecopyLabelCopied({
    required Object label,
  }) {
    return '$label copied.';
  }

  @override
  String
  get hostsHostEventManageScreenVisiblecopyHosteventmanagescreenCreatenamedinvitelinkFailed =>
      'HostEventManageScreen._createNamedInviteLink failed';

  @override
  String
  get hostsHostEventManageScreenVisiblecopyHosteventmanagescreenCopynamedinvitelinkFailed =>
      'HostEventManageScreen._copyNamedInviteLink failed';

  @override
  String hostsHostEventManageScreenVisiblecopyLabelDisabled({
    required Object label,
  }) {
    return '$label disabled.';
  }

  @override
  String
  get hostsHostEventManageScreenVisiblecopyHosteventmanagescreenDisablenamedinvitelinkFailed =>
      'HostEventManageScreen._disableNamedInviteLink failed';

  @override
  String
  get hostsHostEventManageScreenVisiblecopyHosteventmanagescreenSharehostprivatelinkFailed =>
      'HostEventManageScreen._shareHostPrivateLink failed';

  @override
  String get hostsHostEventManageScreenVisiblecopyFree => 'Free';

  @override
  String hostsHostEventManageScreenVisiblecopyBooked({required Object booked}) {
    return '$booked';
  }

  @override
  String hostsHostEventManageScreenVisiblecopyCapacitylimit({
    required Object capacityLimit,
  }) {
    return '/$capacityLimit';
  }

  @override
  String hostsHostEventManageScreenVisiblecopyWaitlisted({
    required Object waitlisted,
  }) {
    return '$waitlisted';
  }

  @override
  String get hostsHostEventManageScreenStateVisiblecopyNoPeopleMatchThis =>
      'No people match this search.';

  @override
  String get hostsHostEventManageScreenStateVisiblecopySlotsShowCapacityLeft =>
      'Slots show capacity left after booked people. New people appear here once they book or request access.';

  @override
  String
  get hostsHostEventManageScreenStateVisiblecopyBookedAndWaitlistedPeople =>
      'Booked and waitlisted people will appear here.';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyNoLiveRosterRows =>
      'No live roster rows match this search.';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyNoReportRowsMatch =>
      'No report rows match this search.';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyCheckedIn =>
      'Checked in';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyUndo => 'Undo';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyCheckIn => 'Check in';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyFree => 'Free';

  @override
  String get hostsHostEventManageScreenStateVisiblecopySharing => 'Sharing...';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyPublicEventLink =>
      'Public event link';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyLoadingLink =>
      'Loading link';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyInviteSetupUnavailable =>
      'Invite setup unavailable';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyPrivateInviteLink =>
      'Private invite link';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyInviteLinksUnavailable =>
      'Invite links unavailable';

  @override
  String get hostsHostEventManageScreenStateVisiblecopy1InviteLink =>
      '1 invite link';

  @override
  String hostsHostEventManageScreenStateVisiblecopyCountInviteLinks({
    required Object count,
  }) {
    return '$count invite links';
  }

  @override
  String
  get hostsHostEventManageScreenStateVisiblecopyEveryoneVisibleIsChecked =>
      'Everyone visible is checked in';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyNoCheckedInPeople =>
      'No checked-in people yet';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyNoWaitlistedPeople =>
      'No waitlisted people';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyRosterIsEmpty =>
      'Roster is empty';

  @override
  String get hostsHostEventManageScreenStateVisiblecopySwitchToInTo =>
      'Switch to In to review arrivals or All to see the full roster.';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyCheckedInPeopleWill =>
      'Checked-in people will appear here during the event.';

  @override
  String
  get hostsHostEventManageScreenStateVisiblecopyWaitlistedPeopleWillAppear =>
      'Waitlisted people will appear here for context.';

  @override
  String
  get hostsHostEventManageScreenStateVisiblecopySignedUpParticipantsWill =>
      'Signed-up participants will appear here when they book.';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyNoAttendedPeopleYet =>
      'No attended people yet';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyNoNoShowsYet =>
      'No no-shows yet';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyNoParticipantsYet =>
      'No participants yet';

  @override
  String
  get hostsHostEventManageScreenStateVisiblecopyCheckedInPeopleWill186cb6 =>
      'Checked-in people will appear here after the event.';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyBookedPeopleWhoDid =>
      'Booked people who did not check in will appear here.';

  @override
  String
  get hostsHostEventManageScreenStateVisiblecopyWaitlistHistoryWillAppear =>
      'Waitlist history will appear here when people queue for this event.';

  @override
  String
  get hostsHostEventManageScreenStateVisiblecopyAttendanceAndWaitlistHistory =>
      'Attendance and waitlist history will appear here once people sign up.';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyOfferSent =>
      'Offer sent';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyAcceptedOffer =>
      'Accepted offer';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyOfferExpired =>
      'Offer expired';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyApproved => 'Approved';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyViewProfile =>
      'View profile';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyWaitlisted =>
      'Waitlisted';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyProfileReady =>
      'Profile ready';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyBooked => 'Booked';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyCancelled => 'Cancelled';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyDeleted => 'Deleted';

  @override
  String get hostsHostEventManageScreenStateVisiblecopyParticipant =>
      'Participant';

  @override
  String get hostsHostClubTeamScreenVisiblecopyHostProfileSaved =>
      'Host profile saved.';

  @override
  String get hostsHostClubTeamScreenVisiblecopyHostProfileCreated =>
      'Host profile created.';

  @override
  String get hostsHostClubTeamScreenVisiblecopyCreatingProfile =>
      'Creating profile...';

  @override
  String get hostsHostClubTeamScreenVisiblecopyCreateHostProfile =>
      'Create host profile';

  @override
  String get hostsHostClubTeamScreenVisiblecopyAddRoleTitle => 'Add role title';

  @override
  String get hostsHostClubTeamScreenVisiblecopyAddAHostBio => 'Add a host bio';

  @override
  String get hostsHostAuthRequiredScreenVisiblecopySignIn => 'Sign in';

  @override
  String hostsHostClubProfileVisiblecopyMinageMaxage({
    required Object minAge,
    required Object maxAge,
  }) {
    return '$minAge–$maxAge';
  }

  @override
  String get hostsHostTodayVisiblecopyMorning => 'morning';

  @override
  String get hostsHostTodayVisiblecopyAfternoon => 'afternoon';

  @override
  String get hostsHostTodayVisiblecopyEvening => 'evening';

  @override
  String get hostsHostTodayLabelOwner => 'Owner';

  @override
  String get hostsHostTodayLabelHostTeam => 'Host team';

  @override
  String hostsHostTodayVisiblecopySignedupcount({
    required Object signedUpCount,
  }) {
    return '$signedUpCount';
  }

  @override
  String hostsHostTodayVisiblecopyWaitlistcount({
    required Object waitlistCount,
  }) {
    return '$waitlistCount';
  }

  @override
  String hostsHostTodayVisiblecopyTaskcount({required Object taskCount}) {
    return '$taskCount';
  }

  @override
  String get hostsHostInboxScreenVisiblecopySomePushAttemptsFailed =>
      'Some push attempts failed; Activity updates are still available.';

  @override
  String hostsHostInboxScreenVisiblecopyBroadcastSentToRecipientcount({
    required Object recipientCount,
    required Object suffix,
  }) {
    return 'Broadcast sent to $recipientCount people.$suffix';
  }

  @override
  String get hostsHostInboxScreenVisiblecopySelectAnEventOr =>
      'Select an event or general inquiries';

  @override
  String get hostsHostInboxScreenVisiblecopyGeneralInquiries =>
      'General inquiries';

  @override
  String get hostsHostInboxScreenVisiblecopyEventInquiry => 'Event inquiry';

  @override
  String hostsHostInboxScreenVisiblecopyLongweekdayEventtitlelabel({
    required Object longWeekday,
    required Object eventTitleLabel,
  }) {
    return '$longWeekday $eventTitleLabel';
  }

  @override
  String hostsHostInboxScreenVisiblecopyTonightTime({required Object time}) {
    return 'Tonight $time';
  }

  @override
  String hostsHostInboxScreenVisiblecopyShortdatelabelTime({
    required Object shortDateLabel,
    required Object time,
  }) {
    return '$shortDateLabel · $time';
  }

  @override
  String hostsHostInboxScreenVisiblecopyEventnameTiming({
    required Object eventName,
    required Object timing,
  }) {
    return '$eventName · $timing';
  }

  @override
  String
  hostsHostInboxScreenVisiblecopyTitleShortdatelabelCompacttimerangelabel({
    required Object title,
    required Object shortDateLabel,
    required Object compactTimeRangeLabel,
  }) {
    return '$title · $shortDateLabel · $compactTimeRangeLabel';
  }

  @override
  String hostsHostInboxScreenVisiblecopyNameAttendee({required Object name}) {
    return '$name attendee';
  }

  @override
  String get hostsHostPaymentAccountCardVisiblecopyNotSetUp => 'Not set up';

  @override
  String get hostsHostPaymentAccountCardVisiblecopyReady => 'Ready';

  @override
  String get hostsHostPaymentAccountCardVisiblecopyActionNeeded =>
      'Action needed';

  @override
  String get hostsHostPaymentAccountCardVisiblecopyPending => 'Pending';

  @override
  String
  get hostsHostPaymentAccountControllerCardVisiblecopyHostpaymentaccountcontrollercardStartonboardingFailed =>
      'HostPaymentAccountControllerCard.startOnboarding failed';

  @override
  String
  get hostsHostPaymentAccountControllerCardVisiblecopyHostpaymentaccountcontrollercardRefreshFailed =>
      'HostPaymentAccountControllerCard.refresh failed';

  @override
  String hostsHostClubToolsVisiblecopyTotalbooked({
    required Object totalBooked,
  }) {
    return '$totalBooked';
  }

  @override
  String hostsHostClubToolsVisiblecopyTotalwaitlist({
    required Object totalWaitlist,
  }) {
    return '$totalWaitlist';
  }

  @override
  String get hostsHostEventAttendancePanelVisiblecopyRevenueCsvReady =>
      'Revenue CSV ready.';

  @override
  String get hostsHostEventAttendancePanelVisiblecopySharerevenuereportFailed =>
      '_shareRevenueReport failed';

  @override
  String get hostsHostEventAttendancePanelVisiblecopyOpsCsvReady =>
      'Ops CSV ready.';

  @override
  String get hostsHostEventAttendancePanelVisiblecopyShareopsreportFailed =>
      '_shareOpsReport failed';

  @override
  String get hostsHostEventAttendancePanelVisiblecopyGuest => 'Guest';

  @override
  String get hostsHostEventAttendancePanelVisiblecopySignal => 'Signal';

  @override
  String get hostsHostEventAttendancePanelVisiblecopyHostAction =>
      'Host action';

  @override
  String get hostsHostEventAttendancePanelVisiblecopyStatus => 'Status';

  @override
  String get hostsHostEventAttendancePanelVisiblecopyName => 'Name';

  @override
  String get hostsHostEventAttendancePanelVisiblecopyAttendance => 'Attendance';

  @override
  String get hostsHostEventAttendancePanelVisiblecopyPayment => 'Payment';

  @override
  String hostsHostEventAttendancePanelVisiblecopyValue({
    required Object value,
  }) {
    return '$value';
  }

  @override
  String
  hostsHostEventAttendancePanelVisiblecopyRemainingaftersendStillWaitingAfter({
    required Object remainingAfterSend,
  }) {
    return '$remainingAfterSend still waiting after this offer';
  }

  @override
  String hostsHostEventAttendancePanelVisiblecopyNextCountPersonnounOn({
    required Object count,
    required Object personNoun,
  }) {
    return 'Next $count $personNoun on the waitlist';
  }

  @override
  String hostsHostEventToolsVisiblecopyHostedEventValue1Of({
    required Object value1,
    required Object length,
  }) {
    return 'Hosted event $value1 of $length';
  }

  @override
  String hostsHostEventToolsVisiblecopyHostedEventSelectedindexOf({
    required Object selectedIndex,
    required Object length,
  }) {
    return 'Hosted event $selectedIndex of $length';
  }

  @override
  String
  get hostsHostTeamManagementSectionVisiblecopyHostteammanagementsectionShowaddhostsheetFailed =>
      'HostTeamManagementSection._showAddHostSheet failed';

  @override
  String get hostsHostTeamManagementSectionVisiblecopyHostAdded =>
      'Host added.';

  @override
  String
  get hostsHostTeamManagementSectionVisiblecopyHostteammanagementsectionConfirmhostactionFailed =>
      'HostTeamManagementSection._confirmHostAction failed';

  @override
  String get hostsHostTeamManagementSectionVisiblecopyTransfer => 'transfer';

  @override
  String get hostsHostTeamManagementSectionVisiblecopyRemove => 'remove';

  @override
  String get imageUploadsProfilePhotoEditorScreenVisiblecopyDelete => 'Delete';

  @override
  String get onboardingOnboardingStepVisiblecopyWelcome => 'Welcome';

  @override
  String get onboardingOnboardingStepVisiblecopyYourName => 'Your name';

  @override
  String get onboardingOnboardingStepVisiblecopyGender => 'Gender';

  @override
  String get onboardingOnboardingStepVisiblecopyInstagram => 'Instagram';

  @override
  String get onboardingOnboardingStepVisiblecopyPhotos => 'Photos';

  @override
  String get onboardingOnboardingStepVisiblecopyPrompts => 'Prompts';

  @override
  String get onboardingOnboardingStepVisiblecopyRunningStyle => 'Running style';

  @override
  String get onboardingPhotosPageVisiblecopyUploadFailedPleaseTry =>
      'Upload failed. Please try again.';

  @override
  String get onboardingWelcomePageVisiblecopyReducedMotion => 'reduced_motion';

  @override
  String get onboardingWelcomePageVisiblecopyDirect => 'direct';

  @override
  String get onboardingWelcomePageVisiblecopyAnimated => 'animated';

  @override
  String get onboardingWelcomePageVisiblecopyContinuePhone => 'continue_phone';

  @override
  String get onboardingWelcomePageVisiblecopySeeWhatsOn => 'see_whats_on';

  @override
  String get onboardingWelcomePageVisiblecopyFrom => 'from';

  @override
  String get onboardingWelcomePageVisiblecopyAuth => '/auth';

  @override
  String publicProfilePublicProfileScreenVisiblecopyNameHasBeenBlocked({
    required Object name,
  }) {
    return '$name has been blocked.';
  }

  @override
  String get publicProfilePublicProfileScreenVisiblecopyReportSubmitted =>
      'Report submitted.';

  @override
  String get publicProfilePublicProfileScreenVisiblecopyReport => 'report';

  @override
  String get publicProfilePublicProfileScreenVisiblecopyBlock => 'block';

  @override
  String get publicProfilePublicProfileScreenVisiblecopyHarassmentOrAbuse =>
      'harassment_or_abuse';

  @override
  String
  get publicProfilePublicProfileScreenVisiblecopyFakeOrMisleadingProfile =>
      'fake_or_misleading_profile';

  @override
  String get publicProfilePublicProfileScreenVisiblecopyInappropriateContent =>
      'inappropriate_content';

  @override
  String get publicProfilePublicProfileScreenVisiblecopyOther => 'other';

  @override
  String swipesFiltersScreenVisiblecopyRoundFormatpreferredmatchage({
    required Object round,
    required Object formatPreferredMatchAge,
  }) {
    return '$round – $formatPreferredMatchAge';
  }

  @override
  String get swipesCatchProfileViewVisiblecopyRunningRhythm => 'Running rhythm';

  @override
  String get swipesProfileViewMapperVisiblecopyCompatibility => 'compatibility';

  @override
  String swipesProfileViewMapperVisiblecopyProfilePromptPromptid({
    required Object promptId,
  }) {
    return 'profile-prompt-$promptId';
  }

  @override
  String get swipesProfileViewMapperVisiblecopyRunning => 'running';

  @override
  String get swipesProfileViewMapperVisiblecopyRunningRhythm =>
      'Running rhythm';

  @override
  String get swipesProfileViewMapperVisiblecopyDetails => 'details';

  @override
  String get swipesProfileViewMapperVisiblecopyDetails4d7b56 => 'Details';

  @override
  String get swipesProfileViewMapperVisiblecopyLifestyle => 'lifestyle';

  @override
  String get swipesProfileViewMapperVisiblecopyLifestyle900024 => 'Lifestyle';

  @override
  String get swipesProfileViewMapperVisiblecopyHeroPhoto => 'hero-photo';

  @override
  String get swipesProfileViewMapperVisiblecopyMainPhoto => 'Main photo';

  @override
  String get swipesProfileViewMapperVisiblecopyMainProfilePhoto =>
      'main profile photo';

  @override
  String get userProfileSelfProfileEditTabStateVisiblecopyDisplayname =>
      'displayName';

  @override
  String get userProfileSelfProfileEditTabStateVisiblecopyEmaile69bb2 =>
      'email';

  @override
  String
  get userProfileSelfProfileEditTabStateVisiblecopyInstagramhandle71eebb =>
      'instagramHandle';

  @override
  String userProfileSelfProfileEditTabStateVisiblecopyHeightCm({
    required Object height,
  }) {
    return '$height cm';
  }

  @override
  String get userProfileSelfProfileEditTabStateVisiblecopyHeight => 'Height';

  @override
  String get userProfileSelfProfileEditTabStateVisiblecopyCity => 'city';

  @override
  String get userProfileSelfProfileEditTabStateVisiblecopyOccupation =>
      'occupation';

  @override
  String get userProfileSelfProfileEditTabStateVisiblecopyCompanyfd8aec =>
      'company';

  @override
  String get userProfileSelfProfileEditTabStateVisiblecopyEducation =>
      'education';

  @override
  String get userProfileSelfProfileEditTabStateVisiblecopyReligion =>
      'religion';

  @override
  String get userProfileSelfProfileEditTabStateVisiblecopyLanguages =>
      'languages';

  @override
  String get userProfileSelfProfileEditTabStateVisiblecopyRelationshipgoal =>
      'relationshipGoal';

  @override
  String userProfileSelfProfileEditTabStateVisiblecopyFormatpaceKm({
    required Object formatPace,
  }) {
    return '$formatPace/km';
  }

  @override
  String get userProfileSelfProfileEditTabStateVisiblecopyPreferreddistances =>
      'preferredDistances';

  @override
  String get userProfileSelfProfileEditTabStateVisiblecopyRunningreasons =>
      'runningReasons';

  @override
  String get userProfileSelfProfileEditTabStateVisiblecopyPreferredruntimes =>
      'preferredRunTimes';

  @override
  String get userProfileSelfProfileEditTabStateVisiblecopyDrinking =>
      'drinking';

  @override
  String get userProfileSelfProfileEditTabStateVisiblecopySmoking => 'smoking';

  @override
  String get userProfileSelfProfileEditTabStateVisiblecopyWorkout => 'workout';

  @override
  String get userProfileSelfProfileEditTabStateVisiblecopyDiet => 'diet';

  @override
  String get userProfileSelfProfileEditTabStateVisiblecopyChildren =>
      'children';

  @override
  String userProfileInlineEditorHeightBodyHeightcmCm({
    required Object heightCm,
  }) {
    return '$heightCm cm';
  }

  @override
  String userProfileInlineEditorRangeBodyLabeltextLabeltext2({
    required Object labelText,
    required Object labelText2,
  }) {
    return '$labelText - $labelText2';
  }

  @override
  String
  userProfileProfileTabVisiblecopyCompletedpromptcountOfMaxprofilepromptanswersAnswered({
    required Object completedPromptCount,
    required Object maxProfilePromptAnswers,
  }) {
    return '$completedPromptCount of $maxProfilePromptAnswers answered';
  }

  @override
  String
  userProfileProfileTabVisiblecopyCompletedcountOfMaximumprofilephotocountAdded({
    required Object completedCount,
    required Object maximumProfilePhotoCount,
  }) {
    return '$completedCount of $maximumProfilePhotoCount added';
  }

  @override
  String get userProfileProfileTabSkeletonVisiblecopyLoading => 'loading';

  @override
  String get profileQualityPhotosTitle => 'Add 3 clear photos';

  @override
  String get profileQualityPhotosDetail =>
      'A mix of face, full-body, and running/social photos gives people confidence.';

  @override
  String get profileQualityPromptsTitle => 'Answer all 3 prompts';

  @override
  String get profileQualityPromptsDetail =>
      'Specific prompts create the easiest openings for comments and likes.';

  @override
  String get profileQualityPhotoPromptsTitle => 'Add photo prompts';

  @override
  String get profileQualityPhotoPromptsDetail =>
      'Prompts make photos easier to react to without writing captions.';

  @override
  String get profileQualityRelationshipGoalTitle =>
      'Add what you are looking for';

  @override
  String get profileQualityRelationshipGoalDetail =>
      'Intent helps people decide whether starting a conversation makes sense.';

  @override
  String get profileQualityRunningIdentityTitle =>
      'Fill out your running identity';

  @override
  String get profileQualityRunningIdentityDetail =>
      'Distance, reason, and time-of-day preferences power better compatibility signals.';

  @override
  String get profileQualityBackgroundTitle => 'Add one background detail';

  @override
  String get profileQualityBackgroundDetail =>
      'Height, work, education, or languages help round out the card.';

  @override
  String get profileQualityLifestyleTitle => 'Add one lifestyle detail';

  @override
  String get profileQualityLifestyleDetail =>
      'Small details make the profile feel less generic.';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyProfileInsights =>
      'Profile insights';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyLoadingProfileInsights =>
      'Loading profile insights';

  @override
  String get userAnalyticsUserAnalyticsCopyEmptytitleInsightsAreWarmingUp =>
      'Insights are warming up';

  @override
  String get userAnalyticsUserAnalyticsCopyEmptybodyYouWillSeeTrends =>
      'You will see trends here after Catch has enough event and profile activity.';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyRange => 'Range';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyTrend => 'Trend';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopySuggestions =>
      'Suggestions';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyDataCoverage =>
      'Data coverage';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyPartial => 'Partial';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyMissing => 'Missing';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyLast7Days =>
      'Last 7 days';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyLast30Days =>
      'Last 30 days';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyLast90Days =>
      'Last 90 days';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyThisMonth => 'This month';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyProfileViews =>
      'Profile views';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyCaughtYou => 'Caught you';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyMutualCatches =>
      'Mutual catches';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyChatsStarted =>
      'Chats started';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyEventsAttended =>
      'Events attended';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyFollowThrough =>
      'Follow-through';

  @override
  String
  get userAnalyticsUserAnalyticsCopyVisiblecopyPostEventProfileAttention =>
      'Post-event profile attention.';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyPeopleWhoShowedInterest =>
      'People who showed interest.';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyMatchesWhereInterestWas =>
      'Matches where interest was mutual.';

  @override
  String
  get userAnalyticsUserAnalyticsCopyVisiblecopyConversationsThatOpenedAfter =>
      'Conversations that opened after matching.';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyEventsYouAttended =>
      'Events you attended.';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyChatsStartedFromMutual =>
      'Chats started from mutual catches.';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyViews => 'Views';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyInterest => 'Interest';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyMatches => 'Matches';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyChats => 'Chats';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyAttended => 'Attended';

  @override
  String get userAnalyticsUserAnalyticsCopyTitleTuneYourProfile =>
      'Tune your profile';

  @override
  String get userAnalyticsUserAnalyticsCopyBodyAFreshPromptOr =>
      'A fresh prompt or first photo can make post-event interest easier to read.';

  @override
  String get userAnalyticsUserAnalyticsCopyTitleOpenTheLoop => 'Open the loop';

  @override
  String get userAnalyticsUserAnalyticsCopyBodyAShortMessageAfter =>
      'A short message after a mutual catch is the clearest follow-through signal.';

  @override
  String get userAnalyticsUserAnalyticsCopyTitleShowUpInPerson =>
      'Show up in person';

  @override
  String get userAnalyticsUserAnalyticsCopyBodyTheStrongestProfileTrends =>
      'The strongest profile trends start after attended events.';

  @override
  String get userAnalyticsUserAnalyticsCopyTitleKeepShowingUp =>
      'Keep showing up';

  @override
  String get userAnalyticsUserAnalyticsCopyBodyRepeatedEventAttendanceGives =>
      'Repeated event attendance gives Catch better connection signal.';

  @override
  String get userAnalyticsUserAnalyticsCopyTitleKeepBuildingSignal =>
      'Keep building signal';

  @override
  String get userAnalyticsUserAnalyticsCopyBodyInsightsGetSharperAfter =>
      'Insights get sharper after more post-event profile views.';

  @override
  String get coreCatchPrivacyBadgeLabelPrivateToYou => 'Private to you';

  @override
  String get coreCatchPrivacyBadgeLabelHostCanSee => 'Host can see';

  @override
  String get coreCatchPrivacyBadgeLabelCatchPrivate => 'Catch private';

  @override
  String get eventSuccessEventSuccessLiveRevealCardLabelPodReveal =>
      'Pod reveal';

  @override
  String get eventSuccessEventSuccessLiveRevealCardLabelRotationReveal =>
      'Rotation reveal';

  @override
  String eventSuccessEventSuccessHostLiveVisiblecopyStepValue1TotalRound({
    required Object value1,
    required Object total,
  }) {
    return 'Step $value1/$total · Round';
  }

  @override
  String get eventSuccessEventSuccessHostLiveVisiblecopyRound => 'Round';

  @override
  String get eventSuccessEventSuccessHostLiveTitleRoundInPlay =>
      'Round in play';

  @override
  String get eventSuccessEventSuccessHostLiveVisiblecopyKeepRoundsTightReveal =>
      'Keep rounds tight; reveal scores between each. Swap anyone sitting out into a team.';

  @override
  String get eventSuccessEventSuccessHostLiveVisiblecopyAttendeesSeeGuestsSee =>
      'Attendees see: Guests see the current round and the live scoreboard.';

  @override
  String get eventSuccessEventSuccessHostSharedLabelSetup => 'Setup';

  @override
  String get eventSuccessEventSuccessHostSharedLabelLive => 'Live';

  @override
  String get eventSuccessEventSuccessHostSharedLabelReport => 'Report';

  @override
  String get eventsEventStatsGridVisiblecopyKm => 'km';

  @override
  String get eventsEventStatsGridLabelDistance => 'Distance';

  @override
  String get eventsEventStatsGridLabelActivity => 'Activity';

  @override
  String get eventsEventStatsGridLabelSpotsTaken => 'Spots taken';

  @override
  String get eventsEventStatsGridVisiblecopyPaceLevel => 'Pace level';

  @override
  String get eventsEventStatsGridVisiblecopySkillLevel => 'Skill level';

  @override
  String get eventsEventStatsGridVisiblecopyIntensity => 'Intensity';

  @override
  String get eventsEventStatsGridVisiblecopyEnergy => 'Energy';

  @override
  String eventsEventDetailScreenStateVisiblecopyClubReviewSummary({
    required Object rating,
    required Object reviewCount,
  }) {
    return '$rating FROM $reviewCount ORGANIZER REVIEWS';
  }

  @override
  String get dashboardDashboardFullViewModelTitleLetSFindYour =>
      'Let\'s find your first event';

  @override
  String dashboardDashboardFullViewModelTitleDashboardgreetingName({
    required Object dashboardGreeting,
    required Object name,
  }) {
    return '$dashboardGreeting, $name';
  }

  @override
  String get dashboardDashboardFullViewModelVisiblecopyMorning => 'Morning';

  @override
  String get dashboardDashboardFullViewModelVisiblecopyAfternoon => 'Afternoon';

  @override
  String get dashboardDashboardFullViewModelVisiblecopyEvening => 'Evening';

  @override
  String get coreAppErrorMessageVisiblecopyExploreIsStillGetting =>
      'Explore is still getting set up. Please try again in a moment.';

  @override
  String get coreAppErrorMessageVisiblecopyConnectionIssue =>
      'Connection issue';

  @override
  String get coreAppErrorMessageVisiblecopySignInRequired => 'Sign in required';

  @override
  String get coreAppErrorMessageVisiblecopyActionUnavailable =>
      'Action unavailable';

  @override
  String get coreAppErrorMessageVisiblecopyCheckYourDetails =>
      'Check your details';

  @override
  String get coreAppErrorMessageVisiblecopyPaymentCancelled =>
      'Payment cancelled';

  @override
  String get coreAppErrorMessageVisiblecopyPaymentVerificationFailed =>
      'Payment verification failed';

  @override
  String get coreAppErrorMessageVisiblecopyPaymentFailed => 'Payment failed';

  @override
  String get coreAppErrorMessageVisiblecopyPaymentUnavailable =>
      'Payment unavailable';

  @override
  String get coreAppErrorMessageVisiblecopyEventSignupUnavailable =>
      'Event signup unavailable';

  @override
  String get coreAppErrorMessageVisiblecopyUploadFailed => 'Upload failed';

  @override
  String get coreAppErrorMessageVisiblecopyActionFailed => 'Action failed';

  @override
  String get coreAppErrorMessageVisiblecopySessionVerificationFailed =>
      'Session verification failed';

  @override
  String get coreAppErrorMessageVisiblecopyNotificationsUnavailable =>
      'Notifications unavailable';

  @override
  String get coreAppErrorMessageVisiblecopyUpdateCheckUnavailable =>
      'Update check unavailable';

  @override
  String get coreAppErrorMessageVisiblecopySignInProblem => 'Sign in problem';

  @override
  String get coreAppErrorMessageVisiblecopyDashboardUnavailable =>
      'Dashboard unavailable';

  @override
  String get coreAppErrorMessageVisiblecopyExploreUnavailable =>
      'Explore unavailable';

  @override
  String get coreAppErrorMessageVisiblecopyProfileUnavailable =>
      'Profile unavailable';

  @override
  String get coreAppErrorMessageVisiblecopyEventUnavailable =>
      'Event unavailable';

  @override
  String get coreAppErrorMessageVisiblecopyClubUnavailable =>
      'Organizer unavailable';

  @override
  String get coreAppErrorMessageVisiblecopyMessagesUnavailable =>
      'Messages unavailable';

  @override
  String get coreAppErrorMessageVisiblecopyCatchesUnavailable =>
      'Catches unavailable';

  @override
  String get coreAppErrorMessageVisiblecopyPaymentsUnavailable =>
      'Payments unavailable';

  @override
  String get coreAppErrorMessageVisiblecopySomethingWentWrong =>
      'Something went wrong';

  @override
  String get coreAppErrorMessageVisiblecopySignIn => 'Sign in';

  @override
  String get coreAppErrorMessageVisiblecopyTryUploadAgain => 'Try upload again';

  @override
  String get coreAppErrorMessageVisiblecopyTryPaymentAgain =>
      'Try payment again';

  @override
  String get coreAppErrorMessageVisiblecopyReloadMessages => 'Reload messages';

  @override
  String get coreAppErrorMessageVisiblecopyReloadExplore => 'Reload Explore';

  @override
  String get coreAppErrorMessageVisiblecopyReloadProfile => 'Reload profile';

  @override
  String get coreAppErrorMessageVisiblecopyReloadEvent => 'Reload event';

  @override
  String get coreAppErrorMessageVisiblecopyReloadClub => 'Reload organizer';

  @override
  String get coreAppErrorMessageVisiblecopyReloadCatches => 'Reload catches';

  @override
  String get coreAppErrorMessageVisiblecopyReloadPayments => 'Reload payments';

  @override
  String get coreAppErrorMessageVisiblecopyTryAgain => 'Try again';

  @override
  String get coreAppErrorMessageVisiblecopyProfileNotFound =>
      'Profile not found';

  @override
  String get coreAppErrorMessageVisiblecopyExploreItemNotFound =>
      'Explore item not found';

  @override
  String get coreAppErrorMessageVisiblecopyEventNotFound => 'Event not found';

  @override
  String get coreAppErrorMessageVisiblecopyClubNotFound =>
      'Organizer not found';

  @override
  String get coreAppErrorMessageVisiblecopyChatNotFound => 'Chat not found';

  @override
  String get coreAppErrorMessageVisiblecopyCatchesNotFound =>
      'Catches not found';

  @override
  String get coreAppErrorMessageVisiblecopyPaymentNotFound =>
      'Payment not found';

  @override
  String get coreAppErrorMessageVisiblecopyNotFound => 'Not found';

  @override
  String get hostsHostOperationsScreenStateTitleClubs => 'Organizers';

  @override
  String get imageUploadsProfilePhotoEditorScreenLabelNoPrompt => 'No prompt';

  @override
  String get publicProfilePublicProfileScreenStateTitleProfile => 'Profile';

  @override
  String get hostsCreateEventScreenVisiblecopyUnsavedChanges =>
      'Unsaved changes';

  @override
  String get hostsCreateEventScreenVisiblecopyYouHaveUnsavedChanges =>
      'You have unsaved changes. Would you like to save a draft?';

  @override
  String get hostsCreateEventScreenLabelDiscard => 'Discard';

  @override
  String get hostsCreateEventScreenLabelSaveDraft => 'Save draft';

  @override
  String get hostsDraftPickerSheetVisiblecopyDeleteDraft => 'Delete draft?';

  @override
  String get hostsDraftPickerSheetLabelCancel => 'Cancel';

  @override
  String get hostsDraftPickerSheetLabelDelete => 'Delete';

  @override
  String hostsDraftPickerSheetVisiblecopyThisWillPermanentlyDelete({
    required Object summary,
  }) {
    return 'This will permanently delete \"$summary\".';
  }

  @override
  String swipesProfileCardContentTextHeightCm({required Object height}) {
    return '$height cm';
  }

  @override
  String swipesProfileCardContentTextOccupationAtCompany({
    required Object occupation,
    required Object company,
  }) {
    return '$occupation at $company';
  }

  @override
  String get onboardingPhotosPageStateVisiblecopyFinishUploadingYourPhotos =>
      'Finish uploading your photos to continue.';

  @override
  String get onboardingPhotosPageStateLabel1MorePhoto => '1 more photo';

  @override
  String onboardingPhotosPageStateLabelRemainingphotosMorePhotos({
    required Object remainingPhotos,
  }) {
    return '$remainingPhotos more photos';
  }

  @override
  String onboardingPhotosPageStateVisiblecopyAddLabelToContinue({
    required Object label,
  }) {
    return 'Add $label to continue.';
  }

  @override
  String get onboardingPhotosPageStateVisiblecopyThisOnlyGatesCatches =>
      'This only gates Catches. Event booking stays available.';

  @override
  String get onboardingPhotosPageStateVisiblecopyRunningPhotosBoostCatches =>
      'Running photos boost catches by 2.3x.';

  @override
  String
  hostsHostEventManageScreenStateVisiblecopyPriceinpaiseGrossEstimateCheckedincount({
    required Object priceInPaise,
    required Object checkedInCount,
    required Object noShowCount,
    required Object waitlistCount,
  }) {
    return '$priceInPaise gross estimate · $checkedInCount attended · $noShowCount no-shows · $waitlistCount waitlisted.';
  }

  @override
  String get coreAppErrorMessageVisiblecopySomethingWentWrongPlease =>
      'Something went wrong. Please try again.';

  @override
  String get coreAppErrorMessageVisiblecopyUnableToCheckThe =>
      'Unable to check the latest app configuration right now.';

  @override
  String get coreAppErrorMessageVisiblecopyUnableToVerifyThis =>
      'Unable to verify this app session. Please try again.';

  @override
  String get coreAppErrorMessageVisiblecopyUnableToUpdateNotification =>
      'Unable to update notification settings right now.';

  @override
  String get coreAppErrorMessageVisiblecopyPleaseSignInTo =>
      'Please sign in to continue.';

  @override
  String get coreAppErrorMessageVisiblecopyPaymentWasCancelled =>
      'Payment was cancelled.';

  @override
  String get coreAppErrorMessageVisiblecopyPaymentFailedPleaseTry =>
      'Payment failed. Please try again.';

  @override
  String get coreAppErrorMessageVisiblecopyPaymentCouldNotBe =>
      'Payment could not be verified. Please contact support.';

  @override
  String get coreAppErrorMessageVisiblecopyPaidBookingsAreOnly =>
      'Paid bookings are only available on Android and iOS.';

  @override
  String get coreAppErrorMessageVisiblecopyWeCouldNotFind =>
      'We could not find what you requested.';

  @override
  String get coreAppErrorMessageVisiblecopyThatImageIsToo =>
      'That image is too large. Please choose a smaller image.';

  @override
  String get coreAppErrorMessageVisiblecopyPleaseChooseAnImage =>
      'Please choose an image file.';

  @override
  String get coreAppErrorMessageVisiblecopyThatImageCouldNot =>
      'That image could not be uploaded. Please choose another image.';

  @override
  String get coreAppErrorMessageVisiblecopyPleaseEnterAValid =>
      'Please enter a valid phone number.';

  @override
  String get coreAppErrorMessageVisiblecopyThatCodeIsInvalid =>
      'That code is invalid. Please try again.';

  @override
  String get coreAppErrorMessageVisiblecopyThatCodeExpiredPlease =>
      'That code expired. Please request a new one.';

  @override
  String get coreAppErrorMessageVisiblecopyWeAreHavingTrouble =>
      'We are having trouble connecting. Please check your internet and try again.';

  @override
  String get coreAppErrorMessageVisiblecopyTheRequestTimedOut =>
      'The request timed out. Please try again.';

  @override
  String get coreAppErrorMessageVisiblecopyTooManyAttemptsPlease =>
      'Too many attempts. Please wait a bit and try again.';

  @override
  String get coreAppErrorMessageVisiblecopyYouDoNotHave =>
      'You do not have permission to do that.';

  @override
  String get coreAppErrorMessageVisiblecopyThisAlreadyExists =>
      'This already exists.';

  @override
  String get coreAppErrorMessageVisiblecopyTheOperationCouldNot =>
      'The operation could not be completed. Please try again.';

  @override
  String get coreAppErrorMessageVisiblecopyThisDataIsStill =>
      'This data is still getting set up. Please try again in a moment.';

  @override
  String get coreAppErrorMessageVisiblecopyThisSignInMethod =>
      'This sign-in method is not enabled.';

  @override
  String get coreAppErrorMessageVisiblecopyThisAccountHasBeen =>
      'This account has been disabled.';

  @override
  String get coreAppErrorMessageVisiblecopyUnableToFinishSign =>
      'Unable to finish sign-in on this device. Please restart the app and request a new code.';

  @override
  String get coreAppErrorMessageVisiblecopyVerificationWasCancelledPlease =>
      'Verification was cancelled. Please try again when ready.';

  @override
  String get coreAppErrorMessageVisiblecopyUnableToCompleteThe =>
      'Unable to complete the verification check. Please close the verification window and try again.';

  @override
  String get coreAppErrorMessageVisiblecopyPleaseCompleteYourBasic =>
      'Please complete your basic profile details before continuing.';

  @override
  String get coreAppErrorMessageVisiblecopyPleaseChooseYourDating =>
      'Please choose your dating preferences before continuing.';

  @override
  String get coreAppErrorMessageVisiblecopyPleaseChooseWhoYou =>
      'Please choose who you want to see before continuing.';

  @override
  String get coreAppErrorMessageVisiblecopyPleaseAddAValid =>
      'Please add a valid phone number before continuing.';

  @override
  String get coreAppErrorMessageVisiblecopyPleaseVerifyYourPhone =>
      'Please verify your phone number before continuing.';

  @override
  String get coreAppErrorMessageVisiblecopyPleaseCompleteYourAccess =>
      'Please complete your access application.';

  @override
  String get coreAppErrorMessageVisiblecopyThisAccessApplicationIs =>
      'This access application is already locked for review.';

  @override
  String get coreAppErrorMessageVisiblecopyOnlyAClubHost =>
      'Only an organizer manager can edit this organizer.';

  @override
  String get coreAppErrorMessageVisiblecopyOnlyTheClubOwner =>
      'Only the organizer owner can edit organizer details.';

  @override
  String get coreAppErrorMessageVisiblecopyChooseAClubBefore =>
      'Choose an organizer before creating the event.';

  @override
  String get coreAppErrorMessageVisiblecopyAddAMeetingLocation =>
      'Add a meeting location before creating the event.';

  @override
  String get coreAppErrorMessageVisiblecopyProfilesAreTakingToo =>
      'Profiles are taking too long to load. Please check your connection and try again.';

  @override
  String get coreAppErrorMessageVisiblecopyProfileChangedWhileSaving =>
      'Profile changed while saving. Please try again.';

  @override
  String get coreAppErrorMessageVisiblecopyCheckTheHighlightedDetails =>
      'Check the highlighted details and try again.';

  @override
  String coreCatchFieldVisiblecopySelectTolowercase({
    required Object toLowerCase,
  }) {
    return 'Select $toLowerCase';
  }

  @override
  String coreCatchFieldVisiblecopyAddFieldLabel({required Object fieldLabel}) {
    return 'Add $fieldLabel';
  }

  @override
  String exploreExploreMapScreenLabelWithinDistance({required int distanceKm}) {
    return 'Within $distanceKm km';
  }

  @override
  String get exploreExploreMapScreenLabelDistance => 'Distance';

  @override
  String get exploreExploreMapScreenValueAnyDistance => 'Any';

  @override
  String exploreExploreMapScreenValueDistanceKm({required int distanceKm}) {
    return '$distanceKm km';
  }

  @override
  String get exploreExploreMapScreenActionUseMyLocation => 'Use my location';

  @override
  String get exploreExploreMapScreenActionLocating => 'Locating';

  @override
  String get exploreExploreMapScreenSemanticsLocating =>
      'Finding your location';

  @override
  String exploreExploreMapScreenSemanticsDistanceValue({
    required Object distance,
  }) {
    return 'Distance, $distance. Tap to change';
  }

  @override
  String get exploreExploreMapScreenSemanticsUseMyLocation =>
      'Use my location to set a distance';

  @override
  String get exploreExploreMapScreenHintChangeDistance =>
      'Changes the distance filter';

  @override
  String get exploreExploreMapScreenMessageLocationUnavailable =>
      'Location is unavailable. You can still browse the map.';

  @override
  String get exploreExploreMapScreenMessageLocationServicesDisabled =>
      'Location Services are off. Turn them on in Settings to use a distance ring.';

  @override
  String get exploreExploreMapScreenMessageLocationPermissionDeniedForever =>
      'Location access is off for Catch. You can enable it in Settings.';

  @override
  String get exploreExploreMapScreenActionOpenSettings => 'Open settings';

  @override
  String eventsEventPinsMapSemanticsEventCluster({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '1 event',
    );
    return '$_temp0';
  }

  @override
  String get eventsEventPinsMapTooltipShowAllEventsAndDistance =>
      'Show all events and distance';

  @override
  String exploreExploreMapScreenTitleNoEventsWithinDistance({
    required int distanceKm,
  }) {
    return 'No events within $distanceKm km';
  }

  @override
  String exploreExploreMapScreenMessageTryWiderOrShowCity({
    required String cityLabel,
  }) {
    return 'Try a wider distance, or show every event in $cityLabel.';
  }

  @override
  String exploreExploreMapScreenActionExpandToDistance({
    required int distanceKm,
  }) {
    return 'Expand to $distanceKm km';
  }

  @override
  String get exploreExploreMapScreenActionShowAll => 'Show all';

  @override
  String get exploreExploreMapScreenTitleNoEventsMatchMap =>
      'No events match this map';

  @override
  String get exploreExploreMapScreenMessageChangeFiltersToBringEventsBack =>
      'Change your filters to bring events back into view.';

  @override
  String get eventsEventLocationMapBodyScreenTitleLocationUnavailable =>
      'Location unavailable';

  @override
  String get eventsEventLocationMapBodyScreenMessageThisEventDoesNot =>
      'This event does not have an exact pinned starting point yet.';

  @override
  String get userAnalyticsUserAnalyticsCopyVisiblecopyAvailable => 'Available';

  @override
  String get userAnalyticsUserAnalyticsCopyDataqualityParticipantSignals =>
      'Participant signals';

  @override
  String get userAnalyticsUserAnalyticsCopyDataqualityProfileExposure =>
      'Profile exposure';

  @override
  String get userAnalyticsUserAnalyticsCopyDataqualityAppEngagement =>
      'App engagement';

  @override
  String get userAnalyticsUserAnalyticsCopyDataqualityAnalyticsSource =>
      'Analytics source';

  @override
  String get sharedSearchLabel => 'Search';

  @override
  String get sharedActionDelete => 'Delete';

  @override
  String get sharedValidationRequired => 'Required';

  @override
  String get sharedValidationInvalid => 'Invalid';

  @override
  String get sharedValidationMinimumOne => 'Min 1';

  @override
  String get sharedValidationInviteCodeMinimum => 'Min 4 chars';

  @override
  String get sharedValidationInviteCodeMaximum => 'Max 64 chars';

  @override
  String get sharedValidationAgeRange => '18-99';

  @override
  String get sharedValidationMinimumAtMostMaximum => '<= max';

  @override
  String get sharedValidationMaximumAtLeastMinimum => '>= min';

  @override
  String get chatsEmptyStateNoCatchesTitle => 'No catches yet';

  @override
  String get chatsEmptyStateNoCatchesMessage =>
      'When someone catches you back after a shared event, the conversation opens here with that event as context.';

  @override
  String get chatsEmptyStateHostInboxTitle => 'No attendee queries yet';

  @override
  String get chatsEmptyStateHostInboxMessage =>
      'Guest and attendee questions will appear here once people reach out about an event.';

  @override
  String get chatsEmptyStateNoSearchResultsTitle =>
      'No chats match your search';

  @override
  String get chatsEmptyStateNoSearchResultsMessage =>
      'Try another name or clear the search field.';

  @override
  String get chatsEmptyStateNoHostSearchResultsTitle =>
      'No attendee queries match your search';

  @override
  String get chatsEmptyStateNoHostSearchResultsMessage =>
      'Try another attendee name or clear the search field.';

  @override
  String get chatsEmptyStateNoUnreadQueriesTitle => 'No unread queries';

  @override
  String get chatsEmptyStateNoUnreadQueriesMessage =>
      'New attendee questions will move here until you open their thread.';

  @override
  String get clubsClubShareCardFootnote =>
      'Shares a visual organizer card with the organizer link.';

  @override
  String clubsClubShareCardHostedBy({required String hostName}) {
    return 'Hosted by $hostName';
  }

  @override
  String clubsClubShareTextIntro({required String clubName}) {
    return 'Check out $clubName on Catch.';
  }

  @override
  String get clubsClubHostRoleOwner => 'OWNER';

  @override
  String get clubsClubHostRoleHost => 'HOST';

  @override
  String clubsClubHostEstablishedMeta({
    required String role,
    required String established,
  }) {
    return '$role · EST. $established';
  }

  @override
  String get clubsClubScheduleHostedBadge => 'HOSTED';

  @override
  String get clubsClubScheduleViewBadge => 'VIEW';

  @override
  String get eventsInviteShareButton => 'Share invite';

  @override
  String get eventsInviteShareFootnote =>
      'Shares a visual invite with the event link.';

  @override
  String eventsInviteShareSubject({required String eventTitle}) {
    return 'Join me at $eventTitle';
  }

  @override
  String get eventsInviteShareEventDetailIntro =>
      'This feels like your kind of plan.';

  @override
  String get eventsInviteShareBookingIntro =>
      'I just booked this. Come with me?';

  @override
  String get eventsInviteShareReferralIntro =>
      'I am going to this on Catch and thought of you.';

  @override
  String eventsInviteShareHostPrivateIntro({
    required String eventTitle,
    required String clubName,
  }) {
    return 'You are invited to $eventTitle from $clubName.';
  }

  @override
  String get eventsInviteShareHostPrivatePrompt =>
      'Use this private Catch invite to book your spot:';

  @override
  String get eventsInviteShareBookingPrompt => 'Book it on Catch:';

  @override
  String get eventsInviteShareFree => 'Free';

  @override
  String get eventsInviteShareFooter => 'Curated singles event';

  @override
  String eventsInviteShareSpotsLeft({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots left',
      one: '1 spot left',
    );
    return '$_temp0';
  }

  @override
  String get eventsInviteShareWaitlistOpen => 'Waitlist open';

  @override
  String get eventsTileStatusOpen => 'Open';

  @override
  String get eventsTileStatusJoined => 'You\'re in';

  @override
  String get eventsTileStatusSaved => 'Saved';

  @override
  String get eventsTileStatusRecommended => 'Recommended';

  @override
  String get eventsTileStatusHosted => 'Hosted';

  @override
  String get eventsTileStatusWaitlisted => 'Waitlisted';

  @override
  String get eventsTileStatusAttended => 'Attended';

  @override
  String get eventsTileStatusPast => 'Past';

  @override
  String get eventsTileStatusFull => 'Full';

  @override
  String get eventsTileStatusIneligible => 'Not eligible';

  @override
  String get eventsTileStatusCancelled => 'Cancelled';

  @override
  String get exploreRecommendationsTitleForYou => 'For you';

  @override
  String get eventsLocationPickerSelectedPlace => 'selected place';

  @override
  String get eventsLocationPickerSearchFailure =>
      'Could not search places. Try again.';

  @override
  String get eventsLocationPickerDetailsFailure =>
      'Could not load that place. Try another result.';

  @override
  String get eventSuccessSocialMissionTitle => 'Social mission';

  @override
  String get hostsAdmissionOpenCapacityDescription =>
      'Anyone eligible can book until the event reaches capacity.';

  @override
  String get hostsAdmissionInviteOnlyDescription =>
      'New invite-only events ask for an event-specific code.';

  @override
  String get hostsAdmissionBalancedSinglesDescription =>
      'Straight men and women are kept within one spot of each other.';

  @override
  String get hostsAdmissionFixedCohortCapsLabel => 'Fixed cohort caps';

  @override
  String get hostsAdmissionFixedCohortCapsDescription =>
      'Open booking with optional straight men and straight women caps.';

  @override
  String get hostsValidationEnterValidEmail => 'Enter a valid email.';

  @override
  String get hostsValidationEnterDisplayName => 'Enter a display name.';

  @override
  String get hostsProfileStatusActive => 'Active professional profile';

  @override
  String get hostsProfileStatusPending => 'Profile pending review';

  @override
  String get hostsProfileStatusSuspended => 'Profile suspended';

  @override
  String get hostsEventActionCancelling => 'Cancelling...';

  @override
  String get hostsEventActionCancelDetail => 'Keeps records · notifies guests';

  @override
  String get hostsEventActionDeleting => 'Deleting...';

  @override
  String get hostsEventActionDeleteDetail => 'Permanent removal';

  @override
  String get hostsEventEditSaveChanges => 'Save changes';

  @override
  String get hostsEventEditUpdated => 'Event updated.';

  @override
  String get hostsEventEditMissingStartingPoint =>
      'Pin a starting point before saving.';

  @override
  String get hostsEventEditInvalidSchedule =>
      'Event start must be in the future.';

  @override
  String get launchAccessValidationChooseCity => 'Please choose your city';

  @override
  String get launchAccessValidationChooseEventType =>
      'Choose at least one event type';

  @override
  String get launchAccessValidationChooseTime => 'Choose at least one time';

  @override
  String get launchAccessValidationTellUsMore => 'Tell us a little more.';

  @override
  String matchesCelebrationLikedBack({required String name}) {
    return '$name liked you back.';
  }

  @override
  String get onboardingRunningPrefsContinueBooking => 'Continue booking';

  @override
  String get onboardingRunningPrefsSave => 'Save run preferences';

  @override
  String get onboardingRunningPrefsBookingReasonLabel => 'Why do you run?';

  @override
  String get onboardingRunningPrefsReasonLabel => 'WHY DO YOU RUN?';

  @override
  String get onboardingRunningPrefsRunTimesLabel => 'FAVOURITE RUN TIMES';

  @override
  String get onboardingRunningPrefsEventTimesLabel => 'FAVOURITE EVENT TIMES';

  @override
  String get onboardingGenderValidationSelectGender =>
      'Please select your gender';

  @override
  String get onboardingGenderValidationSelectInterest =>
      'Please select who you want to see';

  @override
  String get paymentsHistorySupportMessage =>
      'Please contact Catch support for assistance with this booking.';

  @override
  String get safetyAccountUnblockedMessage => 'Account unblocked.';

  @override
  String get eventsEventPriceCopyFree => 'Free';

  @override
  String eventsEventPriceCopyFromPrice({required Object price}) {
    return 'From $price';
  }

  @override
  String get eventsEventPriceCopyPriceOnSource => 'Price on source';

  @override
  String coreCatchCountCopyEvents({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '1 event',
      zero: 'No events',
    );
    return '$_temp0';
  }

  @override
  String coreCatchDistanceFormatterMetersAway({required int meters}) {
    return '$meters m away';
  }

  @override
  String coreCatchDistanceFormatterKilometersAway({required String distance}) {
    return '$distance km away';
  }

  @override
  String get exploreExploreScreenStateAvailabilityOpen => 'Open';

  @override
  String get exploreExploreScreenStateAvailabilityApprovedToJoin =>
      'Approved to join';

  @override
  String get exploreExploreScreenStateAvailabilityRequestRequired =>
      'Request required';

  @override
  String get exploreExploreScreenStateAvailabilityWaitlistOpen =>
      'Waitlist open';

  @override
  String get exploreExploreScreenStateAvailabilityFull => 'Full';

  @override
  String get exploreExploreScreenStateAvailabilityFullForYou =>
      'Your group is full';

  @override
  String get exploreExploreScreenStateAvailabilityInviteRequired =>
      'Invite required';

  @override
  String get exploreExploreScreenStateAvailabilityMembersOnly => 'Members only';

  @override
  String get exploreExploreScreenStateAvailabilitySetPreferences =>
      'Set preferences';

  @override
  String get exploreExploreScreenStateAvailabilityEnded => 'Ended';

  @override
  String get exploreExploreScreenStateAvailabilityCancelled => 'Cancelled';

  @override
  String get exploreExploreScreenStateAvailabilityAgeRestricted =>
      'Age restricted';

  @override
  String exploreExploreScreenStateAvailabilityMinimumAge({
    required int minAge,
  }) {
    return 'Must be $minAge+';
  }

  @override
  String exploreExploreScreenStateAvailabilityMaximumAge({
    required int maxAge,
  }) {
    return 'Max age $maxAge';
  }

  @override
  String exploreExploreScreenStateAvailabilitySpotsLeft({required int spots}) {
    String _temp0 = intl.Intl.pluralLogic(
      spots,
      locale: localeName,
      other: '$spots spots left',
      one: '1 spot left',
    );
    return '$_temp0';
  }

  @override
  String exploreExploreScreenStateGoingCount({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count going',
      one: '1 going',
    );
    return '$_temp0';
  }

  @override
  String exploreExploreScreenStateGoingAvailability({
    required Object goingLabel,
    required Object availabilityLabel,
  }) {
    return '$goingLabel · $availabilityLabel';
  }

  @override
  String exploreExploreScreenStateClubRatingReviews({
    required Object rating,
    required int reviewCount,
  }) {
    String _temp0 = intl.Intl.pluralLogic(
      reviewCount,
      locale: localeName,
      other: '$reviewCount REVIEWS',
      one: '1 REVIEW',
      zero: 'NO REVIEWS',
    );
    return '$rating · $_temp0';
  }

  @override
  String exploreExploreScreenStateClubCardSemantics({
    required Object title,
    required Object caption,
    required Object supportingLabel,
    required Object memberCountLabel,
    required Object ratingReviewLabel,
  }) {
    return '$title, $caption, $supportingLabel, $memberCountLabel, $ratingReviewLabel';
  }

  @override
  String exploreExploreScreenStateExternalEventSemantics({
    required Object title,
    required Object sourceLabel,
    required Object statusLabel,
    required Object supportingLabel,
    required Object timePriceLabel,
    required Object readOnlySupplyLabel,
  }) {
    return '$title, $sourceLabel, $statusLabel, $supportingLabel, $timePriceLabel, $readOnlySupplyLabel';
  }
}
