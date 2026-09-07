import 'package:flutter/material.dart';

String catchAvatarInitialsOf(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'[\s\-_]+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) {
    final word = parts.first;
    return word.characters.take(2).toString().toUpperCase();
  }
  return parts
      .take(2)
      .map((part) => part.characters.first)
      .join()
      .toUpperCase();
}
