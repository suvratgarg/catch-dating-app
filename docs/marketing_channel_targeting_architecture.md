---
doc_id: marketing_channel_targeting_architecture
version: 0.1.0
updated: 2026-05-31
owner: marketing_website
status: draft
---

# Marketing Channel Targeting Architecture

This document maps the acquisition architecture for Catch across paid,
organic, partnership, and community channels. It is intentionally upstream of
copywriting and page implementation. The goal is to decide which audiences can
be reached precisely on which channels, then design landing pages and assets
around those reachable use cases.

## Execution Artifacts

- [`ads_launch_tracker.md`](ads_launch_tracker.md) owns the first paid
  acquisition setup sequence, spend gates, campaign cells, and stop rules.
- [`ads_conversion_spec.md`](ads_conversion_spec.md) owns website and app
  conversion naming, ad-platform import order, consent rules, and verification.

## Strategic Premise

Different marketing channels expose different targeting primitives:

- Search channels expose explicit demand: "singles events in Mumbai",
  "pickleball near me", "run club Bangalore", "dating app".
- Social channels expose inferred interests and creative-response signals:
  people who watch dating, city, nightlife, fitness, racket sport, creator, or
  event content.
- Professional channels expose work identity: job title, industry, company,
  seniority, skills, groups, and company size.
- Community channels expose topic and place context: subreddits, questions,
  forums, city groups, event listings, WhatsApp communities, Telegram groups,
  and creator audiences.
- First-party channels expose actual intent: site visitors, waitlist signups,
  host leads, app installers, booked users, attended users, and high-quality
  hosts.

For Catch, the channel plan should not be "run ads everywhere." It should map
one narrow audience, one channel primitive, one promise, and one landing page.

## Current Product Frame

Repo truth as of 2026-05-31:

- Catch is evolving from a run-club dating app into a singles event platform
  built around clubs, hosts, city discovery, event booking, attendance, and
  post-event dating.
- Current/default activity formats include social runs, walking, pickleball,
  padel, tennis, badminton, cycling, spin class, yoga, dinner, pub quiz, bar
  crawl, singles mixer, and open host-led activities.
- Host tooling includes club and event creation, booking, waitlist, attendance,
  paid-event support, QR/self check-in, private links, event-success setup and
  live mode, aggregate reporting, and post-event dating context.
- Current India implementation still has important India-specific assumptions:
  `+91` auth, hardcoded Indian city surfaces, and Razorpay INR payments.

Marketing implication:

- Consumer copy can say "curated singles events" where policy allows it.
- Host copy should often lead with "event operating system for singles and
  social formats" rather than only "dating app."
- Paid ads that explicitly promote dating, singles, matchmaking, or post-event
  romantic matching should be treated as restricted dating advertising.
- Community/host tooling pages can often be cleaner policy-wise if they sell
  event operations, attendance, demand management, and repeat community growth.

## Initial Market Split

### Hosts Abroad

Likely targets:

- Existing singles-event organizers.
- Indian diaspora event/community organizers.
- Run club, racket sport, dinner, quiz, bar, and mixer hosts.
- Venues with underused weekday slots.
- Creators with city social audiences.
- Event operators already using Luma, Partiful, Eventbrite, Meetup, WhatsApp, or
  Instagram DMs.

Primary job:

- Build supply and credibility before broad consumer acquisition in that city.
- Convert host leads to pilot calls and hosted demo events.

### General Public In India

Likely targets:

- Singles in launch cities who want better offline ways to meet people.
- People searching for things to do, new friends, run clubs, racket sports,
  mixers, dinners, pub quizzes, and dating events.
- Urban professionals who distrust infinite swipe apps but will attend a
  specific, well-hosted event.
- New-to-city users seeking social context.

Primary job:

- Drive city waitlist, app installs, event interest, and bookings.

### Hosts In India

Likely targets:

- Run clubs and fitness communities.
- Pickleball, padel, tennis, badminton venues and coaches.
- Cafes, bars, supper clubs, quiz hosts, and nightlife/community creators.
- Existing Meetup/Eventbrite/Luma/Instagram event hosts.
- College alumni, coworking, startup, and cultural community organizers, where
  legally and brand-safely appropriate.

