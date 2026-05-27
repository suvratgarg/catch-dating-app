import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_concept/explore_concept_preview_screen.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: ExploreConceptPreviewApp()));
}

class ExploreConceptPreviewApp extends StatelessWidget {
  const ExploreConceptPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const ExploreConceptPreviewScreen(),
    );
  }
}
