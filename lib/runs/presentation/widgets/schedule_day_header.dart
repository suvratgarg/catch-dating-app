import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class ScheduleDayHeader extends StatelessWidget {
  const ScheduleDayHeader({super.key, required this.day});

  final DateTime day;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(day, DateTime.now());
    final t = CatchTokens.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _weekdays[day.weekday - 1],
          style: CatchTextStyles.labelSm(
            context,
            color: isToday ? t.primary : t.ink2,
          ).copyWith(fontWeight: isToday ? FontWeight.bold : FontWeight.normal),
        ),
        gapH2,
        CircleAvatar(
          radius: 13,
          backgroundColor: isToday ? t.primary : Colors.transparent,
          child: Text(
            '${day.day}',
            style: CatchTextStyles.labelMd(
              context,
              color: isToday ? t.primaryInk : t.ink,
            ).copyWith(fontWeight: isToday ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      ],
    );
  }
}