Primary job:

- Drive host lead forms, WhatsApp inquiries, demo calls, and first hosted
  events in launch cities.

## Targeting Primitive Taxonomy

| Primitive | What it targets | Strong channels | Catch use |
|---|---|---|---|
| Geo | Country, state, city, radius, DMA, zip/postal where available | Google, Meta, LinkedIn, Reddit, TikTok, Snap, Apple Ads | Launch-city control, city waitlists, venue-radius campaigns |
| Demographic | Age, gender, language, device | Meta, TikTok, Snap, Reddit, Apple Ads, Google, LinkedIn | Adult-only dating compliance, city/language fit, OS-specific app installs |
| Search intent | User query or app-store query | Google Search, Apple Ads, Bing, YouTube search, Quora SEO | "singles events Mumbai", "run club Bangalore", "dating app", "pickleball singles" |
| Contextual content | Page, video, community, topic, question, keyword, placement | Google Display/YouTube, Reddit, Quora, Pinterest | City subreddits, racket sport videos, event blogs, "how to make friends" questions |
| Interest/behavior | Inferred interests, recent engagement, watch/read behavior | Meta, Instagram, TikTok, Reddit, Pinterest, YouTube, X, Snap | Dating-app alternatives, fitness, nightlife, food, racket sports, city life |
| Professional identity | Company, industry, title, function, seniority, skills, groups, school | LinkedIn, Sales Navigator, some B2B data tools | Host operators, venue owners, event managers, community managers |
| First-party | Website visitors, CRM, app users, lead lists, event engagers | Meta, Google, LinkedIn, Reddit, TikTok, Snap, Pinterest, X | Retarget host leads, seed lookalikes, exclude converted users |
| Expansion | Lookalike, predictive, optimized, Advantage+, smart targeting | Meta, LinkedIn, Google Demand Gen, TikTok, Snap, Pinterest | Scale after clean conversion data exists |
| Social graph | Followers, creator audiences, page engagers, account lookalikes | Instagram, TikTok, X, LinkedIn, YouTube | Influencer whitelisting, founder/host content, follower lookalikes |
| Human curation | Manual list building, mod-approved posts, partnerships, direct outreach | Reddit, Instagram, LinkedIn, WhatsApp, event platforms | Hosts abroad, venues, communities, city pilots |

## Channel Capability Inventory

### Google Search

Best targeting primitives:

- Search keywords and match types.
- Location presence or presence-plus-interest.
- Device, language, schedule, audience observation, and remarketing.
- Customer Match where eligible.

Best Catch use cases:

- High-intent consumer demand: "singles events in Mumbai", "dating events
  Bangalore", "meet people in Pune", "run club Mumbai", "pickleball near me".
- High-intent host demand: "host singles event", "event ticketing app",
  "run club management", "event check in app", "how to run speed dating".
- City SEO validation: query data should inform landing-page taxonomy.

Landing page fit:

- `/city/mumbai/singles-events`
- `/city/bengaluru/social-events`
- `/formats/social-run`
- `/formats/pickleball-singles`
- `/hosts/event-operating-system`

Notes:

- Use "Presence" rather than "Presence or Interest" when the event is only
  available in a city and out-of-city clicks are waste.
- Use "Presence or Interest" for host-abroad research campaigns, diaspora
  travel/relocation angles, and content queries where intent may be outside the
  event city.
- If copy or landing pages promote dating or matchmaking, treat Google dating
  certification as a prerequisite.

### Google Display, YouTube, Demand Gen, and Performance Max

Best targeting primitives:

- Audience segments: affinity, in-market, detailed demographics, custom
  segments, first-party data, and Demand Gen lookalikes.
- Contextual content: topics, placements, and content keywords where supported.
- App campaigns can promote across Google Search, Google Play, YouTube,
  Discover, and the Display Network, but with more automation and less manual
  audience control.

Best Catch use cases:

- Retargeting site visitors and video viewers.
- Creative education: explain the "show up first, match after" loop.
- Format-specific awareness: social run, racket rotations, dinner mixer,
  pub quiz, singles mixer.
- YouTube placement tests around run clubs, pickleball, padel, dating advice,
  city nightlife, and "things to do" content.

Landing page fit:

