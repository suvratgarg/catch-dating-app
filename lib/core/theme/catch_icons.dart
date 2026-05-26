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
