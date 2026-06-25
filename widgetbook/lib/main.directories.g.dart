// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:widgetbook/widgetbook.dart' as _widgetbook;
import 'package:widgetbook_workspace/catches/catches_use_cases.dart'
    as _widgetbook_workspace_catches_catches_use_cases;
import 'package:widgetbook_workspace/clubs/club_detail_use_cases.dart'
    as _widgetbook_workspace_clubs_club_detail_use_cases;
import 'package:widgetbook_workspace/consumer/p2_consumer_use_cases.dart'
    as _widgetbook_workspace_consumer_p2_consumer_use_cases;
import 'package:widgetbook_workspace/dashboard/dashboard_use_cases.dart'
    as _widgetbook_workspace_dashboard_dashboard_use_cases;
import 'package:widgetbook_workspace/event_success/event_success_companion_use_cases.dart'
    as _widgetbook_workspace_event_success_event_success_companion_use_cases;
import 'package:widgetbook_workspace/events/event_detail_use_cases.dart'
    as _widgetbook_workspace_events_event_detail_use_cases;
import 'package:widgetbook_workspace/explore/explore_use_cases.dart'
    as _widgetbook_workspace_explore_explore_use_cases;
import 'package:widgetbook_workspace/foundation/foundation_token_use_cases.dart'
    as _widgetbook_workspace_foundation_foundation_token_use_cases;
import 'package:widgetbook_workspace/hosts/host_operations_use_cases.dart'
    as _widgetbook_workspace_hosts_host_operations_use_cases;
import 'package:widgetbook_workspace/matches/matches_chat_use_cases.dart'
    as _widgetbook_workspace_matches_matches_chat_use_cases;
import 'package:widgetbook_workspace/primitives/core_catalog_use_cases.dart'
    as _widgetbook_workspace_primitives_core_catalog_use_cases;
import 'package:widgetbook_workspace/primitives/primitive_contract_use_cases.dart'
    as _widgetbook_workspace_primitives_primitive_contract_use_cases;
import 'package:widgetbook_workspace/profiles/profile_use_cases.dart'
    as _widgetbook_workspace_profiles_profile_use_cases;
