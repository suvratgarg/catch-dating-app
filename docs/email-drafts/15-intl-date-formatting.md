# Email Draft: Replacing manual date/weekday arrays with intl DateFormat

## Why

`RunFormatters` had three hardcoded arrays (`_monthsShort`, `_weekdaysShort`,
`_weekdaysLong`) and manual index lookups to format dates. `run.dart` had a
duplicate weekday array in the `Run.title` getter. `intl` was already a
project dependency but wasn't being used for these simple formatting tasks.

## What changed

### run_formatters.dart — Before
```dart
static const _monthsShort = ['Jan','Feb','Mar','Apr','May','Jun',
                              'Jul','Aug','Sep','Oct','Nov','Dec'];
static const _weekdaysShort = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
static const _weekdaysLong = ['Monday','Tuesday','Wednesday',...];

static String shortMonth(DateTime dt) => _monthsShort[dt.month - 1];
static String shortWeekday(DateTime dt) => _weekdaysShort[dt.weekday - 1];
static String longWeekday(DateTime dt) => _weekdaysLong[dt.weekday - 1];
static String time(DateTime dt) =>
    '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
```

### run_formatters.dart — After
```dart
import 'package:intl/intl.dart';

static final _month = DateFormat('MMM');
static final _weekdayShort = DateFormat('E');
static final _weekdayLong = DateFormat('EEEE');
static final _time = DateFormat('HH:mm');

static String shortMonth(DateTime dt) => _month.format(dt);
static String shortWeekday(DateTime dt) => _weekdayShort.format(dt);
static String longWeekday(DateTime dt) => _weekdayLong.format(dt);
static String time(DateTime dt) => _time.format(dt);
```

### run.dart — Before
```dart
const weekdays = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
final weekday = weekdays[startTime.weekday - 1];
```

### run.dart — After
```dart
final weekday = DateFormat('EEEE').format(startTime);
```

## Key decisions

**Static `DateFormat` instances, not local.** `DateFormat` construction is
expensive (it compiles the pattern internally). We create 5 static `final`
instances and reuse them across all calls. This avoids recompiling the same
patterns on every `time()` or `shortWeekday()` call.

**Public API preserved.** The method signatures didn't change — callers are
unaffected. This is a pure internal refactor.

**`intl` was already a dependency** (used for `flutter_localizations`). No
new package needed.
