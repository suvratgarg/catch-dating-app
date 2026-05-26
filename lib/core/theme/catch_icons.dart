import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Centralised icon facade for Catch.
///
/// Screens reference Catch-named icons (`CatchIcons.tonight`, not
/// `PhosphorIcons.moon()`) so a future icon-set swap is a one-file change.
///
/// We default to Phosphor Duotone for primary nav / time pills (it carries
/// the same friendly + modern aesthetic as the moon/sun/sofa scribbles in
/// the existing time pills) and Phosphor Regular for inline meta + actions
/// where the slimmer line works better at small sizes. Rounded icons that
/// don't have a Phosphor equivalent we want fall back to Material rounded.
abstract final class CatchIcons {
  // ── Time pills ───────────────────────────────────────────────────────────
  static IconData get tonight => PhosphorIconsDuotone.moonStars;
  static IconData get tomorrow => PhosphorIconsDuotone.sun;
  static IconData get weekend => PhosphorIconsDuotone.couch;
  static IconData get thisWeek => PhosphorIconsDuotone.calendarBlank;
  static IconData get anytime => PhosphorIconsDuotone.infinity;

  // ── Distance / location ──────────────────────────────────────────────────
  static IconData get nearMe => PhosphorIconsBold.navigationArrow;
  static IconData get nearMeOutlined => PhosphorIconsRegular.navigationArrow;
  static IconData get pin => PhosphorIconsBold.mapPin;
  static IconData get pinOutlined => PhosphorIconsRegular.mapPin;

  // ── Filters / chips ──────────────────────────────────────────────────────
  static IconData get joined => PhosphorIconsRegular.checkCircle;
  static IconData get joinedFilled => PhosphorIconsFill.checkCircle;
  static IconData get rated => PhosphorIconsFill.star;
  static IconData get hosted => PhosphorIconsRegular.shield;
  static IconData get clear => PhosphorIconsRegular.x;

  // ── Browse modes / navigation ────────────────────────────────────────────
  static IconData get map => PhosphorIconsBold.mapTrifold;
  static IconData get list => PhosphorIconsBold.list;
  static IconData get search => PhosphorIconsRegular.magnifyingGlass;
  static IconData get add => PhosphorIconsBold.plus;
  static IconData get forwardArrow => PhosphorIconsBold.arrowRight;
  static IconData get backArrow => PhosphorIconsBold.arrowLeft;
  static IconData get close => PhosphorIconsRegular.x;
  static IconData get menu => PhosphorIconsBold.list;
  static IconData get more => PhosphorIconsBold.dotsThree;

  // ── Detail screen actions ────────────────────────────────────────────────
  static IconData get share => PhosphorIconsRegular.shareNetwork;
  static IconData platformShare({TargetPlatform? platform}) {
    final effectivePlatform = platform ?? defaultTargetPlatform;
    return effectivePlatform == TargetPlatform.iOS ? iosShareRounded : share;
  }

  static IconData get calendarAdd => PhosphorIconsRegular.calendarPlus;
  static IconData get refresh => PhosphorIconsRegular.arrowsClockwise;
  static IconData get edit => PhosphorIconsRegular.pencilSimple;
  static IconData get info => PhosphorIconsRegular.info;
  static IconData get clock => PhosphorIconsRegular.clock;

  // ── Status badges / sashes ───────────────────────────────────────────────
  static IconData get joinedCheck => PhosphorIconsBold.check;
  static IconData get saved => PhosphorIconsFill.bookmarkSimple;
  static IconData get savedOutlined => PhosphorIconsRegular.bookmarkSimple;
  static IconData get hostBadge => PhosphorIconsFill.shield;
  static IconData get waitlisted => PhosphorIconsRegular.clock;

  // ── Empty / error / info ─────────────────────────────────────────────────
  static IconData get eventBusy => PhosphorIconsRegular.calendarX;
  static IconData get eventAvailable => PhosphorIconsRegular.calendarCheck;

