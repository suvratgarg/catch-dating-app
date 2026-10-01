import {useEffect, useReducer, useState} from "react";
import {hostConceptCopy} from "@content/hostConceptNavigation";
import {hostConceptContentPages, type HostConceptContentSection} from "@content/hostConceptContent";
import {prototypeInteractionContent} from "@content/prototypeInteractionContent";
import {ownerGatedSiteDestinations, siteFooterLegalLinks, siteMenuCopy} from "@content/site";
import {SiteFooter, SiteHeader, WebsitePageMain} from "../../../shared/site";
import {
  ActionGroup, Button, ButtonLink, ChoiceCard, ChoiceChipGrid, ContentGrid, LiveStatus,
  HostPreviewFaqList, MarketingInfoCardGrid, MarketingSection, MarketingSectionCopy, SearchFormShell, TextField, UiLabel,
} from "../../../shared/ui/primitives";
import {initialPrototypeStackState, projectPrototypeStack, reducePrototypeStack} from "./prototypeStackModel";
import {
  createPrototypeConsoleState, initialPrototypeTierState, prototypeConsoleTickMs,
  prototypeTierRotationMs, reducePrototypeTier, tickPrototypeConsole,
} from "./prototypePresentationModel";

export function HostConceptPage({slug}: {slug: string}) {
  const page = hostConceptContentPages.find((candidate) => candidate.slug === slug);
  if (!page) return null;
  const copy = hostConceptCopy;
  return <>
    <SiteHeader brandHref="/" menuCopy={siteMenuCopy}
      nav={[...copy.nav, ...copy.personaLinks]}
      ctaHref={ownerGatedSiteDestinations.contactHref} ctaLabel={copy.headerContact} />
    <WebsitePageMain id="top">
      <MarketingSection variant="story">
        <UiLabel>{copy.eyebrow}</UiLabel>
        <h1>{page.sections[0]?.heading ?? page.title}</h1>
        <p>{page.description}</p>
        <p>{page.conceptNotice}</p>
        <ActionGroup variant="marketing">
          <ButtonLink href="/host/workflows/">{copy.workflows}</ButtonLink>
          <ButtonLink href="/host/" variant="ghost">{copy.live}</ButtonLink>
        </ActionGroup>
      </MarketingSection>
      {slug === "directory" ? <ConceptDirectorySearch /> : null}
      {page.sections.map((section, index) => <ConceptSection key={section.id} section={section}
        sectionAction={page.sectionAction}
        slug={slug} first={index === 0} />)}
      {(slug === "index" || slug === "host") ? <ConceptConsole /> : null}
      <MarketingSection variant="story">
        <ActionGroup variant="marketing">
          <ButtonLink href={ownerGatedSiteDestinations.contactHref}>{copy.contact}</ButtonLink>
          <ButtonLink href="/host/apply/" variant="ghost">{copy.apply}</ButtonLink>
          <ButtonLink href="/explore/" variant="ghost">{copy.consumer}</ButtonLink>
        </ActionGroup>
      </MarketingSection>
    </WebsitePageMain>
    <SiteFooter brandHref="/" body={copy.notice}
      links={[...copy.nav, ...copy.personaLinks, ...copy.additionalLinks, ...siteFooterLegalLinks]} />
  </>;
}

function ConceptDirectorySearch() {
  return <MarketingSection variant="story">
    <SearchFormShell variant="organizer" role="search" action="/organizers/" method="get">
      <TextField id="concept-organizer-query" name="q" type="search" label={hostConceptCopy.directorySearch} placeholder={hostConceptCopy.directoryPlaceholder} />
      <Button type="submit">{hostConceptCopy.directory}</Button>
    </SearchFormShell>
    <p>{hostConceptCopy.directorySearchNote}</p>
  </MarketingSection>;
}

