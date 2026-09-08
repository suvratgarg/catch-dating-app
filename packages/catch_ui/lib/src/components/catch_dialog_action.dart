/// A caller-labeled dialog choice and its typed navigation result.
class CatchDialogAction<T> {
  const CatchDialogAction({
    required this.label,
    required this.value,
    this.isDefault = false,
    this.isDestructive = false,
  });

  final String label;
  final T value;
  final bool isDefault;
  final bool isDestructive;
}
