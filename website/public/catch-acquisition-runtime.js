/* Fixed, opaque-origin runtime. Never attach to the parent diagnostic dataLayer.
 * No cookies, matching, click IDs, referrers, automatic views or personalization.
 * Production activation and attribution acceptance remain separate gates. */
(() => {
  "use strict";
  let session = null;
  const observed = new Set();
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
      if (session || message.origin !== "https://catchdates.com" || typeof data.channel !== "string" ||
          !/^[a-f0-9-]{36}$/u.test(data.channel) ||
          data.measurementId !== "G-HZFG0DL2DK" ||
          data.leadDestination !== "AW-18526407471/dUL7CNKBn6MdEK-WioJF") return;
      session = {channel: data.channel, origin: message.origin,
        measurementId: data.measurementId, leadDestination: data.leadDestination};
      window.dataLayer = [];
      window.gtag = function () { window.dataLayer.push(arguments); };
      window.gtag("consent", "default", {analytics_storage: "denied", ad_storage: "denied",
        ad_user_data: "denied", ad_personalization: "denied"});
      window.gtag("set", "ads_data_redaction", true);
      window.gtag("set", "url_passthrough", false);
      window.gtag("js", new Date());
      window.gtag("config", session.measurementId, {send_page_view: false,
        allow_google_signals: false, allow_ad_personalization_signals: false,
        page_location: "https://catchdates.com/host/", page_referrer: "", page_title: "Catch"});
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
    if (!p || typeof p.page_path !== "string" ||
        !/^\/(?:|host\/|host\/(?:overview|platform|planners|clubs|directory|claim|apply|stack|workflows)\/|claim\/)$/u.test(p.page_path)) return;
    const params = {page_location: `https://catchdates.com${p.page_path}`,
      page_referrer: "", page_title: "Catch"};
    // Re-project even an in-process message; unknown fields never become tags.
    for (const [key, allowed] of Object.entries(choices)) {
      if (allowed.includes(p[key])) params[key] = p[key];
    }
    if (event.name === "lead_accepted") {
      if (!/^((waitlist|host_lead|catch)_[0-9]{13}_([a-f0-9-]{36}|[a-z0-9]{8,24}))$/u.test(p.event_id ?? "") ||
          observed.has(p.event_id) || observed.size >= 4096) return;
      observed.add(p.event_id);
    }
    window.gtag("event", names[event.name], {...params, send_to: session.measurementId});
    if (event.name === "lead_accepted" && event.consent.marketing === true &&
        p.audience === "organizer" && ["host_lead", "host_application"].includes(p.form) &&
        /^((waitlist|host_lead|catch)_[0-9]{13}_([a-f0-9-]{36}|[a-z0-9]{8,24}))$/u.test(p.event_id ?? "")) {
      window.gtag("event", "conversion", {...params, send_to: session.leadDestination,
        transaction_id: p.event_id});
    }
  });
})();
