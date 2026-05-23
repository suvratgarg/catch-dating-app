import 'package:flutter_riverpod/flutter_riverpod.dart';

const eventSuccessCompanionClockInterval = Duration(seconds: 30);

final eventSuccessCompanionClockProvider = StreamProvider.autoDispose<DateTime>(
  (ref) async* {
    yield DateTime.now();
    yield* Stream<DateTime>.periodic(
      eventSuccessCompanionClockInterval,
      (_) => DateTime.now(),
    );
  },
);
