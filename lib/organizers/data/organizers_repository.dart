import 'package:catch_dating_app/clubs/data/clubs_repository.dart';

/// Canonical repository name. The compatibility typedef lets existing
/// provider overrides survive while all persistence now targets organizers.
typedef OrganizersRepository = ClubsRepository;
