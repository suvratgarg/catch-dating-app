export interface SectionCopy {
  readonly eyebrow?: string;
  readonly title: string;
  readonly body?: string;
}

export interface CardCopy {
  readonly title: string;
  readonly body: string;
  readonly label?: string;
}

export type Card = CardCopy;

export interface LoopStepCopy {
  readonly step: string;
  readonly title: string;
  readonly body: string;
}

export type LoopStep = LoopStepCopy;

export type StorePlatform = "android" | "ios";

export interface StoreCtaCopy {
  readonly platform: StorePlatform;
  readonly kicker: string;
  readonly label: string;
  readonly shortLabel: string;
}

export interface FaqItemCopy {
  readonly question: string;
  readonly answer: string;
}

export type FaqItem = FaqItemCopy;

export interface PlaybookStage {
  readonly id: string;
  readonly label: string;
  readonly sub: string;
  readonly guestLine: string;
  readonly hostLine: string;
}

export interface PlaybookModule {
  readonly id: string;
  readonly anchor: string;
  readonly publicName: string;
  readonly stageId: string;
  readonly chip?: "NEW POWER" | "OFF YOUR PLATE";
  readonly oneLiner: string;
  readonly more: string;
  readonly fits: string;
}

export interface StaticPageMetaCopy {
  readonly title: string;
  readonly description: string;
  readonly canonicalPath: string;
  readonly twitterDescription: string;
  readonly robots?: "noindex, follow";
}

export interface ListingMetaCopy {
  readonly titleTemplate: string;
  readonly staticLabels: {
    readonly profileEyebrow: string;
    readonly formatsHeading: string;
    readonly factsHeading: string;
    readonly sourcesHeading: string;
    readonly lastVerifiedPrefix: string;
    readonly notRecorded: string;
    readonly homeBreadcrumb: string;
    readonly organizersBreadcrumb: string;
  };
}

export interface WebsiteMetaCopy {
  readonly routes: Readonly<
    Record<"home" | "host" | "organizers" | "claim" | "not_found", StaticPageMetaCopy>
  >;
  readonly listing: ListingMetaCopy;
}

export type OwnerGatedLegalPath = "/help" | "/privacy" | "/terms";

export interface OwnerGatedLegalPage {
  readonly path: OwnerGatedLegalPath;
  readonly body: string | null;
}
