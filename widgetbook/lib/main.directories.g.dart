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
import 'package:widgetbook_workspace/event_success/event_success_strict_coverage_use_cases.dart'
    as _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases;
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
import 'package:widgetbook_workspace/onboarding/onboarding_use_cases.dart'
    as _widgetbook_workspace_onboarding_onboarding_use_cases;
import 'package:widgetbook_workspace/primitives/core_catalog_use_cases.dart'
    as _widgetbook_workspace_primitives_core_catalog_use_cases;
import 'package:widgetbook_workspace/primitives/primitive_contract_use_cases.dart'
    as _widgetbook_workspace_primitives_primitive_contract_use_cases;
import 'package:widgetbook_workspace/profiles/profile_use_cases.dart'
    as _widgetbook_workspace_profiles_profile_use_cases;
import 'package:widgetbook_workspace/shell/app_shell_use_cases.dart'
    as _widgetbook_workspace_shell_app_shell_use_cases;
import 'package:widgetbook_workspace/user_analytics/user_analytics_use_cases.dart'
    as _widgetbook_workspace_user_analytics_user_analytics_use_cases;
import 'package:widgetbook_workspace/utility/p3_utility_use_cases.dart'
    as _widgetbook_workspace_utility_p3_utility_use_cases;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookCategory(
    name: 'App shell',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'AppShell',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Guest shell',
            builder: _widgetbook_workspace_shell_app_shell_use_cases
                .appShellGuestState,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'AppShellNavigationBadge',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Navigation badge',
            builder: _widgetbook_workspace_shell_app_shell_use_cases
                .appShellNavigationBadgeState,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'AppShellNavigationBar',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Navigation bar',
            builder: _widgetbook_workspace_shell_app_shell_use_cases
                .appShellNavigationBarState,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'GuestAuthCtaBar',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Guest CTA',
            builder: _widgetbook_workspace_shell_app_shell_use_cases
                .guestAuthCtaBarState,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'HostAppShell',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Host shell',
            builder: _widgetbook_workspace_shell_app_shell_use_cases
                .hostAppShellGuestState,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Club Detail',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Cards',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ClubShareCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Share card states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubShareCardStates,
              ),
            ],
          ),
        ],
      ),
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
            name: 'ClubContactSection',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contact section states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubContactSectionStates,
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
            name: 'ClubDetailLoadingBody',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Loading body states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubDetailLoadingBodyStates,
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
            name: 'ClubHostRow',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Host row states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubHostRowStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ClubHostSection',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Host section states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubHostSectionStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ClubMembershipDock',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Provider dock states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubMembershipDockStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ClubPhotoStrip',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Photo strip states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubPhotoStripStates,
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
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Club Discovery',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Atoms',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ClubHostAvatar',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Host avatar states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubHostAvatarStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ClubHostIdentityLine',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Host identity states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubHostIdentityLineStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ClubHostRoleBadge',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Role badge states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubHostRoleBadgeStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ClubMemberSeal',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Member seal states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubMemberSealStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ClubRatingPill',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Rating pill states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubRatingPillStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ClubTagWrap',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Tag wrap states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubTagWrapStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Cards',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchPolaroid',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Polaroid states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .catchPolaroidStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ClubListTile',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'List tile states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubListTileStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ClubPolaroidArtwork',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Artwork states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubPolaroidArtworkStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Sections',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ClubAvatarRail',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Avatar rail states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubAvatarRailStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ClubDiscoverList',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Discover list states',
                builder: _widgetbook_workspace_clubs_club_detail_use_cases
                    .clubDiscoverListStates,
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
            name: 'CatchActivityMapPin',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchActivityMapPinCatalogStates,
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
            name: 'CatchStatColumn',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchStatColumnCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Event cards',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchEventCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchEventCardCatalogStates,
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
            name: 'EventHeroSurface',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .eventHeroSurfaceCatalogStates,
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
            name: 'CatchErrorScaffold',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchErrorScaffoldCatalogStates,
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
            name: 'CatchInlineErrorState',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchInlineErrorStateCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchInlineMessageSurface',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchInlineMessageSurfaceCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchMutationErrorBanner',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchMutationErrorBannerCatalogStates,
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
            name: 'CatchMutationErrorListeners',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchMutationErrorListenersCatalogStates,
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
          _widgetbook.WidgetbookComponent(
            name: 'CatchSliverErrorState',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchSliverErrorStateCatalogStates,
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
            name: 'CatchOtpCodeField',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchOtpCodeFieldCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Layout',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchFormStepBody',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchFormStepBodyCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchPageBody',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchPageBodyCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchSliverPageBody',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchSliverPageBodyCatalogStates,
              ),
            ],
          ),
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
        name: 'Motion',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchTicketHero',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchTicketHeroCatalogStates,
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
            name: 'CatchTopBarIconAction',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchTopBarIconActionCatalogStates,
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
          _widgetbook.WidgetbookComponent(
            name: 'CatchTopBarTextAction',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchTopBarTextActionCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'People',
        children: [
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
            name: 'CatchSelectChip',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Catalog states',
                builder: _widgetbook_workspace_primitives_core_catalog_use_cases
                    .catchSelectChipCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Sheets and footers',
        children: [
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
        name: 'Typography',
        children: [
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
            name: 'CatchCountPill',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchCountPillContractStates,
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
        name: 'Activity',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchActivityArt',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchActivityArtContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchActivityChip',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchActivityChipContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchActivityMapPin',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchActivityMapPinContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchDistanceRing',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchDistanceRingContractStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Data display',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchMetricStrip',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchMetricStripContractStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Device chrome',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchStatusBar',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchStatusBarContractStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Dialogs',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchConfirmDialog',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchConfirmDialogContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchFormDialog',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchFormDialogContractStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Feedback',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchEmptyState',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchEmptyStateContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchErrorBanner',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchErrorBannerContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchErrorIcon',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchErrorIconContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchErrorState',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchErrorStateContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchNotice',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchNoticeContractStates,
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
        name: 'Icon atoms',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchIconTile',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchIconTileContractStates,
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
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchCodeInputContractStates,
              ),
            ],
          ),
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
            name: 'CatchNumberStepper',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchNumberStepperContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchRangeSlider',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchRangeSliderContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchSearchField',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchSearchFieldContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchToggle',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchToggleContractStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Loading',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchSkeleton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchLoadingContractStates,
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
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchDetailHeroBackdropContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchGradedImage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchGradedImageContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchNetworkImage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchNetworkImageContractStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Navigation',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchCollapsedSliverTitle',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchCollapsedSliverTitleContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchPageDots',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchPageDotsContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchStepHeader',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchStepHeaderContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchTabDock',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchTabDockContractStates,
              ),
            ],
          ),
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
        name: 'People',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchPersonAvatar',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchPersonAvatarContractStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Product composites',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchBottomDock',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchBottomDockContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchClubDock',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchClubDockContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchCoverStory',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchCoverStoryContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchCrossPathsCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchCrossPathsCardContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchEventCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchEventCardContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchPersonRow',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchPersonRowChatPreviewContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'NotificationRow',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .notificationRowContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'QuickActions',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .quickActionsContractStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Sections',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchDetailSliverSectionList',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchDetailSliverSectionListContractStates,
              ),
            ],
          ),
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
            name: 'CatchSection',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchSectionContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchSectionList',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchSectionListContractStates,
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
            name: 'CatchOptionGroup',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchOptionGroupContractStates,
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
        name: 'Sheets and footers',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchBottomSheetScaffold',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchSheetContractStates,
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
            name: 'CatchCornerSash',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchCornerSashContractStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CatchIconBadge',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchIconBadgeContractStates,
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
          _widgetbook.WidgetbookComponent(
            name: 'CatchStatusDot',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchStatusDotContractStates,
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
      _widgetbook.WidgetbookFolder(
        name: 'Typography',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CatchKicker',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contract states',
                builder:
                    _widgetbook_workspace_primitives_primitive_contract_use_cases
                        .catchTypographyContractStates,
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
        name: 'Booking Dock',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'AttendedLeading',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Attended leading',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .attendedLeadingState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'BookedLeading',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Booked leading',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .bookedLeadingState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PriceLeading',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Price leading',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .priceLeadingState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'WaitlistOfferLeading',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Waitlist offer leading',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .waitlistOfferLeadingState,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Cards',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'EventShareCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Share card states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventShareCardStates,
              ),
            ],
          ),
        ],
      ),
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
        name: 'Screens',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'EventCheckInCelebrationScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Check-in confirmation',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventCheckInCelebrationScreenState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventJoinedCelebrationScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Joined confirmation',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventJoinedCelebrationScreenState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ReviewsHistoryScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Review history states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .reviewsHistoryScreenStates,
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
            name: 'EventCompanionEntry',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Companion entry states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventDetailCompanionEntryStates,
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
            name: 'EventDetailHostsSection',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Host section states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventDetailHostSectionStates,
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
            name: 'EventDetailPolicySummary',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Policy summary states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventDetailPolicySummaryStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventDetailPolicySummaryLine',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Policy summary line',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventDetailPolicySummaryLineState,
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
            name: 'EventHypeAvatarStack',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Hype avatars',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventHypeAvatarStackState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventPhotoHeader',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Event photo header',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventPhotoHeaderState,
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
          _widgetbook.WidgetbookComponent(
            name: 'EventStatsGrid',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Event stats',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventStatsGridState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'RequirementsRow',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Requirements',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .requirementsRowState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'SavedEventsAgendaSliver',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Agenda sliver states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .savedEventsAgendaSliverStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'SavedEventsClubNamesErrorSliver',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Club names error sliver',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .savedEventsClubNamesErrorSliverState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'SavedEventsError',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Route error',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .savedEventsErrorState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'SavedEventsHeaderSliver',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Header sliver',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .savedEventsHeaderSliverState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'WhoIsGoing',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Who\'s going states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .whoIsGoingStates,
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
          _widgetbook.WidgetbookComponent(
            name: 'BookingConflictEventRow',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Booking conflict event row states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventDetailBookingConflictEventRowStates,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Events',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Calendar',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'EventDateMarker',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Date marker states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventDateMarkerStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'WeekMarker',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Week marker states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventWeekMarkerStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'MonthMarker',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Month marker states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventMonthMarkerStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Lists',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'EventAgendaList',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Agenda list',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventAgendaListState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventAgendaSliverList',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Agenda sliver list',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventAgendaSliverListState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'AgendaDayGroup',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Agenda day group',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventAgendaDayGroupState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventAgendaSliverSkeleton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Agenda skeleton',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventAgendaSliverSkeletonState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventAgendaTileSkeleton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Agenda tile skeleton',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventAgendaTileSkeletonState,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Map',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'EventLocationMapLoadingBody',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Location loading',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventLocationMapLoadingBodyState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventMapLoadingBody',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Map loading',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventMapLoadingBodyState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventMapView',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Map view states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventMapViewStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventPinsMap',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Map placeholder',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventPinsMapState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'MapOverlayControls',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Overlay controls',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .mapOverlayControlsState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'MapPinTile',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Pin tile states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .mapPinTileStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Screens',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'LocationPickerScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Picker states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .locationPickerScreenStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'SavedEventsScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Saved states',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .savedEventsScreenStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Tiles',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'EventActionCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Action card',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventActionCardState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventActionCardHeader',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Action card header',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventActionCardHeaderState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventActionCardActions',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Action card actions',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventActionCardActionsState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventAgendaTile',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Agenda tile',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventAgendaTileState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventClockMark',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Visual atom clock',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventClockMarkState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventCompactRow',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Compact row',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventCompactRowState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventCompactDatePill',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Compact date pill',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventCompactDatePillState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventDateRailCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Date rail card',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventDateRailCardState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventStatusPill',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Visual atom status',
                builder: _widgetbook_workspace_events_event_detail_use_cases
                    .eventStatusPillState,
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
        name: 'Controls',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ExploreCityPicker',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'City picker states',
                builder: _widgetbook_workspace_explore_explore_use_cases
                    .exploreCityPickerStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ExploreClearAction',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Clear action states',
                builder: _widgetbook_workspace_explore_explore_use_cases
                    .exploreClearActionStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ExploreFilterSheet',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Filter sheet states',
                builder: _widgetbook_workspace_explore_explore_use_cases
                    .exploreFilterSheetStates,
              ),
            ],
          ),
        ],
      ),
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
            name: 'ExploreBody',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Body sliver states',
                builder: _widgetbook_workspace_explore_explore_use_cases
                    .exploreBodyStates,
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
            name: 'ExploreDiscoveryCoverHeader',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Cover header states',
                builder: _widgetbook_workspace_explore_explore_use_cases
                    .exploreDiscoveryCoverHeaderStates,
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
            name: 'ExploreEventsEmptySliver',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Feed empty sliver states',
                builder: _widgetbook_workspace_explore_explore_use_cases
                    .exploreEventsEmptySliverStates,
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
            name: 'ExploreList',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'List sliver states',
                builder: _widgetbook_workspace_explore_explore_use_cases
                    .exploreListStates,
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
          _widgetbook.WidgetbookComponent(
            name: 'ExploreMapSheetLead',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Map sheet lead states',
                builder: _widgetbook_workspace_explore_explore_use_cases
                    .exploreMapSheetLeadStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ExplorePeekRailContent',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Peek rail states',
                builder: _widgetbook_workspace_explore_explore_use_cases
                    .explorePeekRailContentStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ExploreScreenEmptyState',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Route empty states',
                builder: _widgetbook_workspace_explore_explore_use_cases
                    .exploreScreenEmptyStateStates,
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
          _widgetbook.WidgetbookComponent(
            name: 'EventRecapScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Event recap route states',
                builder: _widgetbook_workspace_catches_catches_use_cases
                    .eventRecapScreenRouteStates,
              ),
            ],
          ),
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
                name: 'CatchProfileView',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Raw profile view states',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .catchProfileViewStates,
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
                name: 'CatchesProfileReviewSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Review skeleton states',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .catchesProfileReviewSkeletonStates,
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
                name: 'EventRecapLoadingBody',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Loading composition',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .eventRecapLoadingBodyStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventRecapReadyBody',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Ready body states',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .eventRecapReadyBodyStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'FiltersContentSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Filters loading composition',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .filtersContentSkeletonStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'FiltersSection',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Filter section states',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .filtersSectionStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'FiltersValue',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Filter value states',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .filtersValueStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ProfileInfoChip',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Profile info chip states',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .profileInfoChipStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ProfileReactionCommentSheet',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Reaction comment sheet states',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .profileReactionCommentSheetStates,
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
                name: 'ProfileSurfaceSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Profile skeleton states',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .profileSurfaceSkeletonStates,
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
              _widgetbook.WidgetbookComponent(
                name: 'VibeGrid',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Vibe grid states',
                    builder: _widgetbook_workspace_catches_catches_use_cases
                        .eventRecapVibeGridStates,
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
        name: 'Dashboard activity',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ActivitySectionSkeleton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Skeleton states',
                builder: _widgetbook_workspace_dashboard_dashboard_use_cases
                    .dashboardActivitySectionSkeletonReview,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ActivitySignedOutState',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Signed-out state',
                builder: _widgetbook_workspace_dashboard_dashboard_use_cases
                    .dashboardActivitySignedOutStateReview,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'NotificationDayGroups',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Grouped rows',
                builder: _widgetbook_workspace_dashboard_dashboard_use_cases
                    .dashboardNotificationDayGroupsReview,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Dashboard home',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'DashboardEmptySliverBody',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Empty home sliver',
                builder: _widgetbook_workspace_dashboard_dashboard_use_cases
                    .dashboardEmptySliverBodyReview,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'DashboardFull',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Full home',
                builder: _widgetbook_workspace_dashboard_dashboard_use_cases
                    .dashboardFullReview,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'DashboardFullSliverBody',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Full sliver body',
                builder: _widgetbook_workspace_dashboard_dashboard_use_cases
                    .dashboardFullSliverBodyReview,
              ),
            ],
          ),
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
          _widgetbook.WidgetbookComponent(
            name: 'EmptyHeroCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Hero states',
                builder: _widgetbook_workspace_dashboard_dashboard_use_cases
                    .dashboardEmptyHeroCardReviewStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventFocusRail',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Rail states',
                builder: _widgetbook_workspace_dashboard_dashboard_use_cases
                    .dashboardEventFocusRailReviewStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'Recommendations',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Recommendation rail',
                builder: _widgetbook_workspace_dashboard_dashboard_use_cases
                    .dashboardRecommendationsReview,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Dashboard primitives',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'DashboardNotificationBellButton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Bell states',
                builder: _widgetbook_workspace_dashboard_dashboard_use_cases
                    .dashboardNotificationBellButtonReviewStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'DashboardQuickActionTile',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Tile states',
                builder: _widgetbook_workspace_dashboard_dashboard_use_cases
                    .dashboardQuickActionTileReviewStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'DashboardSectionStateCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Review states',
                builder: _widgetbook_workspace_dashboard_dashboard_use_cases
                    .dashboardSectionStateCardReviewStates,
              ),
            ],
          ),
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
            name: 'RecommendCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Review states',
                builder: _widgetbook_workspace_dashboard_dashboard_use_cases
                    .dashboardRecommendCardReviewStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'StrideBarColumn',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Bar states',
                builder: _widgetbook_workspace_dashboard_dashboard_use_cases
                    .dashboardStrideBarColumnReviewStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'StrideCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Card states',
                builder: _widgetbook_workspace_dashboard_dashboard_use_cases
                    .dashboardStrideCardReviewStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Event Success companion',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'EventSuccessCompanionLoadingBody',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Loading body',
                builder:
                    _widgetbook_workspace_event_success_event_success_companion_use_cases
                        .eventSuccessCompanionLoadingBodyState,
              ),
            ],
          ),
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
          _widgetbook.WidgetbookComponent(
            name: 'EventSuccessFeedbackForm',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Feedback form',
                builder:
                    _widgetbook_workspace_event_success_event_success_companion_use_cases
                        .eventSuccessFeedbackFormStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Event Success strict coverage',
        children: [
          _widgetbook.WidgetbookFolder(
            name: 'Companion folded states',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'AfterglowBeatGrid',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'AfterglowBeatGrid',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictAfterglowBeatGrid,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'AfterglowBeatRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'AfterglowBeatRow',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictAfterglowBeatRow,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'AnimatedStageMotifBackground',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'AnimatedStageMotifBackground',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictAnimatedStageMotifBackground,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ArrivalRingCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'ArrivalRingCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictArrivalRingCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CompanionHero',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'CompanionHero',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictCompanionHero,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CompanionMomentStage',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'CompanionMomentStage',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictCompanionMomentStage,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CompanionMomentStageContent',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'CompanionMomentStageContent',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictCompanionMomentStageContent,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CompanionPaperScaffold',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'CompanionPaperScaffold',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictCompanionPaperScaffold,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CompanionStageContentTransition',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'CompanionStageContentTransition',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictCompanionStageContentTransition,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CompanionStageScaffold',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'CompanionStageScaffold',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictCompanionStageScaffold,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CompatibilityQuestionnaireSection',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'CompatibilityQuestionnaireSection',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictCompatibilityQuestionnaireSection,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventCheckInQrScannerSheet',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventCheckInQrScannerSheet',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventCheckInQrScannerSheet,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'FirstHelloCheckInCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'FirstHelloCheckInCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictFirstHelloCheckInCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'GroupRotationSlotRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'GroupRotationSlotRow',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictGroupRotationSlotRow,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'IncludeMeToggle',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'IncludeMeToggle',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictIncludeMeToggle,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'LiveArrivalRing',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'LiveArrivalRing',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictLiveArrivalRing,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'LiveOthersInRoomLine',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'LiveOthersInRoomLine',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictLiveOthersInRoomLine,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'LiveStepContextCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'LiveStepContextCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictLiveStepContextCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'MicroPodCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'MicroPodCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictMicroPodCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'NoCompanionActionsCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'NoCompanionActionsCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictNoCompanionActionsCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PaperBarcode',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PaperBarcode',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPaperBarcode,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PaperCompanionNav',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PaperCompanionNav',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPaperCompanionNav,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PaperCompanionTicket',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PaperCompanionTicket',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPaperCompanionTicket,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PaperExpectationCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PaperExpectationCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPaperExpectationCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PaperExpectationRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PaperExpectationRow',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPaperExpectationRow,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PaperPrivacyCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PaperPrivacyCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPaperPrivacyCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PaperProgressRail',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PaperProgressRail',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPaperProgressRail,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PaperSelfCheckInBar',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PaperSelfCheckInBar',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPaperSelfCheckInBar,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PaperTicketDetail',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PaperTicketDetail',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPaperTicketDetail,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PaperTicketHeader',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PaperTicketHeader',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPaperTicketHeader,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PaperTicketPerforation',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PaperTicketPerforation',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPaperTicketPerforation,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PaperTicketSerial',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PaperTicketSerial',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPaperTicketSerial,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PeopleTokenRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PeopleTokenRow',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPeopleTokenRow,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PreCheckInPlanningCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PreCheckInPlanningCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPreCheckInPlanningCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PreviewLine',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PreviewLine',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPreviewLine,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PrivacyBadge',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PrivacyBadge',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPrivacyBadge,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PrivateAfterglowRecapCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PrivateAfterglowRecapCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPrivateAfterglowRecapCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'QuestionProgressRail',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'QuestionProgressRail',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictQuestionProgressRail,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'RevealCinematicOverlay',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'RevealCinematicOverlay',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictRevealCinematicOverlay,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'RotationScheduleCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'RotationScheduleCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictRotationScheduleCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'RotationSlotRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'RotationSlotRow',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictRotationSlotRow,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'SelfCheckInCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'SelfCheckInCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictSelfCheckInCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'StageActionDock',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'StageActionDock',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictStageActionDock,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'StageBouncyChip',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'StageBouncyChip',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictStageBouncyChip,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'StageBouncyPress',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'StageBouncyPress',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictStageBouncyPress,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'StageConversationCueCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'StageConversationCueCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictStageConversationCueCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'StageCueLine',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'StageCueLine',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictStageCueLine,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'StageGlyph',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'StageGlyph',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictStageGlyph,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'StageNav',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'StageNav',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictStageNav,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'StagePanel',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'StagePanel',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictStagePanel,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'StagePrivacyLine',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'StagePrivacyLine',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictStagePrivacyLine,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'StagePromptCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'StagePromptCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictStagePromptCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'StageSectionLabel',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'StageSectionLabel',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictStageSectionLabel,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'StageSoftBand',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'StageSoftBand',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictStageSoftBand,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'WingmanRequestSection',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'WingmanRequestSection',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictWingmanRequestSection,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'Defaults panel folded states',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessDefaultsPanel',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessDefaultsPanel',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessDefaultsPanel,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'Event preview folded states',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'EventPreviewCompanionSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventPreviewCompanionSkeleton',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventPreviewCompanionSkeleton,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventPreviewHero',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventPreviewHero',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventPreviewHero,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventPreviewHeroSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventPreviewHeroSkeleton',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventPreviewHeroSkeleton,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventPreviewLiveSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventPreviewLiveSkeleton',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventPreviewLiveSkeleton,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventPreviewNotesSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventPreviewNotesSkeleton',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventPreviewNotesSkeleton,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventPreviewReportSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventPreviewReportSkeleton',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventPreviewReportSkeleton,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventPreviewSectionSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventPreviewSectionSkeleton',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventPreviewSectionSkeleton,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventPreviewSetupSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventPreviewSetupSkeleton',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventPreviewSetupSkeleton,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessEventPreviewLoadingBody',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessEventPreviewLoadingBody',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessEventPreviewLoadingBody,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessEventPreviewLoadingScreen',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessEventPreviewLoadingScreen',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessEventPreviewLoadingScreen,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessEventPreviewRouteScreen',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessEventPreviewRouteScreen',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessEventPreviewRouteScreen,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessEventPreviewScreen',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessEventPreviewScreen',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessEventPreviewScreen,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'IntegrationNotesCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'IntegrationNotesCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictIntegrationNotesCard,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'Feature block folded states',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'BlockHeader',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'BlockHeader',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictBlockHeader,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ConversationCueRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'ConversationCueRow',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictConversationCueRow,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessAttendeeCompanionPreview',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessAttendeeCompanionPreview',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessAttendeeCompanionPreview,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessConversationCueCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessConversationCueCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessConversationCueCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessDarkPill',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessDarkPill',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessDarkPill,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessHostSetupFlow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessHostSetupFlow',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessHostSetupFlow,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessLiveHostMode',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessLiveHostMode',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessLiveHostMode,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessMetricPill',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessMetricPill',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessMetricPill,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessPostEventReport',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessPostEventReport',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessPostEventReport,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessPromptCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessPromptCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessPromptCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessRecommendationTile',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessRecommendationTile',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessRecommendationTile,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'IssueList',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'IssueList',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictIssueList,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'LiveStepRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'LiveStepRow',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictLiveStepRow,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ModuleToggleRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'ModuleToggleRow',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictModuleToggleRow,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PlaybookSummaryCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PlaybookSummaryCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPlaybookSummaryCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ProgressRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'ProgressRow',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictProgressRow,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'WingmanCandidateRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'WingmanCandidateRow',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictWingmanCandidateRow,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'Host folded states',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'AssignmentReasonSummary',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'AssignmentReasonSummary',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictAssignmentReasonSummary,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CompatibilitySignalHostCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'CompatibilitySignalHostCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictCompatibilitySignalHostCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessHostPanel',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessHostPanel',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessHostPanel,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessHostSection',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessHostSection',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessHostSection,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessHostSectionSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessHostSectionSkeleton',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessHostSectionSkeleton,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessLiveRosterSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessLiveRosterSkeleton',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessLiveRosterSkeleton,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessLiveTabSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessLiveTabSkeleton',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessLiveTabSkeleton,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessReportMetricsSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessReportMetricsSkeleton',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessReportMetricsSkeleton,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessReportTabSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessReportTabSkeleton',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessReportTabSkeleton,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessSetupControlsSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessSetupControlsSkeleton',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessSetupControlsSkeleton,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessSetupTabSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessSetupTabSkeleton',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessSetupTabSkeleton,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessSkeletonSurface',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessSkeletonSurface',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessSkeletonSurface,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessTabPicker',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessTabPicker',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessTabPicker,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessTabPickerSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessTabPickerSkeleton',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessTabPickerSkeleton,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'GroupOverrideMemberEditor',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'GroupOverrideMemberEditor',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictGroupOverrideMemberEditor,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'GroupOverrideRoundEditor',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'GroupOverrideRoundEditor',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictGroupOverrideRoundEditor,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'GroupOverrideSheet',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'GroupOverrideSheet',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictGroupOverrideSheet,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'GroupOverrideUnitEditor',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'GroupOverrideUnitEditor',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictGroupOverrideUnitEditor,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostActivitySummary',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'HostActivitySummary',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictHostActivitySummary,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostCheckInQrPanel',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'HostCheckInQrPanel',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictHostCheckInQrPanel,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostFunnelSummary',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'HostFunnelSummary',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictHostFunnelSummary,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostOverrideIconAction',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'HostOverrideIconAction',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictHostOverrideIconAction,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostReportSignalGrid',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'HostReportSignalGrid',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictHostReportSignalGrid,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'LiveAttendanceSummaryCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'LiveAttendanceSummaryCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictLiveAttendanceSummaryCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'LiveCheckInQrCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'LiveCheckInQrCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictLiveCheckInQrCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'LiveCheckInSummaryStrip',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'LiveCheckInSummaryStrip',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictLiveCheckInSummaryStrip,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'LiveNowConsole',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'LiveNowConsole',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictLiveNowConsole,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'LiveNowPill',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'LiveNowPill',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictLiveNowPill,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'LiveSectionHeader',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'LiveSectionHeader',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictLiveSectionHeader,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'LiveStepNavigation',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'LiveStepNavigation',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictLiveStepNavigation,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'LiveTab',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'LiveTab',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictLiveTab,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'MicroPodsHostCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'MicroPodsHostCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictMicroPodsHostCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'NoticeCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'NoticeCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictNoticeCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PlanSummary',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PlanSummary',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPlanSummary,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PodGroupSummary',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PodGroupSummary',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPodGroupSummary,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ReadinessIssues',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'ReadinessIssues',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictReadinessIssues,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ReportTab',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'ReportTab',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictReportTab,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'RotationOverridePairEditor',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'RotationOverridePairEditor',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictRotationOverridePairEditor,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'RotationOverrideRoundEditor',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'RotationOverrideRoundEditor',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictRotationOverrideRoundEditor,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'RotationOverrideSheet',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'RotationOverrideSheet',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictRotationOverrideSheet,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'RotationsHostCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'RotationsHostCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictRotationsHostCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'SetupSectionTitle',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'SetupSectionTitle',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictSetupSectionTitle,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'SetupTab',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'SetupTab',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictSetupTab,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'TargetAttendeeControl',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'TargetAttendeeControl',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictTargetAttendeeControl,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'UnsavedChangesPill',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'UnsavedChangesPill',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictUnsavedChangesPill,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'WingmanRequestHostRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'WingmanRequestHostRow',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictWingmanRequestHostRow,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'WingmanRequestsHostCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'WingmanRequestsHostCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictWingmanRequestsHostCard,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'Lab screen folded states',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'CapacityRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'CapacityRow',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictCapacityRow,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CoachPanel',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'CoachPanel',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictCoachPanel,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessLabScreen',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessLabScreen',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessLabScreen,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'LabHero',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'LabHero',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictLabHero,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'LayerHeader',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'LayerHeader',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictLayerHeader,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ModuleCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'ModuleCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictModuleCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ModuleGrid',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'ModuleGrid',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictModuleGrid,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'NotesList',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'NotesList',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictNotesList,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PlaybookCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PlaybookCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPlaybookCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PromiseCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PromiseCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPromiseCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PromiseGrid',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PromiseGrid',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPromiseGrid,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'RunOfShow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'RunOfShow',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictRunOfShow,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'Section',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Section',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictSection,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'Live reveal folded states',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'AssignmentUnlockedShell',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'AssignmentUnlockedShell',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictAssignmentUnlockedShell,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'AttendeeCountdown',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'AttendeeCountdown',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictAttendeeCountdown,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CountdownBeatPill',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'CountdownBeatPill',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictCountdownBeatPill,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CountdownBeatRail',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'CountdownBeatRail',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictCountdownBeatRail,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CountdownCuePill',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'CountdownCuePill',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictCountdownCuePill,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CountdownCueStack',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'CountdownCueStack',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictCountdownCueStack,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CountdownNumber',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'CountdownNumber',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictCountdownNumber,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CountdownStageDial',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'CountdownStageDial',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictCountdownStageDial,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessLiveRevealAttendeeCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessLiveRevealAttendeeCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessLiveRevealAttendeeCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessLiveRevealHostCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessLiveRevealHostCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessLiveRevealHostCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostRevealActions',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'HostRevealActions',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictHostRevealActions,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'RevealGroupSlotRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'RevealGroupSlotRow',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictRevealGroupSlotRow,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'RevealHostCopy',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'RevealHostCopy',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictRevealHostCopy,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'RevealProgressBar',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'RevealProgressBar',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictRevealProgressBar,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'RevealRoundList',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'RevealRoundList',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictRevealRoundList,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'RevealRoundRail',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'RevealRoundRail',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictRevealRoundRail,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'RevealRoundRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'RevealRoundRow',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictRevealRoundRow,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'RevealSlotRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'RevealSlotRow',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictRevealSlotRow,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'RevealTicker',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'RevealTicker',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictRevealTicker,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'VisibleGroupRotationSlots',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'VisibleGroupRotationSlots',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictVisibleGroupRotationSlots,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'VisiblePodAssignment',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'VisiblePodAssignment',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictVisiblePodAssignment,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'VisibleRotationSlots',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'VisibleRotationSlots',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictVisibleRotationSlots,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'WaitingRevealCue',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'WaitingRevealCue',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictWaitingRevealCue,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'Manual QA folded states',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'AttendeeQaControls',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'AttendeeQaControls',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictAttendeeQaControls,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ControlLabel',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'ControlLabel',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictControlLabel,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'DarkPill',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'DarkPill',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictDarkPill,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessManualQaScreen',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessManualQaScreen',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessManualQaScreen,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ManualQaControls',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'ManualQaControls',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictManualQaControls,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ManualQaHero',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'ManualQaHero',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictManualQaHero,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ManualQaHostManagePane',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'ManualQaHostManagePane',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictManualQaHostManagePane,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ManualQaSideBySide',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'ManualQaSideBySide',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictManualQaSideBySide,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ManualQaToggleRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'ManualQaToggleRow',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictManualQaToggleRow,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'QaDeviceFrame',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'QaDeviceFrame',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictQaDeviceFrame,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'Questionnaire editor folded states',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'CustomQuestionFields',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'CustomQuestionFields',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictCustomQuestionFields,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CustomQuestionnaireFields',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'CustomQuestionnaireFields',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictCustomQuestionnaireFields,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CustomQuestionnaireSheet',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'CustomQuestionnaireSheet',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictCustomQuestionnaireSheet,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessQuestionnaireConfigEditor',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessQuestionnaireConfigEditor',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessQuestionnaireConfigEditor,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'QuestionnairePreview',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'QuestionnairePreview',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictQuestionnairePreview,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'Setup body folded states',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'AttendeePromptPreview',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'AttendeePromptPreview',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictAttendeePromptPreview,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessSetupBody',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessSetupBody',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessSetupBody,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'FoundationLine',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'FoundationLine',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictFoundationLine,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PresetReviewCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'PresetReviewCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictPresetReviewCard,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'QuestionnaireBlock',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'QuestionnaireBlock',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictQuestionnaireBlock,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'RecommendationSwitch',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'RecommendationSwitch',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictRecommendationSwitch,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'RevealCountdownChips',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'RevealCountdownChips',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictRevealCountdownChips,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'RotationCadenceChips',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'RotationCadenceChips',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictRotationCadenceChips,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'SafetyFooter',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'SafetyFooter',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictSafetyFooter,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'SetupDisclosureSection',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'SetupDisclosureSection',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictSetupDisclosureSection,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'StageCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'StageCard',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictStageCard,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'Structure editor folded states',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'ActivityAttributeGoalChips',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'ActivityAttributeGoalChips',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictActivityAttributeGoalChips,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'EventSuccessStructureConfigEditor',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'EventSuccessStructureConfigEditor',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictEventSuccessStructureConfigEditor,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'StructureNumberField',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'StructureNumberField',
                    builder:
                        _widgetbook_workspace_event_success_event_success_strict_coverage_use_cases
                            .eventSuccessStrictStructureNumberField,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Host create club',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ClubBasicsStep',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Form states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .clubBasicsStepCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ClubDetailsStep',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Form states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .clubDetailsStepCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ClubEventSuccessDefaultsStep',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Event success defaults states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .clubEventSuccessDefaultsStepCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ClubHostDefaultsStep',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Defaults states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .clubHostDefaultsStepCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ClubPolicyDefaultsCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Policy defaults states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .clubPolicyDefaultsCardCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CreateClubContactFields',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Contact states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .createClubContactFieldsCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CreateClubPhotosPicker',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Media states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .createClubPhotosPickerCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CreateClubProfileImagePicker',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Image states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .createClubProfileImagePickerCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CreateClubScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Direct form states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .createClubScreenCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Host create event',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CreateEventPhotoPicker',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Photo picker states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .createEventPhotoPickerCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CreateEventScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Direct screen states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .createEventScreenCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CreateEventStepHeader',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Header states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .createEventStepHeaderCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CreateEventSuccessScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Success states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .createEventSuccessScreenCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CreateEventUnsavedChangesDialog',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Dialog states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .createEventUnsavedChangesDialogCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'DraftDeleteConfirmationDialog',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Delete confirmation',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .draftDeleteConfirmationDialogCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'DraftPickerSheet',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Draft sheet states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .draftPickerSheetCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventDetailsStep',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Details step states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .eventDetailsStepCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventPolicyStep',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Policy step states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .eventPolicyStepCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventSuccessStep',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Event success step states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .eventSuccessStepCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'HostCreateEventRouteStateView',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Route state renderer',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .hostCreateEventRouteStateViewCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'WhenStep',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'When step states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .whenStepCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'WhereStep',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Where step states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .whereStepCatalogStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Host edit event',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'EditHostedEventScopeNotice',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Scope notice states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .editHostedEventScopeNoticeCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EditHostedEventScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Direct screen states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .editHostedEventScreenCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EditableHostedEventPolicyCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Editable policy states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .editableHostedEventPolicyCardCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ReadOnlyHostedEventPolicyCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Read-only policy states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .readOnlyHostedEventPolicyCardCatalogStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ReadOnlyHostedEventScheduleCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Read-only schedule states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .readOnlyHostedEventScheduleCardCatalogStates,
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
          _widgetbook.WidgetbookFolder(
            name: 'Components',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'CatchRosterTileCell',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Roster primitive states',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostRosterPrimitiveCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostClubManagementPanel',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Tool card states',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostToolCardCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostRouteLoadingBody',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Skeleton states',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostLoadingSkeletonCatalogStates,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'Composed sections',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'HostClubsScaffold',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Covered by host clubs route states',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostClubsRouteStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostEventManageScreen',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Covered by host event manage route states',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostEventManageRouteAndSectionStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostEventsClubSection',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Covered by host event section states',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostHomeEventSectionStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostEventsScaffold',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Covered by host home route states',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostHomeRouteStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostSettingsSection',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Covered by host settings route states',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostSettingsRouteStates,
                  ),
                ],
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
          _widgetbook.WidgetbookFolder(
            name: 'Strict coverage',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'CatchRosterActionCell',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictCatchRosterActionCellCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CatchRosterDecideTarget',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictCatchRosterDecideTargetCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostAccountScreen',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostAccountScreenCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostActionRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostActionRowCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostAnalyticsBar',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostAnalyticsBarCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostAnalyticsControls',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostAnalyticsControlsCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostAnalyticsDataQualityPanel',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder: _widgetbook_workspace_hosts_host_operations_use_cases
                        .hostStrictHostAnalyticsDataQualityPanelCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostAnalyticsDateButton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostAnalyticsDateButtonCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostAnalyticsEventList',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostAnalyticsEventListCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostAnalyticsEventTile',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostAnalyticsEventTileCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostAnalyticsInlineStat',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostAnalyticsInlineStatCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostAnalyticsMetricGrid',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostAnalyticsMetricGridCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostAnalyticsMetricTile',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostAnalyticsMetricTileCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostAnalyticsReportSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostAnalyticsReportSkeletonCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostAnalyticsReportView',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostAnalyticsReportViewCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostAnalyticsReviewDiscoveryPanel',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder: _widgetbook_workspace_hosts_host_operations_use_cases
                        .hostStrictHostAnalyticsReviewDiscoveryPanelCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostAnalyticsSection',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostAnalyticsSectionCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostAnalyticsTrendPanel',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostAnalyticsTrendPanelCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostAuthRequiredScreen',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostAuthRequiredScreenCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostCapacityTile',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostCapacityTileCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostChartSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostChartSkeletonCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostClubInsightsPane',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostClubInsightsPaneCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostClubOrganizerOverview',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostClubOrganizerOverviewCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostClubPreviewPane',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostClubPreviewPaneCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostClubProfileCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostClubProfileCardCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostClubTabRail',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostClubTabRailCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostClubsScreen',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostClubsScreenCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostEmptyState',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostEmptyStateCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostEventActionsSection',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostEventActionsSectionCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostEventAttendancePanel',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostEventAttendancePanelCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostEventManageRouteScreen',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostEventManageRouteScreenCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostEventParticipantsList',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostEventParticipantsListCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostEventParticipantsPanel',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostEventParticipantsPanelCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostEventRows',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostEventRowsCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostEventRowsSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostEventRowsSkeletonCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostEventSummaryCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostEventSummaryCardCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostEventSummaryRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostEventSummaryRowCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostEventToolCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostEventToolCardCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostEventToolsCarousel',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostEventToolsCarouselCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostEventToolsPageIndicator',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostEventToolsPageIndicatorCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostEventsClubCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostEventsClubCardCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostExportReportButton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostExportReportButtonCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostFullCapacityApron',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostFullCapacityApronCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostFullCapacityBanner',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostFullCapacityBannerCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostInlineAgeRangeEditor',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostInlineAgeRangeEditorCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostInlineOptionEditor',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostInlineOptionEditorCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostInlineSkeletonIcon',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostInlineSkeletonIconCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostInlineTextEntryEditor',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostInlineTextEntryEditorCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostInviteLinkRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostInviteLinkRowCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostInviteLinksList',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostInviteLinksListCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostLoadingScreen',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostLoadingScreenCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostManageMetaItem',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostManageMetaItemCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostManageMetaRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostManageMetaRowCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostManageSectionPicker',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostManageSectionPickerCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostOperationsHomeScreen',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostOperationsHomeScreenCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostOrganizerHeader',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostOrganizerHeaderCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostOrganizerMetricGrid',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostOrganizerMetricGridCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostOrganizerMetricRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostOrganizerMetricRowCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostOrganizerMetricTile',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostOrganizerMetricTileCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostOrganizerPayoutPrompt',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostOrganizerPayoutPromptCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostOrganizerSectionHeader',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostOrganizerSectionHeaderCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostOrganizerTeamCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostOrganizerTeamCardCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostOrganizerTeamRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostOrganizerTeamRowCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostOrganizerTrendStrip',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostOrganizerTrendStripCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostParticipationLifecycleBoard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder: _widgetbook_workspace_hosts_host_operations_use_cases
                        .hostStrictHostParticipationLifecycleBoardCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostPaymentAccountCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostPaymentAccountCardCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostPaymentAccountContentCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder: _widgetbook_workspace_hosts_host_operations_use_cases
                        .hostStrictHostPaymentAccountContentCardCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostPaymentAccountErrorCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostPaymentAccountErrorCardCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostPaymentAccountLoadingCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder: _widgetbook_workspace_hosts_host_operations_use_cases
                        .hostStrictHostPaymentAccountLoadingCardCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostPrivateAccessBody',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostPrivateAccessBodyCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostPrivateAccessCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostPrivateAccessCardCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostPrivateAccessShell',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostPrivateAccessShellCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostProfileEditorSheet',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostProfileEditorSheetCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostRosterFilterHeader',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostRosterFilterHeaderCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostRosterSearchBar',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostRosterSearchBarCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostRosterSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostRosterSkeletonCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostSectionLabel',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostSectionLabelCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostSettingsClubRows',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostSettingsClubRowsCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostSettingsClubsEmptyState',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostSettingsClubsEmptyStateCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostSettingsProfileRows',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostSettingsProfileRowsCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostSettingsRowsSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostSettingsRowsSkeletonCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostStatChip',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostStatChipCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostSummarySkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostSummarySkeletonCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostTabRailSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostTabRailSkeletonCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostTeamManagementSection',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostTeamManagementSectionCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostTeamOwnerHostRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostTeamOwnerHostRowCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostTodayAvatarDot',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostTodayAvatarDotCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostTodayAvatarStack',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostTodayAvatarStackCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostTodayClubPill',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostTodayClubPillCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostTodayCountdownPill',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostTodayCountdownPillCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostTodayDashboardCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostTodayDashboardCardCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostTodayDashboardSection',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostTodayDashboardSectionCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostTodayEmptyEvents',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostTodayEmptyEventsCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostTodayEventHero',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostTodayEventHeroCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostTodayHeader',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostTodayHeaderCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostTodayHeroMetric',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostTodayHeroMetricCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostTodayLoadingBody',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostTodayLoadingBodyCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostTodayTaskCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostTodayTaskCardCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostTrendKpi',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostTrendKpiCatalogStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostWaitlistBulkOfferAction',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Exact catalog',
                    builder:
                        _widgetbook_workspace_hosts_host_operations_use_cases
                            .hostStrictHostWaitlistBulkOfferActionCatalogStates,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Host shared',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'StepperFooter',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Footer states',
                builder: _widgetbook_workspace_hosts_host_operations_use_cases
                    .stepperFooterCatalogStates,
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
            name: 'Components',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'ChatConversationsList',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Sliver states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .chatConversationsListStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ChatMessageList',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Renderer states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .chatMessageListRendererStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ChatPersonRowSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Skeleton states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .chatPersonRowSkeletonStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ChatShareCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Card states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .chatShareCardStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ChatShareCardSheet',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Sheet states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .chatShareCardSheetStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ChatsBrowseHeader',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Header states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .chatsBrowseHeaderStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ChatsEmptyState',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Empty states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .chatsEmptyStateVariants,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ChatsList',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Sliver states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .chatsListSliverStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ChatsListBody',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Body states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .chatsListBodyStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ChatsListSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Skeleton states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .chatsListSkeletonStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HostInboxBroadcastCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Card states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .hostInboxBroadcastCardStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'MatchCelebrationDialog',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Dialog states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .matchCelebrationDialogStates,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'Host inbox',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'HostBroadcastComposerSheet',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Sheet states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .hostBroadcastComposerSheetStates,
                  ),
                ],
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
                name: 'MatchTesterSheet',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Sheet states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .matchTesterSheetStates,
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
              _widgetbook.WidgetbookComponent(
                name: 'SuvbotActionBar',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Primitive states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .suvbotActionBarPrimitiveStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'SuvbotResetActionRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Primitive states',
                    builder:
                        _widgetbook_workspace_matches_matches_chat_use_cases
                            .suvbotResetActionRowPrimitiveStates,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Onboarding',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'OnboardingScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Route states',
                builder: _widgetbook_workspace_onboarding_onboarding_use_cases
                    .onboardingScreenRouteStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'Pages',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'GenderInterestPage',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Gender and interest form',
                    builder:
                        _widgetbook_workspace_onboarding_onboarding_use_cases
                            .genderInterestPageStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'InstagramPage',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Instagram form',
                    builder:
                        _widgetbook_workspace_onboarding_onboarding_use_cases
                            .instagramPageStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'NameDobPage',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Identity form',
                    builder:
                        _widgetbook_workspace_onboarding_onboarding_use_cases
                            .nameDobPageStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PhotosPage',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Photo grid states',
                    builder:
                        _widgetbook_workspace_onboarding_onboarding_use_cases
                            .photosPageStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ProfilePromptsPage',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Prompt form',
                    builder:
                        _widgetbook_workspace_onboarding_onboarding_use_cases
                            .profilePromptsPageStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'RunningPrefsPage',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Run preferences form',
                    builder:
                        _widgetbook_workspace_onboarding_onboarding_use_cases
                            .runningPrefsPageStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'WelcomePage',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Splash states',
                    builder:
                        _widgetbook_workspace_onboarding_onboarding_use_cases
                            .welcomePageStates,
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
          _widgetbook.WidgetbookFolder(
            name: 'Inline Editors',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'ProfileDirectTextEntryField',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Direct text entry states',
                    builder: _widgetbook_workspace_profiles_profile_use_cases
                        .profileDirectTextEntryFieldStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ProfileInlineHeightEditor',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Inline height editor states',
                    builder: _widgetbook_workspace_profiles_profile_use_cases
                        .profileInlineHeightEditorStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ProfileInlineLanguageMultiChoiceEntryEditor',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Inline multi choice editor states',
                    builder: _widgetbook_workspace_profiles_profile_use_cases
                        .profileInlineMultiChoiceEntryEditorStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ProfileInlinePromptEntryEditor',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Inline prompt editor states',
                    builder: _widgetbook_workspace_profiles_profile_use_cases
                        .profileInlinePromptEntryEditorStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ProfileInlineRangeEditor',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Inline range editor states',
                    builder: _widgetbook_workspace_profiles_profile_use_cases
                        .profileInlineRangeEditorStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ProfileInlineRelationshipGoalChoiceEntryEditor',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Inline single choice editor states',
                    builder: _widgetbook_workspace_profiles_profile_use_cases
                        .profileInlineSingleChoiceEntryEditorStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ProfileInlineTextValue',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Inline text value states',
                    builder: _widgetbook_workspace_profiles_profile_use_cases
                        .profileInlineTextValueStates,
                  ),
                ],
              ),
            ],
          ),
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
            name: 'PublicProfileBody',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Body states',
                builder: _widgetbook_workspace_profiles_profile_use_cases
                    .publicProfileBodyStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PublicProfileReportReasonTile',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Report reason row',
                builder: _widgetbook_workspace_profiles_profile_use_cases
                    .publicProfileReportReasonTileStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PublicProfileReportSheet',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Report sheet',
                builder: _widgetbook_workspace_profiles_profile_use_cases
                    .publicProfileReportSheetStates,
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
          _widgetbook.WidgetbookFolder(
            name: 'Sections',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'PreviewTab',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Preview tab states',
                    builder: _widgetbook_workspace_profiles_profile_use_cases
                        .previewTabStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ProfileTab',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Edit tab states',
                    builder: _widgetbook_workspace_profiles_profile_use_cases
                        .profileTabStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ProfileTabContent',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Edit tab content states',
                    builder: _widgetbook_workspace_profiles_profile_use_cases
                        .profileTabContentStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ProfileFieldRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Field row states',
                    builder: _widgetbook_workspace_profiles_profile_use_cases
                        .profileFieldRowStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ProfileDirectTextEntry',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Direct text entry adapter states',
                    builder: _widgetbook_workspace_profiles_profile_use_cases
                        .profileDirectTextEntryStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ProfilePromptEntry',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Prompt entry adapter states',
                    builder: _widgetbook_workspace_profiles_profile_use_cases
                        .profilePromptEntryStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ProfileTabSkeletonSliverBody',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Edit tab skeleton states',
                    builder: _widgetbook_workspace_profiles_profile_use_cases
                        .profileTabSkeletonSliverBodyStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ProfileTabSliverBody',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Edit tab sliver body states',
                    builder: _widgetbook_workspace_profiles_profile_use_cases
                        .profileTabSliverBodyStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'PublicProfileScreenBody',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Route body states',
                    builder: _widgetbook_workspace_profiles_profile_use_cases
                        .publicProfileScreenBodyStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'SelfProfileTabBody',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Self tab body states',
                    builder: _widgetbook_workspace_profiles_profile_use_cases
                        .profileScreenSelfTabBodyStates,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'User analytics',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'UserAnalyticsPanel',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Panel states',
                builder:
                    _widgetbook_workspace_user_analytics_user_analytics_use_cases
                        .userAnalyticsPanelStates,
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
        name: 'App root',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'MyApp',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Root shell',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .myAppRootState,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Auth',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'AuthScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Screen states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .authScreenStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'OtpPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'OTP entry states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .otpPageStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PhonePage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Phone entry states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .phonePageStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Calendar',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CalendarScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Screen states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .calendarScreenStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'Components',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'CalendarAgendaSliverSection',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Agenda section states',
                    builder: _widgetbook_workspace_utility_p3_utility_use_cases
                        .calendarAgendaSliverSectionStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CalendarDateHeader',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Header states',
                    builder: _widgetbook_workspace_utility_p3_utility_use_cases
                        .calendarDateHeaderStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CalendarDateHeaderSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Skeleton state',
                    builder: _widgetbook_workspace_utility_p3_utility_use_cases
                        .calendarDateHeaderSkeletonStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CalendarLoadingScreen',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Loading state',
                    builder: _widgetbook_workspace_utility_p3_utility_use_cases
                        .calendarLoadingScreenStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CalendarMessage',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Empty message state',
                    builder: _widgetbook_workspace_utility_p3_utility_use_cases
                        .calendarMessageStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CalendarMonthGrid',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Month grid state',
                    builder: _widgetbook_workspace_utility_p3_utility_use_cases
                        .calendarMonthGridStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CalendarStatDivider',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Divider state',
                    builder: _widgetbook_workspace_utility_p3_utility_use_cases
                        .calendarStatDividerStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CalendarStatSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Skeleton state',
                    builder: _widgetbook_workspace_utility_p3_utility_use_cases
                        .calendarStatSkeletonStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CalendarStatsHeader',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Stats state',
                    builder: _widgetbook_workspace_utility_p3_utility_use_cases
                        .calendarStatsHeaderStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CalendarStatsHeaderSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Skeleton state',
                    builder: _widgetbook_workspace_utility_p3_utility_use_cases
                        .calendarStatsHeaderSkeletonStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CalendarTitleRow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Title row state',
                    builder: _widgetbook_workspace_utility_p3_utility_use_cases
                        .calendarTitleRowStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CalendarWeekStrip',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Week strip state',
                    builder: _widgetbook_workspace_utility_p3_utility_use_cases
                        .calendarWeekStripStates,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CalendarWeekStripSkeleton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Skeleton state',
                    builder: _widgetbook_workspace_utility_p3_utility_use_cases
                        .calendarWeekStripSkeletonStates,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
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
        name: 'Event policy lab',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'EventPolicyCancellationRow',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Cancellation row',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .eventPolicyCancellationRowState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventPolicyCancellationRows',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Cancellation rows',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .eventPolicyCancellationRowsStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventPolicyDebugOutput',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Debug output',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .eventPolicyDebugOutputState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventPolicyDividerLine',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Divider',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .eventPolicyDividerLineState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventPolicyLabHeader',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Header states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .eventPolicyLabHeaderStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventPolicyLabScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Scenario states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .eventPolicyLabScreenStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventPolicyLabSectionTitle',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Small primitives',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .eventPolicySmallPrimitiveStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventPolicyResultRow',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Preview result row',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .eventPolicyResultRowState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventPolicyResultRows',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Preview result rows',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .eventPolicyResultRowsStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventPolicyScenarioCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Scenario card states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .eventPolicyScenarioCardStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventPolicyScenarioPicker',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Scenario picker',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .eventPolicyScenarioPickerState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventPolicySummary',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Summary states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .eventPolicySummaryStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'EventPolicySummaryLine',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Summary line',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .eventPolicySummaryLineState,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Force update',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ForceUpdateCheckErrorScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Error state',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .forceUpdateCheckErrorScreenStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ForceUpdateGate',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Gate states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .forceUpdateGateStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'UpdateRequiredScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Screen states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .updateRequiredScreenStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Image uploads',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'OrderedPhotoPicker',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Picker states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .orderedPhotoPickerStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PhotoGrid',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Grid states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .photoGridStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PhotoSlot',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Slot states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .photoSlotStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ProfilePhotoEditorScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Editor states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .profilePhotoEditorScreenStates,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Launch access',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'LaunchAccessApplicationForm',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Form states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .launchAccessApplicationFormStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'LaunchAccessApplicationScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Screen states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .launchAccessApplicationScreenStates,
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
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Payment confirmation',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'PaymentCheckoutSheet',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Checkout sheet states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .paymentCheckoutSheetStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PaymentConfirmationHeadsUp',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Info surfaces',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .paymentConfirmationInfoStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PaymentConfirmationScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Screen states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .paymentConfirmationScreenStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PaymentReferralBanner',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Referral banner',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .paymentReferralBannerStates,
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
            name: 'PaymentHistoryTile',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Row states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .paymentHistoryTileStates,
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
            name: 'ReviewCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Card states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .reviewCardStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ReviewHistoryItem',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'History row states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .reviewHistoryItemStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ReviewOwnerResponseBlock',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Host response block',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .reviewOwnerResponseBlockState,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ReviewResponseSheet',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Response sheet states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .reviewResponseSheetStates,
              ),
            ],
          ),
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
            name: 'ReviewsPreviewSection',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Preview section states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .reviewsPreviewSectionStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'StarRating',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Rating states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .starRatingStates,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'StarRatingPicker',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Picker states',
                builder: _widgetbook_workspace_utility_p3_utility_use_cases
                    .starRatingPickerStates,
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
