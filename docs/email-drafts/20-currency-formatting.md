# Email Draft: Consolidating duplicated currency formatting

## Why

Two files implemented identical paise-to-rupees formatting logic:

`RunFormatters.priceInPaise` — the canonical version used by run detail screens:
```dart
static String priceInPaise(int paise) {
  final rupees = paise / 100;
  return rupees == rupees.roundToDouble()
      ? '₹${rupees.round()}'
      : '₹${rupees.toStringAsFixed(2)}';
}
```

`PaymentHistoryScreen._formattedAmount` — an identical private copy:
```dart
String _formattedAmount(Payment payment) {
  final rupees = payment.amount / 100;
  return rupees == rupees.roundToDouble()
      ? '₹${rupees.round()}'
      : '₹${rupees.toStringAsFixed(2)}';
}
```

Same integer-display logic (whole rupees shown without decimals, fractional
rupees with 2 decimal places). If the formatting convention ever changes
(e.g., always show 2 decimals, add thousands separator), having two copies
means they'd inevitably drift apart.

## What changed

`PaymentHistoryScreen._formattedAmount` removed. Call sites replaced with
`RunFormatters.priceInPaise(payment.amount)`.

The `intl` package's `NumberFormat.currency()` was considered but not used
because the custom logic (whole rupees = no decimals, fractional = 2 decimals)
is a deliberate UX choice that `NumberFormat.currency()` doesn't replicate
without additional configuration.
