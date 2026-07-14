import type {DataMode} from "../../../shared/types/adminTypes";
import {useOverviewController} from "../controllers/useOverviewController";
import {
  OverviewScreen,
  type OverviewQueueDestination,
} from "./OverviewScreen";

export function OverviewRouteScreen({
  adminRoles,
  isSessionReady,
  mode,
  onError,
  onNotice,
  onOpenQueue,
}: {
  adminRoles: string[];
  isSessionReady: boolean;
  mode: DataMode;
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
  onOpenQueue: (destination: OverviewQueueDestination) => void;
}) {
  const controller = useOverviewController({
    adminRoles,
    isSessionReady,
    mode,
    onError,
    onNotice,
  });

  return (
    <OverviewScreen
      analyticsClubId={controller.analyticsClubId}
      analyticsEndDate={controller.analyticsEndDate}
      analyticsError={controller.analyticsError}
      analyticsEventId={controller.analyticsEventId}
      analyticsGranularity={controller.analyticsGranularity}
      analyticsLoadedAt={controller.analyticsLoadedAt}
      analyticsRangePreset={controller.analyticsRangePreset}
      analyticsStartDate={controller.analyticsStartDate}
      canLoadAnalytics={controller.canLoadAnalytics}
      hostAnalytics={controller.hostAnalytics}
      isLoading={controller.isLoading}
      isAnalyticsLoading={controller.isAnalyticsLoading}
      isOverviewLoading={controller.isOverviewLoading}
      overview={controller.overview}
      overviewError={controller.overviewError}
      overviewLoadedAt={controller.overviewLoadedAt}
      onAnalyticsClubIdChange={controller.setAnalyticsClubId}
      onAnalyticsEndDateChange={controller.setAnalyticsEndDate}
      onAnalyticsEventIdChange={controller.setAnalyticsEventId}
      onAnalyticsGranularityChange={controller.setAnalyticsGranularity}
      onAnalyticsRangePresetChange={controller.setAnalyticsRangePreset}
      onAnalyticsStartDateChange={controller.setAnalyticsStartDate}
      onClearAnalyticsScope={controller.clearAnalyticsScope}
      onOpenQueue={onOpenQueue}
      onRefresh={() => void controller.refresh()}
      onRefreshAnalytics={() => void controller.refreshAnalytics()}
      onRefreshOverview={() => void controller.refreshOverview()}
    />
  );
}