- Retarget to the exact city or host page previously viewed.
- Prospecting should land on format-specific pages, not generic home.

Notes:

- Use custom segments as signal inputs, not as a guarantee that Google will
  target exact app users or exact site audiences.
- For app campaigns, delay serious spend until install/open/profile-complete
  events are measured cleanly through Firebase or an MMP.

### Meta: Facebook and Instagram Paid

Best targeting primitives:

- Location, age, gender, language, placements.
- Detailed targeting around interests and behaviors, with Meta optimization
  often expanding beyond suggestions depending on setup.
- Custom Audiences from website, app, lead form, engagement, and CRM data.
- Lookalike Audiences and Advantage+ audience expansion.
- Instagram placements for Reels, Stories, Feed, Explore, profile, and creator
  partnership formats.

Best Catch use cases:

- Consumer event demand in India.
- City and format creative tests: "Sunday social run", "pickleball singles",
  "dinner table mixer", "pub quiz teams", "new to Mumbai".
- Host creator acquisition through Instagram-first proof.
- Retargeting users who watched event videos, clicked waitlist, opened host
  forms, or visited specific format pages.

Landing page fit:

- `/city/{city}`
- `/formats/{format}`
- `/for/new-to-city`
- `/hosts/creators`
- `/hosts/racket-sports`

Notes:

- Do not write ad copy that implies knowledge of a personal attribute, such as
  "Are you lonely?" Use "New to the city?" or "Meet people offline this weekend"
  instead.
- Explicit dating/singles campaigns may require restricted-category review or
  permission. Build a policy-safe "social events" creative family alongside the
  direct "singles events" family.
- Instagram organic and creator partnerships should be treated as a separate
  channel, because targeting happens through creator selection and content
  context rather than Ads Manager fields.

### LinkedIn Ads

Best targeting primitives:

- Required location and profile language.
- Company attributes: industry, name, category, growth rate, size, followers,
  and connections.
- Job experience: title, function, seniority, skills, years of experience.
- Education, member interests, member groups where available, devices.
- Matched Audiences, predictive audiences, audience expansion, and website
  retargeting.

Best Catch use cases:

- Host and venue acquisition, not broad attendee acquisition.
- Abroad host pilots: event managers, founders, community managers, hospitality
  operators, sports/recreation facility managers, and Indian diaspora community
  leaders in target cities.
- India host pilots: venue owners, sports facility operators, activity coaches,
  event managers, community builders, and hospitality marketing managers.
- B2B credibility content: "How to turn singles events into repeat community."

Landing page fit:

- `/hosts`
- `/hosts/abroad`
- `/hosts/venues`
- `/hosts/racket-sports`
- `/hosts/community-creators`

Notes:

- LinkedIn is expensive for consumer installs. Use it where professional data is
  decisive.
- Avoid hyper-targeting early. Start with two to three facets, then refine from
  professional demographics and lead quality.
- For niche host lists, build company/account lists manually and layer seniority
  or function rather than relying only on industry.

### Reddit Paid

Best targeting primitives:

- Community targeting by subreddit.
- Keyword targeting in conversations.
- Interest targeting.
- Location, gender, device, and retargeting.
- Custom audiences and lookalike-style expansion where account features allow.

Best Catch use cases:

- City pain and intent: `r/mumbai`, `r/bangalore`, `r/delhi`, `r/pune`,
  `r/india`, `r/indiasocial`, and city-specific advice threads.
- Topic intent: running, fitness, pickleball/padel/tennis, social anxiety,
  moving cities, weekend plans, dating advice, expats, Indian diaspora.
- Host research: find recurring posts by organizers, community owners, and venue
  promoters.

Landing page fit:

- `/for/new-to-city`
- `/city/{city}/weekend-socials`
- `/formats/social-run`
- `/formats/pub-quiz`
- `/hosts/community-creators`

Notes:

- Reddit is strongest when the message matches the thread/community context.
- Paid ads should be split by targeting type. Do not combine all communities,
  interests, and keywords into one blended test if the goal is learning.
- Organic or guerrilla Reddit must be moderator-respecting, transparent, and
  useful. Avoid astroturfing and fake user stories.

### Reddit Organic and Guerrilla

Targeting primitive:

- Human selection of communities and threads.
- Post/comment context.
- Moderator relationships.
- Founder/operator participation.

Best Catch use cases:

- Validate the "new to city" and "offline social life" need.
- Recruit first attendees for a specific event when a subreddit allows local
  event posts.
- Ask for feedback on event formats without pretending to be a normal user.
- Identify city-specific vocabulary: "scene", "meetup", "hangout",
  "socials", "singles", "third place", "sports night", "weekend plan".

Execution rules:

- Use official/founder accounts, not fake accounts.
- Ask moderators before promotional posts.
- Share useful city/event guides and research summaries before direct asks.
- Never scrape or target vulnerable personal posts with intrusive replies.
- Keep dating copy adult-only and non-predatory.

### TikTok Paid and Organic

Best targeting primitives:

- Demographics, audience targeting, advanced targeting, device type, and smart
  targeting.
- Interest and behavior signals, video engagement, creator/Spark Ads, custom
  audiences, and lookalikes.

Best Catch use cases:

- Fast consumer creative learning.
- UGC-style proof of event formats: "first hello", "pickleball rotation",
  "post-run coffee", "quiz team reveal", "dinner table prompt".
- City waitlist and app-install prospecting once conversion tracking is stable.
- Creator-assisted trust building.

Landing page fit:

- Lightweight mobile pages with one CTA.
- App store links when policy requires.
- Format pages that match video hook exactly.

Notes:

- TikTok dating-app ads have strict 18+ and market restrictions, and in allowed
  markets require working with a TikTok sales representative. If the ad is
  framed as a dating app, plan for this gate before spend.
- Avoid negative single-life framing and young-looking models.

### Apple Ads

Best targeting primitives:

- App Store search keywords.
- Broad and exact match.
- Search Match discovery.
- Customer type: all users, new users, returning users, users of other owned
  apps.
- Location refinements, age, gender, and device where available.
- Custom product pages and deep links for ad variations.

Best Catch use cases:

- High-intent iOS install capture.
- Competitor/category queries: dating app, singles events, meetup, run club,
  events near me, social app, pickleball app.
- City/format App Store product pages once the app is live and metadata supports
  relevance.

Landing page fit:

- App Store product page, custom product page, or deep link.

Notes:

- Apple will not enter auctions if the app is not relevant enough to the query,
  regardless of bid.
- Use exact match for controlled learning, broad/Search Match for discovery,
  and negative keywords to control waste.

### Google Play and App Store Organic ASO

Best targeting primitives:

- Store search intent.
- App title, subtitle/short description, keyword field, screenshots, ratings,
  reviews, and in-app events where available.

Best Catch use cases:

- Capture "dating app", "singles events", "meet people", "run club", "events",
  and city-driven queries.
- Align store screenshots with the same segments as paid pages: city, event
  booking, host tools, post-event matches.

Notes:

- ASO must not over-index on "run" if the product promise is broader singles
  events.
- Store page claims need to match current product availability by country/city.

### X Ads

Best targeting primitives:

- Keywords, conversations, events, interests, follower lookalikes, post
  engagers, custom audiences, age, gender, language, location, device.

Best Catch use cases:

- Founder-led public build and city launch narrative.
- Target people discussing dating apps, city loneliness, weekend plans, running,
  padel/pickleball, Indian startup/social scenes.
- Reach followers/lookalikes of local event brands, creator accounts, and
  competitor categories.

Landing page fit:

- `/city/{city}`
- `/hosts/abroad`
- `/for/new-to-city`

Notes:

- Treat as test budget unless there is strong founder/community content.
- Useful for discourse capture, weaker for predictable conversion than search
  or Meta.

### Snapchat

Best targeting primitives:

- Location, age, gender, language, interests, lifestyle categories, device,
  custom audiences, lookalikes, and Snap Pixel audiences.

Best Catch use cases:

- Younger adult city awareness.
- Event-day urgency around social, nightlife, and active formats.
- Short video creative tests if 18+ gating and app policies are clean.

Landing page fit:

- Mobile-only city/event pages.

Notes:

- Good for reach, less precise for host acquisition.
- Use only after Meta/TikTok creative tests identify hooks worth adapting.

### Pinterest