function ConceptSection({section, sectionAction, slug, first}: {
  section: HostConceptContentSection;
  sectionAction?: {readonly label: string; readonly href: string};
  slug: string;
  first: boolean;
}) {
  const copy = hostConceptCopy;
  const stack = section.layout.includes("stack");
  const tiers = section.layout.includes("tiers");
  const faq = section.layout.includes("faq");
  return <MarketingSection variant="story" id={section.id} aria-labelledby={`${slug}-${section.id}-title`}>
    <MarketingSectionCopy variant="proof" reveal={false} titleId={`${slug}-${section.id}-title`}
      title={first ? copy.original : section.heading} body={null} />
    {section.body.map((body, index) => <p key={index}>{body}</p>)}
    {faq ? <HostPreviewFaqList initiallyOpenIndex={0} items={section.items.map((item) => ({question:item.title,answer:item.body}))} /> : section.items.length && !tiers && !section.layout.includes("console") ? <MarketingInfoCardGrid variant="surface" reveal={false}
      items={section.items.map((item, index) => ({key: `${section.id}-${index}`,
        title: item.title ?? item.label ?? section.heading, label: item.label, body: item.body}))} /> : null}
    {tiers ? <ConceptTiers section={section} /> : null}
    {stack ? <ConceptStack /> : null}
    <ActionGroup variant="marketing">
      {[...section.links, ...(sectionAction ? [sectionAction] : [])].map((link, index) => {
        const href = link.href;
        return href ? <ButtonLink key={`${section.id}-action-${index}`} href={href} variant="ghost">{link.label}</ButtonLink> : null;
      })}
    </ActionGroup>
  </MarketingSection>;
}

function useConceptMotion() {
  const [context, setContext] = useState(() => ({
    reducedMotion: typeof window === "undefined" || window.matchMedia("(prefers-reduced-motion: reduce)").matches,
    documentHidden: typeof document === "undefined" ? false : document.hidden,
    finePointer: typeof window === "undefined" ? false : window.matchMedia("(hover: hover) and (pointer: fine)").matches,
  }));
  useEffect(() => {
    const reduced = window.matchMedia("(prefers-reduced-motion: reduce)");
    const pointer = window.matchMedia("(hover: hover) and (pointer: fine)");
    const update = () => setContext({reducedMotion: reduced.matches, documentHidden: document.hidden, finePointer: pointer.matches});
    update();
    reduced.addEventListener("change", update); pointer.addEventListener("change", update);
    document.addEventListener("visibilitychange", update);
    return () => {reduced.removeEventListener("change", update); pointer.removeEventListener("change", update); document.removeEventListener("visibilitychange", update);};
  }, []);
  return context;
}

function ConceptTiers({section}: {section: HostConceptContentSection}) {
  const context = useConceptMotion();
  const [state, setState] = useState(initialPrototypeTierState);
  const tiers = prototypeInteractionContent.tiers;
  useEffect(() => {
    if (context.reducedMotion || context.documentHidden || state.pinned) return;
    const timer = window.setInterval(() => setState((value) => reducePrototypeTier(value, {type:"tick"}, context)), prototypeTierRotationMs);
    return () => window.clearInterval(timer);
  }, [context, state.pinned]);
  const details = section.items.filter((item) => item.role === "tier-detail");
  const activeDetail = details.find((item) => item.tierId === tiers[state.activeIndex]?.id);
  return <>
    <UiLabel>{hostConceptCopy.tiers}</UiLabel>
    <ChoiceChipGrid aria-label={hostConceptCopy.tiers}>
      {tiers.map((tier, index) => <ChoiceCard key={tier.id} title={tier.name} body={tier.ringLabel}
        selected={state.activeIndex === index}
        onClick={() => setState((value) => reducePrototypeTier(value, {type:"select-card", index}, context))}
        onMouseEnter={() => setState((value) => reducePrototypeTier(value, {type:"hover", index}, context))} />)}
    </ChoiceChipGrid>
    <LiveStatus>{hostConceptCopy.selectedTier}: {tiers[state.activeIndex]?.name}</LiveStatus>
    {activeDetail ? <section>
      <h3>{activeDetail.title}</h3><p>{activeDetail.body}</p>
      <ul>{activeDetail.bullets?.map((bullet) => <li key={bullet}>{bullet}</li>)}</ul>
    </section> : null}
    <MarketingInfoCardGrid variant="surface" reveal={false} items={section.items
      .filter((item) => item.role === "tier-note")
      .map((item, index) => ({key:`tier-note-${index}`,title:item.title ?? item.label ?? section.heading,body:item.body}))} />
  </>;
}

