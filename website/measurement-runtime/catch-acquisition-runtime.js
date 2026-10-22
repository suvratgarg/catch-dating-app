/* Preview-only Google runtime on a dedicated static origin. No parent DOM,
 * storage, contact data, advertising delivery or production activation. */
(() => {
  "use strict";
  const runtimeOrigin = "https://catch-host-measurement.web.app";
  const previewOrigin = "https://catch-dating-app-64e51--next-candidate-tnpxnhes.web.app";
  const measurementId = "G-HZFG0DL2DK";
  if (window.location.origin !== runtimeOrigin || parent === window) return;
  let session = null;
  let stopped = false;
  let configured = false;
  const observed = new Set();
  const choices = {
    audience: ["organizer"], form: ["host_lead", "host_application", "claim"],
    utm_source: ["google", "meta", "newsletter", "catch", "partner"],
    utm_medium: ["cpc", "paid_social", "email", "organic", "referral"],
    utm_campaign: ["launch", "launch_2026", "planner_launch", "host_acquisition_2026", "synthetic_launch"],
    utm_content: ["host_hero", "host_footer", "claim_cta", "application_cta"],
  };
  const names = {page_view: "page_view", cta_click: "cta_click",
    acquisition_start: "acquisition_start", lead_accepted: "generate_lead"};
  function clearCookies() {
    // This origin hosts only this runtime. Also remove the unprefixed cookies
    // left by an earlier reviewed experiment; never touch Catch-site storage.
    for (const part of document.cookie.split(";")) {
      const name = part.split("=")[0].trim();
      if (/^(?:catch_host_ga|_ga)(?:_[A-Z0-9]+)?$/u.test(name)) {
        document.cookie = `${name}=; Max-Age=0; Path=/; Secure; SameSite=None`;
      }
    }
  }
  function stop() {
    if (stopped) return;
    stopped = true;
    window[`ga-disable-${measurementId}`] = true;
    // Tighten the document policy before SDK teardown. Existing batch timers,
    // pagehide handlers and consent pings cannot start another network send.
    const policy = document.createElement("meta");
    policy.httpEquiv = "Content-Security-Policy";
    policy.content = "default-src 'none'; connect-src 'none'; img-src 'none'; script-src 'none'";
    document.head.appendChild(policy);
    clearCookies();
    if (session) parent.postMessage({type: "catch:acquisition-stopped", channel: session.channel}, session.origin);
  }
  window.addEventListener("pagehide", stop, {once: true});
  window.addEventListener("message", (message) => {
    if (stopped || message.source !== parent || message.origin !== previewOrigin) return;
    const data = message.data;
    if (!data || typeof data !== "object") return;
    if (data.type === "catch:acquisition-init") {
      if (session || typeof data.channel !== "string" || !/^[a-f0-9-]{36}$/u.test(data.channel) ||
          data.measurementId !== measurementId) return;
      session = {channel: data.channel, origin: message.origin};
      // Never reuse a previous SDK cookie. Catch supplies its reviewed, consented
      // client/session context for every event, with a fixed lifetime.
      clearCookies();
      window.dataLayer = [];
      window.gtag = function () { window.dataLayer.push(arguments); };
      window.gtag("consent", "default", {analytics_storage: "denied", ad_storage: "denied",
        ad_user_data: "denied", ad_personalization: "denied"});
      window.gtag("set", "ads_data_redaction", true);
      window.gtag("set", "url_passthrough", false);
      window.gtag("js", new Date());
      // Load the SDK only after a validated analytics event below.
      return;
    }
    if (!session || data.channel !== session.channel) return;
    if (data.type === "catch:acquisition-stop") { stop(); return; }
    if (data.type !== "catch:acquisition-event") return;
    const event = data.event;
    if (!event || !Object.hasOwn(names, event.name) || event.consent?.analytics !== true) return;
    const p = event.parameters;
    if (!p || p.audience !== "organizer" || p.form === "member_waitlist" ||
        typeof p.page_path !== "string" ||
        !/^\/(?:host\/(?:overview\/|platform\/|planners\/|clubs\/|directory\/|claim\/|apply\/|stack\/|workflows\/)?|claim\/)$/u.test(p.page_path)) return;
    const context = event.attribution;
    if (!context || typeof context.clientId !== "string" || !/^\d{1,10}\.\d{10}$/u.test(context.clientId) ||
        !Number.isSafeInteger(context.sessionId) || context.sessionId < 1_000_000_000 || context.sessionId > 9_999_999_999) return;
    const born = Number(context.clientId.split(".")[1]);
    const age = Math.floor(Date.now() / 1000) - born;
    const remaining = 30 * 24 * 60 * 60 - age;
    if (age < 0 || remaining <= 0) return;
    if (event.name === "lead_accepted") {
      if (!/^(?:waitlist|host_lead|catch)_[0-9]{13}_(?:[a-f0-9-]{36}|[a-z0-9]{8,24})$/u.test(p.event_id ?? "") ||
          observed.has(p.event_id) || observed.size >= 4096) return;
      observed.add(p.event_id);
    }
    const params = {page_location: `https://catchdates.com${p.page_path}`, page_referrer: "", page_title: "Catch",
      debug_mode: true, traffic_type: "internal", client_id: context.clientId, session_id: context.sessionId};
    for (const [key, allowed] of Object.entries(choices)) if (allowed.includes(p[key])) params[key] = p[key];
    for (const [utm, field] of Object.entries({utm_source: "campaign_source", utm_medium: "campaign_medium",
      utm_campaign: "campaign_name", utm_content: "campaign_content"})) if (params[utm]) params[field] = params[utm];
    if (event.name === "lead_accepted") params.event_id = p.event_id;
    if (!configured) {
      configured = true;
      window.gtag("consent", "update", {analytics_storage: "granted", ad_storage: "denied",
        ad_user_data: "denied", ad_personalization: "denied"});
      window.gtag("config", measurementId, {...params, send_page_view: false,
        allow_google_signals: false, allow_ad_personalization_signals: false,
        cookie_domain: "none", cookie_prefix: "catch_host", cookie_flags: "SameSite=None;Secure",
        cookie_expires: remaining, cookie_update: false});
      const script = document.createElement("script");
      script.async = true;
      script.referrerPolicy = "no-referrer";
      script.src = `https://www.googletagmanager.com/gtag/js?id=${measurementId}`;
      document.head.appendChild(script);
    }
    window.gtag("event", names[event.name], {...params, send_to: measurementId});
  });
})();
