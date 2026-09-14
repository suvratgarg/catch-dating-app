/// Disclosure ownership and initial expansion for Field controls.
///
/// Local modes let the field own subsequent taps. Changing between local modes
/// updates its expansion. Controlled modes report requests through onOpenChanged
/// and wait for the caller to supply the next mode. Releasing control preserves
/// the last caller-owned expansion before local interaction resumes.
enum CatchFieldMode {
  localCollapsed,
  localExpanded,
  controlledCollapsed,
  controlledExpanded,
}
