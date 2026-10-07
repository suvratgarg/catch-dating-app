"use strict";

// The owner-private file anchors the original process before any HTTP page
// can load. No loopback document can supply or replace this key/capability.
function launchPage(clientOrigin, launch) {
  const fragment = Buffer.from(JSON.stringify(launch)).toString("base64url");
  const target = clientOrigin + "/operator-session#" + fragment;
  return `<!doctype html><html lang="en"><meta charset="utf-8"><meta name="referrer" content="no-referrer"><title>Catch protected session launch</title><h1>Catch operator session</h1><p>Open the protected Catch view. Sign in only through Catch’s normal Google UI. Never copy credentials.</p><button id="start">Open protected session UI</button><script>document.getElementById('start').onclick = () => { window.opener = null; location.replace(${JSON.stringify(target)}); };</script></html>`;
}
module.exports = {launchPage};
