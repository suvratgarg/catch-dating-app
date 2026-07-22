import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Consumer app title shown by the operating system and Flutter app shell.
  ///
  /// In en, this message translates to:
  /// **'Catch'**
  String get appTitleConsumer;

  /// Host app title shown by the operating system and Flutter app shell.
  ///
  /// In en, this message translates to:
  /// **'Catch Host'**
  String get appTitleHost;

  /// Primary retry action used when an operation can safely be attempted again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get sharedActionTryAgain;

  /// Persistent notice title shown when the device has no usable connection.
  ///
  /// In en, this message translates to:
  /// **'You\'\'re offline'**
  String get sharedOfflineTitle;

  /// Persistent notice body explaining that cached content may be stale while offline.
  ///
  /// In en, this message translates to:
  /// **'Some content may be out of date.'**
  String get sharedOfflineBody;

  /// Blocking startup error title when the app cannot verify the minimum supported version.
  ///
  /// In en, this message translates to:
  /// **'Could not verify app version'**
  String get sharedForceUpdateCheckErrorTitle;

  /// Blocking startup error body when the app cannot verify the minimum supported version.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get sharedForceUpdateCheckErrorBody;

  /// Primary guest action that opens phone-number authentication.
  ///
  /// In en, this message translates to:
  /// **'Continue with phone'**
  String get consumerAuthContinueWithPhone;

  /// Consumer bottom navigation label for the Home tab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get consumerNavigationHome;

  /// Consumer bottom navigation label for the Explore tab.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get consumerNavigationExplore;

  /// Consumer bottom navigation label for the Chats tab.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get consumerNavigationChats;

  /// Consumer bottom navigation label for the signed-in user''s profile tab.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get consumerNavigationProfile;

  /// Host bottom navigation label for the daily operations tab.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get hostNavigationToday;

  /// Host bottom navigation label for the event-management tab.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get hostNavigationEvents;

  /// Host bottom navigation label for attendee inquiries.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get hostNavigationInbox;

  /// Host bottom navigation label for organizer identity and settings.
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get hostNavigationOrganizer;

  /// Host inbox filter label showing the number of unread attendee inquiries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Unread} =1{Unread · 1} other{Unread · {count}}}'**
  String hostInboxUnreadCount({required int count});

  /// Heading on the phone-number sign-in step.
  ///
  /// In en, this message translates to:
  /// **'What\'\'s your number?'**
  String get authPhoneTitle;

  /// Explanation below the phone-number sign-in heading.
  ///
  /// In en, this message translates to:
  /// **'We\'\'ll send you a one-time code to verify.'**
  String get authPhoneSubtitle;

  /// Label for the sign-in phone number field.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get authPhoneFieldLabel;

  /// Search hint in the country-code picker.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get authSearchCountryHint;

  /// Primary action that sends the phone verification code.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get authSendCodeAction;

  /// Validation message for an invalid sign-in phone number.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number.'**
  String get authInvalidPhoneNumber;

  /// Heading on the one-time-code verification step.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get authOtpTitle;

  /// Explains which phone number received the one-time code.
  ///
  /// In en, this message translates to:
  /// **'Sent to {phoneNumber}'**
  String authOtpSentTo({required String phoneNumber});

  /// Fallback phone-number phrase if the OTP step has no displayable number.
  ///
  /// In en, this message translates to:
  /// **'your number'**
  String get authYourNumber;

  /// Primary action that verifies the one-time code.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authVerifyAction;

  /// Action that returns to phone-number entry.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get authChangeNumberAction;

  /// Status shown when another one-time code can be requested.
  ///
  /// In en, this message translates to:
  /// **'RESEND NOW'**
  String get authResendNowStatus;

  /// Countdown until another one-time code can be requested. Seconds are already zero-padded.
  ///
  /// In en, this message translates to:
  /// **'RESEND IN {minutes}:{seconds}'**
  String authResendCountdownStatus({
    required int minutes,
    required String seconds,
  });

  /// Action that requests another one-time code.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get authResendCodeAction;

  /// Disabled action label while another one-time code is being sent.
  ///
  /// In en, this message translates to:
  /// **'Sending OTP...'**
  String get authSendingCodeAction;

  /// Consumer chats screen heading.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get consumerChatsTitle;

  /// Host attendee inbox screen heading.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get hostInboxTitle;

  /// Host inbox subtitle describing attendee conversations.
  ///
  /// In en, this message translates to:
  /// **'Attendee queries'**
  String get hostInboxSubtitle;

  /// Search hint for a list of people or conversations.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get sharedSearchByNameHint;

  /// Tooltip and accessibility label for consumer chat search.
  ///
  /// In en, this message translates to:
  /// **'Search chats'**
  String get consumerSearchChatsAction;

  /// Tooltip and accessibility label for host attendee search.
  ///
  /// In en, this message translates to:
  /// **'Search attendees'**
  String get hostSearchAttendeesAction;

  /// Host inbox filter showing all attendee conversations.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get hostInboxAllFilter;

  /// Product copy used by lib/chats/presentation/chat_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Share card'**
  String get chatsChatScreenLabelShareCard;

  /// Product copy used by lib/chats/presentation/chat_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get chatsChatScreenLabelReport;

  /// Product copy used by lib/chats/presentation/chat_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get chatsChatScreenLabelBlock;

  /// Product copy used by lib/chats/presentation/chat_screen.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Chat actions'**
  String get chatsChatScreenTooltipChatActions;

  /// Product copy used by lib/chats/presentation/chat_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Messages unavailable'**
  String get chatsChatScreenTitleMessagesUnavailable;

  /// Product copy used by lib/chats/presentation/chat_screen.dart (CatchErrorState).
  ///
  /// In en, this message translates to:
  /// **'Reload messages'**
  String get chatsChatScreenCatcherrorstateReloadMessages;

  /// Product copy used by lib/chats/presentation/inbox/chat_inbox_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'New blast'**
  String get chatsChatInboxScreenTextNewBlast;

  /// Product copy used by lib/chats/presentation/inbox/chat_inbox_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Broadcast sending is not connected yet. Use this as the review surface for audience and template states.'**
  String get chatsChatInboxScreenTextBroadcastSendingIsNot;

  /// Product copy used by lib/chats/presentation/inbox/chat_inbox_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get chatsChatInboxScreenTextReminder;

  /// Product copy used by lib/chats/presentation/inbox/chat_inbox_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'See you tonight at 8. Doors open at 7:45.'**
  String get chatsChatInboxScreenTextSeeYouTonightAt;

  /// Product copy used by lib/chats/presentation/inbox/chat_inbox_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Meeting point'**
  String get chatsChatInboxScreenTextMeetingPoint;

  /// Product copy used by lib/chats/presentation/inbox/chat_inbox_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Share arrival notes, parking, or table details.'**
  String get chatsChatInboxScreenTextShareArrivalNotesParking;

  /// Product copy used by lib/chats/presentation/inbox/widgets/chats_list_body.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Reminders, the meeting point, changes'**
  String get chatsChatsListBodySubtitleRemindersTheMeetingPoint;

  /// Product copy used by lib/chats/presentation/widgets/chat_event_context_header.dart (title).
  ///
  /// In en, this message translates to:
  /// **'the same event'**
  String get chatsChatEventContextHeaderTitleTheSameEvent;

  /// Product copy used by lib/chats/presentation/widgets/chat_input_bar.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Send an image'**
  String get chatsChatInputBarMessageSendAnImage;

  /// Product copy used by lib/chats/presentation/widgets/chat_input_bar.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatsChatInputBarTitleMessage;

  /// Product copy used by lib/chats/presentation/widgets/chat_input_bar.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'Message...'**
  String get chatsChatInputBarPlaceholderMessage;

  /// Product copy used by lib/chats/presentation/widgets/chat_input_bar.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get chatsChatInputBarMessageSendMessage;

  /// Accessible busy-state label for the chat image action.
  ///
  /// In en, this message translates to:
  /// **'Uploading image'**
  String get chatsChatInputBarLabelUploadingImage;

  /// Accessible busy-state label for the chat send action.
  ///
  /// In en, this message translates to:
  /// **'Sending message'**
  String get chatsChatInputBarLabelSendingMessage;

  /// Product copy used by lib/chats/presentation/widgets/chat_message_list.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Messages unavailable'**
  String get chatsChatMessageListTitleMessagesUnavailable;

  /// Product copy used by lib/chats/presentation/widgets/chat_message_list.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Unable to load messages.'**
  String get chatsChatMessageListMessageUnableToLoadMessages;

  /// Product copy used by lib/chats/presentation/widgets/chat_message_list.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Say hi'**
  String get chatsChatMessageListTitleSayHi;

  /// Product copy used by lib/chats/presentation/widgets/chat_share_card.dart (text).
  ///
  /// In en, this message translates to:
  /// **'Shared from Catch.'**
  String get chatsChatShareCardTextSharedFromCatch;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Suvbot controls'**
  String get chatsSuvbotActionBarTextSuvbotControls;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'No typing needed'**
  String get chatsSuvbotActionBarTextNoTypingNeeded;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Refresh all'**
  String get chatsSuvbotActionBarLabelRefreshAll;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Create a test state'**
  String get chatsSuvbotActionBarTextCreateATestState;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Reset...'**
  String get chatsSuvbotActionBarLabelReset;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Reload controls'**
  String get chatsSuvbotActionBarLabelReloadControls;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Reset demo state'**
  String get chatsSuvbotActionBarTitleResetDemoState;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'These actions only touch demo-owned data.'**
  String get chatsSuvbotActionBarSubtitleTheseActionsOnlyTouch;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Match tester'**
  String get chatsSuvbotActionBarTextMatchTester;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Enter an allowlisted beta tester phone number.'**
  String get chatsSuvbotActionBarTextEnterAnAllowlistedBeta;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get chatsSuvbotActionBarTitlePhoneNumber;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Create match'**
  String get chatsSuvbotActionBarLabelCreateMatch;

  /// Product copy used by lib/clubs/presentation/detail/club_detail_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'clubId'**
  String get clubsClubDetailScreenBodyClubid;

  /// Product copy used by lib/clubs/presentation/detail/club_detail_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'eventId'**
  String get clubsClubDetailScreenBodyEventid;

  /// Product copy used by lib/clubs/presentation/detail/club_detail_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'uid'**
  String get clubsClubDetailScreenBodyUid;

  /// Product copy used by lib/clubs/presentation/detail/club_detail_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Organizer not found'**
  String get clubsClubDetailScreenTitleClubNotFound;

  /// Product copy used by lib/clubs/presentation/detail/club_detail_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This organizer is no longer available.'**
  String get clubsClubDetailScreenMessageThisClubIsNo;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_contact_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get clubsClubContactSectionTitleContact;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_body.dart (title).
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get clubsClubDetailBodyTitleAbout;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_body.dart (title).
  ///
  /// In en, this message translates to:
  /// **'What we do'**
  String get clubsClubDetailBodyTitleWhatWeDo;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_body.dart (title).
  ///
  /// In en, this message translates to:
  /// **'From the organizer'**
  String get clubsClubDetailBodyTitleFromTheClub;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_body.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Your hosts'**
  String get clubsClubDetailBodyTitleYourHosts;

  /// Authority badge for a crawled organizer listing that has not been claimed.
  ///
  /// In en, this message translates to:
  /// **'Unclaimed listing'**
  String get organizersAuthorityBadgeUnclaimed;

  /// Authority badge for an organizer listing supported by reviewed public sources but not owner verified.
  ///
  /// In en, this message translates to:
  /// **'Source backed'**
  String get organizersAuthorityBadgeSourceBacked;

  /// Authority badge for an organizer listing with a pending claim request.
  ///
  /// In en, this message translates to:
  /// **'Claim under review'**
  String get organizersAuthorityBadgeClaimPending;

  /// Authority badge for a claimed organizer listing that is not yet owner verified.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get organizersAuthorityBadgeClaimed;

  /// Authority badge for a first-party organizer created in Catch without implying owner verification.
  ///
  /// In en, this message translates to:
  /// **'Catch organizer'**
  String get organizersAuthorityBadgeCatchOrganizer;

  /// Authority badge for an organizer whose owner identity has been verified.
  ///
  /// In en, this message translates to:
  /// **'Owner verified'**
  String get organizersAuthorityBadgeOwnerVerified;

  /// Defensive authority badge for a suppressed organizer; public routes should normally hide this state.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get organizersAuthorityBadgeUnavailable;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_body.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get clubsClubDetailBodyTitleReviews;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_body.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Get in touch'**
  String get clubsClubDetailBodyTitleGetInTouch;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_dock.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Disable organizer push notifications'**
  String get clubsClubDetailDockLabelDisableClubPushNotifications;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_dock.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Enable organizer push notifications'**
  String get clubsClubDetailDockLabelEnableClubPushNotifications;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_hero_app_bar.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get clubsClubHeroAppBarTooltipBack;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_hero_app_bar.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Share organizer'**
  String get clubsClubHeroAppBarTooltipShareClub;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_host_section.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Message host'**
  String get clubsClubHostSectionMessageMessageHost;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_photo_strip.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'FROM THE ORGANIZER'**
  String get clubsClubPhotoStripTextFromTheClub;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_schedule_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No events scheduled'**
  String get clubsClubScheduleSectionTitleNoEventsScheduled;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_schedule_section.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Future events will appear here once the host publishes one.'**
  String get clubsClubScheduleSectionMessageFutureEventsWillAppear;

  /// Product copy used by lib/clubs/presentation/discovery/widgets/club_avatar_rail.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Your organizers'**
  String get clubsClubAvatarRailTitleYourClubs;

  /// Product copy used by lib/clubs/presentation/discovery/widgets/club_discover_list.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Organizer directory'**
  String get clubsClubDiscoverListTitleClubDirectory;

  /// Product copy used by lib/clubs/shared/club_identity_atoms.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get clubsClubIdentityAtomsLabelOwner;

  /// Product copy used by lib/clubs/shared/club_identity_atoms.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get clubsClubIdentityAtomsLabelHost;

  /// Product copy used by lib/core/widgets/catch_adaptive_picker.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get coreCatchAdaptivePickerTextCancel;

  /// Product copy used by lib/core/widgets/catch_adaptive_picker.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get coreCatchAdaptivePickerTextDone;

  /// Product copy used by lib/core/widgets/catch_error_banner.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get coreCatchErrorBannerLabelTryAgain;

  /// Product copy used by lib/core/widgets/catch_field.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'field'**
  String get coreCatchFieldTooltipField;

  /// Product copy used by lib/core/widgets/catch_field.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get coreCatchFieldLabelCancel;

  /// Product copy used by lib/core/widgets/catch_field.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get coreCatchFieldLabelDone;

  /// Product copy used by lib/core/widgets/catch_field.dart (saving label).
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get coreCatchFieldLabelSaving;

  /// Muted suffix appended to an empty optional field add affordance.
  ///
  /// In en, this message translates to:
  /// **' · Optional'**
  String get coreCatchFieldTextOptionalSuffix;

  /// Live accessibility status for a CatchField save in progress.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get coreCatchFieldSemanticSaving;

  /// Live accessibility status for a successfully saved CatchField.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get coreCatchFieldSemanticSaved;

  /// Product copy used by lib/core/widgets/catch_form_field_label.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get coreCatchFormFieldLabelTextOptional;

  /// Schema-derived validation message for an empty required form field.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String coreCatchFormValidationRequired({required String field});

  /// Schema-derived validation message for text shorter than the contract minimum.
  ///
  /// In en, this message translates to:
  /// **'{field} must be at least {minLength} characters'**
  String coreCatchFormValidationMinLength({
    required String field,
    required int minLength,
  });

  /// Schema-derived validation message for text longer than the contract maximum.
  ///
  /// In en, this message translates to:
  /// **'{field} must be {maxLength} characters or fewer'**
  String coreCatchFormValidationMaxLength({
    required String field,
    required int maxLength,
  });

  /// Schema-derived validation message for text that does not match the contract pattern.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid {field}'**
  String coreCatchFormValidationPattern({required String field});

  /// Product copy used by lib/core/widgets/catch_framework_error_view.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get coreCatchFrameworkErrorViewTextSomethingWentWrong;

  /// Product copy used by lib/core/widgets/catch_framework_error_view.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Developer details'**
  String get coreCatchFrameworkErrorViewTextDeveloperDetails;

  /// Product copy used by lib/core/widgets/catch_person_row.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get coreCatchPersonRowTextTyping;

  /// Product copy used by lib/core/widgets/catch_person_row.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Unread chat'**
  String get coreCatchPersonRowLabelUnreadChat;

  /// Product copy used by lib/core/widgets/catch_person_row.dart (label).
  ///
  /// In en, this message translates to:
  /// **'New match'**
  String get coreCatchPersonRowLabelNewMatch;

  /// Product copy used by lib/core/widgets/catch_share_card_footer.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'CATCH'**
  String get coreCatchShareCardFooterTextCatch;

  /// Product copy used by lib/core/widgets/catch_startup_loading_screen.dart (semanticLabel).
  ///
  /// In en, this message translates to:
  /// **'Catch'**
  String get coreCatchStartupLoadingScreenSemanticlabelCatch;

  /// Product copy used by lib/core/widgets/ordered_photo_picker.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'COVER'**
  String get coreOrderedPhotoPickerTextCover;

  /// Product copy used by lib/dashboard/presentation/activity_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get dashboardActivityScreenTitleActivity;

  /// Product copy used by lib/dashboard/presentation/dashboard_screen.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get dashboardDashboardScreenTooltipCalendar;

  /// Product copy used by lib/dashboard/presentation/dashboard_screen.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get dashboardDashboardScreenTooltipNotifications;

  /// Product copy used by lib/dashboard/presentation/widgets/activity_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get dashboardActivitySectionTitleNoActivityYet;

  /// Product copy used by lib/dashboard/presentation/widgets/activity_section.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Sign in and book an event to start seeing updates here.'**
  String get dashboardActivitySectionMessageSignInAndBook;

  /// Product copy used by lib/dashboard/presentation/widgets/activity_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Activity unavailable'**
  String get dashboardActivitySectionTitleActivityUnavailable;

  /// Product copy used by lib/dashboard/presentation/widgets/activity_section.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Could not load activity.'**
  String get dashboardActivitySectionMessageCouldNotLoadActivity;

  /// Product copy used by lib/dashboard/presentation/widgets/activity_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No new activity'**
  String get dashboardActivitySectionTitleNoNewActivity;

  /// Product copy used by lib/dashboard/presentation/widgets/activity_section.dart (message).
  ///
  /// In en, this message translates to:
  /// **'New catches, bookings, and event reminders will collect here.'**
  String get dashboardActivitySectionMessageNewCatchesBookingsAnd;

  /// Product copy used by lib/dashboard/presentation/widgets/club_posts_home_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Organizer updates'**
  String get dashboardClubPostsHomeSectionTitleClubUpdates;

  /// Product copy used by lib/dashboard/presentation/widgets/club_posts_home_section.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Linked event'**
  String get dashboardClubPostsHomeSectionTextLinkedEvent;

  /// Product copy used by lib/dashboard/presentation/widgets/empty_hero_card.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'WELCOME TO CATCH'**
  String get dashboardEmptyHeroCardTextWelcomeToCatch;

  /// Product copy used by lib/dashboard/presentation/widgets/empty_hero_card.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'● NO EVENTS BOOKED'**
  String get dashboardEmptyHeroCardTextNoEventsBooked;

  /// Product copy used by lib/dashboard/presentation/widgets/empty_hero_card.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Your catches unlock\nafter your first event.'**
  String get dashboardEmptyHeroCardTextYourCatchesUnlockAfter;

  /// Product copy used by lib/dashboard/presentation/widgets/empty_hero_card.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'The dating app where you\'\'ve already met. No cold swiping — just people you actually crossed paths with.'**
  String get dashboardEmptyHeroCardTextTheDatingAppWhere;

  /// Product copy used by lib/dashboard/presentation/widgets/empty_hero_card.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Find an event near me'**
  String get dashboardEmptyHeroCardLabelFindAnEventNear;

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Event Focus'**
  String get dashboardEventFocusRailTextEventFocus;

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Event focus carousel'**
  String get dashboardEventFocusRailLabelEventFocusCarousel;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'In development'**
  String get eventPoliciesEventPolicyLabScreenLabelInDevelopment;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'No live writes'**
  String get eventPoliciesEventPolicyLabScreenLabelNoLiveWrites;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get eventPoliciesEventPolicyLabScreenLabelCapacity;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get eventPoliciesEventPolicyLabScreenLabelBase;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get eventPoliciesEventPolicyLabScreenLabelBooked;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Waitlist'**
  String get eventPoliciesEventPolicyLabScreenLabelWaitlist;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Host configuration'**
  String get eventPoliciesEventPolicyLabScreenTitleHostConfiguration;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Policy shape'**
  String get eventPoliciesEventPolicyLabScreenTitlePolicyShape;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Admission'**
  String get eventPoliciesEventPolicyLabScreenLabelAdmission;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get eventPoliciesEventPolicyLabScreenLabelInvite;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Membership'**
  String get eventPoliciesEventPolicyLabScreenLabelMembership;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Host review'**
  String get eventPoliciesEventPolicyLabScreenLabelHostReview;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Cohort caps'**
  String get eventPoliciesEventPolicyLabScreenLabelCohortCaps;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Ratio'**
  String get eventPoliciesEventPolicyLabScreenLabelRatio;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Out-of-ratio'**
  String get eventPoliciesEventPolicyLabScreenLabelOutOfRatio;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Cohort pricing'**
  String get eventPoliciesEventPolicyLabScreenLabelCohortPricing;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Demand pricing'**
  String get eventPoliciesEventPolicyLabScreenLabelDemandPricing;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Cancellation'**
  String get eventPoliciesEventPolicyLabScreenLabelCancellation;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Attendee terms'**
  String get eventPoliciesEventPolicyLabScreenLabelAttendeeTerms;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Host payout'**
  String get eventPoliciesEventPolicyLabScreenLabelHostPayout;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Preview outcomes'**
  String get eventPoliciesEventPolicyLabScreenTitlePreviewOutcomes;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Cancellation outcomes'**
  String get eventPoliciesEventPolicyLabScreenTitleCancellationOutcomes;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Debug map'**
  String get eventPoliciesEventPolicyLabScreenTitleDebugMap;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event companion'**
  String get eventSuccessEventSuccessCompanionScreenTitleEventCompanion;

  /// Product copy used by lib/event_success/presentation/event_success_event_preview_body_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Preview only'**
  String get eventSuccessEventSuccessEventPreviewBodyScreenLabelPreviewOnly;

  /// Product copy used by lib/event_success/presentation/event_success_event_preview_body_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Dev/staging'**
  String get eventSuccessEventSuccessEventPreviewBodyScreenLabelDevStaging;

  /// Product copy used by lib/event_success/presentation/event_success_event_preview_body_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'How this maps to the live app'**
  String get eventSuccessEventSuccessEventPreviewBodyScreenTextHowThisMapsTo;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Host setup flow'**
  String get eventSuccessEventSuccessFeatureBlocksTitleHostSetupFlow;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Choose the format, event structure, assignment tools, and safety gates before an event goes live.'**
  String get eventSuccessEventSuccessFeatureBlocksSubtitleChooseTheFormatEvent;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get eventSuccessEventSuccessFeatureBlocksTextFormat;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Event structure'**
  String get eventSuccessEventSuccessFeatureBlocksTextEventStructure;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Experience architecture'**
  String get eventSuccessEventSuccessFeatureBlocksTextExperienceArchitecture;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Live host mode'**
  String get eventSuccessEventSuccessFeatureBlocksTitleLiveHostMode;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'A phone-friendly guide for check-in, welcome, the current instruction, and the next social cue.'**
  String get eventSuccessEventSuccessFeatureBlocksSubtitleAPhoneFriendlyGuide;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get eventSuccessEventSuccessFeatureBlocksLabelCheckedIn;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Run of show'**
  String get eventSuccessEventSuccessFeatureBlocksLabelRunOfShow;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Attendee companion'**
  String get eventSuccessEventSuccessFeatureBlocksTitleAttendeeCompanion;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'The attendee sees only what helps them participate: check-in, assignment, prompt, and host help.'**
  String get eventSuccessEventSuccessFeatureBlocksSubtitleTheAttendeeSeesOnly;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get eventSuccessEventSuccessFeatureBlocksLabelCheckIn;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Ask host for help'**
  String get eventSuccessEventSuccessFeatureBlocksTextAskHostForHelp;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Post-event host report'**
  String get eventSuccessEventSuccessFeatureBlocksTitlePostEventHostReport;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'A concrete report surface that turns event outcomes into the next change the host should make.'**
  String
  get eventSuccessEventSuccessFeatureBlocksSubtitleAConcreteReportSurface;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get eventSuccessEventSuccessFeatureBlocksLabelCheckIn16e104;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Intro coverage'**
  String get eventSuccessEventSuccessFeatureBlocksLabelIntroCoverage;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Caught someone'**
  String get eventSuccessEventSuccessFeatureBlocksLabelCaughtSomeone;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Host help'**
  String get eventSuccessEventSuccessFeatureBlocksLabelHostHelp;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Chat start'**
  String get eventSuccessEventSuccessFeatureBlocksLabelChatStart;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Working well'**
  String get eventSuccessEventSuccessFeatureBlocksTextWorkingWell;

  /// Section title for the post-event recommendations list.
  ///
  /// In en, this message translates to:
  /// **'Improve next time'**
  String get eventSuccessEventSuccessFeatureBlocksTextImproveNextTime;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Before launch'**
  String get eventSuccessEventSuccessFeatureBlocksLabelBeforeLaunch;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get eventSuccessEventSuccessFeatureBlocksLabelRequested;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Host visible'**
  String get eventSuccessEventSuccessFeatureBlocksLabelHostVisible;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Actual WIP feature blocks'**
  String get eventSuccessEventSuccessLabScreenTitleActualWipFeatureBlocks;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Product promise'**
  String get eventSuccessEventSuccessLabScreenTitleProductPromise;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Playbooks'**
  String get eventSuccessEventSuccessLabScreenTitlePlaybooks;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Architecture layers'**
  String get eventSuccessEventSuccessLabScreenTitleArchitectureLayers;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Host coach sample'**
  String get eventSuccessEventSuccessLabScreenTitleHostCoachSample;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Work in progress'**
  String get eventSuccessEventSuccessLabScreenLabelWorkInProgress;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Preview only'**
  String get eventSuccessEventSuccessLabScreenLabelPreviewOnly;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Event Success Layer'**
  String get eventSuccessEventSuccessLabScreenTextEventSuccessLayer;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'A first-pass workspace for improving what happens during events: structure, attendance, assignments, live reveal moments, host help, feedback, and coaching.'**
  String get eventSuccessEventSuccessLabScreenTextAFirstPassWorkspace;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Attendees'**
  String get eventSuccessEventSuccessLabScreenTitleAttendees;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Hosts'**
  String get eventSuccessEventSuccessLabScreenTitleHosts;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Catch'**
  String get eventSuccessEventSuccessLabScreenTitleCatch;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Learn which live structures improve check-in, mixing, matches, chat starts, repeats, and safety.'**
  String get eventSuccessEventSuccessLabScreenBodyLearnWhichLiveStructures;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Iteration questions'**
  String get eventSuccessEventSuccessLabScreenTitleIterationQuestions;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Anti-patterns'**
  String get eventSuccessEventSuccessLabScreenTitleAntiPatterns;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Run of show'**
  String get eventSuccessEventSuccessLabScreenTextRunOfShow;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Sample debrief'**
  String get eventSuccessEventSuccessLabScreenTextSampleDebrief;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get eventSuccessEventSuccessLabScreenLabelCheckIn;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Intro coverage'**
  String get eventSuccessEventSuccessLabScreenLabelIntroCoverage;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Caught someone'**
  String get eventSuccessEventSuccessLabScreenLabelCaughtSomeone;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Host help'**
  String get eventSuccessEventSuccessLabScreenLabelHostHelp;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Chat start'**
  String get eventSuccessEventSuccessLabScreenLabelChatStart;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Strengths'**
  String get eventSuccessEventSuccessLabScreenTitleStrengths;

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Manual QA'**
  String get eventSuccessEventSuccessManualQaScreenLabelManualQa;

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Fixture data'**
  String get eventSuccessEventSuccessManualQaScreenLabelFixtureData;

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Questionnaire off'**
  String get eventSuccessEventSuccessManualQaScreenLabelQuestionnaireOff;

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Fixture scenario'**
  String get eventSuccessEventSuccessManualQaScreenTextFixtureScenario;

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Host Manage'**
  String get eventSuccessEventSuccessManualQaScreenTitleHostManage;

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Attendee experience'**
  String get eventSuccessEventSuccessManualQaScreenTitleAttendeeExperience;

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Micro-pods opt-out'**
  String get eventSuccessEventSuccessManualQaScreenTitleMicroPodsOptOut;

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Rotations opt-out'**
  String get eventSuccessEventSuccessManualQaScreenTitleRotationsOptOut;

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'first hello complete'**
  String get eventSuccessEventSuccessManualQaScreenLabelFirstHelloComplete;

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'first hello skipped'**
  String get eventSuccessEventSuccessManualQaScreenLabelFirstHelloSkipped;

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'first hello pending'**
  String get eventSuccessEventSuccessManualQaScreenLabelFirstHelloPending;

  /// Product copy used by lib/event_success/presentation/event_success_questionnaire_config_editor.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Question set'**
  String get eventSuccessEventSuccessQuestionnaireConfigEditorTextQuestionSet;

  /// Product copy used by lib/event_success/presentation/event_success_questionnaire_config_editor.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get eventSuccessEventSuccessQuestionnaireConfigEditorLabelCustom;

  /// Product copy used by lib/event_success/presentation/event_success_questionnaire_config_editor.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Custom question set name'**
  String
  get eventSuccessEventSuccessQuestionnaireConfigEditorTitleCustomQuestionSetName;

  /// Product copy used by lib/event_success/presentation/event_success_questionnaire_config_editor.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Add question'**
  String get eventSuccessEventSuccessQuestionnaireConfigEditorLabelAddQuestion;

  /// Product copy used by lib/event_success/presentation/event_success_questionnaire_config_editor.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get eventSuccessEventSuccessQuestionnaireConfigEditorLabelReset;

  /// Product copy used by lib/event_success/presentation/event_success_questionnaire_config_editor.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Remove question'**
  String
  get eventSuccessEventSuccessQuestionnaireConfigEditorMessageRemoveQuestion;

  /// Product copy used by lib/event_success/presentation/event_success_setup_body.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Your goal for the event'**
  String get eventSuccessEventSuccessSetupBodyTitleYourGoalForTheEvent;

  /// Product copy used by lib/event_success/presentation/event_success_setup_body.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Message to attendees'**
  String get eventSuccessEventSuccessSetupBodyTitleMessageToAttendees;

  /// Product copy used by lib/event_success/presentation/event_success_setup_body.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'Something attendees see before the event kicks off.'**
  String
  get eventSuccessEventSuccessSetupBodyPlaceholderSomethingAttendeesSeeBeforeTheEventKicksOff;

  /// Stage heading in the host live event guide.
  ///
  /// In en, this message translates to:
  /// **'Before the event'**
  String get eventSuccessEventSuccessSetupBodyTitleBeforeTheEvent;

  /// Stage heading in the host live event guide.
  ///
  /// In en, this message translates to:
  /// **'When people arrive'**
  String get eventSuccessEventSuccessSetupBodyTitleWhenPeopleArrive;

  /// Stage heading in the host live event guide.
  ///
  /// In en, this message translates to:
  /// **'During the event'**
  String get eventSuccessEventSuccessSetupBodyTitleDuringTheEvent;

  /// Stage heading in the host live event guide.
  ///
  /// In en, this message translates to:
  /// **'After the event'**
  String get eventSuccessEventSuccessSetupBodyTitleAfterTheEvent;

  /// Product copy used by lib/event_success/presentation/event_success_setup_body.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Switch partners every'**
  String get eventSuccessEventSuccessSetupBodyLabelSwitchPartnersEvery;

  /// Product copy used by lib/event_success/presentation/event_success_setup_body.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get eventSuccessEventSuccessSetupBodyLabelReset;

  /// Product copy used by lib/event_success/presentation/event_success_setup_body.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Match clue questions'**
  String get eventSuccessEventSuccessSetupBodyTextMatchClueQuestions;

  /// Reveal countdown field label in the live event guide.
  ///
  /// In en, this message translates to:
  /// **'Reveal countdown'**
  String get eventSuccessEventSuccessSetupBodyLabelRevealCountdown;

  /// Section title for live event grouping controls.
  ///
  /// In en, this message translates to:
  /// **'How the room is grouped'**
  String get eventSuccessEventSuccessSetupBodyTitleHowTheRoomIsGrouped;

  /// Product copy used by lib/event_success/presentation/event_success_setup_body.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get eventSuccessEventSuccessSetupBodyLabelOff;

  /// Match clue questionnaire mode without pairing influence.
  ///
  /// In en, this message translates to:
  /// **'Clues only'**
  String get eventSuccessEventSuccessSetupBodyLabelCluesOnly;

  /// Match clue questionnaire mode with soft pairing influence.
  ///
  /// In en, this message translates to:
  /// **'Clues + soft pairing'**
  String get eventSuccessEventSuccessSetupBodyLabelCluesSoftPairing;

  /// Summary for the disabled match clue questionnaire.
  ///
  /// In en, this message translates to:
  /// **'Optional prompts are off.'**
  String get eventSuccessEventSuccessSetupBodyTextOptionalPromptsAreOff;

  /// Summary for clue-only questionnaire mode.
  ///
  /// In en, this message translates to:
  /// **'Answers create reveal clues.'**
  String get eventSuccessEventSuccessSetupBodyTextAnswersCreateRevealClues;

  /// Summary for clue and soft-pairing questionnaire mode.
  ///
  /// In en, this message translates to:
  /// **'Answers create clues and softly guide pairings.'**
  String
  get eventSuccessEventSuccessSetupBodyTextAnswersCreateCluesAndSoftlyGuidePairings;

  /// Product copy used by lib/event_success/presentation/event_success_structure_config_editor.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Group people into'**
  String get eventSuccessEventSuccessStructureConfigEditorTextGroupPeopleInto;

  /// Product copy used by lib/event_success/presentation/event_success_structure_config_editor.dart (detail).
  ///
  /// In en, this message translates to:
  /// **'Set the number yourself, or let Catch work it out from attendance.'**
  String
  get eventSuccessEventSuccessStructureConfigEditorDetailSetTheNumberYourselfOrLetCatchWorkItOutFromAttendance;

  /// Product copy used by lib/event_success/presentation/event_success_structure_config_editor.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get eventSuccessEventSuccessStructureConfigEditorLabelAuto;

  /// Product copy used by lib/event_success/presentation/event_success_structure_config_editor.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get eventSuccessEventSuccessStructureConfigEditorLabelFixed;

  /// Product copy used by lib/event_success/presentation/event_success_structure_config_editor.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'One shared group for the full event.'**
  String get eventSuccessEventSuccessStructureConfigEditorTextOneSharedGroupFor;

  /// Product copy used by lib/event_success/presentation/event_success_structure_config_editor.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Catch uses this when it builds the groups.'**
  String
  get eventSuccessEventSuccessStructureConfigEditorTextCatchUsesThisWhenItBuildsTheGroups;

  /// Product copy used by lib/event_success/presentation/event_success_structure_config_editor.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Spread people out by'**
  String
  get eventSuccessEventSuccessStructureConfigEditorTitleSpreadPeopleOutBy;

  /// Product copy used by lib/event_success/presentation/event_success_structure_config_editor.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Keep similar people together by'**
  String
  get eventSuccessEventSuccessStructureConfigEditorTitleKeepSimilarPeopleTogetherBy;

  /// Product copy used by lib/event_success/presentation/event_success_structure_config_editor.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Meeting the same person again'**
  String
  get eventSuccessEventSuccessStructureConfigEditorTextMeetingTheSamePersonAgain;

  /// Product copy used by lib/event_success/presentation/event_success_structure_config_editor.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Max times the same pair meets'**
  String
  get eventSuccessEventSuccessStructureConfigEditorLabelMaxTimesTheSamePairMeets;

  /// Product copy used by lib/event_success/presentation/event_success_structure_config_editor.dart (detail).
  ///
  /// In en, this message translates to:
  /// **'Only used when there are more rounds than people to meet.'**
  String
  get eventSuccessEventSuccessStructureConfigEditorDetailOnlyUsedWhenThereAreMoreRoundsThanPeopleToMeet;

  /// Accessible stepper label used by lib/event_success/presentation/event_success_structure_config_editor.dart.
  ///
  /// In en, this message translates to:
  /// **'Decrease people per unit'**
  String
  get eventSuccessEventSuccessStructureConfigEditorSemanticDecreasePeoplePerUnit;

  /// Accessible stepper label used by lib/event_success/presentation/event_success_structure_config_editor.dart.
  ///
  /// In en, this message translates to:
  /// **'Increase people per unit'**
  String
  get eventSuccessEventSuccessStructureConfigEditorSemanticIncreasePeoplePerUnit;

  /// Accessible stepper label used by lib/event_success/presentation/event_success_structure_config_editor.dart.
  ///
  /// In en, this message translates to:
  /// **'Decrease unit count'**
  String
  get eventSuccessEventSuccessStructureConfigEditorSemanticDecreaseUnitCount;

  /// Accessible stepper label used by lib/event_success/presentation/event_success_structure_config_editor.dart.
  ///
  /// In en, this message translates to:
  /// **'Increase unit count'**
  String
  get eventSuccessEventSuccessStructureConfigEditorSemanticIncreaseUnitCount;

  /// Accessible stepper label used by lib/event_success/presentation/event_success_structure_config_editor.dart.
  ///
  /// In en, this message translates to:
  /// **'Decrease meetings per pair'**
  String
  get eventSuccessEventSuccessStructureConfigEditorSemanticDecreaseMeetingsPerPair;

  /// Accessible stepper label used by lib/event_success/presentation/event_success_structure_config_editor.dart.
  ///
  /// In en, this message translates to:
  /// **'Increase meetings per pair'**
  String
  get eventSuccessEventSuccessStructureConfigEditorSemanticIncreaseMeetingsPerPair;

  /// Product copy used by lib/event_success/presentation/event_success_structure_config_editor.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Structure is locked once attendance or waitlist activity exists.'**
  String
  get eventSuccessEventSuccessStructureConfigEditorTextStructureIsLockedOnce;

  /// Product copy used by lib/events/presentation/calendar/calendar_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Calendar date header. Drag up to collapse the month.'**
  String get eventsCalendarScreenLabelCalendarDateHeaderDrag;

  /// Product copy used by lib/events/presentation/calendar/calendar_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Calendar date header. Drag down to expand the month.'**
  String get eventsCalendarScreenLabelCalendarDateHeaderDrag0f5be6;

  /// Product copy used by lib/events/presentation/calendar/calendar_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get eventsCalendarScreenLabelToday;

  /// Product copy used by lib/events/presentation/calendar/calendar_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get eventsCalendarScreenLabelPlanned;

  /// Product copy used by lib/events/presentation/calendar/calendar_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get eventsCalendarScreenLabelDistance;

  /// Product copy used by lib/events/presentation/calendar/calendar_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get eventsCalendarScreenLabelNext;

  /// Product copy used by lib/events/presentation/event_detail_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'eventId'**
  String get eventsEventDetailScreenBodyEventid;

  /// Product copy used by lib/events/presentation/event_detail_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'clubId'**
  String get eventsEventDetailScreenBodyClubid;

  /// Product copy used by lib/events/presentation/event_location_map_body_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Get directions'**
  String get eventsEventLocationMapBodyScreenLabelGetDirections;

  /// Product copy used by lib/events/presentation/event_map_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No mapped events yet'**
  String get eventsEventMapScreenTitleNoMappedEventsYet;

  /// Product copy used by lib/events/presentation/event_map_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Follow organizers, book events, or save future events to see starting points here.'**
  String get eventsEventMapScreenMessageJoinClubsBookEvents;

  /// Product copy used by lib/events/presentation/location_picker_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Search for a meeting point'**
  String get eventsLocationPickerScreenTitleSearchForAMeeting;

  /// Product copy used by lib/events/presentation/location_picker_screen.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'Search for a meeting point'**
  String get eventsLocationPickerScreenPlaceholderSearchForAMeeting;

  /// Product copy used by lib/events/presentation/location_picker_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Pinned location'**
  String get eventsLocationPickerScreenTitlePinnedLocation;

  /// Product copy used by lib/events/presentation/location_picker_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No location selected'**
  String get eventsLocationPickerScreenTitleNoLocationSelected;

  /// Product copy used by lib/events/presentation/location_picker_screen.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Confirm this map pin or tap elsewhere to adjust.'**
  String get eventsLocationPickerScreenSubtitleConfirmThisMapPin;

  /// Product copy used by lib/events/presentation/location_picker_screen.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Confirm this place or tap elsewhere to adjust.'**
  String get eventsLocationPickerScreenSubtitleConfirmThisPlaceOr;

  /// Product copy used by lib/events/presentation/location_picker_screen.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Search for a place or tap the map to set the meeting point.'**
  String get eventsLocationPickerScreenSubtitleSearchForAPlace;

  /// Product copy used by lib/events/presentation/location_picker_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Confirm location'**
  String get eventsLocationPickerScreenLabelConfirmLocation;

  /// Product copy used by lib/events/presentation/saved_events_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No saved events yet'**
  String get eventsSavedEventsScreenTitleNoSavedEventsYet;

  /// Product copy used by lib/events/presentation/saved_events_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Save events you want to revisit before booking.'**
  String get eventsSavedEventsScreenMessageSaveEventsYouWant;

  /// Product copy used by lib/events/presentation/widgets/booking_conflict_sheet.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Booking time conflict'**
  String get eventsBookingConflictSheetLabelBookingTimeConflict;

  /// Product copy used by lib/events/presentation/widgets/booking_conflict_sheet.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'That\'\'s the same time slot'**
  String get eventsBookingConflictSheetTextThatSTheSame;

  /// Product copy used by lib/events/presentation/widgets/booking_conflict_sheet.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Cancel existing & book this'**
  String get eventsBookingConflictSheetLabelCancelExistingBookThis;

  /// Product copy used by lib/events/presentation/widgets/booking_conflict_sheet.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Keep both'**
  String get eventsBookingConflictSheetLabelKeepBoth;

  /// Product copy used by lib/events/presentation/widgets/booking_conflict_sheet.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Keep existing only'**
  String get eventsBookingConflictSheetLabelKeepExistingOnly;

  /// Product copy used by lib/events/presentation/widgets/event_detail_body.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Bring someone into the room'**
  String get eventsEventDetailBodyTitleBringSomeoneIntoThe;

  /// Product copy used by lib/events/presentation/widgets/event_detail_body.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Your spot is booked. Invite a friend who would make this event better.'**
  String get eventsEventDetailBodyBodyYourSpotIsBooked;

  /// Product copy used by lib/events/presentation/widgets/event_detail_body.dart (actionLabel).
  ///
  /// In en, this message translates to:
  /// **'Invite a friend'**
  String get eventsEventDetailBodyActionlabelInviteAFriend;

  /// Product copy used by lib/events/presentation/widgets/event_detail_body.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event companion'**
  String get eventsEventDetailBodyTitleEventCompanion;

  /// Product copy used by lib/events/presentation/widgets/event_detail_body.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Check in, see your social prompt, and handle private follow-up after the event.'**
  String get eventsEventDetailBodyBodyCheckInSeeYour;

  /// Product copy used by lib/events/presentation/widgets/event_detail_body.dart (actionLabel).
  ///
  /// In en, this message translates to:
  /// **'Open companion'**
  String get eventsEventDetailBodyActionlabelOpenCompanion;

  /// Product copy used by lib/events/presentation/widgets/event_detail_body.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Sign in to book this event'**
  String get eventsEventDetailBodyLabelSignInToBook;

  /// Product copy used by lib/events/presentation/widgets/event_detail_body.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Hosted by'**
  String get eventsEventDetailBodyTitleHostedBy;

  /// Product copy used by lib/events/presentation/widgets/event_detail_body.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Message host'**
  String get eventsEventDetailBodyTooltipMessageHost;

  /// Product copy used by lib/events/presentation/widgets/event_detail_cta.dart (label).
  ///
  /// In en, this message translates to:
  /// **'You\'\'re in!'**
  String get eventsEventDetailCtaLabelYouReIn;

  /// Product copy used by lib/events/presentation/widgets/event_detail_cta.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get eventsEventDetailCtaLabelCompleted;

  /// Product copy used by lib/events/presentation/widgets/event_detail_cta.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'per person'**
  String get eventsEventDetailCtaTextPerPerson;

  /// Product copy used by lib/events/presentation/widgets/event_detail_cta.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Declining'**
  String get eventsEventDetailCtaLabelDeclining;

  /// Product copy used by lib/events/presentation/widgets/event_detail_cta.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get eventsEventDetailCtaLabelDecline;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'EVENT PHOTOS'**
  String get eventsEventDetailDesignPrimitivesTextEventPhotos;

  /// Product copy used by lib/events/presentation/widgets/event_detail_hero_app_bar.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get eventsEventDetailHeroAppBarTooltipBack;

  /// Product copy used by lib/events/presentation/widgets/event_detail_hero_app_bar.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Share event'**
  String get eventsEventDetailHeroAppBarTooltipShareEvent;

  /// Product copy used by lib/events/presentation/widgets/event_detail_hero_app_bar.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Add to calendar'**
  String get eventsEventDetailHeroAppBarTooltipAddToCalendar;

  /// Product copy used by lib/events/presentation/widgets/event_detail_hero_app_bar.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Unsave event'**
  String get eventsEventDetailHeroAppBarTooltipUnsaveEvent;

  /// Product copy used by lib/events/presentation/widgets/event_detail_hero_app_bar.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Save event'**
  String get eventsEventDetailHeroAppBarTooltipSaveEvent;

  /// Product copy used by lib/events/presentation/widgets/event_detail_loading_skeleton.dart (title).
  ///
  /// In en, this message translates to:
  /// **'The plan'**
  String get eventsEventDetailLoadingSkeletonTitleThePlan;

  /// Product copy used by lib/events/presentation/widgets/event_detail_loading_skeleton.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Why you might click'**
  String get eventsEventDetailLoadingSkeletonTitleWhyYouMightClick;

  /// Product copy used by lib/events/presentation/widgets/event_detail_loading_skeleton.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Itinerary'**
  String get eventsEventDetailLoadingSkeletonTitleItinerary;

  /// Product copy used by lib/events/presentation/widgets/event_detail_loading_skeleton.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get eventsEventDetailLoadingSkeletonTitleWhere;

  /// Product copy used by lib/events/presentation/widgets/event_detail_loading_skeleton.dart (title).
  ///
  /// In en, this message translates to:
  /// **'How sign-ups work'**
  String get eventsEventDetailLoadingSkeletonTitleHowSignUpsWork;

  /// Product copy used by lib/events/presentation/widgets/event_detail_loading_skeleton.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Who\'\'s going'**
  String get eventsEventDetailLoadingSkeletonTitleWhoSGoing;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'The plan'**
  String get eventsEventDetailOverviewSectionTitleThePlan;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Why you might click'**
  String get eventsEventDetailOverviewSectionTitleWhyYouMightClick;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Based on event format, capacity and booking rules — never shown to the group.'**
  String get eventsEventDetailOverviewSectionTextBasedOnEventFormat;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Itinerary'**
  String get eventsEventDetailOverviewSectionTitleItinerary;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get eventsEventDetailOverviewSectionTitlePhotos;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get eventsEventDetailOverviewSectionTitleWhere;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'How sign-ups work'**
  String get eventsEventDetailOverviewSectionTitleHowSignUpsWork;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Good to know'**
  String get eventsEventDetailOverviewSectionTitleGoodToKnow;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'About this event'**
  String get eventsEventDetailOverviewSectionTextAboutThisEvent;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Demand pricing'**
  String get eventsEventDetailOverviewSectionTitleDemandPricing;

  /// Product copy used by lib/events/presentation/widgets/event_detail_social_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Who\'\'s going'**
  String get eventsEventDetailSocialSectionTitleWhoSGoing;

  /// Product copy used by lib/events/presentation/widgets/event_detail_social_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get eventsEventDetailSocialSectionTitleReviews;

  /// Product copy used by lib/events/presentation/widgets/event_detail_social_section.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Who\'\'s going'**
  String get eventsEventDetailSocialSectionTextWhoSGoing;

  /// Product copy used by lib/events/presentation/widgets/event_detail_social_section.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Sign in to see who has booked this event.'**
  String get eventsEventDetailSocialSectionTextSignInToSee;

  /// Product copy used by lib/events/presentation/widgets/event_pins_map.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Event map preview'**
  String get eventsEventPinsMapLabelEventMapPreview;

  /// Product copy used by lib/events/presentation/widgets/requirements_row.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get eventsRequirementsRowTextRequirements;

  /// Product copy used by lib/events/presentation/widgets/who_is_going.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Who\'\'s going'**
  String get eventsWhoIsGoingTextWhoSGoing;

  /// Product copy used by lib/events/presentation/widgets/who_is_going.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No attendees yet'**
  String get eventsWhoIsGoingTitleNoAttendeesYet;

  /// Product copy used by lib/events/presentation/widgets/who_is_going.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No attendees booked'**
  String get eventsWhoIsGoingTitleNoAttendeesBooked;

  /// Product copy used by lib/events/presentation/widgets/who_is_going.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Be the first to book this event.'**
  String get eventsWhoIsGoingMessageBeTheFirstTo;

  /// Product copy used by lib/events/presentation/widgets/who_is_going.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This event did not have any booked attendees.'**
  String get eventsWhoIsGoingMessageThisEventDidNot;

  /// Product copy used by lib/events/presentation/widgets/who_is_going.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Catches unlock for 24 hours after the event finishes.'**
  String get eventsWhoIsGoingMessageCatchesUnlockFor24;

  /// Product copy used by lib/events/presentation/widgets/who_is_going.dart (message).
  ///
  /// In en, this message translates to:
  /// **'The catch window is open for 24 hours after the event finishes.'**
  String get eventsWhoIsGoingMessageTheCatchWindowIs;

  /// Product copy used by lib/events/presentation/widgets/who_is_going.dart (message).
  ///
  /// In en, this message translates to:
  /// **'The catch window for this event has closed.'**
  String get eventsWhoIsGoingMessageTheCatchWindowFor;

  /// Product copy used by lib/events/shared/event_check_in_celebration_screen.dart (eyebrow).
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get eventsEventCheckInCelebrationScreenEyebrowCheckedIn;

  /// Product copy used by lib/events/shared/event_check_in_celebration_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Checked in.'**
  String get eventsEventCheckInCelebrationScreenTitleCheckedIn;

  /// Product copy used by lib/events/shared/event_check_in_celebration_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'You\'\'re on the roster. Have a great event.'**
  String get eventsEventCheckInCelebrationScreenMessageYouReOnThe;

  /// Product copy used by lib/events/shared/event_check_in_celebration_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get eventsEventCheckInCelebrationScreenLabelEvent;

  /// Product copy used by lib/events/shared/event_check_in_celebration_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get eventsEventCheckInCelebrationScreenLabelStarts;

  /// Product copy used by lib/events/shared/event_check_in_celebration_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Meet point'**
  String get eventsEventCheckInCelebrationScreenLabelMeetPoint;

  /// Product copy used by lib/events/shared/event_check_in_celebration_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'View event'**
  String get eventsEventCheckInCelebrationScreenLabelViewEvent;

  /// Product copy used by lib/events/shared/event_check_in_celebration_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get eventsEventCheckInCelebrationScreenLabelBackToHome;

  /// Product copy used by lib/events/shared/event_joined_celebration_screen.dart (eyebrow).
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed'**
  String get eventsEventJoinedCelebrationScreenEyebrowBookingConfirmed;

  /// Product copy used by lib/events/shared/event_joined_celebration_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'You\'\'re in.'**
  String get eventsEventJoinedCelebrationScreenTitleYouReIn;

  /// Product copy used by lib/events/shared/event_joined_celebration_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get eventsEventJoinedCelebrationScreenLabelWhen;

  /// Product copy used by lib/events/shared/event_joined_celebration_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get eventsEventJoinedCelebrationScreenLabelWhere;

  /// Product copy used by lib/events/shared/event_joined_celebration_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get eventsEventJoinedCelebrationScreenLabelEvent;

  /// Product copy used by lib/events/shared/event_joined_celebration_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get eventsEventJoinedCelebrationScreenLabelPaid;

  /// Product copy used by lib/events/shared/event_joined_celebration_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Payment ID'**
  String get eventsEventJoinedCelebrationScreenLabelPaymentId;

  /// Product copy used by lib/events/shared/event_joined_celebration_screen.dart (note).
  ///
  /// In en, this message translates to:
  /// **'Arrive by the meeting time. Catches unlock automatically when the event finishes.'**
  String get eventsEventJoinedCelebrationScreenNoteArriveByTheMeeting;

  /// Product copy used by lib/events/shared/event_joined_celebration_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'View event'**
  String get eventsEventJoinedCelebrationScreenLabelViewEvent;

  /// Product copy used by lib/events/shared/event_joined_celebration_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get eventsEventJoinedCelebrationScreenLabelBackToHome;

  /// Product copy used by lib/events/shared/event_share_card.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'CATCH INVITE'**
  String get eventsEventShareCardTextCatchInvite;

  /// Product copy used by lib/events/shared/map_pin_tile.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Pinned location'**
  String get eventsMapPinTileTitlePinnedLocation;

  /// Product copy used by lib/events/shared/map_pin_tile.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Choose on map'**
  String get eventsMapPinTileTitleChooseOnMap;

  /// Product copy used by lib/explore/presentation/explore_map_screen.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Back to Explore'**
  String get exploreExploreMapScreenTooltipBackToExplore;

  /// Product copy used by lib/explore/presentation/explore_screen.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Saved events'**
  String get exploreExploreScreenTooltipSavedEvents;

  /// Button that advances the cursor-paginated Explore discovery window.
  ///
  /// In en, this message translates to:
  /// **'Load more plans'**
  String get exploreExploreScreenActionLoadMorePlans;

  /// Product copy used by lib/explore/presentation/explore_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No organizers match this search'**
  String get exploreExploreScreenTitleNoClubsMatchThis;

  /// Product copy used by lib/explore/presentation/explore_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Clear the search or filters to bring nearby organizers back into view.'**
  String get exploreExploreScreenMessageClearTheSearchOr;

  /// Product copy used by lib/explore/presentation/explore_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Try another organizer, neighborhood, host, or tag.'**
  String get exploreExploreScreenMessageTryAnotherClubNeighborhood;

  /// Product copy used by lib/explore/presentation/explore_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No organizers match these filters'**
  String get exploreExploreScreenTitleNoClubsMatchThese;

  /// Product copy used by lib/explore/presentation/explore_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Clear one or more filters to bring nearby organizers back into view.'**
  String get exploreExploreScreenMessageClearOneOrMore;

  /// Product copy used by lib/explore/presentation/explore_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Clear search and filters'**
  String get exploreExploreScreenLabelClearSearchAndFilters;

  /// Product copy used by lib/explore/presentation/explore_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get exploreExploreScreenLabelClearSearch;

  /// Product copy used by lib/explore/presentation/explore_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get exploreExploreScreenLabelClearFilters;

  /// Product copy used by lib/explore/presentation/explore_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get exploreExploreScreenLabelClear;

  /// Recovery action shown when the selected Explore city has no clubs.
  ///
  /// In en, this message translates to:
  /// **'Change city'**
  String get exploreExploreScreenLabelChangeCity;

  /// Product copy used by lib/explore/presentation/widgets/catch_cover_story.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Change location'**
  String get exploreCatchCoverStoryMessageChangeLocation;

  /// Product copy used by lib/explore/presentation/widgets/catch_cover_story.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get exploreCatchCoverStoryTooltipSearch;

  /// Product copy used by lib/explore/presentation/widgets/explore_city_picker.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get exploreExploreCityPickerTextCity;

  /// Product copy used by lib/explore/presentation/widgets/explore_event_rows.dart (title).
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get exploreExploreEventRowsTitleThisWeek;

  /// Product copy used by lib/explore/presentation/widgets/explore_event_type_browse_grid.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'BY ACTIVITY'**
  String get exploreExploreEventTypeBrowseGridTextByActivity;

  /// Product copy used by lib/explore/presentation/widgets/explore_filter_rail.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Explore filters'**
  String get exploreExploreFilterRailTitleExploreFilters;

  /// Product copy used by lib/explore/presentation/widgets/explore_filter_rail.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Narrow the map and feed without changing your time scope.'**
  String get exploreExploreFilterRailSubtitleNarrowTheMapAnd;

  /// Product copy used by lib/explore/presentation/widgets/explore_filter_rail.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get exploreExploreFilterRailLabelClear;

  /// Filter sheet footer while the current Explore result count is loading.
  ///
  /// In en, this message translates to:
  /// **'Updating plans'**
  String get exploreExploreFilterRailLabelUpdatingPlans;

  /// Filter sheet footer with the exhaustive live Explore result count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Show 1 plan} other{Show {count} plans}}'**
  String exploreExploreFilterRailLabelShowPlans({required int count});

  /// Filter sheet footer with the lower-bound live Explore result count when more pages exist.
  ///
  /// In en, this message translates to:
  /// **'Show {count}+ plans'**
  String exploreExploreFilterRailLabelShowPlansPlus({required int count});

  /// Explore filter heading clarifying that club cards do not carry distance coordinates.
  ///
  /// In en, this message translates to:
  /// **'DISTANCE · EVENTS ONLY'**
  String get exploreExploreFilterRailTextDistanceEventsOnly;

  /// Applied distance-filter chip clarifying its event-only scope.
  ///
  /// In en, this message translates to:
  /// **'{distance} · events only'**
  String exploreExploreFilterRailAppliedDistance({required Object distance});

  /// Product copy used by lib/explore/presentation/widgets/explore_filter_rail.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'ORGANIZERS'**
  String get exploreExploreFilterRailTextClubs;

  /// Product copy used by lib/explore/presentation/widgets/explore_filter_rail.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Followed organizers'**
  String get exploreExploreFilterRailLabelJoinedClubs;

  /// Product copy used by lib/explore/presentation/widgets/explore_filter_rail.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Rated 4.5+'**
  String get exploreExploreFilterRailLabelRated45;

  /// Product copy used by lib/explore/presentation/widgets/explore_filter_rail.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'ACTIVITY'**
  String get exploreExploreFilterRailTextActivity;

  /// Product copy used by lib/explore/presentation/widgets/explore_filter_rail.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'AREA'**
  String get exploreExploreFilterRailTextArea;

  /// Product copy used by lib/explore/presentation/widgets/explore_list.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No organizers match this search'**
  String get exploreExploreListTitleNoClubsMatchThis;

  /// Product copy used by lib/explore/presentation/widgets/explore_list.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Clear the search or filters to bring nearby organizers back into view.'**
  String get exploreExploreListMessageClearTheSearchOr;

  /// Product copy used by lib/explore/presentation/widgets/explore_list.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Try another organizer, neighborhood, host, or tag.'**
  String get exploreExploreListMessageTryAnotherClubNeighborhood;

  /// Product copy used by lib/explore/presentation/widgets/explore_list.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No organizers match these filters'**
  String get exploreExploreListTitleNoClubsMatchThese;

  /// Product copy used by lib/explore/presentation/widgets/explore_list.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Clear one or more filters to bring nearby organizers back into view.'**
  String get exploreExploreListMessageClearOneOrMore;

  /// Product copy used by lib/force_update/presentation/update_required_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get forceUpdateUpdateRequiredScreenTextUpdateRequired;

  /// Product copy used by lib/force_update/presentation/update_required_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get forceUpdateUpdateRequiredScreenLabelUpdateNow;

  /// Product copy used by lib/hosts/presentation/club_management/create/create_club_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Organizer basics'**
  String get hostsCreateClubScreenTitleClubBasics;

  /// Product copy used by lib/hosts/presentation/club_management/create/create_club_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Organizer details'**
  String get hostsCreateClubScreenTitleClubDetails;

  /// Product copy used by lib/hosts/presentation/club_management/create/create_club_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Host defaults'**
  String get hostsCreateClubScreenTitleHostDefaults;

  /// Product copy used by lib/hosts/presentation/club_management/create/create_club_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event success defaults'**
  String get hostsCreateClubScreenTitleEventSuccessDefaults;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_basics_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Organizer name'**
  String get hostsClubBasicsStepTitleClubName;

  /// Canonical organizer classification field shown to organizer owners.
  ///
  /// In en, this message translates to:
  /// **'Organizer type'**
  String get hostsOrganizerTypeLabel;

  /// Organizer type option for a membership-led club.
  ///
  /// In en, this message translates to:
  /// **'Club'**
  String get hostsOrganizerTypeClub;

  /// Organizer type option for a community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get hostsOrganizerTypeCommunity;

  /// Organizer type option for an individual host or curator.
  ///
  /// In en, this message translates to:
  /// **'Individual organizer'**
  String get hostsOrganizerTypeIndividual;

  /// Organizer type option for an event production organization.
  ///
  /// In en, this message translates to:
  /// **'Event producer'**
  String get hostsOrganizerTypeEventProducer;

  /// Organizer type option for a venue.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get hostsOrganizerTypeVenue;

  /// Organizer type option for a brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get hostsOrganizerTypeBrand;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_basics_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get hostsClubBasicsStepTitleCity;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_basics_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Area / neighbourhood'**
  String get hostsClubBasicsStepTitleAreaNeighbourhood;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_basics_step.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'e.g. Bandra, Koramangala'**
  String get hostsClubBasicsStepPlaceholderEGBandraKoramangala;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_details_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get hostsClubDetailsStepTitleDescription;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_event_success_defaults_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Live event guide'**
  String get hostsClubEventSuccessDefaultsStepTitleLiveEventGuide;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_event_success_defaults_step.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'New events start with a ready-to-run plan for this activity. You can adjust any event\'\'s plan later.'**
  String
  get hostsClubEventSuccessDefaultsStepSubtitleNewEventsStartWithAReadyToRunPlanForThisActivity;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Default activity'**
  String get hostsClubHostDefaultsStepTextDefaultActivity;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'New events start from this activity. Hosts can still change the activity and override the event-specific setup.'**
  String get hostsClubHostDefaultsStepTextNewEventsStartFrom;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Default event policy'**
  String get hostsClubHostDefaultsStepTextDefaultEventPolicy;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'These defaults prefill new events. Hosts can override them per event before anyone books or joins the waitlist.'**
  String get hostsClubHostDefaultsStepTextTheseDefaultsPrefillNew;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Cohort caps'**
  String get hostsClubHostDefaultsStepTitleCohortCaps;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Optionally prefill straight men and straight women caps for open events.'**
  String get hostsClubHostDefaultsStepBodyOptionallyPrefillStraightMen;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Max straight men'**
  String get hostsClubHostDefaultsStepTitleMaxStraightMen;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Max straight women'**
  String get hostsClubHostDefaultsStepTitleMaxStraightWomen;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Demand pricing'**
  String get hostsClubHostDefaultsStepTitleDemandPricing;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Prefill dynamic pricing controls for balanced singles events.'**
  String get hostsClubHostDefaultsStepBodyPrefillDynamicPricingControls;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get hostsClubHostDefaultsStepTitleStep;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get hostsClubHostDefaultsStepTitleMax;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/create_club_contact_fields.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Instagram handle'**
  String get hostsCreateClubContactFieldsTitleInstagramHandle;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/create_club_contact_fields.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'@yourclub'**
  String get hostsCreateClubContactFieldsPlaceholderYourclub;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/create_club_contact_fields.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get hostsCreateClubContactFieldsTitlePhoneNumber;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/create_club_contact_fields.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get hostsCreateClubContactFieldsTitleEmail;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/create_club_contact_fields.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'hello@yourclub.com'**
  String get hostsCreateClubContactFieldsPlaceholderHelloYourclubCom;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder - the first photo is your cover. Add as many as you like.'**
  String get hostsCreateClubPhotosPickerTextDragToReorderThe;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'A square logo, shown on your organizer profile and every event.'**
  String get hostsCreateClubPhotosPickerTextASquareLogoShown;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Change organizer profile image'**
  String get hostsCreateClubPhotosPickerLabelChangeClubProfileImage;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Add organizer profile image'**
  String get hostsCreateClubPhotosPickerLabelAddClubProfileImage;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get hostsCreateClubPhotosPickerTextAddImage;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Decrease duration'**
  String get hostsEditHostedEventScreenBodyDecreaseDuration;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Increase duration'**
  String get hostsEditHostedEventScreenBodyIncreaseDuration;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Location name'**
  String get hostsEditHostedEventScreenTitleLocationName;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'e.g. Bandstand Promenade, Bandra'**
  String get hostsEditHostedEventScreenPlaceholderEGBandstandPromenade;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (helperText).
  ///
  /// In en, this message translates to:
  /// **'This is what attendees see in event cards and details.'**
  String get hostsEditHostedEventScreenHelpertextThisIsWhatAttendees;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get hostsEditHostedEventScreenBodyRequired;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Extra directions'**
  String get hostsEditHostedEventScreenTitleExtraDirections;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'e.g. Meet outside the blue gate, third entrance'**
  String get hostsEditHostedEventScreenPlaceholderEGMeetOutside;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Distance (km)'**
  String get hostsEditHostedEventScreenTitleDistanceKm;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'^\\d*\\.?\\d*'**
  String get hostsEditHostedEventScreenBodyDD;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get hostsEditHostedEventScreenBodyInvalid;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Must be > 0'**
  String get hostsEditHostedEventScreenBodyMustBe0;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get hostsEditHostedEventScreenTitleDescription;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'What should attendees expect? Any tips for the route or venue?'**
  String get hostsEditHostedEventScreenPlaceholderWhatShouldAttendeesExpect;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event date'**
  String get hostsEditHostedEventScreenTitleEventDate;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get hostsEditHostedEventScreenTitleStartTime;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Cancelled event'**
  String get hostsEditHostedEventScreenTitleCancelledEvent;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Schedule locked'**
  String get hostsEditHostedEventScreenTitleScheduleLocked;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Published event'**
  String get hostsEditHostedEventScreenTitlePublishedEvent;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Cancelled events cannot be edited. Create a new event if you need to host this again.'**
  String get hostsEditHostedEventScreenMessageCancelledEventsCannotBe;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'You can still update location and descriptive details. Date, time, and duration stay locked after the event starts or once people have joined.'**
  String get hostsEditHostedEventScreenMessageYouCanStillUpdate;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'You can edit the schedule, location, distance, and description. Capacity, pricing, admission policy, and invite setup are locked by existing event activity.'**
  String get hostsEditHostedEventScreenMessageYouCanEditThe;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'You can edit schedule, location, event details, capacity, pricing, admission policy, and invite setup until the first booking or waitlist join.'**
  String get hostsEditHostedEventScreenMessageYouCanEditSchedule;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Editable until the first booking or waitlist join.'**
  String get hostsEditHostedEventScreenTextEditableUntilTheFirst;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Max attendees'**
  String get hostsEditHostedEventScreenTitleMaxAttendees;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Loading current invite code...'**
  String get hostsEditHostedEventScreenTextLoadingCurrentInviteCode;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get hostsEditHostedEventScreenTitleInviteCode;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'CATCH-DELHI'**
  String get hostsEditHostedEventScreenPlaceholderCatchDelhi;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Cohort caps'**
  String get hostsEditHostedEventScreenTitleCohortCaps;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Optionally cap straight men and straight women without making this a separate admission format.'**
  String get hostsEditHostedEventScreenBodyOptionallyCapStraightMen;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Max straight men'**
  String get hostsEditHostedEventScreenTitleMaxStraightMen;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Max straight women'**
  String get hostsEditHostedEventScreenTitleMaxStraightWomen;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Requests appear in host manage with each person\'\'s public profile so the host can review fit before confirming spots.'**
  String get hostsEditHostedEventScreenTextRequestsAppearInHost;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Demand pricing'**
  String get hostsEditHostedEventScreenTitleDemandPricing;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Increase price for the over-demand cohort while preserving the event balance.'**
  String get hostsEditHostedEventScreenBodyIncreasePriceForThe;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Policy locked'**
  String get hostsEditHostedEventScreenTextPolicyLocked;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Capacity, pricing, admission, and cancellation policy lock once the event starts or someone books or joins the waitlist.'**
  String get hostsEditHostedEventScreenTextCapacityPricingAdmissionAnd;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get hostsEditHostedEventScreenLabelCapacity;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get hostsEditHostedEventScreenLabelPrice;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Admission'**
  String get hostsEditHostedEventScreenLabelAdmission;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Cancellation'**
  String get hostsEditHostedEventScreenLabelCancellation;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Schedule changes are blocked here to avoid changing attendee commitments.'**
  String get hostsEditHostedEventScreenTextScheduleChangesAreBlocked;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event date'**
  String get hostsCreateEventScreenTitleEventDate;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get hostsCreateEventScreenTitleStartTime;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_success_screen.dart (eyebrow).
  ///
  /// In en, this message translates to:
  /// **'Event created'**
  String get hostsCreateEventSuccessScreenEyebrowEventCreated;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_success_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Your event is live.'**
  String get hostsCreateEventSuccessScreenTitleYourEventIsLive;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_success_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get hostsCreateEventSuccessScreenLabelWhen;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_success_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get hostsCreateEventSuccessScreenLabelWhere;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_success_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get hostsCreateEventSuccessScreenLabelEvent;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_success_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get hostsCreateEventSuccessScreenLabelCapacity;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_success_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get hostsCreateEventSuccessScreenLabelInviteCode;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_success_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Private link'**
  String get hostsCreateEventSuccessScreenLabelPrivateLink;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_success_screen.dart (note).
  ///
  /// In en, this message translates to:
  /// **'Bookings, waitlist, and attendance are tracked from Manage event.'**
  String get hostsCreateEventSuccessScreenNoteBookingsWaitlistAndAttendance;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_success_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Manage event'**
  String get hostsCreateEventSuccessScreenLabelManageEvent;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_success_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Back to organizer'**
  String get hostsCreateEventSuccessScreenLabelBackToClub;

  /// Product copy used by lib/hosts/presentation/event_management/host_create_event_route_loading_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event basics'**
  String get hostsHostCreateEventRouteLoadingScreenTitleEventBasics;

  /// Product copy used by lib/hosts/presentation/event_management/host_create_event_route_loading_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Loading organizer'**
  String get hostsHostCreateEventRouteLoadingScreenBodyLoadingClub;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/draft_picker_sheet.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Resume a draft?'**
  String get hostsDraftPickerSheetTitleResumeADraft;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/draft_picker_sheet.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Pick up where you left off, or start fresh.'**
  String get hostsDraftPickerSheetSubtitlePickUpWhereYou;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/draft_picker_sheet.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Start a fresh event'**
  String get hostsDraftPickerSheetLabelStartAFreshEvent;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/draft_picker_sheet.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No drafts yet'**
  String get hostsDraftPickerSheetTitleNoDraftsYet;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/draft_picker_sheet.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Saved drafts for this organizer will appear here.'**
  String get hostsDraftPickerSheetMessageSavedDraftsForThis;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/draft_picker_sheet.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Delete draft'**
  String get hostsDraftPickerSheetMessageDeleteDraft;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_details_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Format name'**
  String get hostsEventDetailsStepTitleFormatName;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_details_step.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'Salsa night'**
  String get hostsEventDetailsStepPlaceholderSalsaNight;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_details_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Distance (km)'**
  String get hostsEventDetailsStepTitleDistanceKm;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_details_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get hostsEventDetailsStepTitleDescription;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_details_step.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'What should attendees expect? Any tips for the route or venue?'**
  String get hostsEventDetailsStepPlaceholderWhatShouldAttendeesExpect;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Configure who can book, how waitlists open, what attendees pay, and what happens if plans change.'**
  String get hostsEventPolicyStepTextConfigureWhoCanBook;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Max attendees'**
  String get hostsEventPolicyStepTitleMaxAttendees;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'The code is stored in the host-only private access document. Public event listings only show that an invite is required.'**
  String get hostsEventPolicyStepTextTheCodeIsStored;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get hostsEventPolicyStepTitleInviteCode;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'CATCH-DELHI'**
  String get hostsEventPolicyStepPlaceholderCatchDelhi;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Cohort caps'**
  String get hostsEventPolicyStepTitleCohortCaps;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Optionally cap straight men and straight women without making this a separate admission format.'**
  String get hostsEventPolicyStepBodyOptionallyCapStraightMen;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Max straight men'**
  String get hostsEventPolicyStepTitleMaxStraightMen;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'Max men'**
  String get hostsEventPolicyStepPlaceholderMaxMen;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Max straight women'**
  String get hostsEventPolicyStepTitleMaxStraightWomen;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'Max women'**
  String get hostsEventPolicyStepPlaceholderMaxWomen;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Requests appear in host manage with each person\'\'s public profile so the host can review fit before confirming spots.'**
  String get hostsEventPolicyStepTextRequestsAppearInHost;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Demand pricing'**
  String get hostsEventPolicyStepTitleDemandPricing;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Increase the straight-men price when that cohort has more booked and waitlisted demand than the balancing cohort.'**
  String get hostsEventPolicyStepBodyIncreaseTheStraightMen;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Host payout is released after event completion. If the host cancels, attendees are made complete before any host payout.'**
  String get hostsEventPolicyStepTextHostPayoutIsReleased;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_success_step.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Prepare the host guide for this event. You can adjust it again before Live mode starts.'**
  String get hostsEventSuccessStepTextPrepareTheHostGuide;

  /// Title for the live event guide toggle in event creation.
  ///
  /// In en, this message translates to:
  /// **'Live event guide'**
  String get hostsEventSuccessStepTitleLiveEventGuide;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_success_step.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Save a simple plan with this event so Live mode is ready when it starts.'**
  String get hostsEventSuccessStepSubtitleSaveASimplePlan;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/when_step.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get hostsWhenStepPlaceholderSelectADate;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/when_step.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'Select start time'**
  String get hostsWhenStepPlaceholderSelectStartTime;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/where_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Location name'**
  String get hostsWhereStepTitleLocationName;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/where_step.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'e.g. Bandstand Promenade, Bandra'**
  String get hostsWhereStepPlaceholderEGBandstandPromenade;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/where_step.dart (helperText).
  ///
  /// In en, this message translates to:
  /// **'Pick a map location first. Google Places fills this when available.'**
  String get hostsWhereStepHelpertextPickAMapLocation;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/where_step.dart (helperText).
  ///
  /// In en, this message translates to:
  /// **'Edit this if attendees need a clearer name.'**
  String get hostsWhereStepHelpertextEditThisIfAttendees;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/where_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Extra directions'**
  String get hostsWhereStepTitleExtraDirections;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/where_step.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'e.g. Meet outside the blue gate, third entrance'**
  String get hostsWhereStepPlaceholderEGMeetOutside;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/where_step.dart (helperText).
  ///
  /// In en, this message translates to:
  /// **'Gate, entrance, floor, or landmark for the group.'**
  String get hostsWhereStepHelpertextGateEntranceFloorOr;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Cancel this event?'**
  String get hostsHostEventManageScreenTitleCancelThisEvent;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Cancelling removes it from schedules but keeps attendee, payment, and history records. Attendees are notified and refunded per your cancellation policy.'**
  String get hostsHostEventManageScreenMessageCancellingRemovesItFrom;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Delete unused event?'**
  String get hostsHostEventManageScreenTitleDeleteUnusedEvent;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Only events with no bookings, waitlist, attendance, payments, or reviews can be deleted. This permanently removes the event.'**
  String get hostsHostEventManageScreenMessageOnlyEventsWithNo;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Disable invite link?'**
  String get hostsHostEventManageScreenTitleDisableInviteLink;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Loading invite access...'**
  String get hostsHostEventManageScreenTextLoadingInviteAccess;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Private access'**
  String get hostsHostEventManageScreenTextPrivateAccess;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get hostsHostEventManageScreenLabelCode;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get hostsHostEventManageScreenLabelLink;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Share private link'**
  String get hostsHostEventManageScreenLabelSharePrivateLink;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'New link'**
  String get hostsHostEventManageScreenLabelNewLink;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Named invite links'**
  String get hostsHostEventManageScreenTextNamedInviteLinks;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Track which channels create demand, bookings, arrivals, catches, and chats.'**
  String get hostsHostEventManageScreenTextTrackWhichChannelsCreate;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Loading invite links...'**
  String get hostsHostEventManageScreenTextLoadingInviteLinks;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get hostsHostEventManageScreenMessageCopyLink;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Disable link'**
  String get hostsHostEventManageScreenMessageDisableLink;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'New invite link'**
  String get hostsHostEventManageScreenTitleNewInviteLink;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get hostsHostEventManageScreenLabelCancel;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get hostsHostEventManageScreenLabelCreate;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get hostsHostEventManageScreenTitleLabel;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'Instagram bio'**
  String get hostsHostEventManageScreenPlaceholderInstagramBio;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get hostsHostEventManageScreenTitleSource;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'instagram'**
  String get hostsHostEventManageScreenPlaceholderInstagram;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get hostsHostEventManageScreenLabelBooked;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Waitlist'**
  String get hostsHostEventManageScreenLabelWaitlist;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (detail).
  ///
  /// In en, this message translates to:
  /// **'1 to review'**
  String get hostsHostEventManageScreenDetail1ToReview;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Revenue est'**
  String get hostsHostEventManageScreenLabelRevenueEst;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Refund policy'**
  String get hostsHostEventManageScreenLabelRefundPolicy;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'FULL - CAPACITY REACHED'**
  String get hostsHostEventManageScreenTextFullCapacityReached;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'WAITLIST OPEN'**
  String get hostsHostEventManageScreenTextWaitlistOpen;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'HOST ACTIONS'**
  String get hostsHostEventManageScreenTextHostActions;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Edit event details'**
  String get hostsHostEventManageScreenLabelEditEventDetails;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (detail).
  ///
  /// In en, this message translates to:
  /// **'Schedule · location'**
  String get hostsHostEventManageScreenDetailScheduleLocation;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'DANGER ZONE'**
  String get hostsHostEventManageScreenTextDangerZone;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Cancel event'**
  String get hostsHostEventManageScreenLabelCancelEvent;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Delete unused event'**
  String get hostsHostEventManageScreenLabelDeleteUnusedEvent;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get hostsHostEventManageScreenLabelClub;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Meet'**
  String get hostsHostEventManageScreenLabelMeet;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get hostsHostEventManageScreenLabelEvent;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get hostsHostEventManageScreenLabelPrice;

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (title).
  ///
  /// In en, this message translates to:
  /// **'New broadcast'**
  String get hostsHostBroadcastComposerSheetTitleNewBroadcast;

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Audience'**
  String get hostsHostBroadcastComposerSheetTextAudience;

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get hostsHostBroadcastComposerSheetTextTemplate;

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get hostsHostBroadcastComposerSheetTitleMessage;

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'Write a clear update for attendees'**
  String get hostsHostBroadcastComposerSheetPlaceholderWriteAClearUpdate;

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Sending stays off in this build until the production callable passes the release preflight.'**
  String get hostsHostBroadcastComposerSheetTextSendingStaysOffIn;

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'This audience has no eligible recipients yet.'**
  String get hostsHostBroadcastComposerSheetTextThisAudienceHasNo;

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Send to 1 person'**
  String get hostsHostBroadcastComposerSheetLabelSendTo1Person;

  /// Product copy used by lib/hosts/presentation/inbox/host_inbox_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Inbox scope'**
  String get hostsHostInboxScreenLabelInboxScope;

  /// Product copy used by lib/hosts/presentation/inbox/host_inbox_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'booked attendees'**
  String get hostsHostInboxScreenTitleBookedAttendees;

  /// Product copy used by lib/hosts/presentation/inbox/host_inbox_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'prospective attendees'**
  String get hostsHostInboxScreenTitleProspectiveAttendees;

  /// Product copy used by lib/hosts/presentation/inbox/host_inbox_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Personal questions appear here. Broadcast audience size is based on the event roster, not this thread list.'**
  String get hostsHostInboxScreenMessagePersonalQuestionsAppearHere;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Set up payouts'**
  String get hostsHostPaymentAccountCardTitleSetUpPayouts;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Powered by Stripe'**
  String get hostsHostPaymentAccountCardSubtitlePoweredByStripe;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Continue to Stripe'**
  String get hostsHostPaymentAccountCardLabelContinueToStripe;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Catch pays hosts through Stripe. Finish a short verification on Stripe, then come back here before paid non-INR events can take checkout.'**
  String get hostsHostPaymentAccountCardTextCatchPaysHostsThrough;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get hostsHostPaymentAccountCardTitleCountry;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Default currency'**
  String get hostsHostPaymentAccountCardTitleDefaultCurrency;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'We will refresh your payout status when you return.'**
  String get hostsHostPaymentAccountCardTextWeWillRefreshYour;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Set up payouts'**
  String get hostsHostPaymentAccountCardLabelSetUpPayouts;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Continue setup'**
  String get hostsHostPaymentAccountCardLabelContinueSetup;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get hostsHostPaymentAccountCardLabelRefresh;

  /// Product copy used by lib/hosts/presentation/widgets/catch_roster_board.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get hostsCatchRosterBoardLabelOpenProfile;

  /// Product copy used by lib/hosts/presentation/widgets/catch_roster_board.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Approve request'**
  String get hostsCatchRosterBoardLabelApproveRequest;

  /// Product copy used by lib/hosts/presentation/widgets/catch_roster_board.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Decline request'**
  String get hostsCatchRosterBoardLabelDeclineRequest;

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Manage this organizer, publish events, and track upcoming demand.'**
  String get hostsHostClubToolsTextManageThisClubPublish;

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get hostsHostClubToolsLabelBooked;

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Waitlist'**
  String get hostsHostClubToolsLabelWaitlist;

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Base est.'**
  String get hostsHostClubToolsLabelBaseEst;

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get hostsHostClubToolsLabelRevenue;

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Base estimate uses starting prices; demand-priced bookings may settle higher.'**
  String get hostsHostClubToolsTextBaseEstimateUsesStarting;

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get hostsHostClubToolsLabelAddEvent;

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Post quota used'**
  String get hostsHostClubToolsLabelPostQuotaUsed;

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Post update'**
  String get hostsHostClubToolsLabelPostUpdate;

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Edit organizer'**
  String get hostsHostClubToolsLabelEditClub;

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Post to followers'**
  String get hostsHostClubToolsTitlePostToFollowers;

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Posting...'**
  String get hostsHostClubToolsLabelPosting;

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (CatchButton).
  ///
  /// In en, this message translates to:
  /// **'Posted to followers.'**
  String get hostsHostClubToolsCatchbuttonPostedToFollowers;

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get hostsHostClubToolsTitleUpdate;

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'Share a route note, meetup detail, or organizer update.'**
  String get hostsHostClubToolsPlaceholderShareARouteNote;

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Could not post this update. Please try again.'**
  String get hostsHostClubToolsTextCouldNotPostThis;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event not found'**
  String get hostsHostEventAttendancePanelTitleEventNotFound;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This event is no longer available.'**
  String get hostsHostEventAttendancePanelMessageThisEventIsNo;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Participation'**
  String get hostsHostEventAttendancePanelTitleParticipation;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Review profiles and approve requests before launch.'**
  String get hostsHostEventAttendancePanelSubtitleReviewProfilesAndApprove;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Review booking status before launch.'**
  String get hostsHostEventAttendancePanelSubtitleReviewBookingStatusBefore;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Search people'**
  String get hostsHostEventAttendancePanelLabelSearchPeople;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Check-in board'**
  String get hostsHostEventAttendancePanelTitleCheckInBoard;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Use the status tiles to focus the roster as people arrive.'**
  String get hostsHostEventAttendancePanelSubtitleUseTheStatusTiles;

  /// Title for the host disclosure that reveals the attendee check-in QR code.
  ///
  /// In en, this message translates to:
  /// **'Check-in QR'**
  String get hostsHostEventAttendancePanelTitleCheckInQr;

  /// Supporting copy for the host attendee check-in QR disclosure.
  ///
  /// In en, this message translates to:
  /// **'Show this code to attendees as they arrive.'**
  String get hostsHostEventAttendancePanelBodyCheckInQr;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Search roster'**
  String get hostsHostEventAttendancePanelLabelSearchRoster;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event report'**
  String get hostsHostEventAttendancePanelTitleEventReport;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Attendance, payout, and export-ready roster history.'**
  String get hostsHostEventAttendancePanelSubtitleAttendancePayoutAndExport;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Ops CSV'**
  String get hostsHostEventAttendancePanelLabelOpsCsv;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Revenue CSV'**
  String get hostsHostEventAttendancePanelLabelRevenueCsv;

  /// Accessible label for the report export action menu.
  ///
  /// In en, this message translates to:
  /// **'Export report'**
  String get hostsHostEventAttendancePanelLabelExport;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Waitlist movement'**
  String get hostsHostEventAttendancePanelTextWaitlistMovement;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_tools.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Host event tools carousel'**
  String get hostsHostEventToolsLabelHostEventToolsCarousel;

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Host team'**
  String get hostsHostTeamManagementSectionTitleHostTeam;

  /// Empty roster copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (text).
  ///
  /// In en, this message translates to:
  /// **'No host team members yet.'**
  String get hostsHostTeamManagementSectionTextNoHostTeamMembers;

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Host actions'**
  String get hostsHostTeamManagementSectionTooltipHostActions;

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Transfer ownership'**
  String get hostsHostTeamManagementSectionLabelTransferOwnership;

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Remove host'**
  String get hostsHostTeamManagementSectionLabelRemoveHost;

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Add host'**
  String get hostsHostTeamManagementSectionTitleAddHost;

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Enter the phone number on their Catch profile.'**
  String get hostsHostTeamManagementSectionSubtitleEnterThePhoneNumber;

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Add host'**
  String get hostsHostTeamManagementSectionLabelAddHost;

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get hostsHostTeamManagementSectionTitlePhoneNumber;

  /// Product copy used by lib/hosts/presentation/widgets/stepper_footer.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get hostsStepperFooterLabelNext;

  /// Product copy used by lib/hosts/presentation/widgets/stepper_footer.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get hostsStepperFooterLabelSaveDraft;

  /// Product copy used by lib/image_uploads/shared/profile_photo_editor_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Delete photo?'**
  String get imageUploadsProfilePhotoEditorScreenTitleDeletePhoto;

  /// Product copy used by lib/image_uploads/shared/profile_photo_editor_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This removes the photo from your profile.'**
  String get imageUploadsProfilePhotoEditorScreenMessageThisRemovesThePhoto;

  /// Product copy used by lib/image_uploads/shared/profile_photo_editor_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get imageUploadsProfilePhotoEditorScreenTitleAddPhoto;

  /// Product copy used by lib/image_uploads/shared/profile_photo_editor_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Edit photo'**
  String get imageUploadsProfilePhotoEditorScreenTitleEditPhoto;

  /// Product copy used by lib/image_uploads/shared/profile_photo_editor_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Photo prompt'**
  String get imageUploadsProfilePhotoEditorScreenTitlePhotoPrompt;

  /// Product copy used by lib/image_uploads/shared/profile_photo_editor_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get imageUploadsProfilePhotoEditorScreenLabelSaving;

  /// Product copy used by lib/image_uploads/shared/profile_photo_editor_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get imageUploadsProfilePhotoEditorScreenLabelSaveChanges;

  /// Product copy used by lib/image_uploads/shared/profile_photo_editor_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get imageUploadsProfilePhotoEditorScreenLabelChoosePhoto;

  /// Product copy used by lib/image_uploads/shared/profile_photo_editor_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get imageUploadsProfilePhotoEditorScreenLabelChangePhoto;

  /// Product copy used by lib/image_uploads/shared/profile_photo_editor_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Deleting'**
  String get imageUploadsProfilePhotoEditorScreenLabelDeleting;

  /// Product copy used by lib/image_uploads/shared/profile_photo_editor_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Delete photo'**
  String get imageUploadsProfilePhotoEditorScreenLabelDeletePhoto;

  /// Product copy used by lib/image_uploads/shared/profile_photo_editor_screen.dart (CatchButton).
  ///
  /// In en, this message translates to:
  /// **'Delete photo unavailable'**
  String
  get imageUploadsProfilePhotoEditorScreenCatchbuttonDeletePhotoUnavailable;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Access gate is off'**
  String get launchAccessLaunchAccessApplicationScreenTitleAccessGateIsOff;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Remote Config has not enabled launch access for this build.'**
  String get launchAccessLaunchAccessApplicationScreenMessageRemoteConfigHasNot;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Verify your phone'**
  String get launchAccessLaunchAccessApplicationScreenTitleVerifyYourPhone;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Phone verification is required before applying for access.'**
  String
  get launchAccessLaunchAccessApplicationScreenMessagePhoneVerificationIsRequired;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Access is approved. Profile creation can be unlocked once the router uses this gate.'**
  String
  get launchAccessLaunchAccessApplicationScreenMessageAccessIsApprovedProfile;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Your application is saved for the next launch cohort.'**
  String
  get launchAccessLaunchAccessApplicationScreenMessageYourApplicationIsSaved;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Join the next city drop'**
  String get launchAccessLaunchAccessApplicationScreenTextJoinTheNextCity;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Tell us where you fit so we can open access around real events.'**
  String get launchAccessLaunchAccessApplicationScreenTextTellUsWhereYou;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get launchAccessLaunchAccessApplicationScreenTitleCity;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (hintText).
  ///
  /// In en, this message translates to:
  /// **'Select city'**
  String get launchAccessLaunchAccessApplicationScreenHinttextSelectCity;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Joining as'**
  String get launchAccessLaunchAccessApplicationScreenLabelJoiningAs;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Events you would show up for'**
  String get launchAccessLaunchAccessApplicationScreenLabelEventsYouWouldShow;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Best times'**
  String get launchAccessLaunchAccessApplicationScreenLabelBestTimes;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'I might host'**
  String get launchAccessLaunchAccessApplicationScreenTitleIMightHost;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Useful if you already run a club, venue, or social format.'**
  String get launchAccessLaunchAccessApplicationScreenBodyUsefulIfYouAlready;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get launchAccessLaunchAccessApplicationScreenTitleInviteCode;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get launchAccessLaunchAccessApplicationScreenTitleInstagram;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Who referred you?'**
  String get launchAccessLaunchAccessApplicationScreenTitleWhoReferredYou;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Why do you want to join?'**
  String get launchAccessLaunchAccessApplicationScreenTitleWhyDoYouWant;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Submit application'**
  String get launchAccessLaunchAccessApplicationScreenLabelSubmitApplication;

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Update application'**
  String get launchAccessLaunchAccessApplicationScreenLabelUpdateApplication;

  /// Product copy used by lib/matches/shared/match_celebration_dialog.dart (eyebrow).
  ///
  /// In en, this message translates to:
  /// **'New catch'**
  String get matchesMatchCelebrationDialogEyebrowNewCatch;

  /// Product copy used by lib/matches/shared/match_celebration_dialog.dart (title).
  ///
  /// In en, this message translates to:
  /// **'It\'\'s a Catch.'**
  String get matchesMatchCelebrationDialogTitleItSACatch;

  /// Product copy used by lib/matches/shared/match_celebration_dialog.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get matchesMatchCelebrationDialogLabelMatch;

  /// Product copy used by lib/matches/shared/match_celebration_dialog.dart (note).
  ///
  /// In en, this message translates to:
  /// **'Start with something specific from their profile or event history.'**
  String get matchesMatchCelebrationDialogNoteStartWithSomethingSpecific;

  /// Product copy used by lib/matches/shared/match_celebration_dialog.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Send a message'**
  String get matchesMatchCelebrationDialogLabelSendAMessage;

  /// Product copy used by lib/matches/shared/match_celebration_dialog.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Keep catching'**
  String get matchesMatchCelebrationDialogLabelKeepCatching;

  /// Product copy used by lib/onboarding/presentation/pages/gender_interest_page.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingGenderInterestPageLabelContinue;

  /// Product copy used by lib/onboarding/presentation/pages/gender_interest_page.dart (label).
  ///
  /// In en, this message translates to:
  /// **'I AM A'**
  String get onboardingGenderInterestPageLabelIAmA;

  /// Product copy used by lib/onboarding/presentation/pages/gender_interest_page.dart (label).
  ///
  /// In en, this message translates to:
  /// **'SHOW ME'**
  String get onboardingGenderInterestPageLabelShowMe;

  /// Product copy used by lib/onboarding/presentation/pages/instagram_page.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingInstagramPageLabelContinue;

  /// Product copy used by lib/onboarding/presentation/pages/instagram_page.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get onboardingInstagramPageLabelSkipForNow;

  /// Product copy used by lib/onboarding/presentation/pages/instagram_page.dart (title).
  ///
  /// In en, this message translates to:
  /// **'HANDLE'**
  String get onboardingInstagramPageTitleHandle;

  /// Product copy used by lib/onboarding/presentation/pages/instagram_page.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'@yourhandle'**
  String get onboardingInstagramPagePlaceholderYourhandle;

  /// Product copy used by lib/onboarding/presentation/pages/name_dob_page.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingNameDobPageLabelContinue;

  /// Product copy used by lib/onboarding/presentation/pages/name_dob_page.dart (title).
  ///
  /// In en, this message translates to:
  /// **'FIRST NAME'**
  String get onboardingNameDobPageTitleFirstName;

  /// Product copy used by lib/onboarding/presentation/pages/name_dob_page.dart (helperText).
  ///
  /// In en, this message translates to:
  /// **'Displayed on your profile.'**
  String get onboardingNameDobPageHelpertextDisplayedOnYourProfile;

  /// Product copy used by lib/onboarding/presentation/pages/name_dob_page.dart (title).
  ///
  /// In en, this message translates to:
  /// **'LAST NAME'**
  String get onboardingNameDobPageTitleLastName;

  /// Product copy used by lib/onboarding/presentation/pages/name_dob_page.dart (helperText).
  ///
  /// In en, this message translates to:
  /// **'Private. We never show this on your public profile.'**
  String get onboardingNameDobPageHelpertextPrivateWeNeverShow;

  /// Product copy used by lib/onboarding/presentation/pages/name_dob_page.dart (title).
  ///
  /// In en, this message translates to:
  /// **'DATE OF BIRTH'**
  String get onboardingNameDobPageTitleDateOfBirth;

  /// Product copy used by lib/onboarding/presentation/pages/name_dob_page.dart (helperText).
  ///
  /// In en, this message translates to:
  /// **'We never show your birth year.'**
  String get onboardingNameDobPageHelpertextWeNeverShowYour;

  /// Product copy used by lib/onboarding/presentation/pages/name_dob_page.dart (title).
  ///
  /// In en, this message translates to:
  /// **'PHONE'**
  String get onboardingNameDobPageTitlePhone;

  /// Product copy used by lib/onboarding/presentation/pages/name_dob_page.dart (helperText).
  ///
  /// In en, this message translates to:
  /// **'Verified via OTP.'**
  String get onboardingNameDobPageHelpertextVerifiedViaOtp;

  /// Product copy used by lib/onboarding/presentation/pages/photos_page.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingPhotosPageLabelContinue;

  /// Product copy used by lib/onboarding/presentation/pages/profile_prompts_page.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingProfilePromptsPageLabelContinue;

  /// Product copy used by lib/onboarding/presentation/pages/profile_prompts_page.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Profile prompt'**
  String get onboardingProfilePromptsPageTitleProfilePrompt;

  /// Product copy used by lib/onboarding/presentation/pages/profile_prompts_page.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get onboardingProfilePromptsPageTitleAnswer;

  /// Product copy used by lib/onboarding/presentation/pages/running_prefs_page.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'TYPICAL PACE · PER KM'**
  String get onboardingRunningPrefsPageTextTypicalPacePerKm;

  /// Selected running pace range shown by the onboarding pace field.
  ///
  /// In en, this message translates to:
  /// **'{minPace} - {maxPace}'**
  String onboardingRunningPrefsPageBodyPaceRange({
    required String minPace,
    required String maxPace,
  });

  /// Product copy used by lib/onboarding/presentation/pages/running_prefs_page.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'4:00 FAST'**
  String get onboardingRunningPrefsPageText400Fast;

  /// Product copy used by lib/onboarding/presentation/pages/running_prefs_page.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'9:00 EASY'**
  String get onboardingRunningPrefsPageText900Easy;

  /// Product copy used by lib/onboarding/presentation/pages/running_prefs_page.dart (label).
  ///
  /// In en, this message translates to:
  /// **'FAVOURITE DISTANCES'**
  String get onboardingRunningPrefsPageLabelFavouriteDistances;

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Payment not completed'**
  String get paymentsPaymentConfirmationScreenTitlePaymentNotCompleted;

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Checkout is waiting'**
  String get paymentsPaymentConfirmationScreenTitleCheckoutIsWaiting;

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get paymentsPaymentConfirmationScreenLabelFailed;

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get paymentsPaymentConfirmationScreenLabelPending;

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'View payment history'**
  String get paymentsPaymentConfirmationScreenLabelViewPaymentHistory;

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Back to event'**
  String get paymentsPaymentConfirmationScreenLabelBackToEvent;

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Add to calendar'**
  String get paymentsPaymentConfirmationScreenLabelAddToCalendar;

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Get directions'**
  String get paymentsPaymentConfirmationScreenLabelGetDirections;

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Invite friend'**
  String get paymentsPaymentConfirmationScreenLabelInviteFriend;

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'HEADS UP'**
  String get paymentsPaymentConfirmationScreenTextHeadsUp;

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Bring someone you actually want there'**
  String get paymentsPaymentConfirmationScreenTextBringSomeoneYouActually;

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'The best invites happen while the plan still feels fresh.'**
  String get paymentsPaymentConfirmationScreenTextTheBestInvitesHappen;

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get paymentsPaymentConfirmationScreenTextShare;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get paymentsPaymentHistoryScreenTitleSignInRequired;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Sign in again to view payment history.'**
  String get paymentsPaymentHistoryScreenMessageSignInAgainTo;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get paymentsPaymentHistoryScreenTitleNoPaymentsYet;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Event bookings and refunds will appear here.'**
  String get paymentsPaymentHistoryScreenMessageEventBookingsAndRefunds;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Payment ID'**
  String get paymentsPaymentHistoryScreenTitlePaymentId;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get paymentsPaymentHistoryScreenTitleOrderId;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event ID'**
  String get paymentsPaymentHistoryScreenTitleEventId;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get paymentsPaymentHistoryScreenTitleDate;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get paymentsPaymentHistoryScreenTitleStatus;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Get help with this booking'**
  String get paymentsPaymentHistoryScreenLabelGetHelpWithThis;

  /// Product copy used by lib/public_profile/presentation/public_profile_screen.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Profile actions'**
  String get publicProfilePublicProfileScreenTooltipProfileActions;

  /// Product copy used by lib/public_profile/presentation/public_profile_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get publicProfilePublicProfileScreenLabelReport;

  /// Product copy used by lib/public_profile/presentation/public_profile_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get publicProfilePublicProfileScreenLabelBlock;

  /// Product copy used by lib/public_profile/presentation/public_profile_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Profile unavailable'**
  String get publicProfilePublicProfileScreenTitleProfileUnavailable;

  /// Product copy used by lib/public_profile/presentation/public_profile_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This profile is no longer available on Catch.'**
  String get publicProfilePublicProfileScreenMessageThisProfileIsNo;

  /// Product copy used by lib/public_profile/presentation/public_profile_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Harassment or abuse'**
  String get publicProfilePublicProfileScreenLabelHarassmentOrAbuse;

  /// Product copy used by lib/public_profile/presentation/public_profile_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Fake or misleading profile'**
  String get publicProfilePublicProfileScreenLabelFakeOrMisleadingProfile;

  /// Product copy used by lib/public_profile/presentation/public_profile_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get publicProfilePublicProfileScreenLabelInappropriateContent;

  /// Product copy used by lib/public_profile/presentation/public_profile_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Other safety concern'**
  String get publicProfilePublicProfileScreenLabelOtherSafetyConcern;

  /// Product copy used by lib/reviews/shared/reviews_section.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Edit your review'**
  String get reviewsReviewsSectionLabelEditYourReview;

  /// Product copy used by lib/reviews/shared/reviews_section.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get reviewsReviewsSectionLabelWriteAReview;

  /// Product copy used by lib/reviews/shared/reviews_section.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Be the first to review this event.'**
  String get reviewsReviewsSectionMessageBeTheFirstToReviewThisEvent;

  /// Product copy used by lib/reviews/shared/reviews_section.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsReviewsSectionTextReviews;

  /// Product copy used by lib/reviews/shared/reviews_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get reviewsReviewsSectionTitleNoReviewsYet;

  /// Product copy used by lib/reviews/shared/reviews_section.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Reviews appear after members attend an event.'**
  String get reviewsReviewsSectionMessageReviewsAppearAfterMembers;

  /// Product copy used by lib/reviews/shared/reviews_section.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Reviews from attendees will appear here after an event.'**
  String get reviewsReviewsSectionMessageReviewsFromAttendeesWill;

  /// Product copy used by lib/reviews/shared/reviews_section.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get reviewsReviewsSectionTextYou;

  /// Product copy used by lib/reviews/shared/reviews_section.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Edit review'**
  String get reviewsReviewsSectionMessageEditReview;

  /// Product copy used by lib/reviews/shared/reviews_section.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Respond as host'**
  String get reviewsReviewsSectionMessageRespondAsHost;

  /// Product copy used by lib/reviews/shared/reviews_section.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Edit host response'**
  String get reviewsReviewsSectionMessageEditHostResponse;

  /// Product copy used by lib/reviews/shared/reviews_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Respond to review'**
  String get reviewsReviewsSectionTitleRespondToReview;

  /// Product copy used by lib/reviews/shared/reviews_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Edit response'**
  String get reviewsReviewsSectionTitleEditResponse;

  /// Product copy used by lib/reviews/shared/reviews_section.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Save response'**
  String get reviewsReviewsSectionLabelSaveResponse;

  /// Product copy used by lib/reviews/shared/reviews_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get reviewsReviewsSectionTitleResponse;

  /// Product copy used by lib/reviews/shared/reviews_section.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'Thank the attendee or clarify what happened'**
  String get reviewsReviewsSectionPlaceholderThankTheAttendeeOr;

  /// Product copy used by lib/reviews/shared/star_rating.dart (message).
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get reviewsStarRatingMessageS;

  /// Product copy used by lib/reviews/shared/star_rating.dart (label).
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get reviewsStarRatingLabelS;

  /// Product copy used by lib/reviews/shared/write_review_sheet.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Delete review?'**
  String get reviewsWriteReviewSheetTitleDeleteReview;

  /// Product copy used by lib/reviews/shared/write_review_sheet.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This removes your review from this event.'**
  String get reviewsWriteReviewSheetMessageThisRemovesYourReview;

  /// Product copy used by lib/reviews/shared/write_review_sheet.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Edit review'**
  String get reviewsWriteReviewSheetTitleEditReview;

  /// Product copy used by lib/reviews/shared/write_review_sheet.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get reviewsWriteReviewSheetTitleWriteAReview;

  /// Product copy used by lib/reviews/shared/write_review_sheet.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Delete review'**
  String get reviewsWriteReviewSheetLabelDeleteReview;

  /// Product copy used by lib/reviews/shared/write_review_sheet.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get reviewsWriteReviewSheetLabelSave;

  /// Product copy used by lib/reviews/shared/write_review_sheet.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get reviewsWriteReviewSheetLabelSubmit;

  /// Product copy used by lib/reviews/shared/write_review_sheet.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewsWriteReviewSheetTitleReview;

  /// Product copy used by lib/reviews/shared/write_review_sheet.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'Share your experience'**
  String get reviewsWriteReviewSheetPlaceholderShareYourExperience;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get safetySettingsScreenTitleDeleteAccount;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get safetySettingsScreenTitleAccount;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get safetySettingsScreenTitlePhoneNumber;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get safetySettingsScreenTitleEmail;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Review history'**
  String get safetySettingsScreenTitleReviewHistory;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Events you reviewed'**
  String get safetySettingsScreenBodyEventsYouReviewed;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get safetySettingsScreenTitlePaymentHistory;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Bookings and receipts'**
  String get safetySettingsScreenBodyBookingsAndReceipts;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Catch Host'**
  String get safetySettingsScreenTitleCatchHost;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Manage events and organizers'**
  String get safetySettingsScreenBodyManageEventsAndClubs;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get safetySettingsScreenTitleDevelopment;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event policy lab'**
  String get safetySettingsScreenTitleEventPolicyLab;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Static booking policy previews'**
  String get safetySettingsScreenBodyStaticBookingPolicyPreviews;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event success lab'**
  String get safetySettingsScreenTitleEventSuccessLab;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Host, attendee, and report previews'**
  String get safetySettingsScreenBodyHostAttendeeAndReport;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event success manual QA'**
  String get safetySettingsScreenTitleEventSuccessManualQa;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Host and attendee side by side'**
  String get safetySettingsScreenBodyHostAndAttendeeSide;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get safetySettingsScreenTitleNotifications;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get safetySettingsScreenTitlePushNotifications;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get safetySettingsScreenTitleMessages;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event reminders'**
  String get safetySettingsScreenTitleEventReminders;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event changes and cancellations'**
  String get safetySettingsScreenTitleEventChangesAndCancellations;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Organizer announcements'**
  String get safetySettingsScreenTitleClubAnnouncements;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Email updates'**
  String get safetySettingsScreenTitleEmailUpdates;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Privacy & safety'**
  String get safetySettingsScreenTitlePrivacySafety;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Blocked users'**
  String get safetySettingsScreenTitleBlockedUsers;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Who can see you'**
  String get safetySettingsScreenTitleWhoCanSeeYou;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Runners on my events'**
  String get safetySettingsScreenBodyRunnersOnMyEvents;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Show me on map'**
  String get safetySettingsScreenTitleShowMeOnMap;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get safetySettingsScreenTitlePrivacyPolicy;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get safetySettingsScreenTitleDeleteAccount658588;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get safetySettingsScreenTitleAbout;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get safetySettingsScreenTitleHelpSupport;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get safetySettingsScreenBodyContactUs;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get safetySettingsScreenTitleTerms;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get safetySettingsScreenBodyLegal;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get safetySettingsScreenTitleVersion;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get safetySettingsScreenTitleLogOut;

  /// Settings footer with the running app version.
  ///
  /// In en, this message translates to:
  /// **'Catch {version} · made in Bombay'**
  String safetySettingsScreenTextVersionMade({required String version});

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No blocked accounts'**
  String get safetySettingsScreenTitleNoBlockedAccounts;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'People you block will appear here.'**
  String get safetySettingsScreenMessagePeopleYouBlockWill;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get safetySettingsScreenLabelUnblock;

  /// Product copy used by lib/swipes/presentation/event_recap_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event recap'**
  String get swipesEventRecapScreenTitleEventRecap;

  /// Product copy used by lib/swipes/presentation/event_recap_screen.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Close recap'**
  String get swipesEventRecapScreenTooltipCloseRecap;

  /// Product copy used by lib/swipes/presentation/event_recap_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Who brought the vibe?'**
  String get swipesEventRecapScreenTextWhoBroughtTheVibe;

  /// Product copy used by lib/swipes/presentation/event_recap_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Tap people you remember. They\'\'ll be easier to spot when you open the catches deck.'**
  String get swipesEventRecapScreenTextTapPeopleYouRemember;

  /// Product copy used by lib/swipes/presentation/event_recap_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No attendees to tag'**
  String get swipesEventRecapScreenTitleNoAttendeesToTag;

  /// Product copy used by lib/swipes/presentation/event_recap_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'No other checked-in attendees are attached to this event yet.'**
  String get swipesEventRecapScreenMessageNoOtherCheckedIn;

  /// Product copy used by lib/swipes/presentation/event_recap_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Open catches deck'**
  String get swipesEventRecapScreenLabelOpenCatchesDeck;

  /// Product copy used by lib/swipes/presentation/event_recap_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get swipesEventRecapScreenLabelWhen;

  /// Product copy used by lib/swipes/presentation/event_recap_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get swipesEventRecapScreenLabelTime;

  /// Product copy used by lib/swipes/presentation/event_recap_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Catches'**
  String get swipesEventRecapScreenLabelCatches;

  /// Product copy used by lib/swipes/presentation/filters_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get swipesFiltersScreenTitleFilters;

  /// Product copy used by lib/swipes/presentation/filters_screen.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Close filters'**
  String get swipesFiltersScreenTooltipCloseFilters;

  /// Product copy used by lib/swipes/presentation/filters_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get swipesFiltersScreenLabelReset;

  /// Product copy used by lib/swipes/presentation/filters_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get swipesFiltersScreenTitleAge;

  /// Product copy used by lib/swipes/presentation/filters_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Interested in'**
  String get swipesFiltersScreenTitleInterestedIn;

  /// Product copy used by lib/swipes/presentation/filters_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get swipesFiltersScreenLabelApplyFilters;

  /// Product copy used by lib/swipes/presentation/swipe_hub_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Open catch windows'**
  String get swipesSwipeHubScreenTitleOpenCatchWindows;

  /// Product copy used by lib/swipes/presentation/swipe_hub_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'After the event'**
  String get swipesSwipeHubScreenTextAfterTheEvent;

  /// Product copy used by lib/swipes/presentation/swipe_hub_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Start catching'**
  String get swipesSwipeHubScreenLabelStartCatching;

  /// Product copy used by lib/swipes/presentation/swipe_hub_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'24H WINDOW OPEN'**
  String get swipesSwipeHubScreenText24hWindowOpen;

  /// Product copy used by lib/swipes/presentation/swipe_hub_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'You ran together. Now you can catch.'**
  String get swipesSwipeHubScreenTextYouRanTogetherNow;

  /// Product copy used by lib/swipes/presentation/swipe_hub_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Closes in'**
  String get swipesSwipeHubScreenLabelClosesIn;

  /// Product copy used by lib/swipes/presentation/swipe_hub_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Roster'**
  String get swipesSwipeHubScreenLabelRoster;

  /// Product copy used by lib/swipes/presentation/swipe_hub_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No active catches'**
  String get swipesSwipeHubScreenTitleNoActiveCatches;

  /// Product copy used by lib/swipes/presentation/swipe_hub_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Book a group event, show up, and your 24-hour catch window opens here after check-in.'**
  String get swipesSwipeHubScreenMessageBookAGroupEvent;

  /// Product copy used by lib/swipes/presentation/swipe_hub_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Find an event'**
  String get swipesSwipeHubScreenLabelFindAnEvent;

  /// Product copy used by lib/swipes/presentation/swipe_hub_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Dating stays locked until you actually run together. No cold stranger browsing.'**
  String get swipesSwipeHubScreenTextDatingStaysLockedUntil;

  /// Product copy used by lib/swipes/presentation/swipe_screen.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Back to Catches'**
  String get swipesSwipeScreenTooltipBackToCatches;

  /// Product copy used by lib/swipes/presentation/swipe_screen.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get swipesSwipeScreenTooltipFilters;

  /// Product copy used by lib/swipes/presentation/widgets/attended_event_tile.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'OPEN CATCH WINDOW'**
  String get swipesAttendedEventTileTextOpenCatchWindow;

  /// Product copy used by lib/swipes/presentation/widgets/attended_event_tile.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Recap'**
  String get swipesAttendedEventTileLabelRecap;

  /// Product copy used by lib/swipes/presentation/widgets/catches_pass_button.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Passing'**
  String get swipesCatchesPassButtonMessagePassing;

  /// Product copy used by lib/swipes/presentation/widgets/catches_pass_button.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get swipesCatchesPassButtonMessagePass;

  /// Product copy used by lib/swipes/presentation/widgets/catches_pass_button.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Passing profile'**
  String get swipesCatchesPassButtonLabelPassingProfile;

  /// Product copy used by lib/swipes/presentation/widgets/catches_pass_button.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Pass profile'**
  String get swipesCatchesPassButtonLabelPassProfile;

  /// Product copy used by lib/swipes/shared/profile_surface/catch_profile_view.dart (label).
  ///
  /// In en, this message translates to:
  /// **'PACE'**
  String get swipesCatchProfileViewLabelPace;

  /// Product copy used by lib/swipes/shared/profile_surface/catch_profile_view.dart (label).
  ///
  /// In en, this message translates to:
  /// **'DISTANCE'**
  String get swipesCatchProfileViewLabelDistance;

  /// Product copy used by lib/swipes/shared/profile_surface/profile_reaction_controls.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Send a comment with your like.'**
  String get swipesProfileReactionControlsSubtitleSendACommentWith;

  /// Product copy used by lib/swipes/shared/profile_surface/profile_reaction_controls.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get swipesProfileReactionControlsLabelCancel;

  /// Product copy used by lib/swipes/shared/profile_surface/profile_reaction_controls.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Send like'**
  String get swipesProfileReactionControlsLabelSendLike;

  /// Product copy used by lib/swipes/shared/profile_surface/profile_reaction_controls.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get swipesProfileReactionControlsTitleComment;

  /// Product copy used by lib/swipes/shared/profile_surface/profile_reaction_controls.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'Write something specific...'**
  String get swipesProfileReactionControlsPlaceholderWriteSomethingSpecific;

  /// Product copy used by lib/user_profile/presentation/profile_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Profile tabs'**
  String get userProfileProfileScreenLabelProfileTabs;

  /// Product copy used by lib/user_profile/presentation/profile_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Drag left or right to switch between Edit, Preview, and Insights.'**
  String get userProfileProfileScreenBodyDragLeftOrRight;

  /// Product copy used by lib/user_profile/presentation/profile_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Profile not available'**
  String get userProfileProfileScreenTitleProfileNotAvailable;

  /// Product copy used by lib/user_profile/presentation/profile_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Finish onboarding or sign in again to load your profile.'**
  String get userProfileProfileScreenMessageFinishOnboardingOrSign;

  /// Product copy used by lib/user_profile/presentation/widgets/inline_editor_height.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Decrease height'**
  String get userProfileInlineEditorHeightTooltipDecreaseHeight;

  /// Product copy used by lib/user_profile/presentation/widgets/inline_editor_height.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Increase height'**
  String get userProfileInlineEditorHeightTooltipIncreaseHeight;

  /// Product copy used by lib/user_profile/presentation/widgets/profile_sliver_header.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get userProfileProfileSliverHeaderTooltipSettings;

  /// Product copy used by lib/user_profile/presentation/widgets/profile_tab.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Prompts'**
  String get userProfileProfileTabTitlePrompts;

  /// Product copy used by lib/user_profile/presentation/widgets/profile_tab.dart (title).
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get userProfileProfileTabTitleAboutYou;

  /// Product copy used by lib/user_profile/presentation/widgets/profile_tab.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get userProfileProfileTabTitleRunning;

  /// Product copy used by lib/user_profile/presentation/widgets/profile_tab.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get userProfileProfileTabTitleLifestyle;

  /// Product copy used by lib/user_profile/presentation/widgets/profile_tab.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get userProfileProfileTabTitlePhotos;

  /// Product copy used by lib/user_profile/presentation/widgets/profile_tab_skeleton.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get userProfileProfileTabSkeletonTitlePhotos;

  /// Product copy used by lib/chats/presentation/inbox/chat_inbox_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Send broadcast'**
  String get chatsChatInboxScreenLabelSendBroadcast;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_skeleton.dart (title).
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get clubsClubDetailSkeletonTitleAbout;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_skeleton.dart (title).
  ///
  /// In en, this message translates to:
  /// **'What we do'**
  String get clubsClubDetailSkeletonTitleWhatWeDo;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_skeleton.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Your hosts'**
  String get clubsClubDetailSkeletonTitleYourHosts;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_skeleton.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get clubsClubDetailSkeletonTitleSchedule;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_hero_app_bar.dart (title).
  ///
  /// In en, this message translates to:
  /// **'club-detail-collapsed-title'**
  String get clubsClubHeroAppBarTitleClubDetailCollapsedTitle;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_hero_app_bar.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'club-detail-expanded-title'**
  String get clubsClubHeroAppBarTextClubDetailExpandedTitle;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_schedule_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get clubsClubScheduleSectionTitleSchedule;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_share_card.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'ORGANIZER ON CATCH'**
  String get clubsClubShareCardTextClubOnCatch;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_empty.dart (title).
  ///
  /// In en, this message translates to:
  /// **'How Catch works'**
  String get dashboardDashboardEmptyTitleHowCatchWorks;

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Review pending'**
  String get dashboardEventFocusRailLabelReviewPending;

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event policy lab'**
  String get eventPoliciesEventPolicyLabScreenTitleEventPolicyLab;

  /// Product copy used by lib/event_success/presentation/event_success_event_preview_body_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event success preview'**
  String
  get eventSuccessEventSuccessEventPreviewBodyScreenTitleEventSuccessPreview;

  /// Product copy used by lib/event_success/presentation/event_success_event_preview_loading_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event success preview'**
  String
  get eventSuccessEventSuccessEventPreviewLoadingScreenTitleEventSuccessPreview;

  /// Product copy used by lib/event_success/presentation/event_success_event_preview_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event not found'**
  String get eventSuccessEventSuccessEventPreviewScreenTitleEventNotFound;

  /// Product copy used by lib/event_success/presentation/event_success_event_preview_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This event is no longer available for preview.'**
  String get eventSuccessEventSuccessEventPreviewScreenMessageThisEventIsNo;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Host only'**
  String get eventSuccessEventSuccessFeatureBlocksLabelHostOnly;

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Attendee'**
  String get eventSuccessEventSuccessFeatureBlocksLabelAttendee;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event success lab'**
  String get eventSuccessEventSuccessLabScreenTitleEventSuccessLab;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Dev/staging route'**
  String get eventSuccessEventSuccessLabScreenLabelDevStagingRoute;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'No Firestore writes'**
  String get eventSuccessEventSuccessLabScreenLabelNoFirestoreWrites;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'No booking changes'**
  String get eventSuccessEventSuccessLabScreenLabelNoBookingChanges;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'some live phone use'**
  String get eventSuccessEventSuccessLabScreenLabelSomeLivePhoneUse;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'live phone'**
  String get eventSuccessEventSuccessLabScreenLabelLivePhone;

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'later experiment'**
  String get eventSuccessEventSuccessLabScreenLabelLaterExperiment;

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event success manual QA'**
  String get eventSuccessEventSuccessManualQaScreenTitleEventSuccessManualQa;

  /// Product copy used by lib/event_success/presentation/event_success_setup_body.dart (label).
  ///
  /// In en, this message translates to:
  /// **'No timer'**
  String get eventSuccessEventSuccessSetupBodyLabelNoTimer;

  /// Product copy used by lib/event_success/presentation/event_success_setup_body.dart (label).
  ///
  /// In en, this message translates to:
  /// **'10 min'**
  String get eventSuccessEventSuccessSetupBodyLabel10Min;

  /// Product copy used by lib/event_success/presentation/event_success_setup_body.dart (label).
  ///
  /// In en, this message translates to:
  /// **'15 min'**
  String get eventSuccessEventSuccessSetupBodyLabel15Min;

  /// Product copy used by lib/event_success/presentation/event_success_setup_body.dart (label).
  ///
  /// In en, this message translates to:
  /// **'20 min'**
  String get eventSuccessEventSuccessSetupBodyLabel20Min;

  /// Product copy used by lib/event_success/presentation/event_success_setup_body.dart (label).
  ///
  /// In en, this message translates to:
  /// **'30 min'**
  String get eventSuccessEventSuccessSetupBodyLabel30Min;

  /// Product copy used by lib/event_success/presentation/event_success_setup_body.dart (label).
  ///
  /// In en, this message translates to:
  /// **'5s'**
  String get eventSuccessEventSuccessSetupBodyLabel5s;

  /// Product copy used by lib/event_success/presentation/event_success_setup_body.dart (label).
  ///
  /// In en, this message translates to:
  /// **'10s'**
  String get eventSuccessEventSuccessSetupBodyLabel10s;

  /// Product copy used by lib/event_success/presentation/event_success_setup_body.dart (label).
  ///
  /// In en, this message translates to:
  /// **'15s'**
  String get eventSuccessEventSuccessSetupBodyLabel15s;

  /// Product copy used by lib/events/presentation/event_detail_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event not found'**
  String get eventsEventDetailScreenTitleEventNotFound;

  /// Product copy used by lib/events/presentation/event_detail_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This event is no longer available.'**
  String get eventsEventDetailScreenMessageThisEventIsNo;

  /// Product copy used by lib/events/presentation/event_location_map_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event not found'**
  String get eventsEventLocationMapScreenTitleEventNotFound;

  /// Product copy used by lib/events/presentation/event_location_map_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This event is no longer available.'**
  String get eventsEventLocationMapScreenMessageThisEventIsNo;

  /// Product copy used by lib/events/presentation/saved_events_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Saved events'**
  String get eventsSavedEventsScreenTitleSavedEvents;

  /// Product copy used by lib/events/presentation/widgets/event_detail_hero_app_bar.dart (title).
  ///
  /// In en, this message translates to:
  /// **'event-detail-collapsed-title'**
  String get eventsEventDetailHeroAppBarTitleEventDetailCollapsedTitle;

  /// Product copy used by lib/explore/presentation/explore_map_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'no-selected-map-event'**
  String get exploreExploreMapScreenBodyNoSelectedMapEvent;

  /// Product copy used by lib/explore/presentation/explore_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'explore-list-scroll-view'**
  String get exploreExploreScreenBodyExploreListScrollView;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Admission format'**
  String get hostsClubHostDefaultsStepLabelAdmissionFormat;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Cancellation policy'**
  String get hostsClubHostDefaultsStepLabelCancellationPolicy;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/create_club_contact_fields.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get hostsCreateClubContactFieldsLabelContact;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Organizer photos'**
  String get hostsCreateClubPhotosPickerLabelClubPhotos;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Organizer profile image'**
  String get hostsCreateClubPhotosPickerLabelClubProfileImage;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get hostsEditHostedEventScreenTitleEditEvent;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get hostsEditHostedEventScreenLabelSchedule;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get hostsEditHostedEventScreenLabelDuration;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get hostsEditHostedEventScreenLabelWhere;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Event details'**
  String get hostsEditHostedEventScreenLabelEventDetails;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Event policy'**
  String get hostsEditHostedEventScreenLabelEventPolicy;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get hostsEditHostedEventScreenLabelLocked;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Admission format'**
  String get hostsEditHostedEventScreenLabelAdmissionFormat;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Cancellation policy'**
  String get hostsEditHostedEventScreenLabelCancellationPolicy;

  /// Product copy used by lib/hosts/presentation/event_management/host_create_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event setup unavailable'**
  String get hostsHostCreateEventScreenTitleEventSetupUnavailable;

  /// Product copy used by lib/hosts/presentation/event_management/host_create_event_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'That organizer does not match this event route.'**
  String get hostsHostCreateEventScreenMessageThatOrganizerDoesNot;

  /// Product copy used by lib/hosts/presentation/event_management/host_create_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Repeat unavailable'**
  String get hostsHostCreateEventScreenTitleRepeatUnavailable;

  /// Product copy used by lib/hosts/presentation/event_management/host_create_event_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'That event belongs to a different organizer.'**
  String get hostsHostCreateEventScreenMessageThatEventBelongsTo;

  /// Product copy used by lib/hosts/presentation/event_management/host_create_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Organizer not found'**
  String get hostsHostCreateEventScreenTitleClubNotFound;

  /// Product copy used by lib/hosts/presentation/event_management/host_create_event_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This organizer is no longer available.'**
  String get hostsHostCreateEventScreenMessageThisClubIsNo;

  /// Product copy used by lib/hosts/presentation/event_management/host_create_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Host access required'**
  String get hostsHostCreateEventScreenTitleHostAccessRequired;

  /// Product copy used by lib/hosts/presentation/event_management/host_create_event_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Only this organizer\'\'s host team can create events for this organizer.'**
  String get hostsHostCreateEventScreenMessageOnlyThisClubS;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/create_event_photo_picker.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Event photos'**
  String get hostsCreateEventPhotoPickerLabelEventPhotos;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_details_step.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Activity type'**
  String get hostsEventDetailsStepLabelActivityType;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_details_step.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Format structure'**
  String get hostsEventDetailsStepLabelFormatStructure;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_details_step.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Pace level'**
  String get hostsEventDetailsStepLabelPaceLevel;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Admission format'**
  String get hostsEventPolicyStepLabelAdmissionFormat;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Cancellation policy'**
  String get hostsEventPolicyStepLabelCancellationPolicy;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/when_step.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get hostsWhenStepLabelDate;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/when_step.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get hostsWhenStepLabelStartTime;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/when_step.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get hostsWhenStepLabelDuration;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/where_step.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Meeting location'**
  String get hostsWhereStepLabelMeetingLocation;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'host_event_manage_scroll_view'**
  String get hostsHostEventManageScreenBodyHostEventManageScroll;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Keep event'**
  String get hostsHostEventManageScreenLabelKeepEvent;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Keep active'**
  String get hostsHostEventManageScreenLabelKeepActive;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get hostsHostEventManageScreenLabelDisable;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get hostsHostEventManageScreenLabelInvite;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get hostsHostEventManageScreenLabelDisabled;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Event cancelled'**
  String get hostsHostEventManageScreenLabelEventCancelled;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (detail).
  ///
  /// In en, this message translates to:
  /// **'Records are retained'**
  String get hostsHostEventManageScreenDetailRecordsAreRetained;

  /// Product copy used by lib/hosts/presentation/inbox/host_inbox_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No general inquiries'**
  String get hostsHostInboxScreenTitleNoGeneralInquiries;

  /// Product copy used by lib/hosts/presentation/inbox/host_inbox_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Questions that are not tied to one event will appear here.'**
  String get hostsHostInboxScreenMessageQuestionsThatAreNot;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Payouts'**
  String get hostsHostPaymentAccountCardTitlePayouts;

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Host tools'**
  String get hostsHostClubToolsLabelHostTools;

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get hostsHostClubToolsLabelClub;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_tools.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Host event'**
  String get hostsHostEventToolsLabelHostEvent;

  /// Product copy used by lib/chats/presentation/inbox/widgets/chats_list_body.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No {audienceLabel}s yet'**
  String chatsChatsListBodyTitleNoAudiencelabelSYet({
    required Object audienceLabel,
  });

  /// Product copy used by lib/chats/presentation/inbox/widgets/chats_list_body.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Message {countLabel}'**
  String chatsChatsListBodyTitleMessageCountlabel({required Object countLabel});

  /// Product copy used by lib/chats/presentation/widgets/chat_event_context_header.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{title} · {date}'**
  String chatsChatEventContextHeaderTextTitleDate({
    required Object title,
    required Object date,
  });

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_dock.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{members}'**
  String clubsClubDetailDockTextMembers({required Object members});

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_hero_app_bar.dart (semanticLabel).
  ///
  /// In en, this message translates to:
  /// **'{name} cover photo'**
  String clubsClubHeroAppBarSemanticlabelNameCoverPhoto({required Object name});

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_host_section.dart (label).
  ///
  /// In en, this message translates to:
  /// **'View {displayName} profile'**
  String clubsClubHostSectionLabelViewDisplaynameProfile({
    required Object displayName,
  });

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_photo_strip.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{length} PHOTOS'**
  String clubsClubPhotoStripTextLengthPhotos({required Object length});

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_share_card.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{area}, {cityLabel}'**
  String clubsClubShareCardLabelAreaCitylabel({
    required Object area,
    required Object cityLabel,
  });

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_share_card.dart (semanticLabel).
  ///
  /// In en, this message translates to:
  /// **'{name} cover photo'**
  String clubsClubShareCardSemanticlabelNameCoverPhoto({required Object name});

  /// Product copy used by lib/dashboard/presentation/widgets/activity_section.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{title}. {body}'**
  String dashboardActivitySectionLabelTitleBody({
    required Object title,
    required Object body,
  });

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (semanticLabel).
  ///
  /// In en, this message translates to:
  /// **'Event {value1} of {length}'**
  String dashboardEventFocusRailSemanticlabelEventValue1OfLength({
    required Object value1,
    required Object length,
  });

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Catch · {swipeCountdown}'**
  String dashboardEventFocusRailLabelCatchSwipecountdown({
    required Object swipeCountdown,
  });

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{signedUpCount}/{capacityLimit}'**
  String dashboardEventFocusRailLabelSignedupcountCapacitylimit({
    required Object signedUpCount,
    required Object capacityLimit,
  });

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{length} fixtures'**
  String eventPoliciesEventPolicyLabScreenTextLengthFixtures({
    required Object length,
  });

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{length} probes'**
  String eventPoliciesEventPolicyLabScreenTextLengthProbes({
    required Object length,
  });

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Base {formatPaise} · cohort {formatSignedPaise} · demand {formatSignedPaise2}'**
  String
  eventPoliciesEventPolicyLabScreenTextBaseFormatpaiseCohortFormatsignedpaise({
    required Object formatPaise,
    required Object formatSignedPaise,
    required Object formatSignedPaise2,
  });

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{formatCancellationActor} · {beforeStartHours}h before start'**
  String
  eventPoliciesEventPolicyLabScreenTextFormatcancellationactorBeforestarthoursHBefore({
    required Object formatCancellationActor,
    required Object beforeStartHours,
  });

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Refund {formatPaise}'**
  String eventPoliciesEventPolicyLabScreenLabelRefundFormatpaise({
    required Object formatPaise,
  });

  /// Product copy used by lib/event_policies/presentation/event_policy_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Credit {formatPaise}'**
  String eventPoliciesEventPolicyLabScreenLabelCreditFormatpaise({
    required Object formatPaise,
  });

  /// Product copy used by lib/event_success/presentation/event_success_event_preview_body_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{clubName} · {title}'**
  String eventSuccessEventSuccessEventPreviewBodyScreenTextClubnameTitle({
    required Object clubName,
    required Object title,
  });

  /// Product copy used by lib/event_success/presentation/event_success_event_preview_body_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{capacityLimit} target'**
  String
  eventSuccessEventSuccessEventPreviewBodyScreenLabelCapacitylimitTarget({
    required Object capacityLimit,
  });

  /// Product copy used by lib/event_success/presentation/event_success_event_preview_body_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{bookedCount} booked'**
  String eventSuccessEventSuccessEventPreviewBodyScreenLabelBookedcountBooked({
    required Object bookedCount,
  });

  /// Product copy used by lib/event_success/presentation/event_success_event_preview_body_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{checkedInCount} checked in'**
  String
  eventSuccessEventSuccessEventPreviewBodyScreenLabelCheckedincountCheckedIn({
    required Object checkedInCount,
  });

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (detail).
  ///
  /// In en, this message translates to:
  /// **'{checkedInCount}/{bookedCount}'**
  String eventSuccessEventSuccessFeatureBlocksDetailCheckedincountBookedcount({
    required Object checkedInCount,
    required Object bookedCount,
  });

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (detail).
  ///
  /// In en, this message translates to:
  /// **'{value1}/{length}'**
  String eventSuccessEventSuccessFeatureBlocksDetailValue1Length({
    required Object value1,
    required Object length,
  });

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Attendee experience: {attendeeExperience}'**
  String
  eventSuccessEventSuccessFeatureBlocksTextAttendeeExperienceAttendeeexperience({
    required Object attendeeExperience,
  });

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{round}%'**
  String eventSuccessEventSuccessFeatureBlocksLabelRound({
    required Object round,
  });

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{targetAttendeeCount} target attendees'**
  String
  eventSuccessEventSuccessFeatureBlocksLabelTargetattendeecountTargetAttendees({
    required Object targetAttendeeCount,
  });

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{length} live phone tools'**
  String eventSuccessEventSuccessFeatureBlocksLabelLengthLivePhoneTools({
    required Object length,
  });

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{title} tool'**
  String eventSuccessEventSuccessFeatureBlocksLabelTitleTool({
    required Object title,
  });

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{durationMinutes} min · {label}'**
  String eventSuccessEventSuccessFeatureBlocksTextDurationminutesMinLabel({
    required Object durationMinutes,
    required Object label,
  });

  /// Product copy used by lib/event_success/presentation/event_success_feature_blocks.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{label} {round}%'**
  String eventSuccessEventSuccessFeatureBlocksTextLabelRound({
    required Object label,
    required Object round,
  });

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{playbookCount} playbooks'**
  String eventSuccessEventSuccessLabScreenLabelPlaybookcountPlaybooks({
    required Object playbookCount,
  });

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'+{value1} more'**
  String eventSuccessEventSuccessLabScreenLabelValue1More({
    required Object value1,
  });

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{min}-{max} attendees'**
  String eventSuccessEventSuccessLabScreenTextMinMaxAttendees({
    required Object min,
    required Object max,
  });

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{durationMinutes}'**
  String eventSuccessEventSuccessLabScreenTextDurationminutes({
    required Object durationMinutes,
  });

  /// Product copy used by lib/event_success/presentation/event_success_lab_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{round}%'**
  String eventSuccessEventSuccessLabScreenLabelRound({required Object round});

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Manual QA fixture failed to load: {error}'**
  String eventSuccessEventSuccessManualQaScreenTextManualQaFixtureFailed({
    required Object error,
  });

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{title} · {label} · {label2}'**
  String eventSuccessEventSuccessManualQaScreenTextTitleLabelLabel2({
    required Object title,
    required Object label,
    required Object label2,
  });

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{bookedCount} booked'**
  String eventSuccessEventSuccessManualQaScreenLabelBookedcountBooked({
    required Object bookedCount,
  });

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{checkedInCount} checked in'**
  String eventSuccessEventSuccessManualQaScreenLabelCheckedincountCheckedIn({
    required Object checkedInCount,
  });

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{revealCountdownSeconds}s reveal'**
  String
  eventSuccessEventSuccessManualQaScreenLabelRevealcountdownsecondsSReveal({
    required Object revealCountdownSeconds,
  });

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{title} · ranking'**
  String eventSuccessEventSuccessManualQaScreenLabelTitleRanking({
    required Object title,
  });

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{title} · clues'**
  String eventSuccessEventSuccessManualQaScreenLabelTitleClues({
    required Object title,
  });

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Production host workspace · {activeStepLabel}'**
  String
  eventSuccessEventSuccessManualQaScreenSubtitleProductionHostWorkspaceActivesteplabel({
    required Object activeStepLabel,
  });

  /// Product copy used by lib/event_success/presentation/event_success_manual_qa_screen.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'{publicDisplayName} · {name} · {activeStepLabel}'**
  String
  eventSuccessEventSuccessManualQaScreenSubtitlePublicdisplaynameNameActivesteplabel({
    required Object publicDisplayName,
    required Object name,
    required Object activeStepLabel,
  });

  /// Product copy used by lib/event_success/presentation/event_success_questionnaire_config_editor.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{length} questions'**
  String eventSuccessEventSuccessQuestionnaireConfigEditorLabelLengthQuestions({
    required Object length,
  });

  /// Product copy used by lib/event_success/presentation/event_success_questionnaire_config_editor.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Question {value1}'**
  String eventSuccessEventSuccessQuestionnaireConfigEditorTextQuestionValue1({
    required Object value1,
  });

  /// Product copy used by lib/event_success/presentation/event_success_questionnaire_config_editor.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Option {value1}'**
  String eventSuccessEventSuccessQuestionnaireConfigEditorTitleOptionValue1({
    required Object value1,
  });

  /// Product copy used by lib/event_success/presentation/event_success_setup_body.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Attendees will see: \"{text}\"'**
  String eventSuccessEventSuccessSetupBodyTextAttendeesWillSeeText({
    required Object text,
  });

  /// Product copy used by lib/event_success/presentation/event_success_structure_config_editor.dart (detail).
  ///
  /// In en, this message translates to:
  /// **'Target size for each {singularLabel}.'**
  String eventSuccessEventSuccessStructureConfigEditorDetailTargetSizeForEach({
    required Object singularLabel,
  });

  /// Product copy used by lib/event_success/presentation/event_success_structure_config_editor.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Auto: about {estimatedUnitCount} {toLowerCase} from {targetAttendeeCount} target attendees.'**
  String
  eventSuccessEventSuccessStructureConfigEditorTextAutoAboutEstimatedunitcountTolowercase({
    required Object estimatedUnitCount,
    required Object toLowerCase,
    required Object targetAttendeeCount,
  });

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{length} UPLOADED'**
  String eventsEventDetailDesignPrimitivesTextLengthUploaded({
    required Object length,
  });

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'{title} cancellation'**
  String eventsEventDetailOverviewSectionTitleTitleCancellation({
    required Object title,
  });

  /// Product copy used by lib/events/presentation/widgets/event_pins_map.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{locationName} location'**
  String eventsEventPinsMapLabelLocationnameLocation({
    required Object locationName,
  });

  /// Product copy used by lib/events/presentation/widgets/event_pins_map.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Select {locationName}'**
  String eventsEventPinsMapLabelSelectLocationname({
    required Object locationName,
  });

  /// Product copy used by lib/events/presentation/widgets/who_is_going.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{total}/{capacityLimit}'**
  String eventsWhoIsGoingTextTotalCapacitylimit({
    required Object total,
    required Object capacityLimit,
  });

  /// Product copy used by lib/explore/presentation/explore_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No organizers in {cityLabel} yet'**
  String exploreExploreScreenTitleNoClubsInCitylabel({
    required Object cityLabel,
  });

  /// Product copy used by lib/explore/presentation/widgets/catch_cover_story.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Change location, {location}'**
  String exploreCatchCoverStoryLabelChangeLocationLocation({
    required Object location,
  });

  /// Product copy used by lib/explore/presentation/widgets/explore_city_picker.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Select {label}'**
  String exploreExploreCityPickerLabelSelectLabel({required Object label});

  /// Product copy used by lib/explore/presentation/widgets/explore_event_type_browse_grid.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{label}, {countLabel}'**
  String exploreExploreEventTypeBrowseGridLabelLabelCountlabel({
    required Object label,
    required Object countLabel,
  });

  /// Product copy used by lib/explore/presentation/widgets/explore_event_type_browse_grid.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String exploreExploreEventTypeBrowseGridTextCount({required Object count});

  /// Product copy used by lib/explore/presentation/widgets/explore_event_type_browse_grid.dart (label).
  ///
  /// In en, this message translates to:
  /// **'+ {remainingCount} MORE TYPES'**
  String exploreExploreEventTypeBrowseGridLabelRemainingcountMoreTypes({
    required Object remainingCount,
  });

  /// Product copy used by lib/explore/presentation/widgets/explore_event_type_browse_grid.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Show {remainingCount} more activity types'**
  String exploreExploreEventTypeBrowseGridLabelShowRemainingcountMoreActivity({
    required Object remainingCount,
  });

  /// Product copy used by lib/explore/presentation/widgets/explore_list.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No organizers in {cityLabel} yet'**
  String exploreExploreListTitleNoClubsInCitylabel({required Object cityLabel});

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Base price ({currencyCode})'**
  String hostsEditHostedEventScreenTitleBasePriceCurrencycode({
    required Object currencyCode,
  });

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Step ({currencyCode})'**
  String hostsEditHostedEventScreenTitleStepCurrencycode({
    required Object currencyCode,
  });

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Max ({currencyCode})'**
  String hostsEditHostedEventScreenTitleMaxCurrencycode({
    required Object currencyCode,
  });

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_success_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'{displayName} is now listed on {name}. People can discover it from their home feed.'**
  String hostsCreateEventSuccessScreenMessageDisplaynameIsNowListed({
    required Object displayName,
    required Object name,
  });

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_success_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'{displayName} is now listed on {name}. People can discover it, but only attendees with the invite code or private link can book.'**
  String hostsCreateEventSuccessScreenMessageDisplaynameIsNowListed244c65({
    required Object displayName,
    required Object name,
  });

  /// Product copy used by lib/hosts/presentation/event_management/widgets/draft_picker_sheet.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'SAVED {toUpperCase}'**
  String hostsDraftPickerSheetTextSavedTouppercase({
    required Object toUpperCase,
  });

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Base price ({currencyCode})'**
  String hostsEventPolicyStepTitleBasePriceCurrencycode({
    required Object currencyCode,
  });

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Step ({currencyCode})'**
  String hostsEventPolicyStepTitleStepCurrencycode({
    required Object currencyCode,
  });

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Max ({currencyCode})'**
  String hostsEventPolicyStepTitleMaxCurrencycode({
    required Object currencyCode,
  });

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This stops new attribution for {label}, but keeps its history in reporting.'**
  String hostsHostEventManageScreenMessageThisStopsNewAttribution({
    required Object label,
  });

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{shortDateLabel} · {time}'**
  String hostsHostEventManageScreenLabelShortdatelabelTime({
    required Object shortDateLabel,
    required Object time,
  });

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (detail).
  ///
  /// In en, this message translates to:
  /// **'{open} open'**
  String hostsHostEventManageScreenDetailOpenOpen({required Object open});

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (detail).
  ///
  /// In en, this message translates to:
  /// **'{waitlisted} to review'**
  String hostsHostEventManageScreenDetailWaitlistedToReview({
    required Object waitlisted,
  });

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Booked · {bookedCount}'**
  String hostsHostBroadcastComposerSheetLabelBookedBookedcount({
    required Object bookedCount,
  });

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Waitlist · {prospectiveCount}'**
  String hostsHostBroadcastComposerSheetLabelWaitlistProspectivecount({
    required Object prospectiveCount,
  });

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Everyone · {recipientCount}'**
  String hostsHostBroadcastComposerSheetLabelEveryoneRecipientcount({
    required Object recipientCount,
  });

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Send to {recipientCount} people'**
  String hostsHostBroadcastComposerSheetLabelSendToRecipientcountPeople({
    required Object recipientCount,
  });

  /// Product copy used by lib/hosts/presentation/inbox/host_inbox_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'BOOKED · {bookedThreadCount}'**
  String hostsHostInboxScreenLabelBookedBookedthreadcount({
    required Object bookedThreadCount,
  });

  /// Product copy used by lib/hosts/presentation/inbox/host_inbox_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'PROSPECTIVE · {prospectiveThreadCount}'**
  String hostsHostInboxScreenLabelProspectiveProspectivethreadcount({
    required Object prospectiveThreadCount,
  });

  /// Product copy used by lib/hosts/presentation/inbox/host_inbox_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No {value1} have written yet'**
  String hostsHostInboxScreenTitleNoValue1HaveWritten({required Object value1});

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'{remainingQuota} of {weeklyQuota} posts left this week.'**
  String hostsHostClubToolsSubtitleRemainingquotaOfWeeklyquotaPosts({
    required Object remainingQuota,
    required Object weeklyQuota,
  });

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (helperText).
  ///
  /// In en, this message translates to:
  /// **'{value1} characters left'**
  String hostsHostClubToolsHelpertextValue1CharactersLeft({
    required Object value1,
  });

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Offer next {count}'**
  String hostsHostEventAttendancePanelLabelOfferNextCount({
    required Object count,
  });

  /// Product copy used by lib/hosts/presentation/widgets/host_event_tools.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Host event {value1} of {itemCount}'**
  String hostsHostEventToolsLabelHostEventValue1Of({
    required Object value1,
    required Object itemCount,
  });

  /// Product copy used by lib/hosts/presentation/widgets/host_event_tools.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{value1} of {itemCount}'**
  String hostsHostEventToolsTextValue1OfItemcount({
    required Object value1,
    required Object itemCount,
  });

  /// Product copy used by lib/hosts/presentation/widgets/host_event_tools.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{shortDateLabel} · {timeRangeLabel}'**
  String hostsHostEventToolsLabelShortdatelabelTimerangelabel({
    required Object shortDateLabel,
    required Object timeRangeLabel,
  });

  /// Product copy used by lib/core/widgets/block_user_dialog.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Block {name}?'**
  String coreBlockUserDialogTitleBlockName({required Object name});

  /// Product copy used by lib/core/widgets/catch_field.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Clear {value1}'**
  String coreCatchFieldTooltipClearValue1({required Object value1});

  /// Product copy used by lib/core/widgets/catch_form_field_label.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{label}, optional'**
  String coreCatchFormFieldLabelLabelLabelOptional({required Object label});

  /// Product copy used by lib/core/widgets/catch_notice.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get coreCatchNoticeTooltipDismiss;

  /// Product copy used by lib/core/widgets/catch_person_avatar.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'+{count}'**
  String coreCatchPersonAvatarTextCount({required Object count});

  /// Product copy used by lib/core/widgets/catch_person_row.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{label} unread chats'**
  String coreCatchPersonRowLabelLabelUnreadChats({required Object label});

  /// Product copy used by lib/core/widgets/catch_search_field.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Clear {placeholder}'**
  String coreCatchSearchFieldTooltipClearPlaceholder({
    required Object placeholder,
  });

  /// Product copy used by lib/core/widgets/catch_section_layout.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{displayTitle} · {count}'**
  String coreCatchSectionLayoutTextDisplaytitleCount({
    required Object displayTitle,
    required Object count,
  });

  /// Product copy used by lib/core/widgets/catch_startup_loading_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'startup-loading-indicator'**
  String get coreCatchStartupLoadingScreenBodyStartupLoadingIndicator;

  /// Product copy used by lib/core/widgets/catch_startup_loading_screen.dart (body).
  ///
  /// In en, this message translates to:
  /// **'startup-loading-delay'**
  String get coreCatchStartupLoadingScreenBodyStartupLoadingDelay;

  /// Product copy used by lib/core/widgets/catch_step_flow_header.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'STEP {clampedStep} OF {total}'**
  String coreCatchStepFlowHeaderTextStepClampedstepOfTotal({
    required Object clampedStep,
    required Object total,
  });

  /// Product copy used by lib/core/widgets/catch_step_progress.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{value1}/{totalSteps}'**
  String coreCatchStepProgressTextValue1Totalsteps({
    required Object value1,
    required Object totalSteps,
  });

  /// Product copy used by lib/core/widgets/catch_top_bar.dart (label).
  ///
  /// In en, this message translates to:
  /// **'View {name} profile'**
  String coreCatchTopBarLabelViewNameProfile({required Object name});

  /// Product copy used by lib/core/widgets/ordered_photo_picker.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Photo {value1}'**
  String coreOrderedPhotoPickerLabelPhotoValue1({required Object value1});

  /// Product copy used by lib/core/widgets/ordered_photo_picker.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Photo {value1}'**
  String coreOrderedPhotoPickerMessagePhotoValue1({required Object value1});

  /// Product copy used by lib/core/widgets/ordered_photo_picker.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Remove photo {value1}'**
  String coreOrderedPhotoPickerMessageRemovePhotoValue1({
    required Object value1,
  });

  /// Product copy used by lib/events/shared/event_joined_celebration_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Your spot is confirmed for {title}{value2}.'**
  String eventsEventJoinedCelebrationScreenMessageYourSpotIsConfirmed({
    required Object title,
    required Object value2,
  });

  /// Product copy used by lib/events/shared/event_tiles/event_date_marker.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{day} {day2}'**
  String eventsEventDateMarkerLabelDayDay2({
    required Object day,
    required Object day2,
  });

  /// Product copy used by lib/events/shared/event_tiles/event_date_marker.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{day}'**
  String eventsEventDateMarkerTextDay({required Object day});

  /// Product copy used by lib/events/shared/event_tiles/event_date_marker.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{day}'**
  String eventsEventDateMarkerLabelDay({required Object day});

  /// Product copy used by lib/events/shared/event_tiles/event_date_rail_card.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{day}'**
  String eventsEventDateRailCardTextDay({required Object day});

  /// Accessible hint for tappable condensed event tickets.
  ///
  /// In en, this message translates to:
  /// **'Opens event details'**
  String get eventsEventDateRailCardSemanticsOpensEventDetails;

  /// Product copy used by lib/image_uploads/shared/photo_slot.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Photo {value1} uploading'**
  String imageUploadsPhotoSlotLabelPhotoValue1Uploading({
    required Object value1,
  });

  /// Product copy used by lib/image_uploads/shared/photo_slot.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Edit photo {value1}'**
  String imageUploadsPhotoSlotLabelEditPhotoValue1({required Object value1});

  /// Product copy used by lib/image_uploads/shared/photo_slot.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Add photo {value1}'**
  String imageUploadsPhotoSlotLabelAddPhotoValue1({required Object value1});

  /// Product copy used by lib/image_uploads/shared/photo_slot.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Photo slot {value1} unavailable'**
  String imageUploadsPhotoSlotLabelPhotoSlotValue1Unavailable({
    required Object value1,
  });

  /// Product copy used by lib/image_uploads/shared/photo_slot.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Delete photo {value1}'**
  String imageUploadsPhotoSlotMessageDeletePhotoValue1({
    required Object value1,
  });

  /// Product copy used by lib/image_uploads/shared/photo_slot.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'PHOTO {padLeft}'**
  String imageUploadsPhotoSlotTextPhotoPadleft({required Object padLeft});

  /// Product copy used by lib/image_uploads/shared/profile_photo_editor_screen.dart (CatchButton).
  ///
  /// In en, this message translates to:
  /// **'Delete photo {value1}'**
  String imageUploadsProfilePhotoEditorScreenCatchbuttonDeletePhotoValue1({
    required Object value1,
  });

  /// Product copy used by lib/image_uploads/shared/profile_photo_editor_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Keep at least {minimumProfilePhotoCount} photos on your profile.'**
  String
  imageUploadsProfilePhotoEditorScreenTextKeepAtLeastMinimumprofilephotocount({
    required Object minimumProfilePhotoCount,
  });

  /// Product copy used by lib/launch_access/presentation/launch_access_application_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Apply for access'**
  String get launchAccessLaunchAccessApplicationScreenTitleApplyForAccess;

  /// Product copy used by lib/matches/shared/match_celebration_dialog.dart (message).
  ///
  /// In en, this message translates to:
  /// **'You and {name} both liked each other.'**
  String matchesMatchCelebrationDialogMessageYouAndNameBoth({
    required Object name,
  });

  /// Product copy used by lib/onboarding/presentation/pages/profile_prompts_page.dart (helperText).
  ///
  /// In en, this message translates to:
  /// **'{length} / {maximumProfilePromptAnswerLength}'**
  String
  onboardingProfilePromptsPageHelpertextLengthMaximumprofilepromptanswerlength({
    required Object length,
    required Object maximumProfilePromptAnswerLength,
  });

  /// Product copy used by lib/onboarding/presentation/pages/welcome_page.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Skip welcome animation'**
  String get onboardingWelcomePageLabelSkipWelcomeAnimation;

  /// Product copy used by lib/onboarding/presentation/pages/welcome_page.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Catch'**
  String get onboardingWelcomePageTextCatch;

  /// Product copy used by lib/onboarding/presentation/pages/welcome_page.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Continue with phone'**
  String get onboardingWelcomePageLabelContinueWithPhone;

  /// Product copy used by lib/onboarding/presentation/pages/welcome_page.dart (label).
  ///
  /// In en, this message translates to:
  /// **'See what\'\'s on'**
  String get onboardingWelcomePageLabelSeeWhatSOn;

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event not found'**
  String get paymentsPaymentConfirmationScreenTitleEventNotFound;

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This event is no longer available.'**
  String get paymentsPaymentConfirmationScreenMessageThisEventIsNo;

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Try {providerLabel} again'**
  String paymentsPaymentConfirmationScreenLabelTryProviderlabelAgain({
    required Object providerLabel,
  });

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Open {providerLabel} checkout'**
  String paymentsPaymentConfirmationScreenLabelOpenProviderlabelCheckout({
    required Object providerLabel,
  });

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get paymentsPaymentHistoryScreenTitlePaymentHistory;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Payment for {eventTitle}'**
  String paymentsPaymentHistoryScreenLabelPaymentForEventtitle({
    required Object eventTitle,
  });

  /// Product copy used by lib/public_profile/presentation/public_profile_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Report {profileName}'**
  String publicProfilePublicProfileScreenTitleReportProfilename({
    required Object profileName,
  });

  /// Product copy used by lib/reviews/presentation/reviews_history_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Sign in to see reviews'**
  String get reviewsReviewsHistoryScreenTitleSignInToSee;

  /// Product copy used by lib/reviews/presentation/reviews_history_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Your past event reviews will appear here.'**
  String get reviewsReviewsHistoryScreenMessageYourPastEventReviews;

  /// Product copy used by lib/reviews/presentation/reviews_history_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Review history'**
  String get reviewsReviewsHistoryScreenTitleReviewHistory;

  /// Product copy used by lib/reviews/shared/reviews_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'All reviews ({length})'**
  String reviewsReviewsSectionTitleAllReviewsLength({required Object length});

  /// Product copy used by lib/reviews/shared/reviews_section.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{toStringAsFixed} · {length}'**
  String reviewsReviewsSectionTextTostringasfixedLength({
    required Object toStringAsFixed,
    required Object length,
  });

  /// Product copy used by lib/reviews/shared/reviews_section.dart (label).
  ///
  /// In en, this message translates to:
  /// **'See all {length} reviews'**
  String reviewsReviewsSectionLabelSeeAllLengthReviews({
    required Object length,
  });

  /// Product copy used by lib/reviews/shared/reviews_section.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Host response · {hostName}'**
  String reviewsReviewsSectionTextHostResponseHostname({
    required Object hostName,
  });

  /// Product copy used by lib/reviews/shared/star_rating.dart (message).
  ///
  /// In en, this message translates to:
  /// **'{value} star{value2}'**
  String reviewsStarRatingMessageValueStarValue2({
    required Object value,
    required Object value2,
  });

  /// Product copy used by lib/reviews/shared/star_rating.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Rate {value} star{value2}'**
  String reviewsStarRatingLabelRateValueStarValue2({
    required Object value,
    required Object value2,
  });

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get safetySettingsScreenTitleSettings;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Account unavailable'**
  String get safetySettingsScreenTitleAccountUnavailable;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Sign out and sign back in if this keeps happening.'**
  String get safetySettingsScreenMessageSignOutAndSign;

  /// Product copy used by lib/swipes/presentation/event_recap_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event not found'**
  String get swipesEventRecapScreenTitleEventNotFound;

  /// Product copy used by lib/swipes/presentation/event_recap_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This event is no longer available.'**
  String get swipesEventRecapScreenMessageThisEventIsNo;

  /// Product copy used by lib/swipes/presentation/swipe_hub_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{length}'**
  String swipesSwipeHubScreenTextLength({required Object length});

  /// Product copy used by lib/swipes/presentation/swipe_hub_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Catches'**
  String get swipesSwipeHubScreenTitleCatches;

  /// Product copy used by lib/swipes/presentation/swipe_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Catches · {remainingCount} left'**
  String swipesSwipeScreenTextCatchesRemainingcountLeft({
    required Object remainingCount,
  });

  /// Product copy used by lib/swipes/presentation/widgets/attended_event_tile.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Catch'**
  String get swipesAttendedEventTileLabelCatch;

  /// Product copy used by lib/swipes/shared/profile_surface/catch_profile_view.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{name}, {age}'**
  String swipesCatchProfileViewTextNameAge({
    required Object name,
    required Object age,
  });

  /// Product copy used by lib/swipes/shared/profile_surface/profile_reaction_controls.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Like {label}'**
  String swipesProfileReactionControlsTooltipLikeLabel({required Object label});

  /// Product copy used by lib/swipes/shared/profile_surface/profile_reaction_controls.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Comment on {label}'**
  String swipesProfileReactionControlsTooltipCommentOnLabel({
    required Object label,
  });

  /// Product copy used by lib/swipes/shared/profile_surface/profile_reaction_controls.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Start with {label}'**
  String swipesProfileReactionControlsTitleStartWithLabel({
    required Object label,
  });

  /// Product copy used by lib/swipes/shared/profile_surface/profile_reaction_controls.dart (helperText).
  ///
  /// In en, this message translates to:
  /// **'{length} / {maxSwipeReactionCommentLength} characters'**
  String
  swipesProfileReactionControlsHelpertextLengthMaxswipereactioncommentlengthCharacters({
    required Object length,
    required Object maxSwipeReactionCommentLength,
  });

  /// Product copy used by lib/swipes/shared/profile_surface/profile_surface.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Profile of {name}, {age}'**
  String swipesProfileSurfaceLabelProfileOfNameAge({
    required Object name,
    required Object age,
  });

  /// Product copy used by lib/user_profile/presentation/profile_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get userProfileProfileScreenTitleYourProfile;

  /// Numbered prompt-question field label in the profile editor.
  ///
  /// In en, this message translates to:
  /// **'Prompt {number}'**
  String userProfileInlineEditorPromptLabelPromptNumber({
    required Object number,
  });

  /// Prompt-answer field label in the profile editor.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get userProfileInlineEditorPromptLabelAnswer;

  /// Action that opens the next empty profile prompt card.
  ///
  /// In en, this message translates to:
  /// **'Add another prompt'**
  String get userProfileInlineEditorPromptLabelAddAnotherPrompt;

  /// Product copy used by lib/user_profile/presentation/widgets/inline_editor_text.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'+ {displayValue}'**
  String userProfileInlineEditorTextTextDisplayvalue({
    required Object displayValue,
  });

  /// Product copy used by lib/user_profile/presentation/widgets/inline_editor_text.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'profile-inline-display-{label}-{displayValue}-{isAddAffordance}'**
  String userProfileInlineEditorTextTextProfileInlineDisplayLabel({
    required Object label,
    required Object displayValue,
    required Object isAddAffordance,
  });

  /// Product copy used by lib/user_profile/presentation/widgets/profile_sliver_header.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get userProfileProfileSliverHeaderLabelEdit;

  /// Product copy used by lib/user_profile/presentation/widgets/profile_sliver_header.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get userProfileProfileSliverHeaderLabelPreview;

  /// Product copy used by lib/user_profile/presentation/widgets/profile_sliver_header.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get userProfileProfileSliverHeaderLabelInsights;

  /// Product copy used by lib/user_profile/presentation/widgets/profile_tab_skeleton.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Prompts'**
  String get userProfileProfileTabSkeletonTitlePrompts;

  /// Product copy used by lib/user_profile/presentation/widgets/profile_tab_skeleton.dart (title).
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get userProfileProfileTabSkeletonTitleAboutYou;

  /// Product copy used by lib/user_profile/presentation/widgets/profile_tab_skeleton.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get userProfileProfileTabSkeletonTitleRunning;

  /// Product copy used by lib/user_profile/presentation/widgets/profile_tab_skeleton.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get userProfileProfileTabSkeletonTitleLifestyle;

  /// Product copy used by lib/clubs/presentation/discovery/widgets/club_list_tile_parts/avatar_chip.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Open {name} organizer'**
  String clubsAvatarChipLabelOpenNameClub({required Object name});

  /// Product copy used by lib/clubs/presentation/discovery/widgets/club_list_tile_parts/avatar_chip.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Event soon'**
  String get clubsAvatarChipTextEventSoon;

  /// Product copy used by lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Open {name} organizer'**
  String clubsDirectoryCardLabelOpenNameClub({required Object name});

  /// Product copy used by lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get clubsDirectoryCardLabelJoined;

  /// Product copy used by lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get clubsDirectoryCardLabelJoin;

  /// Product copy used by lib/dashboard/presentation/dashboard_empty_home_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get dashboardDashboardEmptyHomeScreenLabelHome;

  /// Product copy used by lib/dashboard/presentation/dashboard_home_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get dashboardDashboardHomeScreenLabelHome;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Private afterglow'**
  String get eventSuccessEventSuccessCompanionAfterglowLabelPrivateAfterglow;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Your night at {title}'**
  String eventSuccessEventSuccessCompanionAfterglowTextYourNightAtTitle({
    required Object title,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'A small recap for you, not a public share card.'**
  String get eventSuccessEventSuccessCompanionAfterglowTextASmallRecapFor;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart (label).
  ///
  /// In en, this message translates to:
  /// **'You showed up'**
  String get eventSuccessEventSuccessCompanionAfterglowLabelYouShowedUp;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Openers ready'**
  String get eventSuccessEventSuccessCompanionAfterglowLabelOpenersReady;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Memory saved'**
  String get eventSuccessEventSuccessCompanionAfterglowLabelMemorySaved;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Your read'**
  String get eventSuccessEventSuccessCompanionAfterglowLabelYourRead;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Your read saved'**
  String get eventSuccessEventSuccessCompanionAfterglowLabelYourReadSaved;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Only you see this recap. Hosts get aggregate coaching, never your private notes or individual opener choices.'**
  String get eventSuccessEventSuccessCompanionAfterglowTextOnlyYouSeeThis;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_arrival_mission.dart (label).
  ///
  /// In en, this message translates to:
  /// **'First Hello'**
  String get eventSuccessEventSuccessCompanionArrivalMissionLabelFirstHello;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_arrival_mission.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Start your First Hello.'**
  String
  get eventSuccessEventSuccessCompanionArrivalMissionTextStartYourFirstHello;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_arrival_mission.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'We will confirm you are at the venue, then give you one person and one tiny question. Complete it to check in.'**
  String
  get eventSuccessEventSuccessCompanionArrivalMissionTextWeWillConfirmYou;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_arrival_mission.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'This is a private prompt. It is designed to make the first conversation easier, not to put your answers on display.'**
  String get eventSuccessEventSuccessCompanionArrivalMissionTextThisIsAPrivate;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_arrival_mission.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Start First Hello'**
  String
  get eventSuccessEventSuccessCompanionArrivalMissionLabelStartFirstHello;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_arrival_mission.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Use normal check-in'**
  String
  get eventSuccessEventSuccessCompanionArrivalMissionLabelUseNormalCheckIn;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_arrival_mission.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Find {targetDisplayName}.'**
  String
  eventSuccessEventSuccessCompanionArrivalMissionTextFindTargetdisplayname({
    required Object targetDisplayName,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_arrival_mission.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Complete this tiny mission to check in. If the room is crowded or the person is late, use the fallback.'**
  String
  get eventSuccessEventSuccessCompanionArrivalMissionTextCompleteThisTinyMission;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_arrival_mission.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Complete check-in'**
  String
  get eventSuccessEventSuccessCompanionArrivalMissionLabelCompleteCheckIn;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_arrival_mission.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Can\'\'t find them'**
  String get eventSuccessEventSuccessCompanionArrivalMissionLabelCanTFindThem;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'How did it feel?'**
  String get eventSuccessEventSuccessCompanionFeedbackTextHowDidItFeel;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Your feedback is saved'**
  String get eventSuccessEventSuccessCompanionFeedbackTextYourFeedbackIsSaved;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'This is private-first: hosts see aggregate trends, while private notes and safety concerns stay with Catch.'**
  String get eventSuccessEventSuccessCompanionFeedbackTextThisIsPrivateFirst;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get eventSuccessEventSuccessCompanionFeedbackLabelWelcome;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Structure'**
  String get eventSuccessEventSuccessCompanionFeedbackLabelStructure;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart (title).
  ///
  /// In en, this message translates to:
  /// **'I want Catch to review a safety or comfort concern'**
  String get eventSuccessEventSuccessCompanionFeedbackTitleIWantCatchTo;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Private note to Catch'**
  String get eventSuccessEventSuccessCompanionFeedbackTitlePrivateNoteToCatch;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Submit feedback'**
  String get eventSuccessEventSuccessCompanionFeedbackLabelSubmitFeedback;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Update feedback'**
  String get eventSuccessEventSuccessCompanionFeedbackLabelUpdateFeedback;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'{label} {i}'**
  String eventSuccessEventSuccessCompanionFeedbackTooltipLabelI({
    required Object label,
    required Object i,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'People I met'**
  String get eventSuccessEventSuccessCompanionFeedbackTextPeopleIMet;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Decrease people met'**
  String get eventSuccessEventSuccessCompanionFeedbackTooltipDecreasePeopleMet;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{value}'**
  String eventSuccessEventSuccessCompanionFeedbackTextValue({
    required Object value,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Increase people met'**
  String get eventSuccessEventSuccessCompanionFeedbackTooltipIncreasePeopleMet;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Starter group'**
  String get eventSuccessEventSuccessCompanionLiveCardsLabelStarterGroup;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Starter groups paused for you'**
  String
  get eventSuccessEventSuccessCompanionLiveCardsTextStarterGroupsPausedFor;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Your starter group is forming'**
  String get eventSuccessEventSuccessCompanionLiveCardsTextYourStarterGroupIs;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'You won\'\'t be included when the host runs the generator.'**
  String get eventSuccessEventSuccessCompanionLiveCardsTextYouWonTBe;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'The host will publish starter groups once everyone is checked in.'**
  String get eventSuccessEventSuccessCompanionLiveCardsTextTheHostWillPublish;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Loading group members'**
  String get eventSuccessEventSuccessCompanionLiveCardsLabelLoadingGroupMembers;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Include me in starter groups'**
  String get eventSuccessEventSuccessCompanionLiveCardsLabelIncludeMeInStarter;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{value1} people'**
  String eventSuccessEventSuccessCompanionLiveCardsLabelValue1People({
    required Object value1,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Timed rotations'**
  String get eventSuccessEventSuccessCompanionLiveCardsLabelTimedRotations;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Timed rotations paused for you'**
  String
  get eventSuccessEventSuccessCompanionLiveCardsTextTimedRotationsPausedFor;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Your rotation schedule is forming'**
  String
  get eventSuccessEventSuccessCompanionLiveCardsTextYourRotationScheduleIs;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Your timed pairings appear once the host generates rotations.'**
  String
  get eventSuccessEventSuccessCompanionLiveCardsTextYourTimedPairingsAppear;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Loading partner names'**
  String get eventSuccessEventSuccessCompanionLiveCardsLabelLoadingPartnerNames;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Include me in timed rotations'**
  String get eventSuccessEventSuccessCompanionLiveCardsLabelIncludeMeInTimed;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{timeRange} · {peerName}'**
  String eventSuccessEventSuccessCompanionLiveCardsTextTimerangePeername({
    required Object timeRange,
    required Object peerName,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Live cue'**
  String get eventSuccessEventSuccessCompanionLiveCardsLabelLiveCue;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Event is live'**
  String get eventSuccessEventSuccessCompanionLiveCardsTextEventIsLive;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Follow the host for the next event moment.'**
  String get eventSuccessEventSuccessCompanionLiveCardsTextFollowTheHostFor;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (text).
  ///
  /// In en, this message translates to:
  /// **'Small starter group when you check in.'**
  String
  get eventSuccessEventSuccessCompanionLiveCardsTextSmallStarterGroupWhen;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (text).
  ///
  /// In en, this message translates to:
  /// **'Timed partner rotations during the event.'**
  String
  get eventSuccessEventSuccessCompanionLiveCardsTextTimedPartnerRotationsDuring;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (text).
  ///
  /// In en, this message translates to:
  /// **'Synchronized partner reveals as the event unfolds.'**
  String
  get eventSuccessEventSuccessCompanionLiveCardsTextSynchronizedPartnerRevealsAs;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (text).
  ///
  /// In en, this message translates to:
  /// **'Live conversation prompts from the host.'**
  String
  get eventSuccessEventSuccessCompanionLiveCardsTextLiveConversationPromptsFrom;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (text).
  ///
  /// In en, this message translates to:
  /// **'You can ask the host for an intro to someone specific.'**
  String get eventSuccessEventSuccessCompanionLiveCardsTextYouCanAskThe;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get eventSuccessEventSuccessCompanionLiveCardsLabelPreview;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'What we\'\'ll guide you through'**
  String get eventSuccessEventSuccessCompanionLiveCardsTextWhatWeLlGuide;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Live partner and group details unlock after check-in. Here\'\'s what to expect at the event:'**
  String get eventSuccessEventSuccessCompanionLiveCardsTextLivePartnerAndGroup;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get eventSuccessEventSuccessCompanionLiveCardsLabelArrival;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Arrival check-in'**
  String get eventSuccessEventSuccessCompanionLiveCardsTextArrivalCheckIn;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Confirm you are at the event so post-event follow-up only includes actual attendees.'**
  String get eventSuccessEventSuccessCompanionLiveCardsTextConfirmYouAreAt;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Scan host QR'**
  String get eventSuccessEventSuccessCompanionLiveCardsLabelScanHostQr;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get eventSuccessEventSuccessCompanionLiveCardsLabelCheckIn;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Scan host QR'**
  String get eventSuccessEventSuccessCompanionLiveCardsTextScanHostQr;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get eventSuccessEventSuccessCompanionLiveCardsMessageClose;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Location still verifies the venue after the QR is scanned.'**
  String
  get eventSuccessEventSuccessCompanionLiveCardsTextLocationStillVerifiesThe;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Copy opener'**
  String get eventSuccessEventSuccessCompanionLiveCardsMessageCopyOpener;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Copy cue'**
  String get eventSuccessEventSuccessCompanionLiveCardsMessageCopyCue;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_questionnaire.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'A few quick questions'**
  String
  get eventSuccessEventSuccessCompanionQuestionnaireTextAFewQuickQuestions;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_questionnaire.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Can guide pairings'**
  String
  get eventSuccessEventSuccessCompanionQuestionnaireLabelCanGuidePairings;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_questionnaire.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Clues only'**
  String get eventSuccessEventSuccessCompanionQuestionnaireLabelCluesOnly;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_questionnaire.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get eventSuccessEventSuccessCompanionQuestionnaireLabelSaved;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_questionnaire.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Your answers can shape reveal clues and help guide pairings. Hosts never see individual answers.'**
  String
  get eventSuccessEventSuccessCompanionQuestionnaireTextYourAnswersCanShape;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_questionnaire.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Your answers can shape reveal clues. Hosts never see individual answers, and this event will not use them for pairings.'**
  String
  get eventSuccessEventSuccessCompanionQuestionnaireTextYourAnswersCanShape025884;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_questionnaire.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Save clues'**
  String get eventSuccessEventSuccessCompanionQuestionnaireLabelSaveClues;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_questionnaire.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Update clues'**
  String get eventSuccessEventSuccessCompanionQuestionnaireLabelUpdateClues;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_questionnaire.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Question {value1}'**
  String eventSuccessEventSuccessCompanionQuestionnaireMessageQuestionValue1({
    required Object value1,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_questionnaire.dart (semanticLabel).
  ///
  /// In en, this message translates to:
  /// **'Question {value1}'**
  String
  eventSuccessEventSuccessCompanionQuestionnaireSemanticlabelQuestionValue1({
    required Object value1,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_questionnaire.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{value1}'**
  String eventSuccessEventSuccessCompanionQuestionnaireTextValue1({
    required Object value1,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Event companion'**
  String get eventSuccessEventSuccessCompanionSharedTextEventCompanion;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{padLeft} / {totalSteps}'**
  String eventSuccessEventSuccessCompanionSharedTextPadleftTotalsteps({
    required Object padLeft,
    required Object totalSteps,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'YOUR TICKET - TODAY'**
  String get eventSuccessEventSuccessCompanionSharedTextYourTicketToday;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'WHEN'**
  String get eventSuccessEventSuccessCompanionSharedLabelWhen;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'WHERE'**
  String get eventSuccessEventSuccessCompanionSharedLabelWhere;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'ENTRY'**
  String get eventSuccessEventSuccessCompanionSharedLabelEntry;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{title} - {locationName}'**
  String eventSuccessEventSuccessCompanionSharedTextTitleLocationname({
    required Object title,
    required Object locationName,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'What to expect'**
  String get eventSuccessEventSuccessCompanionSharedLabelWhatToExpect;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'I\'\'m here - check me in'**
  String get eventSuccessEventSuccessCompanionSharedLabelIMHereCheck;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get eventSuccessEventSuccessCompanionSharedMessageBack;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{title} · {locationName}'**
  String eventSuccessEventSuccessCompanionSharedTextTitleLocationname29e462({
    required Object title,
    required Object locationName,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{checkedInCount}'**
  String eventSuccessEventSuccessCompanionSharedTextCheckedincount({
    required Object checkedInCount,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'1 person is checked in alongside you'**
  String get eventSuccessEventSuccessCompanionSharedText1PersonIsChecked;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{count} people in the room with you'**
  String eventSuccessEventSuccessCompanionSharedTextCountPeopleInThe({
    required Object count,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'The host is running the room'**
  String get eventSuccessEventSuccessCompanionSharedTextTheHostIsRunning;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Your next prompt or partner reveal will show up here.'**
  String get eventSuccessEventSuccessCompanionSharedTextYourNextPromptOr;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_wingman.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Ask the host for an intro'**
  String get eventSuccessEventSuccessCompanionWingmanTextAskTheHostFor;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_wingman.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Tell the host who you\'\'d like to be introduced to. The host can see this request — the other person is not notified.'**
  String get eventSuccessEventSuccessCompanionWingmanTextTellTheHostWho;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_wingman.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Request sent for {value1}.'**
  String eventSuccessEventSuccessCompanionWingmanTextRequestSentForValue1({
    required Object value1,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_wingman.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get eventSuccessEventSuccessCompanionWingmanLabelWithdraw;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_wingman.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Private note to host'**
  String get eventSuccessEventSuccessCompanionWingmanTitlePrivateNoteToHost;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_wingman.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'No checked-in attendees available yet.'**
  String get eventSuccessEventSuccessCompanionWingmanTextNoCheckedInAttendees;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_wingman.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get eventSuccessEventSuccessCompanionWingmanLabelRequested;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_wingman.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Ask host'**
  String get eventSuccessEventSuccessCompanionWingmanLabelAskHost;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_wingman.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get eventSuccessEventSuccessCompanionWingmanLabelSwitch;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Social prompt'**
  String get eventSuccessEventSuccessCompanionBodyScreenTitleSocialPrompt;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Suggested first-message openers'**
  String
  get eventSuccessEventSuccessCompanionBodyScreenTitleSuggestedFirstMessageOpeners;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Conversation cues'**
  String get eventSuccessEventSuccessCompanionBodyScreenTitleConversationCues;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Use one after a mutual match opens.'**
  String get eventSuccessEventSuccessCompanionBodyScreenSubtitleUseOneAfterA;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Pick one when the room needs an easy next line.'**
  String get eventSuccessEventSuccessCompanionBodyScreenSubtitlePickOneWhenThe;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Live mode needs saved setup'**
  String get eventSuccessEventSuccessHostLiveTitleLiveModeNeedsSaved;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Live mode was not configured'**
  String get eventSuccessEventSuccessHostLiveTitleLiveModeWasNot;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Save the live guide before the event to enable guided controls. Attendance and check-in stay available from this Live tab.'**
  String get eventSuccessEventSuccessHostLiveBodySaveTheLiveGuide;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (body).
  ///
  /// In en, this message translates to:
  /// **'This event did not have a live guide saved before it started. Attendance and check-in remain available; guided live controls stay unavailable for this event.'**
  String get eventSuccessEventSuccessHostLiveBodyThisEventDidNot;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No live steps selected'**
  String get eventSuccessEventSuccessHostLiveTitleNoLiveStepsSelected;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (body).
  ///
  /// In en, this message translates to:
  /// **'This saved setup does not include any tools the host can use during the event.'**
  String get eventSuccessEventSuccessHostLiveBodyThisSavedSetupDoes;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Conversation cues'**
  String get eventSuccessEventSuccessHostLiveTitleConversationCues;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Use one when the room needs a cleaner next interaction.'**
  String get eventSuccessEventSuccessHostLiveSubtitleUseOneWhenThe;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Close with one suggested first message after mutual matches.'**
  String get eventSuccessEventSuccessHostLiveSubtitleCloseWithOneSuggested;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Supporting controls'**
  String get eventSuccessEventSuccessHostLiveTitleSupportingControls;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Controls that stay available without competing with the current live step.'**
  String get eventSuccessEventSuccessHostLiveSubtitleControlsThatStayAvailable;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Mark live guide complete'**
  String get eventSuccessEventSuccessHostLiveLabelMarkLiveGuideComplete;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Controls for this step'**
  String get eventSuccessEventSuccessHostLiveTitleControlsForThisStep;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Handle these before moving the room forward.'**
  String get eventSuccessEventSuccessHostLiveSubtitleHandleTheseBeforeMoving;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Live now'**
  String get eventSuccessEventSuccessHostLiveTextLiveNow;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (CatchButton).
  ///
  /// In en, this message translates to:
  /// **'eventSuccessPreviousStepButton'**
  String
  get eventSuccessEventSuccessHostLiveCatchbuttonEventsuccesspreviousstepbutton;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get eventSuccessEventSuccessHostLiveLabelPrevious;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (CatchButton).
  ///
  /// In en, this message translates to:
  /// **'eventSuccessNextStepButton'**
  String
  get eventSuccessEventSuccessHostLiveCatchbuttonEventsuccessnextstepbutton;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Small starter groups'**
  String get eventSuccessEventSuccessHostOverridesTextSmallStarterGroups;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{length} assigned'**
  String eventSuccessEventSuccessHostOverridesLabelLengthAssigned({
    required Object length,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{optedOutCount} opted out'**
  String eventSuccessEventSuccessHostOverridesLabelOptedoutcountOptedOut({
    required Object optedOutCount,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Host edited'**
  String get eventSuccessEventSuccessHostOverridesLabelHostEdited;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Regenerate to remove opted-out attendee cards from the current pod set.'**
  String get eventSuccessEventSuccessHostOverridesTextRegenerateToRemoveOpted;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Generate attendee pod cards from the roster, excluding opted-out attendees.'**
  String get eventSuccessEventSuccessHostOverridesTextGenerateAttendeePodCards;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Generate attendee pod cards from the current booked and checked-in roster.'**
  String
  get eventSuccessEventSuccessHostOverridesTextGenerateAttendeePodCards4cbcdf;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (CatchButton).
  ///
  /// In en, this message translates to:
  /// **'eventSuccessGenerateMicroPodsButton'**
  String
  get eventSuccessEventSuccessHostOverridesCatchbuttonEventsuccessgeneratemicropodsbutton;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Generate micro-pods'**
  String get eventSuccessEventSuccessHostOverridesLabelGenerateMicroPods;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get eventSuccessEventSuccessHostOverridesLabelRegenerate;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Edit groups'**
  String get eventSuccessEventSuccessHostOverridesLabelEditGroups;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Edit groups'**
  String get eventSuccessEventSuccessHostOverridesTitleEditGroups;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Host override'**
  String get eventSuccessEventSuccessHostOverridesSubtitleHostOverride;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Save overrides'**
  String get eventSuccessEventSuccessHostOverridesLabelSaveOverrides;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Group {value1}'**
  String eventSuccessEventSuccessHostOverridesLabelGroupValue1({
    required Object value1,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Round {value1}'**
  String eventSuccessEventSuccessHostOverridesTextRoundValue1({
    required Object value1,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Add group'**
  String get eventSuccessEventSuccessHostOverridesLabelAddGroup;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'No groups in this round.'**
  String get eventSuccessEventSuccessHostOverridesTextNoGroupsInThis;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Group label'**
  String get eventSuccessEventSuccessHostOverridesTitleGroupLabel;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Remove group'**
  String get eventSuccessEventSuccessHostOverridesTooltipRemoveGroup;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Add attendee'**
  String get eventSuccessEventSuccessHostOverridesLabelAddAttendee;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Group attendee'**
  String get eventSuccessEventSuccessHostOverridesTitleGroupAttendee;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (hintText).
  ///
  /// In en, this message translates to:
  /// **'Attendee'**
  String get eventSuccessEventSuccessHostOverridesHinttextAttendee;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Remove attendee'**
  String get eventSuccessEventSuccessHostOverridesTooltipRemoveAttendee;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Timed partner rotations'**
  String get eventSuccessEventSuccessHostOverridesTextTimedPartnerRotations;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{roundCount} rounds'**
  String eventSuccessEventSuccessHostOverridesLabelRoundcountRounds({
    required Object roundCount,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Regenerate to remove opted-out attendees from timed rotations.'**
  String
  get eventSuccessEventSuccessHostOverridesTextRegenerateToRemoveOpted4eddde;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Generate pairings from event duration, saved cadence, checked-in participants, and mutual gender interest.'**
  String get eventSuccessEventSuccessHostOverridesTextGeneratePairingsFromEvent;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{eventRotationCapacity} possible'**
  String
  eventSuccessEventSuccessHostOverridesLabelEventrotationcapacityPossible({
    required Object eventRotationCapacity,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{sitOutRoundCount} planned breaks'**
  String
  eventSuccessEventSuccessHostOverridesLabelSitoutroundcountPlannedBreaks({
    required Object sitOutRoundCount,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{repeatPeerCount} repeated peers'**
  String
  eventSuccessEventSuccessHostOverridesLabelRepeatpeercountRepeatedPeers({
    required Object repeatPeerCount,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (CatchButton).
  ///
  /// In en, this message translates to:
  /// **'eventSuccessGenerateRotationsButton'**
  String
  get eventSuccessEventSuccessHostOverridesCatchbuttonEventsuccessgeneraterotationsbutton;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Generate rotations'**
  String get eventSuccessEventSuccessHostOverridesLabelGenerateRotations;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Edit rotations'**
  String get eventSuccessEventSuccessHostOverridesLabelEditRotations;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Edit rotations'**
  String get eventSuccessEventSuccessHostOverridesTitleEditRotations;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Add pair'**
  String get eventSuccessEventSuccessHostOverridesLabelAddPair;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'No pairs in this round.'**
  String get eventSuccessEventSuccessHostOverridesTextNoPairsInThis;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (title).
  ///
  /// In en, this message translates to:
  /// **'First rotation attendee'**
  String get eventSuccessEventSuccessHostOverridesTitleFirstRotationAttendee;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Second rotation attendee'**
  String get eventSuccessEventSuccessHostOverridesTitleSecondRotationAttendee;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (hintText).
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get eventSuccessEventSuccessHostOverridesHinttextPartner;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Remove pair'**
  String get eventSuccessEventSuccessHostOverridesTooltipRemovePair;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{key} · {value} assigned'**
  String eventSuccessEventSuccessHostOverridesLabelKeyValueAssigned({
    required Object key,
    required Object value,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Assignment notes'**
  String get eventSuccessEventSuccessHostOverridesTextAssignmentNotes;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No event report yet'**
  String get eventSuccessEventSuccessHostReportTitleNoEventReportYet;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (body).
  ///
  /// In en, this message translates to:
  /// **'The live event guide was not saved for this event, so there is no post-event report to review. Attendance reporting remains available on this screen.'**
  String get eventSuccessEventSuccessHostReportBodyTheLiveEventGuide;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Post-event insights are off'**
  String get eventSuccessEventSuccessHostReportTitlePostEventInsightsAre;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (body).
  ///
  /// In en, this message translates to:
  /// **'This event guide does not include post-event coaching for the host.'**
  String get eventSuccessEventSuccessHostReportBodyThisEventGuideDoes;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Waiting for attendee feedback'**
  String get eventSuccessEventSuccessHostReportTitleWaitingForAttendeeFeedback;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (title).
  ///
  /// In en, this message translates to:
  /// **'{feedbackCount} attendee feedback response{value2}'**
  String
  eventSuccessEventSuccessHostReportTitleFeedbackcountAttendeeFeedbackResponse({
    required Object feedbackCount,
    required Object value2,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (body).
  ///
  /// In en, this message translates to:
  /// **'The report combines attendance, safe aggregate feedback, assignment coverage, and explicit host-help requests. Private notes, safety concerns, and individual opener choices are not shown to hosts.'**
  String get eventSuccessEventSuccessHostReportBodyTheReportCombinesAttendance;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'How reliable is this report?'**
  String get eventSuccessEventSuccessHostReportTextHowReliableIsThis;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Shows whether the report is based on enough live data to trust.'**
  String get eventSuccessEventSuccessHostReportTextShowsWhetherTheReport;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get eventSuccessEventSuccessHostReportLabelFeedback;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Caught someone'**
  String get eventSuccessEventSuccessHostReportLabelCaughtSomeone;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (label).
  ///
  /// In en, this message translates to:
  /// **'People included'**
  String get eventSuccessEventSuccessHostReportLabelPeopleIncluded;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Opted out'**
  String get eventSuccessEventSuccessHostReportLabelOptedOut;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Wingman help'**
  String get eventSuccessEventSuccessHostReportLabelWingmanHelp;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{feedbackResponseCount}/{checkedInCount} feedback'**
  String
  eventSuccessEventSuccessHostReportLabelFeedbackresponsecountCheckedincountFeedback({
    required Object feedbackResponseCount,
    required Object checkedInCount,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{attendeesWhoCaughtSomeone} caught someone'**
  String
  eventSuccessEventSuccessHostReportLabelAttendeeswhocaughtsomeoneCaughtSomeone({
    required Object attendeesWhoCaughtSomeone,
  });

  /// Label for the number of post-event catches sent.
  ///
  /// In en, this message translates to:
  /// **'Catches sent'**
  String get eventSuccessEventSuccessHostReportLabelCatchesSent;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{assignmentParticipantCount} assigned'**
  String
  eventSuccessEventSuccessHostReportLabelAssignmentparticipantcountAssigned({
    required Object assignmentParticipantCount,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{assignmentOptOutCount} opted out'**
  String eventSuccessEventSuccessHostReportLabelAssignmentoptoutcountOptedOut({
    required Object assignmentOptOutCount,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{wingmanRequestCount} host-help requests'**
  String
  eventSuccessEventSuccessHostReportLabelWingmanrequestcountHostHelpRequests({
    required Object wingmanRequestCount,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Event funnel'**
  String get eventSuccessEventSuccessHostReportTextEventFunnel;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Demand to booked'**
  String get eventSuccessEventSuccessHostReportLabelDemandToBooked;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Requests approved'**
  String get eventSuccessEventSuccessHostReportLabelRequestsApproved;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Offers accepted'**
  String get eventSuccessEventSuccessHostReportLabelOffersAccepted;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Payment complete'**
  String get eventSuccessEventSuccessHostReportLabelPaymentComplete;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Repeat attendees'**
  String get eventSuccessEventSuccessHostReportLabelRepeatAttendees;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{totalDemandCount} people in demand'**
  String eventSuccessEventSuccessHostReportLabelTotaldemandcountPeopleInDemand({
    required Object totalDemandCount,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{waitlistJoinCount} waitlisted'**
  String eventSuccessEventSuccessHostReportLabelWaitlistjoincountWaitlisted({
    required Object waitlistJoinCount,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{paymentCompletedCount} paid'**
  String eventSuccessEventSuccessHostReportLabelPaymentcompletedcountPaid({
    required Object paymentCompletedCount,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{chatStartedCount} chats started'**
  String eventSuccessEventSuccessHostReportLabelChatstartedcountChatsStarted({
    required Object chatStartedCount,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_setup.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event started without a saved guide'**
  String get eventSuccessEventSuccessHostSetupTitleEventStartedWithoutA;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_setup.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Live guide can no longer be saved'**
  String get eventSuccessEventSuccessHostSetupTitleLiveGuideCanNo;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_setup.dart (body).
  ///
  /// In en, this message translates to:
  /// **'This event began before a live guide was saved. Attendance and check-in still work, but the Live tab won\'\'t have any guided controls for this event.'**
  String get eventSuccessEventSuccessHostSetupBodyThisEventBeganBefore;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_setup.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Bookings have already started. Attendance and check-in still work, but the Live tab won\'\'t have guided controls unless a guide was saved first.'**
  String get eventSuccessEventSuccessHostSetupBodyBookingsHaveAlreadyStarted;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_setup.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Setup not saved yet'**
  String get eventSuccessEventSuccessHostSetupTitleSetupNotSavedYet;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_setup.dart (body).
  ///
  /// In en, this message translates to:
  /// **'This default plan is visible here only. Save it so the Live tab is ready when the event starts.'**
  String get eventSuccessEventSuccessHostSetupBodyThisDefaultPlanIs;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_setup.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Settings are locked'**
  String get eventSuccessEventSuccessHostSetupTitleSettingsAreLocked;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_setup.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Bookings have started, so the saved guide is locked in. Switch to the Live tab to drive the event in real time once it starts.'**
  String get eventSuccessEventSuccessHostSetupBodyBookingsHaveStartedSo;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_setup.dart (body).
  ///
  /// In en, this message translates to:
  /// **'The event has started — setup is locked. Use the Live tab to control the event right now, and the Report tab afterward.'**
  String get eventSuccessEventSuccessHostSetupBodyTheEventHasStarted;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_setup.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Your plan'**
  String get eventSuccessEventSuccessHostSetupTitleYourPlan;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_setup.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get eventSuccessEventSuccessHostSetupLabelSaveChanges;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_setup.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Save setup'**
  String get eventSuccessEventSuccessHostSetupLabelSaveSetup;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_setup.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Save live guide'**
  String get eventSuccessEventSuccessHostSetupLabelSaveLiveGuide;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_setup.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Target attendees'**
  String get eventSuccessEventSuccessHostSetupTextTargetAttendees;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_setup.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Recommended range: {recommendedMin}-{recommendedMax}'**
  String
  eventSuccessEventSuccessHostSetupTextRecommendedRangeRecommendedminRecommendedmax({
    required Object recommendedMin,
    required Object recommendedMax,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_setup.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Add a goal so the live guide knows what to aim for.'**
  String
  get eventSuccessEventSuccessHostSetupTextAddAGoalSoTheLiveGuideKnowsWhatToAimFor;

  /// Heading above live guide readiness issues.
  ///
  /// In en, this message translates to:
  /// **'Before launch'**
  String get eventSuccessEventSuccessHostSetupTitleBeforeLaunch;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_setup.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get eventSuccessEventSuccessHostSetupTextUnsavedChanges;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{length} tools'**
  String eventSuccessEventSuccessHostSharedLabelLengthTools({
    required Object length,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Not saved'**
  String get eventSuccessEventSuccessHostSharedLabelNotSaved;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{length} selected'**
  String eventSuccessEventSuccessHostSharedLabelLengthSelected({
    required Object length,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_shared.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Match clue questions'**
  String get eventSuccessEventSuccessHostSharedTextMatchClueQuestions;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Can guide pairings'**
  String get eventSuccessEventSuccessHostSharedLabelCanGuidePairings;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Clues only'**
  String get eventSuccessEventSuccessHostSharedLabelCluesOnly;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_shared.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Suggested pairings can use shared answers as one light input after interest, safety, and attendee opt-out checks.'**
  String get eventSuccessEventSuccessHostSharedTextSuggestedPairingsCanUse;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_shared.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Answers can still shape reveal clues, but suggested pairings will not use them.'**
  String get eventSuccessEventSuccessHostSharedTextAnswersCanStillShape;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_shared.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'\"Help me say hi\" requests'**
  String get eventSuccessEventSuccessHostSharedTextHelpMeSayHi;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{length} active'**
  String eventSuccessEventSuccessHostSharedLabelLengthActive({
    required Object length,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_shared.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Attendees explicitly asked the host for help. Use rotation edits or live facilitation to pair them safely.'**
  String get eventSuccessEventSuccessHostSharedTextAttendeesExplicitlyAskedThe;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_shared.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Attendees explicitly asked the host for help. Use this as live facilitation context.'**
  String
  get eventSuccessEventSuccessHostSharedTextAttendeesExplicitlyAskedThef44110;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_shared.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'No host-help requests yet.'**
  String get eventSuccessEventSuccessHostSharedTextNoHostHelpRequests;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Host visible'**
  String get eventSuccessEventSuccessHostSharedLabelHostVisible;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_actions.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Generate assignments first'**
  String
  get eventSuccessEventSuccessLiveRevealActionsLabelGenerateAssignmentsFirst;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_actions.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Reveal now'**
  String get eventSuccessEventSuccessLiveRevealActionsLabelRevealNow;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_actions.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get eventSuccessEventSuccessLiveRevealActionsLabelReset;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_actions.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Reset reveal'**
  String get eventSuccessEventSuccessLiveRevealActionsLabelResetReveal;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_actions.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Reveal round {value1}'**
  String eventSuccessEventSuccessLiveRevealActionsLabelRevealRoundValue1({
    required Object value1,
  });

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_actions.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Drop {countdownSeconds}s countdown'**
  String
  eventSuccessEventSuccessLiveRevealActionsLabelDropCountdownsecondsSCountdown({
    required Object countdownSeconds,
  });

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_attendee.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Unlocking'**
  String get eventSuccessEventSuccessLiveRevealAttendeeLabelUnlocking;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_attendee.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Revealed'**
  String get eventSuccessEventSuccessLiveRevealAttendeeLabelRevealed;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_attendee.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get eventSuccessEventSuccessLiveRevealAttendeeLabelWaiting;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_host.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Synchronized partner reveal'**
  String
  get eventSuccessEventSuccessLiveRevealHostLabelSynchronizedPartnerReveal;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_host.dart (label).
  ///
  /// In en, this message translates to:
  /// **'No assignments'**
  String get eventSuccessEventSuccessLiveRevealHostLabelNoAssignments;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_host.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{value1}/{roundCount} shown'**
  String eventSuccessEventSuccessLiveRevealHostLabelValue1RoundcountShown({
    required Object value1,
    required Object roundCount,
  });

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_host.dart (caption).
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get eventSuccessEventSuccessLiveRevealHostCaptionSeconds;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_host.dart (caption).
  ///
  /// In en, this message translates to:
  /// **'revealed'**
  String get eventSuccessEventSuccessLiveRevealHostCaptionRevealed;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_host.dart (caption).
  ///
  /// In en, this message translates to:
  /// **'next round'**
  String get eventSuccessEventSuccessLiveRevealHostCaptionNextRound;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Room hold'**
  String get eventSuccessEventSuccessLiveRevealWidgetsLabelRoomHold;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Everyone gets this {assignmentNoun} at the same time. No names shown yet.'**
  String
  eventSuccessEventSuccessLiveRevealWidgetsTextEveryoneGetsThisAssignmentnoun({
    required Object assignmentNoun,
  });

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{seconds}'**
  String eventSuccessEventSuccessLiveRevealWidgetsTextSeconds({
    required Object seconds,
  });

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'SECONDS'**
  String get eventSuccessEventSuccessLiveRevealWidgetsTextSeconds3fb8f1;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get eventSuccessEventSuccessLiveRevealWidgetsLabelHold;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get eventSuccessEventSuccessLiveRevealWidgetsLabelWatch;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get eventSuccessEventSuccessLiveRevealWidgetsLabelMove;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No names shown yet'**
  String get eventSuccessEventSuccessLiveRevealWidgetsTitleNoNamesShownYet;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Partner details stay locked until the shared release.'**
  String
  get eventSuccessEventSuccessLiveRevealWidgetsBodyPartnerDetailsStayLocked;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Clue is live'**
  String get eventSuccessEventSuccessLiveRevealWidgetsTitleClueIsLive;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'The room is holding for the reveal.'**
  String get eventSuccessEventSuccessLiveRevealWidgetsTextTheRoomIsHolding;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'The host controls the {assignmentNoun} unlock from live mode.'**
  String eventSuccessEventSuccessLiveRevealWidgetsTextTheHostControlsThe({
    required Object assignmentNoun,
  });

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Unlocked together'**
  String get eventSuccessEventSuccessLiveRevealWidgetsTitleUnlockedTogether;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{value1} people'**
  String eventSuccessEventSuccessLiveRevealWidgetsLabelValue1People({
    required Object value1,
  });

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Loading podmates'**
  String get eventSuccessEventSuccessLiveRevealWidgetsLabelLoadingPodmates;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Loading partners'**
  String get eventSuccessEventSuccessLiveRevealWidgetsLabelLoadingPartners;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Loading group members'**
  String get eventSuccessEventSuccessLiveRevealWidgetsLabelLoadingGroupMembers;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Names loading'**
  String get eventSuccessEventSuccessLiveRevealWidgetsLabelNamesLoading;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{timeRange} · {peerName}'**
  String eventSuccessEventSuccessLiveRevealWidgetsTextTimerangePeername({
    required Object timeRange,
    required Object peerName,
  });

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Hidden until reveal'**
  String get eventSuccessEventSuccessLiveRevealWidgetsLabelHiddenUntilReveal;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Round {value1}'**
  String eventSuccessEventSuccessLiveRevealWidgetsLabelRoundValue1({
    required Object value1,
  });

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'R{value1}'**
  String eventSuccessEventSuccessLiveRevealWidgetsTextRValue1({
    required Object value1,
  });

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (label).
  ///
  /// In en, this message translates to:
  /// **'R{value1}'**
  String eventSuccessEventSuccessLiveRevealWidgetsLabelRValue1({
    required Object value1,
  });

  /// Product copy used by lib/events/shared/event_joined_celebration_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'with {clubName}'**
  String eventsEventJoinedCelebrationScreenMessageWithClubname({
    required Object clubName,
  });

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_route_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get hostsEditHostedEventRouteScreenTitleEditEvent;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_route_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event not found'**
  String get hostsEditHostedEventRouteScreenTitleEventNotFound;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_route_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This hosted event is no longer available.'**
  String get hostsEditHostedEventRouteScreenMessageThisHostedEventIs;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_route_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Action unavailable'**
  String get hostsEditHostedEventRouteScreenTitleActionUnavailable;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_route_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'You can edit only events that you host.'**
  String get hostsEditHostedEventRouteScreenMessageYouCanEditOnly;

  /// Product copy used by lib/hosts/presentation/host_event_manage_route_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Manage event'**
  String get hostsHostEventManageRouteScreenTitleManageEvent;

  /// Product copy used by lib/hosts/presentation/host_event_manage_route_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event not found'**
  String get hostsHostEventManageRouteScreenTitleEventNotFound;

  /// Product copy used by lib/hosts/presentation/host_event_manage_route_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This hosted event is no longer available.'**
  String get hostsHostEventManageRouteScreenMessageThisHostedEventIs;

  /// Product copy used by lib/hosts/presentation/host_event_manage_route_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Action unavailable'**
  String get hostsHostEventManageRouteScreenTitleActionUnavailable;

  /// Product copy used by lib/hosts/presentation/host_event_manage_route_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'You can manage only events that you host.'**
  String get hostsHostEventManageRouteScreenMessageYouCanManageOnly;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_team_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get hostsHostClubTeamScreenTitleSignOut;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_team_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get hostsHostClubTeamScreenLabelEdit;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_team_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get hostsHostClubTeamScreenLabelPreview;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_team_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get hostsHostClubTeamScreenTitleProfile;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_team_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get hostsHostClubTeamScreenTitleDisplayName;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_team_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Role title'**
  String get hostsHostClubTeamScreenTitleRoleTitle;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_team_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get hostsHostClubTeamScreenTitleStatus;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_team_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'About you as a host'**
  String get hostsHostClubTeamScreenTitleAboutYouAsA;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_team_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Organizers you host'**
  String get hostsHostClubTeamScreenTitleClubsYouHost;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_team_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'No hosted organizers yet.'**
  String get hostsHostClubTeamScreenTextNoHostClubsYet;

  /// Product copy used by lib/hosts/presentation/host_operations/host_analytics.dart (label).
  ///
  /// In en, this message translates to:
  /// **'All events'**
  String get hostsHostAnalyticsLabelAllEvents;

  /// Product copy used by lib/hosts/presentation/host_operations/host_analytics.dart (label).
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get hostsHostAnalyticsLabel30Days;

  /// Product copy used by lib/hosts/presentation/host_operations/host_analytics.dart (label).
  ///
  /// In en, this message translates to:
  /// **'90 days'**
  String get hostsHostAnalyticsLabel90Days;

  /// Long-range preset on the Host club Insights scorecard.
  ///
  /// In en, this message translates to:
  /// **'12 months'**
  String get hostsHostAnalyticsLabel12Months;

  /// Freshness label for a Host analytics report.
  ///
  /// In en, this message translates to:
  /// **'Updated {relative}'**
  String hostsHostAnalyticsTextUpdatedRelative({required Object relative});

  /// Host-safe analytics freshness warning.
  ///
  /// In en, this message translates to:
  /// **'Some data is still syncing — numbers may update.'**
  String get hostsHostAnalyticsTextSomeDataIsStillSyncingNumbersMayUpdate;

  /// Scope label for lifetime club identity metrics.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get hostsHostAnalyticsLabelAllTime;

  /// Heading above the Host analytics range control.
  ///
  /// In en, this message translates to:
  /// **'Performance period'**
  String get hostsHostAnalyticsLabelPerformancePeriod;

  /// Heading for range-scoped Host performance metrics.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get hostsHostAnalyticsLabelPerformance;

  /// Combined listing and event-view analytics label.
  ///
  /// In en, this message translates to:
  /// **'Profile & event views'**
  String get hostsHostAnalyticsLabelProfileAndEventViews;

  /// Client-owned label for listing-view analytics.
  ///
  /// In en, this message translates to:
  /// **'Profile views'**
  String get hostsHostAnalyticsLabelProfileViews;

  /// Client-owned label for event-view analytics.
  ///
  /// In en, this message translates to:
  /// **'Event views'**
  String get hostsHostAnalyticsLabelEventViews;

  /// Client-owned Host analytics metric label.
  ///
  /// In en, this message translates to:
  /// **'Attendance rate'**
  String get hostsHostAnalyticsLabelAttendanceRate;

  /// Client-owned Host analytics metric label.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get hostsHostAnalyticsLabelRevenue;

  /// Client-owned Host analytics metric label.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get hostsHostAnalyticsLabelConnections;

  /// Client-owned Host analytics metric label.
  ///
  /// In en, this message translates to:
  /// **'Checkout drop-off'**
  String get hostsHostAnalyticsLabelCheckoutDropOff;

  /// Client-owned Host analytics metric label.
  ///
  /// In en, this message translates to:
  /// **'Checkout conversion'**
  String get hostsHostAnalyticsLabelCheckoutConversion;

  /// Client-owned Host analytics metric label.
  ///
  /// In en, this message translates to:
  /// **'Chats started'**
  String get hostsHostAnalyticsLabelChatsStarted;

  /// Disclosure label for secondary Host analytics metrics.
  ///
  /// In en, this message translates to:
  /// **'More metrics'**
  String get hostsHostAnalyticsLabelMoreMetrics;

  /// Supporting copy for secondary Host analytics metrics.
  ///
  /// In en, this message translates to:
  /// **'Checkout, chats and saves'**
  String get hostsHostAnalyticsBodyCheckoutChatsAndSaves;

  /// Badge for a partially available Host metric.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get hostsHostAnalyticsLabelPartial;

  /// Badge for an unavailable Host metric.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get hostsHostAnalyticsLabelMissing;

  /// Comparison caption for a Host analytics metric.
  ///
  /// In en, this message translates to:
  /// **'{direction} {percent}% vs previous {period}'**
  String hostsHostAnalyticsTextDirectionPercentVsPreviousPeriod({
    required Object direction,
    required Object percent,
    required Object period,
  });

  /// Empty-state copy for the Host analytics trend.
  ///
  /// In en, this message translates to:
  /// **'No analytics in this range.'**
  String get hostsHostAnalyticsTextNoAnalyticsInThisRange;

  /// Selected Host analytics trend-bucket detail.
  ///
  /// In en, this message translates to:
  /// **'{period}: {demand} demand · {bookings} bookings'**
  String hostsHostAnalyticsTextPeriodDemandBookings({
    required Object period,
    required Object demand,
    required Object bookings,
  });

  /// Heading for recent events linked to their reports.
  ///
  /// In en, this message translates to:
  /// **'Recent events'**
  String get hostsHostAnalyticsLabelRecentEvents;

  /// Single warning badge on a recent event with payment friction.
  ///
  /// In en, this message translates to:
  /// **'Payment issues'**
  String get hostsHostAnalyticsLabelPaymentIssues;

  /// Compact recent-event metric summary.
  ///
  /// In en, this message translates to:
  /// **'{booked} booked · {attended} attended · {matches} matches'**
  String hostsHostAnalyticsTextBookedAttendedMatches({
    required Object booked,
    required Object attended,
    required Object matches,
  });

  /// Compact recent-event date and status line.
  ///
  /// In en, this message translates to:
  /// **'{date} · {status}'**
  String hostsHostAnalyticsTextEventDateStatus({
    required Object date,
    required Object status,
  });

  /// Heading for the Host analytics review summary.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get hostsHostAnalyticsLabelReviews;

  /// Published review count label.
  ///
  /// In en, this message translates to:
  /// **'Published reviews'**
  String get hostsHostAnalyticsLabelPublishedReviews;

  /// Localized event status.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get hostsHostAnalyticsStatusLive;

  /// Localized event status.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get hostsHostAnalyticsStatusActive;

  /// Localized event status.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get hostsHostAnalyticsStatusOpen;

  /// Localized event status.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get hostsHostAnalyticsStatusPublished;

  /// Localized event status.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get hostsHostAnalyticsStatusCompleted;

  /// Localized event status.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get hostsHostAnalyticsStatusPast;

  /// Localized event status.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get hostsHostAnalyticsStatusDraft;

  /// Localized event status.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get hostsHostAnalyticsStatusPending;

  /// Localized event status.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get hostsHostAnalyticsStatusScheduled;

  /// Localized event status.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get hostsHostAnalyticsStatusCancelled;

  /// Product copy used by lib/hosts/presentation/host_operations/host_analytics.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Trend · bookings vs demand'**
  String get hostsHostAnalyticsLabelTrendBookingsVsDemand;

  /// Product copy used by lib/hosts/presentation/host_operations/host_analytics.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Demand'**
  String get hostsHostAnalyticsLabelDemand;

  /// Product copy used by lib/hosts/presentation/host_operations/host_analytics.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get hostsHostAnalyticsLabelBookings;

  /// Product copy used by lib/hosts/presentation/host_operations/host_analytics.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'No events in this range.'**
  String get hostsHostAnalyticsTextNoEventsInThis;

  /// Product copy used by lib/hosts/presentation/host_operations/host_analytics.dart (label).
  ///
  /// In en, this message translates to:
  /// **'New reviews'**
  String get hostsHostAnalyticsLabelNewReviews;

  /// Product copy used by lib/hosts/presentation/host_operations/host_analytics.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Average rating'**
  String get hostsHostAnalyticsLabelAverageRating;

  /// Product copy used by lib/hosts/presentation/host_operations/host_analytics.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Event saves'**
  String get hostsHostAnalyticsLabelEventSaves;

  /// Product copy used by lib/hosts/presentation/host_operations/host_analytics.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Responses'**
  String get hostsHostAnalyticsLabelResponses;

  /// Section title for concise rules-based host recommendations.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get hostsHostAnalyticsTitleCoach;

  /// Coach suggestion shown when attendance is below sixty percent across at least two events.
  ///
  /// In en, this message translates to:
  /// **'Almost half your bookings didn\'\'t show. Reminders and check-in help — see how your last event ran.'**
  String get hostsHostAnalyticsCoachAttendance;

  /// Coach suggestion shown when checkout drop-off is at least thirty percent.
  ///
  /// In en, this message translates to:
  /// **'Lots of people started paying and stopped. Review your price or enable demand pricing.'**
  String get hostsHostAnalyticsCoachCheckoutDropoff;

  /// Coach suggestion shown when event demand is at least twice bookings.
  ///
  /// In en, this message translates to:
  /// **'Demand outran capacity on {event}. Consider a bigger venue or a second date.'**
  String hostsHostAnalyticsCoachDemandCapacity({required String event});

  /// Coach suggestion shown when no repeat attendee appears across at least three events.
  ///
  /// In en, this message translates to:
  /// **'No repeat attendees this period. Organizer posts and follows help people come back.'**
  String get hostsHostAnalyticsCoachNoRepeatAttendees;

  /// Product copy used by lib/hosts/presentation/host_operations/host_auth_required_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get hostsHostAuthRequiredScreenTitleSignInRequired;

  /// Product copy used by lib/hosts/presentation/host_operations/host_auth_required_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage host operations.'**
  String get hostsHostAuthRequiredScreenMessageSignInToManage;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_edit_tab.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get hostsHostClubProfileTitleIdentity;

  /// Section title for club logo and photo editing in the organizer workspace.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get hostsHostClubProfileTitleMedia;

  /// Club photo count shown in the organizer Media section header.
  ///
  /// In en, this message translates to:
  /// **'{completedCount} of {maximumClubPhotoCount} added'**
  String
  hostsHostClubProfileVisiblecopyCompletedcountOfMaximumclubphotocountAdded({
    required Object completedCount,
    required Object maximumClubPhotoCount,
  });

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_edit_tab.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Organizer name'**
  String get hostsHostClubProfileLabelClubName;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_edit_tab.dart (label).
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get hostsHostClubProfileLabelCity;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_edit_tab.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Area / neighbourhood'**
  String get hostsHostClubProfileLabelAreaNeighbourhood;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_edit_tab.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get hostsHostClubProfileLabelDescription;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_edit_tab.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get hostsHostClubProfileTitleContact;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_edit_tab.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get hostsHostClubProfileLabelInstagram;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_edit_tab.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'@yourclub'**
  String get hostsHostClubProfilePlaceholderYourclub;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_edit_tab.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get hostsHostClubProfileLabelPhone;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_edit_tab.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get hostsHostClubProfileLabelEmail;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_edit_tab.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'hello@yourclub.com'**
  String get hostsHostClubProfilePlaceholderHelloYourclubCom;

  /// Section heading for organizer configuration destinations.
  ///
  /// In en, this message translates to:
  /// **'Organizer settings'**
  String get hostsHostClubEditTabTitleClubSettings;

  /// Navigation row to club event defaults.
  ///
  /// In en, this message translates to:
  /// **'Event defaults'**
  String get hostsHostClubEditTabLabelEventDefaults;

  /// Navigation row to club live event guide defaults.
  ///
  /// In en, this message translates to:
  /// **'Live event guide'**
  String get hostsHostClubEditTabLabelLiveEventGuide;

  /// Navigation row to club payment setup.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get hostsHostClubEditTabLabelPayments;

  /// Navigation row to club host team management.
  ///
  /// In en, this message translates to:
  /// **'Host team'**
  String get hostsHostClubEditTabLabelHostTeam;

  /// Enabled value for organizer configuration rows.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get hostsHostClubEditTabValueOn;

  /// Disabled value for organizer configuration rows.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get hostsHostClubEditTabValueOff;

  /// Host count shown on the host team navigation row.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 host} other{{count} hosts}}'**
  String hostsHostClubEditTabValueHostCount({required int count});

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_edit_tab.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Default activity'**
  String get hostsHostClubProfileTitleDefaultActivity;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_edit_tab.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Admission'**
  String get hostsHostClubProfileTitleAdmission;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_edit_tab.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Age range'**
  String get hostsHostClubProfileTitleAgeRange;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_edit_tab.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Cancellation policy'**
  String get hostsHostClubProfileTitleCancellationPolicy;

  /// Product copy used by lib/hosts/presentation/host_operations/host_clubs_scaffold.dart (kicker).
  ///
  /// In en, this message translates to:
  /// **'HOST ORGANIZERS'**
  String get hostsHostClubsScaffoldKickerHostClubs;

  /// Accessibility label for the Host Clubs tabbed workspace.
  ///
  /// In en, this message translates to:
  /// **'Organizer workspace tabs'**
  String get hostsHostClubsScaffoldLabelClubWorkspaceTabs;

  /// Accessibility hint for switching Host Clubs workspace pages.
  ///
  /// In en, this message translates to:
  /// **'Drag left or right to switch between Edit, Insights, and Preview.'**
  String get hostsHostClubsScaffoldBodyDragLeftOrRight;

  /// Product copy used by lib/hosts/presentation/host_operations/host_clubs_scaffold.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get hostsHostClubsScaffoldLabelEdit;

  /// Product copy used by lib/hosts/presentation/host_operations/host_clubs_scaffold.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get hostsHostClubsScaffoldLabelInsights;

  /// Product copy used by lib/hosts/presentation/host_operations/host_clubs_scaffold.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get hostsHostClubsScaffoldLabelPreview;

  /// Product copy used by lib/hosts/presentation/host_operations/host_clubs_scaffold.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Switch organizer'**
  String get hostsHostClubsScaffoldTooltipSwitchClub;

  /// Product copy used by lib/hosts/presentation/host_operations/host_clubs_scaffold.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No hosted organizers yet'**
  String get hostsHostClubsScaffoldTitleNoHostClubsYet;

  /// Product copy used by lib/hosts/presentation/host_operations/host_clubs_scaffold.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Create an organizer or accept a host invite to start managing events.'**
  String get hostsHostClubsScaffoldBodyCreateAClubOr;

  /// Product copy used by lib/hosts/presentation/host_operations/host_clubs_scaffold.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Create organizer'**
  String get hostsHostClubsScaffoldLabelCreateClub;

  /// Product copy used by lib/hosts/presentation/host_operations/host_clubs_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Organizers'**
  String get hostsHostClubsScreenTitleClubs;

  /// Product copy used by lib/hosts/presentation/host_operations/host_events_list.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get hostsHostEventsListTextEvents;

  /// Product copy used by lib/hosts/presentation/host_operations/host_events_list.dart (label).
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get hostsHostEventsListLabelNewEvent;

  /// Product copy used by lib/hosts/presentation/host_operations/host_events_list.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get hostsHostEventsListTextLive;

  /// Product copy used by lib/hosts/presentation/host_operations/host_events_list.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get hostsHostEventsListTextToday;

  /// Product copy used by lib/hosts/presentation/host_operations/host_events_scaffold.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Create your first organizer'**
  String get hostsHostEventsScaffoldTitleCreateYourFirstClub;

  /// Product copy used by lib/hosts/presentation/host_operations/host_events_scaffold.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Create an organizer to publish events, manage attendees, and run Event Success.'**
  String get hostsHostEventsScaffoldBodyCreateAClubTo;

  /// Product copy used by lib/hosts/presentation/host_operations/host_events_scaffold.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Create organizer'**
  String get hostsHostEventsScaffoldLabelCreateClub;

  /// Product copy used by lib/hosts/presentation/host_operations/host_operations_home_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Host events'**
  String get hostsHostOperationsHomeScreenTitleHostEvents;

  /// Product copy used by lib/hosts/presentation/host_operations/host_organizer.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get hostsHostOrganizerLabelMembers;

  /// Product copy used by lib/hosts/presentation/host_operations/host_organizer.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Rating · {reviewCount} reviews'**
  String hostsHostOrganizerLabelRatingReviewcountReviews({
    required Object reviewCount,
  });

  /// Product copy used by lib/hosts/presentation/host_operations/host_organizer.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get hostsHostOrganizerLabelRating;

  /// Product copy used by lib/hosts/presentation/host_operations/host_organizer.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Events hosted'**
  String get hostsHostOrganizerLabelEventsHosted;

  /// Product copy used by lib/hosts/presentation/host_operations/host_organizer.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get hostsHostOrganizerLabelUpcoming;

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No active events yet'**
  String get hostsHostTodayTitleNoActiveEventsYet;

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Create an event for {name} to start filling the host dashboard.'**
  String hostsHostTodayBodyCreateAnEventFor({required Object name});

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (label).
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get hostsHostTodayLabelNewEvent;

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get hostsHostTodayLabelEvents;

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Needs you'**
  String get hostsHostTodayTitleNeedsYou;

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Nothing needs you right now.'**
  String get hostsHostTodayTextNothingNeedsYouRight;

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Later this week'**
  String get hostsHostTodayTitleLaterThisWeek;

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (label).
  ///
  /// In en, this message translates to:
  /// **'All events'**
  String get hostsHostTodayLabelAllEvents;

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{longWeekday} {daypart}'**
  String hostsHostTodayTextLongweekdayDaypart({
    required Object longWeekday,
    required Object daypart,
  });

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Good {daypart},\n{hostName}'**
  String hostsHostTodayTextGoodDaypartHostname({
    required Object daypart,
    required Object hostName,
  });

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Switch organizer'**
  String get hostsHostTodayTooltipSwitchClub;

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{eventDayLabel} · {time}'**
  String hostsHostTodayTextEventdaylabelTime({
    required Object eventDayLabel,
    required Object time,
  });

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Going'**
  String get hostsHostTodayLabelGoing;

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get hostsHostTodayLabelWaiting;

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Needs you'**
  String get hostsHostTodayLabelNeedsYou;

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Open run-of-show'**
  String get hostsHostTodayLabelOpenRunOfShow;

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Set up & run'**
  String get hostsHostTodayLabelSetUpRun;

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (label).
  ///
  /// In en, this message translates to:
  /// **'D'**
  String get hostsHostTodayLabelD;

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (label).
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get hostsHostTodayLabelM;

  /// Product copy used by lib/core/widgets/block_user_dialog.dart (message).
  ///
  /// In en, this message translates to:
  /// **'You will stop seeing each other in chats, matches, Catches, and future event slots where the other person is already booked.'**
  String get coreBlockUserDialogMessageYouWillStopSeeing;

  /// Product copy used by lib/core/widgets/catch_framework_error_view.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'This screen hit a temporary app error. Please go back or try again in a moment.'**
  String get coreCatchFrameworkErrorViewTextThisScreenHitA;

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{shortWeekday}, {day} {shortMonth} · {timeRangeLabel}'**
  String dashboardEventFocusRailLabelShortweekdayDayShortmonthTimerangelabel({
    required Object shortWeekday,
    required Object day,
    required Object shortMonth,
    required Object timeRangeLabel,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'ADMIT ONE - NO {padLeft} / {capacity}'**
  String eventSuccessEventSuccessCompanionSharedLabelAdmitOneNoPadleft({
    required Object padLeft,
    required Object capacity,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_wingman.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'this attendee'**
  String get eventSuccessEventSuccessCompanionWingmanTextThisAttendee;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (body).
  ///
  /// In en, this message translates to:
  /// **'The post-event report appears once checked-in attendees share feedback. There is no signal to summarize yet.'**
  String get eventSuccessEventSuccessHostReportBodyThePostEventReport;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_report.dart (title).
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get eventSuccessEventSuccessHostReportTitleS;

  /// Product copy used by lib/events/presentation/widgets/booking_conflict_sheet.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'You\'\'re already booked for something then. Keep both if you can make it work, or swap one out.'**
  String get eventsBookingConflictSheetTextYouReAlreadyBooked;

  /// Product copy used by lib/explore/presentation/explore_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Try another city from the location control, or create the first organizer when you are ready to host.'**
  String get exploreExploreScreenMessageTryAnotherCityFrom;

  /// Product copy used by lib/explore/presentation/widgets/explore_list.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Try another city from the location control, or create the first organizer when you are ready to host.'**
  String get exploreExploreListMessageTryAnotherCityFrom;

  /// Product copy used by lib/force_update/presentation/update_required_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'A new version of Catch is available. Please update to continue.'**
  String get forceUpdateUpdateRequiredScreenTextANewVersionOf;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_tools.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{signedUpCount}/{capacityLimit} booked · {waitlistCount} waitlist'**
  String hostsHostEventToolsLabelSignedupcountCapacitylimitBookedWaitlistcount({
    required Object signedUpCount,
    required Object capacityLimit,
    required Object waitlistCount,
  });

  /// Product copy used by lib/onboarding/presentation/pages/welcome_page.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Show up to something you\'\'d do anyway — a long run, a long table, trivia night. Match only with the people who were actually there.'**
  String get onboardingWelcomePageTextShowUpToSomething;

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'{longDateLabel} · {timeRangeLabel} · {locationName}. {priceInPaise} · {capacityLimit} spots.'**
  String
  paymentsPaymentConfirmationScreenTextLongdatelabelTimerangelabelLocationnamePriceinpaise({
    required Object longDateLabel,
    required Object timeRangeLabel,
    required Object locationName,
    required Object priceInPaise,
    required Object capacityLimit,
  });

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'{providerLabel} did not complete this booking. If money moved, it stays visible in payment history while support resolves it.'**
  String paymentsPaymentConfirmationScreenMessageProviderlabelDidNotComplete({
    required Object providerLabel,
  });

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Finish payment in {providerLabel}. Your spot is reserved only after {providerLabel2} confirms the payment and Catch writes the booking.'**
  String paymentsPaymentConfirmationScreenMessageFinishPaymentInProviderlabel({
    required Object providerLabel,
    required Object providerLabel2,
  });

  /// Product copy used by lib/payments/presentation/payment_confirmation_screen.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Bring a water bottle and arrive by the meeting time. Catches unlock automatically when the event finishes — keep your phone charged.'**
  String get paymentsPaymentConfirmationScreenTextBringAWaterBottle;

  /// Product copy used by lib/safety/presentation/settings_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This removes your public profile, signs you out, and keeps only the minimal records required for safety and payment history.'**
  String get safetySettingsScreenMessageThisRemovesYourPublic;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingOnboardingStepTitleWelcome;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'What\'\'s your name?'**
  String get onboardingOnboardingStepTitleWhatSYourName;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Last name stays private until you catch.'**
  String get onboardingOnboardingStepSubtitleLastNameStaysPrivate;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'How do you identify?'**
  String get onboardingOnboardingStepTitleHowDoYouIdentify;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Your Instagram'**
  String get onboardingOnboardingStepTitleYourInstagram;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Helps us verify you for early access. Your handle is never shown to other users.'**
  String get onboardingOnboardingStepSubtitleHelpsUsVerifyYou;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Complete your profile for Catches'**
  String get onboardingOnboardingStepTitleCompleteYourProfileFor;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Catches need photos so people can decide who they want to meet. You can still book events with your current details.'**
  String get onboardingOnboardingStepSubtitleCatchesNeedPhotosSo;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Show yourself'**
  String get onboardingOnboardingStepTitleShowYourself;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Add at least 2 photos so others can find you.'**
  String get onboardingOnboardingStepSubtitleAddAtLeast2;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Add prompts to start catching'**
  String get onboardingOnboardingStepTitleAddPromptsToStart;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Prompts give people something real to respond to before you match.'**
  String get onboardingOnboardingStepSubtitlePromptsGivePeopleSomething;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Show your personality'**
  String get onboardingOnboardingStepTitleShowYourPersonality;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Answer 3 prompts to complete your profile.'**
  String get onboardingOnboardingStepSubtitleAnswer3PromptsTo;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Finish your Catches profile'**
  String get onboardingOnboardingStepTitleFinishYourCatchesProfile;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'These are optional, but they help us rank compatible people in Catches.'**
  String get onboardingOnboardingStepSubtitleTheseAreOptionalBut;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Set your run preferences'**
  String get onboardingOnboardingStepTitleSetYourRunPreferences;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'We only ask for these before run events so hosts can plan pace groups and distances.'**
  String get onboardingOnboardingStepSubtitleWeOnlyAskFor;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Your running style'**
  String get onboardingOnboardingStepTitleYourRunningStyle;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (subtitle).
  ///
  /// In en, this message translates to:
  /// **'Help us find compatible running partners.'**
  String get onboardingOnboardingStepSubtitleHelpUsFindCompatible;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get userProfileSelfProfileEditTabStateLabelDisplayName;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get userProfileSelfProfileEditTabStateLabelDateOfBirth;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (body).
  ///
  /// In en, this message translates to:
  /// **'{padLeft}/{padLeft2}/{year}  ({ageOn} years)'**
  String userProfileSelfProfileEditTabStateBodyPadleftPadleft2YearAgeon({
    required Object padLeft,
    required Object padLeft2,
    required Object year,
    required Object ageOn,
  });

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get userProfileSelfProfileEditTabStateLabelGender;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get userProfileSelfProfileEditTabStateLabelPhone;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get userProfileSelfProfileEditTabStateLabelEmail;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get userProfileSelfProfileEditTabStateLabelInstagram;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get userProfileSelfProfileEditTabStateLabelHeight;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get userProfileSelfProfileEditTabStateLabelCity;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Job title'**
  String get userProfileSelfProfileEditTabStateLabelJobTitle;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get userProfileSelfProfileEditTabStateLabelCompany;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get userProfileSelfProfileEditTabStateLabelEducation;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Religion'**
  String get userProfileSelfProfileEditTabStateLabelReligion;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get userProfileSelfProfileEditTabStateLabelLanguages;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Looking for'**
  String get userProfileSelfProfileEditTabStateLabelLookingFor;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Pace range'**
  String get userProfileSelfProfileEditTabStateLabelPaceRange;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Preferred distances'**
  String get userProfileSelfProfileEditTabStateLabelPreferredDistances;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Why I event'**
  String get userProfileSelfProfileEditTabStateLabelWhyIEvent;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Favorite event times'**
  String get userProfileSelfProfileEditTabStateLabelFavoriteEventTimes;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Drinking'**
  String get userProfileSelfProfileEditTabStateLabelDrinking;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Smoking'**
  String get userProfileSelfProfileEditTabStateLabelSmoking;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get userProfileSelfProfileEditTabStateLabelWorkout;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get userProfileSelfProfileEditTabStateLabelDiet;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get userProfileSelfProfileEditTabStateLabelChildren;

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Paid booking unavailable'**
  String get eventsEventDetailScreenStateLabelPaidBookingUnavailable;

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Accept spot'**
  String get eventsEventDetailScreenStateLabelAcceptSpot;

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Accept spot and pay'**
  String get eventsEventDetailScreenStateLabelAcceptSpotAndPay;

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Set run preferences'**
  String get eventsEventDetailScreenStateLabelSetRunPreferences;

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Request to join'**
  String get eventsEventDetailScreenStateLabelRequestToJoin;

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Join waitlist'**
  String get eventsEventDetailScreenStateLabelJoinWaitlist;

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Withdraw request'**
  String get eventsEventDetailScreenStateLabelWithdrawRequest;

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Leave waitlist'**
  String get eventsEventDetailScreenStateLabelLeaveWaitlist;

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'You attended this event'**
  String get eventsEventDetailScreenStateLabelYouAttendedThisEvent;

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'This event has ended'**
  String get eventsEventDetailScreenStateLabelThisEventHasEnded;

  /// Disabled Event Detail dock status for a cancelled event.
  ///
  /// In en, this message translates to:
  /// **'This event was cancelled'**
  String get eventsEventDetailScreenStateLabelEventCancelled;

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Must be {minAge}+ to join'**
  String eventsEventDetailScreenStateLabelMustBeMinageTo({
    required Object minAge,
  });

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Must be {maxAge} or younger'**
  String eventsEventDetailScreenStateLabelMustBeMaxageOr({
    required Object maxAge,
  });

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Invite required'**
  String get eventsEventDetailScreenStateLabelInviteRequired;

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Request required'**
  String get eventsEventDetailScreenStateLabelRequestRequired;

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Spots for your gender are full'**
  String get eventsEventDetailScreenStateLabelSpotsForYourGender;

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Not eligible for this event'**
  String get eventsEventDetailScreenStateLabelNotEligibleForThis;

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Join approved event'**
  String get eventsEventDetailScreenStateLabelJoinApprovedEvent;

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Complete approved booking'**
  String get eventsEventDetailScreenStateLabelCompleteApprovedBooking;

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Join event — {joinCtaAvailabilityLabel}'**
  String eventsEventDetailScreenStateLabelJoinEventJoinctaavailabilitylabel({
    required Object joinCtaAvailabilityLabel,
  });

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Book event'**
  String get eventsEventDetailScreenStateLabelBookEvent;

  /// Disabled Event Detail action when capacity is full and no waitlist is available.
  ///
  /// In en, this message translates to:
  /// **'Event full'**
  String get eventsEventDetailScreenStateLabelEventFull;

  /// Disabled Event Detail action while an event is currently running.
  ///
  /// In en, this message translates to:
  /// **'Event in progress'**
  String get eventsEventDetailScreenStateLabelEventInProgress;

  /// Event Detail action shown to signed-in viewers who need booking profile fields.
  ///
  /// In en, this message translates to:
  /// **'Complete booking profile'**
  String get eventsEventDetailScreenLabelCompleteBookingProfile;

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get eventsEventDetailScreenStateLabelCancelBooking;

  /// Product copy used by lib/core/widgets/event_activity_visuals.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Social run'**
  String get coreEventActivityVisualsLabelSocialRun;

  /// Product copy used by lib/core/widgets/event_activity_visuals.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get coreEventActivityVisualsLabelRunning;

  /// Product copy used by lib/core/widgets/event_activity_visuals.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get coreEventActivityVisualsLabelWalking;

  /// Product copy used by lib/core/widgets/event_activity_visuals.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Pickleball'**
  String get coreEventActivityVisualsLabelPickleball;

  /// Product copy used by lib/core/widgets/event_activity_visuals.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Padel'**
  String get coreEventActivityVisualsLabelPadel;

  /// Product copy used by lib/core/widgets/event_activity_visuals.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Tennis'**
  String get coreEventActivityVisualsLabelTennis;

  /// Product copy used by lib/core/widgets/event_activity_visuals.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Badminton'**
  String get coreEventActivityVisualsLabelBadminton;

  /// Product copy used by lib/core/widgets/event_activity_visuals.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get coreEventActivityVisualsLabelCycling;

  /// Product copy used by lib/core/widgets/event_activity_visuals.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Spin class'**
  String get coreEventActivityVisualsLabelSpinClass;

  /// Product copy used by lib/core/widgets/event_activity_visuals.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get coreEventActivityVisualsLabelYoga;

  /// Product copy used by lib/core/widgets/event_activity_visuals.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get coreEventActivityVisualsLabelStrength;

  /// Product copy used by lib/core/widgets/event_activity_visuals.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get coreEventActivityVisualsLabelDinner;

  /// Product copy used by lib/core/widgets/event_activity_visuals.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Pub quiz'**
  String get coreEventActivityVisualsLabelPubQuiz;

  /// Product copy used by lib/core/widgets/event_activity_visuals.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Bar crawl'**
  String get coreEventActivityVisualsLabelBarCrawl;

  /// Product copy used by lib/core/widgets/event_activity_visuals.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Singles mixer'**
  String get coreEventActivityVisualsLabelSinglesMixer;

  /// Product copy used by lib/core/widgets/event_activity_visuals.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Open format'**
  String get coreEventActivityVisualsLabelOpenFormat;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (body).
  ///
  /// In en, this message translates to:
  /// **'When check-in opens, this screen turns into the live guide for {locationName}.'**
  String eventSuccessEventSuccessCompanionScreenStateBodyWhenCheckInOpens({
    required Object locationName,
  });

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (body).
  ///
  /// In en, this message translates to:
  /// **'One tap tells the host you are in the room and ready for the live flow.'**
  String get eventSuccessEventSuccessCompanionScreenStateBodyOneTapTellsThe;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Find one person, ask one tiny question, and let the room start with permission instead of pressure.'**
  String get eventSuccessEventSuccessCompanionScreenStateBodyFindOnePersonAsk;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Quick answers help Catch shape prompts without turning the event into a form.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateBodyQuickAnswersHelpCatch;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (body).
  ///
  /// In en, this message translates to:
  /// **'The host is pacing the room from live mode.'**
  String get eventSuccessEventSuccessCompanionScreenStateBodyTheHostIsPacing;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Use it if the room needs an easy next line.'**
  String get eventSuccessEventSuccessCompanionScreenStateBodyUseItIfThe;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (body).
  ///
  /// In en, this message translates to:
  /// **'These are light nudges for the current event moment.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateBodyTheseAreLightNudges;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Use it as a nudge into the next interaction, then let the room breathe.'**
  String get eventSuccessEventSuccessCompanionScreenStateBodyUseItAsA;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (body).
  ///
  /// In en, this message translates to:
  /// **'The host controls the timing so the room unlocks together instead of leaking awkwardly.'**
  String get eventSuccessEventSuccessCompanionScreenStateBodyTheHostControlsThe;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Choose someone you want help meeting and the host can use that as live facilitation context.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateBodyChooseSomeoneYouWant;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Keep the useful parts of the room, send private feedback, and use event-specific openers when a match appears.'**
  String get eventSuccessEventSuccessCompanionScreenStateBodyKeepTheUsefulParts;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (body).
  ///
  /// In en, this message translates to:
  /// **'The host is running the room. Your next prompt or reveal appears here when it is time.'**
  String get eventSuccessEventSuccessCompanionScreenStateBodyTheHostIsRunning;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event not found'**
  String get eventSuccessEventSuccessCompanionScreenStateTitleEventNotFound;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This event is no longer available.'**
  String get eventSuccessEventSuccessCompanionScreenStateMessageThisEventIsNo;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get eventSuccessEventSuccessCompanionScreenStateTitleSignInRequired;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Sign in to open your event companion.'**
  String get eventSuccessEventSuccessCompanionScreenStateMessageSignInToOpen;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No booking found'**
  String get eventSuccessEventSuccessCompanionScreenStateTitleNoBookingFound;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Book this event before opening the companion.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateMessageBookThisEventBefore;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Companion not available'**
  String
  get eventSuccessEventSuccessCompanionScreenStateTitleCompanionNotAvailable;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (message).
  ///
  /// In en, this message translates to:
  /// **'The host has not enabled the live event guide for this event yet.'**
  String get eventSuccessEventSuccessCompanionScreenStateMessageTheHostHasNot;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get paymentsPaymentHistoryScreenLabelRefunded;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (detail).
  ///
  /// In en, this message translates to:
  /// **'Booking failed, but your payment was refunded.'**
  String get paymentsPaymentHistoryScreenDetailBookingFailedButYour;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Refund pending'**
  String get paymentsPaymentHistoryScreenLabelRefundPending;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (detail).
  ///
  /// In en, this message translates to:
  /// **'No spot was reserved and the refund needs attention. Please contact support.'**
  String get paymentsPaymentHistoryScreenDetailNoSpotWasReserved;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Booking failed'**
  String get paymentsPaymentHistoryScreenLabelBookingFailed;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (detail).
  ///
  /// In en, this message translates to:
  /// **'No spot was reserved. Refund may still be pending.'**
  String get paymentsPaymentHistoryScreenDetailNoSpotWasReservedd0a580;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paymentsPaymentHistoryScreenLabelPaid;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get paymentsPaymentHistoryScreenLabelFailed;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (detail).
  ///
  /// In en, this message translates to:
  /// **'Your refund needs attention. Please contact support.'**
  String get paymentsPaymentHistoryScreenDetailYourRefundNeedsAttention;

  /// Product copy used by lib/payments/presentation/payment_history_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get paymentsPaymentHistoryScreenLabelPending;

  /// Product copy used by lib/swipes/presentation/swipe_empty_content.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No more attendees'**
  String get swipesSwipeEmptyContentTitleNoMoreAttendees;

  /// Product copy used by lib/swipes/presentation/swipe_empty_content.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Join more events to meet new people'**
  String get swipesSwipeEmptyContentMessageJoinMoreEventsTo;

  /// Product copy used by lib/swipes/presentation/swipe_empty_content.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Catch unavailable'**
  String get swipesSwipeEmptyContentTitleCatchUnavailable;

  /// Product copy used by lib/swipes/presentation/swipe_empty_content.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This event could not be found.'**
  String get swipesSwipeEmptyContentMessageThisEventCouldNot;

  /// Product copy used by lib/swipes/presentation/swipe_empty_content.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get swipesSwipeEmptyContentTitleSignInRequired;

  /// Product copy used by lib/swipes/presentation/swipe_empty_content.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Sign in again to catch fellow attendees.'**
  String get swipesSwipeEmptyContentMessageSignInAgainTo;

  /// Product copy used by lib/swipes/presentation/swipe_empty_content.dart (message).
  ///
  /// In en, this message translates to:
  /// **'You can only catch attendees from events you attended.'**
  String get swipesSwipeEmptyContentMessageYouCanOnlyCatch;

  /// Product copy used by lib/swipes/presentation/swipe_empty_content.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event in progress'**
  String get swipesSwipeEmptyContentTitleEventInProgress;

  /// Product copy used by lib/swipes/presentation/swipe_empty_content.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Catches unlock for 24 hours after the event finishes.'**
  String get swipesSwipeEmptyContentMessageCatchesUnlockFor24;

  /// Product copy used by lib/swipes/presentation/swipe_empty_content.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Catch window closed'**
  String get swipesSwipeEmptyContentTitleCatchWindowClosed;

  /// Product copy used by lib/swipes/presentation/swipe_empty_content.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This event is past the 24-hour catch window.'**
  String get swipesSwipeEmptyContentMessageThisEventIsPast;

  /// Product copy used by lib/reviews/presentation/reviews_history_view_model.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Sign in to see reviews'**
  String get reviewsReviewsHistoryViewModelTitleSignInToSee;

  /// Product copy used by lib/reviews/presentation/reviews_history_view_model.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Your past event reviews will appear here.'**
  String get reviewsReviewsHistoryViewModelMessageYourPastEventReviews;

  /// Product copy used by lib/reviews/presentation/reviews_history_view_model.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Reviews unavailable'**
  String get reviewsReviewsHistoryViewModelTitleReviewsUnavailable;

  /// Product copy used by lib/reviews/presentation/reviews_history_view_model.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Could not load your profile.'**
  String get reviewsReviewsHistoryViewModelMessageCouldNotLoadYour;

  /// Product copy used by lib/reviews/presentation/reviews_history_view_model.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Could not load your reviews.'**
  String get reviewsReviewsHistoryViewModelMessageCouldNotLoadYourb38403;

  /// Product copy used by lib/reviews/presentation/reviews_history_view_model.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get reviewsReviewsHistoryViewModelTitleNoReviewsYet;

  /// Product copy used by lib/reviews/presentation/reviews_history_view_model.dart (message).
  ///
  /// In en, this message translates to:
  /// **'After you review a completed event, it will appear here.'**
  String get reviewsReviewsHistoryViewModelMessageAfterYouReviewA;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get exploreExploreScreenStateLabelMap;

  /// Accessible map-launcher label with the number of mapped events.
  ///
  /// In en, this message translates to:
  /// **'Map, {mappableEventCount, plural, =1 {1 event} other {{mappableEventCount} events}}'**
  String exploreExploreScreenStateSemanticsMapEventCount({
    required int mappableEventCount,
  });

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get exploreExploreScreenStateLabelAny;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'1 km'**
  String get exploreExploreScreenStateLabel1Km;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'3 km'**
  String get exploreExploreScreenStateLabel3Km;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'5 km'**
  String get exploreExploreScreenStateLabel5Km;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'10 km'**
  String get exploreExploreScreenStateLabel10Km;

  /// Explore cover-story CTA for an event the viewer can book after opening its details.
  ///
  /// In en, this message translates to:
  /// **'View and book'**
  String get exploreExploreScreenStateCtaViewAndBook;

  /// Explore cover-story CTA for an event that requires an attendance request.
  ///
  /// In en, this message translates to:
  /// **'View and request'**
  String get exploreExploreScreenStateCtaViewAndRequest;

  /// Explore cover-story CTA for an event whose waitlist can be viewed from details.
  ///
  /// In en, this message translates to:
  /// **'View waitlist'**
  String get exploreExploreScreenStateCtaViewWaitlist;

  /// Explore cover-story CTA for an event that has no immediate booking action.
  ///
  /// In en, this message translates to:
  /// **'View event'**
  String get exploreExploreScreenStateCtaViewEvent;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (actionLabel).
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get exploreExploreScreenStateActionlabelOpen;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (actionLabel).
  ///
  /// In en, this message translates to:
  /// **'No link'**
  String get exploreExploreScreenStateActionlabelNoLink;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (caption).
  ///
  /// In en, this message translates to:
  /// **'Organizer to know'**
  String get exploreExploreScreenStateCaptionClubToKnow;

  /// Eyebrow above the host identity shown on an Explore club polaroid.
  ///
  /// In en, this message translates to:
  /// **'Hosted by'**
  String get exploreExploreScreenStateLabelHostedBy;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No events match this search'**
  String get exploreExploreScreenStateTitleNoEventsMatchThis;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Clear the search and filters to see every upcoming event.'**
  String get exploreExploreScreenStateMessageClearTheSearchAnd;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (actionLabel).
  ///
  /// In en, this message translates to:
  /// **'Clear search and filters'**
  String get exploreExploreScreenStateActionlabelClearSearchAndFilters;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Nothing tonight'**
  String get exploreExploreScreenStateTitleNothingTonight;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (message).
  ///
  /// In en, this message translates to:
  /// **'The next good fit may be over the weekend.'**
  String get exploreExploreScreenStateMessageTheNextGoodFit;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Nothing tomorrow'**
  String get exploreExploreScreenStateTitleNothingTomorrow;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Open up the weekend to catch more event slots.'**
  String get exploreExploreScreenStateMessageOpenUpTheWeekend;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Nothing this weekend'**
  String get exploreExploreScreenStateTitleNothingThisWeekend;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This week has the broader event slate.'**
  String get exploreExploreScreenStateMessageThisWeekHasThe;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (actionLabel).
  ///
  /// In en, this message translates to:
  /// **'See this week'**
  String get exploreExploreScreenStateActionlabelSeeThisWeek;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Nothing this week'**
  String get exploreExploreScreenStateTitleNothingThisWeek;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Remove the time window to see every upcoming event.'**
  String get exploreExploreScreenStateMessageRemoveTheTimeWindow;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (actionLabel).
  ///
  /// In en, this message translates to:
  /// **'See anytime'**
  String get exploreExploreScreenStateActionlabelSeeAnytime;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No upcoming events match this view'**
  String get exploreExploreScreenStateTitleNoUpcomingEventsMatch;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (message).
  ///
  /// In en, this message translates to:
  /// **'Try a different area, a wider distance, or check the organizer directory below.'**
  String get exploreExploreScreenStateMessageTryADifferentArea;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (actionLabel).
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get exploreExploreScreenStateActionlabelClearFilters;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (description).
  ///
  /// In en, this message translates to:
  /// **'This event can stay listed; only people with this code or private link can book.'**
  String get hostsHostEventManageScreenStateDescriptionThisEventCanStay;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (description).
  ///
  /// In en, this message translates to:
  /// **'This event requires an invite, but no host-readable access code was found.'**
  String get hostsHostEventManageScreenStateDescriptionThisEventRequiresAn;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get hostsHostEventManageScreenStateLabelAll;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get hostsHostEventManageScreenStateLabelBooked;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get hostsHostEventManageScreenStateLabelRequests;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Waitlist'**
  String get hostsHostEventManageScreenStateLabelWaitlist;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Slots'**
  String get hostsHostEventManageScreenStateLabelSlots;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (emptyTitle).
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get hostsHostEventManageScreenStateEmptytitleNoMatches;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (emptyTitle).
  ///
  /// In en, this message translates to:
  /// **'Open slots are not people'**
  String get hostsHostEventManageScreenStateEmptytitleOpenSlotsAreNot;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (emptyTitle).
  ///
  /// In en, this message translates to:
  /// **'No participants yet'**
  String get hostsHostEventManageScreenStateEmptytitleNoParticipantsYet;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get hostsHostEventManageScreenStateLabelDue;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get hostsHostEventManageScreenStateLabelIn;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Attended'**
  String get hostsHostEventManageScreenStateLabelAttended;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'No-show'**
  String get hostsHostEventManageScreenStateLabelNoShow;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get hostsHostEventManageScreenStateLabelSetup;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get hostsHostEventManageScreenStateLabelGuests;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get hostsHostEventManageScreenStateLabelLive;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get hostsHostEventManageScreenStateLabelReport;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Offered'**
  String get hostsHostEventManageScreenStateLabelOffered;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get hostsHostEventManageScreenStateLabelAccepted;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get hostsHostEventManageScreenStateLabelRequest;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Wait'**
  String get hostsHostEventManageScreenStateLabelWait;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get hostsHostEventManageScreenStateLabelExpired;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get hostsHostEventManageScreenStateLabelNew;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (action).
  ///
  /// In en, this message translates to:
  /// **'View map'**
  String get eventsEventDetailDesignPrimitivesActionViewMap;

  /// Product copy used by lib/events/presentation/event_detail_information_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'If it fills, spots reopen'**
  String get eventsEventDetailInformationStateTitleIfItFillsSpotsReopen;

  /// Product copy used by lib/events/presentation/event_detail_information_state.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Eligible people are notified together; the first completed booking gets the spot.'**
  String get eventsEventDetailInformationStateBodyEligiblePeopleAreNotified;

  /// Product copy used by lib/events/presentation/event_detail_information_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Host-managed waitlist'**
  String get eventsEventDetailInformationStateTitleHostManagedWaitlist;

  /// Product copy used by lib/events/presentation/event_detail_information_state.dart (body).
  ///
  /// In en, this message translates to:
  /// **'The host reviews waiting requests when capacity opens.'**
  String get eventsEventDetailInformationStateBodyTheHostReviewsWaitingRequests;

  /// Product copy used by lib/events/presentation/event_detail_information_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Variable pricing'**
  String get eventsEventDetailInformationStateTitleVariablePricing;

  /// Product copy used by lib/events/presentation/event_detail_information_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Plans change?'**
  String get eventsEventDetailInformationStateTitlePlansChange;

  /// Product copy used by lib/events/presentation/event_detail_information_state.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Release your spot early so the waitlist can move.'**
  String get eventsEventDetailInformationStateBodyReleaseYourSpotEarly;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (label).
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get eventsEventDetailDesignPrimitivesLabelWhen;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get eventsEventDetailDesignPrimitivesLabelWhere;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'This event is currently full; the waitlist keeps priority order.'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyThisEventIsCurrently;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Only {remaining} {value2} left before sign-ups move to waitlist.'**
  String eventsEventDetailDesignPrimitivesVisiblecopyOnlyRemainingValue2Left({
    required Object remaining,
    required Object value2,
  });

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{spotsLabel} spots are already spoken for.'**
  String eventsEventDetailDesignPrimitivesVisiblecopySpotslabelSpotsAreAlready({
    required Object spotsLabel,
  });

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Gather at {locationName}'**
  String eventsEventDetailDesignPrimitivesTitleGatherAtLocationname({
    required Object locationName,
  });

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (detail).
  ///
  /// In en, this message translates to:
  /// **'Quick hellos, host check-in, and the plan for the group.'**
  String get eventsEventDetailDesignPrimitivesDetailQuickHellosHostCheck;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Wrap up'**
  String get eventsEventDetailDesignPrimitivesTitleWrapUp;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (detail).
  ///
  /// In en, this message translates to:
  /// **'Attendees can linger naturally; private follow-up unlocks after.'**
  String get eventsEventDetailDesignPrimitivesDetailAttendeesCanLingerNaturally;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (title).
  ///
  /// In en, this message translates to:
  /// **'If it fills, a waitlist'**
  String get eventsEventDetailDesignPrimitivesTitleIfItFillsA;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (detail).
  ///
  /// In en, this message translates to:
  /// **'Spots free up in order as capacity changes or people cancel.'**
  String get eventsEventDetailDesignPrimitivesDetailSpotsFreeUpIn;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'The format keeps the pace conversational, with regroup points so nobody gets stranded.'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyTheFormatKeepsThe;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Rotations give you natural one-on-one moments without managing the room yourself.'**
  String
  get eventsEventDetailDesignPrimitivesVisiblecopyRotationsGiveYouNatural;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Team structure creates low-pressure reasons to talk throughout the event.'**
  String
  get eventsEventDetailDesignPrimitivesVisiblecopyTeamStructureCreatesLow;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'A seated format and host cues make the first conversation easier.'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyASeatedFormatAnd;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Host nudges keep the room moving when it needs a little structure.'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyHostNudgesKeepThe;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'The host runs the arc, so you can just show up and follow the moment.'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyTheHostRunsThe;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'The host shapes the format around the room and venue.'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyTheHostShapesThe;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{distanceKm} at a {toLowerCase} pace, with host-led regroup points.'**
  String eventsEventDetailDesignPrimitivesVisiblecopyDistancekmAtATolowercase({
    required Object distanceKm,
    required Object toLowerCase,
  });

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Paired or court-based rotations keep the activity moving and social.'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyPairedOrCourtBased;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Host-led teams and rotations create a clear rhythm for the group.'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyHostLedTeamsAnd;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'A table-led format with built-in prompts and host cues.'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyATableLedFormat;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'A looser mixer with host nudges when the room needs direction.'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyALooserMixerWith;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'A host-led activity with clear arrival, activity, and follow-up moments.'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyAHostLedActivity;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'The host adapts the format to the group and venue.'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyTheHostAdaptsThe;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyPace;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Skill'**
  String get eventsEventDetailDesignPrimitivesVisiblecopySkill;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyIntensity;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyEnergy;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Open sign-up'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyOpenSignUp;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Invite only'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyInviteOnly;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Host approval'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyHostApproval;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Cohort caps'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyCohortCaps;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Balanced singles'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyBalancedSingles;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Members only'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyMembersOnly;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'No approval needed; RSVP until {capacityLimit} spots are filled.'**
  String eventsEventDetailDesignPrimitivesVisiblecopyNoApprovalNeededRsvp({
    required Object capacityLimit,
  });

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Book within total capacity while cohort caps keep the room balanced.'**
  String
  get eventsEventDetailDesignPrimitivesVisiblecopyBookWithinTotalCapacity;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Straight men and women are balanced within a small tolerance; other cohorts book within total capacity.'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyStraightMenAndWomen;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Only attendees with the host invite can book this event.'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyOnlyAttendeesWithThe;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Request a spot first; the host reviews requests before confirming.'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyRequestASpotFirst;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Only active organizer followers can book this event.'**
  String get eventsEventDetailDesignPrimitivesVisiblecopyOnlyActiveClubMembers;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_dock.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'FREE TO JOIN · LEAVE ANYTIME'**
  String get clubsClubDetailDockVisiblecopyFreeToJoinLeave;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_dock.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'MEMBER · MANAGE ANYTIME'**
  String get clubsClubDetailDockVisiblecopyMemberManageAnytime;

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'1 event'**
  String get dashboardEventFocusRailVisiblecopy1Event;

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{length} events'**
  String dashboardEventFocusRailVisiblecopyLengthEvents({
    required Object length,
  });

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Event {value1} of {length}'**
  String dashboardEventFocusRailVisiblecopyEventValue1OfLength({
    required Object value1,
    required Object length,
  });

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Event {selectedIndex} of {length}'**
  String dashboardEventFocusRailVisiblecopyEventSelectedindexOfLength({
    required Object selectedIndex,
    required Object length,
  });

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{value1}/{cardCount}'**
  String dashboardEventFocusRailVisiblecopyValue1Cardcount({
    required Object value1,
    required Object cardCount,
  });

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Set up international payouts'**
  String get hostsHostPaymentAccountCardTitleSetUpInternationalPayouts;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Required before paid non-INR events can accept checkout through Stripe.'**
  String get hostsHostPaymentAccountCardBodyRequiredBeforePaidNon;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (title).
  ///
  /// In en, this message translates to:
  /// **'International checkout is ready'**
  String get hostsHostPaymentAccountCardTitleInternationalCheckoutIsReady;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Non-INR paid bookings can route through Stripe for this host account.'**
  String get hostsHostPaymentAccountCardBodyNonInrPaidBookings;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Stripe needs more information'**
  String get hostsHostPaymentAccountCardTitleStripeNeedsMoreInformation;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Finish the outstanding Stripe requirements to accept payments.'**
  String get hostsHostPaymentAccountCardBodyFinishTheOutstandingStripe;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Stripe onboarding is in progress'**
  String get hostsHostPaymentAccountCardTitleStripeOnboardingIsIn;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Refresh after completing Stripe onboarding to update checkout readiness.'**
  String get hostsHostPaymentAccountCardBodyRefreshAfterCompletingStripe;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_policy_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get hostsCreateEventPolicyStateLabelOpen;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_policy_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'INVITE'**
  String get hostsCreateEventPolicyStateLabelInvite;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_policy_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'REQUEST'**
  String get hostsCreateEventPolicyStateLabelRequest;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_policy_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'BALANCED'**
  String get hostsCreateEventPolicyStateLabelBalanced;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_policy_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Open capacity'**
  String get hostsCreateEventPolicyStateTitleOpenCapacity;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_policy_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Invite only'**
  String get hostsCreateEventPolicyStateTitleInviteOnly;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_policy_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Request to join'**
  String get hostsCreateEventPolicyStateTitleRequestToJoin;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_policy_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Balanced singles'**
  String get hostsCreateEventPolicyStateTitleBalancedSingles;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_empty.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Book a group event'**
  String get dashboardDashboardEmptyTitleBookAGroupEvent;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_empty.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Pick an organizer near you. Pay the fee — or don\'\'t; some are free.'**
  String get dashboardDashboardEmptyBodyPickAClubNear;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_empty.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Actually show up'**
  String get dashboardDashboardEmptyTitleActuallyShowUp;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_empty.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Meet the organizer at the event. No cold matching happens here.'**
  String get dashboardDashboardEmptyBodyMeetTheClubAt;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_empty.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Catch within 24 hours'**
  String get dashboardDashboardEmptyTitleCatchWithin24Hours;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_empty.dart (body).
  ///
  /// In en, this message translates to:
  /// **'You get the roster of who came. Catch anyone who caught your eye.'**
  String get dashboardDashboardEmptyBodyYouGetTheRoster;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_empty.dart (title).
  ///
  /// In en, this message translates to:
  /// **'They catch you back?'**
  String get dashboardDashboardEmptyTitleTheyCatchYouBack;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_empty.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Match. Message. Plan the next event together.'**
  String get dashboardDashboardEmptyBodyMatchMessagePlanThe;

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Remove host?'**
  String get hostsHostTeamManagementSectionTitleRemoveHost;

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Transfer ownership?'**
  String get hostsHostTeamManagementSectionTitleTransferOwnership;

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (message).
  ///
  /// In en, this message translates to:
  /// **'{displayName} will stay an organizer follower but will lose host tools.'**
  String hostsHostTeamManagementSectionMessageDisplaynameWillStayA({
    required Object displayName,
  });

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (message).
  ///
  /// In en, this message translates to:
  /// **'{displayName} will become the organizer owner. You will remain a host.'**
  String hostsHostTeamManagementSectionMessageDisplaynameWillBecomeThe({
    required Object displayName,
  });

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get hostsHostTeamManagementSectionLabelCancel;

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get hostsHostTeamManagementSectionLabelRemove;

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get hostsHostTeamManagementSectionLabelTransfer;

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (successMessage).
  ///
  /// In en, this message translates to:
  /// **'{displayName} removed.'**
  String hostsHostTeamManagementSectionSuccessmessageDisplaynameRemoved({
    required Object displayName,
  });

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (successMessage).
  ///
  /// In en, this message translates to:
  /// **'Ownership transferred to {displayName}.'**
  String
  hostsHostTeamManagementSectionSuccessmessageOwnershipTransferredToDisplayname({
    required Object displayName,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Post-event follow-up opens after attendance is confirmed.'**
  String get eventSuccessEventSuccessCompanionSharedLabelPostEventFollowUp;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Conversation starters stay private to your event context.'**
  String
  get eventSuccessEventSuccessCompanionSharedLabelConversationStartersStayPrivate;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Check in when you reach {locationName}.'**
  String eventSuccessEventSuccessCompanionSharedLabelCheckInWhenYou({
    required Object locationName,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'A small starter group will form when arrivals open.'**
  String get eventSuccessEventSuccessCompanionSharedLabelASmallStarterGroup;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Timed partner rotations as the event unfolds.'**
  String
  get eventSuccessEventSuccessCompanionSharedLabelTimedPartnerRotationsAs;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Conversation cues appear when the room needs an easy opener.'**
  String
  get eventSuccessEventSuccessCompanionSharedLabelConversationCuesAppearWhen;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'One synchronized reveal - every phone at once.'**
  String
  get eventSuccessEventSuccessCompanionSharedLabelOneSynchronizedRevealEvery;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Your guide stays private to your ticket and attendance.'**
  String get eventSuccessEventSuccessCompanionSharedLabelYourGuideStaysPrivate;

  /// Product copy used by lib/swipes/presentation/event_recap_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Catches open until {time}'**
  String swipesEventRecapScreenStateVisiblecopyCatchesOpenUntilTime({
    required Object time,
  });

  /// Product copy used by lib/swipes/presentation/event_recap_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Catch window closed'**
  String get swipesEventRecapScreenStateVisiblecopyCatchWindowClosed;

  /// Product copy used by lib/swipes/presentation/event_recap_screen_state.dart (kicker).
  ///
  /// In en, this message translates to:
  /// **'{toUpperCase} · COMPLETE'**
  String swipesEventRecapScreenStateKickerTouppercaseComplete({
    required Object toUpperCase,
  });

  /// Product copy used by lib/swipes/presentation/event_recap_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{activitySummaryLabel} · {checkedInCount} checked in'**
  String
  swipesEventRecapScreenStateVisiblecopyActivitysummarylabelCheckedincountCheckedIn({
    required Object activitySummaryLabel,
    required Object checkedInCount,
  });

  /// Product copy used by lib/swipes/presentation/event_recap_screen_state.dart (displayName).
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get swipesEventRecapScreenStateDisplaynameGuest;

  /// Product copy used by lib/swipes/presentation/event_recap_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'guest'**
  String get swipesEventRecapScreenStateVisiblecopyGuest;

  /// Product copy used by lib/swipes/presentation/event_recap_screen_state.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Remove {tooltipName}'**
  String swipesEventRecapScreenStateTooltipRemoveTooltipname({
    required Object tooltipName,
  });

  /// Product copy used by lib/swipes/presentation/event_recap_screen_state.dart (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Remember {tooltipName}'**
  String swipesEventRecapScreenStateTooltipRememberTooltipname({
    required Object tooltipName,
  });

  /// Product copy used by lib/explore/presentation/widgets/explore_filter_rail.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Tonight'**
  String get exploreExploreFilterRailLabelTonight;

  /// Product copy used by lib/explore/presentation/widgets/explore_filter_rail.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get exploreExploreFilterRailLabelTomorrow;

  /// Product copy used by lib/explore/presentation/widgets/explore_filter_rail.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Weekend'**
  String get exploreExploreFilterRailLabelWeekend;

  /// Product copy used by lib/explore/presentation/widgets/explore_filter_rail.dart (label).
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get exploreExploreFilterRailLabelThisWeek;

  /// Compact final option in the Explore seven-day date strip.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get exploreExploreFilterRailLabelAny;

  /// Explore date-strip label paired with the current supply count.
  ///
  /// In en, this message translates to:
  /// **'{label} · {count}'**
  String exploreExploreFilterRailDateSupply({
    required Object label,
    required int count,
  });

  /// Explore date-strip label with a lower-bound supply count when more discovery pages exist.
  ///
  /// In en, this message translates to:
  /// **'{label} · {count}+'**
  String exploreExploreFilterRailDateSupplyPlus({
    required Object label,
    required int count,
  });

  /// Product copy used by lib/dashboard/presentation/notifications_list_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Marking...'**
  String get dashboardNotificationsListStateVisiblecopyMarking;

  /// Product copy used by lib/dashboard/presentation/notifications_list_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get dashboardNotificationsListStateVisiblecopyMarkAllRead;

  /// Product copy used by lib/dashboard/presentation/notifications_list_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dashboardNotificationsListStateLabelToday;

  /// Product copy used by lib/dashboard/presentation/notifications_list_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dashboardNotificationsListStateLabelYesterday;

  /// Product copy used by lib/dashboard/presentation/notifications_list_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get dashboardNotificationsListStateLabelThisWeek;

  /// Product copy used by lib/dashboard/presentation/notifications_list_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get dashboardNotificationsListStateLabelEarlier;

  /// Product copy used by lib/dashboard/presentation/notifications_list_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get dashboardNotificationsListStateVisiblecopyNow;

  /// Product copy used by lib/dashboard/presentation/notifications_list_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{inMinutes}m'**
  String dashboardNotificationsListStateVisiblecopyInminutesM({
    required Object inMinutes,
  });

  /// Product copy used by lib/dashboard/presentation/notifications_list_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{inHours}h'**
  String dashboardNotificationsListStateVisiblecopyInhoursH({
    required Object inHours,
  });

  /// Product copy used by lib/dashboard/presentation/notifications_list_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{inDays}d'**
  String dashboardNotificationsListStateVisiblecopyIndaysD({
    required Object inDays,
  });

  /// Product copy used by lib/onboarding/presentation/pages/name_dob_page_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get onboardingNameDobPageStateVisiblecopyDateOfBirth;

  /// Product copy used by lib/onboarding/presentation/pages/name_dob_page_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get onboardingNameDobPageStateVisiblecopyFirstName;

  /// Product copy used by lib/onboarding/presentation/pages/name_dob_page_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get onboardingNameDobPageStateVisiblecopyLastName;

  /// Product copy used by lib/swipes/shared/profile_surface/profile_view_mapper.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Profile signals'**
  String get swipesProfileViewMapperTitleProfileSignals;

  /// Product copy used by lib/swipes/shared/profile_surface/profile_view_mapper.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Why you might click'**
  String get swipesProfileViewMapperTitleWhyYouMightClick;

  /// Product copy used by lib/swipes/shared/profile_surface/profile_view_mapper.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get swipesProfileViewMapperTitleDetails;

  /// Product copy used by lib/swipes/shared/profile_surface/profile_view_mapper.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get swipesProfileViewMapperTitleLifestyle;

  /// Product copy used by lib/hosts/presentation/host_operations/host_clubs_scaffold.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get hostsHostClubsScaffoldVisiblecopyOwner;

  /// Product copy used by lib/hosts/presentation/host_operations/host_clubs_scaffold.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Host team'**
  String get hostsHostClubsScaffoldVisiblecopyHostTeam;

  /// Product copy used by lib/hosts/presentation/host_operations/host_clubs_scaffold.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{name} · {roleLabel}'**
  String hostsHostClubsScaffoldLabelNameRolelabel({
    required Object name,
    required Object roleLabel,
  });

  /// Product copy used by lib/event_success/presentation/event_success_questionnaire_config_editor.dart (prompt).
  ///
  /// In en, this message translates to:
  /// **'Custom question {questionNumber}'**
  String
  eventSuccessEventSuccessQuestionnaireConfigEditorPromptCustomQuestionQuestionnumber({
    required Object questionNumber,
  });

  /// Product copy used by lib/event_success/presentation/event_success_questionnaire_config_editor.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Option 1'**
  String get eventSuccessEventSuccessQuestionnaireConfigEditorLabelOption1;

  /// Product copy used by lib/event_success/presentation/event_success_questionnaire_config_editor.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Option 2'**
  String get eventSuccessEventSuccessQuestionnaireConfigEditorLabelOption2;

  /// Product copy used by lib/event_success/presentation/event_success_questionnaire_config_editor.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Option 3'**
  String get eventSuccessEventSuccessQuestionnaireConfigEditorLabelOption3;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_tools.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Manage event'**
  String get hostsHostEventToolsLabelManageEvent;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_tools.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Take attendance'**
  String get hostsHostEventToolsLabelTakeAttendance;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_tools.dart (label).
  ///
  /// In en, this message translates to:
  /// **'View report'**
  String get hostsHostEventToolsLabelViewReport;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_tools.dart (badgeLabel).
  ///
  /// In en, this message translates to:
  /// **'Attendance open'**
  String get hostsHostEventToolsBadgelabelAttendanceOpen;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_tools.dart (badgeLabel).
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get hostsHostEventToolsBadgelabelUpcoming;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_tools.dart (badgeLabel).
  ///
  /// In en, this message translates to:
  /// **'Attendance closed'**
  String get hostsHostEventToolsBadgelabelAttendanceClosed;

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get hostsHostBroadcastComposerSheetLabelReminder;

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Meeting point'**
  String get hostsHostBroadcastComposerSheetLabelMeetingPoint;

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get hostsHostBroadcastComposerSheetLabelChange;

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (description).
  ///
  /// In en, this message translates to:
  /// **'Confirm timing and help everyone arrive ready.'**
  String get hostsHostBroadcastComposerSheetDescriptionConfirmTimingAndHelp;

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (description).
  ///
  /// In en, this message translates to:
  /// **'Share arrival notes, parking, or table details.'**
  String get hostsHostBroadcastComposerSheetDescriptionShareArrivalNotesParking;

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (description).
  ///
  /// In en, this message translates to:
  /// **'Call out an important update to the plan.'**
  String get hostsHostBroadcastComposerSheetDescriptionCallOutAnImportant;

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (bodyFor).
  ///
  /// In en, this message translates to:
  /// **'Reminder for {title}: doors open shortly before the start. See you there!'**
  String hostsHostBroadcastComposerSheetBodyforReminderForTitleDoors({
    required Object title,
  });

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (bodyFor).
  ///
  /// In en, this message translates to:
  /// **'We are meeting at {locationName}. Please arrive a few minutes early.'**
  String hostsHostBroadcastComposerSheetBodyforWeAreMeetingAt({
    required Object locationName,
  });

  /// Product copy used by lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart (bodyFor).
  ///
  /// In en, this message translates to:
  /// **'Quick update for {title}:'**
  String hostsHostBroadcastComposerSheetBodyforQuickUpdateForTitle({
    required Object title,
  });

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_body.dart (label).
  ///
  /// In en, this message translates to:
  /// **'followers'**
  String get clubsClubDetailBodyLabelMembers;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_body.dart (label).
  ///
  /// In en, this message translates to:
  /// **'rating'**
  String get clubsClubDetailBodyLabelRating;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_body.dart (label).
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get clubsClubDetailBodyLabelReviews;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_body.dart (label).
  ///
  /// In en, this message translates to:
  /// **'est.'**
  String get clubsClubDetailBodyLabelEst;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'A {distanceKm} {toLowerCase} at a {toLowerCase2} pace from {locationName}.'**
  String eventsEventDetailOverviewSectionVisiblecopyADistancekmTolowercaseAt({
    required Object distanceKm,
    required Object toLowerCase,
    required Object toLowerCase2,
    required Object locationName,
  });

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'A hosted {toLowerCase} built around a clear arrival, shared activity, and low-pressure follow-up.'**
  String eventsEventDetailOverviewSectionVisiblecopyAHostedTolowercaseBuilt({
    required Object toLowerCase,
  });

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Attendance matters'**
  String get eventsEventDetailOverviewSectionTitleAttendanceMatters;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Check-in or host-marked attendance decides who can use post-event follow-up and feedback.'**
  String get eventsEventDetailOverviewSectionBodyCheckInOrHost;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{toStringAsFixed} km {toLowerCase} {toLowerCase2}'**
  String
  eventsEventDetailOverviewSectionVisiblecopyTostringasfixedKmTolowercaseTolowercase2({
    required Object toStringAsFixed,
    required Object toLowerCase,
    required Object toLowerCase2,
  });

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Arrive ready for the listed pace and route. The host may split attendees into smaller groups if the crowd needs structure.'**
  String get eventsEventDetailOverviewSectionVisiblecopyArriveReadyForThe;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Expect paired or court-based rotations so attendees can meet more people without managing the logistics themselves.'**
  String get eventsEventDetailOverviewSectionVisiblecopyExpectPairedOrCourt;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Expect team structure and host-led moments that create natural reasons to talk.'**
  String get eventsEventDetailOverviewSectionVisiblecopyExpectTeamStructureAnd;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Expect a seated format with table-level structure and host cues for easier conversation.'**
  String get eventsEventDetailOverviewSectionVisiblecopyExpectASeatedFormat;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Expect a looser social format with host nudges when the room needs more mixing.'**
  String get eventsEventDetailOverviewSectionVisiblecopyExpectALooserSocial;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Expect a host-led activity with clear arrival, activity, and follow-up moments.'**
  String get eventsEventDetailOverviewSectionVisiblecopyExpectAHostLed;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Expect the host to shape the format around the room and venue.'**
  String get eventsEventDetailOverviewSectionVisiblecopyExpectTheHostTo;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Price can change based on live demand.'**
  String get eventsEventDetailOverviewSectionVisiblecopyPriceCanChangeBased;

  /// Product copy used by lib/events/presentation/widgets/event_detail_overview_section.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Price can increase by {step} per demand step, capped at {max} above the base price.'**
  String eventsEventDetailOverviewSectionVisiblecopyPriceCanIncreaseBy({
    required Object step,
    required Object max,
  });

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (label).
  ///
  /// In en, this message translates to:
  /// **'View event'**
  String get dashboardEventFocusRailLabelViewEvent;

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get dashboardEventFocusRailLabelCheckIn;

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get dashboardEventFocusRailLabelDirections;

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Add to calendar'**
  String get dashboardEventFocusRailLabelAddToCalendar;

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Start catching'**
  String get dashboardEventFocusRailLabelStartCatching;

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Write review'**
  String get dashboardEventFocusRailLabelWriteReview;

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (badgeLabel).
  ///
  /// In en, this message translates to:
  /// **'Check-in open'**
  String get dashboardEventFocusRailBadgelabelCheckInOpen;

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (badgeLabel).
  ///
  /// In en, this message translates to:
  /// **'After the event'**
  String get dashboardEventFocusRailBadgelabelAfterTheEvent;

  /// Product copy used by lib/dashboard/presentation/widgets/event_focus_rail.dart (badgeLabel).
  ///
  /// In en, this message translates to:
  /// **'Next event'**
  String get dashboardEventFocusRailBadgelabelNextEvent;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_dock.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Sign in to follow'**
  String get clubsClubDetailDockLabelSignInToJoin;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_dock.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Follow organizer'**
  String get clubsClubDetailDockLabelJoinClub;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_dock.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get clubsClubDetailDockLabelJoined;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_dock.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get clubsClubDetailDockLabelManage;

  /// Product copy used by lib/clubs/presentation/detail/widgets/club_detail_dock.dart (label).
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get clubsClubDetailDockLabelNewEvent;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get hostsHostEventAttendancePanelLabelAccepted;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Offered'**
  String get hostsHostEventAttendancePanelLabelOffered;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get hostsHostEventAttendancePanelLabelOffer;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get hostsHostEventAttendancePanelLabelProfile;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (label).
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get hostsClubHostDefaultsStepLabelOpen;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (label).
  ///
  /// In en, this message translates to:
  /// **'INVITE'**
  String get hostsClubHostDefaultsStepLabelInvite;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (label).
  ///
  /// In en, this message translates to:
  /// **'BALANCED'**
  String get hostsClubHostDefaultsStepLabelBalanced;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (description).
  ///
  /// In en, this message translates to:
  /// **'Anyone eligible can book until the event reaches capacity.'**
  String get hostsClubHostDefaultsStepDescriptionAnyoneEligibleCanBook;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (description).
  ///
  /// In en, this message translates to:
  /// **'New invite-only events will ask for an event-specific code.'**
  String get hostsClubHostDefaultsStepDescriptionNewInviteOnlyEvents;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (description).
  ///
  /// In en, this message translates to:
  /// **'Straight men and women are kept within one spot of each other.'**
  String get hostsClubHostDefaultsStepDescriptionStraightMenAndWomen;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart (description).
  ///
  /// In en, this message translates to:
  /// **'New events start open with optional straight men and straight women caps.'**
  String get hostsClubHostDefaultsStepDescriptionNewEventsStartOpen;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_policy_state.dart (description).
  ///
  /// In en, this message translates to:
  /// **'Anyone eligible can book until the event reaches capacity.'**
  String get hostsCreateEventPolicyStateDescriptionAnyoneEligibleCanBook;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_policy_state.dart (description).
  ///
  /// In en, this message translates to:
  /// **'Only people with the invite code or private link can book. Waitlist is off by default.'**
  String get hostsCreateEventPolicyStateDescriptionOnlyPeopleWithThe;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_policy_state.dart (description).
  ///
  /// In en, this message translates to:
  /// **'People request a spot first. The host reviews their public profile before confirming who gets in.'**
  String get hostsCreateEventPolicyStateDescriptionPeopleRequestASpot;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_policy_state.dart (description).
  ///
  /// In en, this message translates to:
  /// **'Straight men and women are kept within one spot of each other. Queer, open, non-binary, and other attendees can book within total capacity.'**
  String get hostsCreateEventPolicyStateDescriptionStraightMenAndWomen;

  /// Product copy used by lib/events/presentation/calendar/calendar_screen_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'No planned events yet'**
  String get eventsCalendarScreenStateTitleNoPlannedEventsYet;

  /// Product copy used by lib/events/presentation/calendar/calendar_screen_state.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Events you book or save will show up here by day and time.'**
  String get eventsCalendarScreenStateBodyEventsYouBookOr;

  /// Product copy used by lib/events/presentation/calendar/calendar_screen_state.dart (badgeLabel).
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get eventsCalendarScreenStateBadgelabelCancelled;

  /// Product copy used by lib/events/presentation/calendar/calendar_screen_state.dart (badgeLabel).
  ///
  /// In en, this message translates to:
  /// **'SAVED'**
  String get eventsCalendarScreenStateBadgelabelSaved;

  /// Product copy used by lib/events/presentation/calendar/calendar_screen_state.dart (badgeLabel).
  ///
  /// In en, this message translates to:
  /// **'JOINED'**
  String get eventsCalendarScreenStateBadgelabelJoined;

  /// Product copy used by lib/hosts/presentation/host_home_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Repeat last'**
  String get hostsHostHomeScreenStateVisiblecopyRepeatLast;

  /// Product copy used by lib/hosts/presentation/host_home_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Repeat ‘{label}’'**
  String hostsHostHomeScreenStateVisiblecopyRepeatLabel({
    required Object label,
  });

  /// Product copy used by lib/hosts/presentation/host_home_screen_state.dart (emptyTitle).
  ///
  /// In en, this message translates to:
  /// **'No upcoming events'**
  String get hostsHostHomeScreenStateEmptytitleNoUpcomingEvents;

  /// Product copy used by lib/hosts/presentation/host_home_screen_state.dart (emptyTitle).
  ///
  /// In en, this message translates to:
  /// **'Nothing live right now'**
  String get hostsHostHomeScreenStateEmptytitleNothingLiveRightNow;

  /// Product copy used by lib/hosts/presentation/host_home_screen_state.dart (emptyTitle).
  ///
  /// In en, this message translates to:
  /// **'No past events yet'**
  String get hostsHostHomeScreenStateEmptytitleNoPastEventsYet;

  /// Product copy used by lib/hosts/presentation/host_home_screen_state.dart (emptyBody).
  ///
  /// In en, this message translates to:
  /// **'Create your next event to start filling this list.'**
  String get hostsHostHomeScreenStateEmptybodyCreateYourNextEvent;

  /// Product copy used by lib/hosts/presentation/host_home_screen_state.dart (emptyBody).
  ///
  /// In en, this message translates to:
  /// **'Your next event appears here when it starts.'**
  String get hostsHostHomeScreenStateEmptybodyYourNextEventAppears;

  /// Product copy used by lib/hosts/presentation/host_home_screen_state.dart (emptyBody).
  ///
  /// In en, this message translates to:
  /// **'Completed events and their attendance will appear here.'**
  String get hostsHostHomeScreenStateEmptybodyCompletedEventsAndTheir;

  /// Product copy used by lib/hosts/presentation/host_home_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{spotsRemaining} spots open'**
  String hostsHostHomeScreenStateVisiblecopySpotsremainingSpotsOpen({
    required Object spotsRemaining,
  });

  /// Product copy used by lib/hosts/presentation/host_home_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'event full'**
  String get hostsHostHomeScreenStateVisiblecopyEventFull;

  /// Product copy used by lib/hosts/presentation/host_home_screen_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Review waitlist'**
  String get hostsHostHomeScreenStateTitleReviewWaitlist;

  /// Product copy used by lib/hosts/presentation/host_home_screen_state.dart (body).
  ///
  /// In en, this message translates to:
  /// **'{title}\n{waitlistCount} waiting · {availability}'**
  String hostsHostHomeScreenStateBodyTitleWaitlistcountWaitingAvailability({
    required Object title,
    required Object waitlistCount,
    required Object availability,
  });

  /// Product copy used by lib/hosts/presentation/host_home_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get hostsHostHomeScreenStateVisiblecopyReview;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Live prompt'**
  String get eventSuccessEventSuccessConversationCueCopyLabelLivePrompt;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Post-match opener'**
  String get eventSuccessEventSuccessConversationCueCopyLabelPostMatchOpener;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Shared room'**
  String get eventSuccessEventSuccessConversationCueCopyTitleSharedRoom;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'I am glad we both made it to {label}.'**
  String eventSuccessEventSuccessConversationCueCopyBodyIAmGladWe({
    required Object label,
  });

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Easy follow-up'**
  String get eventSuccessEventSuccessConversationCueCopyTitleEasyFollowUp;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'What was your favorite moment from the event?'**
  String get eventSuccessEventSuccessConversationCueCopyBodyWhatWasYourFavorite;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Low pressure'**
  String get eventSuccessEventSuccessConversationCueCopyVisiblecopyLowPressure;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Ask someone what route, cafe, or park they would do again.'**
  String get eventSuccessEventSuccessConversationCueCopyBodyAskSomeoneWhatRoute;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Ask your next partner what shot they are trying to improve.'**
  String get eventSuccessEventSuccessConversationCueCopyBodyAskYourNextPartner;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Ask what kind of ride they want to do next.'**
  String get eventSuccessEventSuccessConversationCueCopyBodyAskWhatKindOf;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Ask what part of class helped them switch off.'**
  String get eventSuccessEventSuccessConversationCueCopyBodyAskWhatPartOf;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Ask what lift or movement they are working on right now.'**
  String get eventSuccessEventSuccessConversationCueCopyBodyAskWhatLiftOr;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Ask which round they wanted more questions from.'**
  String get eventSuccessEventSuccessConversationCueCopyBodyAskWhichRoundThey;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Ask which stop they would come back to with friends.'**
  String get eventSuccessEventSuccessConversationCueCopyBodyAskWhichStopThey;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Ask what dish they would order again.'**
  String get eventSuccessEventSuccessConversationCueCopyBodyAskWhatDishThey;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Ask what answer from tonight surprised them.'**
  String get eventSuccessEventSuccessConversationCueCopyBodyAskWhatAnswerFrom;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Ask what made them say yes to this event.'**
  String get eventSuccessEventSuccessConversationCueCopyBodyAskWhatMadeThem;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (title).
  ///
  /// In en, this message translates to:
  /// **'First live cue'**
  String get eventSuccessEventSuccessConversationCueCopyTitleFirstLiveCue;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Swap one practical tip before the next round or cooldown.'**
  String get eventSuccessEventSuccessConversationCueCopyBodySwapOnePracticalTip;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Find one person you have not spoken to and ask one specific follow-up.'**
  String get eventSuccessEventSuccessConversationCueCopyBodyFindOnePersonYou;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Second touch'**
  String get eventSuccessEventSuccessConversationCueCopyTitleSecondTouch;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get eventSuccessEventSuccessConversationCueCopyVisiblecopyOptional;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'I liked talking on the run. Want to compare routes sometime?'**
  String get eventSuccessEventSuccessConversationCueCopyBodyILikedTalkingOn;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Good game today. I am still thinking about that rally.'**
  String get eventSuccessEventSuccessConversationCueCopyBodyGoodGameTodayI;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'That session had real energy. What kind of ride do you usually like?'**
  String get eventSuccessEventSuccessConversationCueCopyBodyThatSessionHadReal;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'That class was a good reset. Do you usually go for flow or stretch?'**
  String get eventSuccessEventSuccessConversationCueCopyBodyThatClassWasA;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Nice training with you today. What are you building toward right now?'**
  String get eventSuccessEventSuccessConversationCueCopyBodyNiceTrainingWithYou;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'I liked being on a quiz night with you. Which round was your favorite?'**
  String get eventSuccessEventSuccessConversationCueCopyBodyILikedBeingOn;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Fun meeting you tonight. Which stop won for you?'**
  String
  get eventSuccessEventSuccessConversationCueCopyBodyFunMeetingYouTonight;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'I liked meeting you over dinner. What was your favorite dish?'**
  String get eventSuccessEventSuccessConversationCueCopyBodyILikedMeetingYou;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'I liked our conversation tonight. Want to keep it going?'**
  String
  get eventSuccessEventSuccessConversationCueCopyBodyILikedOurConversation;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'I liked meeting you at the event. What did you think of it?'**
  String
  get eventSuccessEventSuccessConversationCueCopyBodyILikedMeetingYou957a50;

  /// Product copy used by lib/event_success/presentation/event_success_conversation_cue_copy.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Use the shared moment'**
  String get eventSuccessEventSuccessConversationCueCopyTitleUseTheSharedMoment;

  /// Product copy used by lib/chats/presentation/inbox/widgets/chats_list_body.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'attendee'**
  String get chatsChatsListBodyVisiblecopyAttendee;

  /// Product copy used by lib/chats/presentation/inbox/widgets/chats_list_body.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'1 {audienceLabel}'**
  String chatsChatsListBodyVisiblecopy1Audiencelabel({
    required Object audienceLabel,
  });

  /// Product copy used by lib/chats/presentation/inbox/widgets/chats_list_body.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{audienceCount} {audienceLabel}s'**
  String chatsChatsListBodyVisiblecopyAudiencecountAudiencelabelS({
    required Object audienceCount,
    required Object audienceLabel,
  });

  /// Product copy used by lib/chats/presentation/widgets/chat_share_card.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'catch-chat-card.png'**
  String get chatsChatShareCardVisiblecopyCatchChatCardPng;

  /// Product copy used by lib/chats/presentation/widgets/chat_share_card.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Share card'**
  String get chatsChatShareCardVisiblecopyShareCard;

  /// Product copy used by lib/chats/presentation/widgets/chat_share_card.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Names, photos, and timestamps are hidden.'**
  String get chatsChatShareCardVisiblecopyNamesPhotosAndTimestamps;

  /// Product copy used by lib/chats/presentation/widgets/chat_share_card.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Catch chat card'**
  String get chatsChatShareCardVisiblecopyCatchChatCard;

  /// Product copy used by lib/chats/presentation/widgets/message_bubble.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get chatsMessageBubbleVisiblecopySending;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'warmSignupState'**
  String get chatsSuvbotActionBarVisiblecopyWarmsignupstate;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'warmPostEventState'**
  String get chatsSuvbotActionBarVisiblecopyWarmposteventstate;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'warmChatState'**
  String get chatsSuvbotActionBarVisiblecopyWarmchatstate;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'warmPaymentState'**
  String get chatsSuvbotActionBarVisiblecopyWarmpaymentstate;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'resetChats'**
  String get chatsSuvbotActionBarVisiblecopyResetchats;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'resetBookings'**
  String get chatsSuvbotActionBarVisiblecopyResetbookings;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'resetNotifications'**
  String get chatsSuvbotActionBarVisiblecopyResetnotifications;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'clearDemoState'**
  String get chatsSuvbotActionBarVisiblecopyCleardemostate;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'checkDemoState'**
  String get chatsSuvbotActionBarVisiblecopyCheckdemostate;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'refreshDemoState'**
  String get chatsSuvbotActionBarVisiblecopyRefreshdemostate;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'help'**
  String get chatsSuvbotActionBarVisiblecopyHelp;

  /// Product copy used by lib/chats/presentation/widgets/suvbot_action_bar.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'matchTesterByPhone'**
  String get chatsSuvbotActionBarVisiblecopyMatchtesterbyphone;

  /// Product copy used by lib/core/widgets/block_user_dialog.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get coreBlockUserDialogVisiblecopyBlock;

  /// Product copy used by lib/core/widgets/catch_adaptive_dialog.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get coreCatchAdaptiveDialogVisiblecopyConfirm;

  /// Product copy used by lib/core/widgets/catch_adaptive_dialog.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get coreCatchAdaptiveDialogVisiblecopyCancel;

  /// Product copy used by lib/core/widgets/catch_adaptive_picker.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get coreCatchAdaptivePickerVisiblecopySelectDate;

  /// Product copy used by lib/core/widgets/catch_adaptive_picker.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get coreCatchAdaptivePickerVisiblecopySelectTime;

  /// Product copy used by lib/core/widgets/catch_event_activity_cards.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{timeLabel} / {countdownLabel}'**
  String coreCatchEventActivityCardsVisiblecopyTimelabelCountdownlabel({
    required Object timeLabel,
    required Object countdownLabel,
  });

  /// Product copy used by lib/core/widgets/catch_field.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get coreCatchFieldVisiblecopySelect;

  /// Product copy used by lib/core/widgets/catch_otp_code_field.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'otp_digit'**
  String get coreCatchOtpCodeFieldVisiblecopyOtpDigit;

  /// Product copy used by lib/core/widgets/catch_search_field.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get coreCatchSearchFieldVisiblecopyCloseSearch;

  /// Product copy used by lib/core/widgets/catch_share_card_sheet.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Unable to share this card.'**
  String get coreCatchShareCardSheetVisiblecopyUnableToShareThis;

  /// Product copy used by lib/dashboard/presentation/activity_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'mark notifications read'**
  String get dashboardActivityScreenVisiblecopyMarkNotificationsRead;

  /// Product copy used by lib/dashboard/presentation/activity_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'activity_screen'**
  String get dashboardActivityScreenVisiblecopyActivityScreen;

  /// Product copy used by lib/dashboard/presentation/dashboard_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'header'**
  String get dashboardDashboardScreenVisiblecopyHeader;

  /// Product copy used by lib/dashboard/presentation/dashboard_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'calendar'**
  String get dashboardDashboardScreenVisiblecopyCalendar;

  /// Product copy used by lib/dashboard/presentation/dashboard_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{stateValue}:{module}'**
  String dashboardDashboardScreenVisiblecopyStatevalueModule({
    required Object stateValue,
    required Object module,
  });

  /// Product copy used by lib/dashboard/presentation/dashboard_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'club_posts'**
  String get dashboardDashboardScreenVisiblecopyClubPosts;

  /// Product copy used by lib/dashboard/presentation/dashboard_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'home'**
  String get dashboardDashboardScreenVisiblecopyHome;

  /// Product copy used by lib/dashboard/presentation/dashboard_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'notifications'**
  String get dashboardDashboardScreenVisiblecopyNotifications;

  /// Product copy used by lib/dashboard/presentation/notification_route_util.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Could not open this activity update.'**
  String get dashboardNotificationRouteUtilVisiblecopyCouldNotOpenThis;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_full.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'catch_window'**
  String get dashboardDashboardFullVisiblecopyCatchWindow;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_full.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'focus_rail'**
  String get dashboardDashboardFullVisiblecopyFocusRail;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_full.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'idle_cta'**
  String get dashboardDashboardFullVisiblecopyIdleCta;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_full.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'find_event'**
  String get dashboardDashboardFullVisiblecopyFindEvent;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_full.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'club_posts'**
  String get dashboardDashboardFullVisiblecopyClubPosts;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_full.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'open_post'**
  String get dashboardDashboardFullVisiblecopyOpenPost;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_full.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'view_event'**
  String get dashboardDashboardFullVisiblecopyViewEvent;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_full.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'directions'**
  String get dashboardDashboardFullVisiblecopyDirections;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_full.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'add_to_calendar'**
  String get dashboardDashboardFullVisiblecopyAddToCalendar;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_full.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'open_catch_window'**
  String get dashboardDashboardFullVisiblecopyOpenCatchWindow;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_full.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'write_review'**
  String get dashboardDashboardFullVisiblecopyWriteReview;

  /// Product copy used by lib/dashboard/presentation/widgets/dashboard_full.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'check_in'**
  String get dashboardDashboardFullVisiblecopyCheckIn;

  /// Product copy used by lib/dashboard/presentation/widgets/empty_hero_card.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Opens the explore page to find events near your location.'**
  String get dashboardEmptyHeroCardVisiblecopyOpensTheExplorePage;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{longDateLabel} | {activitySummaryLabel}'**
  String
  eventSuccessEventSuccessCompanionAfterglowVisiblecopyLongdatelabelActivitysummarylabel({
    required Object longDateLabel,
    required Object activitySummaryLabel,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Use the shared event context when a match opens.'**
  String
  get eventSuccessEventSuccessCompanionAfterglowVisiblecopyUseTheSharedEvent;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Keep the useful parts of the room for yourself.'**
  String
  get eventSuccessEventSuccessCompanionAfterglowVisiblecopyKeepTheUsefulParts;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Leave a quick note while the event is fresh.'**
  String
  get eventSuccessEventSuccessCompanionAfterglowVisiblecopyLeaveAQuickNote;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Catch keeps this recap private to you.'**
  String
  get eventSuccessEventSuccessCompanionAfterglowVisiblecopyCatchKeepsThisRecap;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{metNewPeopleCount} people remembered, welcome {welcomeRating}/5.'**
  String
  eventSuccessEventSuccessCompanionAfterglowVisiblecopyMetnewpeoplecountPeopleRememberedWelcome({
    required Object metNewPeopleCount,
    required Object welcomeRating,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'\\d+'**
  String get eventSuccessEventSuccessCompanionAfterglowVisiblecopyD;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{value1} people'**
  String eventSuccessEventSuccessCompanionLiveCardsVisiblecopyValue1People({
    required Object value1,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Loading group members'**
  String
  get eventSuccessEventSuccessCompanionLiveCardsVisiblecopyLoadingGroupMembers;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{format}-{format2}'**
  String eventSuccessEventSuccessCompanionLiveCardsVisiblecopyFormatFormat2({
    required Object format,
    required Object format2,
  });

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get eventSuccessEventSuccessCompanionLiveCardsVisiblecopyPartner;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'This is not a Catch event QR.'**
  String get eventSuccessEventSuccessCompanionLiveCardsVisiblecopyThisIsNotA;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'This QR belongs to another event.'**
  String
  get eventSuccessEventSuccessCompanionLiveCardsVisiblecopyThisQrBelongsTo;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Opener copied.'**
  String get eventSuccessEventSuccessCompanionLiveCardsVisiblecopyOpenerCopied;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Cue copied.'**
  String get eventSuccessEventSuccessCompanionLiveCardsVisiblecopyCueCopied;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get eventSuccessEventSuccessCompanionSharedVisiblecopyFree;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'person here so far'**
  String get eventSuccessEventSuccessCompanionSharedVisiblecopyPersonHereSoFar;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'people here so far'**
  String get eventSuccessEventSuccessCompanionSharedVisiblecopyPeopleHereSoFar;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_shared.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'waiting for the room to fill'**
  String
  get eventSuccessEventSuccessCompanionSharedVisiblecopyWaitingForTheRoom;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_wingman.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Host-help request active'**
  String
  get eventSuccessEventSuccessCompanionWingmanVisiblecopyHostHelpRequestActive;

  /// Product copy used by lib/event_success/presentation/companion_parts/event_success_companion_wingman.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Checked in to this event'**
  String get eventSuccessEventSuccessCompanionWingmanVisiblecopyCheckedInToThis;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'self-check-in'**
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopySelfCheckIn;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'first-hello'**
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyFirstHello;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'pre-arrival'**
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyPreArrival;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'questionnaire'**
  String
  get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyQuestionnaire;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'prompt'**
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyPrompt;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'afterglow-recap'**
  String
  get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyAfterglowRecap;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'post-openers'**
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyPostOpeners;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'live-cues'**
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyLiveCues;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'live-step'**
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyLiveStep;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'micro-pod'**
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyMicroPod;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'rotation-schedule'**
  String
  get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyRotationSchedule;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'live-reveal'**
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyLiveReveal;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'wingman'**
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyWingman;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'feedback'**
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyFeedback;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'empty'**
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyEmpty;

  /// Product copy used by lib/event_success/presentation/event_success_companion_body_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'stage'**
  String get eventSuccessEventSuccessCompanionBodyScreenVisiblecopyStage;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'no-stage'**
  String get eventSuccessEventSuccessCompanionScreenStateVisiblecopyNoStage;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'no-step'**
  String get eventSuccessEventSuccessCompanionScreenStateVisiblecopyNoStep;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Before arrival'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyBeforeArrival;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Your event guide is warming up.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyYourEventGuideIs;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Pre-event details stay informational until the host starts the room.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyPreEventDetailsStay;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Arrival cue'**
  String get eventSuccessEventSuccessCompanionScreenStateVisiblecopyArrivalCue;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Check in when you reach the venue.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyCheckInWhenYou;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Check-in only updates attendance and the event companion flow.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyCheckInOnlyUpdates;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'First Hello'**
  String get eventSuccessEventSuccessCompanionScreenStateVisiblecopyFirstHello;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Your first arrival mission is live.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyYourFirstArrivalMission;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'This checks you in. Hosts do not see the individual answer.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyThisChecksYouIn;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Match clues'**
  String get eventSuccessEventSuccessCompanionScreenStateVisiblecopyMatchClues;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Add a few clues before the room moves.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyAddAFewClues;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Hosts do not see individual match clue answers.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyHostsDoNotSee;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Live now'**
  String get eventSuccessEventSuccessCompanionScreenStateVisiblecopyLiveNow;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Follow the host for the next beat.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyFollowTheHostFor;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Everyone sees the same room cue; personal details stay scoped to you.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyEveryoneSeesTheSame;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Live prompt'**
  String get eventSuccessEventSuccessCompanionScreenStateVisiblecopyLivePrompt;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'A fresh prompt just dropped.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyAFreshPromptJust;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Prompts are shared guidance, not a public record of what you say.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyPromptsAreSharedGuidance;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Conversation cues'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyConversationCues;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Pick a cue and keep the room moving.'**
  String get eventSuccessEventSuccessCompanionScreenStateVisiblecopyPickACueAnd;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Conversation cues are suggestions only; nothing is sent for you.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyConversationCuesAreSuggestions;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Your next group'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyYourNextGroup;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Your assignment is ready.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyYourAssignmentIsReady;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Only your own assignment details appear on this screen.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyOnlyYourOwnAssignment;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Shared reveal'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopySharedReveal;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Your details stay hidden on this screen until the shared reveal moment.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyYourDetailsStayHidden;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Host help'**
  String get eventSuccessEventSuccessCompanionScreenStateVisiblecopyHostHelp;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Ask for one specific intro.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyAskForOneSpecific;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Only the host sees this request; the other attendee is not notified.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyOnlyTheHostSees;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Afterglow'**
  String get eventSuccessEventSuccessCompanionScreenStateVisiblecopyAfterglow;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Your afterglow is ready.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyYourAfterglowIsReady;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'This recap is private to you. Hosts only see safe aggregate coaching.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyThisRecapIsPrivate;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Wrapped'**
  String get eventSuccessEventSuccessCompanionScreenStateVisiblecopyWrapped;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get eventSuccessEventSuccessCompanionScreenStateVisiblecopyBooked;

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Catch only shows the live details that are relevant to this event moment.'**
  String
  get eventSuccessEventSuccessCompanionScreenStateVisiblecopyCatchOnlyShowsThe;

  /// Product copy used by lib/event_success/presentation/event_success_event_preview_body_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'This organizer'**
  String get eventSuccessEventSuccessEventPreviewBodyScreenVisiblecopyThisClub;

  /// Product copy used by lib/event_success/presentation/event_success_structure_config_editor.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{toInt} people'**
  String eventSuccessEventSuccessStructureConfigEditorVisiblecopyTointPeople({
    required Object toInt,
  });

  /// Product copy used by lib/event_success/presentation/event_success_structure_config_editor.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{toInt} {toLowerCase}'**
  String
  eventSuccessEventSuccessStructureConfigEditorVisiblecopyTointTolowercase({
    required Object toInt,
    required Object toLowerCase,
  });

  /// Product copy used by lib/event_success/presentation/event_success_structure_config_editor.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{toInt} {value2}'**
  String eventSuccessEventSuccessStructureConfigEditorVisiblecopyTointValue2({
    required Object toInt,
    required Object value2,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Attendees at {locationName} see: {attendeeExperience}'**
  String eventSuccessEventSuccessHostLiveVisiblecopyAttendeesAtLocationnameSee({
    required Object locationName,
    required Object attendeeExperience,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Step {value1}/{total} · {label}'**
  String eventSuccessEventSuccessHostLiveVisiblecopyStepValue1TotalLabel({
    required Object value1,
    required Object total,
    required Object label,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Final step'**
  String get eventSuccessEventSuccessHostLiveVisiblecopyFinalStep;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Next: {title}'**
  String eventSuccessEventSuccessHostLiveVisiblecopyNextTitle({
    required Object title,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'host_override_v1'**
  String get eventSuccessEventSuccessHostOverridesVisiblecopyHostOverrideV1;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Add at least one group.'**
  String get eventSuccessEventSuccessHostOverridesVisiblecopyAddAtLeastOne;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Name every group.'**
  String get eventSuccessEventSuccessHostOverridesVisiblecopyNameEveryGroup;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Add at least one attendee to every group.'**
  String
  get eventSuccessEventSuccessHostOverridesVisiblecopyAddAtLeastOne64c0b6;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Choose every attendee slot.'**
  String
  get eventSuccessEventSuccessHostOverridesVisiblecopyChooseEveryAttendeeSlot;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Each attendee can appear once per round.'**
  String
  get eventSuccessEventSuccessHostOverridesVisiblecopyEachAttendeeCanAppear;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Add at least one pair.'**
  String
  get eventSuccessEventSuccessHostOverridesVisiblecopyAddAtLeastOne76e783;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Choose both attendees for every pair.'**
  String
  get eventSuccessEventSuccessHostOverridesVisiblecopyChooseBothAttendeesFor;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_overrides.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Choose two different attendees.'**
  String
  get eventSuccessEventSuccessHostOverridesVisiblecopyChooseTwoDifferentAttendees;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_setup.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{toInt}'**
  String eventSuccessEventSuccessHostSetupVisiblecopyToint({
    required Object toInt,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_setup.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Decrease target attendees'**
  String
  get eventSuccessEventSuccessHostSetupVisiblecopyDecreaseTargetAttendees;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_setup.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Increase target attendees'**
  String
  get eventSuccessEventSuccessHostSetupVisiblecopyIncreaseTargetAttendees;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_shared.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'this attendee'**
  String get eventSuccessEventSuccessHostSharedVisiblecopyThisAttendee;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_shared.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Attendee'**
  String get eventSuccessEventSuccessHostSharedVisiblecopyAttendee;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_shared.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Asked for help meeting {targetName}'**
  String eventSuccessEventSuccessHostSharedVisiblecopyAskedForHelpMeeting({
    required Object targetName,
  });

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_host.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{remainingSeconds}'**
  String eventSuccessEventSuccessLiveRevealHostVisiblecopyRemainingseconds({
    required Object remainingSeconds,
  });

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_host.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get eventSuccessEventSuccessLiveRevealHostVisiblecopyOk;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_host.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{value1}'**
  String eventSuccessEventSuccessLiveRevealHostVisiblecopyValue1({
    required Object value1,
  });

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get eventSuccessEventSuccessLiveRevealWidgetsVisiblecopyPartner;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{format}-{format2}'**
  String eventSuccessEventSuccessLiveRevealWidgetsVisiblecopyFormatFormat2({
    required Object format,
    required Object format2,
  });

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get eventSuccessEventSuccessLiveRevealWidgetsVisiblecopyDone;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get eventSuccessEventSuccessLiveRevealWidgetsVisiblecopyNow;

  /// Product copy used by lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get eventSuccessEventSuccessLiveRevealWidgetsVisiblecopyHidden;

  /// Product copy used by lib/events/presentation/calendar/calendar_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'calendar-agenda-day-{dateKey}'**
  String eventsCalendarScreenVisiblecopyCalendarAgendaDayDatekey({
    required Object dateKey,
  });

  /// Product copy used by lib/events/presentation/calendar/calendar_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{length}'**
  String eventsCalendarScreenVisiblecopyLength({required Object length});

  /// Product copy used by lib/events/presentation/calendar/calendar_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{round} km'**
  String eventsCalendarScreenVisiblecopyRoundKm({required Object round});

  /// Product copy used by lib/events/presentation/calendar/calendar_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get eventsCalendarScreenVisiblecopyNone;

  /// Product copy used by lib/events/presentation/calendar/calendar_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get eventsCalendarScreenVisiblecopyS;

  /// Product copy used by lib/events/presentation/calendar/calendar_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get eventsCalendarScreenVisiblecopyM;

  /// Product copy used by lib/events/presentation/calendar/calendar_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get eventsCalendarScreenVisiblecopyT;

  /// Product copy used by lib/events/presentation/calendar/calendar_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get eventsCalendarScreenVisiblecopyW;

  /// Product copy used by lib/events/presentation/calendar/calendar_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get eventsCalendarScreenVisiblecopyF;

  /// Product copy used by lib/events/presentation/event_detail_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{eventId}:{inviteLinkId}'**
  String eventsEventDetailScreenVisiblecopyEventidInvitelinkid({
    required Object eventId,
    required Object inviteLinkId,
  });

  /// Product copy used by lib/events/presentation/event_detail_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed!'**
  String get eventsEventDetailScreenVisiblecopyBookingConfirmed;

  /// Product copy used by lib/events/presentation/event_detail_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled.'**
  String get eventsEventDetailScreenVisiblecopyBookingCancelled;

  /// Product copy used by lib/events/presentation/event_detail_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Event saved.'**
  String get eventsEventDetailScreenVisiblecopyEventSaved;

  /// Product copy used by lib/events/presentation/event_detail_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Event removed.'**
  String get eventsEventDetailScreenVisiblecopyEventRemoved;

  /// Product copy used by lib/events/presentation/event_detail_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'EventDetailScreen._toggleSavedEvent failed'**
  String
  get eventsEventDetailScreenVisiblecopyEventdetailscreenTogglesavedeventFailed;

  /// Product copy used by lib/events/presentation/event_detail_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Could not open calendar.'**
  String get eventsEventDetailScreenVisiblecopyCouldNotOpenCalendar;

  /// Product copy used by lib/events/presentation/event_detail_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Failed to add event to calendar'**
  String get eventsEventDetailScreenVisiblecopyFailedToAddEvent;

  /// Product copy used by lib/events/presentation/event_detail_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'add event to calendar'**
  String get eventsEventDetailScreenVisiblecopyAddEventToCalendar;

  /// Product copy used by lib/events/presentation/event_detail_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'calendar_link'**
  String get eventsEventDetailScreenVisiblecopyCalendarLink;

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{spotsRemaining} spots left'**
  String eventsEventDetailScreenStateVisiblecopySpotsremainingSpotsLeft({
    required Object spotsRemaining,
  });

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Matching opens for everyone who goes'**
  String get eventsEventDetailScreenStateVisiblecopyMatchingOpensForEveryone;

  /// Product copy used by lib/events/presentation/location_picker_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Selecting...'**
  String get eventsLocationPickerScreenVisiblecopySelecting;

  /// Product copy used by lib/events/presentation/location_picker_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get eventsLocationPickerScreenVisiblecopySearching;

  /// Product copy used by lib/events/presentation/widgets/booking_conflict_sheet.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Already booked'**
  String get eventsBookingConflictSheetVisiblecopyAlreadyBooked;

  /// Product copy used by lib/events/presentation/widgets/booking_conflict_sheet.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get eventsBookingConflictSheetVisiblecopyNew;

  /// Product copy used by lib/events/presentation/widgets/event_detail_cta.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Offer active'**
  String get eventsEventDetailCtaVisiblecopyOfferActive;

  /// Product copy used by lib/events/presentation/widgets/event_detail_cta.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Until {time}'**
  String eventsEventDetailCtaVisiblecopyUntilTime({required Object time});

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'spot'**
  String get eventsEventDetailDesignPrimitivesVisiblecopySpot;

  /// Product copy used by lib/events/presentation/widgets/event_detail_design_primitives.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'spots'**
  String get eventsEventDetailDesignPrimitivesVisiblecopySpots;

  /// Product copy used by lib/events/presentation/widgets/event_pins_map.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'catch event map'**
  String get eventsEventPinsMapVisiblecopyCatchEventMap;

  /// Product copy used by lib/events/presentation/widgets/event_pins_map.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'building event map pin bitmap'**
  String get eventsEventPinsMapVisiblecopyBuildingEventMapPin;

  /// Product copy used by lib/explore/presentation/explore_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'cover_header'**
  String get exploreExploreScreenVisiblecopyCoverHeader;

  /// Product copy used by lib/explore/presentation/explore_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'external_supply'**
  String get exploreExploreScreenVisiblecopyExternalSupply;

  /// Product copy used by lib/explore/presentation/explore_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'external_outbound'**
  String get exploreExploreScreenVisiblecopyExternalOutbound;

  /// Product copy used by lib/explore/presentation/explore_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'external_platform'**
  String get exploreExploreScreenVisiblecopyExternalPlatform;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Choose city: {label}'**
  String exploreExploreScreenStateVisiblecopyChooseCityLabel({
    required Object label,
  });

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'EXPLORE · {label}'**
  String exploreExploreScreenStateVisiblecopyExploreLabel({
    required Object label,
  });

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreExploreScreenStateVisiblecopyExplore;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Search events or organizers'**
  String get exploreExploreScreenStateVisiblecopySearchEventsOrClubs;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Open explore filters'**
  String get exploreExploreScreenStateVisiblecopyOpenExploreFilters;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Open explore filters, {activeCount} active'**
  String exploreExploreScreenStateVisiblecopyOpenExploreFiltersActivecount({
    required Object activeCount,
  });

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{time} - {priceLabel}'**
  String exploreExploreScreenStateVisiblecopyTimePricelabel({
    required Object time,
    required Object priceLabel,
  });

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{signedUpCount} going - {coverSpotsLabel}'**
  String exploreExploreScreenStateVisiblecopySignedupcountGoingCoverspotslabel({
    required Object signedUpCount,
    required Object coverSpotsLabel,
  });

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'FROM {toUpperCase}'**
  String exploreExploreScreenStateVisiblecopyFromTouppercase({
    required Object toUpperCase,
  });

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'External'**
  String get exploreExploreScreenStateVisiblecopyExternal;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{time} · {priceLabel}'**
  String exploreExploreScreenStateVisiblecopyTimePricelabelc30029({
    required Object time,
    required Object priceLabel,
  });

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Open external event source'**
  String get exploreExploreScreenStateVisiblecopyOpenExternalEventSource;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'External event link unavailable'**
  String get exploreExploreScreenStateVisiblecopyExternalEventLinkUnavailable;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'READ-ONLY SUPPLY · NO CATCH BOOKING'**
  String get exploreExploreScreenStateVisiblecopyReadOnlySupplyNo;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'ORGANIZER TO KNOW'**
  String get exploreExploreScreenStateVisiblecopyClubToKnow;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'PLAN'**
  String get exploreExploreScreenStateVisiblecopyPlan;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'PLANS'**
  String get exploreExploreScreenStateVisiblecopyPlans;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{count} {noun}'**
  String exploreExploreScreenStateVisiblecopyCountNoun({
    required Object count,
    required Object noun,
  });

  /// Honest Explore result count while more cursor pages are available.
  ///
  /// In en, this message translates to:
  /// **'{count}+ {noun}'**
  String exploreExploreScreenStateVisiblecopyCountPlusNoun({
    required Object count,
    required Object noun,
  });

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{count} {noun} · {dateSpan}'**
  String exploreExploreScreenStateVisiblecopyCountNounDatespan({
    required Object count,
    required Object noun,
    required Object dateSpan,
  });

  /// Honest dated Explore result count while more cursor pages are available.
  ///
  /// In en, this message translates to:
  /// **'{count}+ {noun} · {dateSpan}'**
  String exploreExploreScreenStateVisiblecopyCountPlusNounDatespan({
    required Object count,
    required Object noun,
    required Object dateSpan,
  });

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Next: {nextEvent}'**
  String exploreExploreScreenStateVisiblecopyNextNextevent({
    required Object nextEvent,
  });

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{clubMemberCountLabel} - {area}'**
  String exploreExploreScreenStateVisiblecopyClubmembercountlabelArea({
    required Object clubMemberCountLabel,
    required Object area,
  });

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{coverTimeScope} - {name} - {locationName}'**
  String exploreExploreScreenStateVisiblecopyCovertimescopeNameLocationname({
    required Object coverTimeScope,
    required Object name,
    required Object locationName,
  });

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Tonight'**
  String get exploreExploreScreenStateVisiblecopyTonight;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get exploreExploreScreenStateVisiblecopyTomorrow;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get exploreExploreScreenStateVisiblecopyThisWeek;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'1 left'**
  String get exploreExploreScreenStateVisiblecopy1Left;

  /// Product copy used by lib/explore/presentation/explore_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{spots} left'**
  String exploreExploreScreenStateVisiblecopySpotsLeft({required Object spots});

  /// Product copy used by lib/explore/presentation/widgets/explore_event_rows.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'COMING UP · {length}'**
  String exploreExploreEventRowsVisiblecopyComingUpLength({
    required Object length,
  });

  /// Product copy used by lib/hosts/presentation/club_management/create/create_club_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Restored your organizer draft'**
  String get hostsCreateClubScreenVisiblecopyRestoredYourClubDraft;

  /// Product copy used by lib/hosts/presentation/club_management/create/create_club_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'CreateClubScreen._restoreSavedDraft failed'**
  String
  get hostsCreateClubScreenVisiblecopyCreateclubscreenRestoresaveddraftFailed;

  /// Product copy used by lib/hosts/presentation/club_management/create/create_club_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Draft updated'**
  String get hostsCreateClubScreenVisiblecopyDraftUpdated;

  /// Product copy used by lib/hosts/presentation/club_management/create/create_club_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get hostsCreateClubScreenVisiblecopyDraftSaved;

  /// Product copy used by lib/hosts/presentation/club_management/create/create_club_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'CreateClubScreen._submit failed'**
  String get hostsCreateClubScreenVisiblecopyCreateclubscreenSubmitFailed;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_basics_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Please enter an organizer name'**
  String get hostsClubBasicsStepVisiblecopyPleaseEnterAClub;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_basics_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Please select a city'**
  String get hostsClubBasicsStepVisiblecopyPleaseSelectACity;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_basics_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Please enter an area'**
  String get hostsClubBasicsStepVisiblecopyPleaseEnterAnArea;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/club_details_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Please add a description'**
  String get hostsClubDetailsStepVisiblecopyPleaseAddADescription;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get hostsCreateClubPhotosPickerVisiblecopyAddPhotos;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Add organizer photos'**
  String get hostsCreateClubPhotosPickerVisiblecopyAddClubPhotos;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'^\\d*\\.?\\d*'**
  String get hostsEditHostedEventScreenVisiblecopyDD;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'[A-Za-z0-9_-]'**
  String get hostsEditHostedEventScreenVisiblecopyAZaZ09;

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{capacityLimit}'**
  String hostsEditHostedEventScreenVisiblecopyCapacitylimit({
    required Object capacityLimit,
  });

  /// Product copy used by lib/hosts/presentation/edit_hosted_event_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get hostsEditHostedEventScreenVisiblecopyFree;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'configuredIn'**
  String get hostsCreateEventScreenVisiblecopyConfiguredin;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'create_event'**
  String get hostsCreateEventScreenVisiblecopyCreateEvent;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_success_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{capacityLimit} attendees'**
  String hostsCreateEventSuccessScreenVisiblecopyCapacitylimitAttendees({
    required Object capacityLimit,
  });

  /// Product copy used by lib/hosts/presentation/event_management/widgets/create_event_photo_picker.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Add event photos'**
  String get hostsCreateEventPhotoPickerVisiblecopyAddEventPhotos;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/create_event_photo_picker.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get hostsCreateEventPhotoPickerVisiblecopyAddPhotos;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/draft_picker_sheet.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Could not delete draft.'**
  String get hostsDraftPickerSheetVisiblecopyCouldNotDeleteDraft;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_details_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get hostsEventDetailsStepVisiblecopyRequired;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_details_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Too short'**
  String get hostsEventDetailsStepVisiblecopyTooShort;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_details_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Too long'**
  String get hostsEventDetailsStepVisiblecopyTooLong;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_details_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'^\\d*\\.?\\d*'**
  String get hostsEventDetailsStepVisiblecopyDD;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_details_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get hostsEventDetailsStepVisiblecopyInvalid;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_details_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Must be > 0'**
  String get hostsEventDetailsStepVisiblecopyMustBe0;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_details_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Select a pace'**
  String get hostsEventDetailsStepVisiblecopySelectAPace;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get hostsEventPolicyStepVisiblecopyRequired;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Min 1'**
  String get hostsEventPolicyStepVisiblecopyMin1;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'^\\d*\\.?\\d*'**
  String get hostsEventPolicyStepVisiblecopyDD;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get hostsEventPolicyStepVisiblecopyInvalid;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'[A-Za-z0-9_-]'**
  String get hostsEventPolicyStepVisiblecopyAZaZ09;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/when_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get hostsWhenStepVisiblecopyPleaseSelectADate;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/when_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get hostsWhenStepVisiblecopyRequired;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/when_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Decrease duration'**
  String get hostsWhenStepVisiblecopyDecreaseDuration;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/when_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Increase duration'**
  String get hostsWhenStepVisiblecopyIncreaseDuration;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/where_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Choose a meeting location'**
  String get hostsWhereStepVisiblecopyChooseAMeetingLocation;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/where_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Add a location name'**
  String get hostsWhereStepVisiblecopyAddALocationName;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Event cancelled.'**
  String get hostsHostEventManageScreenVisiblecopyEventCancelled;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Event deleted.'**
  String get hostsHostEventManageScreenVisiblecopyEventDeleted;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{label} copied.'**
  String hostsHostEventManageScreenVisiblecopyLabelCopied({
    required Object label,
  });

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'HostEventManageScreen._createNamedInviteLink failed'**
  String
  get hostsHostEventManageScreenVisiblecopyHosteventmanagescreenCreatenamedinvitelinkFailed;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'HostEventManageScreen._copyNamedInviteLink failed'**
  String
  get hostsHostEventManageScreenVisiblecopyHosteventmanagescreenCopynamedinvitelinkFailed;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{label} disabled.'**
  String hostsHostEventManageScreenVisiblecopyLabelDisabled({
    required Object label,
  });

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'HostEventManageScreen._disableNamedInviteLink failed'**
  String
  get hostsHostEventManageScreenVisiblecopyHosteventmanagescreenDisablenamedinvitelinkFailed;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'HostEventManageScreen._shareHostPrivateLink failed'**
  String
  get hostsHostEventManageScreenVisiblecopyHosteventmanagescreenSharehostprivatelinkFailed;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get hostsHostEventManageScreenVisiblecopyFree;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{booked}'**
  String hostsHostEventManageScreenVisiblecopyBooked({required Object booked});

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'/{capacityLimit}'**
  String hostsHostEventManageScreenVisiblecopyCapacitylimit({
    required Object capacityLimit,
  });

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{waitlisted}'**
  String hostsHostEventManageScreenVisiblecopyWaitlisted({
    required Object waitlisted,
  });

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'No people match this search.'**
  String get hostsHostEventManageScreenStateVisiblecopyNoPeopleMatchThis;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Slots show capacity left after booked people. New people appear here once they book or request access.'**
  String get hostsHostEventManageScreenStateVisiblecopySlotsShowCapacityLeft;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Booked and waitlisted people will appear here.'**
  String
  get hostsHostEventManageScreenStateVisiblecopyBookedAndWaitlistedPeople;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'No live roster rows match this search.'**
  String get hostsHostEventManageScreenStateVisiblecopyNoLiveRosterRows;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'No report rows match this search.'**
  String get hostsHostEventManageScreenStateVisiblecopyNoReportRowsMatch;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get hostsHostEventManageScreenStateVisiblecopyCheckedIn;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get hostsHostEventManageScreenStateVisiblecopyUndo;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get hostsHostEventManageScreenStateVisiblecopyCheckIn;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get hostsHostEventManageScreenStateVisiblecopyFree;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Sharing...'**
  String get hostsHostEventManageScreenStateVisiblecopySharing;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Public event link'**
  String get hostsHostEventManageScreenStateVisiblecopyPublicEventLink;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Loading link'**
  String get hostsHostEventManageScreenStateVisiblecopyLoadingLink;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Invite setup unavailable'**
  String get hostsHostEventManageScreenStateVisiblecopyInviteSetupUnavailable;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Private invite link'**
  String get hostsHostEventManageScreenStateVisiblecopyPrivateInviteLink;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Invite links unavailable'**
  String get hostsHostEventManageScreenStateVisiblecopyInviteLinksUnavailable;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'1 invite link'**
  String get hostsHostEventManageScreenStateVisiblecopy1InviteLink;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{count} invite links'**
  String hostsHostEventManageScreenStateVisiblecopyCountInviteLinks({
    required Object count,
  });

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Everyone visible is checked in'**
  String get hostsHostEventManageScreenStateVisiblecopyEveryoneVisibleIsChecked;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'No checked-in people yet'**
  String get hostsHostEventManageScreenStateVisiblecopyNoCheckedInPeople;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'No waitlisted people'**
  String get hostsHostEventManageScreenStateVisiblecopyNoWaitlistedPeople;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Roster is empty'**
  String get hostsHostEventManageScreenStateVisiblecopyRosterIsEmpty;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Switch to In to review arrivals or All to see the full roster.'**
  String get hostsHostEventManageScreenStateVisiblecopySwitchToInTo;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Checked-in people will appear here during the event.'**
  String get hostsHostEventManageScreenStateVisiblecopyCheckedInPeopleWill;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Waitlisted people will appear here for context.'**
  String
  get hostsHostEventManageScreenStateVisiblecopyWaitlistedPeopleWillAppear;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Signed-up participants will appear here when they book.'**
  String get hostsHostEventManageScreenStateVisiblecopySignedUpParticipantsWill;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'No attended people yet'**
  String get hostsHostEventManageScreenStateVisiblecopyNoAttendedPeopleYet;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'No no-shows yet'**
  String get hostsHostEventManageScreenStateVisiblecopyNoNoShowsYet;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'No participants yet'**
  String get hostsHostEventManageScreenStateVisiblecopyNoParticipantsYet;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Checked-in people will appear here after the event.'**
  String
  get hostsHostEventManageScreenStateVisiblecopyCheckedInPeopleWill186cb6;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Booked people who did not check in will appear here.'**
  String get hostsHostEventManageScreenStateVisiblecopyBookedPeopleWhoDid;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Waitlist history will appear here when people queue for this event.'**
  String
  get hostsHostEventManageScreenStateVisiblecopyWaitlistHistoryWillAppear;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Attendance and waitlist history will appear here once people sign up.'**
  String
  get hostsHostEventManageScreenStateVisiblecopyAttendanceAndWaitlistHistory;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Offer sent'**
  String get hostsHostEventManageScreenStateVisiblecopyOfferSent;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Accepted offer'**
  String get hostsHostEventManageScreenStateVisiblecopyAcceptedOffer;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Offer expired'**
  String get hostsHostEventManageScreenStateVisiblecopyOfferExpired;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get hostsHostEventManageScreenStateVisiblecopyApproved;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get hostsHostEventManageScreenStateVisiblecopyViewProfile;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Waitlisted'**
  String get hostsHostEventManageScreenStateVisiblecopyWaitlisted;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Profile ready'**
  String get hostsHostEventManageScreenStateVisiblecopyProfileReady;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get hostsHostEventManageScreenStateVisiblecopyBooked;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get hostsHostEventManageScreenStateVisiblecopyCancelled;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get hostsHostEventManageScreenStateVisiblecopyDeleted;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Participant'**
  String get hostsHostEventManageScreenStateVisiblecopyParticipant;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_team_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Host profile saved.'**
  String get hostsHostClubTeamScreenVisiblecopyHostProfileSaved;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_team_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Host profile created.'**
  String get hostsHostClubTeamScreenVisiblecopyHostProfileCreated;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_team_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Creating profile...'**
  String get hostsHostClubTeamScreenVisiblecopyCreatingProfile;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_team_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Create host profile'**
  String get hostsHostClubTeamScreenVisiblecopyCreateHostProfile;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_team_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Add role title'**
  String get hostsHostClubTeamScreenVisiblecopyAddRoleTitle;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_team_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Add a host bio'**
  String get hostsHostClubTeamScreenVisiblecopyAddAHostBio;

  /// Product copy used by lib/hosts/presentation/host_operations/host_auth_required_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get hostsHostAuthRequiredScreenVisiblecopySignIn;

  /// Product copy used by lib/hosts/presentation/host_operations/host_club_edit_tab.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{minAge}–{maxAge}'**
  String hostsHostClubProfileVisiblecopyMinageMaxage({
    required Object minAge,
    required Object maxAge,
  });

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'morning'**
  String get hostsHostTodayVisiblecopyMorning;

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'afternoon'**
  String get hostsHostTodayVisiblecopyAfternoon;

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'evening'**
  String get hostsHostTodayVisiblecopyEvening;

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get hostsHostTodayLabelOwner;

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Host team'**
  String get hostsHostTodayLabelHostTeam;

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{signedUpCount}'**
  String hostsHostTodayVisiblecopySignedupcount({
    required Object signedUpCount,
  });

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{waitlistCount}'**
  String hostsHostTodayVisiblecopyWaitlistcount({
    required Object waitlistCount,
  });

  /// Product copy used by lib/hosts/presentation/host_operations/host_today.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{taskCount}'**
  String hostsHostTodayVisiblecopyTaskcount({required Object taskCount});

  /// Product copy used by lib/hosts/presentation/inbox/host_inbox_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Some push attempts failed; Activity updates are still available.'**
  String get hostsHostInboxScreenVisiblecopySomePushAttemptsFailed;

  /// Product copy used by lib/hosts/presentation/inbox/host_inbox_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Broadcast sent to {recipientCount} people.{suffix}'**
  String hostsHostInboxScreenVisiblecopyBroadcastSentToRecipientcount({
    required Object recipientCount,
    required Object suffix,
  });

  /// Product copy used by lib/hosts/presentation/inbox/host_inbox_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Select an event or general inquiries'**
  String get hostsHostInboxScreenVisiblecopySelectAnEventOr;

  /// Product copy used by lib/hosts/presentation/inbox/host_inbox_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'General inquiries'**
  String get hostsHostInboxScreenVisiblecopyGeneralInquiries;

  /// Product copy used by lib/hosts/presentation/inbox/host_inbox_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Event inquiry'**
  String get hostsHostInboxScreenVisiblecopyEventInquiry;

  /// Product copy used by lib/hosts/presentation/inbox/host_inbox_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{longWeekday} {eventTitleLabel}'**
  String hostsHostInboxScreenVisiblecopyLongweekdayEventtitlelabel({
    required Object longWeekday,
    required Object eventTitleLabel,
  });

  /// Product copy used by lib/hosts/presentation/inbox/host_inbox_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Tonight {time}'**
  String hostsHostInboxScreenVisiblecopyTonightTime({required Object time});

  /// Product copy used by lib/hosts/presentation/inbox/host_inbox_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{shortDateLabel} · {time}'**
  String hostsHostInboxScreenVisiblecopyShortdatelabelTime({
    required Object shortDateLabel,
    required Object time,
  });

  /// Product copy used by lib/hosts/presentation/inbox/host_inbox_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{eventName} · {timing}'**
  String hostsHostInboxScreenVisiblecopyEventnameTiming({
    required Object eventName,
    required Object timing,
  });

  /// Product copy used by lib/hosts/presentation/inbox/host_inbox_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{title} · {shortDateLabel} · {compactTimeRangeLabel}'**
  String
  hostsHostInboxScreenVisiblecopyTitleShortdatelabelCompacttimerangelabel({
    required Object title,
    required Object shortDateLabel,
    required Object compactTimeRangeLabel,
  });

  /// Product copy used by lib/hosts/presentation/inbox/host_inbox_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{name} attendee'**
  String hostsHostInboxScreenVisiblecopyNameAttendee({required Object name});

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Not set up'**
  String get hostsHostPaymentAccountCardVisiblecopyNotSetUp;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get hostsHostPaymentAccountCardVisiblecopyReady;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Action needed'**
  String get hostsHostPaymentAccountCardVisiblecopyActionNeeded;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_card.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get hostsHostPaymentAccountCardVisiblecopyPending;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_controller_card.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'HostPaymentAccountControllerCard.startOnboarding failed'**
  String
  get hostsHostPaymentAccountControllerCardVisiblecopyHostpaymentaccountcontrollercardStartonboardingFailed;

  /// Product copy used by lib/hosts/presentation/payments/host_payment_account_controller_card.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'HostPaymentAccountControllerCard.refresh failed'**
  String
  get hostsHostPaymentAccountControllerCardVisiblecopyHostpaymentaccountcontrollercardRefreshFailed;

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{totalBooked}'**
  String hostsHostClubToolsVisiblecopyTotalbooked({
    required Object totalBooked,
  });

  /// Product copy used by lib/hosts/presentation/widgets/host_club_tools.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{totalWaitlist}'**
  String hostsHostClubToolsVisiblecopyTotalwaitlist({
    required Object totalWaitlist,
  });

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Revenue CSV ready.'**
  String get hostsHostEventAttendancePanelVisiblecopyRevenueCsvReady;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'_shareRevenueReport failed'**
  String get hostsHostEventAttendancePanelVisiblecopySharerevenuereportFailed;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Ops CSV ready.'**
  String get hostsHostEventAttendancePanelVisiblecopyOpsCsvReady;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'_shareOpsReport failed'**
  String get hostsHostEventAttendancePanelVisiblecopyShareopsreportFailed;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get hostsHostEventAttendancePanelVisiblecopyGuest;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Signal'**
  String get hostsHostEventAttendancePanelVisiblecopySignal;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Host action'**
  String get hostsHostEventAttendancePanelVisiblecopyHostAction;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get hostsHostEventAttendancePanelVisiblecopyStatus;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get hostsHostEventAttendancePanelVisiblecopyName;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get hostsHostEventAttendancePanelVisiblecopyAttendance;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get hostsHostEventAttendancePanelVisiblecopyPayment;

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{value}'**
  String hostsHostEventAttendancePanelVisiblecopyValue({required Object value});

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{remainingAfterSend} still waiting after this offer'**
  String
  hostsHostEventAttendancePanelVisiblecopyRemainingaftersendStillWaitingAfter({
    required Object remainingAfterSend,
  });

  /// Product copy used by lib/hosts/presentation/widgets/host_event_attendance_panel.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Next {count} {personNoun} on the waitlist'**
  String hostsHostEventAttendancePanelVisiblecopyNextCountPersonnounOn({
    required Object count,
    required Object personNoun,
  });

  /// Product copy used by lib/hosts/presentation/widgets/host_event_tools.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Hosted event {value1} of {length}'**
  String hostsHostEventToolsVisiblecopyHostedEventValue1Of({
    required Object value1,
    required Object length,
  });

  /// Product copy used by lib/hosts/presentation/widgets/host_event_tools.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Hosted event {selectedIndex} of {length}'**
  String hostsHostEventToolsVisiblecopyHostedEventSelectedindexOf({
    required Object selectedIndex,
    required Object length,
  });

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'HostTeamManagementSection._showAddHostSheet failed'**
  String
  get hostsHostTeamManagementSectionVisiblecopyHostteammanagementsectionShowaddhostsheetFailed;

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Host added.'**
  String get hostsHostTeamManagementSectionVisiblecopyHostAdded;

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'HostTeamManagementSection._confirmHostAction failed'**
  String
  get hostsHostTeamManagementSectionVisiblecopyHostteammanagementsectionConfirmhostactionFailed;

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'transfer'**
  String get hostsHostTeamManagementSectionVisiblecopyTransfer;

  /// Product copy used by lib/hosts/presentation/widgets/host_team_management_section.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'remove'**
  String get hostsHostTeamManagementSectionVisiblecopyRemove;

  /// Product copy used by lib/image_uploads/shared/profile_photo_editor_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get imageUploadsProfilePhotoEditorScreenVisiblecopyDelete;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingOnboardingStepVisiblecopyWelcome;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get onboardingOnboardingStepVisiblecopyYourName;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get onboardingOnboardingStepVisiblecopyGender;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get onboardingOnboardingStepVisiblecopyInstagram;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get onboardingOnboardingStepVisiblecopyPhotos;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Prompts'**
  String get onboardingOnboardingStepVisiblecopyPrompts;

  /// Product copy used by lib/onboarding/presentation/onboarding_step.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Running style'**
  String get onboardingOnboardingStepVisiblecopyRunningStyle;

  /// Product copy used by lib/onboarding/presentation/pages/photos_page.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Please try again.'**
  String get onboardingPhotosPageVisiblecopyUploadFailedPleaseTry;

  /// Product copy used by lib/onboarding/presentation/pages/welcome_page.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'reduced_motion'**
  String get onboardingWelcomePageVisiblecopyReducedMotion;

  /// Product copy used by lib/onboarding/presentation/pages/welcome_page.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'direct'**
  String get onboardingWelcomePageVisiblecopyDirect;

  /// Product copy used by lib/onboarding/presentation/pages/welcome_page.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'animated'**
  String get onboardingWelcomePageVisiblecopyAnimated;

  /// Product copy used by lib/onboarding/presentation/pages/welcome_page.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'continue_phone'**
  String get onboardingWelcomePageVisiblecopyContinuePhone;

  /// Product copy used by lib/onboarding/presentation/pages/welcome_page.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'see_whats_on'**
  String get onboardingWelcomePageVisiblecopySeeWhatsOn;

  /// Product copy used by lib/onboarding/presentation/pages/welcome_page.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get onboardingWelcomePageVisiblecopyFrom;

  /// Product copy used by lib/onboarding/presentation/pages/welcome_page.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'/auth'**
  String get onboardingWelcomePageVisiblecopyAuth;

  /// Product copy used by lib/public_profile/presentation/public_profile_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{name} has been blocked.'**
  String publicProfilePublicProfileScreenVisiblecopyNameHasBeenBlocked({
    required Object name,
  });

  /// Product copy used by lib/public_profile/presentation/public_profile_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Report submitted.'**
  String get publicProfilePublicProfileScreenVisiblecopyReportSubmitted;

  /// Product copy used by lib/public_profile/presentation/public_profile_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'report'**
  String get publicProfilePublicProfileScreenVisiblecopyReport;

  /// Product copy used by lib/public_profile/presentation/public_profile_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'block'**
  String get publicProfilePublicProfileScreenVisiblecopyBlock;

  /// Product copy used by lib/public_profile/presentation/public_profile_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'harassment_or_abuse'**
  String get publicProfilePublicProfileScreenVisiblecopyHarassmentOrAbuse;

  /// Product copy used by lib/public_profile/presentation/public_profile_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'fake_or_misleading_profile'**
  String get publicProfilePublicProfileScreenVisiblecopyFakeOrMisleadingProfile;

  /// Product copy used by lib/public_profile/presentation/public_profile_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'inappropriate_content'**
  String get publicProfilePublicProfileScreenVisiblecopyInappropriateContent;

  /// Product copy used by lib/public_profile/presentation/public_profile_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'other'**
  String get publicProfilePublicProfileScreenVisiblecopyOther;

  /// Product copy used by lib/swipes/presentation/filters_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{round} – {formatPreferredMatchAge}'**
  String swipesFiltersScreenVisiblecopyRoundFormatpreferredmatchage({
    required Object round,
    required Object formatPreferredMatchAge,
  });

  /// Product copy used by lib/swipes/shared/profile_surface/catch_profile_view.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Running rhythm'**
  String get swipesCatchProfileViewVisiblecopyRunningRhythm;

  /// Product copy used by lib/swipes/shared/profile_surface/profile_view_mapper.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'compatibility'**
  String get swipesProfileViewMapperVisiblecopyCompatibility;

  /// Product copy used by lib/swipes/shared/profile_surface/profile_view_mapper.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'profile-prompt-{promptId}'**
  String swipesProfileViewMapperVisiblecopyProfilePromptPromptid({
    required Object promptId,
  });

  /// Product copy used by lib/swipes/shared/profile_surface/profile_view_mapper.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'running'**
  String get swipesProfileViewMapperVisiblecopyRunning;

  /// Product copy used by lib/swipes/shared/profile_surface/profile_view_mapper.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Running rhythm'**
  String get swipesProfileViewMapperVisiblecopyRunningRhythm;

  /// Product copy used by lib/swipes/shared/profile_surface/profile_view_mapper.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'details'**
  String get swipesProfileViewMapperVisiblecopyDetails;

  /// Product copy used by lib/swipes/shared/profile_surface/profile_view_mapper.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get swipesProfileViewMapperVisiblecopyDetails4d7b56;

  /// Product copy used by lib/swipes/shared/profile_surface/profile_view_mapper.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'lifestyle'**
  String get swipesProfileViewMapperVisiblecopyLifestyle;

  /// Product copy used by lib/swipes/shared/profile_surface/profile_view_mapper.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get swipesProfileViewMapperVisiblecopyLifestyle900024;

  /// Product copy used by lib/swipes/shared/profile_surface/profile_view_mapper.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'hero-photo'**
  String get swipesProfileViewMapperVisiblecopyHeroPhoto;

  /// Product copy used by lib/swipes/shared/profile_surface/profile_view_mapper.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Main photo'**
  String get swipesProfileViewMapperVisiblecopyMainPhoto;

  /// Product copy used by lib/swipes/shared/profile_surface/profile_view_mapper.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'main profile photo'**
  String get swipesProfileViewMapperVisiblecopyMainProfilePhoto;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'displayName'**
  String get userProfileSelfProfileEditTabStateVisiblecopyDisplayname;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'email'**
  String get userProfileSelfProfileEditTabStateVisiblecopyEmaile69bb2;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'instagramHandle'**
  String get userProfileSelfProfileEditTabStateVisiblecopyInstagramhandle71eebb;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{height} cm'**
  String userProfileSelfProfileEditTabStateVisiblecopyHeightCm({
    required Object height,
  });

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get userProfileSelfProfileEditTabStateVisiblecopyHeight;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'city'**
  String get userProfileSelfProfileEditTabStateVisiblecopyCity;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'occupation'**
  String get userProfileSelfProfileEditTabStateVisiblecopyOccupation;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'company'**
  String get userProfileSelfProfileEditTabStateVisiblecopyCompanyfd8aec;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'education'**
  String get userProfileSelfProfileEditTabStateVisiblecopyEducation;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'religion'**
  String get userProfileSelfProfileEditTabStateVisiblecopyReligion;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'languages'**
  String get userProfileSelfProfileEditTabStateVisiblecopyLanguages;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'relationshipGoal'**
  String get userProfileSelfProfileEditTabStateVisiblecopyRelationshipgoal;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{formatPace}/km'**
  String userProfileSelfProfileEditTabStateVisiblecopyFormatpaceKm({
    required Object formatPace,
  });

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'preferredDistances'**
  String get userProfileSelfProfileEditTabStateVisiblecopyPreferreddistances;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'runningReasons'**
  String get userProfileSelfProfileEditTabStateVisiblecopyRunningreasons;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'preferredRunTimes'**
  String get userProfileSelfProfileEditTabStateVisiblecopyPreferredruntimes;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'drinking'**
  String get userProfileSelfProfileEditTabStateVisiblecopyDrinking;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'smoking'**
  String get userProfileSelfProfileEditTabStateVisiblecopySmoking;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'workout'**
  String get userProfileSelfProfileEditTabStateVisiblecopyWorkout;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'diet'**
  String get userProfileSelfProfileEditTabStateVisiblecopyDiet;

  /// Product copy used by lib/user_profile/presentation/self_profile_edit_tab_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'children'**
  String get userProfileSelfProfileEditTabStateVisiblecopyChildren;

  /// Product copy used by lib/user_profile/presentation/widgets/inline_editor_height.dart (body).
  ///
  /// In en, this message translates to:
  /// **'{heightCm} cm'**
  String userProfileInlineEditorHeightBodyHeightcmCm({
    required Object heightCm,
  });

  /// Product copy used by lib/user_profile/presentation/widgets/inline_editor_range.dart (body).
  ///
  /// In en, this message translates to:
  /// **'{labelText} - {labelText2}'**
  String userProfileInlineEditorRangeBodyLabeltextLabeltext2({
    required Object labelText,
    required Object labelText2,
  });

  /// Product copy used by lib/user_profile/presentation/widgets/profile_tab.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{completedPromptCount} of {maxProfilePromptAnswers} answered'**
  String
  userProfileProfileTabVisiblecopyCompletedpromptcountOfMaxprofilepromptanswersAnswered({
    required Object completedPromptCount,
    required Object maxProfilePromptAnswers,
  });

  /// Product copy used by lib/user_profile/presentation/widgets/profile_tab.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{completedCount} of {maximumProfilePhotoCount} added'**
  String
  userProfileProfileTabVisiblecopyCompletedcountOfMaximumprofilephotocountAdded({
    required Object completedCount,
    required Object maximumProfilePhotoCount,
  });

  /// Product copy used by lib/user_profile/presentation/widgets/profile_tab_skeleton.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'loading'**
  String get userProfileProfileTabSkeletonVisiblecopyLoading;

  /// Profile quality suggestion title for adding enough clear photos.
  ///
  /// In en, this message translates to:
  /// **'Add 3 clear photos'**
  String get profileQualityPhotosTitle;

  /// Profile quality guidance for choosing a useful mix of photos.
  ///
  /// In en, this message translates to:
  /// **'A mix of face, full-body, and running/social photos gives people confidence.'**
  String get profileQualityPhotosDetail;

  /// Profile quality suggestion title for completing profile prompts.
  ///
  /// In en, this message translates to:
  /// **'Answer all 3 prompts'**
  String get profileQualityPromptsTitle;

  /// Profile quality guidance for completing profile prompts.
  ///
  /// In en, this message translates to:
  /// **'Specific prompts create the easiest openings for comments and likes.'**
  String get profileQualityPromptsDetail;

  /// Profile quality suggestion title for adding prompts to photos.
  ///
  /// In en, this message translates to:
  /// **'Add photo prompts'**
  String get profileQualityPhotoPromptsTitle;

  /// Profile quality guidance for adding prompts to photos.
  ///
  /// In en, this message translates to:
  /// **'Prompts make photos easier to react to without writing captions.'**
  String get profileQualityPhotoPromptsDetail;

  /// Profile quality suggestion title for selecting relationship intent.
  ///
  /// In en, this message translates to:
  /// **'Add what you are looking for'**
  String get profileQualityRelationshipGoalTitle;

  /// Profile quality guidance for selecting relationship intent.
  ///
  /// In en, this message translates to:
  /// **'Intent helps people decide whether starting a conversation makes sense.'**
  String get profileQualityRelationshipGoalDetail;

  /// Profile quality suggestion title for completing running preferences.
  ///
  /// In en, this message translates to:
  /// **'Fill out your running identity'**
  String get profileQualityRunningIdentityTitle;

  /// Profile quality guidance for completing running preferences.
  ///
  /// In en, this message translates to:
  /// **'Distance, reason, and time-of-day preferences power better compatibility signals.'**
  String get profileQualityRunningIdentityDetail;

  /// Profile quality suggestion title for adding a background fact.
  ///
  /// In en, this message translates to:
  /// **'Add one background detail'**
  String get profileQualityBackgroundTitle;

  /// Profile quality guidance for adding a background fact.
  ///
  /// In en, this message translates to:
  /// **'Height, work, education, or languages help round out the card.'**
  String get profileQualityBackgroundDetail;

  /// Profile quality suggestion title for adding a lifestyle fact.
  ///
  /// In en, this message translates to:
  /// **'Add one lifestyle detail'**
  String get profileQualityLifestyleTitle;

  /// Profile quality guidance for adding a lifestyle fact.
  ///
  /// In en, this message translates to:
  /// **'Small details make the profile feel less generic.'**
  String get profileQualityLifestyleDetail;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Profile insights'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyProfileInsights;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Loading profile insights'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyLoadingProfileInsights;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (emptyTitle).
  ///
  /// In en, this message translates to:
  /// **'Insights are warming up'**
  String get userAnalyticsUserAnalyticsCopyEmptytitleInsightsAreWarmingUp;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (emptyBody).
  ///
  /// In en, this message translates to:
  /// **'You will see trends here after Catch has enough event and profile activity.'**
  String get userAnalyticsUserAnalyticsCopyEmptybodyYouWillSeeTrends;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyRange;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyTrend;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopySuggestions;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Data coverage'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyDataCoverage;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyPartial;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyMissing;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyLast7Days;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyLast30Days;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyLast90Days;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyThisMonth;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Profile views'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyProfileViews;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Caught you'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyCaughtYou;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Mutual catches'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyMutualCatches;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Chats started'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyChatsStarted;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Events attended'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyEventsAttended;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Follow-through'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyFollowThrough;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Post-event profile attention.'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyPostEventProfileAttention;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'People who showed interest.'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyPeopleWhoShowedInterest;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Matches where interest was mutual.'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyMatchesWhereInterestWas;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Conversations that opened after matching.'**
  String
  get userAnalyticsUserAnalyticsCopyVisiblecopyConversationsThatOpenedAfter;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Events you attended.'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyEventsYouAttended;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Chats started from mutual catches.'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyChatsStartedFromMutual;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyViews;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyInterest;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyMatches;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyChats;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Attended'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyAttended;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Tune your profile'**
  String get userAnalyticsUserAnalyticsCopyTitleTuneYourProfile;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'A fresh prompt or first photo can make post-event interest easier to read.'**
  String get userAnalyticsUserAnalyticsCopyBodyAFreshPromptOr;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Open the loop'**
  String get userAnalyticsUserAnalyticsCopyTitleOpenTheLoop;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'A short message after a mutual catch is the clearest follow-through signal.'**
  String get userAnalyticsUserAnalyticsCopyBodyAShortMessageAfter;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Show up in person'**
  String get userAnalyticsUserAnalyticsCopyTitleShowUpInPerson;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'The strongest profile trends start after attended events.'**
  String get userAnalyticsUserAnalyticsCopyBodyTheStrongestProfileTrends;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Keep showing up'**
  String get userAnalyticsUserAnalyticsCopyTitleKeepShowingUp;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Repeated event attendance gives Catch better connection signal.'**
  String get userAnalyticsUserAnalyticsCopyBodyRepeatedEventAttendanceGives;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Keep building signal'**
  String get userAnalyticsUserAnalyticsCopyTitleKeepBuildingSignal;

  /// Product copy used by lib/user_analytics/shared/user_analytics_copy.dart (body).
  ///
  /// In en, this message translates to:
  /// **'Insights get sharper after more post-event profile views.'**
  String get userAnalyticsUserAnalyticsCopyBodyInsightsGetSharperAfter;

  /// Product copy used by lib/core/widgets/catch_privacy_badge.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Private to you'**
  String get coreCatchPrivacyBadgeLabelPrivateToYou;

  /// Product copy used by lib/core/widgets/catch_privacy_badge.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Host can see'**
  String get coreCatchPrivacyBadgeLabelHostCanSee;

  /// Product copy used by lib/core/widgets/catch_privacy_badge.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Catch private'**
  String get coreCatchPrivacyBadgeLabelCatchPrivate;

  /// Product copy used by lib/event_success/presentation/event_success_live_reveal_card.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Pod reveal'**
  String get eventSuccessEventSuccessLiveRevealCardLabelPodReveal;

  /// Product copy used by lib/event_success/presentation/event_success_live_reveal_card.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Rotation reveal'**
  String get eventSuccessEventSuccessLiveRevealCardLabelRotationReveal;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Step {value1}/{total} · Round'**
  String eventSuccessEventSuccessHostLiveVisiblecopyStepValue1TotalRound({
    required Object value1,
    required Object total,
  });

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get eventSuccessEventSuccessHostLiveVisiblecopyRound;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Round in play'**
  String get eventSuccessEventSuccessHostLiveTitleRoundInPlay;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Keep rounds tight; reveal scores between each. Swap anyone sitting out into a team.'**
  String get eventSuccessEventSuccessHostLiveVisiblecopyKeepRoundsTightReveal;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_live.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Attendees see: Guests see the current round and the live scoreboard.'**
  String get eventSuccessEventSuccessHostLiveVisiblecopyAttendeesSeeGuestsSee;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get eventSuccessEventSuccessHostSharedLabelSetup;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get eventSuccessEventSuccessHostSharedLabelLive;

  /// Product copy used by lib/event_success/presentation/host_parts/event_success_host_shared.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get eventSuccessEventSuccessHostSharedLabelReport;

  /// Product copy used by lib/events/presentation/widgets/event_stats_grid.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get eventsEventStatsGridVisiblecopyKm;

  /// Product copy used by lib/events/presentation/widgets/event_stats_grid.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get eventsEventStatsGridLabelDistance;

  /// Product copy used by lib/events/presentation/widgets/event_stats_grid.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get eventsEventStatsGridLabelActivity;

  /// Product copy used by lib/events/presentation/widgets/event_stats_grid.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Spots taken'**
  String get eventsEventStatsGridLabelSpotsTaken;

  /// Product copy used by lib/events/presentation/widgets/event_stats_grid.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Pace level'**
  String get eventsEventStatsGridVisiblecopyPaceLevel;

  /// Product copy used by lib/events/presentation/widgets/event_stats_grid.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Skill level'**
  String get eventsEventStatsGridVisiblecopySkillLevel;

  /// Product copy used by lib/events/presentation/widgets/event_stats_grid.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get eventsEventStatsGridVisiblecopyIntensity;

  /// Product copy used by lib/events/presentation/widgets/event_stats_grid.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get eventsEventStatsGridVisiblecopyEnergy;

  /// Product copy used by lib/events/presentation/event_detail_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{rating} FROM {reviewCount} ORGANIZER REVIEWS'**
  String eventsEventDetailScreenStateVisiblecopyClubReviewSummary({
    required Object rating,
    required Object reviewCount,
  });

  /// Product copy used by lib/dashboard/presentation/dashboard_full_view_model.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Let\'\'s find your first event'**
  String get dashboardDashboardFullViewModelTitleLetSFindYour;

  /// Product copy used by lib/dashboard/presentation/dashboard_full_view_model.dart (title).
  ///
  /// In en, this message translates to:
  /// **'{dashboardGreeting}, {name}'**
  String dashboardDashboardFullViewModelTitleDashboardgreetingName({
    required Object dashboardGreeting,
    required Object name,
  });

  /// Product copy used by lib/dashboard/presentation/dashboard_full_view_model.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get dashboardDashboardFullViewModelVisiblecopyMorning;

  /// Product copy used by lib/dashboard/presentation/dashboard_full_view_model.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get dashboardDashboardFullViewModelVisiblecopyAfternoon;

  /// Product copy used by lib/dashboard/presentation/dashboard_full_view_model.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get dashboardDashboardFullViewModelVisiblecopyEvening;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Explore is still getting set up. Please try again in a moment.'**
  String get coreAppErrorMessageVisiblecopyExploreIsStillGetting;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Connection issue'**
  String get coreAppErrorMessageVisiblecopyConnectionIssue;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get coreAppErrorMessageVisiblecopySignInRequired;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Action unavailable'**
  String get coreAppErrorMessageVisiblecopyActionUnavailable;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Check your details'**
  String get coreAppErrorMessageVisiblecopyCheckYourDetails;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled'**
  String get coreAppErrorMessageVisiblecopyPaymentCancelled;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Payment verification failed'**
  String get coreAppErrorMessageVisiblecopyPaymentVerificationFailed;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get coreAppErrorMessageVisiblecopyPaymentFailed;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Payment unavailable'**
  String get coreAppErrorMessageVisiblecopyPaymentUnavailable;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Event signup unavailable'**
  String get coreAppErrorMessageVisiblecopyEventSignupUnavailable;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get coreAppErrorMessageVisiblecopyUploadFailed;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Action failed'**
  String get coreAppErrorMessageVisiblecopyActionFailed;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Session verification failed'**
  String get coreAppErrorMessageVisiblecopySessionVerificationFailed;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Notifications unavailable'**
  String get coreAppErrorMessageVisiblecopyNotificationsUnavailable;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Update check unavailable'**
  String get coreAppErrorMessageVisiblecopyUpdateCheckUnavailable;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Sign in problem'**
  String get coreAppErrorMessageVisiblecopySignInProblem;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Dashboard unavailable'**
  String get coreAppErrorMessageVisiblecopyDashboardUnavailable;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Explore unavailable'**
  String get coreAppErrorMessageVisiblecopyExploreUnavailable;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Profile unavailable'**
  String get coreAppErrorMessageVisiblecopyProfileUnavailable;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Event unavailable'**
  String get coreAppErrorMessageVisiblecopyEventUnavailable;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Organizer unavailable'**
  String get coreAppErrorMessageVisiblecopyClubUnavailable;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Messages unavailable'**
  String get coreAppErrorMessageVisiblecopyMessagesUnavailable;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Catches unavailable'**
  String get coreAppErrorMessageVisiblecopyCatchesUnavailable;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Payments unavailable'**
  String get coreAppErrorMessageVisiblecopyPaymentsUnavailable;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get coreAppErrorMessageVisiblecopySomethingWentWrong;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get coreAppErrorMessageVisiblecopySignIn;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Try upload again'**
  String get coreAppErrorMessageVisiblecopyTryUploadAgain;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Try payment again'**
  String get coreAppErrorMessageVisiblecopyTryPaymentAgain;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Reload messages'**
  String get coreAppErrorMessageVisiblecopyReloadMessages;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Reload Explore'**
  String get coreAppErrorMessageVisiblecopyReloadExplore;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Reload profile'**
  String get coreAppErrorMessageVisiblecopyReloadProfile;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Reload event'**
  String get coreAppErrorMessageVisiblecopyReloadEvent;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Reload organizer'**
  String get coreAppErrorMessageVisiblecopyReloadClub;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Reload catches'**
  String get coreAppErrorMessageVisiblecopyReloadCatches;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Reload payments'**
  String get coreAppErrorMessageVisiblecopyReloadPayments;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get coreAppErrorMessageVisiblecopyTryAgain;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Profile not found'**
  String get coreAppErrorMessageVisiblecopyProfileNotFound;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Explore item not found'**
  String get coreAppErrorMessageVisiblecopyExploreItemNotFound;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Event not found'**
  String get coreAppErrorMessageVisiblecopyEventNotFound;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Organizer not found'**
  String get coreAppErrorMessageVisiblecopyClubNotFound;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Chat not found'**
  String get coreAppErrorMessageVisiblecopyChatNotFound;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Catches not found'**
  String get coreAppErrorMessageVisiblecopyCatchesNotFound;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Payment not found'**
  String get coreAppErrorMessageVisiblecopyPaymentNotFound;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get coreAppErrorMessageVisiblecopyNotFound;

  /// Product copy used by lib/hosts/presentation/host_operations_screen_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Organizers'**
  String get hostsHostOperationsScreenStateTitleClubs;

  /// Product copy used by lib/image_uploads/shared/profile_photo_editor_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'No prompt'**
  String get imageUploadsProfilePhotoEditorScreenLabelNoPrompt;

  /// Product copy used by lib/public_profile/presentation/public_profile_screen_state.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get publicProfilePublicProfileScreenStateTitleProfile;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get hostsCreateEventScreenVisiblecopyUnsavedChanges;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_screen.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Would you like to save a draft?'**
  String get hostsCreateEventScreenVisiblecopyYouHaveUnsavedChanges;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get hostsCreateEventScreenLabelDiscard;

  /// Product copy used by lib/hosts/presentation/event_management/create/create_event_screen.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get hostsCreateEventScreenLabelSaveDraft;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/draft_picker_sheet.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Delete draft?'**
  String get hostsDraftPickerSheetVisiblecopyDeleteDraft;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/draft_picker_sheet.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get hostsDraftPickerSheetLabelCancel;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/draft_picker_sheet.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get hostsDraftPickerSheetLabelDelete;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/draft_picker_sheet.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{summary}\".'**
  String hostsDraftPickerSheetVisiblecopyThisWillPermanentlyDelete({
    required Object summary,
  });

  /// Product copy used by lib/swipes/shared/profile_surface/profile_card_content.dart (text).
  ///
  /// In en, this message translates to:
  /// **'{height} cm'**
  String swipesProfileCardContentTextHeightCm({required Object height});

  /// Product copy used by lib/swipes/shared/profile_surface/profile_card_content.dart (text).
  ///
  /// In en, this message translates to:
  /// **'{occupation} at {company}'**
  String swipesProfileCardContentTextOccupationAtCompany({
    required Object occupation,
    required Object company,
  });

  /// Product copy used by lib/onboarding/presentation/pages/photos_page_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Finish uploading your photos to continue.'**
  String get onboardingPhotosPageStateVisiblecopyFinishUploadingYourPhotos;

  /// Product copy used by lib/onboarding/presentation/pages/photos_page_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'1 more photo'**
  String get onboardingPhotosPageStateLabel1MorePhoto;

  /// Product copy used by lib/onboarding/presentation/pages/photos_page_state.dart (label).
  ///
  /// In en, this message translates to:
  /// **'{remainingPhotos} more photos'**
  String onboardingPhotosPageStateLabelRemainingphotosMorePhotos({
    required Object remainingPhotos,
  });

  /// Product copy used by lib/onboarding/presentation/pages/photos_page_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Add {label} to continue.'**
  String onboardingPhotosPageStateVisiblecopyAddLabelToContinue({
    required Object label,
  });

  /// Product copy used by lib/onboarding/presentation/pages/photos_page_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'This only gates Catches. Event booking stays available.'**
  String get onboardingPhotosPageStateVisiblecopyThisOnlyGatesCatches;

  /// Product copy used by lib/onboarding/presentation/pages/photos_page_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Running photos boost catches by 2.3x.'**
  String get onboardingPhotosPageStateVisiblecopyRunningPhotosBoostCatches;

  /// Product copy used by lib/hosts/presentation/host_event_manage_screen_state.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'{priceInPaise} gross estimate · {checkedInCount} attended · {noShowCount} no-shows · {waitlistCount} waitlisted.'**
  String
  hostsHostEventManageScreenStateVisiblecopyPriceinpaiseGrossEstimateCheckedincount({
    required Object priceInPaise,
    required Object checkedInCount,
    required Object noShowCount,
    required Object waitlistCount,
  });

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get coreAppErrorMessageVisiblecopySomethingWentWrongPlease;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Unable to check the latest app configuration right now.'**
  String get coreAppErrorMessageVisiblecopyUnableToCheckThe;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Unable to verify this app session. Please try again.'**
  String get coreAppErrorMessageVisiblecopyUnableToVerifyThis;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Unable to update notification settings right now.'**
  String get coreAppErrorMessageVisiblecopyUnableToUpdateNotification;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue.'**
  String get coreAppErrorMessageVisiblecopyPleaseSignInTo;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Payment was cancelled.'**
  String get coreAppErrorMessageVisiblecopyPaymentWasCancelled;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Please try again.'**
  String get coreAppErrorMessageVisiblecopyPaymentFailedPleaseTry;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Payment could not be verified. Please contact support.'**
  String get coreAppErrorMessageVisiblecopyPaymentCouldNotBe;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Paid bookings are only available on Android and iOS.'**
  String get coreAppErrorMessageVisiblecopyPaidBookingsAreOnly;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'We could not find what you requested.'**
  String get coreAppErrorMessageVisiblecopyWeCouldNotFind;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'That image is too large. Please choose a smaller image.'**
  String get coreAppErrorMessageVisiblecopyThatImageIsToo;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Please choose an image file.'**
  String get coreAppErrorMessageVisiblecopyPleaseChooseAnImage;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'That image could not be uploaded. Please choose another image.'**
  String get coreAppErrorMessageVisiblecopyThatImageCouldNot;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number.'**
  String get coreAppErrorMessageVisiblecopyPleaseEnterAValid;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'That code is invalid. Please try again.'**
  String get coreAppErrorMessageVisiblecopyThatCodeIsInvalid;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'That code expired. Please request a new one.'**
  String get coreAppErrorMessageVisiblecopyThatCodeExpiredPlease;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'We are having trouble connecting. Please check your internet and try again.'**
  String get coreAppErrorMessageVisiblecopyWeAreHavingTrouble;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Please try again.'**
  String get coreAppErrorMessageVisiblecopyTheRequestTimedOut;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a bit and try again.'**
  String get coreAppErrorMessageVisiblecopyTooManyAttemptsPlease;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to do that.'**
  String get coreAppErrorMessageVisiblecopyYouDoNotHave;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'This already exists.'**
  String get coreAppErrorMessageVisiblecopyThisAlreadyExists;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'The operation could not be completed. Please try again.'**
  String get coreAppErrorMessageVisiblecopyTheOperationCouldNot;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'This data is still getting set up. Please try again in a moment.'**
  String get coreAppErrorMessageVisiblecopyThisDataIsStill;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'This sign-in method is not enabled.'**
  String get coreAppErrorMessageVisiblecopyThisSignInMethod;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get coreAppErrorMessageVisiblecopyThisAccountHasBeen;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Unable to finish sign-in on this device. Please restart the app and request a new code.'**
  String get coreAppErrorMessageVisiblecopyUnableToFinishSign;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Verification was cancelled. Please try again when ready.'**
  String get coreAppErrorMessageVisiblecopyVerificationWasCancelledPlease;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Unable to complete the verification check. Please close the verification window and try again.'**
  String get coreAppErrorMessageVisiblecopyUnableToCompleteThe;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Please complete your basic profile details before continuing.'**
  String get coreAppErrorMessageVisiblecopyPleaseCompleteYourBasic;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Please choose your dating preferences before continuing.'**
  String get coreAppErrorMessageVisiblecopyPleaseChooseYourDating;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Please choose who you want to see before continuing.'**
  String get coreAppErrorMessageVisiblecopyPleaseChooseWhoYou;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Please add a valid phone number before continuing.'**
  String get coreAppErrorMessageVisiblecopyPleaseAddAValid;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Please verify your phone number before continuing.'**
  String get coreAppErrorMessageVisiblecopyPleaseVerifyYourPhone;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Please complete your access application.'**
  String get coreAppErrorMessageVisiblecopyPleaseCompleteYourAccess;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'This access application is already locked for review.'**
  String get coreAppErrorMessageVisiblecopyThisAccessApplicationIs;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Only an organizer manager can edit this organizer.'**
  String get coreAppErrorMessageVisiblecopyOnlyAClubHost;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Only the organizer owner can edit organizer details.'**
  String get coreAppErrorMessageVisiblecopyOnlyTheClubOwner;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Choose an organizer before creating the event.'**
  String get coreAppErrorMessageVisiblecopyChooseAClubBefore;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Add a meeting location before creating the event.'**
  String get coreAppErrorMessageVisiblecopyAddAMeetingLocation;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Profiles are taking too long to load. Please check your connection and try again.'**
  String get coreAppErrorMessageVisiblecopyProfilesAreTakingToo;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Profile changed while saving. Please try again.'**
  String get coreAppErrorMessageVisiblecopyProfileChangedWhileSaving;

  /// Product copy used by lib/core/app_error_message.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Check the highlighted details and try again.'**
  String get coreAppErrorMessageVisiblecopyCheckTheHighlightedDetails;

  /// Product copy used by lib/core/widgets/catch_field.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Select {toLowerCase}'**
  String coreCatchFieldVisiblecopySelectTolowercase({
    required Object toLowerCase,
  });

  /// Canonical empty editable-row copy used by lib/core/widgets/catch_field.dart (visibleCopy).
  ///
  /// In en, this message translates to:
  /// **'Add {fieldLabel}'**
  String coreCatchFieldVisiblecopyAddFieldLabel({required Object fieldLabel});

  /// Compact visible label attached to the Explore map distance ring.
  ///
  /// In en, this message translates to:
  /// **'Within {distanceKm} km'**
  String exploreExploreMapScreenLabelWithinDistance({required int distanceKm});

  /// Function label for the persistent Explore map distance control.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get exploreExploreMapScreenLabelDistance;

  /// Distance-control value when no radius filter is active.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get exploreExploreMapScreenValueAnyDistance;

  /// Distance-control value for an active radius.
  ///
  /// In en, this message translates to:
  /// **'{distanceKm} km'**
  String exploreExploreMapScreenValueDistanceKm({required int distanceKm});

  /// Explicit action that may request location permission before activating a map radius.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get exploreExploreMapScreenActionUseMyLocation;

  /// Temporary map distance-control label while location resolves.
  ///
  /// In en, this message translates to:
  /// **'Locating'**
  String get exploreExploreMapScreenActionLocating;

  /// Accessible state while the explicit map location request is running.
  ///
  /// In en, this message translates to:
  /// **'Finding your location'**
  String get exploreExploreMapScreenSemanticsLocating;

  /// Accessible label for the persistent map distance control.
  ///
  /// In en, this message translates to:
  /// **'Distance, {distance}. Tap to change'**
  String exploreExploreMapScreenSemanticsDistanceValue({
    required Object distance,
  });

  /// Accessible label for explicit location activation on the map.
  ///
  /// In en, this message translates to:
  /// **'Use my location to set a distance'**
  String get exploreExploreMapScreenSemanticsUseMyLocation;

  /// Accessible hint for tapping the geographic distance-ring label.
  ///
  /// In en, this message translates to:
  /// **'Changes the distance filter'**
  String get exploreExploreMapScreenHintChangeDistance;

  /// Non-blocking feedback when explicit map location activation cannot resolve a coordinate.
  ///
  /// In en, this message translates to:
  /// **'Location is unavailable. You can still browse the map.'**
  String get exploreExploreMapScreenMessageLocationUnavailable;

  /// Recovery feedback when the device-wide location service is disabled.
  ///
  /// In en, this message translates to:
  /// **'Location Services are off. Turn them on in Settings to use a distance ring.'**
  String get exploreExploreMapScreenMessageLocationServicesDisabled;

  /// Recovery feedback when Catch location permission is permanently denied.
  ///
  /// In en, this message translates to:
  /// **'Location access is off for Catch. You can enable it in Settings.'**
  String get exploreExploreMapScreenMessageLocationPermissionDeniedForever;

  /// Action that opens the relevant system settings after a location failure.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get exploreExploreMapScreenActionOpenSettings;

  /// Accessible title for a clustered native map marker.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 event} other{{count} events}}'**
  String eventsEventPinsMapSemanticsEventCluster({required int count});

  /// Tooltip for restoring the Explore map overview after panning or selecting an event.
  ///
  /// In en, this message translates to:
  /// **'Show all events and distance'**
  String get eventsEventPinsMapTooltipShowAllEventsAndDistance;

  /// Map recovery title when an active distance radius has no results.
  ///
  /// In en, this message translates to:
  /// **'No events within {distanceKm} km'**
  String exploreExploreMapScreenTitleNoEventsWithinDistance({
    required int distanceKm,
  });

  /// Map recovery guidance for an empty distance radius.
  ///
  /// In en, this message translates to:
  /// **'Try a wider distance, or show every event in {cityLabel}.'**
  String exploreExploreMapScreenMessageTryWiderOrShowCity({
    required String cityLabel,
  });

  /// Map recovery action that widens the active distance radius.
  ///
  /// In en, this message translates to:
  /// **'Expand to {distanceKm} km'**
  String exploreExploreMapScreenActionExpandToDistance({
    required int distanceKm,
  });

  /// Map recovery action that removes the distance radius.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get exploreExploreMapScreenActionShowAll;

  /// Generic map recovery title when non-distance filters have no results.
  ///
  /// In en, this message translates to:
  /// **'No events match this map'**
  String get exploreExploreMapScreenTitleNoEventsMatchMap;

  /// Generic map recovery guidance for an empty filtered result.
  ///
  /// In en, this message translates to:
  /// **'Change your filters to bring events back into view.'**
  String get exploreExploreMapScreenMessageChangeFiltersToBringEventsBack;

  /// Product copy used by lib/events/presentation/event_location_map_body_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get eventsEventLocationMapBodyScreenTitleLocationUnavailable;

  /// Product copy used by lib/events/presentation/event_location_map_body_screen.dart (message).
  ///
  /// In en, this message translates to:
  /// **'This event does not have an exact pinned starting point yet.'**
  String get eventsEventLocationMapBodyScreenMessageThisEventDoesNot;

  /// Fallback label for a ready Profile Insights data-coverage source whose id is not recognized by the app.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get userAnalyticsUserAnalyticsCopyVisiblecopyAvailable;

  /// Stable Profile Insights label for participant-derived analytics coverage.
  ///
  /// In en, this message translates to:
  /// **'Participant signals'**
  String get userAnalyticsUserAnalyticsCopyDataqualityParticipantSignals;

  /// Stable Profile Insights label for profile-view and photo-performance coverage.
  ///
  /// In en, this message translates to:
  /// **'Profile exposure'**
  String get userAnalyticsUserAnalyticsCopyDataqualityProfileExposure;

  /// Stable Profile Insights label for app-activity analytics coverage.
  ///
  /// In en, this message translates to:
  /// **'App engagement'**
  String get userAnalyticsUserAnalyticsCopyDataqualityAppEngagement;

  /// Stable Profile Insights label for the aggregate analytics data source.
  ///
  /// In en, this message translates to:
  /// **'Analytics source'**
  String get userAnalyticsUserAnalyticsCopyDataqualityAnalyticsSource;

  /// Shared search field placeholder and accessibility label.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get sharedSearchLabel;

  /// Shared destructive delete action label.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get sharedActionDelete;

  /// Shared validation message for a required field.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get sharedValidationRequired;

  /// Shared validation message for an invalid field value.
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get sharedValidationInvalid;

  /// Shared validation message for positive integer inputs.
  ///
  /// In en, this message translates to:
  /// **'Min 1'**
  String get sharedValidationMinimumOne;

  /// Minimum-length validation message for invite codes.
  ///
  /// In en, this message translates to:
  /// **'Min 4 chars'**
  String get sharedValidationInviteCodeMinimum;

  /// Maximum-length validation message for invite codes.
  ///
  /// In en, this message translates to:
  /// **'Max 64 chars'**
  String get sharedValidationInviteCodeMaximum;

  /// Allowed age range for Host event policy inputs.
  ///
  /// In en, this message translates to:
  /// **'18-99'**
  String get sharedValidationAgeRange;

  /// Validation requiring the minimum age not to exceed the maximum.
  ///
  /// In en, this message translates to:
  /// **'<= max'**
  String get sharedValidationMinimumAtMostMaximum;

  /// Validation requiring the maximum age not to be below the minimum.
  ///
  /// In en, this message translates to:
  /// **'>= min'**
  String get sharedValidationMaximumAtLeastMinimum;

  /// Consumer inbox empty-state title before a mutual Catch.
  ///
  /// In en, this message translates to:
  /// **'No catches yet'**
  String get chatsEmptyStateNoCatchesTitle;

  /// Consumer inbox empty-state guidance before a mutual Catch.
  ///
  /// In en, this message translates to:
  /// **'When someone catches you back after a shared event, the conversation opens here with that event as context.'**
  String get chatsEmptyStateNoCatchesMessage;

  /// Host inbox empty-state title.
  ///
  /// In en, this message translates to:
  /// **'No attendee queries yet'**
  String get chatsEmptyStateHostInboxTitle;

  /// Host inbox empty-state guidance.
  ///
  /// In en, this message translates to:
  /// **'Guest and attendee questions will appear here once people reach out about an event.'**
  String get chatsEmptyStateHostInboxMessage;

  /// Consumer chat-search empty-state title.
  ///
  /// In en, this message translates to:
  /// **'No chats match your search'**
  String get chatsEmptyStateNoSearchResultsTitle;

  /// Consumer chat-search empty-state recovery guidance.
  ///
  /// In en, this message translates to:
  /// **'Try another name or clear the search field.'**
  String get chatsEmptyStateNoSearchResultsMessage;

  /// Host inbox search empty-state title.
  ///
  /// In en, this message translates to:
  /// **'No attendee queries match your search'**
  String get chatsEmptyStateNoHostSearchResultsTitle;

  /// Host inbox search empty-state recovery guidance.
  ///
  /// In en, this message translates to:
  /// **'Try another attendee name or clear the search field.'**
  String get chatsEmptyStateNoHostSearchResultsMessage;

  /// Host inbox unread-filter empty-state title.
  ///
  /// In en, this message translates to:
  /// **'No unread queries'**
  String get chatsEmptyStateNoUnreadQueriesTitle;

  /// Host inbox unread-filter empty-state guidance.
  ///
  /// In en, this message translates to:
  /// **'New attendee questions will move here until you open their thread.'**
  String get chatsEmptyStateNoUnreadQueriesMessage;

  /// Explanation below the club share-card action.
  ///
  /// In en, this message translates to:
  /// **'Shares a visual organizer card with the organizer link.'**
  String get clubsClubShareCardFootnote;

  /// Host attribution on a club share card.
  ///
  /// In en, this message translates to:
  /// **'Hosted by {hostName}'**
  String clubsClubShareCardHostedBy({required String hostName});

  /// Opening line of externally shared club copy.
  ///
  /// In en, this message translates to:
  /// **'Check out {clubName} on Catch.'**
  String clubsClubShareTextIntro({required String clubName});

  /// Club owner role label in Host attribution.
  ///
  /// In en, this message translates to:
  /// **'OWNER'**
  String get clubsClubHostRoleOwner;

  /// Club host role label in Host attribution.
  ///
  /// In en, this message translates to:
  /// **'HOST'**
  String get clubsClubHostRoleHost;

  /// Club host role and established-date metadata.
  ///
  /// In en, this message translates to:
  /// **'{role} · EST. {established}'**
  String clubsClubHostEstablishedMeta({
    required String role,
    required String established,
  });

  /// Badge on club schedule events managed by the current Host.
  ///
  /// In en, this message translates to:
  /// **'HOSTED'**
  String get clubsClubScheduleHostedBadge;

  /// Read-only club schedule event action badge.
  ///
  /// In en, this message translates to:
  /// **'VIEW'**
  String get clubsClubScheduleViewBadge;

  /// Primary action on the event invite share sheet.
  ///
  /// In en, this message translates to:
  /// **'Share invite'**
  String get eventsInviteShareButton;

  /// Explanation below the event invite share action.
  ///
  /// In en, this message translates to:
  /// **'Shares a visual invite with the event link.'**
  String get eventsInviteShareFootnote;

  /// Subject for an externally shared event invitation.
  ///
  /// In en, this message translates to:
  /// **'Join me at {eventTitle}'**
  String eventsInviteShareSubject({required String eventTitle});

  /// Opening line when sharing from event details.
  ///
  /// In en, this message translates to:
  /// **'This feels like your kind of plan.'**
  String get eventsInviteShareEventDetailIntro;

  /// Opening line when sharing after booking.
  ///
  /// In en, this message translates to:
  /// **'I just booked this. Come with me?'**
  String get eventsInviteShareBookingIntro;

  /// Opening line for an event referral share.
  ///
  /// In en, this message translates to:
  /// **'I am going to this on Catch and thought of you.'**
  String get eventsInviteShareReferralIntro;

  /// Opening line for a Host private invite.
  ///
  /// In en, this message translates to:
  /// **'You are invited to {eventTitle} from {clubName}.'**
  String eventsInviteShareHostPrivateIntro({
    required String eventTitle,
    required String clubName,
  });

  /// Prompt before a Host private invite link.
  ///
  /// In en, this message translates to:
  /// **'Use this private Catch invite to book your spot:'**
  String get eventsInviteShareHostPrivatePrompt;

  /// Prompt before an event deep link in shared copy.
  ///
  /// In en, this message translates to:
  /// **'Book it on Catch:'**
  String get eventsInviteShareBookingPrompt;

  /// Price label for a free event in shared invite copy.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get eventsInviteShareFree;

  /// Brand descriptor on the event invite share card.
  ///
  /// In en, this message translates to:
  /// **'Curated singles event'**
  String get eventsInviteShareFooter;

  /// Remaining-capacity label on an event share card.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 spot left} other{{count} spots left}}'**
  String eventsInviteShareSpotsLeft({required int count});

  /// Waitlist status on an event share card.
  ///
  /// In en, this message translates to:
  /// **'Waitlist open'**
  String get eventsInviteShareWaitlistOpen;

  /// Open event-tile status.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get eventsTileStatusOpen;

  /// Joined event-tile status.
  ///
  /// In en, this message translates to:
  /// **'You\'\'re in'**
  String get eventsTileStatusJoined;

  /// Saved event-tile status.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get eventsTileStatusSaved;

  /// Recommended event-tile status.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get eventsTileStatusRecommended;

  /// Hosted event-tile status.
  ///
  /// In en, this message translates to:
  /// **'Hosted'**
  String get eventsTileStatusHosted;

  /// Waitlisted event-tile status.
  ///
  /// In en, this message translates to:
  /// **'Waitlisted'**
  String get eventsTileStatusWaitlisted;

  /// Attended event-tile status.
  ///
  /// In en, this message translates to:
  /// **'Attended'**
  String get eventsTileStatusAttended;

  /// Past event-tile status.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get eventsTileStatusPast;

  /// Full event-tile status.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get eventsTileStatusFull;

  /// Ineligible event-tile status.
  ///
  /// In en, this message translates to:
  /// **'Not eligible'**
  String get eventsTileStatusIneligible;

  /// Cancelled event-tile status.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get eventsTileStatusCancelled;

  /// Default heading above personalized event recommendations.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get exploreRecommendationsTitleForYou;

  /// Fallback label for a selected autocomplete result.
  ///
  /// In en, this message translates to:
  /// **'selected place'**
  String get eventsLocationPickerSelectedPlace;

  /// Fallback error when place autocomplete fails.
  ///
  /// In en, this message translates to:
  /// **'Could not search places. Try again.'**
  String get eventsLocationPickerSearchFailure;

  /// Fallback error when place details fail.
  ///
  /// In en, this message translates to:
  /// **'Could not load that place. Try another result.'**
  String get eventsLocationPickerDetailsFailure;

  /// Default title for Event Success prompt cards.
  ///
  /// In en, this message translates to:
  /// **'Social mission'**
  String get eventSuccessSocialMissionTitle;

  /// Host admission-default explanation.
  ///
  /// In en, this message translates to:
  /// **'Anyone eligible can book until the event reaches capacity.'**
  String get hostsAdmissionOpenCapacityDescription;

  /// Host admission-default explanation.
  ///
  /// In en, this message translates to:
  /// **'New invite-only events ask for an event-specific code.'**
  String get hostsAdmissionInviteOnlyDescription;

  /// Host admission-default explanation.
  ///
  /// In en, this message translates to:
  /// **'Straight men and women are kept within one spot of each other.'**
  String get hostsAdmissionBalancedSinglesDescription;

  /// Host admission-default label.
  ///
  /// In en, this message translates to:
  /// **'Fixed cohort caps'**
  String get hostsAdmissionFixedCohortCapsLabel;

  /// Host admission-default explanation.
  ///
  /// In en, this message translates to:
  /// **'Open booking with optional straight men and straight women caps.'**
  String get hostsAdmissionFixedCohortCapsDescription;

  /// Host form validation for an invalid optional email.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get hostsValidationEnterValidEmail;

  /// Host professional-profile display-name validation.
  ///
  /// In en, this message translates to:
  /// **'Enter a display name.'**
  String get hostsValidationEnterDisplayName;

  /// Active Host professional-profile status.
  ///
  /// In en, this message translates to:
  /// **'Active professional profile'**
  String get hostsProfileStatusActive;

  /// Pending Host professional-profile status.
  ///
  /// In en, this message translates to:
  /// **'Profile pending review'**
  String get hostsProfileStatusPending;

  /// Suspended Host professional-profile status.
  ///
  /// In en, this message translates to:
  /// **'Profile suspended'**
  String get hostsProfileStatusSuspended;

  /// Pending detail for a Host event cancellation.
  ///
  /// In en, this message translates to:
  /// **'Cancelling...'**
  String get hostsEventActionCancelling;

  /// Concise Host event cancellation consequence.
  ///
  /// In en, this message translates to:
  /// **'Keeps records · notifies guests'**
  String get hostsEventActionCancelDetail;

  /// Pending detail for a Host event deletion.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get hostsEventActionDeleting;

  /// Concise Host event deletion consequence.
  ///
  /// In en, this message translates to:
  /// **'Permanent removal'**
  String get hostsEventActionDeleteDetail;

  /// Primary action for saving Host event edits.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get hostsEventEditSaveChanges;

  /// Success message after Host event edits are saved.
  ///
  /// In en, this message translates to:
  /// **'Event updated.'**
  String get hostsEventEditUpdated;

  /// Validation message for a missing event starting point.
  ///
  /// In en, this message translates to:
  /// **'Pin a starting point before saving.'**
  String get hostsEventEditMissingStartingPoint;

  /// Validation message for an invalid Host event schedule.
  ///
  /// In en, this message translates to:
  /// **'Event start must be in the future.'**
  String get hostsEventEditInvalidSchedule;

  /// Launch-access city validation message.
  ///
  /// In en, this message translates to:
  /// **'Please choose your city'**
  String get launchAccessValidationChooseCity;

  /// Launch-access event-type validation message.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one event type'**
  String get launchAccessValidationChooseEventType;

  /// Launch-access availability validation message.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one time'**
  String get launchAccessValidationChooseTime;

  /// Launch-access motivation validation message.
  ///
  /// In en, this message translates to:
  /// **'Tell us a little more.'**
  String get launchAccessValidationTellUsMore;

  /// Match celebration detail after a mutual like.
  ///
  /// In en, this message translates to:
  /// **'{name} liked you back.'**
  String matchesCelebrationLikedBack({required String name});

  /// Action after editing run preferences during booking.
  ///
  /// In en, this message translates to:
  /// **'Continue booking'**
  String get onboardingRunningPrefsContinueBooking;

  /// Action for saving run preferences.
  ///
  /// In en, this message translates to:
  /// **'Save run preferences'**
  String get onboardingRunningPrefsSave;

  /// Run-reason field label during booking.
  ///
  /// In en, this message translates to:
  /// **'Why do you run?'**
  String get onboardingRunningPrefsBookingReasonLabel;

  /// Run-reason field label during onboarding.
  ///
  /// In en, this message translates to:
  /// **'WHY DO YOU RUN?'**
  String get onboardingRunningPrefsReasonLabel;

  /// Run-time preference label during booking.
  ///
  /// In en, this message translates to:
  /// **'FAVOURITE RUN TIMES'**
  String get onboardingRunningPrefsRunTimesLabel;

  /// Event-time preference label during onboarding.
  ///
  /// In en, this message translates to:
  /// **'FAVOURITE EVENT TIMES'**
  String get onboardingRunningPrefsEventTimesLabel;

  /// Validation message when onboarding gender is missing.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender'**
  String get onboardingGenderValidationSelectGender;

  /// Validation message when onboarding match interests are missing.
  ///
  /// In en, this message translates to:
  /// **'Please select who you want to see'**
  String get onboardingGenderValidationSelectInterest;

  /// Guidance when a payment-history booking needs support.
  ///
  /// In en, this message translates to:
  /// **'Please contact Catch support for assistance with this booking.'**
  String get paymentsHistorySupportMessage;

  /// Confirmation after removing an account block.
  ///
  /// In en, this message translates to:
  /// **'Account unblocked.'**
  String get safetyAccountUnblockedMessage;

  /// Canonical zero-price label shared by event cards and Explore.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get eventsEventPriceCopyFree;

  /// Canonical demand-priced event label when only the base price is known.
  ///
  /// In en, this message translates to:
  /// **'From {price}'**
  String eventsEventPriceCopyFromPrice({required Object price});

  /// Fallback price label for external events whose source has no parsed price.
  ///
  /// In en, this message translates to:
  /// **'Price on source'**
  String get eventsEventPriceCopyPriceOnSource;

  /// Shared localized event-count copy for indexes and semantic labels.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No events} =1{1 event} other{{count} events}}'**
  String coreCatchCountCopyEvents({required int count});

  /// Shared distance label for a place less than one kilometre away.
  ///
  /// In en, this message translates to:
  /// **'{meters} m away'**
  String coreCatchDistanceFormatterMetersAway({required int meters});

  /// Shared distance label for a place at least one kilometre away.
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String coreCatchDistanceFormatterKilometersAway({required String distance});

  /// Explore availability label for an event open to the viewer.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get exploreExploreScreenStateAvailabilityOpen;

  /// Explore availability label after a viewer is approved.
  ///
  /// In en, this message translates to:
  /// **'Approved to join'**
  String get exploreExploreScreenStateAvailabilityApprovedToJoin;

  /// Explore availability label when a join request is required.
  ///
  /// In en, this message translates to:
  /// **'Request required'**
  String get exploreExploreScreenStateAvailabilityRequestRequired;

  /// Explore availability label when only the waitlist is open.
  ///
  /// In en, this message translates to:
  /// **'Waitlist open'**
  String get exploreExploreScreenStateAvailabilityWaitlistOpen;

  /// Explore availability label for a full event.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get exploreExploreScreenStateAvailabilityFull;

  /// Explore availability label when viewer-specific inventory is full.
  ///
  /// In en, this message translates to:
  /// **'Your group is full'**
  String get exploreExploreScreenStateAvailabilityFullForYou;

  /// Explore availability label for an invite-only event.
  ///
  /// In en, this message translates to:
  /// **'Invite required'**
  String get exploreExploreScreenStateAvailabilityInviteRequired;

  /// Explore availability label for a members-only event.
  ///
  /// In en, this message translates to:
  /// **'Members only'**
  String get exploreExploreScreenStateAvailabilityMembersOnly;

  /// Explore availability label when run preferences are missing.
  ///
  /// In en, this message translates to:
  /// **'Set preferences'**
  String get exploreExploreScreenStateAvailabilitySetPreferences;

  /// Explore availability label for a past event.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get exploreExploreScreenStateAvailabilityEnded;

  /// Explore availability label for a cancelled event.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get exploreExploreScreenStateAvailabilityCancelled;

  /// Explore availability fallback for an age-restricted event.
  ///
  /// In en, this message translates to:
  /// **'Age restricted'**
  String get exploreExploreScreenStateAvailabilityAgeRestricted;

  /// Explore availability label for a minimum-age restriction.
  ///
  /// In en, this message translates to:
  /// **'Must be {minAge}+'**
  String exploreExploreScreenStateAvailabilityMinimumAge({required int minAge});

  /// Explore availability label for a maximum-age restriction.
  ///
  /// In en, this message translates to:
  /// **'Max age {maxAge}'**
  String exploreExploreScreenStateAvailabilityMaximumAge({required int maxAge});

  /// Explore low-inventory availability label.
  ///
  /// In en, this message translates to:
  /// **'{spots, plural, =1{1 spot left} other{{spots} spots left}}'**
  String exploreExploreScreenStateAvailabilitySpotsLeft({required int spots});

  /// Explore event attendance count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 going} other{{count} going}}'**
  String exploreExploreScreenStateGoingCount({required int count});

  /// Explore attendance and availability decision line.
  ///
  /// In en, this message translates to:
  /// **'{goingLabel} · {availabilityLabel}'**
  String exploreExploreScreenStateGoingAvailability({
    required Object goingLabel,
    required Object availabilityLabel,
  });

  /// Compact club rating and review-count line on Explore cards.
  ///
  /// In en, this message translates to:
  /// **'{rating} · {reviewCount, plural, =0{NO REVIEWS} =1{1 REVIEW} other{{reviewCount} REVIEWS}}'**
  String exploreExploreScreenStateClubRatingReviews({
    required Object rating,
    required int reviewCount,
  });

  /// Composed screen-reader label for an Explore club card.
  ///
  /// In en, this message translates to:
  /// **'{title}, {caption}, {supportingLabel}, {memberCountLabel}, {ratingReviewLabel}'**
  String exploreExploreScreenStateClubCardSemantics({
    required Object title,
    required Object caption,
    required Object supportingLabel,
    required Object memberCountLabel,
    required Object ratingReviewLabel,
  });

  /// Composed screen-reader summary for an external Explore event row.
  ///
  /// In en, this message translates to:
  /// **'{title}, {sourceLabel}, {statusLabel}, {supportingLabel}, {timePriceLabel}, {readOnlySupplyLabel}'**
  String exploreExploreScreenStateExternalEventSemantics({
    required Object title,
    required Object sourceLabel,
    required Object statusLabel,
    required Object supportingLabel,
    required Object timePriceLabel,
    required Object readOnlySupplyLabel,
  });
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