  // ── Card meta — group counts, ratings ────────────────────────────────────
  static IconData get group => PhosphorIconsRegular.usersThree;
  static IconData get spots => PhosphorIconsRegular.armchair;

  // ── Material compatibility aliases ───────────────────────────────────────
  // Transitional facade entries for app-wide migration off direct `Icons.*`
  // references. Prefer semantic Catch-named getters above for new code.
  static IconData get accessTimeRounded => Icons.access_time_rounded;
  static IconData get accountBalanceWalletOutlined =>
      Icons.account_balance_wallet_outlined;
  static IconData get accountTreeOutlined => Icons.account_tree_outlined;
  static IconData get addCircleOutlineRounded =>
      Icons.add_circle_outline_rounded;
  static IconData get addPhotoAlternateOutlined =>
      Icons.add_photo_alternate_outlined;
  static IconData get addRounded => Icons.add_rounded;
  static IconData get adminPanelSettingsOutlined =>
      Icons.admin_panel_settings_outlined;
  static IconData get alternateEmailOutlined => Icons.alternate_email_outlined;
  static IconData get alternateEmailRounded => Icons.alternate_email_rounded;
  static IconData get arrowBackIosNewRounded =>
      Icons.arrow_back_ios_new_rounded;
  static IconData get arrowBackRounded => Icons.arrow_back_rounded;
  static IconData get arrowForwardRounded => Icons.arrow_forward_rounded;
  static IconData get assignmentReturnOutlined =>
      Icons.assignment_return_outlined;
  static IconData get assignmentTurnedInOutlined =>
      Icons.assignment_turned_in_outlined;
  static IconData get autoAwesomeOutlined => Icons.auto_awesome_outlined;
  static IconData get autoAwesomeRounded => Icons.auto_awesome_rounded;
  static IconData get autoGraphRounded => Icons.auto_graph_rounded;
  static IconData get balanceOutlined => Icons.balance_outlined;
  static IconData get blockOutlined => Icons.block_outlined;
  static IconData get blockRounded => Icons.block_rounded;
  static IconData get bolt => Icons.bolt;
  static IconData get boltRounded => Icons.bolt_rounded;
  static IconData get bookmarkBorderRounded => Icons.bookmark_border_rounded;
  static IconData get bookmarkRounded => Icons.bookmark_rounded;
  static IconData get brightness3Outlined => Icons.brightness_3_outlined;
  static IconData get brokenImageOutlined => Icons.broken_image_outlined;
  static IconData get businessOutlined => Icons.business_outlined;
  static IconData get cakeOutlined => Icons.cake_outlined;
  static IconData get calendarMonthOutlined => Icons.calendar_month_outlined;
  static IconData get calendarTodayOutlined => Icons.calendar_today_outlined;
  static IconData get callOutlined => Icons.call_outlined;
  static IconData get cancelOutlined => Icons.cancel_outlined;
  static IconData get cardMembershipOutlined => Icons.card_membership_outlined;
  static IconData get chatBubbleOutlineRounded =>
      Icons.chat_bubble_outline_rounded;
  static IconData get chatBubbleRounded => Icons.chat_bubble_rounded;
  static IconData get chatOutlined => Icons.chat_outlined;
  static IconData get checkCircleOutlineRounded =>
      Icons.check_circle_outline_rounded;
  static IconData get checkCircleRounded => Icons.check_circle_rounded;
  static IconData get checkRounded => Icons.check_rounded;
  static IconData get checklistRounded => Icons.checklist_rounded;
  static IconData get chevronRightRounded => Icons.chevron_right_rounded;
  static IconData get childCareOutlined => Icons.child_care_outlined;
  static IconData get childFriendlyOutlined => Icons.child_friendly_outlined;
  static IconData get cleaningServicesRounded =>
      Icons.cleaning_services_rounded;
  static IconData get closeRounded => Icons.close_rounded;
  static IconData get cloudOffOutlined => Icons.cloud_off_outlined;
  static IconData get cloudOffRounded => Icons.cloud_off_rounded;
  static IconData get cloudUploadOutlined => Icons.cloud_upload_outlined;
  static IconData get confirmationNumberOutlined =>
      Icons.confirmation_number_outlined;
  static IconData get constructionRounded => Icons.construction_rounded;
  static IconData get contentCopyRounded => Icons.content_copy_rounded;
  static IconData get creditCardOffRounded => Icons.credit_card_off_rounded;
  static IconData get dataObjectRounded => Icons.data_object_rounded;
  static IconData get deleteOutline => Icons.delete_outline;
  static IconData get deleteOutlineRounded => Icons.delete_outline_rounded;
  static IconData get descriptionOutlined => Icons.description_outlined;
  static IconData get directionsBikeRounded => Icons.directions_bike_rounded;
  static IconData get directionsOutlined => Icons.directions_outlined;
  static IconData get directionsRun => Icons.directions_run;
  static IconData get directionsRunOutlined => Icons.directions_run_outlined;
  static IconData get directionsRunRounded => Icons.directions_run_rounded;
  static IconData get directionsWalkRounded => Icons.directions_walk_rounded;
  static IconData get discountOutlined => Icons.discount_outlined;
  static IconData get diversity3Outlined => Icons.diversity_3_outlined;
  static IconData get downloadRounded => Icons.download_rounded;
  static IconData get ecoOutlined => Icons.eco_outlined;
  static IconData get editLocationAltOutlined =>
      Icons.edit_location_alt_outlined;
  static IconData get editNoteOutlined => Icons.edit_note_outlined;
  static IconData get editNoteRounded => Icons.edit_note_rounded;
  static IconData get editOutlined => Icons.edit_outlined;
  static IconData get emailOutlined => Icons.email_outlined;
  static IconData get errorOutlineRounded => Icons.error_outline_rounded;
  static IconData get eventAvailableOutlined => Icons.event_available_outlined;
  static IconData get eventAvailableRounded => Icons.event_available_rounded;
  static IconData get eventBusyOutlined => Icons.event_busy_outlined;
  static IconData get eventBusyRounded => Icons.event_busy_rounded;
  static IconData get eventOutlined => Icons.event_outlined;
  static IconData get eventRepeatOutlined => Icons.event_repeat_outlined;
  static IconData get eventSeatOutlined => Icons.event_seat_outlined;
  static IconData get expandLessRounded => Icons.expand_less_rounded;
  static IconData get expandMoreRounded => Icons.expand_more_rounded;
  static IconData get factCheckOutlined => Icons.fact_check_outlined;
  static IconData get favoriteBorderRounded => Icons.favorite_border_rounded;
  static IconData get favoriteOutline => Icons.favorite_outline;
  static IconData get favoriteOutlineRounded => Icons.favorite_outline_rounded;
  static IconData get favoriteRounded => Icons.favorite_rounded;
  static IconData get femaleOutlined => Icons.female_outlined;
  static IconData get fiberManualRecord => Icons.fiber_manual_record;
  static IconData get filter9PlusRounded => Icons.filter_9_plus_rounded;
  static IconData get fitnessCenterOutlined => Icons.fitness_center_outlined;
  static IconData get fitnessCenterRounded => Icons.fitness_center_rounded;
  static IconData get flagOutlined => Icons.flag_outlined;
  static IconData get flagRounded => Icons.flag_rounded;
  static IconData get formatQuoteRounded => Icons.format_quote_rounded;
  static IconData get forumOutlined => Icons.forum_outlined;
  static IconData get forumRounded => Icons.forum_rounded;
  static IconData get gridViewRounded => Icons.grid_view_rounded;
  static IconData get groupAddOutlined => Icons.group_add_outlined;
  static IconData get groupOffOutlined => Icons.group_off_outlined;
  static IconData get groupOffRounded => Icons.group_off_rounded;
  static IconData get groupOutlined => Icons.group_outlined;
  static IconData get groups2Outlined => Icons.groups_2_outlined;
  static IconData get groups3Outlined => Icons.groups_3_outlined;
  static IconData get groupsOutlined => Icons.groups_outlined;
  static IconData get groupsRounded => Icons.groups_rounded;
  static IconData get heightOutlined => Icons.height_outlined;
  static IconData get helpOutline => Icons.help_outline;
  static IconData get helpOutlineRounded => Icons.help_outline_rounded;
  static IconData get homeOutlined => Icons.home_outlined;
  static IconData get homeRounded => Icons.home_rounded;
  static IconData get hourglassDisabledRounded =>
      Icons.hourglass_disabled_rounded;
  static IconData get hourglassEmptyRounded => Icons.hourglass_empty_rounded;
  static IconData get hourglassTopRounded => Icons.hourglass_top_rounded;
  static IconData get howToRegOutlined => Icons.how_to_reg_outlined;
  static IconData get imageOutlined => Icons.image_outlined;
  static IconData get infoOutline => Icons.info_outline;
  static IconData get infoOutlineRounded => Icons.info_outline_rounded;
  static IconData get insightsOutlined => Icons.insights_outlined;
  static IconData get iosShareRounded => Icons.ios_share_rounded;
  static IconData get keyOutlined => Icons.key_outlined;
  static IconData get keyboardHideRounded => Icons.keyboard_hide_rounded;
  static IconData get keyboardOutlined => Icons.keyboard_outlined;
  static IconData get languageOutlined => Icons.language_outlined;
  static IconData get lightModeOutlined => Icons.light_mode_outlined;
  static IconData get lightbulbOutlineRounded =>
      Icons.lightbulb_outline_rounded;
  static IconData get linkOutlined => Icons.link_outlined;
  static IconData get linkRounded => Icons.link_rounded;
  static IconData get listRounded => Icons.list_rounded;
  static IconData get localBarOutlined => Icons.local_bar_outlined;
  static IconData get locationCityOutlined => Icons.location_city_outlined;
  static IconData get locationOnOutlined => Icons.location_on_outlined;
  static IconData get locationOnRounded => Icons.location_on_rounded;
  static IconData get lockClockRounded => Icons.lock_clock_rounded;
  static IconData get lockOpenOutlined => Icons.lock_open_outlined;
  static IconData get lockOpenRounded => Icons.lock_open_rounded;
  static IconData get lockOutline => Icons.lock_outline;
  static IconData get lockOutlineRounded => Icons.lock_outline_rounded;
  static IconData get lockRounded => Icons.lock_rounded;
  static IconData get logoutRounded => Icons.logout_rounded;
  static IconData get looks5Rounded => Icons.looks_5_rounded;
  static IconData get maleOutlined => Icons.male_outlined;
  static IconData get mapOutlined => Icons.map_outlined;
  static IconData get markEmailReadOutlined => Icons.mark_email_read_outlined;
  static IconData get moreHorizRounded => Icons.more_horiz_rounded;
  static IconData get nightlightRound => Icons.nightlight_round;
  static IconData get nightsStayOutlined => Icons.nights_stay_outlined;
  static IconData get notificationsActiveOutlined =>
      Icons.notifications_active_outlined;
  static IconData get notificationsActiveRounded =>
      Icons.notifications_active_rounded;
  static IconData get notificationsNoneRounded =>
      Icons.notifications_none_rounded;
  static IconData get notificationsOffOutlined =>
      Icons.notifications_off_outlined;
  static IconData get notificationsOffRounded =>
      Icons.notifications_off_rounded;
  static IconData get notificationsOutlined => Icons.notifications_outlined;
  static IconData get notificationsRounded => Icons.notifications_rounded;
  static IconData get openInNew => Icons.open_in_new;
  static IconData get openInNewRounded => Icons.open_in_new_rounded;
  static IconData get panToolAltOutlined => Icons.pan_tool_alt_outlined;
  static IconData get passwordRounded => Icons.password_rounded;
  static IconData get paymentsOutlined => Icons.payments_outlined;
  static IconData get paymentsRounded => Icons.payments_rounded;
  static IconData get pendingActionsOutlined => Icons.pending_actions_outlined;
  static IconData get peopleOutline => Icons.people_outline;
  static IconData get peopleOutlineRounded => Icons.people_outline_rounded;
  static IconData get personAddAlt1Outlined => Icons.person_add_alt_1_outlined;
  static IconData get personAddAlt1Rounded => Icons.person_add_alt_1_rounded;
  static IconData get personOffOutlined => Icons.person_off_outlined;
  static IconData get personOutlineRounded => Icons.person_outline_rounded;
  static IconData get personOutlined => Icons.person_outlined;
  static IconData get personRounded => Icons.person_rounded;
  static IconData get personSearchOutlined => Icons.person_search_outlined;
  static IconData get phoneAndroidRounded => Icons.phone_android_rounded;
  static IconData get phoneIphoneRounded => Icons.phone_iphone_rounded;
  static IconData get phoneOutlined => Icons.phone_outlined;
  static IconData get photoLibraryOutlined => Icons.photo_library_outlined;
  static IconData get placeOutlined => Icons.place_outlined;
  static IconData get playArrowRounded => Icons.play_arrow_rounded;
  static IconData get playCircleOutlineRounded =>
      Icons.play_circle_outline_rounded;
  static IconData get priceChangeOutlined => Icons.price_change_outlined;
  static IconData get priorityHighRounded => Icons.priority_high_rounded;
  static IconData get psychologyAltOutlined => Icons.psychology_alt_outlined;
  static IconData get qrCode2Outlined => Icons.qr_code_2_outlined;
  static IconData get qrCode2Rounded => Icons.qr_code_2_rounded;
  static IconData get qrCodeScannerRounded => Icons.qr_code_scanner_rounded;
  static IconData get queryStatsRounded => Icons.query_stats_rounded;
  static IconData get questionAnswerOutlined => Icons.question_answer_outlined;
  static IconData get queueOutlined => Icons.queue_outlined;
  static IconData get quizOutlined => Icons.quiz_outlined;
  static IconData get radioButtonCheckedRounded =>
      Icons.radio_button_checked_rounded;
  static IconData get radioButtonUncheckedRounded =>
      Icons.radio_button_unchecked_rounded;
  static IconData get rateReviewOutlined => Icons.rate_review_outlined;
  static IconData get receiptLongOutlined => Icons.receipt_long_outlined;
  static IconData get refreshRounded => Icons.refresh_rounded;
  static IconData get removeCircleOutlineRounded =>
      Icons.remove_circle_outline_rounded;
  static IconData get removeRounded => Icons.remove_rounded;
  static IconData get reportGmailerrorredRounded =>
      Icons.report_gmailerrorred_rounded;
  static IconData get restartAltRounded => Icons.restart_alt_rounded;
  static IconData get restaurantOutlined => Icons.restaurant_outlined;
  static IconData get routeOutlined => Icons.route_outlined;
  static IconData get routeRounded => Icons.route_rounded;
  static IconData get ruleFolderOutlined => Icons.rule_folder_outlined;
  static IconData get ruleOutlined => Icons.rule_outlined;
  static IconData get ruleRounded => Icons.rule_rounded;
  static IconData get saveOutlined => Icons.save_outlined;
  static IconData get schedule => Icons.schedule;
  static IconData get scheduleOutlined => Icons.schedule_outlined;
  static IconData get scheduleRounded => Icons.schedule_rounded;
  static IconData get schoolOutlined => Icons.school_outlined;
  static IconData get scienceOutlined => Icons.science_outlined;
  static IconData get searchOffRounded => Icons.search_off_rounded;
  static IconData get searchRounded => Icons.search_rounded;
  static IconData get selfImprovementRounded => Icons.self_improvement_rounded;
  static IconData get sendRounded => Icons.send_rounded;
  static IconData get settingsOutlined => Icons.settings_outlined;
  static IconData get shieldOutlined => Icons.shield_outlined;
  static IconData get smokeFreeOutlined => Icons.smoke_free_outlined;
  static IconData get smokeFreeRounded => Icons.smoke_free_rounded;
  static IconData get spaOutlined => Icons.spa_outlined;
  static IconData get speedOutlined => Icons.speed_outlined;
  static IconData get speedRounded => Icons.speed_rounded;
  static IconData get splitscreenRounded => Icons.splitscreen_rounded;
  static IconData get sportsTennis => Icons.sports_tennis;
  static IconData get sportsTennisRounded => Icons.sports_tennis_rounded;
  static IconData get starBorderRounded => Icons.star_border_rounded;
  static IconData get starOutlineRounded => Icons.star_outline_rounded;
  static IconData get starRounded => Icons.star_rounded;
  static IconData get straightenOutlined => Icons.straighten_outlined;
  static IconData get straightenRounded => Icons.straighten_rounded;
  static IconData get styleOutlined => Icons.style_outlined;
  static IconData get swapHorizRounded => Icons.swap_horiz_rounded;
  static IconData get syncAltRounded => Icons.sync_alt_rounded;
  static IconData get syncRounded => Icons.sync_rounded;
  static IconData get systemUpdateOutlined => Icons.system_update_outlined;
  static IconData get tableRestaurantOutlined =>
      Icons.table_restaurant_outlined;
  static IconData get tableRowsOutlined => Icons.table_rows_outlined;
  static IconData get timerOutlined => Icons.timer_outlined;
  static IconData get tipsAndUpdatesOutlined => Icons.tips_and_updates_outlined;
  static IconData get touchAppRounded => Icons.touch_app_rounded;
  static IconData get translateRounded => Icons.translate_rounded;
  static IconData get trendingUpRounded => Icons.trending_up_rounded;
  static IconData get tune => Icons.tune;
  static IconData get tuneRounded => Icons.tune_rounded;
  static IconData get updateRounded => Icons.update_rounded;
  static IconData get verifiedRounded => Icons.verified_rounded;
  static IconData get verifiedUserOutlined => Icons.verified_user_outlined;
  static IconData get visibilityOffOutlined => Icons.visibility_off_outlined;
  static IconData get visibilityOutlined => Icons.visibility_outlined;
  static IconData get volunteerActivismOutlined =>
      Icons.volunteer_activism_outlined;
  static IconData get volunteerActivismRounded =>
      Icons.volunteer_activism_rounded;
  static IconData get warningAmberRounded => Icons.warning_amber_rounded;
  static IconData get wavingHandOutlined => Icons.waving_hand_outlined;
  static IconData get wbSunnyOutlined => Icons.wb_sunny_outlined;
  static IconData get wbTwilightOutlined => Icons.wb_twilight_outlined;
  static IconData get wbTwilightRounded => Icons.wb_twilight_rounded;
  static IconData get wcOutlined => Icons.wc_outlined;
  static IconData get wifiOffRounded => Icons.wifi_off_rounded;
  static IconData get workOutline => Icons.work_outline;
  static IconData get workOutlineRounded => Icons.work_outline_rounded;

  // ── Activity glyphs — used by event thumbnails ───────────────────────────
  static IconData get socialRun => PhosphorIconsDuotone.personSimpleRun;
  static IconData get running => PhosphorIconsDuotone.personSimpleRun;
  static IconData get walking => PhosphorIconsDuotone.personSimpleWalk;
  static IconData get cycling => PhosphorIconsDuotone.personSimpleBike;
  static IconData get racquet => PhosphorIconsDuotone.tennisBall;
  static IconData get yoga => PhosphorIconsDuotone.flower;
  static IconData get strength => PhosphorIconsDuotone.barbell;
  static IconData get pubQuiz => PhosphorIconsDuotone.question;
  static IconData get barCrawl => PhosphorIconsDuotone.beerBottle;
  static IconData get dinner => PhosphorIconsDuotone.forkKnife;
  static IconData get singlesMixer => PhosphorIconsDuotone.usersThree;
  static IconData get openActivity => PhosphorIconsDuotone.sparkle;
}
