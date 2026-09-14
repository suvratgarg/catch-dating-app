/// Field-label presentation independent of validation or selection requirements.
///
/// Hidden labels retain their accessible name. Optional wording can accompany
/// either visual placement; only text-entry fields support hiding their label.
enum CatchFieldLabelTextMode {
  visible,
  optional,
  hidden,
  hiddenOptional;

  bool get showsLabel => this == visible || this == optional;
  bool get isOptional => this == optional || this == hiddenOptional;
}
