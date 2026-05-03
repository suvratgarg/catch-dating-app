import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/city_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RunClubsHeader extends ConsumerStatefulWidget {
  const RunClubsHeader({super.key});

  @override
  ConsumerState<RunClubsHeader> createState() => _RunClubsHeaderState();
}

class _RunClubsHeaderState extends ConsumerState<RunClubsHeader> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(runClubSearchQueryProvider),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryAutoSelectFromGps();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final selectedCity = ref.watch(selectedRunClubCityProvider);

    // Keep the text field in sync when the query is reset externally (e.g. city change).
    ref.listen(runClubSearchQueryProvider, (_, query) {
      if (_searchController.text != query) {
        _searchController.text = query;
      }
    });

    ref.listen(deviceLocationProvider, (_, next) {
      next.whenData((_) => _tryAutoSelectFromGps());
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        Sizes.p8,
        CatchSpacing.s5,
        Sizes.p12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Run clubs', style: CatchTextStyles.displayL(context)),
                    gapH4,
                    Text(
                      'Find your people. Catch your person.',
                      style: CatchTextStyles.bodyS(context),
                    ),
                  ],
                ),
              ),
              IconBtn(
                onTap: () => context.pushNamed(Routes.createRunClubScreen.name),
                child: Icon(Icons.add_rounded, size: 20, color: t.ink),
              ),
            ],
          ),
          gapH10,
          Row(
            children: [
              CityPicker(
                selectedCity: selectedCity,
                onSelected: (city) => ref
                    .read(selectedRunClubCityProvider.notifier)
                    .setCity(city),
              ),
              gapW8,
              Expanded(
                child: _SearchField(
                  controller: _searchController,
                  onChanged: (q) =>
                      ref.read(runClubSearchQueryProvider.notifier).setQuery(q),
                  onClear: () =>
                      ref.read(runClubSearchQueryProvider.notifier).clear(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _tryAutoSelectFromGps() {
    final location = ref.read(deviceLocationProvider).asData?.value;
    if (location == null) return;
    final nearest = IndianCity.nearestCity(location);
    if (nearest != null) {
      ref.read(selectedRunClubCityProvider.notifier).autoSelectCity(nearest);
    }
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return CatchTextField(
      label: 'Search clubs',
      showLabel: false,
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      hintText: 'Search clubs',
      size: CatchTextFieldSize.compact,
      shape: CatchTextFieldShape.pill,
      prefixIcon: const Icon(Icons.search_rounded, size: 18),
      suffixIcon: ValueListenableBuilder(
        valueListenable: controller,
        builder: (_, value, _) => value.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 16),
                onPressed: onClear,
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
