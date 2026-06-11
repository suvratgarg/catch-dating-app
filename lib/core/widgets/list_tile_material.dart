import 'package:flutter/material.dart';

class ListTileMaterial extends StatelessWidget {
  const ListTileMaterial({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(type: MaterialType.transparency, child: child);
  }
}
