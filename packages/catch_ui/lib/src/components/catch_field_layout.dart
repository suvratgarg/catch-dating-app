part of 'catch_field.dart';

/// Closed, passive row content. A layout cannot own input, focus or geometry.
///
/// Field supplies the activation and section supplies the available perimeter.
/// Features format domain facts before passing them to these layouts.
@immutable
sealed class CatchFieldLayout {
  const CatchFieldLayout();

  String get _subject;
  double get _leadingInset;
  Widget? _leading(BuildContext context);
  Widget _body(BuildContext context);
}

/// A subject with readable facts and optional supporting explanation.
final class CatchRecordLayout extends CatchFieldLayout {
  const CatchRecordLayout({
    required this.title,
    required this.icon,
    this.color,
    this.metadata,
    this.facts = const [],
    this.description,
  });

  final String title;
  final IconData icon;
  final Color? color;
  final String? metadata;
  final List<String> facts;
  final String? description;

  @override
  String get _subject => title;
  @override
  double get _leadingInset =>
      CatchRecordTokens.avatarExtent + CatchFieldRow.leadingSlotGap;

  @override
  Widget _leading(BuildContext context) {
    final tone = color ?? CatchTokens.of(context).ink2;
    return CatchSurface(
      width: CatchRecordTokens.avatarExtent,
      height: CatchRecordTokens.avatarExtent,
      radius: CatchRadius.pill,
      backgroundColor: tone.withValues(alpha: CatchOpacity.subtleFill),
      child: Icon(icon, size: CatchIcon.md, color: tone),
    );
  }

  @override
  Widget _body(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: CatchTextStyles.recordTitle(context)),
      if (metadata case final text? when text.isNotEmpty) ...[
        const SizedBox(height: CatchRecordTokens.titleGap),
        Text(text, style: CatchTextStyles.recordContext(context)),
      ],
      for (final fact in facts.where((text) => text.isNotEmpty)) ...[
        const SizedBox(height: CatchRecordTokens.titleGap),
        Text(fact, style: CatchTextStyles.supporting(context)),
      ],
      if (description case final text? when text.isNotEmpty) ...[
        const SizedBox(height: CatchRecordTokens.bodyGap),
        Text(text, style: CatchTextStyles.recordBody(context)),
      ],
    ],
  );
}

/// A passive business-status annotation, separate from a Field action.
@immutable
final class CatchRowBadge {
  const CatchRowBadge({required this.label, required this.tone});
  final String label;
  final CatchBadgeTone tone;
}

/// Person identity and relationship facts, with natural-height text.
final class CatchPersonLayout extends CatchFieldLayout {
  const CatchPersonLayout({
    required this.name,
    this.imageUrl,
    this.avatarShape = CatchAvatarVariant.circle,
    this.supportingText,
    this.context,
    this.badges = const [],
  });

  final String name;
  final String? imageUrl;
  final CatchAvatarVariant avatarShape;
  final String? supportingText;
  final String? context;
  final List<CatchRowBadge> badges;

  @override
  String get _subject => name;
  @override
  double get _leadingInset =>
      CatchRecordTokens.avatarExtent + CatchFieldRow.leadingSlotGap;

  @override
  Widget _leading(BuildContext context) => CatchAvatar(
    size: CatchRecordTokens.avatarExtent,
    name: name,
    imageUrl: imageUrl,
    variant: avatarShape,
  );

  @override
  Widget _body(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(name, style: CatchTextStyles.name(context)),
      if (supportingText case final text? when text.isNotEmpty) ...[
        const SizedBox(height: CatchRecordTokens.titleGap),
        Text(text, style: CatchTextStyles.supporting(context)),
      ],
      if (this.context case final text? when text.isNotEmpty) ...[
        const SizedBox(height: CatchRecordTokens.titleGap),
        Text(text, style: CatchTextStyles.recordContext(context)),
      ],
      if (badges.isNotEmpty) ...[
        const SizedBox(height: CatchRecordTokens.bodyGap),
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            for (final badge in badges)
              CatchBadge.status(label: badge.label, tone: badge.tone),
          ],
        ),
      ],
    ],
  );
}

/// Conversation anatomy is explicit even before its first message.
final class CatchConversationLayout extends CatchFieldLayout {
  const CatchConversationLayout({
    required this.name,
    required this.preview,
    this.imageUrl,
    this.timestamp,
    this.context,
    this.activityLabel,
    this.activitySemantics,
  }) : assert(activityLabel == null || activitySemantics != null);

  final String name;
  final String preview;
  final String? imageUrl;
  final String? timestamp;
  final String? context;

  /// Caller-resolved exact, partial or unavailable activity (for example 2+).
  final String? activityLabel;
  final String? activitySemantics;

  @override
  String get _subject => name;
  @override
  double get _leadingInset =>
      CatchRecordTokens.avatarExtent + CatchFieldRow.leadingSlotGap;

  @override
  Widget _leading(BuildContext context) => CatchAvatar(
    size: CatchRecordTokens.avatarExtent,
    name: name,
    imageUrl: imageUrl,
  );

  @override
  Widget _body(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(name, style: CatchTextStyles.name(context)),
      const SizedBox(height: CatchRecordTokens.titleGap),
      Text(preview, style: CatchTextStyles.chatPreview(context)),
      if (this.context case final text? when text.isNotEmpty) ...[
        const SizedBox(height: CatchRecordTokens.titleGap),
        Text(text, style: CatchTextStyles.recordContext(context)),
      ],
      if (timestamp != null || activityLabel != null) ...[
        const SizedBox(height: CatchRecordTokens.titleGap),
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            if (timestamp case final text?)
              Text(text, style: CatchTextStyles.recordContext(context)),
            if (activityLabel case final text?)
              Semantics(
                label: activitySemantics,
                excludeSemantics: true,
                child: Text(
                  text,
                  style: CatchTextStyles.supportingStrong(context),
                ),
              ),
          ],
        ),
      ],
    ],
  );
}
