sealed class RunEligibility {
  const RunEligibility();
}

final class Eligible extends RunEligibility {
  const Eligible();
}

final class AlreadySignedUp extends RunEligibility {
  const AlreadySignedUp();
}

final class OnWaitlist extends RunEligibility {
  const OnWaitlist();
}

final class Attended extends RunEligibility {
  const Attended();
}

final class RunPast extends RunEligibility {
  const RunPast();
}

final class RunFull extends RunEligibility {
  const RunFull();
}

/// The user's gender cap for this run has been reached.
final class GenderCapacityReached extends RunEligibility {
  const GenderCapacityReached();
}

final class AgeTooYoung extends RunEligibility {
  const AgeTooYoung(this.minAge);
  final int minAge;
}

final class AgeTooOld extends RunEligibility {
  const AgeTooOld(this.maxAge);
  final int maxAge;
}
