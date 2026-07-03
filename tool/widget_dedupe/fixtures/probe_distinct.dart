// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/widgets.dart';

class ProbeDistinct extends StatelessWidget {
  const ProbeDistinct({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {},
          child: Row(
            children: [Text('$index'), const Spacer(), const Placeholder()],
          ),
        );
      },
    );
  }
}