Best targeting primitives:

- Keywords, interests, demographics, placement, actalike audiences, and
  Performance+ expansion.

Best Catch use cases:

- "Date ideas", "things to do in Mumbai", "weekend plans", "outfit/event
  inspiration", "dinner party", "fitness social" content.
- Long-tail discovery around event guides, not immediate app installs.

Landing page fit:

- Editorial city guides and format pages.

Notes:

- Lower priority for launch unless Catch invests in visual city/event guides.

### Quora

Best targeting primitives:

- Topic, keyword, and question targeting.
- Website traffic, lookalike, list match.
- Interest, keyword-history, question-history targeting.
- Location, device/browser, gender, and exclusions.

Best Catch use cases:

- Problem-aware users: "How do I make friends in Bangalore?", "Where can I meet
  singles in Mumbai?", "Are dating apps worth it?", "How do I find running
  groups near me?"
- Host education content: "How do I organize a singles event?", "How do I get
  people to attend my community event?"

Landing page fit:

- `/for/new-to-city`
- `/learn/how-to-meet-people-offline`
- `/hosts/guides/run-a-singles-event`

Notes:

- Lower scale but unusually precise context.
- Good for testing educational copy that can later become SEO pages.

### Event Marketplaces and Local Discovery

Channels:

- Eventbrite, Luma, Meetup, Partiful, AllEvents, Insider, Skillboxes,
  BookMyShow, Paytm Insider, local city newsletters, college alumni boards,
  coworking event calendars, cafe/bar calendars.

Targeting primitive:

- Users already browsing events and hosts already publishing events.

Best Catch use cases:

- Host list building.
- Competitor/category research.
- Event-level demand capture.
- Co-hosted launch events while Catch's own demand is still ramping.

Landing page fit:

- Event-specific pages and host-specific landing pages.

Notes:

- This is not only acquisition. It is supply research.
- Scrape or collect only in ways allowed by each platform's terms.

### Influencer, Creator, and Ambassador Marketing

Targeting primitive:

- Creator audience composition, local trust, content niche, and community
  density.

Best Catch use cases:

- City creators: weekend plans, dating, food, fitness, nightlife, students,
  working professionals.
- Format creators: running, pickleball, padel, tennis, yoga, pub quizzes,
  supper clubs.
- Host creators: people already convening groups through Instagram, WhatsApp,
  and event platforms.

Landing page fit:

- Creator-specific pages or UTMs to the relevant city/format page.

Notes:

- Require creator briefs, trackable links, landing-page variants, and content
  usage rights.
- Whitelisting/Spark/partnership ads should only happen after organic proof.

### WhatsApp, Telegram, Discord, and Closed Communities

Targeting primitive:

- Group topic, admin permission, trusted introductions, city proximity.

Best Catch use cases:

- India host and attendee pilots.
- Run clubs, racket groups, alumni groups, startup communities, apartment
  communities, coworking groups, and creator broadcast lists.

Landing page fit:

- Event invite page, waitlist page, or WhatsApp host inquiry link.

Notes:

- This is high-trust and easy to abuse. Use admin-approved posts and clear
  attribution.
- The landing page should be extremely direct: what, where, when, who it is for,
  price, safety/attendance rules, and CTA.

### Direct Host Outbound

Channels:

- LinkedIn, Instagram DMs, email, event marketplace profiles, venue websites,
  WhatsApp introductions.

Targeting primitive:

- Manually built lists by category, city, audience fit, and evidence of event
  consistency.

Best Catch use cases:

- Hosts abroad.
- Early India supply.
- Venues and communities where paid ads are too indirect.

Landing page fit:

- `/hosts/abroad`
- `/hosts/racket-sports`
- `/hosts/venues`
- A private demo page with screenshots, pricing assumptions, pilot offer, and
  sample event loop.

Notes:

- This should be a sales motion, not only a marketing motion.
- The best first question is usually not "Will you use our app?" It is "Can we
  help you sell out and run one format with less operational mess?"

### Offline and Guerrilla

Channels:

- Venue QR cards, event flyers, run-club/court partnerships, cafe table tents,
  coworking notice boards, campus/alumni events, launch parties, host referral
  cards, street teams near event venues.

Targeting primitive:

