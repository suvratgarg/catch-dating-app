import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Opaque upstream identity for one user-selected local contact. Scope and
/// actor are included so separate address books/weddings never match through
/// phone numbers, names or a raw platform identifier. This grants no rights.
String phoneContactReferenceId({
  required String accountId,
  required String programId,
  required String localContactId,
}) => sha256
    .convert(
      utf8.encode(
        jsonEncode([
          'catch_phone_contact_v1',
          accountId,
          programId,
          localContactId,
        ]),
      ),
    )
    .toString();
