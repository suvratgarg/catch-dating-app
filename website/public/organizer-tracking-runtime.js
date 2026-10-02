/* Fixed vendor loaders in an opaque sandbox. No custom URLs, snippets, GTM,
 * automatic matching, user data, titles, query parameters or conversion events.
 * Cookie-dependent attribution is intentionally unavailable in this sandbox.
 */
(() => {
  "use strict";
  let session = null;
  let emit = null;
  function load(src) {
    const script = document.createElement("script");
    script.async = true;
    script.src = src;
    script.referrerPolicy = "no-referrer";
    document.head.appendChild(script);
  }
  window.addEventListener("message", (message) => {
    if (message.source !== parent || parent === window) return;
    const data = message.data;
    if (!data || typeof data !== "object") return;
    if (data.type === "catch:provider-init") {
      if (session || typeof data.channel !== "string" || data.channel.length > 100 ||
          !/^\/(organizers|events)\/[A-Za-z0-9_-]{1,160}\/$/u.test(data.publicPath) ||
          data.publicOrigin !== message.origin || !/^https?:\/\//u.test(message.origin)) return;
      const location = `${message.origin}${data.publicPath}`;
      if (data.provider === "ga4" && /^G-[A-Z0-9]{4,20}$/u.test(data.id)) {
        window.dataLayer = [];
        window.gtag = function () { window.dataLayer.push(arguments); };
        // No storage, ads, Google signals or personalization. Explicit consent
        // was checked by the parent before creating this runtime; denied-mode
        // here avoids cookie access in the sandbox, not unconsented loading.
        window.gtag("consent", "default", {analytics_storage: "denied", ad_storage: "denied",
          ad_user_data: "denied", ad_personalization: "denied"});
        window.gtag("js", new Date());
        window.gtag("config", data.id, {send_page_view: false, allow_google_signals: false,
          allow_ad_personalization_signals: false, page_location: location,
          page_referrer: "", page_title: "Catch public page"});
        emit = (event) => window.gtag("event", event, {send_to: data.id,
          page_location: location, page_referrer: "", page_title: "Catch public page"});
        load(`https://www.googletagmanager.com/gtag/js?id=${encodeURIComponent(data.id)}`);
      } else if (data.provider === "meta" && /^[0-9]{5,20}$/u.test(data.id)) {
        const fbq = function () {
          if (fbq.callMethod) fbq.callMethod.apply(fbq, arguments);
          else fbq.queue.push(arguments);
        };
        fbq.queue = []; fbq.loaded = true; fbq.version = "2.0";
        fbq.push = fbq; window.fbq = fbq; window._fbq = fbq;
        fbq("set", "autoConfig", false, data.id);
        fbq("consent", "grant");
        fbq("init", data.id);
        emit = (event) => event === "page_view"
          ? fbq("trackSingle", data.id, "PageView", {public_path: data.publicPath})
          : fbq("trackSingleCustom", data.id, "OutboundBookingClick", {public_path: data.publicPath});
        load("https://connect.facebook.net/en_US/fbevents.js");
      } else return;
      session = {channel: data.channel, origin: message.origin};
    } else if (session && data.type === "catch:provider-event" &&
        data.channel === session.channel && message.origin === session.origin &&
        (data.event === "page_view" || data.event === "outbound_booking_click")) {
      emit(data.event);
    }
  });
})();