- Physical proximity to the venue, city, or activity.

Best Catch use cases:

- City launch density.
- Racket sports and social run formats.
- Conversion from real-world trust to app install or event booking.

Landing page fit:

- QR deep links to city, event, or format page.

Notes:

- Offline only works if the landing path is short and the event is real.
- Track by QR/UTM per venue and format.

## Use Case To Channel Map

| Use case | Most precise paid channel | Best non-paid channel | Landing page | CTA |
|---|---|---|---|---|
| Hosts abroad: existing singles-event organizers | LinkedIn company/job, Google Search, Meta retargeting | Event marketplace list building, Instagram DM, warm intros | `/hosts/abroad` | Book pilot call |
| Hosts abroad: Indian diaspora social communities | LinkedIn location plus community titles/interests, Instagram | Diaspora orgs, WhatsApp groups, cultural event pages | `/hosts/abroad/indian-community-events` | Host a pilot |
| India run club hosts | Google Search, Instagram, LinkedIn skills/groups | Instagram run clubs, Strava-like communities, city groups | `/hosts/run-clubs` | Bring your club |
| India racket sport venues | Meta/Instagram interests, LinkedIn industry/job, Google Search | Venue list outreach, coaches, courts, local creators | `/hosts/racket-sports` | Run a singles night |
| India dinner/pub/quiz hosts | Instagram, Google Search, LinkedIn hospitality/events | Event calendars, cafes/bars, quizmasters, food creators | `/hosts/venues` | Fill a social night |
| General public: singles events | Google Search, Apple Ads, Meta/Instagram | SEO, event listings, creator content | `/city/{city}/singles-events` | Join waitlist/book |
| General public: new to city | Reddit, Google Search, Quora, Meta | Reddit/Quora participation, SEO city guide | `/for/new-to-city` | Find a group event |
| General public: social run | Meta/Instagram, Google Search, YouTube | Run clubs, creator reels, WhatsApp groups | `/formats/social-run` | Join next run |
| General public: pickleball/padel singles | Meta/Instagram, TikTok, Google Search | Coaches, venues, creators, court communities | `/formats/racket-sports` | Join a rotation |
| General public: dinner/pub quiz | Meta/Instagram, TikTok, Google Search | Food/nightlife creators, event listings | `/formats/dinner-pub-quiz` | Save a seat |
| High-intent iOS installers | Apple Ads | ASO, App Store product page | Custom App Store page | Install |
| Returning site visitors | Meta, Google, Reddit, TikTok, LinkedIn retargeting | Email/WhatsApp follow-up | Last-viewed page | Complete signup |

## Landing Page Architecture

The website should become a routing system, not one generic homepage.

### Core Pages

- `/` - broad consumer and host split.
- `/host/` - durable host overview.
- `/city/{city}` - city-specific event promise and waitlist.
- `/hosts/abroad` - host pilot page for non-India city launches.
- `/hosts/india` - India host page with Razorpay/payment and city assumptions.

### Format Pages

- `/formats/social-run`
- `/formats/racket-sports`
- `/formats/dinner`
- `/formats/pub-quiz`
- `/formats/bar-crawl`
- `/formats/singles-mixer`
- `/formats/open-activity`

### Host Vertical Pages

- `/hosts/run-clubs`
- `/hosts/racket-sports`
- `/hosts/venues`
- `/hosts/creators`
- `/hosts/community-groups`
- `/hosts/event-organizers`

### Consumer Situation Pages

- `/for/new-to-city`
- `/for/dating-app-fatigue`
- `/for/working-professionals`
- `/for/weekend-plans`
- `/for/active-social-life`

### Page Requirements

Every page should define:

- Audience.
- Channel source.
- Targeting primitive.
- Promise.
- Proof needed.
- Conversion action.
- Tracking event.
- Policy risk.
- Allowed and disallowed ad copy.

## Creative And Copy Families

### Policy-Safer Social Event Family

Use when channel policy risk is high or dating permissions are not complete.

Angles:

- "Meet people offline through hosted city events."
- "Join social runs, racket rotations, dinners, and quiz nights."
- "A better way to find your next weekend plan."
- "For hosts who want turnout, check-in, and repeat community."

Avoid:

