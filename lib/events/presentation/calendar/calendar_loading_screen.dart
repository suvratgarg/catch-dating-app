part of 'calendar_screen.dart';

class CalendarLoadingScreen extends StatelessWidget {
  const CalendarLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _CalendarDateHeaderDelegate(
            height: _calendarDateHeaderHeightFor(context, expanded: false),
            child: const CalendarDateHeaderSkeleton(),
          ),
        ),
        const SliverToBoxAdapter(child: CalendarStatsHeaderSkeleton()),
        const EventAgendaSliverSkeleton(count: 3),
      ],
    );
  }
}
