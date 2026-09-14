/// Save status shared by the trailing lane, commit bar and control lock.
/// Saving disables disclosure choices and commit actions; direct input edit
/// permissions remain caller-owned through the input configuration.
enum CatchFieldStatus { idle, saving, saved }