- Romantic promises.
- "Lonely" targeting.
- Sexualized or suggestive imagery.
- Implying the user has a personal problem.

### Direct Singles/Dating Family

Use when platform approvals and age targeting are clean.

Angles:

- "Curated singles events that become real dating context."
- "Meet at the event first. Match after you both show up."
- "Singles runs, dinners, racket rotations, and mixers in your city."
- "For hosts running high-quality singles events."

Requirements:

- 18+ targeting.
- Adult-looking models.
- Policy review by platform.
- Clear landing page and app-store consistency.

### Host Operating System Family

Angles:

- "Publish, balance, check in, guide, and report on social events."
- "Turn one event into a repeat singles community."
- "Less spreadsheet chaos. More attended events."
- "Built for hosts running runs, courts, dinners, quizzes, and mixers."

Best channels:

- LinkedIn, Google Search, Instagram, outbound, host partnerships.

## Measurement Architecture

### Required First-Party Events

Website:

- `page_view`
- `city_selected`
- `format_page_viewed`
- `host_vertical_viewed`
- `waitlist_started`
- `waitlist_submitted`
- `host_lead_started`
- `host_lead_submitted`
- `host_whatsapp_clicked`
- `app_store_clicked`
- `event_interest_submitted`

App:

- `install`
- `first_open`
- `phone_verified`
- `profile_completed`
- `club_joined`
- `event_viewed`
- `event_booked`
- `event_attended`
- `post_event_reaction_sent`
- `match_created`
- `host_club_created`
- `host_event_created`

### Seed Audiences

Use only with consent and legal review:

- Website visitors by page group.
- Host leads by vertical.
- Waitlist signups by city.
- App users by funnel stage.
- Booked attendees.
- Attended attendees.
- Hosts who created an event.
- High-quality hosts with repeat events.

### UTM Structure

Recommended pattern:

```text
utm_source={platform}
utm_medium={paid_social|paid_search|organic_social|community|partner|outbound|offline}
utm_campaign={geo}_{audience}_{format}_{objective}
utm_content={creative_hook}_{asset_type}_{variant}
utm_term={keyword_or_targeting_group}
```

Example:

```text
utm_source=reddit
utm_medium=community
utm_campaign=blr_consumer_newcity_waitlist
utm_content=weekend_social_text_v1
utm_term=bangalore_city_subreddit
```

## Testing Architecture

Do not test channels as blobs. Test one targeting primitive at a time.

### Phase 1: Learn Language And Intent

Channels:

- Google Search.
- Reddit organic/paid.
- Quora.
- Instagram organic.
- Direct host calls.

Questions:

- Which words do people use: singles events, meetups, hangouts, dating events,
  run clubs, weekend plans, social sport, new to city?
- Which format has strongest conversion by city?
- Which host segment replies fastest?

### Phase 2: Prove Segment Pages

Channels:

- Meta/Instagram.
- Google Search.
- LinkedIn host campaigns.
- TikTok creative tests.
- Retargeting.

Questions:

- Does a city page beat a generic homepage?
- Does a format page beat a city page?
- Does host vertical copy beat generic host copy?
- Which proof asset matters: host tools, event photos, attendee loop, safety,
  pricing, or screenshots?

### Phase 3: Scale With First-Party Data

Channels:

- Meta lookalikes/Advantage+.
- Google Demand Gen/App campaigns.
- TikTok lookalikes/smart targeting.
- LinkedIn predictive audiences.
- Reddit retargeting/lookalikes.

Questions:

- Which seed predicts bookings, not just cheap leads?
- Which seed predicts hosts who actually publish events?
- Which creative scales without degrading lead quality?

## Current Priority Recommendation

### P0: Build Supply And High-Intent Demand

1. Host outbound and LinkedIn for hosts abroad.
2. Instagram/manual outreach for host categories in India.
3. Google Search for city and format intent.
4. Reddit/Quora/SEO research around "new to city" and "meet people offline."
5. Meta/Instagram retargeting once landing pages and pixels are ready.

### P1: Prove Consumer Creative

1. Instagram Reels and creator content by city/format.
2. TikTok UGC-style format tests, subject to dating-policy gates.
3. Apple Ads once the app store page is live and relevant.
4. YouTube/Display retargeting for education.

