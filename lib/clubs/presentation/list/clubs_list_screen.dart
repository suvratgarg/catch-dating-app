import 'package:catch_dating_app/clubs/presentation/list/widgets/city_picker.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_filter_rail.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_list.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_sliver_header.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/presentation/event_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ClubsBrowseMode { list, map }

class ClubsListScreen extends ConsumerStatefulWidget {
  const ClubsListScreen({super.key, this.enableEventMapNetworkTiles = true});

  final bool enableEventMapNetworkTiles;

  @override
  ConsumerState<ClubsListScreen> createState() => _ClubsListScreenState();
}

class _ClubsListScreenState extends ConsumerState<ClubsListScreen> {
  ClubsBrowseMode _browseMode = ClubsBrowseMode.list;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    if (_browseMode == ClubsBrowseMode.map) {
      return Scaffold(
        backgroundColor: t.bg,
        body: EventMapView(
          enableNetworkTiles: widget.enableEventMapNetworkTiles,
          overlay: _ClubsEventMapOverlay(onShowList: _showList),
        ),
      );
    }

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                ...ClubsSliverHeader().buildSlivers(context),
                const ClubsFilterRail(),
                const ClubsList(),
              ],
            ),
            Positioned(
              right: CatchSpacing.s5,
              bottom: CatchSpacing.s5,
              child: _BrowseModeButton(
                label: 'Map',
                icon: Icons.map_outlined,
                onPressed: _showMap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMap() {
    setState(() => _browseMode = ClubsBrowseMode.map);
  }

  void _showList() {
    setState(() => _browseMode = ClubsBrowseMode.list);
  }
}

class _ClubsEventMapOverlay extends StatelessWidget {
  const _ClubsEventMapOverlay({required this.onShowList});

  final VoidCallback onShowList;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Positioned(
      top: CatchSpacing.s4,
      left: CatchSpacing.s4,
      right: CatchSpacing.s4,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const CityPicker(),
            gapW12,
            Expanded(
              child: CatchSurface(
                padding: const EdgeInsets.symmetric(
                  horizontal: CatchSpacing.s4,
                  vertical: CatchSpacing.s3,
                ),
                borderColor: t.line,
                backgroundColor: t.surface.withValues(alpha: 0.94),
                radius: CatchRadius.md,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event map',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.labelM(context),
                    ),
                    gapH2,
                    Text(
                      'Pins show upcoming runs',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
            ),
            gapW12,
            _BrowseModeButton(
              label: 'List',
              icon: Icons.view_agenda_outlined,
              onPressed: onShowList,
            ),
          ],
        ),
      ),
    );
  }
}

class _BrowseModeButton extends StatelessWidget {
  const _BrowseModeButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CatchButton(
      label: label,
      onPressed: onPressed,
      variant: CatchButtonVariant.light,
      icon: Icon(icon),
    );
  }
}
