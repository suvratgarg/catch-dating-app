part of 'catch_field.dart';

/// A separate, labelled target owned by Field, never by its passive content.
@immutable
sealed class CatchFieldSecondaryAction {
  const CatchFieldSecondaryAction();

  static CatchFieldSecondaryAction menu<T>({
    required String label,
    required List<CatchActionMenuItem<T>> items,
    required ValueChanged<T> onSelected,
  }) => _CatchFieldMenuAction<T>(label, items, onSelected);

  static CatchFieldSecondaryAction command({
    required String label,
    required IconData icon,
    required VoidCallback onActivate,
  }) => _CatchFieldCommandAction(label, icon, onActivate);

  Widget _build(BuildContext context);
}

final class _CatchFieldMenuAction<T> extends CatchFieldSecondaryAction {
  const _CatchFieldMenuAction(this.label, this.items, this.onSelected);
  final String label;
  final List<CatchActionMenuItem<T>> items;
  final ValueChanged<T> onSelected;

  @override
  Widget _build(BuildContext context) => CatchActionMenu<T>(
    tooltip: label,
    items: items,
    onSelected: onSelected,
    variant: CatchIconActionVariant.plain,
  );
}

final class _CatchFieldCommandAction extends CatchFieldSecondaryAction {
  const _CatchFieldCommandAction(this.label, this.icon, this.onActivate);
  final String label;
  final IconData icon;
  final VoidCallback onActivate;

  @override
  Widget _build(BuildContext context) => CatchIconAction(
    tooltip: label,
    variant: CatchIconActionVariant.plain,
    onPressed: onActivate,
    child: Icon(icon),
  );
}
