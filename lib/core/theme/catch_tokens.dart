import 'package:catch_dating_app/core/theme/generated/catch_design_tokens.g.dart';
import 'package:flutter/material.dart';

/// Design tokens for Catch — B&W editorial palette (paper + ink).
/// No brand accent; color is reserved for activity meaning (§3 of
/// design_language.md).
///
/// Access via `CatchTokens.of(context)` inside any widget.
/// [AppTheme] wires `light` / `dark` into [ThemeData.extensions].
@immutable
class CatchTokens extends ThemeExtension<CatchTokens> {
  const CatchTokens({
    required this.bg,
    required this.surface,
    required this.raised,
    required this.overlay,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.line,
    required this.line2,
    required this.primary,
    required this.primaryInk,
    required this.primarySoft,
    required this.accent,
    required this.accentInk,
    required this.success,
    required this.warning,
    required this.danger,
    required this.like,
    required this.pass,
    required this.gold,
    required this.heroGrad,
  });

  // ── Semantic colour roles ─────────────────────────────────────────────────────

  /// App background (cool gallery off-white in light mode).
  final Color bg;

  /// Card / modal surface.
  final Color surface;

  /// Slightly raised surface (e.g. input backgrounds).
  final Color raised;

  /// Modal scrim / overlay.
  final Color overlay;

  /// Primary text colour.
  final Color ink;

  /// Secondary text colour.
  final Color ink2;

  /// Tertiary / placeholder text colour.
  final Color ink3;

  /// Hairline divider.
  final Color line;

  /// Slightly heavier divider.
  final Color line2;

  /// Default action colour (ink in light, paper in dark).
  final Color primary;

  /// Text/icon colour on top of [primary] fills.
  final Color primaryInk;

  /// Tinted background for soft primary containers (chips, badges).
  final Color primarySoft;

  /// Compatibility alias for the default action colour.
  final Color accent;

  /// Text/icon colour on top of [accent] fills.
  final Color accentInk;

  /// Positive state colour.
  final Color success;

  /// Warning / attention state colour.
  final Color warning;

  /// Error / destructive state colour.
  final Color danger;

  /// Swipe-like affordance colour.
  final Color like;

  /// Swipe-pass affordance colour.
  final Color pass;

  /// Gold / highlight colour (streak, achievement).
  final Color gold;

  /// Deprecated compatibility gradient for older surfaces. New event/club hero
  /// artwork should derive from the activity registry.
  final Gradient heroGrad;

  // ── Convenience accessor ──────────────────────────────────────────────────────

  static const Color editorialDark = Color(0xFF000000);
  static const Color editorialLight = Color(0xFFFFFFFF);

  static CatchTokens of(BuildContext context) =>
      Theme.of(context).extension<CatchTokens>()!;

  /// Legible foreground for arbitrary filled surfaces such as activity colors.
  Color onFill(Color fill) =>
      ThemeData.estimateBrightnessForColor(fill) == Brightness.dark
      ? const Color(0xFFFFFFFF)
      : ink;

  /// Muted foreground for secondary text on arbitrary filled surfaces.
  Color onFillMuted(Color fill) =>
      onFill(fill).withValues(alpha: CatchOpacity.onFillMuted);

  /// Dashed divider tone used by ticket/perforation treatments.
  Color get ticketPerforationLine =>
      ink.withValues(alpha: CatchOpacity.ticketPerforationLine);

  /// Fixed editorial dark fill for badges/pills that intentionally remain dark
  /// regardless of app theme.
  Color get darkPillFill =>
      editorialDark.withValues(alpha: CatchOpacity.darkPillFill);

  /// Fixed dark scrim for text overlays on image/activity backdrops.
  Color get darkScrimFill =>
      editorialDark.withValues(alpha: CatchOpacity.scrimFill);

  /// Foreground for fixed editorial dark pills.
  Color get darkPillInk => editorialLight;

  /// Muted foreground on fixed editorial dark overlays.
  Color get darkMutedInk =>
      editorialLight.withValues(alpha: CatchOpacity.onDarkMuted);

  // ── Paper/ink palette — light (launch default) ───────────────────────────────

  // B&W base — light (browse/forms register)
  static const light = CatchTokens(
    bg: GeneratedCatchColorTokens.lightBg,
    surface: GeneratedCatchColorTokens.lightSurface,
    raised: GeneratedCatchColorTokens.lightRaised,
    overlay: GeneratedCatchColorTokens.lightOverlay,
    ink: GeneratedCatchColorTokens.lightInk,
    ink2: GeneratedCatchColorTokens.lightInk2,
    ink3: GeneratedCatchColorTokens.lightInk3,
    line: GeneratedCatchColorTokens.lightLine,
    line2: GeneratedCatchColorTokens.lightLine2,
    primary: GeneratedCatchColorTokens.lightPrimary, // default action = ink
    primaryInk: GeneratedCatchColorTokens.lightPrimaryInk,
    primarySoft: GeneratedCatchColorTokens.lightPrimarySoft,
    // no brand accent; activity color overrides contextually
    accent: GeneratedCatchColorTokens.lightAccent,
    accentInk: GeneratedCatchColorTokens.lightAccentInk,
    success: GeneratedCatchColorTokens.lightSuccess,
    warning: GeneratedCatchColorTokens.lightWarning,
    danger: GeneratedCatchColorTokens.lightDanger,
    like: GeneratedCatchColorTokens.lightLike,
    pass: GeneratedCatchColorTokens.lightPass,
    gold: GeneratedCatchColorTokens.lightGold,
    // deprecated: hero gradients now derive from ActivityPalette
    heroGrad: GeneratedCatchGradientTokens.lightHeroGrad,
  );

  // ── Paper/ink palette — dark ("wow" surfaces) ───────────────────────────────

  // B&W base — dark (wow surfaces)
  static const dark = CatchTokens(
    bg: GeneratedCatchColorTokens.darkBg,
    surface: GeneratedCatchColorTokens.darkSurface,
    raised: GeneratedCatchColorTokens.darkRaised,
    overlay: GeneratedCatchColorTokens.darkOverlay,
    ink: GeneratedCatchColorTokens.darkInk,
    ink2: GeneratedCatchColorTokens.darkInk2,
    ink3: GeneratedCatchColorTokens.darkInk3,
    line: GeneratedCatchColorTokens.darkLine,
    line2: GeneratedCatchColorTokens.darkLine2,
    primary:
        GeneratedCatchColorTokens.darkPrimary, // default action = paper on dark
    primaryInk: GeneratedCatchColorTokens.darkPrimaryInk,
    primarySoft: GeneratedCatchColorTokens.darkPrimarySoft,
    accent: GeneratedCatchColorTokens.darkAccent,
    accentInk: GeneratedCatchColorTokens.darkAccentInk,
    success: GeneratedCatchColorTokens.darkSuccess,
    warning: GeneratedCatchColorTokens.darkWarning,
    danger: GeneratedCatchColorTokens.darkDanger,
    like: GeneratedCatchColorTokens.darkLike,
    pass: GeneratedCatchColorTokens.darkPass,
    gold: GeneratedCatchColorTokens.darkGold,
    heroGrad: GeneratedCatchGradientTokens.darkHeroGrad,
  );

  /// Backward-compatible aliases while older code still names the retired
  /// Sunset palette.
  static const sunsetLight = light;
  static const sunsetDark = dark;

  // ── ThemeExtension boilerplate ────────────────────────────────────────────────

  @override
  CatchTokens copyWith({
    Color? bg,
    Color? surface,
    Color? raised,
    Color? overlay,
    Color? ink,
    Color? ink2,
    Color? ink3,
    Color? line,
    Color? line2,
    Color? primary,
    Color? primaryInk,
    Color? primarySoft,
    Color? accent,
    Color? accentInk,
    Color? success,
    Color? warning,
    Color? danger,
    Color? like,
    Color? pass,
    Color? gold,
    Gradient? heroGrad,
  }) => CatchTokens(
    bg: bg ?? this.bg,
    surface: surface ?? this.surface,
    raised: raised ?? this.raised,
    overlay: overlay ?? this.overlay,
    ink: ink ?? this.ink,
    ink2: ink2 ?? this.ink2,
    ink3: ink3 ?? this.ink3,
    line: line ?? this.line,
    line2: line2 ?? this.line2,
    primary: primary ?? this.primary,
    primaryInk: primaryInk ?? this.primaryInk,
    primarySoft: primarySoft ?? this.primarySoft,
    accent: accent ?? this.accent,
    accentInk: accentInk ?? this.accentInk,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    like: like ?? this.like,
    pass: pass ?? this.pass,
    gold: gold ?? this.gold,
    heroGrad: heroGrad ?? this.heroGrad,
  );

