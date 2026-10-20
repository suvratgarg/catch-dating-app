/* Fixed, opaque-origin runtime. Never attach to the parent diagnostic dataLayer.
 * No parent DOM/storage access, matching, referrers, automatic views or personalization.
 * Production activation and attribution acceptance remain separate gates. */
(() => {
  "use strict";
  let session = null;
  const observed = new Set();
  let configured = false;
  let adsConfigured = false;
  const choices = {
    audience: ["brand", "organizer", "attendee"],
    form: ["member_waitlist", "host_lead", "host_application", "claim"],
    utm_source: ["google", "meta", "newsletter", "catch", "partner"],
    utm_medium: ["cpc", "paid_social", "email", "organic", "referral"],
    utm_campaign: ["launch", "launch_2026", "planner_launch", "host_acquisition_2026", "synthetic_launch"],
    utm_content: ["host_hero", "host_footer", "claim_cta", "application_cta"],
  };
  const names = {page_view: "page_view", cta_click: "cta_click",
    acquisition_start: "acquisition_start", lead_accepted: "generate_lead"};
  window.addEventListener("message", (message) => {
    if (message.source !== parent || parent === window) return;
    const data = message.data;
    if (!data || typeof data !== "object") return;
    if (data.type === "catch:acquisition-init") {
      if (session || !["https://catchdates.com", "https://catch-dating-app-64e51--next-candidate-tnpxnhes.web.app"].includes(message.origin) || typeof data.channel !== "string" ||
          !/^[a-f0-9-]{36}$/u.test(data.channel) ||
          data.measurementId !== "G-HZFG0DL2DK" ||
          data.leadDestination !== "AW-18526407471/dUL7CNKBn6MdEK-WioJF") return;
      session = {channel: data.channel, origin: message.origin,
        measurementId: data.measurementId, leadDestination: data.leadDestination,
        preview: message.origin !== "https://catchdates.com"};
      window.dataLayer = [];
      window.gtag = function () { window.dataLayer.push(arguments); };
      window.gtag("consent", "default", {analytics_storage: "denied", ad_storage: "denied",
        ad_user_data: "denied", ad_personalization: "denied"});
      window.gtag("set", "ads_data_redaction", true);
      window.gtag("set", "url_passthrough", false);
      window.gtag("js", new Date());

      const script = document.createElement("script");
      script.async = true;
      script.referrerPolicy = "no-referrer";
      script.src = `https://www.googletagmanager.com/gtag/js?id=${session.measurementId}`;
      document.head.appendChild(script);
      return;
    }
    if (!session || data.type !== "catch:acquisition-event" ||
        data.channel !== session.channel || message.origin !== session.origin) return;
    const event = data.event;
    if (!event || !Object.hasOwn(names, event.name) || event.consent?.analytics !== true) return;
    const p = event.parameters;
    if (!p || typeof p.page_path !== "string" || p.page_path === "/" ||
        p.audience !== "organizer" || p.form === "member_waitlist" ||
        !/^\/(?:|host\/|host\/(?:overview|platform|planners|clubs|directory|claim|apply|stack|workflows)\/|claim\/)$/u.test(p.page_path)) return;
    const context = event.attribution;
    const hasIdentity = context && typeof context.clientId === "string" &&
      /^\d{1,10}\.\d{10}$/u.test(context.clientId) && Number.isSafeInteger(context.sessionId) &&
      context.sessionId >= 1_000_000_000 && context.sessionId <= 9_999_999_999;
    const params = {page_location: `https://catchdates.com${p.page_path}`,
      page_referrer: "", page_title: "Catch"};
    if (session.preview) { params.debug_mode = true; params.traffic_type = "internal"; }
    if (hasIdentity) {
      params.client_id = context.clientId;
      params.session_id = context.sessionId;
      // The parent owns the consented, time-limited identifier. This sandbox still
      // cannot set/read Catch cookies or see any other parent storage.
      window.gtag("consent", "update", {analytics_storage: "granted", ad_storage: "denied",
        ad_user_data: event.consent.marketing === true ? "granted" : "denied",
        ad_personalization: "denied"});
      window.gtag("set", "ads_data_redaction", event.consent.marketing !== true);
      if (event.consent.marketing === true) {
        const clicks = new URLSearchParams();
        for (const key of ["gclid", "gbraid", "wbraid"]) {
          if (typeof context[key] === "string" && /^[A-Za-z0-9_-]{10,512}$/u.test(context[key])) clicks.set(key, context[key]);
        }
        if (clicks.size) params.page_location += `?${clicks}`;
      }
    }
    // Re-project even an in-process message; unknown fields never become tags.
    for (const [key, allowed] of Object.entries(choices)) {
      if (allowed.includes(p[key])) params[key] = p[key];
    }
    // GA4 campaign attribution uses campaign_* fields, not custom utm_* fields.
    for (const [utm, field] of Object.entries({utm_source: "campaign_source", utm_medium: "campaign_medium",
      utm_campaign: "campaign_name", utm_content: "campaign_content"})) {
      if (params[utm]) params[field] = params[utm];
    }
    if (!configured) {
      configured = true;
      window.gtag("config", session.measurementId, {...params, send_page_view: false,
        allow_google_signals: false, allow_ad_personalization_signals: false});
    }
    if (event.name === "lead_accepted") {
      if (!/^((waitlist|host_lead|catch)_[0-9]{13}_([a-f0-9-]{36}|[a-z0-9]{8,24}))$/u.test(p.event_id ?? "") ||
          observed.has(p.event_id) || observed.size >= 4096) return;
      observed.add(p.event_id);
      params.event_id = p.event_id;
    }
    window.gtag("event", names[event.name], {...params, send_to: session.measurementId});
    if (!session.preview && event.name === "lead_accepted" && event.consent.marketing === true &&
        p.audience === "organizer" && ["host_lead", "host_application"].includes(p.form) &&
        /^((waitlist|host_lead|catch)_[0-9]{13}_([a-f0-9-]{36}|[a-z0-9]{8,24}))$/u.test(p.event_id ?? "")) {
      if (!adsConfigured) {
        adsConfigured = true;
        window.gtag("config", "AW-18526407471", {...params, send_page_view: false,
          allow_ad_personalization_signals: false});
      }
      window.gtag("event", "conversion", {...params, send_to: session.leadDestination,
        transaction_id: p.event_id});
    }
  });
})();
