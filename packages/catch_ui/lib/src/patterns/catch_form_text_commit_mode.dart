/// Commit contract for text rows in one `CatchFormRowList`.
///
/// A form section owns this policy so sibling text rows cannot accidentally
/// mix interaction models. Explicit confirmation is the default for new form
/// sections; [onBlur] remains available for an existing surface that has not
/// yet migrated its product behavior.
enum CatchFormTextCommitMode { explicit, onBlur }