### P2: Extend Reach

1. Snapchat for younger adult event awareness.
2. Pinterest for evergreen "date ideas" and city-planning content.
3. X for founder-led discourse and city launch announcements.
4. Podcasts/newsletters for city culture, fitness, and startup communities.
5. Offline QR/venue partnerships after real events exist.

## Major Channels Not In The Original Prompt

- TikTok.
- Snapchat.
- X.
- Pinterest.
- Quora.
- Apple Ads.
- Google Play and App Store ASO.
- YouTube.
- Google App campaigns.
- Bing/Microsoft Search.
- Programmatic/CTV/audio, only after message-market fit.
- Event marketplaces: Eventbrite, Luma, Meetup, Partiful, AllEvents, Insider.
- City newsletters and local media.
- Creator/influencer/ambassador programs.
- WhatsApp, Telegram, Discord, alumni, coworking, and apartment communities.
- Direct sales outbound.
- Venue partnerships.
- Offline QR and event-day guerrilla.
- Referral loops: attendee invites, host referrals, and private event links.

## Compliance And Brand Guardrails

- Treat Catch as a restricted dating advertiser whenever the ad or landing page
  promotes singles, dating, matchmaking, romantic outcomes, or post-event
  matches.
- Use 18+ targeting and adult-looking creative for all dating/singles copy.
- Do not imply knowledge of sensitive or negative personal attributes.
- Do not use fake user accounts for guerrilla marketing.
- Do not target vulnerable posts with intrusive replies.
- Do not invent social proof, match rates, revenue, user counts, or safety
  guarantees.
- Maintain separate copy families for "social events" and "singles/dating" so
  policy review does not block all acquisition.
- Do not upload sensitive first-party data to ad platforms without consent,
  policy review, and legal review.

## Open Questions

1. Which launch cities are active for India consumer campaigns?
2. Which abroad city should host acquisition prioritize first: New York, London,
   Dubai, Singapore, Toronto, or another market?
3. Are we ready to apply for dating-ad approvals on Google, Meta, TikTok, and
   Reddit, or should paid launch begin with social-event and host-tooling copy?
4. Which event formats are actually launch-ready in production, not just
   roadmap-visible?
5. What is the first conversion we optimize paid campaigns toward: waitlist,
   app install, event booking, host lead, or booked host call?
6. Which first-party data can legally and safely be used for retargeting and
   lookalike seeds?

## Source Notes

External platform documentation checked on 2026-05-31:

- Google Ads targeting and audience segments:
  https://support.google.com/google-ads/answer/1704368
  https://support.google.com/google-ads/answer/2497941
- Google location targeting:
  https://support.google.com/google-ads/answer/1722038
- Google app campaigns:
  https://support.google.com/google-ads/answer/6247380
- Google dating and companionship ads policy:
  https://support.google.com/adspolicy/answer/15328393
- Meta audience targeting, Advantage+ audience, and ad review:
  https://www.facebook.com/business/ads/ad-targeting
  https://www.facebook.com/business/ads/meta-advantage-plus/audience
  https://www.facebook.com/business/ads/review-policy-guidelines
- LinkedIn Ads targeting:
  https://www.linkedin.com/help/linkedin/answer/a424655
- LinkedIn targeting best practices:
  https://business.linkedin.com/advertise/ads/targeting/ad-targeting-best-practices
- Reddit ad targeting:
  https://www.business.reddit.com/advertise/targeting
- TikTok ad targeting:
  https://ads.us.tiktok.com/help/article/ad-targeting
- TikTok adult content and dating-app ad policy:
  https://ads.us.tiktok.com/help/article/tiktok-ads-policy-adult-content
- Apple Ads audience settings and search results:
  https://ads.apple.com/app-store/help/ad-groups/0021-modify-audience-settings
  https://ads.apple.com/app-store/help/ad-placements/0082-search-results
- Pinterest targeting:
  https://help.pinterest.com/en/business/article/targeting-overview
- Quora targeting:
  https://quoraadsupport.zendesk.com/hc/en-us/articles/115010467868-What-ad-targeting-options-are-available
- X Ads targeting:
  https://business.x.com/en/advertising/targeting