function ConceptStack() {
  const [state, dispatch] = useReducer(reducePrototypeStack, initialPrototypeStackState);
  const view = projectPrototypeStack(state);
  const copy = prototypeInteractionContent.stack;
  return <>
    <p>{prototypeInteractionContent.notice}</p>
    <p>{copy.disclosure}</p>
    <TextField id="concept-tool-filter" label={copy.searchLabel} placeholder={copy.searchPlaceholder}
      value={state.query} onChange={(event) => dispatch({type:"search", query:event.target.value})} />
    <ContentGrid variant="marketing-split">
      <div>
        {!view.visibleGroups.length ? <p>{hostConceptCopy.noResults}</p> : null}
        {view.visibleGroups.map((group) => <section key={group.id}>
          <h3>{group.label}</h3><p>{group.hint}</p>
          <ChoiceChipGrid aria-label={group.label}>
            {group.tools.map((tool) => <ChoiceCard key={tool.id} title={tool.name} body={tool.job}
              selected={state.selectedIds.includes(tool.id)} onClick={() => dispatch({type:"toggle-tool",id:tool.id})} />)}
          </ChoiceChipGrid>
        </section>)}
      </div>
      <div>
        <h3>{copy.receiptHeading}</h3>
        <LiveStatus>{view.countLabel} {view.statistics}</LiveStatus>
        {!view.count ? <p>{copy.empty}</p> : null}
        {view.selected.map((tool) => <section key={tool.id}>
          <h4>{tool.name}</h4><p>{tool.catch}</p>
          <Button variant="ghost" aria-expanded={view.expandedIds.includes(tool.id)} aria-controls={`mapping-${tool.id}`}
            onClick={() => dispatch({type:"toggle-detail",id:tool.id})}>
            {view.expandedIds.includes(tool.id) ? hostConceptCopy.hideDetails : hostConceptCopy.details}
          </Button>
          <p id={`mapping-${tool.id}`} hidden={!view.expandedIds.includes(tool.id)}>{tool.detail}</p>
        </section>)}
        <h3>{copy.resultHeading}</h3><h4>{view.tier.name}</h4><p>{view.tierExplanation}</p>
        <ButtonLink href={ownerGatedSiteDestinations.contactHref}>{hostConceptCopy.contact}</ButtonLink>
      </div>
    </ContentGrid>
  </>;
}

function ConceptConsole() {
  const context = useConceptMotion();
  const [paused, setPaused] = useState(false);
  const [state, setState] = useState(() => createPrototypeConsoleState(context.reducedMotion));
  useEffect(() => {
    if (context.reducedMotion) {setState(createPrototypeConsoleState(true)); return;}
    if (paused || context.documentHidden) return;
    const timer = window.setInterval(() => setState((value) => tickPrototypeConsole(value, context)), prototypeConsoleTickMs);
    return () => window.clearInterval(timer);
  }, [context, paused]);
  const copy = prototypeInteractionContent.console;
  return <MarketingSection variant="story">
    <MarketingSectionCopy variant="proof" reveal={false} title={copy.heading} body={copy.notice} />
    <MarketingInfoCardGrid variant="surface" reveal={false} items={copy.events.map((event) => ({key:event.id,title:event.name,body:event.detail,label:event.status}))} />
    <p>{copy.footer.join(" · ")}</p>
    <p>{hostConceptCopy.checkIns}: {state.checkIns}</p>
    <ol aria-label={copy.activityLabel}>{copy.rows.map((row, index) => <li key={row.id} hidden={index >= state.visibleRows}>{row.time} {row.text}</li>)}</ol>
    <ActionGroup variant="marketing">
      <Button variant="ghost" onClick={() => setPaused((value) => !value)}>{paused ? hostConceptCopy.resume : hostConceptCopy.pause}</Button>
      <Button variant="ghost" onClick={() => setState(createPrototypeConsoleState(context.reducedMotion))}>{hostConceptCopy.replay}</Button>
    </ActionGroup>
  </MarketingSection>;
}
