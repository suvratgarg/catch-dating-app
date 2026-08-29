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

  /// Host bottom navigation label for the event-management tab.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get hostNavigationEvents;

  /// Host bottom navigation label for the organizer CRM directory.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get hostNavigationCustomers;

  /// Host bottom navigation label for conversations, broadcasts, and campaigns.
  ///
  /// In en, this message translates to:
  /// **'Messaging'**
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

  /// Host messaging screen heading.
  ///
  /// In en, this message translates to:
  /// **'Messaging'**
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

  /// Opens the scalable ordered gallery manager.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Manage 1 photo} other{Manage all {count} photos}}'**
  String coreOrderedPhotoPickerActionManageAll({required int count});

  /// Title for the full-screen ordered gallery manager.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get coreOrderedPhotoPickerTitlePhotoManager;

  /// Photo count shown in the gallery manager header.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo} other{{count} photos}}'**
  String coreOrderedPhotoPickerSubtitlePhotoCount({required int count});

  /// Closes the full-screen gallery manager.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get coreOrderedPhotoPickerActionDone;

  /// Explains cover-photo semantics in the gallery manager.
  ///
  /// In en, this message translates to:
  /// **'This is the first image guests see. Choose any gallery photo as the cover.'**
  String get coreOrderedPhotoPickerBodyCoverPhoto;

  /// Title for the ordered gallery grid.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get coreOrderedPhotoPickerTitleGallery;

  /// Adds more images to an unbounded Host gallery.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get coreOrderedPhotoPickerActionAddPhotos;

  /// Tooltip for the per-photo action menu.
  ///
  /// In en, this message translates to:
  /// **'Photo options'**
  String get coreOrderedPhotoPickerActionPhotoOptions;

  /// Moves a gallery image to the cover position.
  ///
  /// In en, this message translates to:
  /// **'Set as cover'**
  String get coreOrderedPhotoPickerActionSetAsCover;

  /// Moves a gallery image one position earlier.
  ///
  /// In en, this message translates to:
  /// **'Move earlier'**
  String get coreOrderedPhotoPickerActionMoveEarlier;

  /// Moves a gallery image one position later.
  ///
  /// In en, this message translates to:
  /// **'Move later'**
  String get coreOrderedPhotoPickerActionMoveLater;

  /// Removes an image from a Host gallery.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get coreOrderedPhotoPickerActionRemove;

  /// Status shown on a Host gallery image while it uploads.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get coreOrderedPhotoPickerStatusUploading;

  /// Per-photo upload progress in the shared ordered photo picker.
  ///
  /// In en, this message translates to:
  /// **'Uploading… {percent}%'**
  String coreOrderedPhotoPickerStatusUploadingProgress({required int percent});

  /// Status for a staged photo that will upload when the user saves.
  ///
  /// In en, this message translates to:
  /// **'Ready to upload'**
  String get coreOrderedPhotoPickerStatusQueued;

  /// Status shown on a Host gallery image after an upload failure.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get coreOrderedPhotoPickerStatusUploadFailed;

  /// Retries a failed Host gallery upload.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get coreOrderedPhotoPickerActionRetry;

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

  /// Product copy used by lib/event_success/presentation/event_success_companion_screen.dart (title).
  ///
  /// In en, this message translates to:
  /// **'Event companion'**
  String get eventSuccessEventSuccessCompanionScreenTitleEventCompanion;

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

  /// Host setting for the end-of-event conversation graph consent default.
  ///
  /// In en, this message translates to:
  /// **'Conversation check defaults'**
  String get eventSuccessEventSuccessSetupBodyTitleConversationCheckDefaults;

  /// Opt-in conversation graph mode label.
  ///
  /// In en, this message translates to:
  /// **'Ask everyone to choose'**
  String get eventSuccessEventSuccessSetupBodyLabelAskEveryoneToChoose;

  /// Opt-in conversation graph mode explanation.
  ///
  /// In en, this message translates to:
  /// **'Assigned people appear first as suggestions, but nobody is selected.'**
  String
  get eventSuccessEventSuccessSetupBodyTextAssignedPeopleAppearFirstButNobodyIsSelected;

  /// Opt-out conversation graph mode label.
  ///
  /// In en, this message translates to:
  /// **'Preselect assigned people'**
  String get eventSuccessEventSuccessSetupBodyLabelPreselectAssignedPeople;

  /// Opt-out conversation graph mode explanation.
  ///
  /// In en, this message translates to:
  /// **'Assigned people start selected; attendees can remove anyone before saving.'**
  String
  get eventSuccessEventSuccessSetupBodyTextAssignedPeopleStartSelectedAndCanBeRemoved;

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

  /// Primary saved event-format row in Event Success setup.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get eventSuccessEventSuccessSetupBodyTitleFormat;

  /// Opens the advanced Event Success module controls after the format summary.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get eventSuccessEventSuccessSetupBodyLabelCustomizeTools;

  /// Closes the Event Success module controls without changing their values.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get eventSuccessEventSuccessSetupBodyLabelDoneCustomizing;

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

  /// Failure feedback when the device cannot open walking directions.
  ///
  /// In en, this message translates to:
  /// **'Could not open directions. Please try again.'**
  String get eventsEventLocationMapDirectionsOpenFailed;

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
  /// **'Add as many as you need. The first photo is the cover.'**
  String get hostsCreateClubPhotosPickerTextDragToReorderThe;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'A square logo shown on your organizer profile and events. It stays separate from your gallery.'**
  String get hostsCreateClubPhotosPickerTextASquareLogoShown;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Change organizer logo'**
  String get hostsCreateClubPhotosPickerLabelChangeClubProfileImage;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Add organizer logo'**
  String get hostsCreateClubPhotosPickerLabelAddClubProfileImage;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get hostsCreateClubPhotosPickerTextAddImage;

  /// Adds the organizer logo, separate from gallery media.
  ///
  /// In en, this message translates to:
  /// **'Add logo'**
  String get hostsCreateClubPhotosPickerActionAddLogo;

  /// Replaces the organizer logo.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get hostsCreateClubPhotosPickerActionReplaceLogo;

  /// Removes the organizer logo without affecting gallery photos.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get hostsCreateClubPhotosPickerActionRemoveLogo;

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
  /// **'Event name'**
  String get hostsEventDetailsStepTitleEventName;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_details_step.dart (placeholder).
  ///
  /// In en, this message translates to:
  /// **'Friday night social'**
  String get hostsEventDetailsStepPlaceholderEventName;

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

  /// Explains the external booking companion flow during event creation.
  ///
  /// In en, this message translates to:
  /// **'Keep taking bookings wherever you already do. Catch adds the guest-list, check-in, and Event Success layer without replacing your booking platform.'**
  String get hostsEventDetailsStepExternalIntro;

  /// Field title for the event's external booking provider.
  ///
  /// In en, this message translates to:
  /// **'Booking platform'**
  String get hostsEventDetailsStepExternalProviderTitle;

  /// Catch booking-platform option in external companion event creation.
  ///
  /// In en, this message translates to:
  /// **'Catch'**
  String get hostsEventDetailsStepExternalProviderCatch;

  /// Generic booking-platform option in external companion event creation.
  ///
  /// In en, this message translates to:
  /// **'Another booking platform'**
  String get hostsEventDetailsStepExternalProviderOther;

  /// Luma booking-platform option in external companion event creation.
  ///
  /// In en, this message translates to:
  /// **'Luma'**
  String get hostsEventDetailsStepExternalProviderLuma;

  /// Eventbrite booking-platform option in external companion event creation.
  ///
  /// In en, this message translates to:
  /// **'Eventbrite'**
  String get hostsEventDetailsStepExternalProviderEventbrite;

  /// Partiful booking-platform option in external companion event creation.
  ///
  /// In en, this message translates to:
  /// **'Partiful'**
  String get hostsEventDetailsStepExternalProviderPartiful;

  /// POSH booking-platform option in external companion event creation.
  ///
  /// In en, this message translates to:
  /// **'POSH'**
  String get hostsEventDetailsStepExternalProviderPosh;

  /// BookMyShow booking-platform option in external companion event creation.
  ///
  /// In en, this message translates to:
  /// **'BookMyShow'**
  String get hostsEventDetailsStepExternalProviderBookMyShow;

  /// District booking-platform option in external companion event creation.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get hostsEventDetailsStepExternalProviderDistrict;

  /// SortMyScene booking-platform option in external companion event creation.
  ///
  /// In en, this message translates to:
  /// **'SortMyScene'**
  String get hostsEventDetailsStepExternalProviderSortMyScene;

  /// Airbnb Experiences booking-platform option in external companion event creation.
  ///
  /// In en, this message translates to:
  /// **'Airbnb Experiences'**
  String get hostsEventDetailsStepExternalProviderAirbnbExperiences;

  /// Optional external booking page URL field title.
  ///
  /// In en, this message translates to:
  /// **'Booking page'**
  String get hostsEventDetailsStepExternalEventUrlTitle;

  /// Placeholder for an external booking page URL.
  ///
  /// In en, this message translates to:
  /// **'https://your-booking-platform.com/event'**
  String get hostsEventDetailsStepExternalEventUrlPlaceholder;

  /// Validation error for an invalid external booking URL.
  ///
  /// In en, this message translates to:
  /// **'Enter a secure https URL'**
  String get hostsEventDetailsStepExternalEventUrlInvalid;

  /// Optional external event identifier field title.
  ///
  /// In en, this message translates to:
  /// **'Booking reference'**
  String get hostsEventDetailsStepExternalEventIdTitle;

  /// Placeholder for an external event identifier.
  ///
  /// In en, this message translates to:
  /// **'Event ID or internal reference'**
  String get hostsEventDetailsStepExternalEventIdPlaceholder;

  /// Field title for how runtime visitors missing from the roster are handled.
  ///
  /// In en, this message translates to:
  /// **'Unlisted guests'**
  String get hostsEventDetailsStepExternalWalkInTitle;

  /// Walk-in policy label that denies guests not present on the roster.
  ///
  /// In en, this message translates to:
  /// **'Roster only'**
  String get hostsEventDetailsStepExternalWalkInDeny;

  /// Walk-in policy label that creates a host approval request.
  ///
  /// In en, this message translates to:
  /// **'Ask me to approve them'**
  String get hostsEventDetailsStepExternalWalkInApproval;

  /// Walk-in policy label that automatically creates an attendee record.
  ///
  /// In en, this message translates to:
  /// **'Allow them automatically'**
  String get hostsEventDetailsStepExternalWalkInAutomatic;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_policy_step.dart (Text).
  ///
  /// In en, this message translates to:
  /// **'Configure who can book, how waitlists open, what attendees pay, and what happens if plans change.'**
  String get hostsEventPolicyStepTextConfigureWhoCanBook;

  /// Rules-step intro for externally booked events.
  ///
  /// In en, this message translates to:
  /// **'Set the operational capacity, age range, and on-site pairing inventory. Bookings, payments, refunds, and cancellations stay with the external provider.'**
  String get hostsEventPolicyStepExternalOperationsIntro;

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
  /// **'Refresh'**
  String get hostsHostPaymentAccountCardLabelRefresh;

  /// Razorpay Route provider subtitle.
  ///
  /// In en, this message translates to:
  /// **'Powered by Razorpay Route'**
  String get hostsHostPaymentAccountCardSubtitlePoweredByRazorpay;

  /// Starts Razorpay Route setup.
  ///
  /// In en, this message translates to:
  /// **'Set up Razorpay'**
  String get hostsHostPaymentAccountCardLabelContinueToRazorpay;

  /// Explains Razorpay Route setup.
  ///
  /// In en, this message translates to:
  /// **'Catch uses Razorpay Route for INR payouts. Provide the legal, stakeholder, and bank details Razorpay needs to review your linked account.'**
  String get hostsHostPaymentAccountCardTextCatchPaysIndiaHostsThrough;

  /// Marks the recommended payout provider.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get hostsHostPaymentAccountCardLabelRecommended;

  /// Razorpay provider name.
  ///
  /// In en, this message translates to:
  /// **'Razorpay'**
  String get hostsHostPaymentAccountCardTitleRazorpay;

  /// Confirms provider-side Razorpay Route account activation without claiming settlement release.
  ///
  /// In en, this message translates to:
  /// **'Razorpay payout account is ready'**
  String get hostsHostPaymentAccountCardTitleRazorpayPayoutAccountReady;

  /// Stripe provider name.
  ///
  /// In en, this message translates to:
  /// **'Stripe'**
  String get hostsHostPaymentAccountCardTitleStripe;

  /// Razorpay provider summary.
  ///
  /// In en, this message translates to:
  /// **'Razorpay Route account setup for INR payouts in India.'**
  String get hostsHostPaymentAccountCardBodyRazorpayInr;

  /// Stripe provider summary.
  ///
  /// In en, this message translates to:
  /// **'Non-INR checkout and international payouts.'**
  String get hostsHostPaymentAccountCardBodyStripeInternational;

  /// Razorpay legal business name field.
  ///
  /// In en, this message translates to:
  /// **'Legal business name'**
  String get hostsHostPaymentAccountCardTitleLegalBusinessName;

  /// Razorpay business type field.
  ///
  /// In en, this message translates to:
  /// **'Business type'**
  String get hostsHostPaymentAccountCardTitleBusinessType;

  /// Razorpay contact name field.
  ///
  /// In en, this message translates to:
  /// **'Contact name'**
  String get hostsHostPaymentAccountCardTitleContactName;

  /// Razorpay business email field.
  ///
  /// In en, this message translates to:
  /// **'Business email'**
  String get hostsHostPaymentAccountCardTitleEmail;

  /// Razorpay business phone field.
  ///
  /// In en, this message translates to:
  /// **'Business phone'**
  String get hostsHostPaymentAccountCardTitlePhone;

  /// Razorpay business description field.
  ///
  /// In en, this message translates to:
  /// **'Business description'**
  String get hostsHostPaymentAccountCardTitleBusinessModel;

  /// Razorpay business PAN field.
  ///
  /// In en, this message translates to:
  /// **'Business PAN'**
  String get hostsHostPaymentAccountCardTitleBusinessPan;

  /// Razorpay settlement account field.
  ///
  /// In en, this message translates to:
  /// **'Bank account number'**
  String get hostsHostPaymentAccountCardTitleBankAccountNumber;

  /// Razorpay IFSC field.
  ///
  /// In en, this message translates to:
  /// **'IFSC code'**
  String get hostsHostPaymentAccountCardTitleIfscCode;

  /// Razorpay beneficiary field.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary name'**
  String get hostsHostPaymentAccountCardTitleBeneficiaryName;

  /// Razorpay stakeholder name field.
  ///
  /// In en, this message translates to:
  /// **'Stakeholder name'**
  String get hostsHostPaymentAccountCardTitleStakeholderName;

  /// Razorpay stakeholder email field.
  ///
  /// In en, this message translates to:
  /// **'Stakeholder email'**
  String get hostsHostPaymentAccountCardTitleStakeholderEmail;

  /// Razorpay stakeholder phone field.
  ///
  /// In en, this message translates to:
  /// **'Stakeholder phone'**
  String get hostsHostPaymentAccountCardTitleStakeholderPhone;

  /// Razorpay stakeholder PAN field.
  ///
  /// In en, this message translates to:
  /// **'Stakeholder PAN'**
  String get hostsHostPaymentAccountCardTitleStakeholderPan;

  /// Razorpay ownership percentage field.
  ///
  /// In en, this message translates to:
  /// **'Ownership percentage'**
  String get hostsHostPaymentAccountCardTitleOwnershipPercent;

  /// Razorpay stakeholder director toggle.
  ///
  /// In en, this message translates to:
  /// **'This stakeholder is a director'**
  String get hostsHostPaymentAccountCardTitleStakeholderDirector;

  /// Razorpay stakeholder executive toggle.
  ///
  /// In en, this message translates to:
  /// **'This stakeholder is an executive'**
  String get hostsHostPaymentAccountCardTitleStakeholderExecutive;

  /// Razorpay terms acceptance toggle.
  ///
  /// In en, this message translates to:
  /// **'Accept Razorpay Route terms'**
  String get hostsHostPaymentAccountCardTitleAcceptRazorpayTerms;

  /// Razorpay terms explanation.
  ///
  /// In en, this message translates to:
  /// **'You confirm these details are accurate and authorize Catch to submit them to Razorpay for linked-account review.'**
  String get hostsHostPaymentAccountCardBodyRazorpayTerms;

  /// Submits Razorpay setup details.
  ///
  /// In en, this message translates to:
  /// **'Submit to Razorpay'**
  String get hostsHostPaymentAccountCardLabelSubmitRazorpay;

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
  /// **'Keep this live code on screen as attendees arrive. It refreshes automatically and cannot be printed for later check-in.'**
  String get hostsHostEventAttendancePanelBodyCheckInQr;

  /// Button label for sharing the no-download attendee runtime link.
  ///
  /// In en, this message translates to:
  /// **'Share attendee link'**
  String get hostsHostEventAttendancePanelRuntimeShareLabel;

  /// Subject used when a host shares the no-download attendee runtime link.
  ///
  /// In en, this message translates to:
  /// **'Your event companion link'**
  String get hostsHostEventAttendancePanelRuntimeShareSubject;

  /// Message used when a host shares the no-download attendee runtime link.
  ///
  /// In en, this message translates to:
  /// **'Open this link to join the event companion. Scan the Host\'\'s live QR at the venue to check in: {runtimeUrl}'**
  String hostsHostEventAttendancePanelRuntimeShareText({
    required String runtimeUrl,
  });

  /// Confirmation after the native share sheet is opened for the attendee runtime link.
  ///
  /// In en, this message translates to:
  /// **'Attendee link ready to share'**
  String get hostsHostEventAttendancePanelRuntimeShareReady;

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
  /// **'Access approved. You\'\'re ready for the next Catch city drop.'**
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
  /// **'How to get help with this booking'**
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

  /// Notification setting for event-scoped Cross Paths invitations.
  ///
  /// In en, this message translates to:
  /// **'Cross Paths invitations'**
  String get safetySettingsScreenTitleCrossPathsInvitations;

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

  /// Privacy setting that gives global consent for eligible Cross Paths event suggestions.
  ///
  /// In en, this message translates to:
  /// **'Show me in Cross Paths'**
  String get safetySettingsScreenTitleShowInCrossPaths;

  /// Explains that global Cross Paths consent does not opt the member into every event.
  ///
  /// In en, this message translates to:
  /// **'Allow Catch to suggest your profile to compatible members at events you separately opt into.'**
  String get safetySettingsScreenBodyShowInCrossPaths;

  /// Section label for event-level Cross Paths consent.
  ///
  /// In en, this message translates to:
  /// **'Cross Paths'**
  String get crossPathsEventConsentSectionTitleCrossPaths;

  /// Event-level Cross Paths consent toggle title.
  ///
  /// In en, this message translates to:
  /// **'Meet people at this event'**
  String get crossPathsEventConsentSectionTitleMeetPeopleAtThisEvent;

  /// Consent disclosure shown before a member enables Cross Paths for one booked event.
  ///
  /// In en, this message translates to:
  /// **'Your profile and plan to attend may be shown to compatible Catch members for this event, and they may send a limited invitation. This is not a public attendee list. You can turn it off before the event; safety and cancellation controls still apply.'**
  String get crossPathsEventConsentSectionBodyConsentDisclosure;

  /// Inline recovery copy when private event consent cannot be loaded.
  ///
  /// In en, this message translates to:
  /// **'Cross Paths settings are unavailable right now. Try again shortly.'**
  String get crossPathsEventConsentSectionBodyConsentUnavailable;

  /// Editorial label above an opted-in person suggestion in Explore.
  ///
  /// In en, this message translates to:
  /// **'People you could meet'**
  String get crossPathsExploreCardLabelPeopleYouCouldMeet;

  /// Feature kicker on the person Polaroid.
  ///
  /// In en, this message translates to:
  /// **'Cross Paths'**
  String get crossPathsExploreCardLabelCrossPaths;

  /// Coarse, privacy-safe compatibility reason for an Explore person suggestion.
  ///
  /// In en, this message translates to:
  /// **'A compatible person at this event'**
  String get crossPathsExploreCardReasonCompatibleAtThisEvent;

  /// Prospective event context shown outside the person Polaroid.
  ///
  /// In en, this message translates to:
  /// **'{firstName} is going to {eventTitle}'**
  String crossPathsExploreCardContextPersonGoingToEvent({
    required String firstName,
    required String eventTitle,
  });

  /// Date and time for the event attached to a person suggestion.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String crossPathsExploreCardEventDateTime({
    required String date,
    required String time,
  });

  /// Action that opens the associated first-party Event Detail screen.
  ///
  /// In en, this message translates to:
  /// **'See the event'**
  String get crossPathsExploreCardActionSeeEvent;

  /// Screen-reader label for the person target on a Cross Paths card.
  ///
  /// In en, this message translates to:
  /// **'View {firstName}’s profile'**
  String crossPathsExploreCardSemanticsViewProfile({required String firstName});

  /// Title for the event-tied person profile preview.
  ///
  /// In en, this message translates to:
  /// **'Cross Paths profile'**
  String get crossPathsProfilePreviewTitle;

  /// Tooltip for closing the Cross Paths profile preview.
  ///
  /// In en, this message translates to:
  /// **'Close profile'**
  String get crossPathsProfilePreviewTooltipClose;

  /// Action that sends a message-free Cross Paths event invitation.
  ///
  /// In en, this message translates to:
  /// **'Invite to this event'**
  String get crossPathsInvitationActionSend;

  /// Action shown when the viewer must book before inviting.
  ///
  /// In en, this message translates to:
  /// **'Join the event to invite'**
  String get crossPathsInvitationActionJoinFirst;

  /// Action that cancels a pending Cross Paths invitation.
  ///
  /// In en, this message translates to:
  /// **'Cancel invitation'**
  String get crossPathsInvitationActionCancel;

  /// Action that opens an accepted temporary event plan.
  ///
  /// In en, this message translates to:
  /// **'Open event plan'**
  String get crossPathsInvitationActionOpenPlan;

  /// Pending Cross Paths invitation status.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent — waiting for a reply'**
  String get crossPathsInvitationStatusPending;

  /// Generic terminal Cross Paths invitation status.
  ///
  /// In en, this message translates to:
  /// **'This invitation is closed'**
  String get crossPathsInvitationStatusClosed;

  /// Final confirmation title before sending an invitation.
  ///
  /// In en, this message translates to:
  /// **'Invite {firstName}?'**
  String crossPathsInvitationConfirmTitle({required String firstName});

  /// Explains the invitation outcome before send.
  ///
  /// In en, this message translates to:
  /// **'They’ll be able to accept or decline. If they accept, you’ll get a private event-planning chat.'**
  String get crossPathsInvitationConfirmBody;

  /// Confirmation action that sends the invitation.
  ///
  /// In en, this message translates to:
  /// **'Send invitation'**
  String get crossPathsInvitationConfirmAction;

  /// Success snackbar after an invitation is sent.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent'**
  String get crossPathsInvitationSentMessage;

  /// Title for the participant-only invitation detail screen.
  ///
  /// In en, this message translates to:
  /// **'Cross Paths invitation'**
  String get crossPathsInvitationScreenTitle;

  /// Explanation shown to an invitation recipient.
  ///
  /// In en, this message translates to:
  /// **'They’d like to make a plan to meet you at this event.'**
  String get crossPathsInvitationScreenIncomingBody;

  /// Explanation shown to an invitation sender.
  ///
  /// In en, this message translates to:
  /// **'Your invitation is waiting for a reply.'**
  String get crossPathsInvitationScreenOutgoingBody;

  /// Explanation for an accepted temporary event plan.
  ///
  /// In en, this message translates to:
  /// **'You both agreed to make a plan for this event.'**
  String get crossPathsInvitationScreenAcceptedBody;

  /// Accepts an invitation and creates the event-plan chat.
  ///
  /// In en, this message translates to:
  /// **'Accept and make a plan'**
  String get crossPathsInvitationScreenActionAccept;

  /// Declines a pending invitation.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get crossPathsInvitationScreenActionDecline;

  /// Closes an accepted event plan for both participants.
  ///
  /// In en, this message translates to:
  /// **'Cancel event plan'**
  String get crossPathsInvitationScreenActionCancelPlan;

  /// Title when an invitation cannot be read or no longer exists.
  ///
  /// In en, this message translates to:
  /// **'Invitation unavailable'**
  String get crossPathsInvitationScreenUnavailableTitle;

  /// Generic privacy-safe invitation unavailable message.
  ///
  /// In en, this message translates to:
  /// **'This invitation may have expired, been cancelled, or become unavailable.'**
  String get crossPathsInvitationScreenUnavailableBody;

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

  /// Failure feedback when a Settings external link cannot be opened.
  ///
  /// In en, this message translates to:
  /// **'Could not open that link. Please try again.'**
  String get safetySettingsScreenExternalLinkOpenFailed;

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
  /// **'Gallery & cover'**
  String get hostsCreateClubPhotosPickerLabelClubPhotos;

  /// Product copy used by lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Organizer logo'**
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

  /// Title for event-specific cover and gallery media.
  ///
  /// In en, this message translates to:
  /// **'Event cover & gallery'**
  String get hostsCreateEventPhotoPickerTitleCoverAndGallery;

  /// Explains that the event uses its organizer logo separately from event media.
  ///
  /// In en, this message translates to:
  /// **'Organizer logo · inherited'**
  String get hostsCreateEventPhotoPickerBodyInheritedLogo;

  /// Explains the unbounded ordered event gallery.
  ///
  /// In en, this message translates to:
  /// **'Add as many event photos as you need. The first photo is the cover.'**
  String get hostsCreateEventPhotoPickerBodyUnlimitedGallery;

  /// Product copy used by lib/hosts/presentation/event_management/widgets/event_details_step.dart (label).
  ///
  /// In en, this message translates to:
  /// **'Activity type'**
  String get hostsEventDetailsStepLabelActivityType;

  /// Labels the operational runbook automatically selected from an event type.
  ///
  /// In en, this message translates to:
  /// **'Catch prepares'**
  String get hostsEventDetailsStepFormatPackTitle;

  /// Summarizes the pace-pod event format pack.
  ///
  /// In en, this message translates to:
  /// **'Pace pods · timed legs · finish sweep'**
  String get hostsEventDetailsStepFormatPackPacePods;

  /// Summarizes the paired-rotation event format pack.
  ///
  /// In en, this message translates to:
  /// **'Pair assignments · timed rounds · ranked outcomes'**
  String get hostsEventDetailsStepFormatPackPairedRotations;

  /// Summarizes the team-rotation event format pack.
  ///
  /// In en, this message translates to:
  /// **'Teams · points by round · standings reveal'**
  String get hostsEventDetailsStepFormatPackTeamRotations;

  /// Summarizes the seated-table event format pack.
  ///
  /// In en, this message translates to:
  /// **'Tables · course pacing · guided prompts'**
  String get hostsEventDetailsStepFormatPackSeatedTable;

  /// Summarizes the free-form mixer event format pack.
  ///
  /// In en, this message translates to:
  /// **'Social groups · guided rounds · reveal moments'**
  String get hostsEventDetailsStepFormatPackFreeFormMixer;

  /// Summarizes the host-led event format pack.
  ///
  /// In en, this message translates to:
  /// **'Host run-of-show · live prompts · event recap'**
  String get hostsEventDetailsStepFormatPackHostLedProgram;

  /// Summarizes the open event format pack.
  ///
  /// In en, this message translates to:
  /// **'Flexible run-of-show · optional groups · event recap'**
  String get hostsEventDetailsStepFormatPackOpenFormat;

  /// Labels the composable route operations section.
  ///
  /// In en, this message translates to:
  /// **'Route plan'**
  String get hostsRouteEventPlanSectionTitle;

  /// Lets a custom event opt into route operations.
  ///
  /// In en, this message translates to:
  /// **'Route-based event'**
  String get hostsRouteEventPlanOptInTitle;

  /// Explains what enabling route operations adds.
  ///
  /// In en, this message translates to:
  /// **'Plan how people move, stop, and stay accounted for.'**
  String get hostsRouteEventPlanOptInBody;

  /// Labels the selected route operations preset.
  ///
  /// In en, this message translates to:
  /// **'Route operations'**
  String get hostsRouteEventPlanSummaryTitle;

  /// Labels how attendees move through a route.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get hostsRouteEventPlanMovementTitle;

  /// Route movement option for running.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get hostsRouteEventPlanMovementRun;

  /// Route movement option for walking.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get hostsRouteEventPlanMovementWalk;

  /// Route movement option for riding.
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get hostsRouteEventPlanMovementRide;

  /// Route movement option for mixed movement modes.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get hostsRouteEventPlanMovementMixed;

  /// Labels the route shape choice.
  ///
  /// In en, this message translates to:
  /// **'Route shape'**
  String get hostsRouteEventPlanShapeTitle;

  /// Route shape option that returns to its start.
  ///
  /// In en, this message translates to:
  /// **'Loop'**
  String get hostsRouteEventPlanShapeLoop;

  /// Route shape option that retraces the outward route.
  ///
  /// In en, this message translates to:
  /// **'Out and back'**
  String get hostsRouteEventPlanShapeOutAndBack;

  /// Route shape option with different start and finish points.
  ///
  /// In en, this message translates to:
  /// **'Point to point'**
  String get hostsRouteEventPlanShapePointToPoint;

  /// Labels how attendees are grouped along the route.
  ///
  /// In en, this message translates to:
  /// **'Group movement'**
  String get hostsRouteEventPlanGroupTitle;

  /// Route grouping option where everyone moves together.
  ///
  /// In en, this message translates to:
  /// **'One group'**
  String get hostsRouteEventPlanGroupTogether;

  /// Route grouping option for multiple pace groups.
  ///
  /// In en, this message translates to:
  /// **'Pace groups'**
  String get hostsRouteEventPlanGroupPaceGroups;

  /// Route grouping option where attendees navigate independently.
  ///
  /// In en, this message translates to:
  /// **'Self-directed'**
  String get hostsRouteEventPlanGroupSelfDirected;

  /// Labels how stops are operated along the route.
  ///
  /// In en, this message translates to:
  /// **'Stop rhythm'**
  String get hostsRouteEventPlanCadenceTitle;

  /// Route cadence option with minimal planned stops.
  ///
  /// In en, this message translates to:
  /// **'Continuous'**
  String get hostsRouteEventPlanCadenceContinuous;

  /// Route cadence option with stops taken as needed.
  ///
  /// In en, this message translates to:
  /// **'Flexible stops'**
  String get hostsRouteEventPlanCadenceFlexible;

  /// Route cadence option with actively operated stops.
  ///
  /// In en, this message translates to:
  /// **'Hosted stops'**
  String get hostsRouteEventPlanCadenceHosted;

  /// Labels the route stop types a host plans to prepare.
  ///
  /// In en, this message translates to:
  /// **'Stops to prepare'**
  String get hostsRouteEventPlanStopsTitle;

  /// Water route stop option.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get hostsRouteEventPlanStopWater;

  /// Route stop option where attendees regroup.
  ///
  /// In en, this message translates to:
  /// **'Regroup point'**
  String get hostsRouteEventPlanStopRegroup;

  /// Hosted venue route stop option.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get hostsRouteEventPlanStopVenue;

  /// Photography route stop option.
  ///
  /// In en, this message translates to:
  /// **'Photo spot'**
  String get hostsRouteEventPlanStopPhoto;

  /// Scenic viewpoint route stop option.
  ///
  /// In en, this message translates to:
  /// **'Viewpoint'**
  String get hostsRouteEventPlanStopViewpoint;

  /// Route hazard marker option.
  ///
  /// In en, this message translates to:
  /// **'Hazard'**
  String get hostsRouteEventPlanStopHazard;

  /// Route turnaround marker option.
  ///
  /// In en, this message translates to:
  /// **'Turnaround'**
  String get hostsRouteEventPlanStopTurnaround;

  /// Labels the operational roles assigned along a route.
  ///
  /// In en, this message translates to:
  /// **'Route roles'**
  String get hostsRouteEventPlanRolesTitle;

  /// Role responsible for leading attendees on the route.
  ///
  /// In en, this message translates to:
  /// **'Route lead'**
  String get hostsRouteEventPlanRoleLead;

  /// Role responsible for accounting for the back of a group.
  ///
  /// In en, this message translates to:
  /// **'Sweep'**
  String get hostsRouteEventPlanRoleSweep;

  /// Role responsible for maintaining a route pace.
  ///
  /// In en, this message translates to:
  /// **'Pacer'**
  String get hostsRouteEventPlanRolePacer;

  /// Role responsible for operating a route stop.
  ///
  /// In en, this message translates to:
  /// **'Stop host'**
  String get hostsRouteEventPlanRoleStopHost;

  /// Role responsible for route safety or crossings.
  ///
  /// In en, this message translates to:
  /// **'Marshal'**
  String get hostsRouteEventPlanRoleMarshal;

  /// Role responsible for photographing the route event.
  ///
  /// In en, this message translates to:
  /// **'Photographer'**
  String get hostsRouteEventPlanRolePhotographer;

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

  /// Compact visual step counter used when large text leaves less header width.
  ///
  /// In en, this message translates to:
  /// **'{clampedStep}/{total}'**
  String coreCatchStepFlowHeaderTextCompactStepClampedstepTotal({
    required int clampedStep,
    required int total,
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
  /// **'Only the Host\'\'s current live QR confirms venue presence. Printed and shared join codes cannot check you in.'**
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

  /// Title for the Host presence and late-arrival control.
  ///
  /// In en, this message translates to:
  /// **'Guest presence'**
  String get eventSuccessEventSuccessHostLiveTitleGuestPresence;

  /// Explains the immutable published-round boundary.
  ///
  /// In en, this message translates to:
  /// **'Presence can update the next prepared round. Published rounds stay unchanged.'**
  String
  get eventSuccessEventSuccessHostLiveSubtitlePresenceNeverChangesPublished;

  /// Host prompt when monitored guest heartbeats expire.
  ///
  /// In en, this message translates to:
  /// **'{count} guests may have left. Regenerate the next round before publishing?'**
  String eventSuccessEventSuccessHostLiveTextGuestsMayHaveLeft({
    required int count,
  });

  /// Host action after reviewing likely departed guests.
  ///
  /// In en, this message translates to:
  /// **'Regenerate next round'**
  String get eventSuccessEventSuccessHostLiveLabelRegenerateNextRound;

  /// Host late-arrival section title.
  ///
  /// In en, this message translates to:
  /// **'Late arrivals'**
  String get eventSuccessEventSuccessHostLiveTitleLateArrivals;

  /// Host action to place or hold a late attendee.
  ///
  /// In en, this message translates to:
  /// **'Place next round'**
  String get eventSuccessEventSuccessHostLiveLabelPlaceNextRound;

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

  /// Aggregate count of respondents who confirmed no conversations; no attendee edges are shown.
  ///
  /// In en, this message translates to:
  /// **'Conversation exclusions'**
  String get eventSuccessEventSuccessHostReportLabelConversationExclusions;

  /// Aggregate conversation graph response coverage for the host recap.
  ///
  /// In en, this message translates to:
  /// **'{conversationGraphResponseCount}/{checkedInCount} responses'**
  String
  eventSuccessEventSuccessHostReportLabelConversationgraphresponsecountCheckedincountResponses({
    required Object conversationGraphResponseCount,
    required Object checkedInCount,
  });

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

  /// Opens the full-screen organizer logo and gallery manager.
  ///
  /// In en, this message translates to:
  /// **'Manage images'**
  String get hostsHostClubEditTabActionManageImages;

  /// Role badge shown on the organizer logo in the compact media summary.
  ///
  /// In en, this message translates to:
  /// **'LOGO'**
  String get hostsHostClubEditTabBadgeLogo;

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

  /// Commits staged organizer gallery and logo changes.
  ///
  /// In en, this message translates to:
  /// **'Save media'**
  String get hostsHostClubEditTabActionSaveMedia;

  /// Discards staged organizer gallery and logo changes.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get hostsHostClubEditTabActionDiscardMedia;

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
  /// **'Create event'**
  String get hostsHostEventsListLabelNewEvent;

  /// CTA to create an external companion event from an existing booking-platform guest list.
  ///
  /// In en, this message translates to:
  /// **'Use guest list'**
  String get hostsHostEventsListLabelUseGuestList;

  /// Explains that event-entry choices lead to a reviewable create flow.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to start. You can review every detail before publishing.'**
  String get hostsHostEventEntrySheetSubtitleChooseHowYouWantToStart;

  /// Section label for resuming existing event work.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get hostsHostEventEntrySheetSectionContinueExisting;

  /// Section label for beginning a new event.
  ///
  /// In en, this message translates to:
  /// **'Start new'**
  String get hostsHostEventEntrySheetSectionStartNew;

  /// Action title for resuming a saved event draft.
  ///
  /// In en, this message translates to:
  /// **'Continue draft'**
  String get hostsHostEventEntrySheetTitleContinueDraft;

  /// Action title for reusing the most recent eligible event setup.
  ///
  /// In en, this message translates to:
  /// **'Repeat last event'**
  String get hostsHostEventEntrySheetTitleRepeatLastEvent;

  /// Action title for creating an event that uses Catch bookings.
  ///
  /// In en, this message translates to:
  /// **'Sell tickets with Catch'**
  String get hostsHostEventEntrySheetTitleSellTicketsWithCatch;

  /// Supporting copy showing how many event drafts are available.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 saved draft} other{{count} saved drafts}}'**
  String hostsHostEventEntrySheetBodySavedDraftCount({required int count});

  /// Supporting copy for the repeat-event action.
  ///
  /// In en, this message translates to:
  /// **'Reuse the setup from {eventTitle} and choose a new date.'**
  String hostsHostEventEntrySheetBodyReuseEventSetup({
    required String eventTitle,
  });

  /// Supporting copy for the Catch-bookings event path.
  ///
  /// In en, this message translates to:
  /// **'Tickets, waitlist, and payments in one place.'**
  String get hostsHostEventEntrySheetBodyTicketsWaitlistAndPayments;

  /// Supporting copy for creating an event from an external guest list.
  ///
  /// In en, this message translates to:
  /// **'Import CSV or XLSX; ticketing stays on your existing platform.'**
  String get hostsHostEventEntrySheetBodyImportCsvOrXlsx;

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

  /// Heading for live and upcoming events in the unified Host Events timeline.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get hostEventsTimelineSchedule;

  /// Heading for completed events in the unified Host Events timeline.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get hostEventsTimelineHistory;

  /// Loads the next cursor page of live or upcoming Host events.
  ///
  /// In en, this message translates to:
  /// **'Load more events'**
  String get hostEventsTimelineLoadMoreSchedule;

  /// Loads the next cursor page of completed Host events.
  ///
  /// In en, this message translates to:
  /// **'Load older events'**
  String get hostEventsTimelineLoadMoreHistory;

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

  /// Title for the privacy-bounded organizer audience summary.
  ///
  /// In en, this message translates to:
  /// **'Past attendee CRM'**
  String get hostsHostOrganizerCrmTitle;

  /// Loading message for the organizer audience summary.
  ///
  /// In en, this message translates to:
  /// **'Counting deduplicated roster history…'**
  String get hostsHostOrganizerCrmLoading;

  /// Error message for the organizer audience summary.
  ///
  /// In en, this message translates to:
  /// **'Audience counts are temporarily unavailable.'**
  String get hostsHostOrganizerCrmUnavailable;

  /// Deduplicated organizer attendee and contact counts.
  ///
  /// In en, this message translates to:
  /// **'{pastCount} past attendees · {repeatCount} repeat attendees · {contactCount} total contacts'**
  String hostsHostOrganizerCrmSummary({
    required Object pastCount,
    required Object repeatCount,
    required Object contactCount,
  });

  /// Label for the Catch in-app audience channel.
  ///
  /// In en, this message translates to:
  /// **'Catch app'**
  String get hostsHostOrganizerCrmCatchApp;

  /// Count of contacts linked to Catch identities.
  ///
  /// In en, this message translates to:
  /// **'{count} linked'**
  String hostsHostOrganizerCrmLinked({required Object count});

  /// Readiness status for the existing in-app event broadcast.
  ///
  /// In en, this message translates to:
  /// **'Current-event broadcasts live'**
  String get hostsHostOrganizerCrmCurrentEventLive;

  /// Label for the organizer WhatsApp channel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get hostsHostOrganizerCrmWhatsapp;

  /// Count of contacts explicitly opted into a channel.
  ///
  /// In en, this message translates to:
  /// **'{count} opted in'**
  String hostsHostOrganizerCrmOptedIn({required Object count});

  /// Readiness status for WhatsApp delivery.
  ///
  /// In en, this message translates to:
  /// **'Business provider + template setup required'**
  String get hostsHostOrganizerCrmWhatsappSetup;

  /// Label for the organizer SMS channel.
  ///
  /// In en, this message translates to:
  /// **'Text message'**
  String get hostsHostOrganizerCrmTextMessage;

  /// Readiness status for SMS delivery in India.
  ///
  /// In en, this message translates to:
  /// **'SMS provider + India DLT setup required'**
  String get hostsHostOrganizerCrmSmsSetup;

  /// Notice shown when the bounded audience summary is truncated.
  ///
  /// In en, this message translates to:
  /// **'This preview is capped at 2,500 roster records.'**
  String get hostsHostOrganizerCrmTruncated;

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

  /// Product copy used by lib/hosts/presentation/host_home_screen_state.dart (emptyBody).
  ///
  /// In en, this message translates to:
  /// **'Create your next event to start filling this list.'**
  String get hostsHostHomeScreenStateEmptybodyCreateYourNextEvent;

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
  /// **'Ask which round they wanted more questions from.'**
  String get eventSuccessEventSuccessConversationCueCopyBodyAskWhichRoundThey;

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

  /// Title for a light-disclosure social mission.
  ///
  /// In en, this message translates to:
  /// **'Easy start'**
  String get eventSuccessSocialMissionTitleLight;

  /// Title for a personal-disclosure social mission.
  ///
  /// In en, this message translates to:
  /// **'A little more personal'**
  String get eventSuccessSocialMissionTitlePersonal;

  /// Title for a reflective-disclosure social mission.
  ///
  /// In en, this message translates to:
  /// **'One level deeper'**
  String get eventSuccessSocialMissionTitleReflective;

  /// Reciprocal personal-disclosure social mission.
  ///
  /// In en, this message translates to:
  /// **'Take turns sharing something you changed your mind about recently and what shifted it.'**
  String get eventSuccessSocialMissionBodyPersonal;

  /// Reciprocal reflective-disclosure social mission.
  ///
  /// In en, this message translates to:
  /// **'Take turns answering: what do you hope the people close to you understand about you?'**
  String get eventSuccessSocialMissionBodyReflective;

  /// Label for a light-disclosure social mission.
  ///
  /// In en, this message translates to:
  /// **'Light disclosure'**
  String get eventSuccessSocialMissionLevelLight;

  /// Label for a personal-disclosure social mission.
  ///
  /// In en, this message translates to:
  /// **'Personal disclosure'**
  String get eventSuccessSocialMissionLevelPersonal;

  /// Label for a reflective-disclosure social mission.
  ///
  /// In en, this message translates to:
  /// **'Reflective disclosure'**
  String get eventSuccessSocialMissionLevelReflective;

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
  /// **'I liked being on a quiz night with you. Which round was your favorite?'**
  String get eventSuccessEventSuccessConversationCueCopyBodyILikedBeingOn;

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

  /// Attendee title for a Host-resolved late-arrival outcome.
  ///
  /// In en, this message translates to:
  /// **'Your next round'**
  String get eventSuccessEventSuccessCompanionBodyScreenTitleLateArrival;

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

  /// Control Room sync status after the current live-guide state is stored.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get eventSuccessControlRoomSynced;

  /// Compact Control Room badge combining live state with persistence status.
  ///
  /// In en, this message translates to:
  /// **'Live now · {syncStatus}'**
  String eventSuccessControlRoomLiveSyncStatus({required String syncStatus});

  /// Control Room sync status while a live-guide mutation is pending.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get eventSuccessControlRoomSyncing;

  /// Control Room persistence status after a live-guide mutation fails.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get eventSuccessControlRoomSaveFailed;

  /// Presentation state for a Control Room that has lost connectivity.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get eventSuccessControlRoomOffline;

  /// Presentation state for a Control Room state conflict that needs host review.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get eventSuccessControlRoomNeedsReview;

  /// Current Control Room run-of-show step and total step count.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total} · {stage}'**
  String eventSuccessControlRoomStepProgress({
    required int current,
    required int total,
    required String stage,
  });

  /// Numbered transition label for a continuous run of show.
  ///
  /// In en, this message translates to:
  /// **'Beat {number}'**
  String eventSuccessEventSuccessHostLiveLabelBeatNumber({required int number});

  /// Numbered transition label for a round-based run of show.
  ///
  /// In en, this message translates to:
  /// **'Round {number}'**
  String eventSuccessEventSuccessHostLiveLabelRoundNumber({
    required int number,
  });

  /// First transition label for a course-based run of show.
  ///
  /// In en, this message translates to:
  /// **'First course'**
  String get eventSuccessEventSuccessHostLiveLabelFirstCourse;

  /// Second transition label for a course-based run of show.
  ///
  /// In en, this message translates to:
  /// **'Second course'**
  String get eventSuccessEventSuccessHostLiveLabelSecondCourse;

  /// Third transition label for a course-based run of show.
  ///
  /// In en, this message translates to:
  /// **'Third course'**
  String get eventSuccessEventSuccessHostLiveLabelThirdCourse;

  /// Fourth transition label for a course-based run of show.
  ///
  /// In en, this message translates to:
  /// **'Fourth course'**
  String get eventSuccessEventSuccessHostLiveLabelFourthCourse;

  /// Fallback numbered transition label for later courses.
  ///
  /// In en, this message translates to:
  /// **'Course {number}'**
  String eventSuccessEventSuccessHostLiveLabelCourseNumber({
    required int number,
  });

  /// Numbered transition label for a segmented run of show.
  ///
  /// In en, this message translates to:
  /// **'Leg {number}'**
  String eventSuccessEventSuccessHostLiveLabelLegNumber({required int number});

  /// Kicker above the next live-guide step in Control Room.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get eventSuccessControlRoomUpNext;

  /// Control Room destination for the operational guest roster.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get eventSuccessControlRoomGuests;

  /// Control Room guest destination summary using roster counts rather than event capacity.
  ///
  /// In en, this message translates to:
  /// **'{checkedIn} checked in · {expected} expected'**
  String eventSuccessControlRoomGuestsSummary({
    required int checkedIn,
    required int expected,
  });

  /// Control Room guest summary when no authoritative expected count is available.
  ///
  /// In en, this message translates to:
  /// **'{checkedIn} checked in'**
  String eventSuccessControlRoomGuestsCheckedInOnly({required int checkedIn});

  /// Live Control Room intervention title when checked-in attendees reach the exclusion threshold.
  ///
  /// In en, this message translates to:
  /// **'Guests need an introduction'**
  String get eventSuccessControlRoomExclusionAlertTitle;

  /// Aggregate-only live alert for attendees at or above the configured cumulative exclusion threshold.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 person has} other {{count} people have}} not been assigned to anyone in {minutes} minutes.'**
  String eventSuccessControlRoomExclusionAlertBody({
    required int count,
    required int minutes,
  });

  /// Control Room destination for lightweight recovery guidance.
  ///
  /// In en, this message translates to:
  /// **'Help & fallback'**
  String get eventSuccessControlRoomHelpFallback;

  /// Summary under the Control Room fallback destination.
  ///
  /// In en, this message translates to:
  /// **'Recovery steps for the room'**
  String get eventSuccessControlRoomHelpFallbackSubtitle;

  /// Primary Control Room action that advances to the named next step.
  ///
  /// In en, this message translates to:
  /// **'Continue to {title}'**
  String eventSuccessControlRoomContinueTo({required String title});

  /// Title for the Control Room fallback guidance sheet.
  ///
  /// In en, this message translates to:
  /// **'Keep the room moving'**
  String get eventSuccessControlRoomFallbackTitle;

  /// Subtitle for the Control Room fallback guidance sheet.
  ///
  /// In en, this message translates to:
  /// **'A simple reset when the plan or connection gets in the way.'**
  String get eventSuccessControlRoomFallbackSubtitle;

  /// First fallback instruction title.
  ///
  /// In en, this message translates to:
  /// **'Stay on this step'**
  String get eventSuccessControlRoomFallbackStayTitle;

  /// First fallback instruction body.
  ///
  /// In en, this message translates to:
  /// **'Keep using the instruction on screen while you settle the room.'**
  String get eventSuccessControlRoomFallbackStayBody;

  /// Second fallback instruction title.
  ///
  /// In en, this message translates to:
  /// **'Take attendance manually'**
  String get eventSuccessControlRoomFallbackGuestsTitle;

  /// Second fallback instruction body.
  ///
  /// In en, this message translates to:
  /// **'Open Guests to check people in or add anyone who was not booked through Catch.'**
  String get eventSuccessControlRoomFallbackGuestsBody;

  /// Third fallback instruction title.
  ///
  /// In en, this message translates to:
  /// **'Continue when ready'**
  String get eventSuccessControlRoomFallbackContinueTitle;

  /// Third fallback instruction body.
  ///
  /// In en, this message translates to:
  /// **'The guide only moves when you tap the primary action, so the room stays in your control.'**
  String get eventSuccessControlRoomFallbackContinueBody;

  /// Dismisses the Control Room fallback guidance sheet.
  ///
  /// In en, this message translates to:
  /// **'Back to Control Room'**
  String get eventSuccessControlRoomFallbackDone;

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

  /// Actionable guidance when a payment-history booking needs support.
  ///
  /// In en, this message translates to:
  /// **'Contact Catch support and include the payment and order IDs shown on this receipt.'**
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

  /// CTA for sending an invitation that can reserve a Cross Paths pair spot.
  ///
  /// In en, this message translates to:
  /// **'Ask to go together'**
  String get crossPathsPairInventoryActionAskTogether;

  /// Fail-safe status explaining that a pair reservation is not a completed booking.
  ///
  /// In en, this message translates to:
  /// **'Your pair spot is held — you are not booked yet'**
  String get crossPathsPairInventoryStatusHeldNotBooked;

  /// Terminal pair hold status.
  ///
  /// In en, this message translates to:
  /// **'This pair spot is no longer held'**
  String get crossPathsPairInventoryStatusNoLongerHeld;

  /// Pair hold countdown copy.
  ///
  /// In en, this message translates to:
  /// **'Complete your booking within {minutes} minutes or this spot returns to the event.'**
  String crossPathsPairInventoryHoldCountdown({required int minutes});

  /// Pair hold expiry guidance.
  ///
  /// In en, this message translates to:
  /// **'You can return to the event to see the latest availability.'**
  String get crossPathsPairInventoryHoldEndedBody;

  /// Independent booking states for both people in a pair plan.
  ///
  /// In en, this message translates to:
  /// **'Your booking: {requesterStatus} · Their booking: {attendeeStatus}'**
  String crossPathsPairInventoryBookingStates({
    required Object requesterStatus,
    required Object attendeeStatus,
  });

  /// Human-readable booking status for the requester while a companion spot is held.
  ///
  /// In en, this message translates to:
  /// **'Held, not booked'**
  String get crossPathsPairInventoryBookingStatusHeld;

  /// Human-readable confirmed booking status in a pair plan.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get crossPathsPairInventoryBookingStatusConfirmed;

  /// Fail-safe human-readable booking status when a pair participant has no confirmed booking.
  ///
  /// In en, this message translates to:
  /// **'Not booked'**
  String get crossPathsPairInventoryBookingStatusNotBooked;

  /// CTA to convert an active pair hold into a booking.
  ///
  /// In en, this message translates to:
  /// **'Complete booking'**
  String get crossPathsPairInventoryActionCompleteBooking;

  /// Recipient state while requester has a pair hold.
  ///
  /// In en, this message translates to:
  /// **'Their place is confirmed. We are waiting for the person who sent the invitation to finish booking.'**
  String get crossPathsPairInventoryWaitingForRequester;

  /// Feedback after starting pair hold checkout.
  ///
  /// In en, this message translates to:
  /// **'Booking started. This plan will open when your place is confirmed.'**
  String get crossPathsPairInventoryBookingStarted;

  /// Host toggle for pair inventory.
  ///
  /// In en, this message translates to:
  /// **'Reserved Cross Paths spots'**
  String get hostsEventPolicyStepTitleCrossPathsPairs;

  /// Host explanation of pair inventory.
  ///
  /// In en, this message translates to:
  /// **'Keep a small part of capacity for people who agree to attend together through Cross Paths.'**
  String get hostsEventPolicyStepBodyCrossPathsPairs;

  /// Host pair capacity field label.
  ///
  /// In en, this message translates to:
  /// **'Reserved companion spots'**
  String get hostsEventPolicyStepTitleCrossPathsPairCapacity;

  /// Title for the standalone Host operational roster.
  ///
  /// In en, this message translates to:
  /// **'Guest roster'**
  String get hostsOperationalRosterTitle;

  /// Explanation of the lifecycle-specific operational guest roster.
  ///
  /// In en, this message translates to:
  /// **'Review arrivals, guest details, source, and status in one operational list.'**
  String get hostsOperationalRosterSubtitle;

  /// Non-blocking loading copy for manager-only live roster enrichment.
  ///
  /// In en, this message translates to:
  /// **'Loading customer labels…'**
  String get hostsOperationalRosterInsightsLoading;

  /// Graceful enrichment failure copy that preserves the primary roster.
  ///
  /// In en, this message translates to:
  /// **'Customer labels are unavailable. Check-in still works.'**
  String get hostsOperationalRosterInsightsUnavailable;

  /// Partial-projection copy that distinguishes missing labels from a missing attendee.
  ///
  /// In en, this message translates to:
  /// **'Some customer labels are still being prepared. The roster remains complete.'**
  String get hostsOperationalRosterInsightsPreparing;

  /// Retries the optional roster insight callable.
  ///
  /// In en, this message translates to:
  /// **'Retry labels'**
  String get hostsOperationalRosterInsightsRetry;

  /// Explains the stable event-relative definition of live roster labels.
  ///
  /// In en, this message translates to:
  /// **'Customer labels use history from before this event began, so they do not change as you check people in.'**
  String get hostsOperationalRosterInsightsCaption;

  /// Honest data-coverage note for Catch-only spend labels.
  ///
  /// In en, this message translates to:
  /// **'Spend labels count only completed, non-refunded Catch payments known before this event. External ticket spend is not guessed.'**
  String get hostsOperationalRosterInsightsSpendFootnote;

  /// All-guests roster insight filter label.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get hostsOperationalRosterInsightsFilterAll;

  /// Roster insight filter label with matching guest count.
  ///
  /// In en, this message translates to:
  /// **'{label} {count}'**
  String hostsOperationalRosterInsightsFilterCount({
    required String label,
    required int count,
  });

  /// Empty state after selecting a live roster insight filter.
  ///
  /// In en, this message translates to:
  /// **'No guests match this label'**
  String get hostsOperationalRosterInsightsFilterEmptyTitle;

  /// Recovery copy for an empty live roster insight filter.
  ///
  /// In en, this message translates to:
  /// **'Choose another label or All to return to the full roster.'**
  String get hostsOperationalRosterInsightsFilterEmptyMessage;

  /// Guest had attended no earlier event for this organizer when the current event began.
  ///
  /// In en, this message translates to:
  /// **'First event'**
  String get hostsOperationalRosterInsightFirstTime;

  /// Guest had attended at least one earlier event for this organizer.
  ///
  /// In en, this message translates to:
  /// **'Returning'**
  String get hostsOperationalRosterInsightReturning;

  /// Guest attended at least three earlier events in the preceding 180 days.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get hostsOperationalRosterInsightRegular;

  /// Returning guest whose last earlier attendance was more than 90 days ago.
  ///
  /// In en, this message translates to:
  /// **'Re-engaging'**
  String get hostsOperationalRosterInsightReEngaging;

  /// Guest attended at least 80 percent of three or more earlier expected events.
  ///
  /// In en, this message translates to:
  /// **'Reliable'**
  String get hostsOperationalRosterInsightReliable;

  /// Guest has at least two earlier no-shows across three or more expected events.
  ///
  /// In en, this message translates to:
  /// **'Needs confirmation'**
  String get hostsOperationalRosterInsightNeedsConfirmation;

  /// Guest has a verified registration or check-in referral.
  ///
  /// In en, this message translates to:
  /// **'Advocate'**
  String get hostsOperationalRosterInsightAdvocate;

  /// Guest referred at least three checked-in attendees in the trailing year.
  ///
  /// In en, this message translates to:
  /// **'Top advocate'**
  String get hostsOperationalRosterInsightHighImpactAdvocate;

  /// Guest has at least one completed, non-refunded Catch payment for this organizer.
  ///
  /// In en, this message translates to:
  /// **'Catch spender'**
  String get hostsOperationalRosterInsightCatchSpender;

  /// Guest is in the top quartile of known Catch spend in a currency and has at least two paid orders.
  ///
  /// In en, this message translates to:
  /// **'Top Catch spender'**
  String get hostsOperationalRosterInsightTopCatchSpender;

  /// Preparation disclosure for importing or manually adding guests.
  ///
  /// In en, this message translates to:
  /// **'Imported guest list'**
  String get hostsOperationalRosterGuestIntakeTitle;

  /// Concise summary of external guest intake options.
  ///
  /// In en, this message translates to:
  /// **'Import a spreadsheet, add guests manually, or connect this event\'\'s booking source.'**
  String get hostsOperationalRosterGuestIntakeBody;

  /// CTA to import a Host roster spreadsheet.
  ///
  /// In en, this message translates to:
  /// **'Import spreadsheet'**
  String get hostsOperationalRosterImport;

  /// CTA to add one operational attendee manually.
  ///
  /// In en, this message translates to:
  /// **'Add guest'**
  String get hostsOperationalRosterAddGuest;

  /// Runtime action to add an unexpected guest without exposing setup-only import controls.
  ///
  /// In en, this message translates to:
  /// **'Add walk-in'**
  String get hostsOperationalRosterAddWalkIn;

  /// CTA to create secure per-event email or WhatsApp roster-forwarding instructions.
  ///
  /// In en, this message translates to:
  /// **'Forward CSV'**
  String get hostsOperationalRosterForwardCsv;

  /// Roster forwarding instruction sheet title.
  ///
  /// In en, this message translates to:
  /// **'Forward this guest list'**
  String get hostsOperationalRosterForwardTitle;

  /// Security and usage guidance for roster forwarding.
  ///
  /// In en, this message translates to:
  /// **'Forward one CSV from the email address or phone number on your Catch Host account. The private address and code expire after 30 days.'**
  String get hostsOperationalRosterForwardSubtitle;

  /// Email roster forwarding row title.
  ///
  /// In en, this message translates to:
  /// **'Forward by email'**
  String get hostsOperationalRosterForwardEmail;

  /// WhatsApp roster forwarding row title.
  ///
  /// In en, this message translates to:
  /// **'Forward on WhatsApp'**
  String get hostsOperationalRosterForwardWhatsapp;

  /// WhatsApp number and expiring event capability instruction.
  ///
  /// In en, this message translates to:
  /// **'Send the CSV to {whatsappNumber} with the message: {whatsappMessage}'**
  String hostsOperationalRosterForwardWhatsappBody({
    required String whatsappNumber,
    required String whatsappMessage,
  });

  /// Status shown when the forwarding provider for a channel is not configured.
  ///
  /// In en, this message translates to:
  /// **'Provider setup required'**
  String get hostsOperationalRosterForwardNotAvailable;

  /// Honest setup boundary when no inbound transport provider is configured.
  ///
  /// In en, this message translates to:
  /// **'Forwarding is implemented but this environment still needs an inbound email or WhatsApp provider. Use Import spreadsheet until an administrator finishes provider setup.'**
  String get hostsOperationalRosterForwardProviderSetup;

  /// Copies one roster forwarding address or instruction.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get hostsOperationalRosterForwardCopy;

  /// Closes the roster forwarding instruction sheet.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get hostsOperationalRosterForwardDone;

  /// Empty operational roster title.
  ///
  /// In en, this message translates to:
  /// **'Your outside roster starts here'**
  String get hostsOperationalRosterEmptyTitle;

  /// Empty operational roster guidance.
  ///
  /// In en, this message translates to:
  /// **'Upload a CSV or XLSX from your ticketing tool, or add guests one at a time.'**
  String get hostsOperationalRosterEmptyMessage;

  /// External booking provider disclosure title.
  ///
  /// In en, this message translates to:
  /// **'Booking source'**
  String get hostsOperationalRosterProviderTitle;

  /// External booking provider disclosure body.
  ///
  /// In en, this message translates to:
  /// **'Bring your {provider} guest list into this roster.'**
  String hostsOperationalRosterProviderBody({required String provider});

  /// Lazy provider setup guidance.
  ///
  /// In en, this message translates to:
  /// **'Open this section to check available import and sync options.'**
  String get hostsOperationalRosterProviderOpenToLoad;

  /// Unknown provider capability fallback.
  ///
  /// In en, this message translates to:
  /// **'Catch could not identify a safe import option for this booking source.'**
  String get hostsOperationalRosterProviderUnavailable;

  /// Connected provider account label.
  ///
  /// In en, this message translates to:
  /// **'Connected calendar'**
  String get hostsOperationalRosterProviderAccount;

  /// Provider field coverage label.
  ///
  /// In en, this message translates to:
  /// **'What syncs'**
  String get hostsOperationalRosterProviderCoverage;

  /// Provider last sync label.
  ///
  /// In en, this message translates to:
  /// **'Last successful sync'**
  String get hostsOperationalRosterProviderLastSync;

  /// Provider never synced status.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get hostsOperationalRosterProviderNeverSynced;

  /// Provider limitations label.
  ///
  /// In en, this message translates to:
  /// **'Not supplied by this connection'**
  String get hostsOperationalRosterProviderLimits;

  /// Honest Luma sync limitations.
  ///
  /// In en, this message translates to:
  /// **'Payments, refunds, referral codes and automatic background updates. Catch check-ins are never undone when Luma omits a check-in.'**
  String get hostsOperationalRosterProviderLumaLimits;

  /// Provider roster identity capability.
  ///
  /// In en, this message translates to:
  /// **'Guest names and contact details'**
  String get hostsOperationalRosterProviderCapabilityGuests;

  /// Provider registration status capability.
  ///
  /// In en, this message translates to:
  /// **'Registration status'**
  String get hostsOperationalRosterProviderCapabilityStatus;

  /// Provider check-in capability.
  ///
  /// In en, this message translates to:
  /// **'Provider check-ins'**
  String get hostsOperationalRosterProviderCapabilityCheckIn;

  /// Manual provider sync action.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get hostsOperationalRosterProviderSyncNow;

  /// Provider disconnect action.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get hostsOperationalRosterProviderDisconnect;

  /// Provider disconnect confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Disconnect booking source?'**
  String get hostsOperationalRosterProviderDisconnectTitle;

  /// Provider disconnect consequence.
  ///
  /// In en, this message translates to:
  /// **'Guests already in Catch stay on this roster. Future provider changes will not appear until you reconnect.'**
  String get hostsOperationalRosterProviderDisconnectBody;

  /// Luma connection action.
  ///
  /// In en, this message translates to:
  /// **'Connect Luma'**
  String get hostsOperationalRosterProviderConnect;

  /// Luma credential replacement action.
  ///
  /// In en, this message translates to:
  /// **'Reconnect Luma'**
  String get hostsOperationalRosterProviderReconnect;

  /// Provider spreadsheet import action.
  ///
  /// In en, this message translates to:
  /// **'Import spreadsheet'**
  String get hostsOperationalRosterProviderImport;

  /// Luma connection confirmation.
  ///
  /// In en, this message translates to:
  /// **'Luma connected. Sync when you want to refresh the roster.'**
  String get hostsOperationalRosterProviderConnected;

  /// Provider sync result.
  ///
  /// In en, this message translates to:
  /// **'Roster synced: {created} added, {updated} refreshed, {skipped} skipped.'**
  String hostsOperationalRosterProviderSyncSuccess({
    required int created,
    required int updated,
    required int skipped,
  });

  /// Luma connection sheet title.
  ///
  /// In en, this message translates to:
  /// **'Connect your Luma calendar'**
  String get hostsOperationalRosterProviderConnectTitle;

  /// Luma connection security and sequence guidance.
  ///
  /// In en, this message translates to:
  /// **'Catch checks the calendar key without saving it, then lets you choose an event. The key is stored only after you confirm the event.'**
  String get hostsOperationalRosterProviderConnectBody;

  /// Luma API key field.
  ///
  /// In en, this message translates to:
  /// **'Luma calendar API key'**
  String get hostsOperationalRosterProviderApiKey;

  /// Luma API key requirements and storage guidance.
  ///
  /// In en, this message translates to:
  /// **'Requires Luma Plus. Catch encrypts the key in Google Secret Manager after you choose an event.'**
  String get hostsOperationalRosterProviderApiKeyHelp;

  /// Provider connection field validation.
  ///
  /// In en, this message translates to:
  /// **'Check this value and try again.'**
  String get hostsOperationalRosterProviderFieldRequired;

  /// Verifies Luma key and opens event selection.
  ///
  /// In en, this message translates to:
  /// **'Check key and choose event'**
  String get hostsOperationalRosterProviderChooseEvent;

  /// Luma event selection title.
  ///
  /// In en, this message translates to:
  /// **'Choose the Luma event'**
  String get hostsOperationalRosterProviderChooseEventTitle;

  /// Luma event selection guidance.
  ///
  /// In en, this message translates to:
  /// **'Events managed by {calendar}. Choose the one that matches this Catch event.'**
  String hostsOperationalRosterProviderChooseEventBody({
    required String calendar,
  });

  /// Empty Luma event list title.
  ///
  /// In en, this message translates to:
  /// **'No manageable events found'**
  String get hostsOperationalRosterProviderNoEventsTitle;

  /// Empty Luma event list guidance.
  ///
  /// In en, this message translates to:
  /// **'This key did not return an event the calendar can manage.'**
  String get hostsOperationalRosterProviderNoEventsBody;

  /// Bounded Luma event selection warning.
  ///
  /// In en, this message translates to:
  /// **'Showing the 50 most recent manageable events. Use spreadsheet import if the event you need is older.'**
  String get hostsOperationalRosterProviderEventsTruncated;

  /// Direct provider sync availability.
  ///
  /// In en, this message translates to:
  /// **'Direct sync available'**
  String get hostsOperationalRosterProviderAvailable;

  /// Export-only provider availability.
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet import'**
  String get hostsOperationalRosterProviderExportOnly;

  /// Provider configuration required availability.
  ///
  /// In en, this message translates to:
  /// **'Catch setup pending'**
  String get hostsOperationalRosterProviderConfigurationRequired;

  /// Provider partner access availability.
  ///
  /// In en, this message translates to:
  /// **'Provider approval required'**
  String get hostsOperationalRosterProviderPartnerRequired;

  /// Provider sample required availability.
  ///
  /// In en, this message translates to:
  /// **'Export sample needed'**
  String get hostsOperationalRosterProviderSampleRequired;

  /// Manual-only provider availability.
  ///
  /// In en, this message translates to:
  /// **'Manual import'**
  String get hostsOperationalRosterProviderManualOnly;

  /// Active provider connection status.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get hostsOperationalRosterProviderStatusActive;

  /// Degraded provider connection status.
  ///
  /// In en, this message translates to:
  /// **'Connection needs attention'**
  String get hostsOperationalRosterProviderStatusDegraded;

  /// Revoked credential status.
  ///
  /// In en, this message translates to:
  /// **'Reconnect required'**
  String get hostsOperationalRosterProviderStatusReconnect;

  /// Disconnected provider status.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get hostsOperationalRosterProviderStatusDisconnected;

  /// Roster source label for Catch booking.
  ///
  /// In en, this message translates to:
  /// **'Catch booking'**
  String get hostsOperationalRosterSourceCatchBooking;

  /// Roster source label for spreadsheet imports.
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet'**
  String get hostsOperationalRosterSourceHostImport;

  /// Roster source label for manual guest entry.
  ///
  /// In en, this message translates to:
  /// **'Added by host'**
  String get hostsOperationalRosterSourceHostManual;

  /// Roster source label for public web OTP registration.
  ///
  /// In en, this message translates to:
  /// **'Web registration'**
  String get hostsOperationalRosterSourceWebOtp;

  /// Roster source label for direct booking-provider synchronization.
  ///
  /// In en, this message translates to:
  /// **'Booking provider'**
  String get hostsOperationalRosterSourceProviderSync;

  /// Operational attendee invited status.
  ///
  /// In en, this message translates to:
  /// **'Invited'**
  String get hostsOperationalRosterStatusInvited;

  /// Operational attendee registered status.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get hostsOperationalRosterStatusRegistered;

  /// Operational attendee waitlisted status.
  ///
  /// In en, this message translates to:
  /// **'Waitlisted'**
  String get hostsOperationalRosterStatusWaitlisted;

  /// Operational attendee checked-in status.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get hostsOperationalRosterStatusCheckedIn;

  /// CTA to check in an operational attendee.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get hostsOperationalRosterCheckIn;

  /// CTA to undo operational attendee check-in.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get hostsOperationalRosterUndoCheckIn;

  /// Label for an operational attendee linked to an authenticated identity.
  ///
  /// In en, this message translates to:
  /// **'OTP linked'**
  String get hostsOperationalRosterIdentityLinked;

  /// Count of attendee runtime identity claims awaiting host review.
  ///
  /// In en, this message translates to:
  /// **'{count} runtime approvals'**
  String hostsOperationalRosterClaimsPending({required int count});

  /// Privacy-preserving phone hint for a runtime claim.
  ///
  /// In en, this message translates to:
  /// **'Phone ending {phoneLastFour}'**
  String hostsOperationalRosterClaimPhone({required String phoneLastFour});

  /// Context for a pending no-download runtime identity claim.
  ///
  /// In en, this message translates to:
  /// **'Opened the attendee link and needs access'**
  String get hostsOperationalRosterClaimContext;

  /// CTA to approve a runtime identity claim against its only roster candidate.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get hostsOperationalRosterClaimApprove;

  /// CTA to select the correct roster candidate for an ambiguous runtime claim.
  ///
  /// In en, this message translates to:
  /// **'Choose guest'**
  String get hostsOperationalRosterClaimChooseGuest;

  /// CTA to reject a runtime identity claim.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get hostsOperationalRosterClaimReject;

  /// Confirmation after approving a runtime identity claim.
  ///
  /// In en, this message translates to:
  /// **'Guest approved for this event'**
  String get hostsOperationalRosterClaimApproved;

  /// Confirmation after rejecting a runtime identity claim.
  ///
  /// In en, this message translates to:
  /// **'Access request rejected'**
  String get hostsOperationalRosterClaimRejected;

  /// Roster column mapping sheet title.
  ///
  /// In en, this message translates to:
  /// **'Map your guest list'**
  String get hostsOperationalRosterImportTitle;

  /// Roster mapping privacy and preview explanation.
  ///
  /// In en, this message translates to:
  /// **'Check the detected columns before anything is uploaded.'**
  String get hostsOperationalRosterImportSubtitle;

  /// Warning shown when a provider-specific roster export has not yet been verified.
  ///
  /// In en, this message translates to:
  /// **'We do not have a verified export sample for this platform yet. Review every detected column before importing.'**
  String get hostsOperationalRosterAdapterSampleRequired;

  /// Roster mapping field for guest name.
  ///
  /// In en, this message translates to:
  /// **'Guest name'**
  String get hostsOperationalRosterFieldName;

  /// Roster mapping field for guest phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get hostsOperationalRosterFieldPhone;

  /// Roster mapping field for guest email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get hostsOperationalRosterFieldEmail;

  /// Roster mapping field for an external booking reference.
  ///
  /// In en, this message translates to:
  /// **'Booking reference'**
  String get hostsOperationalRosterFieldReference;

  /// Roster mapping field for guests who share one booking or arrive together.
  ///
  /// In en, this message translates to:
  /// **'Arrival group'**
  String get hostsOperationalRosterFieldArrivalGroup;

  /// Roster mapping field for ticket type.
  ///
  /// In en, this message translates to:
  /// **'Ticket type'**
  String get hostsOperationalRosterFieldTicket;

  /// Roster mapping field for organizer-reported event revenue.
  ///
  /// In en, this message translates to:
  /// **'Order or ticket revenue'**
  String get hostsOperationalRosterFieldRevenue;

  /// Roster mapping or fallback currency field.
  ///
  /// In en, this message translates to:
  /// **'Revenue currency'**
  String get hostsOperationalRosterFieldCurrency;

  /// Optional organizer-entered per-guest revenue fallback.
  ///
  /// In en, this message translates to:
  /// **'Revenue per guest when missing'**
  String get hostsOperationalRosterRevenueFallbackAmount;

  /// Provenance disclosure for an organizer-entered revenue fallback.
  ///
  /// In en, this message translates to:
  /// **'Optional. This is recorded as your estimate, not a verified payment.'**
  String get hostsOperationalRosterRevenueFallbackHelp;

  /// Event price suggestion without automatically claiming it as paid revenue.
  ///
  /// In en, this message translates to:
  /// **'Optional. The event price is {amount}; enter it here only if it is a reasonable per-guest estimate.'**
  String hostsOperationalRosterRevenueFallbackEventPrice({
    required String amount,
  });

  /// Validation for the organizer-entered revenue fallback.
  ///
  /// In en, this message translates to:
  /// **'Enter a non-negative amount and a three-letter currency code.'**
  String get hostsOperationalRosterRevenueFallbackInvalid;

  /// Roster mapping field for attendee status.
  ///
  /// In en, this message translates to:
  /// **'Registration status'**
  String get hostsOperationalRosterFieldStatus;

  /// Roster mapping option that ignores an optional column.
  ///
  /// In en, this message translates to:
  /// **'Do not import'**
  String get hostsOperationalRosterDoNotImport;

  /// Roster mapping preview row count.
  ///
  /// In en, this message translates to:
  /// **'{count} guests ready'**
  String hostsOperationalRosterPreviewCount({required int count});

  /// Roster mapping rows that cannot yet be imported.
  ///
  /// In en, this message translates to:
  /// **'{count} need review'**
  String hostsOperationalRosterNeedsReviewCount({required int count});

  /// Roster mapping rows intentionally excluded due to status.
  ///
  /// In en, this message translates to:
  /// **'{count} excluded'**
  String hostsOperationalRosterExcludedCount({required int count});

  /// Warning when provider hint and detected export disagree.
  ///
  /// In en, this message translates to:
  /// **'The selected booking source does not match this spreadsheet. Catch used the columns in the file; review the mapping before importing.'**
  String get hostsOperationalRosterProviderMismatch;

  /// Warning for legacy encoded CSV files.
  ///
  /// In en, this message translates to:
  /// **'This CSV is not UTF-8. Catch read it using a legacy encoding; check names and symbols carefully.'**
  String get hostsOperationalRosterLegacyEncoding;

  /// Warning when an XLSX contains multiple worksheets.
  ///
  /// In en, this message translates to:
  /// **'This workbook has {count} worksheets. Catch selected the best-matching guest worksheet; verify the columns before importing.'**
  String hostsOperationalRosterMultipleWorksheets({required int count});

  /// Roster import confirmation CTA.
  ///
  /// In en, this message translates to:
  /// **'Import {count} guests'**
  String hostsOperationalRosterImportAction({required int count});

  /// External event guest list field title.
  ///
  /// In en, this message translates to:
  /// **'Guest list'**
  String get hostsCreateEventRosterTitle;

  /// Attached external event roster summary.
  ///
  /// In en, this message translates to:
  /// **'{fileName} · {ready} ready · {review} need review · {excluded} excluded'**
  String hostsCreateEventRosterAttached({
    required String fileName,
    required int ready,
    required int review,
    required int excluded,
  });

  /// Roster reattachment guidance after restoring a draft.
  ///
  /// In en, this message translates to:
  /// **'Reattach {fileName} before publishing. Drafts remember the file fingerprint, not guest data.'**
  String hostsCreateEventRosterReattach({required String fileName});

  /// External event roster picker action.
  ///
  /// In en, this message translates to:
  /// **'Choose CSV or XLSX'**
  String get hostsCreateEventRosterChoose;

  /// External event roster replacement action.
  ///
  /// In en, this message translates to:
  /// **'Replace file'**
  String get hostsCreateEventRosterReplace;

  /// Create event guest list import success summary.
  ///
  /// In en, this message translates to:
  /// **'Guest list imported: {created} added, {updated} refreshed, {skipped} skipped.'**
  String hostsCreateEventRosterImportSuccess({
    required int created,
    required int updated,
    required int skipped,
  });

  /// Create event partial roster import guidance.
  ///
  /// In en, this message translates to:
  /// **'The event is live, but {count} guest rows need attention. Open Manage event to review the roster and retry the file.'**
  String hostsCreateEventRosterImportPartial({required int count});

  /// Create event roster import failure recovery guidance.
  ///
  /// In en, this message translates to:
  /// **'The event is live, but the guest list was not imported. Open Manage event and retry the same file.'**
  String get hostsCreateEventRosterImportFailed;

  /// Success guidance for externally booked events.
  ///
  /// In en, this message translates to:
  /// **'Catch tracks the operational roster, check-in, walk-ins, and event safety. Bookings and payments stay with the external provider.'**
  String get hostsCreateEventExternalSuccessNote;

  /// Success detail label for an imported guest list.
  ///
  /// In en, this message translates to:
  /// **'Guest list'**
  String get hostsCreateEventRosterDetailLabel;

  /// Capacity validation against an attached guest list.
  ///
  /// In en, this message translates to:
  /// **'Capacity must be at least {count} to include every ready guest.'**
  String hostsCreateEventCapacityBelowRoster({required int count});

  /// Roster callable batch limit guidance.
  ///
  /// In en, this message translates to:
  /// **'This import uses the first 250 guests. Put the remaining {count} guests in another file.'**
  String hostsOperationalRosterLimit({required int count});

  /// Unsupported roster file error.
  ///
  /// In en, this message translates to:
  /// **'Choose a CSV or XLSX spreadsheet.'**
  String get hostsOperationalRosterIssueUnsupported;

  /// Roster source file size error.
  ///
  /// In en, this message translates to:
  /// **'Choose a spreadsheet smaller than 5 MB.'**
  String get hostsOperationalRosterIssueFileTooLarge;

  /// Roster expanded workbook size error.
  ///
  /// In en, this message translates to:
  /// **'This workbook expands beyond the 25 MB safety limit. Export only the guest worksheet and try again.'**
  String get hostsOperationalRosterIssueExpandedFileTooLarge;

  /// Missing roster rows error.
  ///
  /// In en, this message translates to:
  /// **'The spreadsheet needs a header row and at least one guest.'**
  String get hostsOperationalRosterIssueMissingRows;

  /// Roster column limit error.
  ///
  /// In en, this message translates to:
  /// **'Keep only the guest fields you need and use no more than 40 columns.'**
  String get hostsOperationalRosterIssueTooManyColumns;

  /// Malformed CSV error.
  ///
  /// In en, this message translates to:
  /// **'The CSV has an unfinished quoted value.'**
  String get hostsOperationalRosterIssueMalformedCsv;

  /// Unreadable XLSX error.
  ///
  /// In en, this message translates to:
  /// **'The XLSX spreadsheet could not be read. Export it again and retry.'**
  String get hostsOperationalRosterIssueUnreadableXlsx;

  /// Missing guest name mapping error.
  ///
  /// In en, this message translates to:
  /// **'Choose the column that contains each guest name.'**
  String get hostsOperationalRosterIssueMissingNameColumn;

  /// Missing guest name row error.
  ///
  /// In en, this message translates to:
  /// **'Row {row}: guest name is empty.'**
  String hostsOperationalRosterIssueMissingName({required int row});

  /// Duplicate roster column mapping error.
  ///
  /// In en, this message translates to:
  /// **'Map each spreadsheet column to only one guest field.'**
  String get hostsOperationalRosterIssueDuplicateMappedColumn;

  /// Missing stable roster identity error.
  ///
  /// In en, this message translates to:
  /// **'Row {row}: add a phone, email, or booking reference so retries cannot create a duplicate guest.'**
  String hostsOperationalRosterIssueMissingStableIdentity({required int row});

  /// Invalid roster phone error.
  ///
  /// In en, this message translates to:
  /// **'Row {row}: phone number is not valid.'**
  String hostsOperationalRosterIssueInvalidPhone({required int row});

  /// Invalid roster email error.
  ///
  /// In en, this message translates to:
  /// **'Row {row}: email address is not valid.'**
  String hostsOperationalRosterIssueInvalidEmail({required int row});

  /// Invalid imported roster revenue error.
  ///
  /// In en, this message translates to:
  /// **'Row {row}: revenue is not a valid non-negative amount.'**
  String hostsOperationalRosterIssueInvalidRevenue({required int row});

  /// Missing imported roster revenue currency error.
  ///
  /// In en, this message translates to:
  /// **'Row {row}: choose a three-letter currency for this revenue amount.'**
  String hostsOperationalRosterIssueMissingRevenueCurrency({required int row});

  /// Duplicate roster identity error.
  ///
  /// In en, this message translates to:
  /// **'Row {row}: this guest has the same identity as an earlier row.'**
  String hostsOperationalRosterIssueDuplicateIdentity({required int row});

  /// Unknown roster status error.
  ///
  /// In en, this message translates to:
  /// **'Row {row}: status \'{status}\' needs review and will not be imported.'**
  String hostsOperationalRosterIssueUnknownStatus({
    required int row,
    required String status,
  });

  /// Excluded roster status explanation.
  ///
  /// In en, this message translates to:
  /// **'Row {row}: status \'{status}\' is excluded from the active guest list.'**
  String hostsOperationalRosterIssueExcludedStatus({
    required int row,
    required String status,
  });

  /// Completed roster import summary.
  ///
  /// In en, this message translates to:
  /// **'Roster updated: {created} added, {updated} refreshed, {skipped} skipped.'**
  String hostsOperationalRosterImportSuccess({
    required int created,
    required int updated,
    required int skipped,
  });

  /// Partial roster import result title.
  ///
  /// In en, this message translates to:
  /// **'Some guest rows need attention'**
  String get hostsOperationalRosterImportPartialTitle;

  /// Partial roster import recovery guidance.
  ///
  /// In en, this message translates to:
  /// **'{created} added, {updated} refreshed, and {count} rows were not imported. Fix those rows in the spreadsheet and import the same file again; Catch will update existing guests instead of duplicating them.'**
  String hostsOperationalRosterImportPartialBody({
    required int created,
    required int updated,
    required int count,
  });

  /// Roster import row error label.
  ///
  /// In en, this message translates to:
  /// **'Row {row}'**
  String hostsOperationalRosterImportRowError({required String row});

  /// Roster import result dismissal action.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get hostsOperationalRosterImportResultDone;

  /// Manual roster entry sheet title.
  ///
  /// In en, this message translates to:
  /// **'Add a guest'**
  String get hostsOperationalRosterManualTitle;

  /// Manual roster entry privacy guidance.
  ///
  /// In en, this message translates to:
  /// **'A phone or email is optional for day-of check-in. Add contact details only when you are allowed to use them.'**
  String get hostsOperationalRosterManualSubtitle;

  /// Manual guest save CTA.
  ///
  /// In en, this message translates to:
  /// **'Add to roster'**
  String get hostsOperationalRosterManualSave;

  /// Manual guest name validation.
  ///
  /// In en, this message translates to:
  /// **'Enter the guest\'\'s name.'**
  String get hostsOperationalRosterManualNameRequired;

  /// Host analytics label for unified operational roster size.
  ///
  /// In en, this message translates to:
  /// **'Guests on roster'**
  String get hostsHostAnalyticsLabelRosterGuests;

  /// Host analytics label for source-independent attendance rate.
  ///
  /// In en, this message translates to:
  /// **'Roster attendance'**
  String get hostsHostAnalyticsLabelRosterAttendanceRate;

  /// Per-event unified roster and outside-source analytics summary.
  ///
  /// In en, this message translates to:
  /// **'{roster} guests · {attended} checked in · {external} outside Catch'**
  String hostsHostAnalyticsTextRosterAttendedExternal({
    required int roster,
    required int attended,
    required int external,
  });

  /// Host event review workspace title.
  ///
  /// In en, this message translates to:
  /// **'Public reviews'**
  String get hostsHostEventReviewsTitlePublicReviews;

  /// Explains where a Host review response is published.
  ///
  /// In en, this message translates to:
  /// **'Reply from Catch for Hosts. Your response appears with the review on the public organizer page.'**
  String get hostsHostEventReviewsSubtitlePublicResponse;

  /// Host event review empty-state guidance.
  ///
  /// In en, this message translates to:
  /// **'Reviews for this event will appear here, including reviews submitted on your public Catch page.'**
  String get hostsHostEventReviewsMessageEmpty;

  /// Organizer publication control title.
  ///
  /// In en, this message translates to:
  /// **'Public visibility'**
  String get hostsHostClubPublicationTitle;

  /// Native Catch discovery channel label.
  ///
  /// In en, this message translates to:
  /// **'Catch app'**
  String get hostsHostClubPublicationChannelCatch;

  /// Public website channel label.
  ///
  /// In en, this message translates to:
  /// **'Public website'**
  String get hostsHostClubPublicationChannelWebsite;

  /// Visible Catch app status badge.
  ///
  /// In en, this message translates to:
  /// **'Visible'**
  String get hostsHostClubPublicationStatusVisible;

  /// Hidden Catch app status badge.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get hostsHostClubPublicationStatusHidden;

  /// Enabled website status badge.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get hostsHostClubPublicationStatusEnabled;

  /// Disabled website status badge.
  ///
  /// In en, this message translates to:
  /// **'Not enabled'**
  String get hostsHostClubPublicationStatusNotEnabled;

  /// Explains a fully private organizer.
  ///
  /// In en, this message translates to:
  /// **'Only your Host team can access this organizer. You can still run events, import guests, and check people in.'**
  String get hostsHostClubPublicationBodyPrivate;

  /// Explains Catch-only organizer visibility.
  ///
  /// In en, this message translates to:
  /// **'People can find this organizer in Catch. Enable its website page to share it outside the app and support web registration. It will appear after the next website release.'**
  String get hostsHostClubPublicationBodyCatchOnly;

  /// Explains website-only organizer visibility.
  ///
  /// In en, this message translates to:
  /// **'The website page is enabled, but this organizer is hidden in Catch. Restore Catch visibility to keep both public settings in sync.'**
  String get hostsHostClubPublicationBodyWebsiteOnly;

  /// Explains fully public organizer settings.
  ///
  /// In en, this message translates to:
  /// **'This organizer is enabled for Catch and the public website. Website changes appear after the next website release.'**
  String get hostsHostClubPublicationBodyEverywhere;

  /// Enable both public channels CTA.
  ///
  /// In en, this message translates to:
  /// **'Make organizer public'**
  String get hostsHostClubPublicationActionMakePublic;

  /// Enable the organizer website page CTA.
  ///
  /// In en, this message translates to:
  /// **'Enable website page'**
  String get hostsHostClubPublicationActionEnableWebsite;

  /// Restore native Catch discovery CTA.
  ///
  /// In en, this message translates to:
  /// **'Restore Catch visibility'**
  String get hostsHostClubPublicationActionRestoreCatch;

  /// Disable both public channels CTA.
  ///
  /// In en, this message translates to:
  /// **'Make organizer private'**
  String get hostsHostClubPublicationActionMakePrivate;

  /// Host public event registration control title.
  ///
  /// In en, this message translates to:
  /// **'Website registration'**
  String get hostsHostPublicRegistrationTitle;

  /// Enabled website registration state.
  ///
  /// In en, this message translates to:
  /// **'Phone OTP sign-up is enabled'**
  String get hostsHostPublicRegistrationSubtitleEnabled;

  /// Disabled website registration state.
  ///
  /// In en, this message translates to:
  /// **'Consumer booking is optional'**
  String get hostsHostPublicRegistrationSubtitleDisabled;

  /// Open website registration badge.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get hostsHostPublicRegistrationStatusOpen;

  /// Disabled website registration badge.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get hostsHostPublicRegistrationStatusOff;

  /// Explains standalone website registration.
  ///
  /// In en, this message translates to:
  /// **'People can sign up from the public event page with only a name and phone OTP. They join this operational roster without completing a Consumer profile.'**
  String get hostsHostPublicRegistrationBodyPublished;

  /// Publication prerequisite for website registration.
  ///
  /// In en, this message translates to:
  /// **'Publish the organizer page first. You can still import guests and run this event privately in the meantime.'**
  String get hostsHostPublicRegistrationBodyNeedsPage;

  /// Explains why standalone website registration cannot safely bypass payment or identity gates.
  ///
  /// In en, this message translates to:
  /// **'Phone OTP registration currently supports free events with open admission. Keep importing the external roster for paid, invite-only, approval, membership, or profile-balanced events; those flows need their own payment or identity gate.'**
  String get hostsHostPublicRegistrationBodyUnsupported;

  /// Enable website registration CTA.
  ///
  /// In en, this message translates to:
  /// **'Enable phone OTP sign-up'**
  String get hostsHostPublicRegistrationActionEnable;

  /// Disable website registration CTA.
  ///
  /// In en, this message translates to:
  /// **'Disable website sign-up'**
  String get hostsHostPublicRegistrationActionDisable;

  /// Contact count label.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get hostsHostAudienceContacts;

  /// Past attendee count label.
  ///
  /// In en, this message translates to:
  /// **'Attended'**
  String get hostsHostAudienceAttended;

  /// Repeat attendee count label.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get hostsHostAudienceRepeat;

  /// Audience search field.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get hostsHostAudienceSearch;

  /// Clear audience segment filter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get hostsHostAudienceAll;

  /// Partial audience coverage notice title.
  ///
  /// In en, this message translates to:
  /// **'Some customer history is unavailable'**
  String get hostsHostAudienceCoveragePartial;

  /// Partial audience coverage explanation.
  ///
  /// In en, this message translates to:
  /// **'Some older attendance may be missing. Counts marked + are minimums, and audience campaigns stay off until history is complete.'**
  String get hostsHostAudienceCoveragePartialBody;

  /// WhatsApp sender section title.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Business sender'**
  String get hostsHostAudienceWhatsappSender;

  /// WhatsApp ownership and consent explanation.
  ///
  /// In en, this message translates to:
  /// **'Connect your own Meta WhatsApp Business account. Catch never sends from a shared number, and only people with explicit organizer-specific opt-in are eligible.'**
  String get hostsHostAudienceWhatsappOwnedSender;

  /// Missing platform-level Meta setup title.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp setup is not enabled in this environment'**
  String get hostsHostAudienceProviderUnavailable;

  /// Missing platform-level Meta setup body.
  ///
  /// In en, this message translates to:
  /// **'An administrator must configure the Catch Meta app and Embedded Signup configuration before organizers can connect their own senders.'**
  String get hostsHostAudienceProviderUnavailableBody;

  /// Open Meta Embedded Signup CTA.
  ///
  /// In en, this message translates to:
  /// **'Connect WhatsApp Business'**
  String get hostsHostAudienceConnectWhatsapp;

  /// WhatsApp templates row title.
  ///
  /// In en, this message translates to:
  /// **'Message templates'**
  String get hostsHostAudienceTemplates;

  /// Approved WhatsApp template count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No approved templates} =1{1 approved template} other{{count} approved templates}}'**
  String hostsHostAudienceApprovedTemplates({required int count});

  /// Sync WhatsApp templates CTA.
  ///
  /// In en, this message translates to:
  /// **'Sync templates'**
  String get hostsHostAudienceSyncTemplates;

  /// Disconnect WhatsApp sender CTA.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get hostsHostAudienceDisconnect;

  /// WhatsApp test recipient field.
  ///
  /// In en, this message translates to:
  /// **'Test recipient phone'**
  String get hostsHostAudienceTestPhone;

  /// WhatsApp test recipient helper.
  ///
  /// In en, this message translates to:
  /// **'Use an opted-in number you control, including the country code.'**
  String get hostsHostAudienceTestPhoneHelp;

  /// Send WhatsApp test CTA.
  ///
  /// In en, this message translates to:
  /// **'Send verification message'**
  String get hostsHostAudienceSendTest;

  /// WhatsApp test accepted confirmation.
  ///
  /// In en, this message translates to:
  /// **'Meta accepted the test. The sender becomes active after the delivered webhook arrives.'**
  String get hostsHostAudienceTestPending;

  /// Cross-event campaign section title.
  ///
  /// In en, this message translates to:
  /// **'Message past attendees'**
  String get hostsHostAudienceCampaign;

  /// Campaign sender prerequisite.
  ///
  /// In en, this message translates to:
  /// **'Finish sender verification before creating a campaign. A delivered test proves that webhooks and the selected number work end to end.'**
  String get hostsHostAudienceCampaignNeedsActiveSender;

  /// Campaign template prerequisite.
  ///
  /// In en, this message translates to:
  /// **'Sync an approved Meta template before creating a campaign.'**
  String get hostsHostAudienceCampaignNeedsTemplate;

  /// Campaign name field.
  ///
  /// In en, this message translates to:
  /// **'Internal campaign name'**
  String get hostsHostAudienceCampaignName;

  /// Campaign name example.
  ///
  /// In en, this message translates to:
  /// **'September regulars invitation'**
  String get hostsHostAudienceCampaignNameExample;

  /// Campaign message class field.
  ///
  /// In en, this message translates to:
  /// **'Message type'**
  String get hostsHostAudienceMessageType;

  /// Campaign recipient segment heading.
  ///
  /// In en, this message translates to:
  /// **'Recipient categories'**
  String get hostsHostAudienceRecipients;

  /// Campaign template picker title.
  ///
  /// In en, this message translates to:
  /// **'Approved template'**
  String get hostsHostAudienceTemplate;

  /// Campaign preview CTA.
  ///
  /// In en, this message translates to:
  /// **'Save and preview recipients'**
  String get hostsHostAudiencePreviewCampaign;

  /// Campaign validation message.
  ///
  /// In en, this message translates to:
  /// **'Add a campaign name and complete every template field before previewing.'**
  String get hostsHostAudienceCompleteCampaign;

  /// Campaign status title.
  ///
  /// In en, this message translates to:
  /// **'Campaign status: {status}'**
  String hostsHostAudienceCampaignStatus({required String status});

  /// Campaign audience preview counts.
  ///
  /// In en, this message translates to:
  /// **'{reachable} of {total} are reachable · {optedOut} opted out · {unknown} have unknown permission or identity'**
  String hostsHostAudienceCampaignCounts({
    required int total,
    required int reachable,
    required int optedOut,
    required int unknown,
  });

  /// Campaign delivery outcome counts.
  ///
  /// In en, this message translates to:
  /// **'{sent} sent · {delivered} delivered · {read} read · {failed} failed'**
  String hostsHostAudienceDeliveryCounts({
    required int sent,
    required int delivered,
    required int read,
    required int failed,
  });

  /// Approve campaign audience snapshot CTA.
  ///
  /// In en, this message translates to:
  /// **'Approve exact audience'**
  String get hostsHostAudienceApprove;

  /// Dispatch approved campaign CTA.
  ///
  /// In en, this message translates to:
  /// **'Send now'**
  String get hostsHostAudienceSendNow;

  /// Refresh campaign outcomes CTA.
  ///
  /// In en, this message translates to:
  /// **'Refresh results'**
  String get hostsHostAudienceRefresh;

  /// Cancel campaign CTA.
  ///
  /// In en, this message translates to:
  /// **'Cancel campaign'**
  String get hostsHostAudienceCancel;

  /// Reset campaign composer CTA.
  ///
  /// In en, this message translates to:
  /// **'New campaign'**
  String get hostsHostAudienceNewCampaign;

  /// Internal label for a stable attendee-created invite link.
  ///
  /// In en, this message translates to:
  /// **'Attendee share'**
  String get eventsAttendeeShareLinkLabel;

  /// Export current audience CTA.
  ///
  /// In en, this message translates to:
  /// **'Export this audience'**
  String get hostsHostAudienceExport;

  /// Audience CSV share subject.
  ///
  /// In en, this message translates to:
  /// **'Catch audience export'**
  String get hostsHostAudienceExportSubject;

  /// Audience export truncation disclosure.
  ///
  /// In en, this message translates to:
  /// **'This export reached the 2,500-contact safety limit.'**
  String get hostsHostAudienceExportTruncated;

  /// Audience CSV share body count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 organizer contact.} other{{count} organizer contacts.}}'**
  String hostsHostAudienceExportCount({required int count});

  /// Customer removal confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Remove customer?'**
  String get hostsHostAudienceRemoveTitle;

  /// Customer removal consequence.
  ///
  /// In en, this message translates to:
  /// **'This hides the person from CRM and future campaigns. Event attendance and audit history stay intact.'**
  String get hostsHostAudienceRemoveBody;

  /// Confirm customer removal CTA.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get hostsHostAudienceRemoveConfirm;

  /// Open customer removal confirmation CTA.
  ///
  /// In en, this message translates to:
  /// **'Remove customer'**
  String get hostsHostAudienceRemoveAction;

  /// Organizer-local audience contact name field.
  ///
  /// In en, this message translates to:
  /// **'Name shown to your team'**
  String get hostsHostAudienceContactName;

  /// Organizer-local audience contact name disclosure.
  ///
  /// In en, this message translates to:
  /// **'This does not alter the guest’s Catch profile or verified contact details.'**
  String get hostsHostAudienceContactNameHelp;

  /// Verified contact phone label.
  ///
  /// In en, this message translates to:
  /// **'Verified phone'**
  String get hostsHostAudienceContactVerifiedPhone;

  /// Contact email label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get hostsHostAudienceContactEmail;

  /// Organizer-suppressed WhatsApp delivery explanation.
  ///
  /// In en, this message translates to:
  /// **'Your team has paused WhatsApp campaigns to this person. Their own opt-out remains authoritative.'**
  String get hostsHostAudienceContactConsentPaused;

  /// Eligible WhatsApp delivery explanation.
  ///
  /// In en, this message translates to:
  /// **'Only the person-verified number and active organizer consent can receive a campaign.'**
  String get hostsHostAudienceContactConsentActive;

  /// New-to-organizer audience segment label.
  ///
  /// In en, this message translates to:
  /// **'New to your audience'**
  String get hostsHostAudienceSegmentNew;

  /// First-time attendee segment label.
  ///
  /// In en, this message translates to:
  /// **'First-time attendees'**
  String get hostsHostAudienceSegmentFirstTime;

  /// Repeat attendee segment label.
  ///
  /// In en, this message translates to:
  /// **'Repeat attendees'**
  String get hostsHostAudienceSegmentRepeat;

  /// Regular attendee segment label.
  ///
  /// In en, this message translates to:
  /// **'Regulars'**
  String get hostsHostAudienceSegmentRegular;

  /// Lapsed regular segment label.
  ///
  /// In en, this message translates to:
  /// **'Lapsed regulars'**
  String get hostsHostAudienceSegmentLapsed;

  /// Reliable attendee segment label.
  ///
  /// In en, this message translates to:
  /// **'Reliable attendees'**
  String get hostsHostAudienceSegmentReliable;

  /// Audience segment for guests with repeated prior no-shows.
  ///
  /// In en, this message translates to:
  /// **'Needs confirmation'**
  String get hostsHostAudienceSegmentNeedsConfirmation;

  /// Advocate segment label.
  ///
  /// In en, this message translates to:
  /// **'Advocates'**
  String get hostsHostAudienceSegmentAdvocate;

  /// High-impact advocate segment label.
  ///
  /// In en, this message translates to:
  /// **'High-impact advocates'**
  String get hostsHostAudienceSegmentHighImpact;

  /// WhatsApp reachable segment label.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp reachable'**
  String get hostsHostAudienceSegmentWhatsapp;

  /// SMS reachable segment label.
  ///
  /// In en, this message translates to:
  /// **'SMS reachable'**
  String get hostsHostAudienceSegmentSms;

  /// Campaign follow-up message class label.
  ///
  /// In en, this message translates to:
  /// **'Post-event follow-up'**
  String get hostsHostAudienceMessageFollowUp;

  /// Campaign organizer update class label.
  ///
  /// In en, this message translates to:
  /// **'Organizer update'**
  String get hostsHostAudienceMessageUpdate;

  /// Campaign organizer promotion class label.
  ///
  /// In en, this message translates to:
  /// **'Event invitation or promotion'**
  String get hostsHostAudienceMessagePromotion;

  /// Active WhatsApp sender state.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get hostsHostAudienceSenderActive;

  /// Testing WhatsApp sender state.
  ///
  /// In en, this message translates to:
  /// **'Verification pending'**
  String get hostsHostAudienceSenderTesting;

  /// Degraded WhatsApp sender state.
  ///
  /// In en, this message translates to:
  /// **'Degraded'**
  String get hostsHostAudienceSenderDegraded;

  /// Blocked WhatsApp sender state.
  ///
  /// In en, this message translates to:
  /// **'Reconnect required'**
  String get hostsHostAudienceSenderNeedsAttention;

  /// Contact attended event count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No check-ins yet} =1{1 event attended} other{{count} events attended}}'**
  String hostsHostAudienceEventsAttended({required int count});

  /// Contact last attended date.
  ///
  /// In en, this message translates to:
  /// **'Last seen {date}'**
  String hostsHostAudienceLastSeen({required String date});

  /// Contact WhatsApp permission state.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp opted in'**
  String get hostsHostAudienceWhatsappOptedIn;

  /// Confirms the native-to-web WhatsApp Embedded Signup handoff.
  ///
  /// In en, this message translates to:
  /// **'Continue WhatsApp setup in the Host web app.'**
  String get hostsHostAudienceWebSignupOpened;

  /// Failure shown when native cannot open the Host web WhatsApp setup route.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp setup in the Host web app.'**
  String get hostsHostAudienceWebSignupOpenFailed;

  /// Campaign provider blocker.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp provider setup is incomplete'**
  String get hostsHostAudienceBlockerProvider;

  /// Campaign sender blocker.
  ///
  /// In en, this message translates to:
  /// **'Sender verification is incomplete'**
  String get hostsHostAudienceBlockerSender;

  /// Campaign template blocker.
  ///
  /// In en, this message translates to:
  /// **'The template is missing or no longer approved'**
  String get hostsHostAudienceBlockerTemplate;

  /// Campaign recipient blocker.
  ///
  /// In en, this message translates to:
  /// **'None of these customers are both verified and opted in'**
  String get hostsHostAudienceBlockerNoRecipients;

  /// Campaign coverage blocker.
  ///
  /// In en, this message translates to:
  /// **'Customer history is incomplete'**
  String get hostsHostAudienceBlockerCoverage;

  /// Campaign size blocker.
  ///
  /// In en, this message translates to:
  /// **'This first release supports up to 100 evaluated contacts per campaign'**
  String get hostsHostAudienceBlockerTooLarge;

  /// Campaign event blocker.
  ///
  /// In en, this message translates to:
  /// **'The linked event or destination is unavailable'**
  String get hostsHostAudienceBlockerEvent;

  /// Campaign schedule blocker.
  ///
  /// In en, this message translates to:
  /// **'The scheduled time has passed'**
  String get hostsHostAudienceBlockerSchedule;

  /// Campaign linked event picker title.
  ///
  /// In en, this message translates to:
  /// **'Event invitation'**
  String get hostsHostAudienceLinkedEvent;

  /// Campaign event picker placeholder.
  ///
  /// In en, this message translates to:
  /// **'Choose an event'**
  String get hostsHostAudienceChooseEvent;

  /// Recipient-specific invitation link explanation.
  ///
  /// In en, this message translates to:
  /// **'Catch creates a different private link for each eligible recipient so opens, registrations, referrals, and check-ins can be attributed safely.'**
  String get hostsHostAudienceLinkedEventHelp;

  /// Campaign invite destination field.
  ///
  /// In en, this message translates to:
  /// **'Where the invitation opens'**
  String get hostsHostAudienceInviteDestination;

  /// Catch event page invitation destination.
  ///
  /// In en, this message translates to:
  /// **'Catch event page'**
  String get hostsHostAudienceDestinationCatchPage;

  /// Event runtime invitation destination.
  ///
  /// In en, this message translates to:
  /// **'No-download event runtime'**
  String get hostsHostAudienceDestinationRuntime;

  /// External booking invitation destination.
  ///
  /// In en, this message translates to:
  /// **'External booking site via Catch event page'**
  String get hostsHostAudienceDestinationExternal;

  /// Truthful external booking attribution limits.
  ///
  /// In en, this message translates to:
  /// **'Catch records the private-link open, then sends the guest to the external booking page. Registration is confirmed only when a supported provider returns the referral code or the guest later makes a phone-verified runtime claim tied to the roster. An ordinary re-import or manual check-in cannot prove which link caused the booking.'**
  String get hostsHostAudienceExternalAttributionExplanation;

  /// Catch registration and guest referral attribution explanation.
  ///
  /// In en, this message translates to:
  /// **'Catch can attribute private-link opens and phone-verified web registration. If guests share their own Catch-generated link, their referred registrations and check-ins are counted separately.'**
  String get hostsHostAudienceCatchAttributionExplanation;

  /// Event staff section title.
  ///
  /// In en, this message translates to:
  /// **'Event staff access'**
  String get hostsEventStaffTitle;

  /// Least privilege event staff explanation.
  ///
  /// In en, this message translates to:
  /// **'Give a trusted operator temporary access to the guest names, check-ins, and runtime identity claims for this event. They cannot edit the event, import guests, see your audience, send messages, connect providers, or view analytics.'**
  String get hostsEventStaffSubtitle;

  /// Add event staff action.
  ///
  /// In en, this message translates to:
  /// **'Add event staff'**
  String get hostsEventStaffAdd;

  /// Copy operator workspace link.
  ///
  /// In en, this message translates to:
  /// **'Copy staff link'**
  String get hostsEventStaffCopyLink;

  /// Empty staff list title.
  ///
  /// In en, this message translates to:
  /// **'No temporary staff access'**
  String get hostsEventStaffEmptyTitle;

  /// Empty staff list guidance.
  ///
  /// In en, this message translates to:
  /// **'Add someone by the phone number they use to sign in to Catch Host. Access expires automatically.'**
  String get hostsEventStaffEmptyMessage;

  /// Masked event staff phone.
  ///
  /// In en, this message translates to:
  /// **'Phone ending {digits}'**
  String hostsEventStaffPhoneEnding({required String digits});

  /// Event staff expiry.
  ///
  /// In en, this message translates to:
  /// **'Access expires {date}'**
  String hostsEventStaffExpires({required String date});

  /// Revoke event staff access action.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get hostsEventStaffRevoke;

  /// Revoke event staff dialog title.
  ///
  /// In en, this message translates to:
  /// **'Revoke event access?'**
  String get hostsEventStaffRevokeTitle;

  /// Revoke event staff dialog message.
  ///
  /// In en, this message translates to:
  /// **'{name} will immediately lose access to the roster and runtime claims for this event.'**
  String hostsEventStaffRevokeMessage({required String name});

  /// Staff workspace clipboard success.
  ///
  /// In en, this message translates to:
  /// **'Staff workspace link copied'**
  String get hostsEventStaffLinkCopied;

  /// Grant event staff sheet title.
  ///
  /// In en, this message translates to:
  /// **'Add event staff'**
  String get hostsEventStaffGrantTitle;

  /// Grant event staff sheet guidance.
  ///
  /// In en, this message translates to:
  /// **'They must first sign in to Catch Host with this phone number. Access applies only to this event and expires automatically.'**
  String get hostsEventStaffGrantSubtitle;

  /// Grant event staff sheet action.
  ///
  /// In en, this message translates to:
  /// **'Grant access'**
  String get hostsEventStaffGrantAction;

  /// Event staff phone field.
  ///
  /// In en, this message translates to:
  /// **'Operator phone number'**
  String get hostsEventStaffPhone;

  /// Event staff phone validation.
  ///
  /// In en, this message translates to:
  /// **'Enter the phone number used for Catch Host'**
  String get hostsEventStaffPhoneRequired;

  /// Event staff duration field.
  ///
  /// In en, this message translates to:
  /// **'Access duration'**
  String get hostsEventStaffAccessDuration;

  /// Four hour staff grant option.
  ///
  /// In en, this message translates to:
  /// **'4 hours'**
  String get hostsEventStaffDurationFourHours;

  /// Twelve hour staff grant option.
  ///
  /// In en, this message translates to:
  /// **'12 hours'**
  String get hostsEventStaffDurationTwelveHours;

  /// One day staff grant option.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get hostsEventStaffDurationOneDay;

  /// Seven day staff grant option.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get hostsEventStaffDurationSevenDays;

  /// Active staff status.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get hostsEventStaffStatusActive;

  /// Revoked staff status.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get hostsEventStaffStatusRevoked;

  /// Expired staff status.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get hostsEventStaffStatusExpired;

  /// Restricted operator route title.
  ///
  /// In en, this message translates to:
  /// **'Event operations'**
  String get hostsEventOperatorTitle;

  /// Cancelled event operator state title.
  ///
  /// In en, this message translates to:
  /// **'This event was cancelled'**
  String get hostsEventOperatorCancelledTitle;

  /// Cancelled event operator state message.
  ///
  /// In en, this message translates to:
  /// **'Its roster can no longer be changed from the staff workspace.'**
  String get hostsEventOperatorCancelledMessage;

  /// Operator access summary title.
  ///
  /// In en, this message translates to:
  /// **'Restricted event access'**
  String get hostsEventOperatorAccessTitle;

  /// Operator access boundary explanation.
  ///
  /// In en, this message translates to:
  /// **'This workspace contains only the guest roster, check-in controls, and identity claims for this event.'**
  String get hostsEventOperatorAccessSubtitle;

  /// Manager role in operator workspace.
  ///
  /// In en, this message translates to:
  /// **'Organizer manager'**
  String get hostsEventOperatorRoleManager;

  /// Staff role in operator workspace.
  ///
  /// In en, this message translates to:
  /// **'Event staff'**
  String get hostsEventOperatorRoleStaff;

  /// Operator grant expiry badge.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String hostsEventOperatorExpires({required String date});

  /// Pending offline attendance title.
  ///
  /// In en, this message translates to:
  /// **'Check-ins waiting to sync'**
  String get hostsOperationalRosterOutboxPendingTitle;

  /// Pending offline attendance count and idempotency explanation.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 attendance change is saved on this device and will retry with the same operation ID.} other{{count} attendance changes are saved on this device and will retry with their original operation IDs.}}'**
  String hostsOperationalRosterOutboxPendingBody({required int count});

  /// Attendance conflict title.
  ///
  /// In en, this message translates to:
  /// **'Some check-ins need review'**
  String get hostsOperationalRosterOutboxReviewTitle;

  /// Attendance conflict count and recovery guidance.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 saved change could not be applied because the roster changed. Reload the roster, verify the guest, then discard the stale change.} other{{count} saved changes could not be applied because the roster changed. Reload the roster, verify the guests, then discard the stale changes.}}'**
  String hostsOperationalRosterOutboxReviewBody({required int count});

  /// Retry pending attendance changes.
  ///
  /// In en, this message translates to:
  /// **'Retry sync'**
  String get hostsOperationalRosterOutboxRetry;

  /// Discard attendance conflicts after review.
  ///
  /// In en, this message translates to:
  /// **'Discard stale changes'**
  String get hostsOperationalRosterOutboxDiscard;

  /// Cancels a reveal countdown before publication.
  ///
  /// In en, this message translates to:
  /// **'Cancel countdown'**
  String get eventSuccessLiveControlCancelCountdownLabel;

  /// Confirmation title before an irreversible assignment reveal.
  ///
  /// In en, this message translates to:
  /// **'Publish this reveal?'**
  String get eventSuccessLiveControlPublishRevealTitle;

  /// Irreversible reveal confirmation message.
  ///
  /// In en, this message translates to:
  /// **'Round {roundNumber} will become visible to everyone and cannot be hidden again.'**
  String eventSuccessLiveControlPublishRevealMessage({
    required int roundNumber,
  });

  /// Confirms an irreversible assignment reveal.
  ///
  /// In en, this message translates to:
  /// **'Publish reveal'**
  String get eventSuccessLiveControlPublishRevealConfirmLabel;

  /// Confirmation title before starting an auto-publishing reveal countdown.
  ///
  /// In en, this message translates to:
  /// **'Start the final countdown?'**
  String get eventSuccessLiveControlStartCountdownTitle;

  /// Countdown confirmation explains automatic irreversible publication.
  ///
  /// In en, this message translates to:
  /// **'Round {roundNumber} will publish after {countdownSeconds} seconds and cannot be hidden again.'**
  String eventSuccessLiveControlStartCountdownMessage({
    required int roundNumber,
    required int countdownSeconds,
  });

  /// Confirms an auto-publishing reveal countdown.
  ///
  /// In en, this message translates to:
  /// **'Start countdown'**
  String get eventSuccessLiveControlStartCountdownConfirmLabel;

  /// Publishes the prepared next rotation round.
  ///
  /// In en, this message translates to:
  /// **'Publish round {roundNumber}'**
  String eventSuccessLiveControlPublishRotationRoundLabel({
    required int roundNumber,
  });

  /// Confirmation title before publishing a prepared rotation.
  ///
  /// In en, this message translates to:
  /// **'Publish this rotation?'**
  String get eventSuccessLiveControlPublishRotationTitle;

  /// Irreversible rotation publication message.
  ///
  /// In en, this message translates to:
  /// **'Round {roundNumber} will become visible to attendees and cannot be withdrawn.'**
  String eventSuccessLiveControlPublishRotationMessage({
    required int roundNumber,
  });

  /// Confirms an irreversible prepared rotation publication.
  ///
  /// In en, this message translates to:
  /// **'Publish rotation'**
  String get eventSuccessLiveControlPublishRotationConfirmLabel;

  /// Labels the standings reveal mode in the live event control room.
  ///
  /// In en, this message translates to:
  /// **'Standings reveal'**
  String get eventSuccessLiveControlStandingsRevealLabel;

  /// Formats a unit score in the published standings.
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String eventSuccessLiveControlPointsValue({required num points});

  /// Formats a unit rank in the published standings.
  ///
  /// In en, this message translates to:
  /// **'Rank {rank}'**
  String eventSuccessLiveControlRankValue({required int rank});

  /// Heads the host form for recording a round outcome.
  ///
  /// In en, this message translates to:
  /// **'Record round {roundNumber}'**
  String eventSuccessLiveControlRecordRoundTitle({required int roundNumber});

  /// Explains how the host records ranked unit outcomes before reveal.
  ///
  /// In en, this message translates to:
  /// **'Enter one unique rank for every unit. The table stays hidden until the existing reveal.'**
  String get eventSuccessLiveControlRankEntryInstructions;

  /// Explains how the host records scored unit outcomes before reveal.
  ///
  /// In en, this message translates to:
  /// **'Enter this round’s score for every unit. Totals stay hidden until the existing reveal.'**
  String get eventSuccessLiveControlScoreEntryInstructions;

  /// Explains why round outcomes cannot be recorded before units exist.
  ///
  /// In en, this message translates to:
  /// **'Generate the live units before recording outcomes.'**
  String get eventSuccessLiveControlEmptyUnitsMessage;

  /// Explains how quiz teams become scoreable units.
  ///
  /// In en, this message translates to:
  /// **'Check in guests and give each team an arrival group before recording points.'**
  String get eventSuccessLiveControlEmptyScoreTeamsMessage;

  /// Saves the current round outcomes for a later reveal.
  ///
  /// In en, this message translates to:
  /// **'Save round for reveal'**
  String get eventSuccessLiveControlSaveRoundLabel;

  /// Reusable room layout selection title.
  ///
  /// In en, this message translates to:
  /// **'Room layout'**
  String get hostsEventSuccessStepRoomLayoutTitle;

  /// Explains reusable coarse layout assets.
  ///
  /// In en, this message translates to:
  /// **'Choose a reusable coarse layout for live placement. This is not a to-scale floor plan.'**
  String get hostsEventSuccessStepRoomLayoutSubtitle;

  /// Layout unit count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unit} other{{count} units}}'**
  String hostsEventSuccessStepRoomLayoutUnitCount({required int count});

  /// Selected layout state.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get hostsEventSuccessStepRoomLayoutSelected;

  /// Opens parametric layout authoring.
  ///
  /// In en, this message translates to:
  /// **'Create reusable layout'**
  String get hostsEventSuccessStepRoomLayoutCreate;

  /// Whole-group layout omission title.
  ///
  /// In en, this message translates to:
  /// **'No room map for whole-group mode'**
  String get hostsEventSuccessStepRoomLayoutWholeGroupTitle;

  /// Whole-group layout omission explanation.
  ///
  /// In en, this message translates to:
  /// **'Switch to pods, pairs, teams, or tables if this event needs mapped placement.'**
  String get hostsEventSuccessStepRoomLayoutWholeGroupBody;

  /// Layout author sheet title.
  ///
  /// In en, this message translates to:
  /// **'Build a room layout'**
  String get hostsEventSuccessStepRoomLayoutAuthorTitle;

  /// Layout author sheet subtitle.
  ///
  /// In en, this message translates to:
  /// **'Set the topology once, then reuse it across events.'**
  String get hostsEventSuccessStepRoomLayoutAuthorSubtitle;

  /// Layout asset name field.
  ///
  /// In en, this message translates to:
  /// **'Layout name'**
  String get hostsEventSuccessStepRoomLayoutName;

  /// Required layout name error.
  ///
  /// In en, this message translates to:
  /// **'Enter a layout name.'**
  String get hostsEventSuccessStepRoomLayoutNameRequired;

  /// Layout unit shape field.
  ///
  /// In en, this message translates to:
  /// **'Unit shape'**
  String get hostsEventSuccessStepRoomLayoutShape;

  /// Round layout unit shape.
  ///
  /// In en, this message translates to:
  /// **'Round tables'**
  String get hostsEventSuccessStepRoomLayoutShapeRound;

  /// Rectangular layout unit shape.
  ///
  /// In en, this message translates to:
  /// **'Rectangular tables'**
  String get hostsEventSuccessStepRoomLayoutShapeRectangle;

  /// Row layout unit shape.
  ///
  /// In en, this message translates to:
  /// **'Rows'**
  String get hostsEventSuccessStepRoomLayoutShapeRow;

  /// Court layout unit shape.
  ///
  /// In en, this message translates to:
  /// **'Courts'**
  String get hostsEventSuccessStepRoomLayoutShapeCourt;

  /// Zone layout unit shape.
  ///
  /// In en, this message translates to:
  /// **'Zones'**
  String get hostsEventSuccessStepRoomLayoutShapeZone;

  /// Layout unit count parameter.
  ///
  /// In en, this message translates to:
  /// **'Number of units'**
  String get hostsEventSuccessStepRoomLayoutUnits;

  /// Layout unit capacity parameter.
  ///
  /// In en, this message translates to:
  /// **'People per unit'**
  String get hostsEventSuccessStepRoomLayoutCapacity;

  /// Layout column parameter.
  ///
  /// In en, this message translates to:
  /// **'Units per row'**
  String get hostsEventSuccessStepRoomLayoutColumns;

  /// Unit count decrease semantics.
  ///
  /// In en, this message translates to:
  /// **'Decrease number of units'**
  String get hostsEventSuccessStepRoomLayoutDecreaseUnits;

  /// Unit count increase semantics.
  ///
  /// In en, this message translates to:
  /// **'Increase number of units'**
  String get hostsEventSuccessStepRoomLayoutIncreaseUnits;

  /// Capacity decrease semantics.
  ///
  /// In en, this message translates to:
  /// **'Decrease unit capacity'**
  String get hostsEventSuccessStepRoomLayoutDecreaseCapacity;

  /// Capacity increase semantics.
  ///
  /// In en, this message translates to:
  /// **'Increase unit capacity'**
  String get hostsEventSuccessStepRoomLayoutIncreaseCapacity;

  /// Column count decrease semantics.
  ///
  /// In en, this message translates to:
  /// **'Decrease units per row'**
  String get hostsEventSuccessStepRoomLayoutDecreaseColumns;

  /// Column count increase semantics.
  ///
  /// In en, this message translates to:
  /// **'Increase units per row'**
  String get hostsEventSuccessStepRoomLayoutIncreaseColumns;

  /// Saves and selects a reusable layout.
  ///
  /// In en, this message translates to:
  /// **'Save and select layout'**
  String get hostsEventSuccessStepRoomLayoutSave;

  /// Spatial room map title.
  ///
  /// In en, this message translates to:
  /// **'Room map'**
  String get eventSuccessRoomMapTitle;

  /// Explains assigned and confirmed placement states.
  ///
  /// In en, this message translates to:
  /// **'Outlined means assigned. Filled means the Host confirmed the attendee is there.'**
  String get eventSuccessRoomMapSubtitle;

  /// Assigned placement legend.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get eventSuccessRoomMapAssigned;

  /// Confirmed placement legend.
  ///
  /// In en, this message translates to:
  /// **'Host confirmed'**
  String get eventSuccessRoomMapConfirmed;

  /// Compact confirmed placement legend.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get eventSuccessRoomMapConfirmedShort;

  /// Open capacity-position legend.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get eventSuccessRoomMapOpen;

  /// Unavailable destination legend.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get eventSuccessRoomMapUnavailable;

  /// Placement requiring Host attention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get eventSuccessRoomMapNeedsAttention;

  /// Available unit semantics status.
  ///
  /// In en, this message translates to:
  /// **'Available destination'**
  String get eventSuccessRoomMapAvailable;

  /// Selected unit semantics status.
  ///
  /// In en, this message translates to:
  /// **'Selected destination'**
  String get eventSuccessRoomMapSelectedDestination;

  /// Accessible room-unit occupancy and destination state.
  ///
  /// In en, this message translates to:
  /// **'{unitLabel}, {occupied} of {capacity} occupied, {status}'**
  String eventSuccessRoomMapUnitSemantics({
    required String unitLabel,
    required int occupied,
    required int capacity,
    required String status,
  });

  /// Attendee has no current room unit.
  ///
  /// In en, this message translates to:
  /// **'Not placed'**
  String get eventSuccessRoomMapNotPlaced;

  /// Selected attendee current room unit.
  ///
  /// In en, this message translates to:
  /// **'At {unitLabel}'**
  String eventSuccessRoomMapCurrentPosition({required String unitLabel});

  /// Compact disabled move action before destination selection.
  ///
  /// In en, this message translates to:
  /// **'Choose destination'**
  String get eventSuccessRoomMapChooseDestinationShort;

  /// Confirms moving the selected attendee to a room unit.
  ///
  /// In en, this message translates to:
  /// **'Move to {unitLabel}'**
  String eventSuccessRoomMapMoveToUnit({required String unitLabel});

  /// Tap placement instruction.
  ///
  /// In en, this message translates to:
  /// **'Select an attendee, then choose a destination.'**
  String get eventSuccessRoomMapSelectAttendee;

  /// Compact temporary placement scope.
  ///
  /// In en, this message translates to:
  /// **'This round'**
  String get eventSuccessRoomMapScopeThisRoundShort;

  /// Compact durable placement scope.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get eventSuccessRoomMapScopePinnedShort;

  /// Invalid destination capacity reason.
  ///
  /// In en, this message translates to:
  /// **'This unit is at capacity.'**
  String get eventSuccessRoomMapReasonCapacity;

  /// Invalid destination safety reason.
  ///
  /// In en, this message translates to:
  /// **'A safety separation keeps this destination unavailable.'**
  String get eventSuccessRoomMapReasonSafety;

  /// Invalid destination constraint reason.
  ///
  /// In en, this message translates to:
  /// **'A declared placement constraint keeps this destination unavailable.'**
  String get eventSuccessRoomMapReasonConstraint;

  /// Host confirms attendee placement.
  ///
  /// In en, this message translates to:
  /// **'Confirm position'**
  String get eventSuccessRoomMapConfirmPosition;

  /// Releases durable attendee placement.
  ///
  /// In en, this message translates to:
  /// **'Release pinned placement'**
  String get eventSuccessRoomMapReleasePinned;

  /// Additive drag affordance explanation.
  ///
  /// In en, this message translates to:
  /// **'On larger screens, drag is also available. Tap controls always work.'**
  String get eventSuccessRoomMapDragHint;

  /// Customers directory scope explanation.
  ///
  /// In en, this message translates to:
  /// **'Everyone who has attended, registered, been imported, or been added by your team.'**
  String get hostCustomersIntro;

  /// Messaging workspace label for direct inquiries and event broadcasts.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get hostMessagingWorkspaceInbox;

  /// Messaging workspace label for outbound history and composing.
  ///
  /// In en, this message translates to:
  /// **'Sends'**
  String get hostMessagingWorkspaceSends;

  /// Opens the explicit Host communication-route picker.
  ///
  /// In en, this message translates to:
  /// **'Choose channel'**
  String get hostSendsChooseChannel;

  /// Groups Host routes delivered inside Catch.
  ///
  /// In en, this message translates to:
  /// **'In Catch'**
  String get hostSendsInCatchChannels;

  /// Groups distinct personal, organizer-owned, and Catch-owned WhatsApp routes.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get hostSendsWhatsappChannels;

  /// Opens organizer WhatsApp sender setup.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Business settings'**
  String get hostSendsSettings;

  /// Channel and sender label for one-to-one Catch conversations.
  ///
  /// In en, this message translates to:
  /// **'Catch chat · Organizer'**
  String get hostSendsCatchChatChannel;

  /// Delivery semantics for Catch chat.
  ///
  /// In en, this message translates to:
  /// **'One linked Catch user · two-way in the Catch app'**
  String get hostSendsCatchChatDescription;

  /// Channel and sender label for an event announcement.
  ///
  /// In en, this message translates to:
  /// **'Catch announcement · Organizer'**
  String get hostSendsCatchAnnouncementChannel;

  /// Delivery semantics for a Catch event announcement.
  ///
  /// In en, this message translates to:
  /// **'Event roster · Activity plus preference-gated push · no reply thread'**
  String get hostSendsCatchAnnouncementDescription;

  /// Channel and sender label for organizer-owned WhatsApp Business.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Business · Organizer number'**
  String get hostSendsWhatsappBusinessChannel;

  /// Delivery semantics for an organizer WhatsApp campaign.
  ///
  /// In en, this message translates to:
  /// **'Permissioned CRM audience · approved template · delivery receipts'**
  String get hostSendsWhatsappBusinessDescription;

  /// Channel and sender label for a personal-device WhatsApp handoff.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp app · You'**
  String get hostSendsWhatsappAppChannel;

  /// Delivery semantics for a personal WhatsApp handoff.
  ///
  /// In en, this message translates to:
  /// **'Choose a person in Customers · editable text · you press Send · untracked by Catch'**
  String get hostSendsWhatsappAppDescription;

  /// Channel and sender label for organizer follower posts.
  ///
  /// In en, this message translates to:
  /// **'Follower update · Organizer'**
  String get hostSendsFollowerUpdateChannel;

  /// Delivery semantics for organizer follower posts.
  ///
  /// In en, this message translates to:
  /// **'Followers in Catch · Home and Activity · preference-gated push'**
  String get hostSendsFollowerUpdateDescription;

  /// Follower-update quota blocker in the Host route picker.
  ///
  /// In en, this message translates to:
  /// **'This organizer has used its three follower updates for the rolling seven-day window.'**
  String get hostSendsFollowerUpdateQuotaUsed;

  /// Compact follower-update quota status.
  ///
  /// In en, this message translates to:
  /// **'Weekly limit reached'**
  String get hostSendsWeeklyLimit;

  /// Audience label for an organizer follower update in Sends history.
  ///
  /// In en, this message translates to:
  /// **'Followers in Catch'**
  String get hostSendsFollowersAudience;

  /// Follower-update history marker for a linked event.
  ///
  /// In en, this message translates to:
  /// **'Linked event'**
  String get hostSendsLinkedEventUpdate;

  /// Channel and sender label for the separate Catch-owned WhatsApp route.
  ///
  /// In en, this message translates to:
  /// **'Catch WhatsApp · Catch number'**
  String get hostSendsCatchWhatsappChannel;

  /// Boundary for future Catch-owned WhatsApp messages.
  ///
  /// In en, this message translates to:
  /// **'Catch-owned sender and Catch-specific permission · not an organizer campaign'**
  String get hostSendsCatchWhatsappDescription;

  /// Loading state for managed-channel readiness.
  ///
  /// In en, this message translates to:
  /// **'Checking sender and template readiness…'**
  String get hostSendsChannelChecking;

  /// Error state for managed-channel readiness.
  ///
  /// In en, this message translates to:
  /// **'Readiness could not be loaded. Open settings to retry.'**
  String get hostSendsChannelUnavailable;

  /// Managed-channel availability label.
  ///
  /// In en, this message translates to:
  /// **'Setup required'**
  String get hostSendsSetupRequired;

  /// Honest availability label for a specified but inactive channel.
  ///
  /// In en, this message translates to:
  /// **'Not active'**
  String get hostSendsPlanned;

  /// Organizer WhatsApp environment configuration blocker.
  ///
  /// In en, this message translates to:
  /// **'Catch has not enabled the Meta provider in this environment.'**
  String get hostSendsWhatsappProviderUnavailable;

  /// Organizer WhatsApp sender connection blocker.
  ///
  /// In en, this message translates to:
  /// **'Connect and verify an organizer-owned WhatsApp Business number.'**
  String get hostSendsWhatsappSenderRequired;

  /// Organizer WhatsApp sender health blocker.
  ///
  /// In en, this message translates to:
  /// **'Finish sender testing or resolve its connection health.'**
  String get hostSendsWhatsappSenderNeedsAttention;

  /// Organizer WhatsApp approved-template blocker.
  ///
  /// In en, this message translates to:
  /// **'Sync at least one approved WhatsApp message template.'**
  String get hostSendsWhatsappTemplateRequired;

  /// Loads the next page of organizer Sends history.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get hostSendsLoadMore;

  /// Empty Sends history title.
  ///
  /// In en, this message translates to:
  /// **'No messages sent yet.'**
  String get hostSendsEmpty;

  /// Empty Sends history guidance.
  ///
  /// In en, this message translates to:
  /// **'Campaigns, event announcements, and follower updates will appear here after you send them.'**
  String get hostSendsEmptyHelp;

  /// Typed label for a WhatsApp campaign row.
  ///
  /// In en, this message translates to:
  /// **'Campaign'**
  String get hostSendsCampaignType;

  /// Typed label for an event announcement row.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get hostSendsAnnouncementType;

  /// Recipient count in a Sends row.
  ///
  /// In en, this message translates to:
  /// **'{count} people'**
  String hostSendsRecipients({required int count});

  /// Announcement partial failure status.
  ///
  /// In en, this message translates to:
  /// **'Some deliveries need attention'**
  String get hostSendsPartial;

  /// User-facing delivery state for an organizer follower update.
  ///
  /// In en, this message translates to:
  /// **'{status, select, pending{Delivering in Catch} completed{Available in Catch} partial{Some deliveries need attention} unknown{Delivery was not tracked} other{Delivery status unavailable}}'**
  String hostSendsFollowerDeliveryStatus({required String status});

  /// Channel facet label for retained WhatsApp threads.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Business · Organizer number'**
  String get hostInboxWhatsappChannel;

  /// Explicit channel/sender prefix for a Catch inquiry row.
  ///
  /// In en, this message translates to:
  /// **'Catch chat · Organizer · {details}'**
  String hostInboxCatchChatPreview({required String details});

  /// Delivery disclosure in the event announcement composer.
  ///
  /// In en, this message translates to:
  /// **'Recipients see a durable Activity update and may receive a push notification. This does not create a chat thread.'**
  String get hostInboxAnnouncementDisclosure;

  /// Closed event-announcement state.
  ///
  /// In en, this message translates to:
  /// **'Catch announcement · event delivery has closed'**
  String get hostInboxAnnouncementClosed;

  /// Backend-gated event-announcement state.
  ///
  /// In en, this message translates to:
  /// **'Catch announcement · backend preflight required'**
  String get hostInboxAnnouncementBackendRequired;

  /// Empty event-announcement audience state.
  ///
  /// In en, this message translates to:
  /// **'Catch announcement · no eligible recipients yet'**
  String get hostInboxAnnouncementNoRecipients;

  /// Available event-announcement delivery summary.
  ///
  /// In en, this message translates to:
  /// **'Catch announcement · Activity plus optional push'**
  String get hostInboxAnnouncementAvailable;

  /// Sends a free-form WhatsApp service reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get hostInboxWhatsappReply;

  /// WhatsApp reply composer hint.
  ///
  /// In en, this message translates to:
  /// **'Write a WhatsApp reply'**
  String get hostInboxWhatsappReplyHint;

  /// Open customer-service window state.
  ///
  /// In en, this message translates to:
  /// **'Replies available until {time}'**
  String hostInboxWhatsappWindowOpen({required String time});

  /// Closed customer-service window state shown before composing.
  ///
  /// In en, this message translates to:
  /// **'The 24-hour reply window is closed. Start a new message with an approved template.'**
  String get hostInboxWhatsappWindowClosed;

  /// Bounded WhatsApp message history notice.
  ///
  /// In en, this message translates to:
  /// **'Only the 200 most recent retained messages are shown.'**
  String get hostInboxWhatsappHistoryTruncated;

  /// Campaign scheduling field label.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get hostSendsDeliveryTime;

  /// Immediate campaign delivery choice.
  ///
  /// In en, this message translates to:
  /// **'Send after approval'**
  String get hostSendsSendNow;

  /// Campaign schedule picker action.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get hostSendsSchedule;

  /// Clears a campaign schedule.
  ///
  /// In en, this message translates to:
  /// **'Send after approval'**
  String get hostSendsClearSchedule;

  /// Customer detail section for organizer-visible phone and email evidence.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get hostCustomersContactDetails;

  /// Opens editable organizer-entered customer contact details.
  ///
  /// In en, this message translates to:
  /// **'Edit details'**
  String get hostCustomersEditDetails;

  /// Empty value shown for a non-editable customer contact field.
  ///
  /// In en, this message translates to:
  /// **'Not saved'**
  String get hostCustomersNotSaved;

  /// Customer event-history status for a completed check-in.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get hostCustomersCheckedIn;

  /// Adds an organizer CRM contact with a name, at least one contact method, and an optional private note.
  ///
  /// In en, this message translates to:
  /// **'Add customer'**
  String get hostCustomersAdd;

  /// Full-page manual CRM contact route title.
  ///
  /// In en, this message translates to:
  /// **'Add a customer'**
  String get hostCustomersAddTitle;

  /// Organizer-owned customer display name used by create and edit states.
  ///
  /// In en, this message translates to:
  /// **'Name shown to your team'**
  String get hostCustomersName;

  /// Manual customer creation guidance for the organizer-owned display name.
  ///
  /// In en, this message translates to:
  /// **'Use the name your team will recognize.'**
  String get hostCustomersNameHelp;

  /// Manual CRM identity boundary.
  ///
  /// In en, this message translates to:
  /// **'Add a name and at least one way to reach this customer. Phone and email stay unverified and never grant messaging permission.'**
  String get hostCustomersAddHelp;

  /// Required manual customer name validation.
  ///
  /// In en, this message translates to:
  /// **'Enter the customer’s name.'**
  String get hostCustomersNameRequired;

  /// Manual customer create and edit validation requiring a durable contact method.
  ///
  /// In en, this message translates to:
  /// **'Add or keep at least one mobile number or email address.'**
  String get hostCustomersContactMethodRequired;

  /// Organizer-owned customer phone field.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get hostCustomersPhone;

  /// E.164 guidance for a manual customer phone.
  ///
  /// In en, this message translates to:
  /// **'Include the country code, for example +919876543210.'**
  String get hostCustomersPhoneHelp;

  /// Manual customer phone validation.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number with country code.'**
  String get hostCustomersPhoneInvalid;

  /// Organizer-owned customer email field.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get hostCustomersEmail;

  /// Manual customer email validation.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get hostCustomersEmailInvalid;

  /// Optional organizer-private note created with a customer.
  ///
  /// In en, this message translates to:
  /// **'Private note'**
  String get hostCustomersInitialNote;

  /// Privacy guidance for the optional note on manual customer creation.
  ///
  /// In en, this message translates to:
  /// **'Private notes are visible only to this organizer’s management team.'**
  String get hostCustomersInitialNoteHelp;

  /// Boundary between organizer-owned contact details and a linked Catch profile.
  ///
  /// In en, this message translates to:
  /// **'Linked Catch profiles stay private. Phone and email can’t be edited here.'**
  String get hostCustomersVerifiedDetailsManagedByCatch;

  /// Labels manually entered customer endpoints as unverified.
  ///
  /// In en, this message translates to:
  /// **'Added by your team · not verified by Catch'**
  String get hostCustomersUnverifiedContactDetails;

  /// Customer-directory load failure title.
  ///
  /// In en, this message translates to:
  /// **'Customers unavailable'**
  String get hostCustomersUnavailable;

  /// Customer-directory retry action.
  ///
  /// In en, this message translates to:
  /// **'Reload customers'**
  String get hostCustomersReload;

  /// Customer-detail load failure title.
  ///
  /// In en, this message translates to:
  /// **'Customer details unavailable'**
  String get hostCustomersDetailUnavailable;

  /// Missing customer-detail title.
  ///
  /// In en, this message translates to:
  /// **'Customer not found'**
  String get hostCustomersDetailNotFound;

  /// Customer-detail retry action.
  ///
  /// In en, this message translates to:
  /// **'Reload customer'**
  String get hostCustomersReloadDetail;

  /// Active customer segment and its server-backed match count.
  ///
  /// In en, this message translates to:
  /// **'{label} · {countLabel}'**
  String hostCustomersFilterSummary({
    required String label,
    required String countLabel,
  });

  /// Opens the grouped customer filter sheet.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get hostCustomersFilters;

  /// Clears the active customer segment filter.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get hostCustomersClearFilter;

  /// Reloads customer history coverage after an organizer import or repair.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get hostCustomersCoverageRefresh;

  /// Starts a campaign for the exact number of customers in the active segment.
  ///
  /// In en, this message translates to:
  /// **'Message these {count}'**
  String hostCustomersMessageThese({required int count});

  /// Starts a campaign for a lower-bound number of customers in the active segment.
  ///
  /// In en, this message translates to:
  /// **'Message these {count}+'**
  String hostCustomersMessageTheseAtLeast({required int count});

  /// Opens the Messaging workspace when the current customer view cannot be used directly as a campaign audience.
  ///
  /// In en, this message translates to:
  /// **'Open messaging'**
  String get hostCustomersOpenMessaging;

  /// Grouped customer filter sheet title.
  ///
  /// In en, this message translates to:
  /// **'Filter customers'**
  String get hostCustomersFilterSheetTitle;

  /// Explains when the grouped customer filter result count updates.
  ///
  /// In en, this message translates to:
  /// **'Choose one computed segment or one of your tags. The result count updates after you apply it.'**
  String get hostCustomersFilterSheetSubtitle;

  /// Customer segment group for attendance lifecycle filters.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get hostCustomersFilterGroupAttendance;

  /// Customer segment group for attendance reliability filters.
  ///
  /// In en, this message translates to:
  /// **'Reliability'**
  String get hostCustomersFilterGroupReliability;

  /// Customer segment group for advocacy filters.
  ///
  /// In en, this message translates to:
  /// **'Advocacy'**
  String get hostCustomersFilterGroupAdvocacy;

  /// Customer segment group for sender-backed reachable channels.
  ///
  /// In en, this message translates to:
  /// **'Reachable'**
  String get hostCustomersFilterGroupReachable;

  /// Customer filter chip with its server-backed match count.
  ///
  /// In en, this message translates to:
  /// **'{label} · {countLabel}'**
  String hostCustomersFilterOption({
    required String label,
    required String countLabel,
  });

  /// Exact number of people matching a customer audience query.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String hostCustomersPeopleCount({required int count});

  /// Lower-bound number of people matching a customer audience query.
  ///
  /// In en, this message translates to:
  /// **'{count}+ people'**
  String hostCustomersPeopleCountAtLeast({required int count});

  /// Temporary customer segment count state.
  ///
  /// In en, this message translates to:
  /// **'Loading count'**
  String get hostCustomersCountLoading;

  /// Customer segment count failure state.
  ///
  /// In en, this message translates to:
  /// **'Count unavailable'**
  String get hostCustomersCountUnavailable;

  /// Explainable alias for the versioned lapsed-regular segment.
  ///
  /// In en, this message translates to:
  /// **'At risk'**
  String get hostCustomersFilterAtRisk;

  /// Customer row warning tag for ambiguous identity resolution.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get hostCustomersNeedsReview;

  /// Opens the manager-only customer merge review.
  ///
  /// In en, this message translates to:
  /// **'Review possible duplicates'**
  String get hostCustomersReviewDuplicates;

  /// Merge-review sheet title.
  ///
  /// In en, this message translates to:
  /// **'Possible duplicate customers'**
  String get hostCustomersMergeReviewTitle;

  /// Explains the manager-controlled merge boundary.
  ///
  /// In en, this message translates to:
  /// **'Nothing is merged automatically. Compare the evidence, then choose which customer record to keep.'**
  String get hostCustomersMergeReviewHelp;

  /// Empty merge-review state.
  ///
  /// In en, this message translates to:
  /// **'No possible duplicates need review.'**
  String get hostCustomersMergeReviewEmpty;

  /// Verified UID merge evidence.
  ///
  /// In en, this message translates to:
  /// **'Same verified Catch account'**
  String get hostCustomersMergeEvidenceVerifiedUid;

  /// Verified phone merge evidence.
  ///
  /// In en, this message translates to:
  /// **'Same verified phone'**
  String get hostCustomersMergeEvidenceVerifiedPhone;

  /// Proposed imported-phone merge evidence.
  ///
  /// In en, this message translates to:
  /// **'Same imported phone'**
  String get hostCustomersMergeEvidenceImportedPhone;

  /// Proposed normalized-email merge evidence.
  ///
  /// In en, this message translates to:
  /// **'Same email'**
  String get hostCustomersMergeEvidenceEmail;

  /// Computed shared-event evidence for a candidate pair.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No shared events} =1{1 shared event} other{{count} shared events}}'**
  String hostCustomersMergeSharedEvents({required int count});

  /// Selects the surviving customer record.
  ///
  /// In en, this message translates to:
  /// **'Keep {name}'**
  String hostCustomersMergeKeep({required String name});

  /// Confirms a reviewed customer merge.
  ///
  /// In en, this message translates to:
  /// **'Merge customers'**
  String get hostCustomersMergeAction;

  /// Durably dismisses a duplicate candidate.
  ///
  /// In en, this message translates to:
  /// **'Different people'**
  String get hostCustomersDifferentPeople;

  /// Merge confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Merge these customer records?'**
  String get hostCustomersMergeConfirmTitle;

  /// Merge and identity-conflict confirmation.
  ///
  /// In en, this message translates to:
  /// **'{survivor} will be kept. Attendance and identity facts will move into that record. This also confirms any conflicting phone, email, or linked-account details shown here. You can undo the merge from the surviving customer’s details.'**
  String hostCustomersMergeConfirmBody({required String survivor});

  /// Dismissed merge-candidate section title.
  ///
  /// In en, this message translates to:
  /// **'Marked as different people'**
  String get hostCustomersDismissedDuplicates;

  /// Reopens the current manager's prior different-people decision.
  ///
  /// In en, this message translates to:
  /// **'Review again'**
  String get hostCustomersReopenDuplicate;

  /// Explains manager-scoped reversal authority.
  ///
  /// In en, this message translates to:
  /// **'Only the manager who marked this pair can reopen it.'**
  String get hostCustomersReopenOwnerOnly;

  /// Active merge receipt section on the survivor.
  ///
  /// In en, this message translates to:
  /// **'Merged records'**
  String get hostCustomersMergedHistory;

  /// Active merge receipt summary.
  ///
  /// In en, this message translates to:
  /// **'{name} · {count, plural, =1{1 fact moved} other{{count} facts moved}}'**
  String hostCustomersMergedHistoryRow({
    required String name,
    required int count,
  });

  /// Reverses one active customer merge receipt.
  ///
  /// In en, this message translates to:
  /// **'Undo merge'**
  String get hostCustomersUndoMerge;

  /// Unmerge confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Undo this merge?'**
  String get hostCustomersUndoMergeTitle;

  /// Unmerge confirmation body.
  ///
  /// In en, this message translates to:
  /// **'The original customer record and its moved facts will be restored.'**
  String get hostCustomersUndoMergeBody;

  /// Empty customer directory title.
  ///
  /// In en, this message translates to:
  /// **'No customers yet'**
  String get hostCustomersEmpty;

  /// Filtered customer directory empty state.
  ///
  /// In en, this message translates to:
  /// **'No customers match these filters.'**
  String get hostCustomersNoResults;

  /// Loads the next customer directory page.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get hostCustomersLoadMore;

  /// Customer attendance stats heading.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get hostCustomersDetailAttendance;

  /// Customer events with a confirmed or checked-in attendance edge.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get hostCustomersExpected;

  /// Checked-in events divided by expected events for a customer.
  ///
  /// In en, this message translates to:
  /// **'Attendance rate'**
  String get hostCustomersAttendanceRate;

  /// Unified customer revenue heading with explicit provenance.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get hostCustomersDetailRevenue;

  /// Zero unified customer revenue state.
  ///
  /// In en, this message translates to:
  /// **'No revenue has been recorded for this customer.'**
  String get hostCustomersDetailNoRevenue;

  /// Revenue data availability boundary.
  ///
  /// In en, this message translates to:
  /// **'Revenue facts are unavailable right now.'**
  String get hostCustomersDetailRevenueUnavailable;

  /// Partial revenue coverage warning.
  ///
  /// In en, this message translates to:
  /// **'This total includes the available event and payment facts, but some bounded history may be missing.'**
  String get hostCustomersDetailRevenuePartial;

  /// Number of payment, imported, provider, or estimated facts for one currency.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 revenue fact} other{{count} revenue facts}}'**
  String hostCustomersDetailRevenueFacts({required int count});

  /// Catch-completed payment provenance label.
  ///
  /// In en, this message translates to:
  /// **'Catch confirmed'**
  String get hostCustomersRevenueSourceCatch;

  /// Financially complete external provider provenance label.
  ///
  /// In en, this message translates to:
  /// **'Provider confirmed'**
  String get hostCustomersRevenueSourceProvider;

  /// Organizer-imported revenue provenance label.
  ///
  /// In en, this message translates to:
  /// **'Imported by your team'**
  String get hostCustomersRevenueSourceImport;

  /// Organizer-entered unverified revenue provenance label.
  ///
  /// In en, this message translates to:
  /// **'Estimated by your team'**
  String get hostCustomersRevenueSourceEstimate;

  /// Shared-order allocation note on one customer event.
  ///
  /// In en, this message translates to:
  /// **'allocated from a shared order'**
  String get hostCustomersRevenueSharedOrder;

  /// Catch-native event origin label.
  ///
  /// In en, this message translates to:
  /// **'Catch-hosted'**
  String get hostCustomersEventOriginCatch;

  /// External companion event origin label.
  ///
  /// In en, this message translates to:
  /// **'Externally hosted'**
  String get hostCustomersEventOriginExternal;

  /// Legacy event origin label when no provenance snapshot exists.
  ///
  /// In en, this message translates to:
  /// **'Event origin unavailable'**
  String get hostCustomersEventOriginUnknown;

  /// Starts a direct Catch chat with a linked customer.
  ///
  /// In en, this message translates to:
  /// **'Start Catch chat'**
  String get hostCustomersStartCatchChat;

  /// Explicit channel and sender label for a personal-device WhatsApp handoff.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp app · You'**
  String get hostCustomersWhatsappAppChannel;

  /// Disclosure for the untracked personal WhatsApp handoff.
  ///
  /// In en, this message translates to:
  /// **'Opens WhatsApp on this device with editable text. You review it and press Send; Catch cannot track delivery or replies.'**
  String get hostCustomersWhatsappHandoffDisclosure;

  /// Personal WhatsApp handoff blocker when the customer has no valid phone.
  ///
  /// In en, this message translates to:
  /// **'Add a valid phone number to use a personal WhatsApp handoff.'**
  String get hostCustomersWhatsappMissingPhone;

  /// Personal WhatsApp handoff blocker for an organizer-admin suppression.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp handoff is paused for this customer by your team.'**
  String get hostCustomersWhatsappOrganizerSuppressed;

  /// Personal WhatsApp handoff blocker for an explicit customer opt-out.
  ///
  /// In en, this message translates to:
  /// **'This customer has opted out of WhatsApp messages.'**
  String get hostCustomersWhatsappContactOptedOut;

  /// Title for the personal WhatsApp handoff composer.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp app'**
  String get hostCustomersWhatsappHandoffTitle;

  /// Recipient shown in the personal WhatsApp handoff composer.
  ///
  /// In en, this message translates to:
  /// **'{name} · {phone}'**
  String hostCustomersWhatsappHandoffSubtitle({
    required String name,
    required String phone,
  });

  /// Editable starter text for a personal WhatsApp handoff.
  ///
  /// In en, this message translates to:
  /// **'Hi {name},'**
  String hostCustomersWhatsappDefaultMessage({required String name});

  /// Editable message field label in the personal WhatsApp handoff composer.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get hostCustomersWhatsappMessage;

  /// Launches WhatsApp with the selected customer and editable text prefilled.
  ///
  /// In en, this message translates to:
  /// **'Open WhatsApp'**
  String get hostCustomersOpenWhatsapp;

  /// Failure shown when the personal WhatsApp handoff cannot launch.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp on this device.'**
  String get hostCustomersWhatsappOpenFailed;

  /// Unlinked customer messaging boundary.
  ///
  /// In en, this message translates to:
  /// **'A conversation becomes available after this customer is unambiguously linked to a Catch account.'**
  String get hostCustomersConversationUnlinked;

  /// Ambiguous customer messaging boundary.
  ///
  /// In en, this message translates to:
  /// **'Resolve this customer’s identity before starting a conversation.'**
  String get hostCustomersConversationAmbiguous;

  /// Customer event history heading.
  ///
  /// In en, this message translates to:
  /// **'Past attendance'**
  String get hostCustomersEventHistory;

  /// Customer with no checked-in event history.
  ///
  /// In en, this message translates to:
  /// **'No checked-in events yet.'**
  String get hostCustomersNoAttendance;

  /// Organizer-authored manual-tag group, visually separate from computed audience segments.
  ///
  /// In en, this message translates to:
  /// **'Your tags'**
  String get hostCustomersFilterGroupYourTags;

  /// Explains why the segment-based export is unavailable for an organizer-authored tag filter.
  ///
  /// In en, this message translates to:
  /// **'Clear the manual tag filter to export.'**
  String get hostCustomersManualTagExportUnavailable;

  /// Organizer-authored contact memory section heading.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get hostCustomersMemory;

  /// Privacy boundary for organizer-authored contact memory.
  ///
  /// In en, this message translates to:
  /// **'Notes and your tags are private to this organizer’s management team.'**
  String get hostCustomersMemoryHelp;

  /// Organizer-authored tags on one customer.
  ///
  /// In en, this message translates to:
  /// **'Your tags'**
  String get hostCustomersManualTags;

  /// Opens manual tag assignment for one customer.
  ///
  /// In en, this message translates to:
  /// **'Edit tags'**
  String get hostCustomersEditTags;

  /// Empty manual-tag state on contact detail.
  ///
  /// In en, this message translates to:
  /// **'No organizer tags yet.'**
  String get hostCustomersNoManualTags;

  /// Manual tag assignment sheet title.
  ///
  /// In en, this message translates to:
  /// **'Customer tags'**
  String get hostCustomersTagSheetTitle;

  /// Manual tag assignment and cap guidance.
  ///
  /// In en, this message translates to:
  /// **'Choose up to 5 of your organizer’s tags, or create a new one.'**
  String get hostCustomersTagSheetSubtitle;

  /// Manual tag label input title.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get hostCustomersNewTag;

  /// Adds a new label to the pending manual-tag assignment.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get hostCustomersAddTag;

  /// Persists manual tags for one customer.
  ///
  /// In en, this message translates to:
  /// **'Save tags'**
  String get hostCustomersSaveTags;

  /// Server-enforced per-contact manual-tag cap.
  ///
  /// In en, this message translates to:
  /// **'A customer can have up to 5 tags.'**
  String get hostCustomersTagContactLimit;

  /// Server-enforced organizer manual-tag vocabulary cap.
  ///
  /// In en, this message translates to:
  /// **'Your organizer already has 20 tags. Choose an existing tag.'**
  String get hostCustomersTagVocabularyLimit;

  /// Organizer-authored contact notes heading.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get hostCustomersNotes;

  /// Opens the append contact-note sheet.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get hostCustomersAddNote;

  /// Opens an existing contact note for editing.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get hostCustomersEditNote;

  /// Organizer contact note input title.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get hostCustomersNoteBody;

  /// Persists a new or edited contact note.
  ///
  /// In en, this message translates to:
  /// **'Save note'**
  String get hostCustomersSaveNote;

  /// Empty organizer contact-note state.
  ///
  /// In en, this message translates to:
  /// **'No notes yet.'**
  String get hostCustomersNoNotes;

  /// Contact note attribution for the current manager.
  ///
  /// In en, this message translates to:
  /// **'You · {date}'**
  String hostCustomersNoteByYou({required String date});

  /// Contact note attribution for another organizer manager.
  ///
  /// In en, this message translates to:
  /// **'Team member · {date}'**
  String hostCustomersNoteByTeam({required String date});

  /// Marks a contact note whose body was edited after creation.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get hostCustomersNoteEdited;

  /// Bounded contact-note history notice.
  ///
  /// In en, this message translates to:
  /// **'Only the 100 newest notes are shown.'**
  String get hostCustomersNotesTruncated;

  /// Localized optional note-history failure title.
  ///
  /// In en, this message translates to:
  /// **'Notes could not be loaded'**
  String get hostCustomersNotesUnavailableTitle;

  /// Localized optional note-history failure guidance.
  ///
  /// In en, this message translates to:
  /// **'The customer details are available. Try reloading to restore note history.'**
  String get hostCustomersNotesUnavailableBody;

  /// Per-person campaign delivery history heading.
  ///
  /// In en, this message translates to:
  /// **'Messages sent'**
  String get hostCustomersSendHistory;

  /// Empty per-person campaign history state.
  ///
  /// In en, this message translates to:
  /// **'No campaign messages sent yet.'**
  String get hostCustomersNoSends;

  /// Bounded per-person campaign history notice.
  ///
  /// In en, this message translates to:
  /// **'Only the 100 newest campaign deliveries are shown.'**
  String get hostCustomersSendsTruncated;

  /// Localized optional send-history failure title.
  ///
  /// In en, this message translates to:
  /// **'Message history could not be loaded'**
  String get hostCustomersSendsUnavailableTitle;

  /// Localized optional send-history failure guidance.
  ///
  /// In en, this message translates to:
  /// **'The customer details are available. Try reloading to restore message history.'**
  String get hostCustomersSendsUnavailableBody;

  /// Organizer campaign delivery state shown on contact detail.
  ///
  /// In en, this message translates to:
  /// **'{status, select, pending{Pending} sending{Sending} suppressed{Suppressed} accepted{Accepted} sent{Sent} delivered{Delivered} read{Read} failed{Failed} replied{Replied} optedOut{Opted out} other{Unknown}}'**
  String hostCustomersSendStatus({required String status});

  /// Customer messaging, consent, and removal controls heading.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get hostCustomersControls;

  /// Per-customer organizer campaign delivery toggle.
  ///
  /// In en, this message translates to:
  /// **'Organizer messages'**
  String get hostCustomersOrganizerMessages;

  /// Customers directory sort menu group label.
  ///
  /// In en, this message translates to:
  /// **'Sort customers'**
  String get hostCustomersSort;

  /// Visible Customers directory sort control with its current ordering.
  ///
  /// In en, this message translates to:
  /// **'Sort: {label}'**
  String hostCustomersSortControl({required String label});

  /// Explains the Customers directory sort sheet.
  ///
  /// In en, this message translates to:
  /// **'Choose how customers are ordered.'**
  String get hostCustomersSortSheetSubtitle;

  /// Customers directory last-seen ordering.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get hostCustomersSortLastSeen;

  /// Customers directory event-attendance ordering.
  ///
  /// In en, this message translates to:
  /// **'Most attended'**
  String get hostCustomersSortMostAttended;

  /// Customers directory alphabetical ordering.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get hostCustomersSortName;

  /// Accessible label for the Customers header overflow commands.
  ///
  /// In en, this message translates to:
  /// **'More customer actions'**
  String get hostCustomersMoreActions;

  /// Number of organizer contacts currently reachable on WhatsApp.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 WhatsApp-ready contact} other{{count} WhatsApp-ready contacts}}'**
  String hostCustomersWhatsappReadyCount({required int count});

  /// Concise customer source and linked-account summary shown on the page.
  ///
  /// In en, this message translates to:
  /// **'{importedCount, plural, =1{1 imported or added by your team} other{{importedCount} imported or added by your team}} · {linkedCount, plural, =1{1 linked Catch account} other{{linkedCount} linked Catch accounts}}'**
  String hostCustomersSourceSummary({
    required int importedCount,
    required int linkedCount,
  });

  /// Host accountability sweep heading.
  ///
  /// In en, this message translates to:
  /// **'Return sweep'**
  String get eventSuccessAccountabilityTitle;

  /// Explains the non-alarmist accountability sweep boundary.
  ///
  /// In en, this message translates to:
  /// **'Mark each checked-in guest as returned or departed. People may leave quietly; this is a safety aid, not a checkout requirement.'**
  String get eventSuccessAccountabilitySubtitle;

  /// Resolved attendee count in the Host sweep.
  ///
  /// In en, this message translates to:
  /// **'{resolved} of {total} marked'**
  String eventSuccessAccountabilityProgress({
    required int resolved,
    required int total,
  });

  /// Empty accountability sweep state.
  ///
  /// In en, this message translates to:
  /// **'No checked-in guests to review.'**
  String get eventSuccessAccountabilityEmpty;

  /// Unresolved accountability choice.
  ///
  /// In en, this message translates to:
  /// **'Not marked'**
  String get eventSuccessAccountabilityUnresolved;

  /// Returned accountability choice.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get eventSuccessAccountabilityReturned;

  /// Departed accountability choice.
  ///
  /// In en, this message translates to:
  /// **'Departed'**
  String get eventSuccessAccountabilityDeparted;

  /// Completion warning title for an unresolved sweep.
  ///
  /// In en, this message translates to:
  /// **'Some guests aren’t marked yet'**
  String get eventSuccessAccountabilityWarningTitle;

  /// Normalizes quiet departures while warning before completion.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 checked-in guest isn’t marked returned or departed.} other{{count} checked-in guests aren’t marked returned or departed.}} People sometimes leave without checking out. Review the list if useful, or finish anyway.'**
  String eventSuccessAccountabilityWarningMessage({required int count});

  /// Dismisses completion to review unresolved guests.
  ///
  /// In en, this message translates to:
  /// **'Review sweep'**
  String get eventSuccessAccountabilityReviewAction;

  /// Acknowledges unresolved guests and completes the event.
  ///
  /// In en, this message translates to:
  /// **'Finish anyway'**
  String get eventSuccessAccountabilityFinishAnywayAction;

  /// Names the Event Success resource whose local area could not load.
  ///
  /// In en, this message translates to:
  /// **'{resource} unavailable'**
  String eventSuccessHostResourceUnavailableTitle({required String resource});

  /// Load-bearing Event Success plan resource name.
  ///
  /// In en, this message translates to:
  /// **'Live guide'**
  String get eventSuccessHostResourceLiveGuide;

  /// Event Success operational roster resource name.
  ///
  /// In en, this message translates to:
  /// **'Guest roster'**
  String get eventSuccessHostResourceGuestRoster;

  /// Event Success micro-pod assignment resource name.
  ///
  /// In en, this message translates to:
  /// **'Micro-pod assignments'**
  String get eventSuccessHostResourceMicroPodAssignments;

  /// Event Success published rotation resource name.
  ///
  /// In en, this message translates to:
  /// **'Published rotations'**
  String get eventSuccessHostResourcePublishedRotations;

  /// Event Success Host-only rotation draft resource name.
  ///
  /// In en, this message translates to:
  /// **'Rotation drafts'**
  String get eventSuccessHostResourceRotationDrafts;

  /// Event Success micro-pod profile enrichment resource name.
  ///
  /// In en, this message translates to:
  /// **'Micro-pod attendee profiles'**
  String get eventSuccessHostResourceMicroPodProfiles;

  /// Event Success rotation profile enrichment resource name.
  ///
  /// In en, this message translates to:
  /// **'Rotation attendee profiles'**
  String get eventSuccessHostResourceRotationProfiles;

  /// Event Success attendee preference resource name.
  ///
  /// In en, this message translates to:
  /// **'Attendee preferences'**
  String get eventSuccessHostResourceAttendeePreferences;

  /// Event Success attendee Host-help request resource name.
  ///
  /// In en, this message translates to:
  /// **'Host-help requests'**
  String get eventSuccessHostResourceHostHelpRequests;

  /// Event Success Host-help profile enrichment resource name.
  ///
  /// In en, this message translates to:
  /// **'Host-help attendee profiles'**
  String get eventSuccessHostResourceHostHelpProfiles;

  /// Event Success aggregate scorecard resource name.
  ///
  /// In en, this message translates to:
  /// **'Event report'**
  String get eventSuccessHostResourceEventReport;

  /// Concise lifecycle subtitle for a hosted event before check-in opens.
  ///
  /// In en, this message translates to:
  /// **'Event preparation'**
  String get hostsHostEventManageWorkspacePreparation;

  /// Preparation section title for stable event facts.
  ///
  /// In en, this message translates to:
  /// **'EVENT DETAILS'**
  String get hostsHostEventManagePreparationEventDetails;

  /// Preparation section title for website registration and imported guest intake.
  ///
  /// In en, this message translates to:
  /// **'GUEST SOURCES'**
  String get hostsHostEventManagePreparationGuestSources;

  /// Preparation section title for temporary event staff access.
  ///
  /// In en, this message translates to:
  /// **'TEAM & ACCESS'**
  String get hostsHostEventManagePreparationTeamAccess;

  /// Concise lifecycle subtitle while Host runtime controls are relevant.
  ///
  /// In en, this message translates to:
  /// **'Live operations'**
  String get hostsHostEventManageWorkspaceRuntime;

  /// Concise lifecycle subtitle after Host runtime closes.
  ///
  /// In en, this message translates to:
  /// **'Event recap'**
  String get hostsHostEventManageWorkspaceRecap;

  /// Concise lifecycle subtitle for a cancelled hosted event.
  ///
  /// In en, this message translates to:
  /// **'Cancelled event'**
  String get hostsHostEventManageWorkspaceCancelled;

  /// Post-event disclosure title for secondary event and Event Success configuration.
  ///
  /// In en, this message translates to:
  /// **'Review event setup'**
  String get hostsHostEventManageReviewSetupTitle;

  /// Explains the secondary post-event setup audit disclosure.
  ///
  /// In en, this message translates to:
  /// **'Event details, Host actions, and Event Success configuration remain available for audit.'**
  String get hostsHostEventManageReviewSetupBody;

  /// Title for the pull-out Host event roster.
  ///
  /// In en, this message translates to:
  /// **'Guest roster'**
  String get hostsHostEventRosterDrawerTitle;

  /// Booked guest count in the pull-out roster header.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No booked guests} =1{1 booked guest} other{{count} booked guests}}'**
  String hostsHostEventRosterDrawerCount({required int count});

  /// Accessible label for the closed roster pull tab.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Open guest roster} =1{Open guest roster, 1 booked guest} other{Open guest roster, {count} booked guests}}'**
  String hostsHostEventRosterDrawerOpen({required int count});

  /// Accessible label for closing the pull-out roster.
  ///
  /// In en, this message translates to:
  /// **'Close guest roster'**
  String get hostsHostEventRosterDrawerClose;

  /// Host application review queue title.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get hostApplicationsTitle;

  /// Application-list or detail load failure title.
  ///
  /// In en, this message translates to:
  /// **'Applications unavailable'**
  String get hostApplicationsUnavailable;

  /// Application-list or detail retry action.
  ///
  /// In en, this message translates to:
  /// **'Reload applications'**
  String get hostApplicationsReload;

  /// Application detail missing-state title.
  ///
  /// In en, this message translates to:
  /// **'Application not found'**
  String get hostApplicationNotFound;

  /// Customers header action opening the application review queue.
  ///
  /// In en, this message translates to:
  /// **'Review applications'**
  String get hostApplicationsOpen;

  /// Application queue spreadsheet import action.
  ///
  /// In en, this message translates to:
  /// **'Import responses'**
  String get hostApplicationsImport;

  /// Accessible label and compact sheet title for application ordering.
  ///
  /// In en, this message translates to:
  /// **'Sort applications'**
  String get hostApplicationsSort;

  /// Application spreadsheet import sheet title.
  ///
  /// In en, this message translates to:
  /// **'Import applications'**
  String get hostApplicationsImportTitle;

  /// Explains provider-neutral automatic field mapping.
  ///
  /// In en, this message translates to:
  /// **'Every column is preserved. Recognized profile fields can support future prefill; unique questions stay organizer-only.'**
  String get hostApplicationsImportSubtitle;

  /// Mapping label for a canonical participant intake field.
  ///
  /// In en, this message translates to:
  /// **'Reusable profile field'**
  String get hostApplicationsImportReusableField;

  /// Mapping label for a proprietary form question.
  ///
  /// In en, this message translates to:
  /// **'Organizer-only question'**
  String get hostApplicationsImportOrganizerField;

  /// Confirms a bounded application spreadsheet import.
  ///
  /// In en, this message translates to:
  /// **'Import {count, plural, =1{1 application} other{{count} applications}}'**
  String hostApplicationsImportAction({required int count});

  /// Application import batch truncation explanation.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 additional row will need a second import.} other{{count} additional rows will need a second import.}}'**
  String hostApplicationsImportLimit({required int count});

  /// Application import requires a safe queue identity.
  ///
  /// In en, this message translates to:
  /// **'Map a Name, Full name, or First name column before importing.'**
  String get hostApplicationsImportMissingName;

  /// Empty application spreadsheet error.
  ///
  /// In en, this message translates to:
  /// **'The spreadsheet does not contain any application rows.'**
  String get hostApplicationsImportNoRows;

  /// Application import result summary.
  ///
  /// In en, this message translates to:
  /// **'Imported {created} and skipped {skipped}.'**
  String hostApplicationsImportComplete({
    required int created,
    required int skipped,
  });

  /// Default participant consent copy for imported-form versions that may later accept native submissions.
  ///
  /// In en, this message translates to:
  /// **'I agree to share these submitted answers with this organizer for application review.'**
  String get hostApplicationsConsentCopy;

  /// Default application retention disclosure.
  ///
  /// In en, this message translates to:
  /// **'The organizer may retain submitted answers for application review and customer history according to its stated policy.'**
  String get hostApplicationsRetentionCopy;

  /// Provider-neutral review queue explanation.
  ///
  /// In en, this message translates to:
  /// **'Review sign-ups from Catch forms or imported spreadsheets in one queue.'**
  String get hostApplicationsSubtitle;

  /// Application queue applicant-name search placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search by applicant name'**
  String get hostApplicationsSearch;

  /// Empty application queue title.
  ///
  /// In en, this message translates to:
  /// **'No applications yet'**
  String get hostApplicationsEmptyTitle;

  /// Empty application queue guidance without favoring one form provider.
  ///
  /// In en, this message translates to:
  /// **'Publish a Catch form or import responses from any spreadsheet. New submissions will appear here.'**
  String get hostApplicationsEmptyBody;

  /// Application queue newest sort.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get hostApplicationsSortNewest;

  /// Application queue oldest sort.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get hostApplicationsSortOldest;

  /// Application queue name sort.
  ///
  /// In en, this message translates to:
  /// **'Applicant name'**
  String get hostApplicationsSortName;

  /// Application queue all-status filter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get hostApplicationsFilterAll;

  /// Accessible title and tooltip for the application review-status filter.
  ///
  /// In en, this message translates to:
  /// **'Filter by review status'**
  String get hostApplicationsReviewStatusFilter;

  /// Visible application review-status filter value.
  ///
  /// In en, this message translates to:
  /// **'Review status: {status}'**
  String hostApplicationsReviewStatusFilterValue({required String status});

  /// New organizer application status.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get hostApplicationsStatusSubmitted;

  /// Organizer application in-review status.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get hostApplicationsStatusInReview;

  /// Approved organizer application status.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get hostApplicationsStatusApproved;

  /// Waitlisted organizer application status.
  ///
  /// In en, this message translates to:
  /// **'Waitlisted'**
  String get hostApplicationsStatusWaitlisted;

  /// Declined organizer application status.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get hostApplicationsStatusDeclined;

  /// Withdrawn organizer application status.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get hostApplicationsStatusWithdrawn;

  /// Native Catch form source label.
  ///
  /// In en, this message translates to:
  /// **'Catch form'**
  String get hostApplicationsSourceNative;

  /// Provider-neutral spreadsheet source label.
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet import'**
  String get hostApplicationsSourceImport;

  /// Generic external form connector source label.
  ///
  /// In en, this message translates to:
  /// **'Connected form'**
  String get hostApplicationsSourceConnector;

  /// Application submitted date metadata.
  ///
  /// In en, this message translates to:
  /// **'Submitted {date}'**
  String hostApplicationsSubmittedOn({required String date});

  /// Application queue pagination action.
  ///
  /// In en, this message translates to:
  /// **'Load more applications'**
  String get hostApplicationsLoadMore;

  /// Application detail answers section title.
  ///
  /// In en, this message translates to:
  /// **'Application answers'**
  String get hostApplicationAnswersTitle;

  /// Empty optional application answer value.
  ///
  /// In en, this message translates to:
  /// **'Not answered'**
  String get hostApplicationNotAnswered;

  /// Boolean yes application answer.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get hostApplicationAnswerYes;

  /// Boolean no application answer.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get hostApplicationAnswerNo;

  /// Application asset answer count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file} other{{count} files}}'**
  String hostApplicationAnswerFiles({required int count});

  /// Application detail validated outreach actions title.
  ///
  /// In en, this message translates to:
  /// **'Contact applicant'**
  String get hostApplicationOutreachTitle;

  /// Calls a validated E.164 application phone number.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get hostApplicationCall;

  /// Emails a validated application address.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get hostApplicationEmail;

  /// Opens a validated Instagram profile.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get hostApplicationInstagram;

  /// Opens a validated LinkedIn profile.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get hostApplicationLinkedin;

  /// Application detail absence of validated outreach data.
  ///
  /// In en, this message translates to:
  /// **'This form did not grant a usable phone, email, Instagram, or LinkedIn destination.'**
  String get hostApplicationNoOutreach;

  /// Application detail review section title.
  ///
  /// In en, this message translates to:
  /// **'Review decision'**
  String get hostApplicationReviewTitle;

  /// Organizer-only application review note label.
  ///
  /// In en, this message translates to:
  /// **'Private review note'**
  String get hostApplicationReviewNote;

  /// Organizer-only application review note hint.
  ///
  /// In en, this message translates to:
  /// **'Add context for your team'**
  String get hostApplicationReviewNoteHint;

  /// Application review transition action.
  ///
  /// In en, this message translates to:
  /// **'Mark in review'**
  String get hostApplicationMarkInReview;

  /// Application approval action.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get hostApplicationApprove;

  /// Application waitlist action.
  ///
  /// In en, this message translates to:
  /// **'Waitlist'**
  String get hostApplicationWaitlist;

  /// Application decline action.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get hostApplicationDecline;

  /// Successful application review mutation message.
  ///
  /// In en, this message translates to:
  /// **'Application review updated'**
  String get hostApplicationReviewUpdated;

  /// Host bottom navigation label for the standalone forms workspace.
  ///
  /// In en, this message translates to:
  /// **'Forms'**
  String get hostNavigationForms;

  /// Creates a standalone organizer form.
  ///
  /// In en, this message translates to:
  /// **'Create form'**
  String get hostFormsCreate;

  /// Forms workspace load failure title.
  ///
  /// In en, this message translates to:
  /// **'Forms unavailable'**
  String get hostFormsUnavailableTitle;

  /// Forms workspace temporary service failure guidance.
  ///
  /// In en, this message translates to:
  /// **'Forms is not available right now. Please try again in a moment.'**
  String get hostFormsUnavailableBody;

  /// Retries loading the Forms workspace.
  ///
  /// In en, this message translates to:
  /// **'Reload forms'**
  String get hostFormsReload;

  /// Missing form error title.
  ///
  /// In en, this message translates to:
  /// **'Form not found'**
  String get hostFormsNotFound;

  /// Form responses load failure title.
  ///
  /// In en, this message translates to:
  /// **'Responses unavailable'**
  String get hostFormResponsesUnavailableTitle;

  /// Form responses temporary service failure guidance.
  ///
  /// In en, this message translates to:
  /// **'Form responses are not available right now. Please try again in a moment.'**
  String get hostFormResponsesUnavailableBody;

  /// Retries loading form responses.
  ///
  /// In en, this message translates to:
  /// **'Reload responses'**
  String get hostFormResponsesReload;

  /// Missing form response error title.
  ///
  /// In en, this message translates to:
  /// **'Response not found'**
  String get hostFormResponseNotFound;

  /// Explains the organizer Forms workspace.
  ///
  /// In en, this message translates to:
  /// **'Applications, registrations, waivers, feedback, and surveys in one reusable workspace.'**
  String get hostFormsSubtitle;

  /// Forms directory search label.
  ///
  /// In en, this message translates to:
  /// **'Search forms'**
  String get hostFormsSearch;

  /// Shows every form lifecycle state.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get hostFormsFilterAll;

  /// Empty Forms workspace title.
  ///
  /// In en, this message translates to:
  /// **'No forms yet'**
  String get hostFormsEmptyTitle;

  /// Empty Forms workspace guidance.
  ///
  /// In en, this message translates to:
  /// **'Start with a template, then tailor the questions and identity requirements.'**
  String get hostFormsEmptyBody;

  /// Filtered Forms empty state title.
  ///
  /// In en, this message translates to:
  /// **'No forms match'**
  String get hostFormsNoMatchesTitle;

  /// Filtered Forms empty state guidance.
  ///
  /// In en, this message translates to:
  /// **'Try another search or lifecycle filter.'**
  String get hostFormsNoMatchesBody;

  /// Opens lifecycle and duplication actions for a form.
  ///
  /// In en, this message translates to:
  /// **'Form actions'**
  String get hostFormsActions;

  /// Forms directory row summary.
  ///
  /// In en, this message translates to:
  /// **'{purpose} · {status} · {count, plural, =0{No responses} =1{1 response} other{{count} responses}}'**
  String hostFormsRowSummary({
    required String purpose,
    required String status,
    required int count,
  });

  /// Loads the next server-backed Forms page.
  ///
  /// In en, this message translates to:
  /// **'Load more forms'**
  String get hostFormsLoadMore;

  /// Opens a form in the builder.
  ///
  /// In en, this message translates to:
  /// **'Edit form'**
  String get hostFormsOpen;

  /// Creates a draft copy of a form.
  ///
  /// In en, this message translates to:
  /// **'Duplicate form'**
  String get hostFormsDuplicate;

  /// Pauses new responses to a published form.
  ///
  /// In en, this message translates to:
  /// **'Pause responses'**
  String get hostFormsPause;

  /// Resumes new responses to a paused form.
  ///
  /// In en, this message translates to:
  /// **'Resume responses'**
  String get hostFormsResume;

  /// Archives a form and preserves its responses.
  ///
  /// In en, this message translates to:
  /// **'Archive form'**
  String get hostFormsArchive;

  /// Permanently deletes a never-published draft form.
  ///
  /// In en, this message translates to:
  /// **'Delete draft'**
  String get hostFormsDeleteDraft;

  /// Archive form confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Archive this form?'**
  String get hostFormsArchiveConfirmTitle;

  /// Archive form consequence copy.
  ///
  /// In en, this message translates to:
  /// **'Its public link will stop accepting responses. Existing responses stay available.'**
  String get hostFormsArchiveConfirmBody;

  /// Draft deletion confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Delete this draft?'**
  String get hostFormsDeleteConfirmTitle;

  /// Draft deletion consequence copy.
  ///
  /// In en, this message translates to:
  /// **'This draft has never been published and will be permanently removed.'**
  String get hostFormsDeleteConfirmBody;

  /// Forms workspace requires an organizer title.
  ///
  /// In en, this message translates to:
  /// **'Create an organizer first'**
  String get hostFormsNoOrganizerTitle;

  /// Forms workspace organizer requirement explanation.
  ///
  /// In en, this message translates to:
  /// **'Forms belong to an organizer so your team, brand, and response data remain scoped correctly.'**
  String get hostFormsNoOrganizerBody;

  /// Creates the organizer required by Forms.
  ///
  /// In en, this message translates to:
  /// **'Create organizer'**
  String get hostFormsCreateOrganizer;

  /// Draft form lifecycle label.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get hostFormsStatusDraft;

  /// Published form lifecycle label.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get hostFormsStatusPublished;

  /// Paused form lifecycle label.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get hostFormsStatusPaused;

  /// Archived form lifecycle label.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get hostFormsStatusArchived;

  /// Application form purpose label.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get hostFormsPurposeApplication;

  /// Registration form purpose label.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get hostFormsPurposeRegistration;

  /// Intake form purpose label.
  ///
  /// In en, this message translates to:
  /// **'Intake'**
  String get hostFormsPurposeIntake;

  /// Waiver form purpose label.
  ///
  /// In en, this message translates to:
  /// **'Waiver'**
  String get hostFormsPurposeWaiver;

  /// Feedback form purpose label.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get hostFormsPurposeFeedback;

  /// Survey form purpose label.
  ///
  /// In en, this message translates to:
  /// **'Survey'**
  String get hostFormsPurposeSurvey;

  /// Forms template gallery title.
  ///
  /// In en, this message translates to:
  /// **'Choose a template'**
  String get hostFormTemplatesTitle;

  /// Forms template gallery guidance.
  ///
  /// In en, this message translates to:
  /// **'Every template is editable. Start blank when you want full control.'**
  String get hostFormTemplatesSubtitle;

  /// Form template purpose and question count.
  ///
  /// In en, this message translates to:
  /// **'{purpose} · {count, plural, =1{1 question} other{{count} questions}}'**
  String hostFormTemplateSummary({required String purpose, required int count});

  /// Fallback form builder route title.
  ///
  /// In en, this message translates to:
  /// **'Form builder'**
  String get hostFormBuilderTitle;

  /// Form-level tab for editing the form.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get hostFormBuildTab;

  /// Form-level responses tab with submission count.
  ///
  /// In en, this message translates to:
  /// **'Responses {count}'**
  String hostFormResponsesTab({required int count});

  /// Primary heading for the compact form builder outline.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get hostFormQuestionsTitle;

  /// Question-selection guidance for application forms.
  ///
  /// In en, this message translates to:
  /// **'Choose the questions that will help you decide who to call.'**
  String get hostFormQuestionsPromptHelp;

  /// Compact form settings step guidance.
  ///
  /// In en, this message translates to:
  /// **'Set access, availability, confirmation, and privacy.'**
  String get hostFormSettingsPromptHelp;

  /// Compact publish review step heading.
  ///
  /// In en, this message translates to:
  /// **'Ready to publish?'**
  String get hostFormPublishPrompt;

  /// Accessible label for a question drag handle.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder question'**
  String get hostFormReorderQuestion;

  /// Disclosure label for less common question settings.
  ///
  /// In en, this message translates to:
  /// **'Advanced settings'**
  String get hostFormAdvancedQuestionSettings;

  /// Summary of advanced question settings.
  ///
  /// In en, this message translates to:
  /// **'Privacy, prefill, response display, and validation'**
  String get hostFormAdvancedQuestionSettingsHelp;

  /// Moves a form question to another section.
  ///
  /// In en, this message translates to:
  /// **'Move to section'**
  String get hostFormMoveToSection;

  /// Accessible label for section edit and reorder actions.
  ///
  /// In en, this message translates to:
  /// **'Section actions'**
  String get hostFormSectionActions;

  /// Opens the focused form-section editor.
  ///
  /// In en, this message translates to:
  /// **'Edit section'**
  String get hostFormEditSection;

  /// Question answer type and requiredness summary.
  ///
  /// In en, this message translates to:
  /// **'{type} · {requirement}'**
  String hostFormQuestionSummary({
    required String type,
    required String requirement,
  });

  /// Compact required-question status.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get hostFormRequiredShort;

  /// Compact optional-question status.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get hostFormOptionalShort;

  /// Readiness summary when a form has no open or close date.
  ///
  /// In en, this message translates to:
  /// **'Accepting responses until you close it'**
  String get hostFormAvailabilityAlwaysOpen;

  /// Readiness summary for a form open date.
  ///
  /// In en, this message translates to:
  /// **'Opens {date}'**
  String hostFormAvailabilityOpens({required String date});

  /// Readiness summary for a form close date.
  ///
  /// In en, this message translates to:
  /// **'Closes {date}'**
  String hostFormAvailabilityCloses({required String date});

  /// Opens the publication readiness review for a draft form.
  ///
  /// In en, this message translates to:
  /// **'Review & publish'**
  String get hostFormReviewPublish;

  /// Opens publication readiness review for changes to a live form.
  ///
  /// In en, this message translates to:
  /// **'Review & publish changes'**
  String get hostFormReviewPublishChanges;

  /// Draft form publication review sheet title.
  ///
  /// In en, this message translates to:
  /// **'Review before publishing'**
  String get hostFormReviewPublishTitle;

  /// Published form version review sheet title.
  ///
  /// In en, this message translates to:
  /// **'Review your changes'**
  String get hostFormReviewChangesTitle;

  /// Guidance shown before publishing a form version.
  ///
  /// In en, this message translates to:
  /// **'Check the respondent experience and the essentials that control who can respond.'**
  String get hostFormReviewPublishSubtitle;

  /// Guidance for the progressive question-type picker.
  ///
  /// In en, this message translates to:
  /// **'Start with the answer shape you need. You can adjust the details next.'**
  String get hostFormChooseQuestionTypeHelp;

  /// Recommended question types group label.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get hostFormRecommendedQuestionTypes;

  /// Additional question types group label.
  ///
  /// In en, this message translates to:
  /// **'More answer types'**
  String get hostFormMoreQuestionTypes;

  /// Opens or titles a form preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get hostFormPreview;

  /// Explains preview fidelity.
  ///
  /// In en, this message translates to:
  /// **'This uses the same renderer respondents will see.'**
  String get hostFormPreviewSubtitle;

  /// Disabled submit label in a non-submitting preview.
  ///
  /// In en, this message translates to:
  /// **'Preview only'**
  String get hostFormPreviewSubmitDisabled;

  /// Public form response submission action.
  ///
  /// In en, this message translates to:
  /// **'Submit response'**
  String get hostFormSubmit;

  /// Clarifies preview data is discarded.
  ///
  /// In en, this message translates to:
  /// **'Preview mode · nothing entered here is saved'**
  String get hostFormPreviewNoResponses;

  /// Preview-only file input placeholder.
  ///
  /// In en, this message translates to:
  /// **'File upload appears here'**
  String get hostFormPreviewUploadPlaceholder;

  /// Preview-only signature input placeholder.
  ///
  /// In en, this message translates to:
  /// **'Signature appears here'**
  String get hostFormPreviewSignaturePlaceholder;

  /// Publishes a draft form.
  ///
  /// In en, this message translates to:
  /// **'Publish form'**
  String get hostFormPublish;

  /// Publishes a new immutable version of a live form.
  ///
  /// In en, this message translates to:
  /// **'Publish changes'**
  String get hostFormPublishChanges;

  /// Successful form publication message.
  ///
  /// In en, this message translates to:
  /// **'Form published'**
  String get hostFormPublished;

  /// Opens or titles form distribution tools.
  ///
  /// In en, this message translates to:
  /// **'Share form'**
  String get hostFormShare;

  /// Form distribution route guidance.
  ///
  /// In en, this message translates to:
  /// **'Publish one link everywhere, or create tracked links for each channel.'**
  String get hostFormShareSubtitle;

  /// Canonical form link section label.
  ///
  /// In en, this message translates to:
  /// **'Public link'**
  String get hostFormCanonicalLink;

  /// Explains app-free form access.
  ///
  /// In en, this message translates to:
  /// **'Respondents open this in any browser. They do not need the Catch app.'**
  String get hostFormCanonicalLinkHelp;

  /// Copies a public form link.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get hostFormCopyLink;

  /// Confirms a form link was copied.
  ///
  /// In en, this message translates to:
  /// **'Form link copied'**
  String get hostFormLinkCopied;

  /// Opens the platform share sheet for a form link.
  ///
  /// In en, this message translates to:
  /// **'Share link'**
  String get hostFormShareLink;

  /// Tracked form distribution links section label.
  ///
  /// In en, this message translates to:
  /// **'Tracked links'**
  String get hostFormTrackedLinks;

  /// Explains tracked form distribution links.
  ///
  /// In en, this message translates to:
  /// **'Use a different link for Instagram, WhatsApp, email, or a partner so response attribution stays visible.'**
  String get hostFormTrackedLinksHelp;

  /// Creates a source-attributed form link.
  ///
  /// In en, this message translates to:
  /// **'Create tracked link'**
  String get hostFormCreateTrackedLink;

  /// Tracked form link dialog title.
  ///
  /// In en, this message translates to:
  /// **'New tracked link'**
  String get hostFormTrackedLinkTitle;

  /// Tracked link human-readable label field.
  ///
  /// In en, this message translates to:
  /// **'Internal label'**
  String get hostFormTrackedLinkLabel;

  /// Example tracked form link label.
  ///
  /// In en, this message translates to:
  /// **'August Instagram story'**
  String get hostFormTrackedLinkLabelHint;

  /// Optional machine-readable form link source field.
  ///
  /// In en, this message translates to:
  /// **'Source tag (optional)'**
  String get hostFormTrackedLinkSource;

  /// Example tracked form link source.
  ///
  /// In en, this message translates to:
  /// **'instagram_story'**
  String get hostFormTrackedLinkSourceHint;

  /// Confirms tracked form link creation.
  ///
  /// In en, this message translates to:
  /// **'Tracked link ready'**
  String get hostFormTrackedLinkReady;

  /// Website form embed section label.
  ///
  /// In en, this message translates to:
  /// **'Embed on your website'**
  String get hostFormEmbed;

  /// Explains the form iframe embed.
  ///
  /// In en, this message translates to:
  /// **'Paste this iframe into your website builder. The embedded route keeps the same validation and submission controls.'**
  String get hostFormEmbedHelp;

  /// Copies a form iframe snippet.
  ///
  /// In en, this message translates to:
  /// **'Copy embed code'**
  String get hostFormCopyEmbed;

  /// Confirms a form iframe snippet was copied.
  ///
  /// In en, this message translates to:
  /// **'Embed code copied'**
  String get hostFormEmbedCopied;

  /// Commits tracked form link creation.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get hostFormCreate;

  /// Form metadata editor section title.
  ///
  /// In en, this message translates to:
  /// **'Form settings'**
  String get hostFormSettings;

  /// Editable form title label.
  ///
  /// In en, this message translates to:
  /// **'Form title'**
  String get hostFormTitleLabel;

  /// Editable form description label.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get hostFormDescriptionLabel;

  /// Editable form purpose label.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get hostFormPurposeLabel;

  /// Respondent identity policy field label.
  ///
  /// In en, this message translates to:
  /// **'Who can respond'**
  String get hostFormIdentityLabel;

  /// Anonymous respondent identity policy.
  ///
  /// In en, this message translates to:
  /// **'Anyone · anonymous allowed'**
  String get hostFormIdentityAnonymous;

  /// Verified email respondent identity policy.
  ///
  /// In en, this message translates to:
  /// **'Verified email required'**
  String get hostFormIdentityEmail;

  /// Verified phone respondent identity policy.
  ///
  /// In en, this message translates to:
  /// **'Verified phone required'**
  String get hostFormIdentityPhone;

  /// Either verified endpoint respondent identity policy.
  ///
  /// In en, this message translates to:
  /// **'Verified email or phone'**
  String get hostFormIdentityEmailOrPhone;

  /// Catch account respondent identity policy.
  ///
  /// In en, this message translates to:
  /// **'Catch account required'**
  String get hostFormIdentityCatchAccount;

  /// Successful response completion title field.
  ///
  /// In en, this message translates to:
  /// **'Confirmation title'**
  String get hostFormCompletionTitleLabel;

  /// Adds a section to a form.
  ///
  /// In en, this message translates to:
  /// **'Add section'**
  String get hostFormAddSection;

  /// Numbered form section label.
  ///
  /// In en, this message translates to:
  /// **'Section {number}'**
  String hostFormSectionNumber({required int number});

  /// Editable section title label.
  ///
  /// In en, this message translates to:
  /// **'Section title'**
  String get hostFormSectionTitleLabel;

  /// Adds a question to a form section.
  ///
  /// In en, this message translates to:
  /// **'Add question'**
  String get hostFormAddQuestion;

  /// Moves a form section earlier.
  ///
  /// In en, this message translates to:
  /// **'Move section up'**
  String get hostFormMoveSectionUp;

  /// Moves a form section later.
  ///
  /// In en, this message translates to:
  /// **'Move section down'**
  String get hostFormMoveSectionDown;

  /// Removes a non-final form section.
  ///
  /// In en, this message translates to:
  /// **'Remove section'**
  String get hostFormRemoveSection;

  /// Editable question label.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get hostFormQuestionLabel;

  /// Editable question type label.
  ///
  /// In en, this message translates to:
  /// **'Answer type'**
  String get hostFormQuestionType;

  /// Question requiredness toggle label.
  ///
  /// In en, this message translates to:
  /// **'Response required'**
  String get hostFormQuestionRequired;

  /// Numbered answer option label.
  ///
  /// In en, this message translates to:
  /// **'Option {number}'**
  String hostFormOptionNumber({required int number});

  /// Adds a choice option.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get hostFormAddOption;

  /// Moves a question earlier.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get hostFormMoveUp;

  /// Moves a question later.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get hostFormMoveDown;

  /// Removes a question from a form.
  ///
  /// In en, this message translates to:
  /// **'Remove question'**
  String get hostFormRemoveQuestion;

  /// Question type picker title.
  ///
  /// In en, this message translates to:
  /// **'Choose an answer type'**
  String get hostFormChooseQuestionType;

  /// Desktop form builder outline pane title.
  ///
  /// In en, this message translates to:
  /// **'Outline'**
  String get hostFormOutline;

  /// Question count within a form section.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No questions} =1{1 question} other{{count} questions}}'**
  String hostFormQuestionCount({required int count});

  /// Form autosave complete state.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get hostFormSaved;

  /// Form autosave dirty state.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get hostFormUnsaved;

  /// Form autosave active state.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get hostFormSaving;

  /// Form revision conflict compact state.
  ///
  /// In en, this message translates to:
  /// **'Newer version available'**
  String get hostFormSaveConflict;

  /// Form autosave failure state.
  ///
  /// In en, this message translates to:
  /// **'Form could not be saved'**
  String get hostFormSaveFailed;

  /// Form revision conflict notice title.
  ///
  /// In en, this message translates to:
  /// **'This form changed elsewhere'**
  String get hostFormConflictTitle;

  /// Form revision conflict recovery guidance.
  ///
  /// In en, this message translates to:
  /// **'Reload the newest revision before making more changes.'**
  String get hostFormConflictBody;

  /// Reloads a form after revision conflict.
  ///
  /// In en, this message translates to:
  /// **'Reload form'**
  String get hostFormReload;

  /// Retries a failed form autosave.
  ///
  /// In en, this message translates to:
  /// **'Retry save'**
  String get hostFormRetrySave;

  /// Form publish validation issue summary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Fix 1 form issue} other{Fix {count} form issues}}'**
  String hostFormValidationTitle({required int count});

  /// Short text question type.
  ///
  /// In en, this message translates to:
  /// **'Short text'**
  String get hostFormTypeShortText;

  /// Long text question type.
  ///
  /// In en, this message translates to:
  /// **'Long text'**
  String get hostFormTypeLongText;

  /// Single choice question type.
  ///
  /// In en, this message translates to:
  /// **'Single choice'**
  String get hostFormTypeSingleChoice;

  /// Multiple choice question type.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice'**
  String get hostFormTypeMultiChoice;

  /// Date question type.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get hostFormTypeDate;

  /// Phone question type.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get hostFormTypePhone;

  /// Email question type.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get hostFormTypeEmail;

  /// URL question type.
  ///
  /// In en, this message translates to:
  /// **'Website link'**
  String get hostFormTypeUrl;

  /// Number question type.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get hostFormTypeNumber;

  /// Boolean question type.
  ///
  /// In en, this message translates to:
  /// **'Yes or no'**
  String get hostFormTypeBoolean;

  /// File upload question type.
  ///
  /// In en, this message translates to:
  /// **'File upload'**
  String get hostFormTypeFile;

  /// Acknowledgement question type.
  ///
  /// In en, this message translates to:
  /// **'Acknowledgement'**
  String get hostFormTypeAcknowledgement;

  /// Signature question type.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get hostFormTypeSignature;

  /// Optional guidance shown below a form question.
  ///
  /// In en, this message translates to:
  /// **'Help text'**
  String get hostFormQuestionHelpLabel;

  /// Form answer privacy classification field.
  ///
  /// In en, this message translates to:
  /// **'Data classification'**
  String get hostFormPrivacyLabel;

  /// Contact data classification.
  ///
  /// In en, this message translates to:
  /// **'Contact information'**
  String get hostFormPrivacyContact;

  /// Profile data classification.
  ///
  /// In en, this message translates to:
  /// **'Profile information'**
  String get hostFormPrivacyProfile;

  /// Sensitive data classification.
  ///
  /// In en, this message translates to:
  /// **'Sensitive information'**
  String get hostFormPrivacySensitive;

  /// Organizer custom data classification.
  ///
  /// In en, this message translates to:
  /// **'Organizer-specific answer'**
  String get hostFormPrivacyCustom;

  /// Form question prefill policy field.
  ///
  /// In en, this message translates to:
  /// **'Prefill behavior'**
  String get hostFormPrefillLabel;

  /// No automatic respondent answer prefill.
  ///
  /// In en, this message translates to:
  /// **'Never prefill'**
  String get hostFormPrefillNever;

  /// Prefill known data with explicit respondent review.
  ///
  /// In en, this message translates to:
  /// **'Prefill, then require review'**
  String get hostFormPrefillReview;

  /// Controls how answers are exposed in response management.
  ///
  /// In en, this message translates to:
  /// **'Host response view'**
  String get hostFormPresentationLabel;

  /// Answer appears only on response detail.
  ///
  /// In en, this message translates to:
  /// **'Response detail only'**
  String get hostFormPresentationDetail;

  /// Answer can filter response lists.
  ///
  /// In en, this message translates to:
  /// **'Filterable column'**
  String get hostFormPresentationFilter;

  /// Answer can sort response lists.
  ///
  /// In en, this message translates to:
  /// **'Sortable column'**
  String get hostFormPresentationSort;

  /// Minimum text answer length.
  ///
  /// In en, this message translates to:
  /// **'Minimum characters'**
  String get hostFormMinimumLength;

  /// Maximum text answer length.
  ///
  /// In en, this message translates to:
  /// **'Maximum characters'**
  String get hostFormMaximumLength;

  /// Minimum numeric answer value.
  ///
  /// In en, this message translates to:
  /// **'Minimum value'**
  String get hostFormMinimumNumber;

  /// Maximum numeric answer value.
  ///
  /// In en, this message translates to:
  /// **'Maximum value'**
  String get hostFormMaximumNumber;

  /// Earliest accepted form date.
  ///
  /// In en, this message translates to:
  /// **'Earliest date (YYYY-MM-DD)'**
  String get hostFormEarliestDate;

  /// Latest accepted form date.
  ///
  /// In en, this message translates to:
  /// **'Latest date (YYYY-MM-DD)'**
  String get hostFormLatestDate;

  /// Minimum multiple-choice selections.
  ///
  /// In en, this message translates to:
  /// **'Minimum choices'**
  String get hostFormMinimumSelections;

  /// Maximum multiple-choice selections.
  ///
  /// In en, this message translates to:
  /// **'Maximum choices'**
  String get hostFormMaximumSelections;

  /// Maximum files accepted by one upload question.
  ///
  /// In en, this message translates to:
  /// **'Maximum files'**
  String get hostFormMaximumFiles;

  /// Maximum uploaded file size in megabytes.
  ///
  /// In en, this message translates to:
  /// **'Maximum size per file (MB)'**
  String get hostFormMaximumFileMegabytes;

  /// Accepted upload MIME types.
  ///
  /// In en, this message translates to:
  /// **'Allowed types (comma separated)'**
  String get hostFormAllowedFileTypes;

  /// Preset text validation pattern field.
  ///
  /// In en, this message translates to:
  /// **'Text format'**
  String get hostFormPatternLabel;

  /// No preset text pattern.
  ///
  /// In en, this message translates to:
  /// **'Any text'**
  String get hostFormPatternNone;

  /// Letters and spaces text pattern.
  ///
  /// In en, this message translates to:
  /// **'Letters and spaces'**
  String get hostFormPatternLetters;

  /// Alphanumeric text pattern.
  ///
  /// In en, this message translates to:
  /// **'Letters and numbers'**
  String get hostFormPatternAlphanumeric;

  /// Postal code text pattern.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get hostFormPatternPostal;

  /// Social handle text pattern.
  ///
  /// In en, this message translates to:
  /// **'Social handle'**
  String get hostFormPatternHandle;

  /// Optional respondent-facing answer error copy.
  ///
  /// In en, this message translates to:
  /// **'Custom validation message'**
  String get hostFormCustomError;

  /// Form appearance settings group.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get hostFormAppearance;

  /// Public form appearance preset.
  ///
  /// In en, this message translates to:
  /// **'Layout style'**
  String get hostFormAppearancePreset;

  /// Editorial form appearance.
  ///
  /// In en, this message translates to:
  /// **'Editorial'**
  String get hostFormAppearanceEditorial;

  /// Minimal form appearance.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get hostFormAppearanceMinimal;

  /// Activity-specific form appearance.
  ///
  /// In en, this message translates to:
  /// **'Activity-led'**
  String get hostFormAppearanceActivity;

  /// Optional event or activity label for an activity-led form.
  ///
  /// In en, this message translates to:
  /// **'Activity label'**
  String get hostFormActivityKind;

  /// Form response availability settings group.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get hostFormAvailability;

  /// Optional form opening date.
  ///
  /// In en, this message translates to:
  /// **'Opens on'**
  String get hostFormOpensAt;

  /// Optional form closing date.
  ///
  /// In en, this message translates to:
  /// **'Closes on'**
  String get hostFormClosesAt;

  /// Empty optional form availability date.
  ///
  /// In en, this message translates to:
  /// **'No date set'**
  String get hostFormDateNotSet;

  /// Clears an optional form availability date.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get hostFormClearDate;

  /// Optional form response capacity.
  ///
  /// In en, this message translates to:
  /// **'Response limit'**
  String get hostFormResponseLimit;

  /// Message shown when a form is unavailable.
  ///
  /// In en, this message translates to:
  /// **'Closed-form message'**
  String get hostFormClosedMessage;

  /// Form consent settings group.
  ///
  /// In en, this message translates to:
  /// **'Consent and retention'**
  String get hostFormConsent;

  /// Respondent consent statement.
  ///
  /// In en, this message translates to:
  /// **'Consent statement'**
  String get hostFormConsentCopy;

  /// Stable consent policy version identifier.
  ///
  /// In en, this message translates to:
  /// **'Consent version'**
  String get hostFormConsentVersion;

  /// Respondent data retention statement.
  ///
  /// In en, this message translates to:
  /// **'Retention statement'**
  String get hostFormRetentionCopy;

  /// Form completion settings group.
  ///
  /// In en, this message translates to:
  /// **'After submission'**
  String get hostFormCompletion;

  /// Successful response completion message.
  ///
  /// In en, this message translates to:
  /// **'Confirmation message'**
  String get hostFormCompletionMessageLabel;

  /// Action shown after response submission.
  ///
  /// In en, this message translates to:
  /// **'Next action'**
  String get hostFormCompletionActionLabel;

  /// No post-submission action.
  ///
  /// In en, this message translates to:
  /// **'No action'**
  String get hostFormCompletionActionNone;

  /// Post-submission external URL action.
  ///
  /// In en, this message translates to:
  /// **'Open a link'**
  String get hostFormCompletionActionExternal;

  /// Post-submission linked event action.
  ///
  /// In en, this message translates to:
  /// **'Open linked event'**
  String get hostFormCompletionActionEvent;

  /// Post-submission event runtime action.
  ///
  /// In en, this message translates to:
  /// **'Open event runtime'**
  String get hostFormCompletionActionRuntime;

  /// Post-submission action button label.
  ///
  /// In en, this message translates to:
  /// **'Button label'**
  String get hostFormCompletionButtonLabel;

  /// Post-submission external URL.
  ///
  /// In en, this message translates to:
  /// **'Destination URL'**
  String get hostFormCompletionUrl;

  /// Form branching rules group.
  ///
  /// In en, this message translates to:
  /// **'Conditional logic'**
  String get hostFormLogic;

  /// Explains form branching constraints.
  ///
  /// In en, this message translates to:
  /// **'Show, hide, skip, or finish based on an earlier answer. Routes must move forward.'**
  String get hostFormLogicHelp;

  /// Adds a conditional form rule.
  ///
  /// In en, this message translates to:
  /// **'Add rule'**
  String get hostFormAddRule;

  /// Removes a conditional form rule.
  ///
  /// In en, this message translates to:
  /// **'Remove rule'**
  String get hostFormRemoveRule;

  /// Conditional rule source question field.
  ///
  /// In en, this message translates to:
  /// **'When this answer'**
  String get hostFormRuleQuestion;

  /// Conditional rule comparison operator field.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get hostFormRuleOperator;

  /// Conditional rule comparison value field.
  ///
  /// In en, this message translates to:
  /// **'Comparison value'**
  String get hostFormRuleValue;

  /// True boolean answer label in form logic.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get hostFormRuleTrue;

  /// False boolean answer label in form logic.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get hostFormRuleFalse;

  /// Conditional rule action field.
  ///
  /// In en, this message translates to:
  /// **'Then'**
  String get hostFormRuleAction;

  /// Conditional rule question target field.
  ///
  /// In en, this message translates to:
  /// **'Target question'**
  String get hostFormRuleTargetQuestion;

  /// Conditional rule section target field.
  ///
  /// In en, this message translates to:
  /// **'Target section'**
  String get hostFormRuleTargetSection;

  /// Commits a conditional form rule.
  ///
  /// In en, this message translates to:
  /// **'Save rule'**
  String get hostFormRuleSave;

  /// Equals form rule operator.
  ///
  /// In en, this message translates to:
  /// **'equals'**
  String get hostFormOperatorEquals;

  /// Not-equals form rule operator.
  ///
  /// In en, this message translates to:
  /// **'does not equal'**
  String get hostFormOperatorNotEquals;

  /// Contains form rule operator.
  ///
  /// In en, this message translates to:
  /// **'contains'**
  String get hostFormOperatorContains;

  /// Not-contains form rule operator.
  ///
  /// In en, this message translates to:
  /// **'does not contain'**
  String get hostFormOperatorNotContains;

  /// Greater-than form rule operator.
  ///
  /// In en, this message translates to:
  /// **'is greater than'**
  String get hostFormOperatorGreater;

  /// Less-than form rule operator.
  ///
  /// In en, this message translates to:
  /// **'is less than'**
  String get hostFormOperatorLess;

  /// Answered form rule operator.
  ///
  /// In en, this message translates to:
  /// **'is answered'**
  String get hostFormOperatorAnswered;

  /// Not-answered form rule operator.
  ///
  /// In en, this message translates to:
  /// **'is not answered'**
  String get hostFormOperatorNotAnswered;

  /// Show-question form rule action.
  ///
  /// In en, this message translates to:
  /// **'Show a question'**
  String get hostFormActionShowQuestion;

  /// Hide-question form rule action.
  ///
  /// In en, this message translates to:
  /// **'Hide a question'**
  String get hostFormActionHideQuestion;

  /// Show-section form rule action.
  ///
  /// In en, this message translates to:
  /// **'Show a section'**
  String get hostFormActionShowSection;

  /// Hide-section form rule action.
  ///
  /// In en, this message translates to:
  /// **'Hide a section'**
  String get hostFormActionHideSection;

  /// Forward section route form rule action.
  ///
  /// In en, this message translates to:
  /// **'Skip to a section'**
  String get hostFormActionRouteSection;

  /// Early finish form rule action.
  ///
  /// In en, this message translates to:
  /// **'Finish the form'**
  String get hostFormActionFinish;

  /// Forms library view tab.
  ///
  /// In en, this message translates to:
  /// **'Forms'**
  String get hostFormsViewForms;

  /// Form responses inbox view tab.
  ///
  /// In en, this message translates to:
  /// **'Responses'**
  String get hostFormsViewResponses;

  /// Explains the response inbox.
  ///
  /// In en, this message translates to:
  /// **'Review every submission, preserve its source, and choose what happens next.'**
  String get hostFormResponsesSubtitle;

  /// Searches the response inbox by permitted identity fields.
  ///
  /// In en, this message translates to:
  /// **'Search responses'**
  String get hostFormResponsesSearch;

  /// Shows submitted and withdrawn form responses.
  ///
  /// In en, this message translates to:
  /// **'All responses'**
  String get hostFormResponsesAll;

  /// Submitted response status label.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get hostFormResponsesSubmitted;

  /// Withdrawn response status label.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get hostFormResponsesWithdrawn;

  /// Fallback identity label for anonymous form responses.
  ///
  /// In en, this message translates to:
  /// **'Anonymous respondent'**
  String get hostFormResponsesAnonymous;

  /// Empty form response inbox title.
  ///
  /// In en, this message translates to:
  /// **'No responses yet'**
  String get hostFormResponsesEmptyTitle;

  /// Empty form response inbox guidance.
  ///
  /// In en, this message translates to:
  /// **'Share a published form. New submissions will appear here without loading the full response history.'**
  String get hostFormResponsesEmptyBody;

  /// Filtered response inbox empty title.
  ///
  /// In en, this message translates to:
  /// **'No responses match'**
  String get hostFormResponsesNoMatchesTitle;

  /// Filtered response inbox empty guidance.
  ///
  /// In en, this message translates to:
  /// **'Try another search or status filter.'**
  String get hostFormResponsesNoMatchesBody;

  /// Loads the next bounded response page.
  ///
  /// In en, this message translates to:
  /// **'Load more responses'**
  String get hostFormResponsesLoadMore;

  /// Response inbox row form and source summary.
  ///
  /// In en, this message translates to:
  /// **'{formTitle} · {source}'**
  String hostFormResponseRowSummary({
    required String formTitle,
    required String source,
  });

  /// Fallback source label for a direct form visit.
  ///
  /// In en, this message translates to:
  /// **'Direct link'**
  String get hostFormResponseDirectSource;

  /// Opens responses filtered to one form.
  ///
  /// In en, this message translates to:
  /// **'View responses'**
  String get hostFormsViewResponsesAction;

  /// Opens aggregate form analytics.
  ///
  /// In en, this message translates to:
  /// **'View analytics'**
  String get hostFormsAnalyticsAction;

  /// Opens form automation rules and runs.
  ///
  /// In en, this message translates to:
  /// **'Manage automations'**
  String get hostFormsAutomationsAction;

  /// Form response detail title.
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get hostFormResponseTitle;

  /// Response identity section title.
  ///
  /// In en, this message translates to:
  /// **'Respondent'**
  String get hostFormResponseIdentitySection;

  /// Response answers section title.
  ///
  /// In en, this message translates to:
  /// **'Answers'**
  String get hostFormResponseAnswersSection;

  /// Response conversion actions section title.
  ///
  /// In en, this message translates to:
  /// **'Next actions'**
  String get hostFormResponseOperationsSection;

  /// Response identity email field.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get hostFormResponseEmail;

  /// Response identity phone field.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get hostFormResponsePhone;

  /// Response attribution source field.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get hostFormResponseSource;

  /// Response submission time field.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get hostFormResponseSubmittedAt;

  /// Response consent version field.
  ///
  /// In en, this message translates to:
  /// **'Consent version'**
  String get hostFormResponseConsent;

  /// Response completion duration field.
  ///
  /// In en, this message translates to:
  /// **'Completion time'**
  String get hostFormResponseCompletionTime;

  /// Fallback for a missing response field.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get hostFormResponseNotProvided;

  /// Fallback for an unanswered form question.
  ///
  /// In en, this message translates to:
  /// **'No answer'**
  String get hostFormResponseNoAnswer;

  /// Opens a time-limited response attachment.
  ///
  /// In en, this message translates to:
  /// **'Open {fileName}'**
  String hostFormResponseDownloadFile({required String fileName});

  /// Reviews a response to CRM conversion.
  ///
  /// In en, this message translates to:
  /// **'Create CRM contact'**
  String get hostFormConvertCrm;

  /// Reviews a response to application conversion.
  ///
  /// In en, this message translates to:
  /// **'Add to applications'**
  String get hostFormConvertApplication;

  /// Reviews a response to event attendee proposal conversion.
  ///
  /// In en, this message translates to:
  /// **'Propose attendee'**
  String get hostFormConvertAttendee;

  /// Conversion preview confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Review this action'**
  String get hostFormConversionReviewTitle;

  /// Conversion preview confirmation guidance.
  ///
  /// In en, this message translates to:
  /// **'Catch will create only the fields shown in this preview. Existing records and conflicts remain protected.'**
  String get hostFormConversionReviewBody;

  /// Confirms a reviewed response conversion.
  ///
  /// In en, this message translates to:
  /// **'Confirm action'**
  String get hostFormConversionConfirm;

  /// Unavailable response conversion explanation.
  ///
  /// In en, this message translates to:
  /// **'This action needs verified identity or additional setup.'**
  String get hostFormConversionUnavailable;

  /// Successful response conversion feedback.
  ///
  /// In en, this message translates to:
  /// **'Action completed'**
  String get hostFormConversionComplete;

  /// Form analytics screen title.
  ///
  /// In en, this message translates to:
  /// **'Form analytics'**
  String get hostFormAnalyticsTitle;

  /// Form analytics funnel section title.
  ///
  /// In en, this message translates to:
  /// **'Response funnel'**
  String get hostFormAnalyticsFunnel;

  /// Public form open count.
  ///
  /// In en, this message translates to:
  /// **'Opens'**
  String get hostFormAnalyticsOpens;

  /// Public form start count.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get hostFormAnalyticsStarts;

  /// Form submission count.
  ///
  /// In en, this message translates to:
  /// **'Submissions'**
  String get hostFormAnalyticsSubmissions;

  /// Form start-to-submit conversion rate.
  ///
  /// In en, this message translates to:
  /// **'Completion rate'**
  String get hostFormAnalyticsCompletionRate;

  /// Median form completion time.
  ///
  /// In en, this message translates to:
  /// **'Median completion'**
  String get hostFormAnalyticsMedianTime;

  /// Source link funnel section title.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get hostFormAnalyticsSources;

  /// Question aggregate analytics section title.
  ///
  /// In en, this message translates to:
  /// **'Question results'**
  String get hostFormAnalyticsQuestions;

  /// Explains form analytics privacy thresholds.
  ///
  /// In en, this message translates to:
  /// **'Question results appear only when the privacy threshold is met. Sensitive and free-text answers are never charted.'**
  String get hostFormAnalyticsPrivacyNotice;

  /// Starts a CSV form response export.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get hostFormExportCsv;

  /// Starts an XLSX form response export.
  ///
  /// In en, this message translates to:
  /// **'Export Excel'**
  String get hostFormExportXlsx;

  /// Completed form response export feedback.
  ///
  /// In en, this message translates to:
  /// **'Export ready'**
  String get hostFormExportReady;

  /// Form automations screen title.
  ///
  /// In en, this message translates to:
  /// **'Automations'**
  String get hostFormAutomationsTitle;

  /// Explains form automations.
  ///
  /// In en, this message translates to:
  /// **'Run explicit, observable actions after a response changes. You can disable any rule instantly.'**
  String get hostFormAutomationsSubtitle;

  /// Form automation rules section title.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get hostFormAutomationsRules;

  /// Form automation execution history section title.
  ///
  /// In en, this message translates to:
  /// **'Recent runs'**
  String get hostFormAutomationsRuns;

  /// Empty automation rules title.
  ///
  /// In en, this message translates to:
  /// **'No automations yet'**
  String get hostFormAutomationsEmptyTitle;

  /// Empty automation rules guidance.
  ///
  /// In en, this message translates to:
  /// **'Start with a safe preset. Every run is recorded and can be disabled.'**
  String get hostFormAutomationsEmptyBody;

  /// Creates a team notification response automation.
  ///
  /// In en, this message translates to:
  /// **'Notify my team'**
  String get hostFormAutomationNotifyPreset;

  /// Creates an identity-gated CRM response automation.
  ///
  /// In en, this message translates to:
  /// **'Create CRM contacts'**
  String get hostFormAutomationCrmPreset;

  /// Response-submitted automation trigger label.
  ///
  /// In en, this message translates to:
  /// **'When a response is submitted'**
  String get hostFormAutomationSubmittedTrigger;

  /// Response-withdrawn automation trigger label.
  ///
  /// In en, this message translates to:
  /// **'When a response is withdrawn'**
  String get hostFormAutomationWithdrawnTrigger;

  /// Answer-matching automation trigger label.
  ///
  /// In en, this message translates to:
  /// **'When an answer matches'**
  String get hostFormAutomationAnswerTrigger;

  /// Automation rule action count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 action} other{{count} actions}}'**
  String hostFormAutomationActionCount({required int count});

  /// Automation run event and retry summary.
  ///
  /// In en, this message translates to:
  /// **'{trigger} · Attempt {attempt}'**
  String hostFormAutomationRunSummary({
    required String trigger,
    required int attempt,
  });

  /// Loads the next bounded automation-run page.
  ///
  /// In en, this message translates to:
  /// **'Load more runs'**
  String get hostFormAutomationsLoadMore;

  /// Anonymous response data provenance label.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get hostFormResponseOriginAnonymous;

  /// Respondent-granted data provenance label.
  ///
  /// In en, this message translates to:
  /// **'Shared by respondent'**
  String get hostFormResponseOriginGranted;

  /// Organizer-acquired data provenance label.
  ///
  /// In en, this message translates to:
  /// **'Organizer record'**
  String get hostFormResponseOriginAcquired;

  /// Revoked response data provenance label.
  ///
  /// In en, this message translates to:
  /// **'Access revoked'**
  String get hostFormResponseOriginRevoked;

  /// Event attendee proposal picker title.
  ///
  /// In en, this message translates to:
  /// **'Choose an event'**
  String get hostFormSelectEventTitle;

  /// Empty attendee proposal event picker guidance.
  ///
  /// In en, this message translates to:
  /// **'No upcoming events are available for an attendee proposal.'**
  String get hostFormSelectEventEmpty;

  /// Conversion preview existing-record notice.
  ///
  /// In en, this message translates to:
  /// **'An existing record already matches this response.'**
  String get hostFormConversionExisting;

  /// Explains a form-scoped response inbox.
  ///
  /// In en, this message translates to:
  /// **'Showing responses for {formTitle}'**
  String hostFormResponseFilteredTo({required String formTitle});

  /// Clears the response inbox form filter.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get hostFormResponseClearFormFilter;

  /// One source-link form funnel summary.
  ///
  /// In en, this message translates to:
  /// **'{opens} opens · {starts} starts · {submissions} submissions'**
  String hostFormAnalyticsSourceSummary({
    required int opens,
    required int starts,
    required int submissions,
  });

  /// Question aggregate response count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 answer} other{{count} answers}}'**
  String hostFormAnalyticsQuestionSummary({required int count});

  /// Choice aggregate response count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 response} other{{count} responses}}'**
  String hostFormAnalyticsChoiceCount({required int count});

  /// Failed or expired form export feedback.
  ///
  /// In en, this message translates to:
  /// **'The export could not be prepared. Try again.'**
  String get hostFormExportFailed;

  /// Long-running form export feedback.
  ///
  /// In en, this message translates to:
  /// **'The export is still preparing. You can retry without creating a duplicate.'**
  String get hostFormExportStillPreparing;

  /// Pending automation run status.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get hostFormAutomationPending;

  /// Running automation run status.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get hostFormAutomationRunning;

  /// Successful automation run status.
  ///
  /// In en, this message translates to:
  /// **'Succeeded'**
  String get hostFormAutomationSucceeded;

  /// Partially failed automation run status.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get hostFormAutomationPartiallyFailed;

  /// Failed automation run status.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get hostFormAutomationFailed;

  /// Skipped automation run status.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get hostFormAutomationSkipped;

  /// Undoes the most recent local form-builder edit.
  ///
  /// In en, this message translates to:
  /// **'Undo last edit'**
  String get hostFormUndo;

  /// Reapplies the most recently undone form-builder edit.
  ///
  /// In en, this message translates to:
  /// **'Redo edit'**
  String get hostFormRedo;

  /// Moves to the preceding section in a resumable Host creation wizard.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get hostsWizardPrevious;

  /// Section status when required creation information is ready.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get hostsWizardStatusComplete;

  /// Section status when required creation information is missing or invalid.
  ///
  /// In en, this message translates to:
  /// **'Needs information'**
  String get hostsWizardStatusNeedsInformation;

  /// Section status for an optional creation section.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get hostsWizardStatusOptional;

  /// Explains out-of-order navigation in resumable Host creation wizards.
  ///
  /// In en, this message translates to:
  /// **'Open any section and finish the required details in any order.'**
  String get hostsWizardOverviewSubtitle;

  /// Section overview title in event creation.
  ///
  /// In en, this message translates to:
  /// **'Event setup'**
  String get hostsCreateEventOverviewTitle;

  /// Create event review activity label.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get hostsCreateEventReviewActivity;

  /// Create event review booking authority label.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get hostsCreateEventReviewBooking;

  /// Create event review Catch booking authority value.
  ///
  /// In en, this message translates to:
  /// **'Catch bookings'**
  String get hostsCreateEventReviewCatchBookings;

  /// Create event review external booking authority value.
  ///
  /// In en, this message translates to:
  /// **'External provider: {provider}'**
  String hostsCreateEventReviewExternalBookings({required String provider});

  /// Create event review location label.
  ///
  /// In en, this message translates to:
  /// **'Meeting location'**
  String get hostsCreateEventReviewLocation;

  /// Create event review schedule label.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get hostsCreateEventReviewSchedule;

  /// Create event review capacity label.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get hostsCreateEventReviewCapacity;

  /// Create event review capacity value.
  ///
  /// In en, this message translates to:
  /// **'{count} attendees'**
  String hostsCreateEventReviewCapacityValue({required int count});

  /// Create event review price label.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get hostsCreateEventReviewPrice;

  /// Create event review external price value.
  ///
  /// In en, this message translates to:
  /// **'Managed by the external provider'**
  String get hostsCreateEventReviewExternalPrice;

  /// Create event review free price value.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get hostsCreateEventReviewFree;

  /// Create event review admission label.
  ///
  /// In en, this message translates to:
  /// **'Admission'**
  String get hostsCreateEventReviewAdmission;

  /// Section overview title in organizer creation.
  ///
  /// In en, this message translates to:
  /// **'Organizer setup'**
  String get hostsCreateClubOverviewTitle;

  /// Guidance on the final review screen for resumable Host creation flows.
  ///
  /// In en, this message translates to:
  /// **'Review every section before publishing. Select a row to make changes.'**
  String get hostsWizardReviewBody;

  /// Final review title and action in event creation.
  ///
  /// In en, this message translates to:
  /// **'Review event'**
  String get hostsCreateEventReviewTitle;

  /// Final review title and action in organizer creation.
  ///
  /// In en, this message translates to:
  /// **'Review organizer'**
  String get hostsCreateClubReviewTitle;

  /// Publishes an event after the final creation review passes.
  ///
  /// In en, this message translates to:
  /// **'Schedule event'**
  String get hostsCreateEventScheduleAction;

  /// Creates an organizer after the final creation review passes.
  ///
  /// In en, this message translates to:
  /// **'Create organizer'**
  String get hostsCreateClubCreateAction;

  /// Title for leaving a dirty resumable Host creation wizard.
  ///
  /// In en, this message translates to:
  /// **'Save your work?'**
  String get hostsDraftExitTitle;

  /// Explains the save-on-exit choice for a dirty Host creation wizard.
  ///
  /// In en, this message translates to:
  /// **'Save this as a draft before you exit?'**
  String get hostsDraftExitMessage;

  /// Dismisses the draft exit dialog and returns to the wizard.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get hostsDraftExitKeepEditing;

  /// Leaves a dirty Host creation wizard without saving its latest changes.
  ///
  /// In en, this message translates to:
  /// **'Discard & exit'**
  String get hostsDraftExitDiscardAndExit;

  /// Saves a Host creation draft and exits only after the save succeeds.
  ///
  /// In en, this message translates to:
  /// **'Save draft & exit'**
  String get hostsDraftExitSaveAndExit;

  /// Accessible label for the interactive wizard step counter.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}. Open section overview.'**
  String hostsWizardStepOverviewSemantics({
    required int step,
    required int total,
  });

  /// Starts a safe rehearsal from the Host event entry sheet.
  ///
  /// In en, this message translates to:
  /// **'Run a dress rehearsal'**
  String get hostEventRehearsalEntryTitle;

  /// Explains rehearsal isolation in the Host entry sheet.
  ///
  /// In en, this message translates to:
  /// **'Practice the Host and guest experience with synthetic people. Nothing touches a real event.'**
  String get hostEventRehearsalEntryBody;

  /// Event rehearsal route title.
  ///
  /// In en, this message translates to:
  /// **'Dress rehearsal'**
  String get hostEventRehearsalTitle;

  /// Persistent rehearsal safety banner.
  ///
  /// In en, this message translates to:
  /// **'Practice mode · No real guests, messages, payments, matches, or event records are changed'**
  String get hostEventRehearsalPracticeBanner;

  /// Canonical Host Manage route subtitle while rehearsing.
  ///
  /// In en, this message translates to:
  /// **'Host · Manage'**
  String get hostEventRehearsalManageSubtitle;

  /// Persistent rehearsal mode badge.
  ///
  /// In en, this message translates to:
  /// **'Rehearsal'**
  String get hostEventRehearsalBadge;

  /// Rehearsal data identity shown beside the mode badge.
  ///
  /// In en, this message translates to:
  /// **'Synthetic guests'**
  String get hostEventRehearsalSyntheticGuests;

  /// Synthetic guest subtitle in the canonical Host runtime.
  ///
  /// In en, this message translates to:
  /// **'Practice guest'**
  String get hostEventRehearsalPracticeGuest;

  /// Synthetic late-arrival subtitle in the canonical Host runtime.
  ///
  /// In en, this message translates to:
  /// **'Late arrival · Practice guest'**
  String get hostEventRehearsalLatePracticeGuest;

  /// Compact virtual-clock control in the rehearsal band.
  ///
  /// In en, this message translates to:
  /// **'Virtual {time}'**
  String hostEventRehearsalClockPill({required String time});

  /// Opens advanced rehearsal controls without replacing the real runtime.
  ///
  /// In en, this message translates to:
  /// **'Practice tools'**
  String get hostEventRehearsalPracticeTools;

  /// Explains the advanced rehearsal tool sheet.
  ///
  /// In en, this message translates to:
  /// **'Control synthetic guests, the companion phone, faults, time, and deterministic replays.'**
  String get hostEventRehearsalPracticeToolsBody;

  /// Explains virtual run controls.
  ///
  /// In en, this message translates to:
  /// **'Change only the simulated clock and rehearsal lifecycle.'**
  String get hostEventRehearsalRunSheetBody;

  /// Coach task progress in the rehearsal dock.
  ///
  /// In en, this message translates to:
  /// **'Task {current} of {total}'**
  String hostEventRehearsalCoachProgress({
    required int current,
    required int total,
  });

  /// Explains why the current practice task matters.
  ///
  /// In en, this message translates to:
  /// **'Why?'**
  String get hostEventRehearsalCoachWhy;

  /// Collapses the rehearsal Coach without completing the task.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get hostEventRehearsalCoachGotIt;

  /// Collapsed rehearsal Coach message.
  ///
  /// In en, this message translates to:
  /// **'Coach is ready when you need the next practice task.'**
  String get hostEventRehearsalCoachCollapsed;

  /// Expands the rehearsal Coach.
  ///
  /// In en, this message translates to:
  /// **'Show Coach'**
  String get hostEventRehearsalCoachShow;

  /// Coach task for a synthetic late arrival.
  ///
  /// In en, this message translates to:
  /// **'Resolve {name}\'\'s late arrival'**
  String hostEventRehearsalCoachResolveLate({required String name});

  /// Coach task for placing a synthetic guest in the live room map.
  ///
  /// In en, this message translates to:
  /// **'Place {name} in the current round'**
  String hostEventRehearsalCoachPlaceGuest({required String name});

  /// Explains that the rehearsal placement task uses the canonical live Room control.
  ///
  /// In en, this message translates to:
  /// **'Use the same Room control you will use on event day.'**
  String get hostEventRehearsalCoachPlaceGuestBody;

  /// Coach task for a synthetic help request.
  ///
  /// In en, this message translates to:
  /// **'Resolve {name}\'\'s help request'**
  String hostEventRehearsalCoachResolveHelp({required String name});

  /// Reinforces that Coach points to production runtime controls.
  ///
  /// In en, this message translates to:
  /// **'Use the same control you will use on event day.'**
  String get hostEventRehearsalCoachSameControl;

  /// Coach task before a rehearsal begins.
  ///
  /// In en, this message translates to:
  /// **'Start the virtual event'**
  String get hostEventRehearsalCoachStart;

  /// Guidance for beginning a rehearsal.
  ///
  /// In en, this message translates to:
  /// **'Open the virtual clock to start, then operate the real Host runtime.'**
  String get hostEventRehearsalCoachStartBody;

  /// Coach task for a paused rehearsal.
  ///
  /// In en, this message translates to:
  /// **'Resume the virtual event'**
  String get hostEventRehearsalCoachResume;

  /// Default Coach task during a running rehearsal.
  ///
  /// In en, this message translates to:
  /// **'Run the current Host step'**
  String get hostEventRehearsalCoachAdvance;

  /// Coach task after a rehearsal completes.
  ///
  /// In en, this message translates to:
  /// **'Review your rehearsal'**
  String get hostEventRehearsalCoachComplete;

  /// Coach guidance after rehearsal completion.
  ///
  /// In en, this message translates to:
  /// **'Open Practice tools to replay, fork, or export the deterministic run.'**
  String get hostEventRehearsalCoachCompleteBody;

  /// Title for the rehearsal Coach explanation.
  ///
  /// In en, this message translates to:
  /// **'Why this task?'**
  String get hostEventRehearsalCoachWhyTitle;

  /// Explains Coach truth and completion semantics.
  ///
  /// In en, this message translates to:
  /// **'The Coach highlights a real Host control, but synthetic state proves the outcome. Dismissing guidance never completes a task.'**
  String get hostEventRehearsalCoachWhyBody;

  /// Confirms leaving an active rehearsal.
  ///
  /// In en, this message translates to:
  /// **'Leave rehearsal?'**
  String get hostEventRehearsalLeaveTitle;

  /// Explains rehearsal persistence when leaving.
  ///
  /// In en, this message translates to:
  /// **'Your practice session stays available until it expires.'**
  String get hostEventRehearsalLeaveBody;

  /// Leaves an active rehearsal after confirmation.
  ///
  /// In en, this message translates to:
  /// **'Leave rehearsal'**
  String get hostEventRehearsalLeaveAction;

  /// Rehearsal creation guidance.
  ///
  /// In en, this message translates to:
  /// **'Choose a room to practice. You can change the rehearsal copy and playbook before starting.'**
  String get hostEventRehearsalStartSubtitle;

  /// Existing-event rehearsal source label.
  ///
  /// In en, this message translates to:
  /// **'Practice this event'**
  String get hostEventRehearsalSourceEvent;

  /// Sample-template rehearsal source label.
  ///
  /// In en, this message translates to:
  /// **'Catch sample event'**
  String get hostEventRehearsalSourceSample;

  /// Rehearsal scenario field label.
  ///
  /// In en, this message translates to:
  /// **'Practice scenario'**
  String get hostEventRehearsalScenario;

  /// Synthetic rehearsal guest count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 synthetic guest} other{{count} synthetic guests}}'**
  String hostEventRehearsalActorCount({required int count});

  /// Explains actor-count bounds.
  ///
  /// In en, this message translates to:
  /// **'Use a realistic roster. Rehearsals are capped at 50 synthetic guests.'**
  String get hostEventRehearsalActorCountBody;

  /// Creates an isolated rehearsal.
  ///
  /// In en, this message translates to:
  /// **'Create rehearsal'**
  String get hostEventRehearsalCreate;

  /// Rehearsal retention notice.
  ///
  /// In en, this message translates to:
  /// **'This rehearsal and its guest link expire after 24 hours.'**
  String get hostEventRehearsalExpiry;

  /// Happy-path rehearsal scenario title.
  ///
  /// In en, this message translates to:
  /// **'Smooth run'**
  String get hostEventRehearsalScenarioSmoothRun;

  /// Happy-path rehearsal scenario summary.
  ///
  /// In en, this message translates to:
  /// **'A cooperative room for learning the normal Host and guest flow.'**
  String get hostEventRehearsalScenarioSmoothRunBody;

  /// Late arrival scenario title.
  ///
  /// In en, this message translates to:
  /// **'Late arrivals and no-shows'**
  String get hostEventRehearsalScenarioLateAndNoShow;

  /// Late arrival scenario summary.
  ///
  /// In en, this message translates to:
  /// **'Recover when expected guests are missing or arrive after groups begin.'**
  String get hostEventRehearsalScenarioLateAndNoShowBody;

  /// Early exit scenario title.
  ///
  /// In en, this message translates to:
  /// **'Early exit and return'**
  String get hostEventRehearsalScenarioEarlyExitAndReturn;

  /// Early exit scenario summary.
  ///
  /// In en, this message translates to:
  /// **'Rebalance when a guest leaves early and another returns later.'**
  String get hostEventRehearsalScenarioEarlyExitAndReturnBody;

  /// Roster capacity scenario title.
  ///
  /// In en, this message translates to:
  /// **'Odd roster and capacity'**
  String get hostEventRehearsalScenarioRosterAndCapacity;

  /// Roster capacity scenario summary.
  ///
  /// In en, this message translates to:
  /// **'Expose odd-sized groups, tight capacity, and unassigned guests.'**
  String get hostEventRehearsalScenarioRosterAndCapacityBody;

  /// Walk-in scenario title.
  ///
  /// In en, this message translates to:
  /// **'Walk-in and ambiguous claim'**
  String get hostEventRehearsalScenarioWalkInAndAmbiguousClaim;

  /// Walk-in scenario summary.
  ///
  /// In en, this message translates to:
  /// **'Admit a walk-in and resolve two similar roster identities.'**
  String get hostEventRehearsalScenarioWalkInAndAmbiguousClaimBody;

  /// Privacy scenario title.
  ///
  /// In en, this message translates to:
  /// **'Privacy and keep-apart'**
  String get hostEventRehearsalScenarioPrivacyAndKeepApart;

  /// Privacy scenario summary.
  ///
  /// In en, this message translates to:
  /// **'Respect an opt-out and a safety keep-apart constraint while preserving flow.'**
  String get hostEventRehearsalScenarioPrivacyAndKeepApartBody;

  /// Connectivity scenario title.
  ///
  /// In en, this message translates to:
  /// **'Low connectivity'**
  String get hostEventRehearsalScenarioLowConnectivity;

  /// Connectivity scenario summary.
  ///
  /// In en, this message translates to:
  /// **'Continue through disconnects, delayed updates, and reconnection.'**
  String get hostEventRehearsalScenarioLowConnectivityBody;

  /// Concurrent Host scenario title.
  ///
  /// In en, this message translates to:
  /// **'Two hosts, one revision'**
  String get hostEventRehearsalScenarioConcurrentHosts;

  /// Concurrent Host scenario summary.
  ///
  /// In en, this message translates to:
  /// **'See how stale Host actions are rejected and recovered safely.'**
  String get hostEventRehearsalScenarioConcurrentHostsBody;

  /// Reveal interruption scenario title.
  ///
  /// In en, this message translates to:
  /// **'Reveal interrupted'**
  String get hostEventRehearsalScenarioRevealInterrupted;

  /// Reveal interruption scenario summary.
  ///
  /// In en, this message translates to:
  /// **'Pause and recover around a reveal or round transition.'**
  String get hostEventRehearsalScenarioRevealInterruptedBody;

  /// External profile scenario title.
  ///
  /// In en, this message translates to:
  /// **'External and incomplete profiles'**
  String get hostEventRehearsalScenarioExternalProfiles;

  /// External profile scenario summary.
  ///
  /// In en, this message translates to:
  /// **'Exercise no-download guests and deliberately sparse participant data.'**
  String get hostEventRehearsalScenarioExternalProfilesBody;

  /// Accountability scenario title.
  ///
  /// In en, this message translates to:
  /// **'Accountability sweep'**
  String get hostEventRehearsalScenarioAccountabilitySweep;

  /// Accountability scenario summary.
  ///
  /// In en, this message translates to:
  /// **'Finish with unresolved checked-in, departed, and disconnected guests.'**
  String get hostEventRehearsalScenarioAccountabilitySweepBody;

  /// Guest rehearsal link section title.
  ///
  /// In en, this message translates to:
  /// **'Live guest phone'**
  String get hostEventRehearsalGuestLinkTitle;

  /// Guest rehearsal link guidance.
  ///
  /// In en, this message translates to:
  /// **'Open this link on another phone. It gets an anonymous synthetic guest and follows the virtual event live.'**
  String get hostEventRehearsalGuestLinkBody;

  /// Copies a rehearsal guest link.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get hostEventRehearsalCopyLink;

  /// Shares a rehearsal guest link.
  ///
  /// In en, this message translates to:
  /// **'Share link'**
  String get hostEventRehearsalShareLink;

  /// Rotates a rehearsal guest link.
  ///
  /// In en, this message translates to:
  /// **'Replace link'**
  String get hostEventRehearsalRotateLink;

  /// Rehearsal setup section title.
  ///
  /// In en, this message translates to:
  /// **'Practice setup'**
  String get hostEventRehearsalSetupTitle;

  /// Rehearsal setup freeze guidance.
  ///
  /// In en, this message translates to:
  /// **'Setup is frozen after Start. Reset or fork to change it.'**
  String get hostEventRehearsalSetupFrozen;

  /// Rehearsal title input.
  ///
  /// In en, this message translates to:
  /// **'Practice event name'**
  String get hostEventRehearsalFieldTitle;

  /// Rehearsal location input.
  ///
  /// In en, this message translates to:
  /// **'Practice location'**
  String get hostEventRehearsalFieldLocation;

  /// Rehearsal Host goal input.
  ///
  /// In en, this message translates to:
  /// **'Host goal'**
  String get hostEventRehearsalFieldGoal;

  /// Rehearsal guest prompt input.
  ///
  /// In en, this message translates to:
  /// **'Guest prompt'**
  String get hostEventRehearsalFieldPrompt;

  /// Rehearsal run-control section title.
  ///
  /// In en, this message translates to:
  /// **'Virtual event'**
  String get hostEventRehearsalRunTitle;

  /// Starts a rehearsal.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get hostEventRehearsalStart;

  /// Pauses a rehearsal.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get hostEventRehearsalPause;

  /// Resumes a rehearsal.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get hostEventRehearsalResume;

  /// Moves to the prior rehearsal moment.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get hostEventRehearsalPrevious;

  /// Moves to the next rehearsal moment.
  ///
  /// In en, this message translates to:
  /// **'Next moment'**
  String get hostEventRehearsalNext;

  /// Advances rehearsal clock five minutes.
  ///
  /// In en, this message translates to:
  /// **'+5 min'**
  String get hostEventRehearsalAdvanceFive;

  /// Advances rehearsal clock fifteen minutes.
  ///
  /// In en, this message translates to:
  /// **'+15 min'**
  String get hostEventRehearsalAdvanceFifteen;

  /// Completes a rehearsal.
  ///
  /// In en, this message translates to:
  /// **'Complete run'**
  String get hostEventRehearsalComplete;

  /// Synthetic behavior simulator title.
  ///
  /// In en, this message translates to:
  /// **'Issue simulator'**
  String get hostEventRehearsalSimulationTitle;

  /// Synthetic behavior simulator guidance.
  ///
  /// In en, this message translates to:
  /// **'Choose a synthetic guest, then inject a realistic behavior. Automatic scenario cues also fire when the virtual clock crosses them.'**
  String get hostEventRehearsalSimulationBody;

  /// Explains when synthetic behavior controls are available.
  ///
  /// In en, this message translates to:
  /// **'Start the virtual event to inject guest behavior. Completed runs can be reset or forked.'**
  String get hostEventRehearsalSimulationUnavailable;

  /// Synthetic guest picker label.
  ///
  /// In en, this message translates to:
  /// **'Synthetic guest'**
  String get hostEventRehearsalChooseGuest;

  /// Synthetic issue picker label.
  ///
  /// In en, this message translates to:
  /// **'Inject issue'**
  String get hostEventRehearsalChooseIssue;

  /// Synthetic rehearsal roster title.
  ///
  /// In en, this message translates to:
  /// **'Synthetic room'**
  String get hostEventRehearsalRosterTitle;

  /// Synthetic room status summary.
  ///
  /// In en, this message translates to:
  /// **'{present} present · {total} expected · {unresolved} unresolved'**
  String hostEventRehearsalRoomSummary({
    required int present,
    required int total,
    required int unresolved,
  });

  /// Internal rehearsal fault panel title.
  ///
  /// In en, this message translates to:
  /// **'Internal QA faults'**
  String get hostEventRehearsalQaFaultsTitle;

  /// Internal fault panel guidance.
  ///
  /// In en, this message translates to:
  /// **'Inject transport, revision, duplicate-delivery, legacy, motion, and bandwidth failures without touching production entities.'**
  String get hostEventRehearsalQaFaultsBody;

  /// Completed rehearsal recap title.
  ///
  /// In en, this message translates to:
  /// **'Practice recap'**
  String get hostEventRehearsalRecapTitle;

  /// Rehearsal reproducibility summary.
  ///
  /// In en, this message translates to:
  /// **'{actions} actions recorded · seed {seed} · revision {revision}'**
  String hostEventRehearsalRecapBody({
    required int actions,
    required int seed,
    required int revision,
  });

  /// Resets a rehearsal with the same seed.
  ///
  /// In en, this message translates to:
  /// **'Reset run'**
  String get hostEventRehearsalReset;

  /// Forks a rehearsal into a fresh session.
  ///
  /// In en, this message translates to:
  /// **'Fork setup'**
  String get hostEventRehearsalFork;

  /// Copies a deterministic rehearsal reproduction.
  ///
  /// In en, this message translates to:
  /// **'Copy reproduction'**
  String get hostEventRehearsalExport;

  /// Rehearsal action history title.
  ///
  /// In en, this message translates to:
  /// **'Recent simulated actions'**
  String get hostEventRehearsalRecentActions;

  /// Synthetic arrival action.
  ///
  /// In en, this message translates to:
  /// **'Arrives now'**
  String get hostEventRehearsalBehaviorArrive;

  /// Synthetic late arrival action.
  ///
  /// In en, this message translates to:
  /// **'Arrives late'**
  String get hostEventRehearsalBehaviorArriveLate;

  /// Synthetic no-show action.
  ///
  /// In en, this message translates to:
  /// **'Becomes a no-show'**
  String get hostEventRehearsalBehaviorNoShow;

  /// Synthetic departure action.
  ///
  /// In en, this message translates to:
  /// **'Leaves early'**
  String get hostEventRehearsalBehaviorLeaves;

  /// Synthetic return action.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get hostEventRehearsalBehaviorReturns;

  /// Synthetic walk-in action.
  ///
  /// In en, this message translates to:
  /// **'Walks in'**
  String get hostEventRehearsalBehaviorWalkIn;

  /// Synthetic ambiguous claim action.
  ///
  /// In en, this message translates to:
  /// **'Claims an ambiguous name'**
  String get hostEventRehearsalBehaviorAmbiguous;

  /// Resolves a synthetic claim.
  ///
  /// In en, this message translates to:
  /// **'Resolve claim'**
  String get hostEventRehearsalBehaviorResolve;

  /// Synthetic privacy opt-out action.
  ///
  /// In en, this message translates to:
  /// **'Opts out'**
  String get hostEventRehearsalBehaviorOptOut;

  /// Synthetic privacy opt-in action.
  ///
  /// In en, this message translates to:
  /// **'Opts back in'**
  String get hostEventRehearsalBehaviorOptIn;

  /// Synthetic safety keep-apart action.
  ///
  /// In en, this message translates to:
  /// **'Adds keep-apart'**
  String get hostEventRehearsalBehaviorKeepApart;

  /// Synthetic disconnect action.
  ///
  /// In en, this message translates to:
  /// **'Loses connection'**
  String get hostEventRehearsalBehaviorDisconnect;

  /// Synthetic reconnect action.
  ///
  /// In en, this message translates to:
  /// **'Reconnects'**
  String get hostEventRehearsalBehaviorReconnect;

  /// Clears rehearsal fault injection.
  ///
  /// In en, this message translates to:
  /// **'No injected fault'**
  String get hostEventRehearsalFaultNone;

  /// Latency fault label.
  ///
  /// In en, this message translates to:
  /// **'Artificial latency'**
  String get hostEventRehearsalFaultLatency;

  /// One-shot failure fault label.
  ///
  /// In en, this message translates to:
  /// **'One-shot failure'**
  String get hostEventRehearsalFaultOneShot;

  /// Listener disconnect fault label.
  ///
  /// In en, this message translates to:
  /// **'Listener disconnect'**
  String get hostEventRehearsalFaultDisconnect;

  /// Stale revision fault label.
  ///
  /// In en, this message translates to:
  /// **'Stale revision'**
  String get hostEventRehearsalFaultStaleRevision;

  /// Duplicate delivery fault label.
  ///
  /// In en, this message translates to:
  /// **'Duplicate delivery'**
  String get hostEventRehearsalFaultDuplicate;

  /// Legacy fixture fault label.
  ///
  /// In en, this message translates to:
  /// **'Legacy fixture'**
  String get hostEventRehearsalFaultLegacy;

  /// Reduced motion fault label.
  ///
  /// In en, this message translates to:
  /// **'Reduced motion'**
  String get hostEventRehearsalFaultReducedMotion;

  /// Low bandwidth fault label.
  ///
  /// In en, this message translates to:
  /// **'Low bandwidth'**
  String get hostEventRehearsalFaultLowBandwidth;

  /// Synthetic expected guest status.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get hostEventRehearsalStatusExpected;

  /// Synthetic present guest status.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get hostEventRehearsalStatusPresent;

  /// Synthetic late guest status.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get hostEventRehearsalStatusLate;

  /// Synthetic no-show status.
  ///
  /// In en, this message translates to:
  /// **'No-show'**
  String get hostEventRehearsalStatusNoShow;

  /// Synthetic departed status.
  ///
  /// In en, this message translates to:
  /// **'Departed'**
  String get hostEventRehearsalStatusDeparted;

  /// Synthetic returned status.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get hostEventRehearsalStatusReturned;

  /// Synthetic disconnected status.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get hostEventRehearsalStatusDisconnected;

  /// Synthetic walk-in status.
  ///
  /// In en, this message translates to:
  /// **'Walk-in'**
  String get hostEventRehearsalStatusWalkIn;

  /// Synthetic ambiguous claim status.
  ///
  /// In en, this message translates to:
  /// **'Claim needs review'**
  String get hostEventRehearsalStatusAmbiguous;

  /// Synthetic guest help signal.
  ///
  /// In en, this message translates to:
  /// **'Help requested'**
  String get hostEventRehearsalSignalHelp;

  /// Synthetic guest prompt-completion signal.
  ///
  /// In en, this message translates to:
  /// **'Prompt complete'**
  String get hostEventRehearsalSignalPromptComplete;

  /// Rehearsal playbook module selector.
  ///
  /// In en, this message translates to:
  /// **'Event Success playbook'**
  String get hostEventRehearsalModules;

  /// Arrival playbook module.
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get hostEventRehearsalModuleArrival;

  /// First Hello playbook module.
  ///
  /// In en, this message translates to:
  /// **'First Hello'**
  String get hostEventRehearsalModuleFirstHello;

  /// Pods playbook module.
  ///
  /// In en, this message translates to:
  /// **'Pods'**
  String get hostEventRehearsalModulePods;

  /// Rotations playbook module.
  ///
  /// In en, this message translates to:
  /// **'Rotations'**
  String get hostEventRehearsalModuleRotations;

  /// Conversation cue playbook module.
  ///
  /// In en, this message translates to:
  /// **'Conversation cues'**
  String get hostEventRehearsalModuleCues;

  /// Reveal playbook module.
  ///
  /// In en, this message translates to:
  /// **'Reveal'**
  String get hostEventRehearsalModuleReveal;

  /// Afterglow playbook module.
  ///
  /// In en, this message translates to:
  /// **'Afterglow'**
  String get hostEventRehearsalModuleAfterglow;

  /// Accountability playbook module.
  ///
  /// In en, this message translates to:
  /// **'Accountability'**
  String get hostEventRehearsalModuleAccountability;

  /// Rehearsal duration input.
  ///
  /// In en, this message translates to:
  /// **'Practice duration'**
  String get hostEventRehearsalDuration;

  /// Current rehearsal run position.
  ///
  /// In en, this message translates to:
  /// **'Moment {current} of {total}'**
  String hostEventRehearsalMoment({required int current, required int total});

  /// Rehearsal virtual clock label.
  ///
  /// In en, this message translates to:
  /// **'Virtual time · {time}'**
  String hostEventRehearsalClock({required String time});

  /// Applies a synthetic issue.
  ///
  /// In en, this message translates to:
  /// **'Apply issue'**
  String get hostEventRehearsalApplyIssue;

  /// QA fault picker label.
  ///
  /// In en, this message translates to:
  /// **'Injected fault'**
  String get hostEventRehearsalChooseFault;

  /// Guest link copy confirmation.
  ///
  /// In en, this message translates to:
  /// **'Practice guest link copied'**
  String get hostEventRehearsalLinkCopied;

  /// Guest link rotation warning.
  ///
  /// In en, this message translates to:
  /// **'The current link and every connected practice phone will stop working.'**
  String get hostEventRehearsalRotateLinkBody;

  /// Rehearsal reset warning.
  ///
  /// In en, this message translates to:
  /// **'This clears the simulated room and action history, then rebuilds the same deterministic roster.'**
  String get hostEventRehearsalResetBody;

  /// Reproduction copy confirmation.
  ///
  /// In en, this message translates to:
  /// **'Deterministic reproduction copied'**
  String get hostEventRehearsalReproductionCopied;

  /// Rehearsal ready action history label.
  ///
  /// In en, this message translates to:
  /// **'Marks room ready'**
  String get hostEventRehearsalActionMarkReady;

  /// Rehearsal moment advance action history label.
  ///
  /// In en, this message translates to:
  /// **'Advances moment'**
  String get hostEventRehearsalActionAdvance;

  /// Rehearsal previous action history label.
  ///
  /// In en, this message translates to:
  /// **'Returns to previous moment'**
  String get hostEventRehearsalActionPrevious;

  /// Rehearsal clock advance action history label.
  ///
  /// In en, this message translates to:
  /// **'Advances virtual time'**
  String get hostEventRehearsalActionAdvanceClock;

  /// Synthetic guest check-in history label.
  ///
  /// In en, this message translates to:
  /// **'Checks in'**
  String get hostEventRehearsalActionCheckIn;

  /// Synthetic guest arrival-confirmation history label.
  ///
  /// In en, this message translates to:
  /// **'Confirms arrival'**
  String get hostEventRehearsalActionConfirmArrival;

  /// Synthetic guest help action history label.
  ///
  /// In en, this message translates to:
  /// **'Requests Host help'**
  String get hostEventRehearsalActionAskForHelp;

  /// Synthetic guest prompt action history label.
  ///
  /// In en, this message translates to:
  /// **'Completes prompt'**
  String get hostEventRehearsalActionCompletePrompt;

  /// Safe fallback for a newer rehearsal action history label.
  ///
  /// In en, this message translates to:
  /// **'Simulated action'**
  String get hostEventRehearsalActionUnknown;

  /// Host rehearsal action kind.
  ///
  /// In en, this message translates to:
  /// **'Host control'**
  String get hostEventRehearsalActionKindControl;

  /// Behavior rehearsal action kind.
  ///
  /// In en, this message translates to:
  /// **'Simulated issue'**
  String get hostEventRehearsalActionKindBehavior;

  /// Guest rehearsal action kind.
  ///
  /// In en, this message translates to:
  /// **'Guest phone'**
  String get hostEventRehearsalActionKindGuest;

  /// Setup rehearsal action kind.
  ///
  /// In en, this message translates to:
  /// **'Practice setup'**
  String get hostEventRehearsalActionKindSetup;

  /// System rehearsal action kind.
  ///
  /// In en, this message translates to:
  /// **'Practice system'**
  String get hostEventRehearsalActionKindSystem;

  /// Rehearsal action kind and revision metadata.
  ///
  /// In en, this message translates to:
  /// **'{kind} · revision {revision}'**
  String hostEventRehearsalActionRevision({
    required String kind,
    required int revision,
  });

  /// Route path builder title.
  ///
  /// In en, this message translates to:
  /// **'Build route'**
  String get hostsRoutePathBuilderTitle;

  /// Indexed route point map label.
  ///
  /// In en, this message translates to:
  /// **'Route point {index}'**
  String hostsRoutePathBuilderPoint({required int index});

  /// Empty route builder guidance.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to add the first route point.'**
  String get hostsRoutePathBuilderEmpty;

  /// Route builder point count guidance.
  ///
  /// In en, this message translates to:
  /// **'{count} route points · tap the map to keep drawing'**
  String hostsRoutePathBuilderCount({required int count});

  /// Undo the latest route point.
  ///
  /// In en, this message translates to:
  /// **'Undo point'**
  String get hostsRoutePathBuilderUndo;

  /// Clear all route points.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get hostsRoutePathBuilderClear;

  /// Save route path action.
  ///
  /// In en, this message translates to:
  /// **'Use this route'**
  String get hostsRoutePathBuilderSave;

  /// Route path field title.
  ///
  /// In en, this message translates to:
  /// **'Route path'**
  String get hostsRouteEventPlanPathTitle;

  /// Empty route path guidance.
  ///
  /// In en, this message translates to:
  /// **'Draw the attendee-facing path on the map.'**
  String get hostsRouteEventPlanPathEmpty;

  /// Mapped route point count.
  ///
  /// In en, this message translates to:
  /// **'{count} mapped points'**
  String hostsRouteEventPlanPathCount({required int count});

  /// Open route builder action.
  ///
  /// In en, this message translates to:
  /// **'Edit map'**
  String get hostsRouteEventPlanPathAction;

  /// Pace group field title.
  ///
  /// In en, this message translates to:
  /// **'Pace groups'**
  String get hostsRouteEventPlanPaceGroupsTitle;

  /// Pace group field guidance.
  ///
  /// In en, this message translates to:
  /// **'Select every group the Host will lead and account for.'**
  String get hostsRouteEventPlanPaceGroupsBody;

  /// Social pace group preset.
  ///
  /// In en, this message translates to:
  /// **'Social · 7:30/km'**
  String get hostsRouteEventPlanPaceSocial;

  /// Steady pace group preset.
  ///
  /// In en, this message translates to:
  /// **'Steady · 6:00/km'**
  String get hostsRouteEventPlanPaceSteady;

  /// Fast pace group preset.
  ///
  /// In en, this message translates to:
  /// **'Fast · 5:00/km'**
  String get hostsRouteEventPlanPaceFast;

  /// Live route tracking field title.
  ///
  /// In en, this message translates to:
  /// **'Live Host position'**
  String get hostsRouteEventPlanTrackingTitle;

  /// Live route tracking privacy guidance.
  ///
  /// In en, this message translates to:
  /// **'Foreground-only sharing during the event helps late arrivals find the moving group.'**
  String get hostsRouteEventPlanTrackingBody;

  /// Disabled route tracking choice.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get hostsRouteEventPlanTrackingDisabled;

  /// Host-only route tracking choice.
  ///
  /// In en, this message translates to:
  /// **'Host only'**
  String get hostsRouteEventPlanTrackingHostOnly;

  /// Authorized operator route tracking choice.
  ///
  /// In en, this message translates to:
  /// **'Host and authorized operators'**
  String get hostsRouteEventPlanTrackingOperators;

  /// Event itinerary editor section title.
  ///
  /// In en, this message translates to:
  /// **'Run of show'**
  String get hostsEventItineraryTitle;

  /// Itinerary relative start time.
  ///
  /// In en, this message translates to:
  /// **'Starts {minutes} minutes after the event begins'**
  String hostsEventItineraryOffset({required int minutes});

  /// Edit itinerary entry action.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get hostsEventItineraryEdit;

  /// Add itinerary entry title.
  ///
  /// In en, this message translates to:
  /// **'Add itinerary step'**
  String get hostsEventItineraryAdd;

  /// Add itinerary entry guidance.
  ///
  /// In en, this message translates to:
  /// **'Publish real timing, stops, transitions, and locations for attendees.'**
  String get hostsEventItineraryAddBody;

  /// Add itinerary entry action.
  ///
  /// In en, this message translates to:
  /// **'Add step'**
  String get hostsEventItineraryAddAction;

  /// New itinerary entry dialog title.
  ///
  /// In en, this message translates to:
  /// **'Add run-of-show step'**
  String get hostsEventItineraryDialogAdd;

  /// Existing itinerary entry dialog title.
  ///
  /// In en, this message translates to:
  /// **'Edit run-of-show step'**
  String get hostsEventItineraryDialogEdit;

  /// Delete itinerary entry action.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get hostsEventItineraryDelete;

  /// Save itinerary entry action.
  ///
  /// In en, this message translates to:
  /// **'Save step'**
  String get hostsEventItinerarySave;

  /// Itinerary entry title field.
  ///
  /// In en, this message translates to:
  /// **'Step title'**
  String get hostsEventItineraryFieldTitle;

  /// Itinerary entry title hint.
  ///
  /// In en, this message translates to:
  /// **'Gather, activity, stop, or finish'**
  String get hostsEventItineraryFieldTitleHint;

  /// Itinerary offset field.
  ///
  /// In en, this message translates to:
  /// **'Minutes after start'**
  String get hostsEventItineraryFieldOffset;

  /// Itinerary duration field.
  ///
  /// In en, this message translates to:
  /// **'Duration in minutes'**
  String get hostsEventItineraryFieldDuration;

  /// Itinerary guidance field.
  ///
  /// In en, this message translates to:
  /// **'Attendee guidance'**
  String get hostsEventItineraryFieldDescription;

  /// Itinerary entry kind field.
  ///
  /// In en, this message translates to:
  /// **'Step type'**
  String get hostsEventItineraryFieldKind;

  /// Copies meeting location into itinerary entry.
  ///
  /// In en, this message translates to:
  /// **'Use the event meeting point'**
  String get hostsEventItineraryUseMeetingPoint;

  /// Optional exact location field for an itinerary entry.
  ///
  /// In en, this message translates to:
  /// **'Stop location'**
  String get hostsEventItineraryLocationTitle;

  /// Empty optional itinerary location value.
  ///
  /// In en, this message translates to:
  /// **'No exact location'**
  String get hostsEventItineraryLocationEmpty;

  /// Choose an itinerary location action.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get hostsEventItineraryLocationChoose;

  /// Change an itinerary location action.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get hostsEventItineraryLocationChange;

  /// Remove an itinerary location action.
  ///
  /// In en, this message translates to:
  /// **'Remove stop location'**
  String get hostsEventItineraryLocationRemove;

  /// Gather itinerary kind.
  ///
  /// In en, this message translates to:
  /// **'Gather'**
  String get hostsEventItineraryKindGather;

  /// Activity itinerary kind.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get hostsEventItineraryKindActivity;

  /// Stop itinerary kind.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get hostsEventItineraryKindStop;

  /// Break itinerary kind.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get hostsEventItineraryKindBreak;

  /// Transition itinerary kind.
  ///
  /// In en, this message translates to:
  /// **'Transition'**
  String get hostsEventItineraryKindTransition;

  /// Finish itinerary kind.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get hostsEventItineraryKindFinish;

  /// Host live position toggle title.
  ///
  /// In en, this message translates to:
  /// **'Share the moving group'**
  String get hostEventLiveLocationTitle;

  /// Host live position toggle guidance.
  ///
  /// In en, this message translates to:
  /// **'Use this phone\'\'s location so late arrivals can find the route lead.'**
  String get hostEventLiveLocationBody;

  /// Host live position privacy guidance.
  ///
  /// In en, this message translates to:
  /// **'Off by default. Sharing runs only while Catch is in the foreground.'**
  String get hostEventLiveLocationPrivacy;

  /// Host live position active status.
  ///
  /// In en, this message translates to:
  /// **'Live now. Leaving the app or switching this off removes your position.'**
  String get hostEventLiveLocationActive;

  /// Host live position permission error.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to share the moving group.'**
  String get hostEventLiveLocationPermissionDenied;

  /// Host live position services error.
  ///
  /// In en, this message translates to:
  /// **'Turn on device location services, then try again.'**
  String get hostEventLiveLocationServicesDisabled;

  /// Host live position generic error.
  ///
  /// In en, this message translates to:
  /// **'Live location could not be updated. Switch it off and try again.'**
  String get hostEventLiveLocationFailed;

  /// Rehearsal movement snapshot title.
  ///
  /// In en, this message translates to:
  /// **'Movement simulation'**
  String get hostEventRehearsalMovementTitle;

  /// Rehearsal movement snapshot summary.
  ///
  /// In en, this message translates to:
  /// **'{itineraryCount} itinerary steps · {routePointCount} route points · {positionCount} synthetic live positions'**
  String hostEventRehearsalMovementSummary({
    required int itineraryCount,
    required int routePointCount,
    required int positionCount,
  });

  /// Expanded customer workspace empty-detail title.
  ///
  /// In en, this message translates to:
  /// **'Select a customer'**
  String get hostCustomersSelectCustomerTitle;

  /// Expanded customer workspace empty-detail guidance.
  ///
  /// In en, this message translates to:
  /// **'Choose someone from the directory to keep their details beside the list.'**
  String get hostCustomersSelectCustomerBody;

  /// Expanded messaging workspace empty-detail title.
  ///
  /// In en, this message translates to:
  /// **'Select a conversation'**
  String get hostInboxSelectConversationTitle;

  /// Expanded messaging workspace empty-detail guidance.
  ///
  /// In en, this message translates to:
  /// **'Choose a thread to keep the conversation beside your inbox.'**
  String get hostInboxSelectConversationBody;

  /// Room setup loading-state title.
  ///
  /// In en, this message translates to:
  /// **'Loading room layouts'**
  String get eventSuccessRoomSetupLoadingTitle;

  /// Room setup loading-state body.
  ///
  /// In en, this message translates to:
  /// **'Your reusable layouts will appear here.'**
  String get eventSuccessRoomSetupLoadingBody;

  /// Current live moment workspace label.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get eventSuccessLiveWorkspaceNow;

  /// Guest drawer action in the live workspace picker.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get eventSuccessLiveWorkspaceGuests;

  /// Room map workspace label.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get eventSuccessLiveWorkspaceRoom;

  /// Room layout resource name used in retry copy.
  ///
  /// In en, this message translates to:
  /// **'room layout'**
  String get eventSuccessHostResourceRoomLayout;

  /// Whole-group room workspace title.
  ///
  /// In en, this message translates to:
  /// **'One shared room'**
  String get eventSuccessRoomWorkspaceWholeGroupTitle;

  /// Whole-group room workspace explanation.
  ///
  /// In en, this message translates to:
  /// **'This format runs as one group, so it does not need assigned tables or zones.'**
  String get eventSuccessRoomWorkspaceWholeGroupBody;

  /// Missing room layout runtime title.
  ///
  /// In en, this message translates to:
  /// **'Room layout not configured'**
  String get eventSuccessRoomWorkspaceUnconfiguredTitle;

  /// Missing room layout runtime guidance.
  ///
  /// In en, this message translates to:
  /// **'Choose or create a room layout in Preparation before the event starts. Live controls remain available in Now.'**
  String get eventSuccessRoomWorkspaceUnconfiguredBody;

  /// Room map loading title.
  ///
  /// In en, this message translates to:
  /// **'Opening the room map'**
  String get eventSuccessRoomWorkspaceLoadingTitle;

  /// Room map loading body.
  ///
  /// In en, this message translates to:
  /// **'Loading placements and room geometry.'**
  String get eventSuccessRoomWorkspaceLoadingBody;

  /// Empty room placement title.
  ///
  /// In en, this message translates to:
  /// **'Waiting for placements'**
  String get eventSuccessRoomWorkspaceWaitingTitle;

  /// Empty room placement guidance.
  ///
  /// In en, this message translates to:
  /// **'The saved room is ready. Placements appear here after the event guide generates groups or rotations.'**
  String get eventSuccessRoomWorkspaceWaitingBody;

  /// Configured room unit and seat summary.
  ///
  /// In en, this message translates to:
  /// **'{units} · {seats} seats'**
  String eventSuccessRoomWorkspaceCapacitySummary({
    required String units,
    required int seats,
  });

  /// Round or rectangular table count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 table} other{{count} tables}}'**
  String eventSuccessRoomWorkspaceTableCount({required int count});

  /// Row layout unit count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 row} other{{count} rows}}'**
  String eventSuccessRoomWorkspaceRowCount({required int count});

  /// Court layout unit count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 court} other{{count} courts}}'**
  String eventSuccessRoomWorkspaceCourtCount({required int count});

  /// Zone layout unit count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 zone} other{{count} zones}}'**
  String eventSuccessRoomWorkspaceZoneCount({required int count});

  /// Mixed room-layout unit count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 area} other{{count} areas}}'**
  String eventSuccessRoomWorkspaceAreaCount({required int count});

  /// Placed attendee count label.
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get eventSuccessRoomWorkspacePlaced;

  /// Unconfirmed placement count label.
  ///
  /// In en, this message translates to:
  /// **'Unconfirmed'**
  String get eventSuccessRoomWorkspaceUnconfirmed;

  /// Room placement attention count label.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get eventSuccessRoomWorkspaceNeedsAttention;
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