  @override
  CatchTokens lerp(CatchTokens? other, double t) {
    if (other is! CatchTokens) return this;
    return CatchTokens(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      raised: Color.lerp(raised, other.raised, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      ink2: Color.lerp(ink2, other.ink2, t)!,
      ink3: Color.lerp(ink3, other.ink3, t)!,
      line: Color.lerp(line, other.line, t)!,
      line2: Color.lerp(line2, other.line2, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryInk: Color.lerp(primaryInk, other.primaryInk, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentInk: Color.lerp(accentInk, other.accentInk, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      like: Color.lerp(like, other.like, t)!,
      pass: Color.lerp(pass, other.pass, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      heroGrad: Gradient.lerp(heroGrad, other.heroGrad, t)!,
    );
  }
}

// ── Spacing ───────────────────────────────────────────────────────────────────

/// Layout spacing constants from the design-system 4-point scale.
abstract final class CatchSpacing {
  static const double s0 = GeneratedCatchSpacingTokens.s0;
  static const double s1 = GeneratedCatchSpacingTokens.s1;
  static const double s2 = GeneratedCatchSpacingTokens.s2;
  static const double s3 = GeneratedCatchSpacingTokens.s3;
  static const double s4 = GeneratedCatchSpacingTokens.s4;
  static const double s5 = GeneratedCatchSpacingTokens.s5;
  static const double s6 = GeneratedCatchSpacingTokens.s6;
  static const double s7 = GeneratedCatchSpacingTokens.s7;
  static const double s8 = GeneratedCatchSpacingTokens.s8;
  static const double s9 = GeneratedCatchSpacingTokens.s9;
  static const double s10 = GeneratedCatchSpacingTokens.s10;
  static const double s11 = GeneratedCatchSpacingTokens.s11;
  static const double s12 = GeneratedCatchSpacingTokens.s12;
  static const double s16 = GeneratedCatchSpacingTokens.s16;

  /// Component-internal micro spacing. Use only inside dense controls, charts,
  /// typographic underlines, and tiny badges where the 4-point rhythm is too
  /// coarse.
  static const double micro2 = GeneratedCatchSpacingTokens.micro2;
  static const double micro3 = GeneratedCatchSpacingTokens.micro3;
  static const double micro6 = GeneratedCatchSpacingTokens.micro6;
  static const double micro10 = GeneratedCatchSpacingTokens.micro10;
  static const double micro14 = GeneratedCatchSpacingTokens.micro14;
  static const double micro18 = GeneratedCatchSpacingTokens.micro18;

  /// App-wide page gutter and body padding from the design handoff.
  static const double screenPx = CatchSpacing.s5;
  static const double screenPt = CatchSpacing.s6;
  static const double screenPb = CatchSpacing.s5;
}

/// Semantic vertical and horizontal gaps for common layout relationships.
///
/// Use [CatchSpacing] for primitive math inside reusable components. Feature
/// screens should prefer these relationship tokens so the code says why a gap
/// exists, not only how large it is.
abstract final class CatchGaps {
  /// Tight icon/label or metadata pair spacing.
  static const double inline = CatchSpacing.s2;

  /// Gap between a screen-header title and the kicker/subtitle paired with it
  /// (browse-header title→subtitle, Home dashboard eyebrow→title). Centralises
  /// the subtitle-to-title relationship of the shared tab-screen header rhythm.
  static const double headerTitleToSubtitle = CatchSpacing.s1;

  /// Distance between closely related rows inside the same content cluster.
  static const double related = CatchSpacing.s3;

  /// Standard gap between controls in one form or settings group.
  static const double formField = CatchSpacing.s4;

  /// Default gap between peer sections in a page body.
  static const double section = CatchSpacing.s6;

  /// Extra separation between major page regions.
  static const double majorSection = CatchSpacing.s8;
}

/// Semantic inset contracts for repeated screen and component shells.
///
/// These are intentionally named for layout roles. Feature screens should use a
/// role here, or a layout primitive that embeds one, before composing raw
/// [EdgeInsets] from [CatchSpacing].
abstract final class CatchInsets {
  /// Default scroll/body padding for app pages with top chrome.
  static const EdgeInsets pageBody = EdgeInsets.fromLTRB(
    CatchSpacing.screenPx,
    CatchSpacing.screenPt,
    CatchSpacing.screenPx,
    CatchSpacing.screenPb,
  );

  /// Page body padding for flows that need extra scroll-end breathing room.
  static const EdgeInsets pageBodyRelaxed = EdgeInsets.fromLTRB(
    CatchSpacing.screenPx,
    CatchSpacing.screenPt,
    CatchSpacing.screenPx,
    CatchSpacing.s8,
  );

  /// Page body padding when top chrome already supplies some separation.
  static const EdgeInsets pageBodyTight = EdgeInsets.fromLTRB(
    CatchSpacing.screenPx,
    CatchSpacing.s3,
    CatchSpacing.screenPx,
    CatchSpacing.screenPb,
  );

  /// Tighter-top page body padding with extra scroll-end breathing room.
  static const EdgeInsets pageBodyRelaxedTight = EdgeInsets.fromLTRB(
    CatchSpacing.screenPx,
    CatchSpacing.s3,
    CatchSpacing.screenPx,
    CatchSpacing.s8,
  );

  /// Page body padding for content that sits directly under a dense header.
  static const EdgeInsets pageBodyUnderHeader = EdgeInsets.fromLTRB(
    CatchSpacing.screenPx,
    CatchSpacing.s1,
    CatchSpacing.screenPx,
    CatchSpacing.screenPb,
  );

  /// Compact body padding for dense chrome where the content already owns
  /// vertical separation.
  static const EdgeInsets pageBodyCompact = EdgeInsets.fromLTRB(
    CatchSpacing.screenPx,
    CatchSpacing.s2,
    CatchSpacing.screenPx,
    CatchSpacing.s4,
  );

  /// Compact-top scroll body for tab screens that own their title block inline
  /// (no pinned header) and need section-sized scroll-end breathing room — the
  /// Catches hub feed and its empty state share this single contract.
  static const EdgeInsets pageBodyHero = EdgeInsets.fromLTRB(
    CatchSpacing.screenPx,
    CatchSpacing.s2,
    CatchSpacing.screenPx,
    CatchSpacing.s6,
  );

  /// Explore activity index padding: page gutters, section top breathing room,
  /// and enough scroll-end space to clear the floating map pill.
  static const EdgeInsets eventTypeBrowseIndex = EdgeInsets.fromLTRB(
    CatchSpacing.screenPx,
    CatchSpacing.screenPx,
    CatchSpacing.screenPx,
    CatchLayout.eventTypeBrowseBottomPadding,
  );

  /// Loading state for the Explore activity index.
  static const EdgeInsets eventTypeBrowseSkeleton = EdgeInsets.fromLTRB(
    CatchSpacing.screenPx,
    CatchSpacing.screenPx,
    CatchSpacing.screenPx,
    CatchSpacing.s4,
  );

  /// Horizontal page/list gutters when vertical padding is owned elsewhere.
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(
    horizontal: CatchSpacing.screenPx,
  );

  /// Wider horizontal gutters for sparse auth/onboarding layouts.
  static const EdgeInsets pageHorizontalWide = EdgeInsets.symmetric(
    horizontal: CatchSpacing.s6,
  );

  /// Full-screen welcome hero padding.
  static const EdgeInsets welcomeHero = EdgeInsets.fromLTRB(
    CatchSpacing.s7,
    CatchSpacing.s6,
    CatchSpacing.s7,
    CatchSpacing.s7,
  );

  /// Reel row copy inset in the animated welcome splash.
  static const EdgeInsets welcomeReelRow = EdgeInsets.only(
    left: CatchLayout.welcomeReelObjectLeft,
    right: CatchLayout.welcomeReelObjectRight,
    top: CatchSpacing.micro14,
  );

  /// Header/body padding for page-level intro rows before dense content.
  static const EdgeInsets pageHeaderBody = EdgeInsets.fromLTRB(
    CatchSpacing.s5,
    CatchSpacing.s4,
    CatchSpacing.s5,
    CatchSpacing.s3,
  );

  /// Compact page-level intro padding before dense content.
  static const EdgeInsets pageHeaderCompact = EdgeInsets.fromLTRB(
    CatchSpacing.s5,
    CatchSpacing.s2,
    CatchSpacing.s5,
    CatchSpacing.s3,
  );

  // ── Shared tab-screen header rhythm ─────────────────────────────────────────
  //
  // The five top-level tab screens (Home, Clubs, Catches, Chats, Profile) share
  // one spacing contract for the band between their title block, any pinned
  // search/filter/tab control, and the first content row. These role tokens
  // centralise that rhythm so screens stop tuning their own raw EdgeInsets.
  // The horizontal page gutter stays [CatchSpacing.screenPx] (s5) everywhere.

  /// (1) Title block padding for tab screens whose header pairs a title with a
  /// subtitle (Chats, Clubs browse headers). Canonical = [pageHeaderBody].
  static const EdgeInsets screenTitleBlock = pageHeaderBody;

  /// (1) Title block padding for tab screens whose header is a compact
  /// eyebrow/title or title-only row (Home dashboard, Profile-style headers).
  /// Canonical = [pageHeaderCompact].
  static const EdgeInsets screenTitleBlockCompact = pageHeaderCompact;

  /// (3) Horizontal gutters for a pinned search/filter/tab control row when its
  /// vertical rhythm is owned by the control's own height slot (Profile tab
  /// bar, Chats host-filter row). Canonical = [pageHorizontal].
  static const EdgeInsets screenControlRow = pageHorizontal;

  /// (3) Padding for a pinned filter/scope rail that sits flush above the first
  /// content row, owning its top separation but deferring the bottom gap to the
  /// content below (Clubs/Explore filter rail).
  static const EdgeInsets screenControlRail = EdgeInsets.fromLTRB(
    CatchSpacing.s5,
    CatchSpacing.s4,
    CatchSpacing.s5,
    CatchSpacing.s0,
  );

  /// Section header padding above compact horizontal rails or lists.
  static const EdgeInsets sectionHeader = EdgeInsets.fromLTRB(
    CatchSpacing.s5,
    CatchSpacing.micro14,
    CatchSpacing.s5,
    CatchSpacing.s2,
  );

  /// Default padding for multi-step creation/edit forms.
  static const EdgeInsets formStepBody = pageBody;

  /// Form-step padding with more bottom space for final/action-heavy steps.
  static const EdgeInsets formStepBodyRelaxed = pageBodyRelaxed;

  /// Long-form edit body padding under a top app bar.
  static const EdgeInsets formEditBodyRelaxed = EdgeInsets.fromLTRB(
    CatchSpacing.screenPx,
    CatchSpacing.s4,
    CatchSpacing.screenPx,
    CatchSpacing.s7,
  );

  /// Top offset for titled form sections inside a continuous edit page.
  static const EdgeInsets formSectionTop = EdgeInsets.only(
    top: CatchSpacing.s2,
  );

  /// Inline error offset below form controls inside step forms.
  static const EdgeInsets formFieldError = EdgeInsets.only(
    top: CatchSpacing.s1,
    left: CatchSpacing.s1,
  );

  /// Bottom-docked form action padding with page gutters and safe-area lift.
  static const EdgeInsets formActionDock = EdgeInsets.fromLTRB(
    CatchSpacing.screenPx,
    CatchSpacing.s3,
    CatchSpacing.screenPx,
    CatchSpacing.micro18,
  );

  /// Default content padding inside cards and bordered panels.
  static const EdgeInsets content = EdgeInsets.all(CatchSpacing.s4);

  /// Confirm-dialog card padding from the implementation handoff.
  static const EdgeInsets confirmDialogCard = EdgeInsets.fromLTRB(
    22.0,
    CatchSpacing.s6,
    22.0,
    CatchSpacing.micro18,
  );

  /// Dense content padding for compact summary tiles and small controls.
  static const EdgeInsets contentDense = EdgeInsets.all(CatchSpacing.s3);

  /// Relaxed content padding for empty states, large cards, and share panels.
  static const EdgeInsets contentRelaxed = EdgeInsets.all(CatchSpacing.s5);

  /// Spacious content padding for hero panels and full-page empty states.
  static const EdgeInsets contentSpacious = EdgeInsets.all(CatchSpacing.s6);

  /// Horizontal content padding when vertical rhythm is supplied separately.
  static const EdgeInsets contentHorizontal = EdgeInsets.symmetric(
    horizontal: CatchSpacing.s4,
  );

  /// Inline horizontal padding for compact chips and segmented items.
  static const EdgeInsets inlineHorizontal = EdgeInsets.symmetric(
    horizontal: CatchSpacing.s2,
  );

  /// Tight inline horizontal padding for tiny rating/star controls.
  static const EdgeInsets inlineHorizontalTight = EdgeInsets.symmetric(
    horizontal: CatchSpacing.s1,
  );

  /// Relaxed inline horizontal padding for pills and message rows.
  static const EdgeInsets inlineHorizontalRelaxed = EdgeInsets.symmetric(
    horizontal: CatchSpacing.s3,
  );

  /// Micro horizontal padding for compact icon labels.
  static const EdgeInsets iconLabelHorizontal = EdgeInsets.symmetric(
    horizontal: CatchSpacing.micro6,
  );

  /// Margin between the selected country flag and dial code text.
  static const EdgeInsets countryCodeFlagMargin = EdgeInsets.only(
    right: CatchSpacing.micro6,
  );

  /// Pill horizontal padding for badges and compact chips.
  static const EdgeInsets pillHorizontal = EdgeInsets.symmetric(
    horizontal: CatchSpacing.micro14,
  );

  /// Tight vertical padding for small controls and menu rows.
  static const EdgeInsets controlVerticalTight = EdgeInsets.symmetric(
    vertical: CatchSpacing.s1,
  );

  /// Compact vertical padding for date markers and dense labels.
  static const EdgeInsets contentVerticalCompact = EdgeInsets.symmetric(
    vertical: CatchSpacing.s2,
  );

  /// Mid-compact vertical padding for button-like empty-state chips.
  static const EdgeInsets contentVerticalMedium = EdgeInsets.symmetric(
    vertical: CatchSpacing.micro14,
  );

  /// Standard vertical padding for rows and list sections.
  static const EdgeInsets contentVertical = EdgeInsets.symmetric(
    vertical: CatchSpacing.s3,
  );

  /// Large vertical padding for tappable rows.
  static const EdgeInsets tileVertical = EdgeInsets.symmetric(
    vertical: CatchSpacing.s4,
  );

  /// Compact but prominent vertical padding for filter rows and dense tiles.
  static const EdgeInsets tileVerticalCompact = EdgeInsets.symmetric(
    vertical: CatchSpacing.micro18,
  );

  /// Relaxed vertical padding for standalone panel sections.
  static const EdgeInsets contentVerticalRelaxed = EdgeInsets.symmetric(
    vertical: CatchSpacing.s5,
  );

  /// Spacious vertical padding for empty states and loading panels.
  static const EdgeInsets contentVerticalSpacious = EdgeInsets.symmetric(
    vertical: CatchSpacing.s6,
  );

  /// Oversized content padding for standalone empty/error states.
  static const EdgeInsets emptyStateContent = EdgeInsets.all(CatchSpacing.s8);

  /// Compact tile padding for dense detail facts and status rows.
  static const EdgeInsets tileContentCompact = EdgeInsets.all(
    CatchSpacing.micro14,
  );

  /// Standard tile padding for large tappable rows.
  static const EdgeInsets tileContent = EdgeInsets.all(CatchSpacing.micro18);

  /// Icon-chip padding for small square/circular icon marks.
  static const EdgeInsets iconChipContent = EdgeInsets.all(CatchSpacing.s2);

  /// Tight icon-chip padding for nested avatar/status marks.
  static const EdgeInsets iconChipContentTight = EdgeInsets.all(
    CatchSpacing.micro2,
  );

  /// Small info-tile padding where icon and label must stay compact.
  static const EdgeInsets infoTileContent = EdgeInsets.symmetric(
    horizontal: CatchSpacing.micro6,
    vertical: CatchSpacing.s1,
  );

  /// Dense stat/control padding for compact metric chips.
  static const EdgeInsets statChipContent = EdgeInsets.symmetric(
    horizontal: CatchSpacing.s2,
    vertical: CatchSpacing.s3,
  );

  /// Compact pill/control padding used by status chips and inline actions.
  static const EdgeInsets compactControlContent = EdgeInsets.symmetric(
    horizontal: CatchSpacing.s3,
    vertical: CatchSpacing.s2,
  );

  /// Label pill padding for over-media metadata.
  static const EdgeInsets compactLabelContent = EdgeInsets.symmetric(
    horizontal: CatchSpacing.s3,
    vertical: CatchSpacing.micro6,
  );

  /// Balanced small-card/control padding.
  static const EdgeInsets controlContent = EdgeInsets.symmetric(
    horizontal: CatchSpacing.s3,
    vertical: CatchSpacing.s3,
  );

  /// Dense list body padding where rows own their own vertical rhythm.
  static const EdgeInsets listBodyDense = EdgeInsets.symmetric(
    horizontal: CatchSpacing.s3,
    vertical: CatchSpacing.s4,
  );

  /// Standard list body padding with page-adjacent horizontal gutters.
  static const EdgeInsets listBody = EdgeInsets.symmetric(
    horizontal: CatchSpacing.s4,
    vertical: CatchSpacing.s3,
  );

  /// Content block padding with slightly stronger bottom separation.
  static const EdgeInsets contentBlock = EdgeInsets.fromLTRB(
    CatchSpacing.s4,
    CatchSpacing.s3,
    CatchSpacing.s4,
    CatchSpacing.s4,
  );

  /// Shared content padding for chat and share-card message bubbles.
  static const EdgeInsets chatBubbleContent = EdgeInsets.symmetric(
    horizontal: CatchSpacing.micro14,
    vertical: CatchSpacing.micro10,
  );

  /// Gap after the last message in a sender group.
  static const EdgeInsets chatBubbleGroupEnd = EdgeInsets.only(
    bottom: CatchSpacing.s3,
  );

  /// Tight gap between consecutive messages from the same sender.
  static const EdgeInsets chatBubbleGroupContinue = EdgeInsets.only(
    bottom: CatchSpacing.micro3,
  );

  /// Gap between a media attachment and the caption/timestamp in a bubble.
  static const EdgeInsets chatMediaAttachmentBottom = EdgeInsets.only(
    bottom: CatchSpacing.micro6,
  );

  /// Horizontal gutters for the Chats conversation list. Matches the section
  /// kicker gutter so the list tiles, header label, and dividers all align.
  static const EdgeInsets chatListGutter = EdgeInsets.symmetric(
    horizontal: CatchSpacing.s4,
  );

  /// Vertical padding for a single chat conversation row.
  static const EdgeInsets chatListTileVertical = EdgeInsets.symmetric(
    vertical: CatchSpacing.s3,
  );

  /// Bottom gap between compact inline rows in detail screens.
  static const EdgeInsets detailInlineRowBottomGap = EdgeInsets.only(
    bottom: CatchSpacing.micro10,
  );

  /// Top alignment offset for small hint dots beside multiline detail copy.
  static const EdgeInsets detailHintDotTop = EdgeInsets.only(
    top: CatchSpacing.s1,
  );

  /// Safe-area minimum padding for fixed loading CTAs on detail screens.
  static const EdgeInsets detailLoadingCtaSafeArea = EdgeInsets.fromLTRB(
    CatchLayout.detailScreenHorizontalPadding,
    CatchSpacing.s3,
    CatchLayout.detailScreenHorizontalPadding,
    CatchSpacing.s3,
  );

  /// Default content padding inside cards and bordered panels.
  static const EdgeInsets cardContent = content;

  /// Dense card padding for compact summary tiles and small controls.
  static const EdgeInsets cardContentDense = contentDense;
}

// ── Radii ─────────────────────────────────────────────────────────────────────

/// Corner radius constants from the design-system radius scale.
abstract final class CatchRadius {
  static const double none = GeneratedCatchRadiusTokens.none;
  static const double xs = GeneratedCatchRadiusTokens.xs;
  static const double sm = GeneratedCatchRadiusTokens.sm;
  static const double md = GeneratedCatchRadiusTokens.md;
  static const double lg = GeneratedCatchRadiusTokens.lg;
  static const double profileHeroBottom = CatchSpacing.s7;
  static const double segmentedInner = CatchSpacing.micro18;
  static const double segmentedOuter = 22.0;
  static const double infoTile = 10.0;
  static const double interactiveTile = 12.0;
  static const double heroCard = 22.0;
  static const double profilePhotoBottom = 30.0;
  static const double attendedEventTile = 18.0;
  static const double pill = GeneratedCatchRadiusTokens.pill;
}

// ── Elevation ────────────────────────────────────────────────────────────────

/// Minimal elevation tokens. Most Catch surfaces should use a hairline border;
/// use shadows only when UI actually floats above content.
abstract final class CatchElevation {
  static const List<BoxShadow> none = <BoxShadow>[];

  /// Shared physical-shadow color for Material/PhysicalShape surfaces.
  static const Color physicalShadow = Color.fromRGBO(26, 20, 16, 0.18);

  /// Flutter physical elevation for clipped ticket shapes that cannot use
  /// regular [BoxShadow] lists.
  static const double physicalTicket = 4.0;

  /// Physical lift for circular floating controls over media.
  static const double physicalControl = 3.0;

  /// Handoff floating icon-button shadow for controls over photos and maps.
  static const List<BoxShadow> iconButtonFloat = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(26, 20, 16, 0.18),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Toggle knob shadow from the handoff control primitive.
  static const List<BoxShadow> toggleKnob = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.25),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  /// Physical lift for the primary pass control over media.
  static const double physicalPassControl = 5.0;

  /// Material menu elevation.
  static const double menu = 8.0;

  /// Subtle lift for content cards that should read as "above the page" while
  /// keeping the hairline border style. Use for hero event cards, editorial
  /// picks, and selected map peek tiles.
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(26, 20, 16, 0.06),
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color.fromRGBO(26, 20, 16, 0.04),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Bottom sheets, floating action buttons, popovers.
  static const List<BoxShadow> raised = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(26, 20, 16, 0.10),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color.fromRGBO(26, 20, 16, 0.06),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Toasts, snackbars, dropdown overlays.
  static const List<BoxShadow> overlay = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(26, 20, 16, 0.18),
      blurRadius: 40,
      offset: Offset(0, 16),
    ),
    BoxShadow(
      color: Color.fromRGBO(26, 20, 16, 0.08),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> focusRing(CatchTokens t) => <BoxShadow>[
    BoxShadow(color: t.primarySoft, spreadRadius: CatchSpacing.micro3),
  ];

  static List<BoxShadow> segmentedSelected(CatchTokens t) => <BoxShadow>[
    BoxShadow(
      color: t.ink.withValues(alpha: CatchOpacity.controlOverlayPressed),
      blurRadius: CatchSpacing.micro14,
      offset: const Offset(CatchSpacing.s0, CatchSpacing.micro3),
    ),
  ];

  static List<BoxShadow> glow(
    Color color, {
    required double blurRadius,
    double spreadRadius = CatchSpacing.micro2,
  }) => <BoxShadow>[
    BoxShadow(color: color, blurRadius: blurRadius, spreadRadius: spreadRadius),
  ];
}

// ── Opacity roles ───────────────────────────────────────────────────────────

/// Semantic opacity levels for component states and editorial visual effects.
abstract final class CatchOpacity {
  static const double visible = 1.0;
  static const double none = 0.0;
  static const double onFillMuted = 0.76;
  static const double ticketPerforationLine = 0.22;

  /// Filled-surface scrim for text/icons that need contrast on colored
  /// backgrounds — activity stamps, active date-marker text.
  static const double scrimFill = 0.72;

  /// Barely visible platform text field used behind custom OTP digit boxes.
  static const double hiddenInput = 0.01;

  /// Photo-obscuring avatar scrim.
  static const double avatarPhotoScrim = 0.16;

  /// Disabled control opacity for non-semantic fade states.
  static const double disabledControl = 0.40;

  /// Translucent fill for floating icon-button chrome over photos and maps.
  static const double iconButtonFloatFill = 0.90;

  /// High-opacity blur fill for the handoff bottom tab dock.
  static const double tabDockFill = 0.93;

  /// Very light tint for accent-color backgrounds (date pills, soft status
  /// pills).
  static const double subtleFill = 0.12;

  /// Tone wash behind a tinted Callout (design-system color-mix 7%).
  static const double calloutFill = 0.07;

  // CoverStory (design-system components/explore/CoverStory) — the dark wow cover.
  static const double coverStoryGlow = 0.58;
  static const double coverStoryGhostGlyph = 0.07;
  static const double coverStoryScrim = 0.035;
  static const double coverStoryBody = 0.76;
  static const double coverStoryData = 0.70;
  static const double coverStoryLocation = 0.65;
  static const double coverStorySearchBorder = 0.28;
  static const double coverStoryKickerMix = 0.55;

  /// Soft warning-state fill.
  static const double warningFill = 0.14;

  /// Soft danger-state fill.
  static const double dangerFill = 0.10;

  /// Almost-clear image scrim stop for full-photo gradients.
  static const double photoScrimBarelyVisible = 0.05;

  /// Nearly transparent image scrim stop for profile-card overlays.
  static const double photoScrimLow = 0.04;

  /// Light image scrim stop for hero/photo gradients.
  static const double photoScrimLight = 0.10;

  /// Mid-light image scrim stop for hero/photo gradients.
  static const double photoScrimMedium = 0.16;

  /// Hairline border on subtle-tint containers (date pills, soft badges).
  static const double subtleBorder = 0.22;

  /// Activity-art fallback icon opacity on photo-replacement surfaces.
  static const double fallbackArtworkIcon = 0.24;

  /// Muted border on medium-contrast component shells (activity stamps).
  static const double mutedBorder = 0.54;

  /// Muted border for urgent/attention card shells.
  static const double mutedBorderUrgent = 0.32;

  /// Disabled / muted content text.
  static const double mutedContent = 0.36;

  /// Gradient-stop band — muted background layer (action-card gradients).
  static const double gradientBand = 0.62;

  /// Gradient-stop band — soft background layer (action-card gradients).
  static const double gradientBandSoft = 0.28;

  /// Dark-pill fill overlay — editorial status pill on the dark tone.
  static const double darkPillFill = 0.68;

  /// Confirm-dialog backdrop alpha from the implementation handoff.
  static const double confirmDialogScrim = 0.46;

  /// Muted copy/icon foreground on fixed dark overlay surfaces.
  static const double onDarkMuted = 0.70;

  /// Hairline separators over fixed dark editorial hero surfaces.
  static const double darkHeroDivider = 0.18;

  /// Translucent pill fills over fixed dark editorial hero surfaces.
  static const double darkHeroPillFill = 0.16;

  /// Backing ring opacity for overlapping avatar stacks on dark/art surfaces.
  static const double avatarStackRing = 0.28;

  static const double activityAvatarPrint = 0.08;
  static const double activityAvatarInnerRule = 0.16;
  static const double activityAvatarDim = 0.20;
  static const double activityMapPinShadow = 0.30;
  static const double distanceRing = 0.28;
  static const double distanceRingLabelFill = 0.94;
  static const double activityArtPrint = 0.07;
  static const double activityArtInnerRule = 0.14;
  static const double activityArtGlyph = 0.16;
  static const double activityArtDim = 0.18;

  /// Prominent but softened text/icon foreground on primary dark surfaces.
  static const double primaryInkProminent = 0.82;

  /// Frosted floating chrome over full-bleed media.
  static const double floatingChromeFill = 0.84;

  /// Hairline border for frosted floating chrome over full-bleed media.
  static const double floatingChromeBorder = 0.72;

  /// Floating circular control surface over full-bleed media.
  static const double floatingControlFill = 0.88;

  static const double welcomeHeroBody = 0.88;
  static const double welcomeIntroBody = 0.66;
  static const double welcomeReelDimMin = 0.12;
  static const double welcomeReelDimDistanceRows = 3.2;
  static const double welcomeReelDecolorPigment = 0.26;
  static const double welcomeSecondaryButtonFill = 0.14;
  static const double welcomeSecondaryButtonBorder = 0.42;
  static const double welcomeTrackPattern = 0.16;
  static const double welcomeReelMaskLead = 0.14;
  static const double welcomeReelMaskTail = 0.88;
  static const double mapDistanceRingStroke = 0.38;
  static const double mapDistanceRingFill = 0.08;
  static const double mapUserLocationStroke = 0.92;
  static const double eventSuccessQrErrorFill = 0.84;
  static const double strideInactiveBar = 0.55;
  static const double emptyHeroArtStroke = 0.25;
  static const double appShellNavigationBarFill = 0.96;
  static const double suvbotDestructiveFill = 0.24;
  static const double profileInlineUnderlineActive = 0.90;
  static const double profileInlineUnderlineInactive = 0.35;
  static const double profileDisabledIcon = 0.45;
  static const double eventDetailLightBorder = 0.24;
  static const double arrivalCelebrationPeak = 0.62;
  static const double arrivalCelebrationMidMultiplier = 0.85;
  static const double arrivalCelebrationLowMultiplier = 0.50;
  static const double manualQaHeroMeta = 0.86;
  static const double manualQaPillFill = 0.14;
  static const double manualQaPillBorder = 0.22;
  static const double hostDangerBorder = 0.45;
  static const double imageEditControlFill = 0.85;
  static const double revealAttendeePanelFill = 0.92;
  static const double revealAttendeeBorder = 0.24;
  static const double revealAttendeeActionDock = 0.88;
  static const double chatUnreadBorder = 0.36;
  static const double paymentReferralBorder = 0.24;
  static const double paymentHelpBorder = 0.40;
  static const double paymentCheckoutScrim = 0.55;
  static const double locationPickerTopChromeFill = 0.94;
  static const double locationPickerPanelFill = 0.96;
  static const double eventDetailCtaDarkDivider = 0.12;
  static const double readinessWarningBorder = 0.32;
  static const double eventSuccessPreviewMeta = 0.86;
  static const double eventDetailPrimarySoft = 0.18;
  static const double mapOverlayChromeFill = 0.92;
  static const double photoDragGhost = 0.35;
  static const double profileInfoDivider = 0.62;

  /// Inset hairline divider between on-surface rows (FieldRow / settings / chat
  /// inbox) — design-system color-mix(line 38%, transparent).
  static const double fieldRowDivider = 0.38;
  static const double profileProgressTrack = 0.70;
  static const double profileShadowDark = 0.34;
  static const double profileShadowLight = 0.10;

  /// Bottom scrim stop for overlaid actions on full-bleed media.
  static const double bottomActionScrim = 0.82;

  /// Hover overlay for buttons and tappable controls.
  static const double controlOverlayHover = 0.04;

  /// Pressed/splash overlay for buttons and tappable controls.
  static const double controlOverlayPressed = 0.08;

  /// Animated loading-dot sequence.
  static const List<double> loadingDotAlphas = <double>[0.4, 0.6, 0.8];

  /// Inactive page-dot opacity.
  static const double pageDotInactive = 0.90;

  /// Frosted white overlay fill for icon marks on dark activity imagery.
  static const double lightOverlayFill = 0.18;

  /// Frosted white overlay border for icon marks on dark activity imagery.
  static const double lightOverlayBorder = 0.42;

  /// Error container fill inside inline banners.
  static const double errorContainerFill = 0.47;

  /// Error container border inside inline banners.
  static const double errorContainerBorder = 0.24;

  /// Near-opaque sash/surface fill on media cards.
  static const double surfaceSashFill = 0.92;

  /// Club-cover fallback art overlay highlight.
  static const double clubCoverHighlightOverlay = 0.10;

  /// Club-cover fallback art low scrim.
  static const double clubCoverLowScrim = 0.04;

  /// Club-cover fallback location-chip fill.
  static const double clubCoverChipFill = 0.72;

  /// Club-cover fallback location-chip border.
  static const double clubCoverChipBorder = 0.62;

  /// Club-cover fallback pattern block overlay.
  static const double clubCoverPatternBlock = 0.44;

  /// Club-cover fallback pattern line overlay.
  static const double clubCoverPatternLine = 0.28;

  /// Club-cover fallback pattern dot overlay.
  static const double clubCoverPatternDot = 0.50;

  /// Club-cover deterministic palette accent blend.
  static const double clubCoverAccentBlend = 0.22;

  /// Club-cover deterministic palette deep blend.
  static const double clubCoverDeepBlend = 0.18;

  /// Club-cover deterministic palette line.
  static const double clubCoverPaletteLine = 0.30;

  /// Club-cover deterministic palette block.
  static const double clubCoverPaletteBlock = 0.45;

  /// Event detail hero top-control scrim.
  static const double eventHeroOverlayScrim = 0.35;

  /// Event detail hero middle gradient scrim.
  static const double eventHeroGradientMidScrim = 0.10;

  /// Event detail hero standard bottom gradient scrim.
  static const double eventHeroGradientBottomScrim = 0.34;

  /// Event detail hero spotlight bottom gradient scrim.
  static const double eventHeroSpotlightBottomScrim = 0.52;

  /// Muted foreground inside event-detail hero overlays.
  static const double eventHeroMutedInk = 0.72;

  /// Prominent foreground/content on Event Success stage surfaces.
  static const double eventSuccessProminent = 0.82;

  /// Companion stage nav/chrome foreground.
  static const double eventSuccessChrome = 0.84;

  /// Muted foreground/content on Event Success stage surfaces.
  static const double eventSuccessMutedInk = 0.72;

  /// Disabled foreground on Event Success stage controls.
  static const double eventSuccessDisabled = 0.36;

  /// Muted foreground on Event Success stage chrome.
  static const double eventSuccessMuted = 0.34;

  /// Subtle Event Success border.
  static const double eventSuccessSubtleBorder = 0.18;

  /// Subtle Event Success privacy border.
  static const double eventSuccessPrivacyBorder = 0.15;

  /// Event Success stage panel fill.
  static const double eventSuccessPanelFill = 0.90;

  /// Event Success action dock fill.
  static const double eventSuccessActionDockFill = 0.88;

  /// Event Success stage-panel breathing border base.
  static const double eventSuccessPanelBorderBase = 0.22;

  /// Event Success stage-panel breathing border delta.
  static const double eventSuccessPanelBorderBreath = 0.12;

  /// Event Success stage-theme background color blend.
  static const double eventSuccessStageBgBlend = 0.42;

  /// Event Success stage-theme mid color blend.
  static const double eventSuccessStageMidBlend = 0.35;

  /// Event Success motif base line opacity.
  static const double eventSuccessMotifBase = 0.12;

  /// Event Success motif accent line opacity.
  static const double eventSuccessMotifAccent = 0.34;

  /// Event Success stage bouncy-press glow multiplier.
  static const double eventSuccessBouncyGlow = 0.36;

  /// Event Success live room glow base.
  static const double eventSuccessRoomGlowBase = 0.18;

  /// Event Success live room glow pulse.
  static const double eventSuccessRoomGlowPulse = 0.22;

  /// Event Success arrival ring accent foreground.
  static const double eventSuccessArrivalAccent = 0.72;

  /// Event Success arrival ring caption.
  static const double eventSuccessArrivalCaption = 0.78;

  /// Event Success arrival ring filled-dot highlight.
  static const double eventSuccessArrivalHighlight = 0.92;

  /// Event Success reveal countdown surface fill.
  static const double revealSurfaceFill = 0.12;

  /// Event Success reveal countdown surface border.
  static const double revealSurfaceBorder = 0.18;

  /// Event Success countdown foreground muted label.
  static const double revealMutedForeground = 0.78;

  /// Event Success countdown gradient start.
  static const double revealGradientStart = 0.08;

  /// Event Success reveal border.
  static const double revealGoldBorder = 0.34;

  /// Event Success reveal glow base.
  static const double revealGlowBase = 0.20;

  /// Event Success reveal glow urgency delta.
  static const double revealGlowUrgency = 0.12;

  /// Event Success reveal beat active fill.
  static const double revealBeatFillActive = 0.24;

  /// Event Success reveal beat inactive fill.
  static const double revealBeatFillInactive = 0.10;

  /// Event Success reveal beat active border.
  static const double revealBeatBorderActive = 0.52;

  /// Event Success reveal beat inactive border.
  static const double revealBeatBorderInactive = 0.16;

  /// Event Success reveal cue fill.
  static const double revealCueFill = 0.09;

  /// Event Success reveal cue border.
  static const double revealCueBorder = 0.13;

  /// Event Success reveal atmosphere glow base.
  static const double revealAtmosphereGlowBase = 0.08;

  /// Event Success reveal atmosphere glow urgency delta.
  static const double revealAtmosphereGlowUrgency = 0.07;

  /// Event Success reveal atmosphere line base.
  static const double revealAtmosphereLineBase = 0.10;

  /// Event Success reveal atmosphere hot-line base.
  static const double revealAtmosphereHotLineBase = 0.22;

  /// Event Success reveal atmosphere hot-line urgency delta.
  static const double revealAtmosphereHotLineUrgency = 0.16;

  /// Event Success reveal dial base.
  static const double revealDialBase = 0.13;

  /// Event Success reveal dial glow base.
  static const double revealDialGlowBase = 0.16;

  /// Event Success reveal dial glow urgency delta.
  static const double revealDialGlowUrgency = 0.10;

  /// Event Success reveal dial sweep accent.
  static const double revealDialSweepAccent = 0.40;

  /// Event Success reveal dial sweep foreground.
  static const double revealDialSweepForeground = 0.90;

  /// Event Success reveal dial center fill.
  static const double revealDialCenterFill = 0.045;

  /// Event Success reveal dial inner glow base.
  static const double revealDialInnerGlowBase = 0.08;

  /// Event Success reveal dial inner glow urgency delta.
  static const double revealDialInnerGlowUrgency = 0.06;

  /// Event Success reveal cinematic flash peak.
  static const double revealCinematicFlash = 0.62;

  /// Event Success reveal cinematic particle peak.
  static const double revealCinematicParticle = 0.70;

  /// Event Success warning/issue border.
  static const double eventSuccessWarningBorder = 0.28;

  /// Event recap hero kicker on fixed dark surfaces.
  static const double eventRecapHeroKicker = 0.68;

  /// Event recap hero metadata on fixed dark surfaces.
  static const double eventRecapHeroMeta = 0.76;

  /// Event recap hero stat label on fixed dark surfaces.
  static const double eventRecapHeroStatLabel = 0.56;

  /// Event recap roster-tile name scrim.
  static const double eventRecapTileScrim = 0.74;

  /// Flagship profile hero scrim stops (design-system ProfileHero, at
  /// 0/45/78/100% → 0.14 / 0 / 0.34 / 0.74). Legible name/meta without crushing
  /// the portrait.
  static const double profileHeroScrimTop = 0.14;
  static const double profileHeroScrimMid = 0.34;
  static const double profileHeroScrimBottom = 0.74;

  /// Activity-art fallback icon opacity on the flagship profile hero.
  static const double profileFallbackArtworkIcon = 0.18;

  /// Activity-art fallback pattern opacity on the flagship profile hero.
  static const double profileFallbackArtworkPattern = 0.20;

  /// Muted profile hero metadata on dark photo overlays.
  static const double profileHeroMuted = 0.86;

  /// Loading scrim over profile-photo upload slots.
  static const double photoUploadLoadingScrim = 0.45;

  /// Floating edit chrome over profile-photo slots.
  static const double photoSlotEditChrome = 0.85;

  /// Prompt chip scrim over profile-photo slots.
  static const double photoPromptScrim = 0.58;

  /// Floating delete chrome over profile-photo slots.
  static const double photoSlotDeleteChrome = 0.90;

  /// Compact club member seal fill.
  static const double clubMemberSealCompactFill = 0.90;

  /// Full club member seal fill.
  static const double clubMemberSealFill = 0.72;

  /// Club member seal accent border.
  static const double clubMemberSealBorder = 0.46;

  /// Club rating pill fill.
  static const double clubRatingFill = 0.13;

  /// Club rating pill border.
  static const double clubRatingBorder = 0.30;

  /// Floating pass-button fill over profile media.
  static const double passButtonFill = 0.96;

  /// Floating pass-button shadow.
  static const double passButtonShadow = 0.24;

  /// Overlay reaction-control fill over profile photos.
  static const double reactionOverlayFill = 0.94;

  /// Overlay reaction-control border over profile photos.
  static const double reactionOverlayBorder = 0.70;

  /// Active event-type tile soft fill.
  static const double eventTypeTileFill = 0.62;

  /// Active event-type color-cue accent stop.
  static const double eventTypeCueAccentActive = 1.0;

  /// Inactive event-type color-cue accent stop.
  static const double eventTypeCueAccentInactive = 0.92;

  /// Active event-type color-cue deep stop.
  static const double eventTypeCueDeepActive = 0.70;

  /// Inactive event-type color-cue deep stop.
  static const double eventTypeCueDeepInactive = 0.58;

  /// Active event-type color-cue glow.
  static const double eventTypeCueGlowActive = 0.34;

  /// Inactive event-type color-cue glow.
  static const double eventTypeCueGlowInactive = 0.26;

  /// Roster filter unselected tile fill.
  static const double rosterFilterFill = 0.42;

  /// Roster filter unselected tile border.
  static const double rosterFilterBorder = 0.20;

  /// Roster filter selected secondary label.
  static const double rosterFilterSelectedLabel = 0.78;

  /// Activity notification unread border.
  static const double activityUnreadBorder = 0.34;

  /// Activity notification unread fill.
  static const double activityUnreadFill = 0.06;

  /// Activity notification icon-chip default fill.
  static const double activityIconFill = 0.11;

  /// Activity notification icon-chip border.
  static const double activityIconBorder = 0.14;

  /// Disabled/muted affordance inside Explore rows.
  static const double exploreMutedAffordance = 0.32;
}

// ── Strokes ─────────────────────────────────────────────────────────────────

/// Stroke widths that are part of reusable component geometry.
abstract final class CatchStroke {
  static const double hairline = 1.0;
  static const double underline = 1.5;
  static const double selection = 3.0;
  static const double clubMemberSeal = 2.0;
}

// ── Motion ───────────────────────────────────────────────────────────────────

/// Shared motion tokens for hover/tap feedback, standard transitions, and
/// celebratory success moments.
abstract final class CatchMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration micro = Duration(milliseconds: 180);
  static const Duration chatScroll = Duration(milliseconds: 200);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration pageStep = Duration(milliseconds: 280);
  static const Duration calendarScroll = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration afterglowBeatEntry = Duration(milliseconds: 480);
  static const Duration afterglowCountUp = Duration(milliseconds: 600);
  static const Duration arrivalCelebration = Duration(milliseconds: 800);
  static const Duration snackbar = Duration(seconds: 2);
  static const Duration authOtpCooldownTick = Duration(seconds: 1);
  static const Duration authOtpResendCooldown = Duration(seconds: 60);
  static const Duration revealDrop = Duration(milliseconds: 280);
  static const Duration revealSettle = Duration(milliseconds: 170);
  static const Duration revealCinematicTick = Duration(seconds: 1);
  static const Duration revealCinematicClimax = Duration(milliseconds: 1500);
  static const Duration revealCinematicSettle = Duration(milliseconds: 700);
  static const Duration cinematicShort = Duration(seconds: 4);
  static const Duration cinematicMedium = Duration(seconds: 6);
  static const Duration ambientLoop = Duration(seconds: 16);
  static const Duration pulse = Duration(milliseconds: 700);
  static const Duration skeletonShimmer = Duration(milliseconds: 1200);
  static const Duration welcomeReel = Duration(milliseconds: 3000);
  static const Duration welcomeLandingReveal = Duration(milliseconds: 1400);
  static const Duration welcomeNonFocusFade = Duration(milliseconds: 500);
  static const Duration welcomeTextCool = Duration(milliseconds: 700);
  static const Duration welcomeRevealSettle = Duration(milliseconds: 600);
  static const Duration welcomeRevealStart = Duration(milliseconds: 520);
  static const Duration welcomeRevealStagger = Duration(milliseconds: 80);
  static const int welcomeReelSpins = 1;
  static const double welcomeSpinCurvePower = 3.0;
  static const Curve welcomeRevealCurve = Curves.easeOutCubic;

  static const Curve standardCurve = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve easeInCubicCurve = Curves.easeInCubic;
  static const Curve easeInOutCurve = Curves.easeInOut;
  static const Curve easeInOutCubicCurve = Curves.easeInOutCubic;
  static const Curve easeOutBackCurve = Curves.easeOutBack;
  static const Curve easeOutCubicCurve = Curves.easeOutCubic;
  static const Curve easeOutCurve = Curves.easeOut;
  static const Curve elasticOutCurve = Curves.elasticOut;
  static const Curve springCurve = Cubic(0.34, 1.4, 0.64, 1.0);
}

// ── Layout ───────────────────────────────────────────────────────────────────

/// Layout constants for constraint-based sizing.
abstract final class CatchLayout {
  /// Content max-width clamp for large phones / foldables.
  /// Wrap full-bleed page bodies in [ConstrainedBox] with this maxWidth, centered.
  static const double maxContentWidth = 600;

  /// Confirm-dialog max card width from the implementation handoff.
  static const double confirmDialogMaxWidth = 320.0;

  /// Full-screen confirm-dialog inset from the implementation handoff.
  static const double confirmDialogInset = CatchSpacing.s7;

  /// Shared horizontal gutter for detail screens with sliver-native content.
  static const double detailScreenHorizontalPadding = CatchSpacing.s5;

  /// Available content width inside a detail screen's horizontal gutters.
  static double detailScreenContentWidthFor(double width) =>
      (width - (detailScreenHorizontalPadding * 2))
          .clamp(0.0, double.infinity)
          .toDouble();

  /// First content offset after a detail hero or pinned header.
  static const double detailScreenTopPadding = CatchSpacing.s3;

  /// Standard gap between major sections on detail screens.
  static const double detailScreenSectionGap = CatchSpacing.s6;

  /// Standard gap between related cards/content inside one detail section.
  static const double detailScreenContentGap = CatchSpacing.s4;

  /// Space between a section title and its first row/list item.
  static const double detailScreenSectionTitleBottomGap = CatchSpacing.s4;

  /// Space between a compact title and supporting copy inside one section.
  static const double detailScreenSupportingGap = CatchSpacing.s2;

  /// Space between dense rows inside a single detail card.
  static const double detailScreenInlineRowGap = CatchSpacing.micro10;

  /// Bottom breathing room inside sliver-native detail sections.
  static const double detailScreenBottomPadding = CatchSpacing.s6;

  /// Vertical gap between agenda cards that belong to the same day.
  static const double agendaItemGap = CatchSpacing.micro10;

  /// Vertical gap between different agenda day groups.
  static const double agendaGroupGap = CatchSpacing.s6;

  /// Gap between an agenda day label and the first event card.
  static const double agendaDayLabelBottomGap = CatchSpacing.s2;

  /// Default top and bottom insets for standalone agenda lists.
  static const double agendaListTopPadding = CatchSpacing.s1;
  static const double agendaListBottomPadding = detailScreenBottomPadding;

  /// Shared inset for club interaction media on list tiles and detail headers.
  static const double clubInteractionMediaInset = CatchSpacing.s3;
  static const EdgeInsets clubInteractionMediaPadding = EdgeInsets.all(
    clubInteractionMediaInset,
  );

  /// Club detail hero media and caption sizing.
  static const double clubDetailHeroCoverHeightRatio = 0.61;
  static const double clubDetailHeroNoCoverPhoneHeight = 220.0;
  static const double clubDetailHeroNoCoverWideHeight = 164.0;
  static const double clubDetailHeroCoverWideMinHeight = 164.0;
  static const double clubDetailHeroCoverWideMaxHeight = 260.0;
  static const double clubDetailHeroTitleTopPadding = CatchSpacing.s3;
  static const double clubDetailHeroTitleBottomPadding = CatchSpacing.s3;
  static const double clubDetailHeroTitleLocationGap = CatchSpacing.s2;
  static const double clubDetailHeroExpandedTitleSize = 34.0;
  static const double clubDetailHeroExpandedTitleLineHeight = 0.96;
  static const double clubDetailHeroCollapsedTitleSize = 28.0;
  static const double clubDetailHeroCollapsedTitleLineHeight = 0.96;
  static const double clubDetailHeroLocationLineExtent = 24.0;
  static const double clubDetailHeroCaptionSlack = CatchSpacing.s1;
  static const double clubDetailHeroCaptionExtent =
      clubDetailHeroTitleTopPadding +
      (clubDetailHeroExpandedTitleSize *
          clubDetailHeroExpandedTitleLineHeight *
          2) +
      clubDetailHeroTitleLocationGap +
      clubDetailHeroLocationLineExtent +
      clubDetailHeroTitleBottomPadding +
      clubDetailHeroCaptionSlack;
  static double clubDetailHeroLocationTextWidthFor(double captionWidth) =>
      (captionWidth - CatchIcon.md - CatchSpacing.micro6)
          .clamp(0.0, double.infinity)
          .toDouble();

  /// Event detail hero sizing for standard photo/activity headers.
  static const double eventDetailHeroStandardHeightRatio = 0.58;
  static const double eventDetailHeroStandardMinHeight = 220.0;
  static const double eventDetailHeroStandardMaxHeight = 252.0;
  static const double eventDetailHeroStandardWideHeight = 220.0;
  static const double eventDetailHeroTitleBottomInset = CatchSpacing.s5;

  /// Event detail hero sizing for ticket and spotlight presentations.
  static const double eventDetailHeroTicketPhoneHeight = 380.0;
  static const double eventDetailHeroTicketWideHeight = 360.0;
  static const double eventDetailTicketCompactHeightThreshold = 360.0;
  static const double eventDetailTicketVisualCompactRatio = 0.48;
  static const double eventDetailTicketVisualExpandedRatio = 0.62;
  static const double eventDetailTicketVisualMinHeight = 96.0;
  static const double eventDetailTicketVisualMaxHeight = 290.0;
  static const double eventDetailTicketTitleCompactSize = 30.0;
  static const double eventDetailTicketTitleExpandedSize = 42.0;
  static const double eventDetailTicketTitleLineHeight = 0.92;
  // Standard (photo) hero title — condensed poster cut, design-system EventHero.
  static const double eventDetailHeroStandardTitleSize = 32.0;

  static const double catchesProfileBottomPadding = 112.0;
  static const double catchesHubBackgroundIconSize = 156.0;
  static const double catchesHubBackgroundIconRightOffset = -34.0;
  static const double catchesHubBackgroundIconTopOffset = -42.0;
  static const double celebrationViewportVerticalPadding =
      CatchSpacing.s4 + CatchSpacing.s5;
  static const double celebrationPaperTopPadding =
      CatchSpacing.s12 + CatchSpacing.s6;
  static const double celebrationPaperBottomPadding = CatchSpacing.s6;
  static const double celebrationPaperViewportVerticalPadding =
      celebrationPaperTopPadding + celebrationPaperBottomPadding;
  static const double celebrationPaperDetailRowVerticalPadding =
      CatchSpacing.micro14;
  static const double celebrationPaperActionTopGap = CatchSpacing.s6;
  static const double celebrationDetailLabelWidth = 78.0;
  static const double bottomActionScrimHeight = 128.0;
  static const double floatingControlExtent = 48.0;
  static const double selectionBadgeRadius = 14.0;
  static const double badgeMdVerticalPadding =
      CatchSpacing.micro6 + CatchStroke.hairline;
  static const double badgeMdDotExtent =
      CatchSpacing.micro6 + CatchStroke.hairline;
  static const double badgeActionHeight = 33.0;
  static const double badgeActionIconSize = 15.0;
  static const double activityAvatarDefaultSize = 40.0;
  static const double activityAvatarInitialsScale = 0.32;
  static const double activityAvatarRingSpread = 2.0;
  static const double activityAvatarTextureStrokeWidth = 2.0;
  static const double activityAvatarTextureStride = 13.0;
  static const double activityMapPinRestingSize = 26.0;
  static const double activityMapPinSelectedSize = 38.0;
  static const double activityMapPinShadowBlur = 3.0;
  static const double activityMapPinShadowDy = 2.0;
  static const double distanceRingDefaultSize = 170.0;
  static const double distanceRingStrokeWidth = 1.2;
  static const double distanceRingLabelOverhang = 10.0;
  static const double distanceRingLabelHorizontal = 9.0;
  static const double distanceRingLabelFontSize = 8.5;
  static const double activityArtDefaultHeight = 180.0;
  static const double activityArtDefaultRadius = 22.0;
  static const double activityArtTextureStrokeWidth = 2.0;
  static const double activityArtTextureStride = 16.0;
  static const double activityArtGlyphRight = -18.0;
  static const double activityArtGlyphBottom = -24.0;
  static const double activityArtGlyphScale = 0.95;
  static const double statStripVerticalPadding = 13.0;
  static const double statStripLabelFontSize = 9.0;
  static const double fieldRowVerticalPadding = 13.0;
  static const double fieldActionBarWrapBreakpoint = 220.0;
  static const double fieldRowDividerIconInset =
      CatchIcon.control + CatchSpacing.s3;
  static const double searchFieldIconSize = 15.0;
  static const double searchFieldIconGap = 10.0;
  static const double searchFieldClearSize = 32.0;
  static const double searchFieldClearIconSize = 16.0;
  static const double toggleTrackWidth = 46.0;
  static const double toggleTrackHeight = 28.0;
  static const double toggleKnobExtent = 22.0;
  static const double toggleTrackPadding = CatchSpacing.micro3;
  static const double menuRowVerticalPadding = 13.0;
  static const double menuRowGap = 10.0;
  static const double menuRowIconSize = 17.0;
  static const double menuRowCheckSize = 16.0;
  static const double menuRowSublabelSize = 8.5;
  static const double activityChipIconSize = 15.0;
  static const double activityChipIconGap = 7.0;
  static const double buttonLgHeight = CatchSpacing.s12 + CatchSpacing.s2;
  static const double controlCompactMinHeight =
      CatchSpacing.s12 + CatchSpacing.s1;
  static const double controlMdMinHeight = CatchSpacing.s12 + CatchSpacing.s2;
  static const double noticeTitleMessageGap = CatchSpacing.micro2;
  static const double personUnreadBadgeHorizontalPadding =
      CatchSpacing.micro6 + CatchStroke.hairline;
  static const double countPillIconSize = CatchIcon.sm + CatchSpacing.micro2;
  static const double countPillLabelVerticalPadding =
      CatchSpacing.micro10 + CatchStroke.hairline;
  static const double settingsRowVerticalPadding =
      CatchSpacing.s3 + CatchStroke.hairline;
  static const double settingsRowDividerIconInset =
      CatchIcon.row + CatchSpacing.s3;
  static const double settingsRowChevronIconSize = CatchIcon.xs;
  static const double clubProfileImagePickerExtent = 120.0;
  static const double clubCoverThumbnailExtent = 64.0;
  static const double clubPolaroidRadius = CatchSpacing.micro6;
  static const double clubPolaroidMediaRadius = CatchSpacing.micro3;
  static const double clubPolaroidTitleSize = CatchSpacing.s6;
  static const double polaroidBodyReserve = 108.0;
  static const double polaroidBodyReserveWithFooter = 212.0;
  static const double eventTypeTileMaxWidth = 340.0;
  static const double eventTypeTileSingleColumnHeight = 88.0;
  static const double eventTypeTileTwoColumnHeight = 72.0;
  static const double eventTypeIndexRowHeight = 66.0;
  static const double eventTypeIndexDotSize = 12.0;
  static const double eventTypeBrowseBottomPadding = 84.0;
  static const double eventTypeColorCueTopOffset = -30.0;
  static const double eventTypeDisplaySize = 26.0;
  static const double eventTypeColorCueActiveExtent = 102.0;
  static const double eventTypeColorCueInactiveExtent = 92.0;
  static const double eventTypeSkeletonTextWidth = 172.0;
  static const double eventTypeSkeletonCardHeight = 120.0;
  static const double photoSlotDeleteExtent = CatchSpacing.s7;
  static const double photoSlotDeleteControlInset = 34.0;
  static const double reactionControlExtent = CatchSpacing.s11;
  static const double reactionControlIconSize = 21.0;
  static const double profileFallbackArtworkIconSize = 160.0;
  static const double profileFactLabelGutter = 116.0;
  static const double profileReactionPassExtent = 56.0;
  static const double profileCardOverlayTrailingInset = 92.0;
  static const double profileInlineMinimumUnderlineWidth = 28.0;
  static const double passButtonExtent = CatchSpacing.s16;
  static const double clubMemberSealCompactExtent = CatchSpacing.s16;
  static const double clubMemberSealExtent = 70.0;
  static const double countryCodeSelectorWidth = 136.0;
  static const double activityLoadingIndicatorExtent = CatchIcon.md;
  static const double eventSuccessLabStepMarkerExtent = 34.0;
  static const double eventPolicyLabScenarioCardWidth = 220.0;
  static const double rosterFilterTileMinHeight = 56.0;
  // Shared roster board (design-system components/hosting/RosterBoard).
  static const double rosterRowAvatarExtent = 32.0;
  static const double rosterDecideTargetExtent = 32.0;
  static const double rosterHeaderIdentityInset = 42.0;
  static const double chatListAvatarExtent = CatchSpacing.s11;
  static const double chatListTextGap = CatchSpacing.s3;

  /// Left inset for the chat-row hairline divider so it starts past the avatar
  /// and aligns with the text column. Kept in terms of the avatar extent + the
  /// avatar→text gap so the divider can't drift from the row layout.
  static const double chatListDividerInset =
      chatListAvatarExtent + chatListTextGap;
  static const double browseHeaderHeight = 88.0;
  static const double browseHeaderContentHeight = 60.0;
  static const double browseHeaderSearchExtent = 52.0;
  static const double horizontalRailHeight = 92.0;
  static const double horizontalRailDividerHeight = CatchSpacing.s6;
  static const double actionMenuWidth = 192.0;
  static const double actionMenuAlignmentX = -160.0;
  static const double avatarStatusDotExtent = 9.0;
  static const double eventHeroBackdropIconSize = 220.0;
  static const double eventCardBackdropIconSize =
      CatchSpacing.s16 * 2 + CatchSpacing.s12 + CatchSpacing.s1;
  static const double eventThumbnailBackdropIconSize =
      CatchSpacing.s16 * 2 + CatchSpacing.s4;
  static const double eventActivityGlyphExtent =
      CatchSpacing.s12 + CatchSpacing.s2;
  static const double eventActivityGlyphIconSize =
      CatchIcon.lg + CatchSpacing.micro2;
  static const double eventHeroBadgeExtent = 56.0;
  static const double eventHeroBadgeRadius = eventHeroBadgeExtent / 2;
  static const double eventHeroBadgeIconSize = 26.0;
  static const double eventDetailTicketStubBandHeight = 72.0;
  static const double eventDetailHintDotExtent = 7.0;
  static const double eventDetailMapCardHeight = 126.0;
  static const double eventDetailPhotoStripTileHeight = 108.0;
  static const double eventDetailHairlineDividerHeight = 25.0;
  static const double eventDetailItineraryTimeColumnWidth = 50.0;
  static const double eventDetailItineraryRailColumnWidth = 20.0;
  static const double eventDetailItineraryDotExtent = 9.0;
  // JourneySteps (design-system components/events/JourneySteps) — numbered
  // node-rail sequence shared by the first-run dashboard and onboarding.
  static const double dashboardEmptyHeroHeight = 370.0;
  static const double dashboardQuickActionSkeletonHeight = 76.0;
  static const double dashboardRecommendedEventSkeletonHeight = 112.0;
  static const double journeyStepsIndexColumnWidth = 30.0;
  static const double journeyStepsRailColumnWidth = 20.0;
  static const double journeyStepsNodeExtent = 11.0;
  // CrossPathsCard (design-system components/explore/CrossPathsCard).
  static const double crossPathsPolaroidWidth = 76.0;
  static const double crossPathsPolaroidHeight = 92.0;
  static const double crossPathsRailColumnWidth = 104.0;
  static const double crossPathsPhotoVariantWidth = 122.0;
  static const double crossPathsHeartExtent = 34.0;
  static const double crossPathsPolaroidTilt = 0.0349; // 2° in radians
  // CoverStory (design-system components/explore/CoverStory).
  static const double exploreDiscoveryCoverHeight = 316.0;
  static const double coverStoryGhostGlyphSize = 210.0;
  static const double coverStorySearchExtent = 38.0;
  static const double coverStoryGhostRightInset = 34.0;
  static const double coverStoryGhostBottomInset = 14.0;
  // "Your hosts" HostCard (design-system components/events/HostCard).
  static const double eventDetailHostAvatarExtent = 46.0;
  static const double eventDetailHostSealSize = 15.0;
  static const double eventDetailHostNameSize = 16.0;
  static const double eventDetailHostStatValueSize = 17.0;
  static const double eventDetailHostStatLabelSize = 9.0;
  static const double eventDetailConflictMedallionExtent = 52.0;
  static const double eventDetailConflictEventGlyphExtent = 38.0;
  static const double paymentCheckoutBackdropHeight = 230.0;
  static const double paymentCheckoutMedallionExtent = 52.0;
  static const double eventSuccessStageNavExtent = CatchSpacing.s12;
  static const double eventSuccessStageGlyphExtent = 88.0;
  static const double eventSuccessStageGlyphIconSize = CatchSpacing.s10;
  static const double eventSuccessArrivalRingExtent = 140.0;
  static const double eventSuccessArrivalRingInnerPadding = CatchSpacing.micro6;
  static const double eventSuccessBouncyGlowBlur = 22.0;
  static const double eventSuccessPaperBarcodeWidth = 92.0;
  static const double eventSuccessPaperBarcodeHeight = 34.0;
  static const double frameworkErrorMaxWidth = 460.0;
  static const double errorIconExtent = CatchSpacing.s16;
  static const double errorIconSize = 30.0;
  static const double iconButtonSize = CatchSpacing.s11;
  static const double iconButtonNavSize = CatchSpacing.s10;
  static const double iconButtonGlyphScale = 0.44;
  static const double iosPickerHeight = 216.0;
  static const double iosPickerToolbarHeight = 52.0;
  static const double iosPickerTitleSidePadding = 96.0;
  static const double menuItemHeightCompact = CatchSpacing.s11;
  static const double menuItemHeight = CatchSpacing.s12;
  static const double noticeMaxWidth = 520.0;
  static const double noticeIconExtent = CatchSpacing.s9;
  static const double otpDigitHeight = CatchSpacing.s16;
  static const double otpDigitGap = CatchSpacing.micro10;
  static const double otpCaretWidth = 2.0;
  static const double otpCaretHeight = CatchSpacing.s6;
  static const double pageDotSelectedWidth = 22.0;
  static const double pageDotExtent = CatchSpacing.micro6;
  static const double sheetGrabberWidth = CatchSpacing.s10;
  static const double sheetGrabberWideWidth = CatchSpacing.s12;
  static const double sheetGrabberHeight = CatchSpacing.s1;
  static const double sheetGrabberTallHeight = 5.0;
  static const double sheetTopPadding = CatchSpacing.micro10;
  static const double sheetHorizontalPadding = 22.0;
  static const double sheetBottomPadding = 26.0;
  static const double sheetTopRadius = 26.0;
  static const double sheetBottomRadius = 30.0;
  static const double sheetGrabberBottomMargin = CatchSpacing.s4;
  static const double sheetHeaderBodyGap = CatchSpacing.micro18;
  static const double sheetHeaderGap = CatchSpacing.s3;
  static const double sheetGlyphTileSize = CatchSpacing.s11;
  static const double sheetGlyphTileRadius = CatchSpacing.s3;
  static const double sheetGlyphIconSize = 22.0;
  static const double skeletonCardHeight = 120.0;
  static const double skeletonCardCompactHeight = 96.0;
  static const double skeletonTextHeight = CatchIcon.sm;
  static const double skeletonCircleExtent = CatchSpacing.s12;
  static const double skeletonAvatarCompactExtent = 42.0;
  static const double skeletonMediaTileExtent = 52.0;
  static const double skeletonTextMicroWidth = 22.0;
  static const double skeletonTextTinyWidth = CatchSpacing.s3;
  static const double skeletonTextDateWidth = 30.0;
  static const double skeletonTextTimeWidth = 42.0;
  static const double skeletonTextValueWidth = CatchSpacing.s12;
  static const double skeletonTextChipWidth = 54.0;
  static const double skeletonTextStatusWidth = 72.0;
  static const double skeletonTextActionWidth = 76.0;
  static const double skeletonTextMetaLabelWidth = 78.0;
  static const double skeletonTextEyebrowWidth = 86.0;
  static const double skeletonTextLabelWidth = 92.0;
  static const double skeletonTextCompactWidth = 104.0;
  static const double skeletonTextBodyWidth = 112.0;
  static const double skeletonTextPillWidth = 118.0;
  static const double skeletonTextSecondaryWidth = 126.0;
  static const double skeletonTextTertiaryWidth = 128.0;
  static const double skeletonTextRowWidth = 130.0;
  static const double skeletonTextSectionWidth = 136.0;
  static const double skeletonTextBodyWideWidth = 138.0;
  static const double skeletonTextSectionWideWidth = 146.0;
  static const double skeletonTextInlineTitleWidth = 148.0;
  static const double skeletonTextWideWidth = 150.0;
  static const double skeletonTextDetailWidth = 154.0;
  static const double skeletonTextDetailWideWidth = 156.0;
  static const double skeletonTextActionLabelWidth = 168.0;
  static const double skeletonTextHeadlineWidth = 178.0;
  static const double skeletonTextCardTitleWidth = 180.0;
  static const double skeletonTextBodyLongWidth = 188.0;
  static const double skeletonTextLongWidth = 190.0;
  static const double skeletonTextFeatureWidth = 216.0;
  static const double skeletonTextHeroWidth = 220.0;
  static const double skeletonTextHeroWideWidth = 230.0;
  static const double skeletonTextPageTitleWidth = 232.0;
  static const double skeletonTextBannerWidth = 240.0;
  static const double skeletonStatusPillWidth = 82.0;
  static const double startupLogoExtent = 96.0;
  static const double startupIndicatorExtent = CatchSpacing.s7;
  static const double stepHeaderProgressHeight = 2.0;
  static const double statusBarTopPadding = CatchSpacing.micro14;
  static const double statusBarHorizontalPadding = CatchSpacing.s7;
  static const double statusBarBottomPadding = CatchSpacing.micro6;
  static const double statusBarTimeFontSize = 14.0;
  static const double statusBarIconSize = 14.0;
  static const double statusBarIconGap = CatchSpacing.micro6;
  static const double tabDockBlurSigma = 10.0;
  static const double tabDockHorizontalPadding = CatchSpacing.s3;
  static const double tabDockTopPadding = CatchSpacing.micro10;
  static const double tabDockBottomPadding = CatchSpacing.micro18;
  static const double tabDockItemGap = CatchSpacing.s1;
  static const double tabDockIconSize = 22.0;
  static const double tabDockLabelFontSize = 8.5;
  static const double topBarHeight = 56.0;
  static const double topBarLargeHeight = 104.0;
  static const double topBarTabHeight = CatchSpacing.s12;
  static const double topBarCollapsedFadeExtent = 72.0;
  static const double topBarCompactSearchBottomHeight = 68.0;
  static const double topBarTrailingMaxRatio = 0.58;
  static const double exploreSheetPeekSize = 0.11;
  static const double exploreSheetMapSize = 0.70;
  static const double exploreSheetFullSize = 1.0;
  static const double exploreSheetRevealOvershootSize = 0.655;
  static const double exploreHeaderContentHeight = 60.0;
  static const double exploreFilterRailHeight = 66.0;
  static const double exploreErrorSliverHeight = 180.0;
  static const double exploreEventsSkeletonHeight = 160.0;
  static const double exploreTicketRailCardWidth = 336.0;
  // Tracks the card's 16:10 media (width*10/16) + the ticket stub/divider budget,
  // so rail height follows card width and can't drift. (A prior fixed 352 assumed
  // a 136px media and overflowed once the media became aspect-ratio-driven via
  // LayoutBuilder; 216 = divider + the 2-line stub headroom the old rail reserved.)
  static const double exploreTicketRailHeight =
      exploreTicketRailCardWidth * 10 / 16 + 216.0;
  static const double mapPlaceholderPinSize = 42.0;
  static const double eventRecapGridGap = 10.0;
  static const double eventRecapStatInset = 10.0;
  static const double eventActivityStampExtent = 42.0;
  static const double eventActivityStampIconSize = 22.0;
  static const double eventCompactDatePillWidth = 52.0;
  static const double eventCompactDatePillHeight = 58.0;
  static const double eventDateRailWidth = 66.0;
  static const double clubAvatarRailColumnWidth = 76.0;
  static const double clubDirectorySkeletonTitleWidth = 180.0;
  static const double clubDirectorySkeletonSubtitleWidth = 132.0;
  static const double clubDirectorySkeletonShortChipWidth = 72.0;
  static const double clubDirectorySkeletonLongChipWidth = 96.0;
  static const double clubDirectorySkeletonFooterWidth = 140.0;
  static const double clubDirectorySkeletonActionWidth = 70.0;
  static const double recommendationRailGap = 10.0;
  static const double heroSignalChipHorizontalPadding = 11.0;
  static const double heroSignalChipVerticalPadding = 7.0;
  static const double compactDarkPillHorizontalPadding = 11.0;
  static const double compactDarkPillVerticalPadding = 7.0;
  static const double calendarWeekStripVerticalInsetTotal = 16.0;
  static const double calendarMonthGridGapTotal = 30.0;
  static const double welcomeBrandMarkExtent = 52.0;
  static const double welcomeMaxWidth = 430.0;
  static const double welcomeReelRowHeight = 90.0;
  static const double welcomeReelRowHalfHeight = 45.0;
  static const double welcomeReelTop = 50.0;
  static const double welcomeReelHeight = 540.0;
  static const double welcomeReelFocus = 230.0;
  static const double welcomeReelCatchLeft = 24.0;
  static const double welcomeReelCatchLineTopOffset = 14.0;
  static const double welcomeReelCatchFocusTop =
      welcomeReelFocus -
      welcomeReelRowHalfHeight +
      welcomeReelCatchLineTopOffset;
  static const double welcomeReelObjectLeft = 116.0;
  static const double welcomeReelObjectRight = 18.0;
  static const double welcomeReelDimRange =
      welcomeReelRowHeight * CatchOpacity.welcomeReelDimDistanceRows;
  static const double welcomeBodyTop = 340.0;
  static const double welcomeBodyHorizontalPadding = 26.0;
  static const double welcomeButtonsBottom = 30.0;
  static const double welcomeButtonGap = 10.0;
  static const double welcomeCtaApproxHeight = 122.0;
  static const double welcomeMinBodyToCtaGap = 16.0;
  static const double welcomeHeadlineToBodyGap = 66.0;
  static const double welcomeRevealOffsetY = 16.0;
  static const double welcomeVoiceWidth = 78.0;

  static double welcomeReelLandingOffset(int index) =>
      (index * welcomeReelRowHeight) +
      welcomeReelRowHalfHeight -
      welcomeReelFocus;

  static double welcomeReelRowCenter({
    required int rowIndex,
    required double trackOffset,
  }) =>
      (rowIndex * welcomeReelRowHeight) -
      trackOffset +
      welcomeReelRowHalfHeight;

  static bool welcomeReelRowIsFocused(double distance) =>
      distance.abs() < welcomeReelRowHalfHeight;
  static const double eventInfoTileExtent = 44.0;
  static const double strideChartHeight = 84.0;
  static const double calendarStatDividerHeight = 44.0;
  static const double calendarStatDividerHorizontalMargin = 10.0;
  static const double calendarEmptyIconSize = 44.0;
  static const double emptyHeroArtOffset = -40.0;
  static const double emptyHeroArtSize = 200.0;
  static const List<double> emptyHeroCircleRadii = <double>[40.0, 60.0, 80.0];
  static const double appShellCupertinoNavHeight = 50.0;
  static const double appShellNavigationBadgeWidth = 38.0;
  static const double appShellNavigationBadgeHeight = 30.0;
  static const double eventSuccessResetButtonMinWidth = 40.0;
  static const double eventSuccessResetButtonMinHeight = 32.0;
  static const double hostPayoutSetupButtonWidth = 120.0;
  static const double hostOrganizerMetricRowHeight = 78.0;
  static const double hostOrganizerTeamDividerInset = 54.0;
  static const double hostOrganizerTrendChartHeight = 76.0;
  static const double hostPaymentActionSkeletonHeight = 44.0;
  static const double hostChartSkeletonHeight = 132.0;
  static const double hostCreateEventRouteFormSkeletonHeight = 192.0;
  static const double afterglowBeatSlideOffset = 14.0;
  static const double suvbotCircleActionExtent = 34.0;
  static const double suvbotLoadingControlsHeight = 84.0;
  static const double profileHeightStepButtonExtent = 36.0;
  static const double profileSignalChipHorizontalPadding = 10.0;
  static const double profileSignalChipVerticalPadding = 7.0;
  static const double manualQaEditorHeight = 780.0;
  static const double clubAvatarRailHeight = 108.0;
  static const double clubCreateButtonExtent = 64.0;
  static const double attendedEventTileArtExtent = 58.0;
  static const double chatBubbleMaxWidthFraction = 0.78;
  static const double chatBubbleMaxWidth = 520.0;
  static const double chatShareCardWidth = 360.0;
  static const double chatShareCardAspectRatio = 4 / 5;
  static const double chatShareCardPixelRatio = 3.0;
  static const double chatShareCardHeaderIconExtent = 40.0;
  static const int chatShareCardMaxMessages = 3;
  static const double richShareCardWidth = 360.0;
  static const double richShareCardAspectRatio = 4 / 5;
  static const double richShareCardPixelRatio = 3.0;
  static const double richShareCardHeaderIconExtent = 40.0;
  static const int richShareCardMaxTags = 3;
  static const double chatUnreadStripWidth = 4.0;
  static const double chatUnreadPillWidth = CatchSpacing.s6;
  static const double celebrationIconExtent = 86.0;
  static const double questionnaireDotExtent = 28.0;
  static const double eventTicketDividerHeight = 20.0;
  static const double eventTicketNotchRadius = 10.0;
  static const double eventTicketNotchDepth = 8.0;
  static const double hostTargetStepperWidth = 150.0;
  static const double skeletonTextShortWidth = 64.0;
  static const double skeletonTextTitleWidth = 132.0;
  static const double chatNewMatchTileWidth = 64.0;
  static const double chatNewMatchAvatarExtent = 64.0;
  static const double clubFilterDividerHeight = 22.0;
  static const double profileTagPillHorizontalPadding = 11.0;
  static const double profileTagPillVerticalPadding = 7.0;
  static const double profileRunStatHorizontalPadding = 12.0;
  static const double profileRunStatVerticalPadding = 11.0;
  static const double profileInfoChipHorizontalPadding = 10.0;
  static const double profileInfoChipVerticalPadding = 6.0;
  static const double profilePhotoEditorBoundaryMargin = 160.0;
}

// ── Aspect ratios ───────────────────────────────────────────────────────────

/// Named media/tile ratios so repeated visual geometry is owned centrally.
abstract final class CatchAspectRatio {
  static const double square = 1.0;
  static const double wide16x9 = 16 / 9;
  static const double activityCard = 16 / 10;
  static const double standardPhoto = 4 / 3;
  static const double portrait4x5 = 4 / 5;
  static const double portrait3x4 = 3 / 4;
  static const double profileSlotFeedback = 112 / 150;
  static const double eventRecapVibeTile = 0.74;
}

// ── Iconography ──────────────────────────────────────────────────────────────

/// Icon sizing and stroke guidance from the component catalog.
abstract final class CatchIcon {
  static const double badge = CatchSpacing.s3;
  static const double rating = 13.0;
  static const double micro = 11.0;
  static const double sm = 14.0;
  static const double xs = CatchSpacing.s4;
  static const double md = 18.0;
  static const double control = CatchSpacing.s5;
  static const double row = 22.0;
  static const double tile = CatchSpacing.s7;
  static const double hero = CatchSpacing.s9;
  static const double emptyState = 34.0;
  static const double passButton = 34.0;
  static const double avatarLg = 52.0;
  static const double fallbackAvatar = 38.0;
  static const double heroSignalChip = 15.0;
  static const double appShellCupertinoNav = 30.0;
  static const double profileHeightStep = 21.0;
  static const double profileRunStat = 17.0;
  static const double unsavedDot = 8.0;
  static const double profileInfoChip = 13.0;
  static const double forceUpdate = 72.0;
  static const double lg = 24.0;

  static const double strokeSm = 1.6;
  static const double strokeMd = 1.6;
  static const double strokeLg = 1.8;
}

/// Static color roles used by canvas-rendered Google Map pins.
abstract final class CatchMapPinColors {
  static const Color brand = Color(0xFFFF4E1F);
  static const Color brandBorder = Color(0xFFB8350F);
  static const Color brandTint = Color(0xFFFFE2D4);
  static const Color mutedFill = Color(0xFFEFE7DD);
  static const Color mutedInk = Color(0xFF7C6B5A);
  static const Color success = Color(0xFF2F7D45);
  static const Color successBorder = Color(0xFF205A30);
  static const Color shadow = Color.fromRGBO(26, 20, 16, 0.18);
}

abstract final class CatchStaticMapColors {
  static const Color land = Color(0xFF1A2E2A);
  static const Color water = Color(0xFF0F1E2B);
  static const Color arterial = Color(0xFF2F2A24);
}

abstract final class CatchPaceColors {
  static const Color moderateLight = Color(0xFF3A6FD0);
  static const Color moderateDark = Color(0xFF5B8FEA);
}

/// Static club artwork colors.
abstract final class CatchClubColors {
  static const Color compactMemberSealInk = Color(0xFF244646);
}

/// Static photo-grade tints for display-time UGC grading.
abstract final class CatchPhotoGradeColors {
  static const Color lightWarmShadow = Color(0x14C9542F);
  static const Color lightWarmHighlight = Color(0x0FF3C778);
  static const Color darkWarmShadow = Color(0x1FC9542F);
  static const Color darkWarmHighlight = Color(0x14F3C778);
}

abstract final class CatchIconButtonColors {
  static const Color floatingForeground = Color(0xFF16140F);
}

abstract final class CatchWelcomeColors {
  static const Color reelMaskClear = Color(0x00FFFFFF);
  static const Color reelMaskOpaque = Color(0xFFFFFFFF);
}

abstract final class CatchEventSuccessColors {
  static const Color arrivalCelebrationWarm = Color(0xFFFFB36B);
  static const Color arrivalCelebrationHot = Color(0xFFFF6F61);
  static const Color arrivalCelebrationGold = Color(0xFFFFD166);
}

abstract final class CatchCelebrationColors {
  static const Color ink = Color(0xFFFFFFFF);
  static const Color cream = Color(0xFFFFFFFF);
  static const Color actionInk = Color(0xFF24110A);
}
