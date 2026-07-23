# Riverpod provider graph

Generated from handwritten Dart ASTs under lib/ by dart run tool/architecture/provider_graph.dart --write.

Open [provider_graph.html](provider_graph.html) for the interactive feature/provider view. [provider_graph.json](provider_graph.json) is the complete machine-readable graph; [provider_graph.mmd](provider_graph.mmd) is the aggregated feature map.

## Current inventory

| Measure | Count |
|---|---:|
| Handwritten Dart files | 795 |
| Providers | 214 |
| Mutations | 83 |
| Unique provider relationships | 328 |
| Cross-feature relationships | 168 |
| Consumer callsites | 724 |
| Reactive cycles | 0 |

## Architecture review

| Candidate | Decision | Rationale |
|---|---|---|
| cross-feature-presentation:authSessionControllerProvider->exploreFiltersProvider | accepted | Sign-out is the app-session boundary and invalidates the keepAlive Explore browse roots so a new account cannot inherit the prior account's filters. The focused AuthSessionController test proves reset behavior. |
| cross-feature-presentation:authSessionControllerProvider->exploreSearchQueryProvider | accepted | Sign-out is the app-session boundary and invalidates the keepAlive Explore browse roots so a new account cannot inherit the prior account's search query. The focused AuthSessionController test proves reset behavior. |
| cross-feature-presentation:authSessionControllerProvider->onboardingControllerProvider | accepted | Sign-out is the app-session boundary and must reset the public onboarding controller plus its Mutations. This is the documented controller-to-controller command seam, not a read-model or widget dependency. |
| cross-feature-presentation:authSessionControllerProvider->selectedExploreCityProvider | accepted | Sign-out is the app-session boundary and invalidates the keepAlive Explore browse roots so a new account cannot inherit the prior account's selected city. The focused AuthSessionController test proves reset behavior. |
| cross-feature-presentation:authSessionControllerProvider->selectedExploreCityWasUserSelectedProvider | accepted | Sign-out is the app-session boundary and invalidates the keepAlive Explore browse roots so a new account cannot inherit the prior account's manual city-selection guard. The focused AuthSessionController test proves reset behavior. |
| cross-feature-presentation:settingsControllerProvider->authSessionControllerProvider | accepted | Account deletion completes through the public auth-session command seam so auth and onboarding flow state are cleared centrally. Moving that cleanup into Safety would duplicate session ownership. |
| high-fan-out:chatRouteStateProvider | accepted | The eight dependencies form one route projection: conversation, match and host-inquiry context, event/profile enrichment, share capability, and action pending state. The provider has no cycles and prevents the screen from assembling those waves itself. |
| high-fan-out:eventDetailViewModelProvider | accepted | The eight dependencies form one Event Detail route projection: auth resolution, event and organizer authority, viewer profile, reviews, saved state, participation, and organizer membership. Their loading and error precedence is intentionally centralized so Event Detail and its map route cannot render inconsistent visibility or viewer actions. |
| high-fan-out:exploreFeedViewModelProvider | watch | The eighteen dependencies are a cohesive discovery aggregate spanning filters, viewer eligibility, memberships, participations, saves, internal and external supply, search, and club names. Splitting now would duplicate partial-loading and precedence logic; revisit if a second route needs a stable subset or fan-out rises above twenty. |
| manual-provider:_hostClubsForUserProvider | accepted-exception | This is a private auto-dispose adapter in a part file that narrows a Host route provider result. Moving it only to satisfy code generation would add a public generated symbol and another ownership file without changing the dependency boundary. |
| routing-to-presentation:goRouterProvider->authControllerProvider | accepted | GoRouter is the app integration root and listens only to the auth verification gate needed to refresh redirects. It does not import auth widgets or perform auth mutations. |

## Refresh and check

    dart run tool/architecture/provider_graph.dart --write
    dart run tool/architecture/provider_graph.dart --check

The check fails on stale artifacts, duplicate or dangling provider nodes, unresolved provider-internal refs, reactive cycles, unreviewed architecture candidates, or stale review decisions.
