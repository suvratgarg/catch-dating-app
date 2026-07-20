import 'package:catch_dating_app/clubs/domain/club.dart';

/// Canonical app-domain name for the organization that owns events.
///
/// The typedef keeps released `Club` call sites source-compatible while new
/// code uses organizer-first language. `Club` is now a value of
/// [OrganizerType], not the parent entity stored by Firestore.
typedef Organizer = Club;
typedef OrganizerLifecycleStatus = ClubLifecycleStatus;
typedef OrganizerAppVisibility = ClubAppVisibility;
typedef OrganizerManagerProfile = ClubHostProfile;
typedef OrganizerManagerRole = ClubHostRole;