import 'package:widgetbook_workspace/utility/p3_utility_use_cases.dart'
    as _widgetbook_workspace_utility_p3_utility_use_cases;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookCategory(
    name: 'Club Detail',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Screen',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ClubDetailScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Screen states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubDetailScreenStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Sections',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchClubDock',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Dock states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .catchClubDockStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ClubDetailBody',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Body composition',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubDetailBodyComposition,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ClubHeroAppBar',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Hero states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubHeroAppBarStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ClubReviewsSection',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Review states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubReviewsSectionStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ClubScheduleSection',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Schedule states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubScheduleSectionStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'StatsStrip',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Stats states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubStatsStripStates,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Core catalog',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Actions',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchTextButton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchTextButtonCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Activity',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchActivityArt',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchActivityArtCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchActivityAvatar',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchActivityAvatarCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchActivityChip',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchActivityChipCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchActivityMapPin',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchActivityMapPinCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchDistanceRing',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchDistanceRingCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Data display',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchMetaDotRow',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchMetaDotRowCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchMetricStrip',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchMetricStripCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchStatColumn',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchStatColumnCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchStatStrip',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchStatStripCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Device frames',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchStatusBar',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchStatusBarCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchViewportCurveFrame',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchViewportCurveFrameCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Event cards',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchEventSpotlightCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchEventSpotlightCardCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchEventTicketCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchEventTicketCardCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventActivityBackdrop',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .eventActivityBackdropCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventActivityStamp',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .eventVisualAtomsCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventTicketPerforatedDivider',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .eventTicketSurfaceCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Event detail',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'EventDetailCta',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .eventDetailBookingDockCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventDetailHeroAppBar',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .eventDetailHeroCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventDetailHintList',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .eventDetailHintListCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventDetailHostCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .eventDetailHostCardCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventDetailItinerary',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .eventDetailItineraryCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventDetailMapCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .eventDetailMapCardCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventDetailMechanismList',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .eventDetailMechanismListCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventDetailPhotoStrip',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .eventDetailPhotoStripCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventDetailTicketStubBand',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .eventDetailTicketStubCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Feedback',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchCallout',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchCalloutCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchEmptyState',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchEmptyStateCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchErrorBanner',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchErrorBannerCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchErrorState',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchErrorStateCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchFrameworkErrorView',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchFrameworkErrorViewCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchMutationErrorListener',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchMutationErrorListenerCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchNotice',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchNoticeCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchNoticeHost',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchNoticeHostCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Host operations',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchRosterRow',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchRosterRowCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchRosterTable',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchRosterTableCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchRosterTiles',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchRosterTilesCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Icon atoms',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchIconTile',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchIconTileCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Inputs',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchCodeInput',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchCodeInputCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchControlShell',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchControlShellCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchDropdownField<Labelled>',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchDropdownFieldCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchFieldGroup',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchFieldGroupCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchFormFieldLabel',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchFormFieldLabelCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchNumberStepper',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchNumberStepperCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchOtpCodeField',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchOtpCodeFieldCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchRangeSlider',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchRangeSliderCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchSelectMenu',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchSelectMenuCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Layout',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ResponsiveBuilder',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .responsiveBuilderCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Loading',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchAsyncScreenLoading',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchAsyncScreenLoadingCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchAsyncSliverLoading',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchAsyncSliverLoadingCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchAsyncValueSliver',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchAsyncValueSliverCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchAsyncValueView',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchAsyncValueViewCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchLoadingIndicator',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchLoadingIndicatorCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchSkeleton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchSkeletonCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchSkeletonList',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchSkeletonListCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchStartupLoadingScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchStartupLoadingScreenCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Media',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchDetailHeroBackdrop',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchDetailHeroBackdropCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchEventThumbnail',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchEventThumbnailCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchGradedImage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchGradedImageCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Menus',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchActionMenu',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchActionMenuCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchMenu',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchMenuCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Moments',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchCelebrationScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchCelebrationScreenCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Navigation',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchPageDots',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchPageDotsCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchSliverHeader',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchSliverHeaderCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchStepHeader',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchStepHeaderCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchStepProgress',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchStepProgressCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchTabDock',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchTabDockCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchTopBarMenuAction',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchTopBarActionsCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchTopBarTabBar',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchTopBarTabBarCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'People',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchPersonAvatar',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchPersonAvatarCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchPersonAvatarStack',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchPersonAvatarStackCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchPersonRow',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchPersonRowCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Profile',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ProfileInfoTile',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .profileInfoTileCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Rows',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchDetailRow',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchDetailRowCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchInfoGroup',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchInfoGroupCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchInfoRow',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchInfoRowCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchSettingsRow',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchSettingsRowCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Search',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchBrowseHeader',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchBrowseHeaderCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchExpandingSearch',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchExpandingSearchCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchSearchField',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchSearchFieldCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Sections',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchDaySectionHeader',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchDaySectionHeaderCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchDesignSection',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchSectionLayoutCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchHorizontalRail',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchHorizontalRailCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchJourneySteps',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchJourneyStepsCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchScreenBody',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchScreenBodyCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchSectionCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchSectionCardCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchSectionHeader',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchSectionHeaderCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchSectionStack',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchSectionStackCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchVerticalSection',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchVerticalSectionCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Selection',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchChipField<Labelled>',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchChipFieldCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchOptionGroup',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchOptionGroupCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchSelectChip',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchSelectChipCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchToggle',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchToggleCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Sheets and footers',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchBottomCta',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchBottomCtaCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchBottomDock',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchBottomDockCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchBottomSheetGrabber',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchBottomSheetGrabberCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchBottomSheetScaffold',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchBottomSheetScaffoldCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchDraggableSheetShell',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchDraggableSheetShellCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchShareCardSheet',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchShareCardSheetCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Status extras',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchBadge',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchStatusExtrasCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchPrivacyBadge',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchPrivacyBadgeCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Surfaces',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchPanel',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchPanelCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchSoftBand',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchSoftBandCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Typography',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchKicker',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchKickerCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchMonoLabel',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchMonoLabelCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchSectionLabel',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchSectionLabelCatalogStates,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Core primitives',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Actions',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchButton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchButtonContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchIconButton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchIconButtonContractStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Host operations',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchRosterRow',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchRosterRowContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchRosterTable',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchRosterTableContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchRosterTiles',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchRosterTilesContractStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Inputs',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchField',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchFieldContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchFieldGroup',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchFieldGroupContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchTextField',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchTextFieldContractStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Navigation',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchTopBar',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchTopBarContractStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Sections',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchJourneySteps',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchJourneyStepsContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchScreenBody',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchScreenBodyContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchSectionStack',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchSectionStackContractStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Selection',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchChip',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchChipContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchOptionCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchOptionCardContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchSegmentedControl',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchSegmentedControlContractStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Status',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchBadge',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchBadgeContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchPrivacyBadge',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchPrivacyBadgeContractStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Surfaces',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchSurface',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchSurfaceContractStates,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Event Detail',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Screen states',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'EventDetailScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Screen states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventDetailScreenStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Sections',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'EventBookingDock',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'BookingDock states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventDetailBookingDockStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventDetailBody',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Prompt states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventDetailPromptBodyStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventDetailOverviewSection',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Overview states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventDetailOverviewSectionStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventDetailSocialSection',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Social states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventDetailSocialSectionStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventReviewsSection',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Review states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventDetailReviewsSectionStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Sheets',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'BookingConflictSheet',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Booking conflict sheet states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventDetailBookingConflictSheetStates,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Explore',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Screen',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ExploreScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Screen states',
                builder: _widgetbook_workspace_explore_explore_use_cases
                    .exploreScreenStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Sections',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchCountPill',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Map launcher states',
                builder: _widgetbook_workspace_explore_explore_use_cases
                    .exploreMapLauncherStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchCoverStory',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'CoverStory states',
                builder: _widgetbook_workspace_explore_explore_use_cases
                    .catchCoverStoryStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchCrossPathsCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'CrossPathsCard states',
                builder: _widgetbook_workspace_explore_explore_use_cases
                    .catchCrossPathsCardStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ExploreBrowseHeaderContent',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Chrome states',
                builder: _widgetbook_workspace_explore_explore_use_cases
                    .exploreBrowseHeaderContentStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ExploreEmptyState',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Empty states',
                builder: _widgetbook_workspace_explore_explore_use_cases
                    .exploreEmptyStateStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ExploreEventTypeBrowseGrid',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Activity states',
                builder: _widgetbook_workspace_explore_explore_use_cases
                    .exploreEventTypeBrowseGridStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ExploreEventsSection',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Feed states',
                builder: _widgetbook_workspace_explore_explore_use_cases
                    .exploreEventsSectionStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ExploreFilterRail',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Filter states',
                builder: _widgetbook_workspace_explore_explore_use_cases
                    .exploreFilterRailStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ExploreMapScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Map route states',
                builder: _widgetbook_workspace_explore_explore_use_cases
                    .exploreMapRouteStates,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Foundation tokens',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Core',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'FoundationBrandTokens',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Wordmark',
                builder:
                    _widgetbook_workspace_foundation_foundation_token_use_cases
                        .foundationBrandTokens,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'FoundationColorTokens',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Color roles',
                builder:
                    _widgetbook_workspace_foundation_foundation_token_use_cases
                        .foundationColorRoles,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'FoundationDataPhotoTokens',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Data pairs and photo grade',
                builder:
                    _widgetbook_workspace_foundation_foundation_token_use_cases
                        .foundationDataPhotoTokens,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'FoundationIconMediaTokens',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Icons and media geometry',
                builder:
                    _widgetbook_workspace_foundation_foundation_token_use_cases
                        .foundationIconMediaTokens,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'FoundationShapeTokens',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Radius elevation opacity',
                builder:
                    _widgetbook_workspace_foundation_foundation_token_use_cases
                        .foundationShapeTokens,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'FoundationSpacingTokens',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Spacing and layout',
                builder:
                    _widgetbook_workspace_foundation_foundation_token_use_cases
                        .foundationSpacingAndLayout,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'FoundationStrokeMotionTokens',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Stroke and motion',
                builder:
                    _widgetbook_workspace_foundation_foundation_token_use_cases
                        .foundationStrokeMotionTokens,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'FoundationTypographyTokens',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Typography roles',
                builder:
                    _widgetbook_workspace_foundation_foundation_token_use_cases
                        .foundationTypographyRoles,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'P1 product surfaces',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Catches',
        children: [
          _widgetbook.WidgetbookFolder(
            name: 'Sections',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'AttendedEventTile',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Tile states',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .attendedEventTileStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CatchesBottomScrim',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Bottom scrim states',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .catchesBottomScrimStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CatchesHubContent',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Hub composition',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .catchesHubContentStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CatchesHubEmptyState',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Empty states',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .catchesHubEmptyStateStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CatchesHubHeader',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Header states',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .catchesHubHeaderStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CatchesIntroCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Intro card states',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .catchesIntroCardStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CatchesPassButton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Pass button states',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .catchesPassButtonStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CatchesProfileReview',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Deck composition',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .catchesProfileReviewStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CatchesTopOverlay',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Top overlay states',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .catchesTopOverlayStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ProfileReactionControls',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Reaction control states',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .catchesReactionControlStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ProfileSurface',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Catches profile states',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .catchesProfileSurfaceStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'SwipeEmptyState',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Deck empty states',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .swipeEmptyStateStates,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'SwipeHubScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Hub route states',
                builder: _widgetbook_workspace_catches_catches_use_cases
                    .catchesHubRouteStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'SwipeScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Event deck route states',
                builder: _widgetbook_workspace_catches_catches_use_cases
                    .catchesEventDeckRouteStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Dashboard home',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'DashboardScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Screen states',
                builder: _widgetbook_workspace_dashboard_dashboard_use_cases
                    .dashboardScreenStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Dashboard primitives',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'DashboardStrideSection',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Review states',
                builder: _widgetbook_workspace_dashboard_dashboard_use_cases
                    .dashboardStrideSectionReviewStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'QuickActions',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Review states',
                builder: _widgetbook_workspace_dashboard_dashboard_use_cases
                    .dashboardQuickActionsReviewStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'RecommendCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Review states',
                builder: _widgetbook_workspace_dashboard_dashboard_use_cases
                    .dashboardRecommendCardReviewStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Event Success companion',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'EventSuccessCompanionRouteScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Route states',
                builder:
                    _widgetbook_workspace_event_success_event_success_companion_use_cases
                        .eventSuccessCompanionRouteStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventSuccessCompanionScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Screen states',
                builder:
                    _widgetbook_workspace_event_success_event_success_companion_use_cases
                        .eventSuccessCompanionScreenStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Host operations',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ClubDetailScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Public preview states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .hostClubDetailPublicPreviewStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EditHostedEventRouteScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Route and section states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .hostEditEventRouteAndFormStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'HostClubsScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Route states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .hostClubsRouteStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'HostCreateClubScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Route and wizard states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .hostCreateClubRouteAndWizardStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'HostCreateEventRouteScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Route and wizard states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .hostCreateEventRouteAndWizardStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'HostEditClubRouteScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Route and mode states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .hostEditClubRouteAndModeStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'HostEventManageRouteScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Route and section states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .hostEventManageRouteAndSectionStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'HostOperationsHomeScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Route states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .hostHomeRouteStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'Sections',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'HostEventRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Event row states',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostHomeEventRowStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostEventsClubCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Event section states',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostHomeEventSectionStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostMetaRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Meta row states',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostHomeMetaRowStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostOperationsTopBar',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Top bar states',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostOperationsTopBarStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostTeamAddHostSheet',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Add host sheet states',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostTeamAddHostSheetStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostTeamHostActionDialog',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Host action confirmation dialogs',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostTeamHostActionDialogStates,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Matches and chat',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ChatScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Host chat states',
                builder: _widgetbook_workspace_matches_matches_chat_use_cases
                    .hostChatRouteStates,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Route states',
                builder: _widgetbook_workspace_matches_matches_chat_use_cases
                    .matchChatRouteStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ChatsListScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Consumer route states',
                builder: _widgetbook_workspace_matches_matches_chat_use_cases
                    .matchesListConsumerRouteStates,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Host inbox states',
                builder: _widgetbook_workspace_matches_matches_chat_use_cases
                    .matchesListHostInboxStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'Primitives',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'ChatEventContextHeader',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Primitive states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .chatEventContextHeaderPrimitiveStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ChatInputBar',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Primitive states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .chatInputBarPrimitiveStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ChatListTile',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Primitive states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .chatListTilePrimitiveStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ChatTopBar',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Primitive states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .chatTopBarPrimitiveStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'MessageBubble',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Primitive states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .messageBubblePrimitiveStates,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Profiles',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ProfileScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Self route states',
                builder: _widgetbook_workspace_profiles_profile_use_cases
                    .profileScreenSelfRouteStates,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Self section states',
                builder: _widgetbook_workspace_profiles_profile_use_cases
                    .profileScreenSelfSectionStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PublicProfileScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Route states',
                builder: _widgetbook_workspace_profiles_profile_use_cases
                    .publicProfileRouteStates,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Safety action states',
                builder: _widgetbook_workspace_profiles_profile_use_cases
                    .publicProfileSafetyActionStates,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'P2 consumer surfaces',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Filters',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'FiltersContent',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Content states',
                builder: _widgetbook_workspace_consumer_p2_consumer_use_cases
                    .filtersContentStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'FiltersScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Route states',
                builder: _widgetbook_workspace_consumer_p2_consumer_use_cases
                    .filtersRouteStates,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'P2 host surfaces',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Host profile',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'HostProfileFields',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Field states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .hostProfileFieldStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'HostProfileForm',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Form states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .hostProfileFormStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'HostProfileMissingState',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Missing states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .hostProfileMissingStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'HostProfileScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Route states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .hostProfileRouteStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Host settings',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'HostAccountScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Route states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .hostSettingsRouteStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'HostSettingsClubsSection',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Clubs states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .hostSettingsClubsStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'HostSettingsProfileSection',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Profile summary states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .hostSettingsProfileSummaryStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'HostSettingsTabRail',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Tab states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .hostSettingsTabStates,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'P3 utility surfaces',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Event location map',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'EventLocationMapRouteScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Route states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .eventLocationMapRouteStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventLocationMapScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Map states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .eventLocationMapScreenStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Notifications',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ActivityScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Screen states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .activityScreenStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ActivitySection',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Section states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .activitySectionStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'NotificationRow',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Row states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .notificationRowStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Payment history',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'PaymentHistoryScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Screen states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .paymentHistoryScreenStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PaymentReceiptSheet',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Receipt states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .paymentReceiptSheetStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Reviews history',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ReviewsHistoryScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Screen states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .reviewsHistoryScreenStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'WriteReviewSheet',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Sheet states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .writeReviewSheetStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Settings',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchConfirmDialog',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Dialog states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .settingsDangerDialogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'SettingsScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Mutation states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .settingsMutationStates,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Screen states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .settingsScreenStates,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
