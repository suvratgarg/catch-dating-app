import 'package:catch_dating_app/programs/data/program_create_journal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  const values = ProgramCreateJournalValues(
    title: 'Kapoor–Shah Wedding',
    kind: 'wedding',
    timezone: 'Asia/Kolkata',
    startsAtMillis: 1791158400000,
    endsAtMillis: 1791417600000,
  );

  test('draft, submitted command and receipt survive a new journal', () async {
    const journal = ProgramCreateJournal();
    const entry = ProgramCreateJournalEntry(
      accountId: 'account-1',
      organizerId: 'organizer-1',
      requestId: 'program-request-0001',
      values: values,
      submittedValues: values,
      programId: 'program-1',
    );

    await journal.save(entry);
    final recovered = await const ProgramCreateJournal().load(
      accountId: 'account-1',
      organizerId: 'organizer-1',
    );

    expect(recovered, isNotNull);
    expect(recovered!.requestId, entry.requestId);
    expect(recovered.programId, entry.programId);
    expect(recovered.submittedValues!.title, values.title);
    expect(recovered.submittedValues!.startsAtMillis, values.startsAtMillis);
  });

  test(
    'account and organizer scopes cannot read or clear each other',
    () async {
      const journal = ProgramCreateJournal();
      const first = ProgramCreateJournalEntry(
        accountId: 'account-1',
        organizerId: 'organizer-1',
        requestId: 'program-request-0001',
        values: values,
      );
      const second = ProgramCreateJournalEntry(
        accountId: 'account-1',
        organizerId: 'organizer-2',
        requestId: 'program-request-0002',
        values: values,
      );
      await journal.save(first);
      await journal.save(second);

      await journal.clear(
        accountId: first.accountId,
        organizerId: first.organizerId,
        requestId: second.requestId,
      );
      expect(
        await journal.load(
          accountId: first.accountId,
          organizerId: first.organizerId,
        ),
        isNotNull,
      );
      await journal.clear(
        accountId: first.accountId,
        organizerId: first.organizerId,
        requestId: first.requestId,
      );
      expect(
        await journal.load(
          accountId: first.accountId,
          organizerId: first.organizerId,
        ),
        isNull,
      );
      expect(
        await journal.load(
          accountId: second.accountId,
          organizerId: second.organizerId,
        ),
        isNotNull,
      );
    },
  );
}
