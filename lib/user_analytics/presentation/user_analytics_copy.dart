import 'package:catch_dating_app/user_analytics/data/user_analytics_repository.dart';

class UserAnalyticsTipCopy {
  const UserAnalyticsTipCopy({required this.title, required this.body});

  final String title;
  final String body;
}

abstract final class UserAnalyticsCopy {
  static const sectionTitle = 'Profile insights';
  static const loadingLabel = 'Loading profile insights';
  static const emptyTitle = 'Insights are warming up';
  static const emptyBody =
      'You will see trends here after Catch has enough event and profile activity.';
  static const trendTitle = 'Trend';
  static const tipsTitle = 'Suggestions';
  static const dataQualityTitle = 'Data coverage';
  static const partialBadge = 'Partial';
  static const missingBadge = 'Missing';

  static const rangeLabels = {
    UserAnalyticsRangePreset.sevenDays: '7D',
    UserAnalyticsRangePreset.thirtyDays: '30D',
    UserAnalyticsRangePreset.ninetyDays: '90D',
    UserAnalyticsRangePreset.month: 'MONTH',
  };

  static const metricLabels = {
    'profileViews': 'Profile views',
    'caughtYou': 'Caught you',
    'mutualCatches': 'Mutual catches',
    'chatsStarted': 'Chats started',
    'eventsAttended': 'Events attended',
    'followThroughRate': 'Follow-through',
  };

  static const metricCaptions = {
    'profileViews': 'Post-event profile attention.',
    'caughtYou': 'People who showed interest.',
    'mutualCatches': 'Matches where interest was mutual.',
    'chatsStarted': 'Conversations that opened after matching.',
    'eventsAttended': 'Events you attended.',
    'followThroughRate': 'Chats started from mutual catches.',
  };

  static const trendMetricLabels = {
    'profileViews': 'Views',
    'caughtYou': 'Interest',
    'mutualCatches': 'Matches',
    'chatsStarted': 'Chats',
    'eventsAttended': 'Attended',
  };

  static const tipCopy = {
    'profileAnalyticsGrowing': UserAnalyticsTipCopy(
      title: 'Keep building signal',
      body: 'Insights get sharper after more post-event profile views.',
    ),
    'refreshProfilePrompts': UserAnalyticsTipCopy(
      title: 'Tune your profile',
      body:
          'A fresh prompt or first photo can make post-event interest easier to read.',
    ),
    'startFirstChat': UserAnalyticsTipCopy(
      title: 'Open the loop',
      body:
          'A short message after a mutual catch is the clearest follow-through signal.',
    ),
    'showUpToEvents': UserAnalyticsTipCopy(
      title: 'Show up in person',
      body: 'The strongest profile trends start after attended events.',
    ),
    'keepShowingUp': UserAnalyticsTipCopy(
      title: 'Keep showing up',
      body: 'Repeated event attendance gives Catch better connection signal.',
    ),
  };

  static String metricLabel(String id, {required String fallback}) =>
      metricLabels[id] ?? fallback;

  static String? metricCaption(String id, {String? fallback}) =>
      metricCaptions[id] ?? fallback;

  static String trendMetricLabel(String id) => trendMetricLabels[id] ?? id;

  static UserAnalyticsTipCopy tip(String copyKey) =>
      tipCopy[copyKey] ?? tipCopy['profileAnalyticsGrowing']!;
}
