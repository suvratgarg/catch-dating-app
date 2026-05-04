# Email Draft: Converting if-chains to switch expressions

## Why

Two locations had if-chains that were better expressed as switch:

### chat_screen.dart — string dispatch
```dart
if (value == 'profile') { ... }
else if (value == 'report') { ... }
else if (value == 'block') { ... }
```
A switch statement on the same string values is more readable and the compiler
can optimize it into a jump table. This also makes it obvious if a new menu
item is added without a handler (the `default` case makes the intention
explicit).

### payment_repository.dart — type dispatch
```dart
if (error is AppException) return error;
if (error is FirebaseFunctionsException) return PaymentFailedException(...);
return PaymentFailedException(error.toString());
```
This is a sealed-class-style dispatch on the error type, which is exactly
what Dart 3's switch expressions with pattern matching are designed for.

## What changed

### chat_screen.dart
```dart
switch (value) {
  case 'profile':
    context.pushNamed(...);
  case 'report':
    _reportUser(...);
  case 'block':
    _confirmBlock(...);
  default:
}
```

### payment_repository.dart
```dart
return switch (error) {
  AppException e => e,
  FirebaseFunctionsException e =>
    PaymentFailedException(e.message ?? fallbackMessage),
  _ => PaymentFailedException(error.toString()),
};
```

The `switch` on types is exhaustive — if a new error subtype is added, the
compiler catches it at the switch (the `_` wildcard handles unexpected types).
