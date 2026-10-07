"use strict";
const {createHash} = require("node:crypto");

// No privileged response is available until the private file's one-use
// capability is consumed. Scrub the fragment before any browser interaction.
const script = String.raw`(async () => {
  let csrf, child, transfer, handshake, cancelled = false, transferred = false;
  const status = document.getElementById('status');
  const config = document.getElementById('config');
  const confirm = document.getElementById('confirm');
  const open = document.getElementById('open');
  const cancel = document.getElementById('cancel');
  const post = async (url, value, bootstrap) => {
    const response = await fetch(url, {method:'POST', credentials:'same-origin',
      headers:{'Content-Type':'application/json', ...(bootstrap ? {'X-Catch-Bootstrap':bootstrap} : {'X-Catch-CSRF':csrf})},
      body:JSON.stringify(value)});
    if (response.status === 409 && url === '/cancel') return {state:'saved'};
    if (!response.ok) throw new Error('unavailable');
    return response.json();
  };
  const capability = location.hash.slice(1);
  history.replaceState(null, '', '/');
  try {
    const initial = await post('/bootstrap', {}, capability);
    csrf = initial.csrf;
    document.getElementById('binding').textContent = JSON.stringify(initial.runtime);
    if (initial.profile) {config.value = JSON.stringify(initial.profile); config.readOnly = true;}
    confirm.disabled = false; cancel.disabled = false;
    status.textContent = 'Review the selected configuration. Never enter credentials here.';
  } catch {status.textContent = 'Open the owner-only launch file to start. Restart if it expired.';}
  confirm.onclick = async () => {
    confirm.disabled = true;
    try {
      transfer = await post('/configure', JSON.parse(config.value));
      if (cancelled) return;
      open.disabled = false;
      status.textContent = 'Configuration validated. Sign in through Catch’s normal Google UI first, then open the handoff view.';
    } catch {status.textContent = 'Configuration unavailable. No profile or session was saved. Restart to retry.';}
  };
  open.onclick = () => {
    if (cancelled || !transfer || child) return;
    child = window.open(transfer.clientOrigin + '/operator-session', '_blank');
    if (!child) status.textContent = 'The browser blocked the handoff window. Cancel and restart.';
    else handshake = setInterval(() => {
      if (cancelled) {clearInterval(handshake); return;}
      if (Date.now() >= transfer.request.expiresAtMillis || child.closed) {cancel.click(); return;}
      try {child.postMessage(transfer.request, transfer.clientOrigin);} catch {}
    }, 250);
    open.disabled = true;
  };
  cancel.onclick = async () => {
    cancelled = true; confirm.disabled = true; open.disabled = true;
    clearInterval(handshake);
    try {if (child && transfer) child.postMessage({kind:'catch-operator-session-cancel', challenge:transfer.request.challenge}, transfer.clientOrigin);} catch {}
    try {
      const receipt = await post('/cancel', {});
      status.textContent = receipt.state === 'saved' ? 'The session was already saved. Check the save receipt.' : 'Cancelled. No session will be saved.';
    } catch {status.textContent = 'Cancellation unconfirmed. Check the helper process before restarting.';}
  };
  window.addEventListener('message', async event => {
    if (cancelled || !transfer || event.source !== child || event.origin !== transfer.clientOrigin) return;
    const keys = event.data && Object.keys(event.data).sort().join(',');
    if (keys === 'challenge,kind' && event.data.kind === 'catch-operator-session-ready' && event.data.challenge === transfer.request.challenge) {
      clearInterval(handshake); return;
    }
    if (keys === 'challenge,kind' && event.data.kind === 'catch-operator-session-cancel' && event.data.challenge === transfer.request.challenge) {cancel.click(); return;}
    if (transferred) return;
    if (!event.data || Object.keys(event.data).sort().join(',') !== 'challenge,idToken,kind' ||
        event.data.kind !== 'catch-operator-session-transfer' || event.data.challenge !== transfer.request.challenge) return;
    const token = event.data.idToken;
    if (typeof token !== 'string' || token.length > 16384) return;
    transferred = true;
    try {
      const receipt = await post('/session', {challenge:transfer.request.challenge, idToken:token});
      if (cancelled) return;
      cancel.disabled = true;
      status.textContent = 'Session saved. It expires at ' + new Date(receipt.expiresAtMillis).toLocaleString() + '.';
    } catch {if (!cancelled) status.textContent = 'Save status unconfirmed. Check the local helper and session file before retrying.';}
  });
  window.addEventListener('beforeunload', () => {
    if (!csrf || cancelled) return;
    cancelled = true;
    try {if (child && transfer) child.postMessage({kind:'catch-operator-session-cancel', challenge:transfer.request.challenge}, transfer.clientOrigin);} catch {}
    void fetch('/cancel', {method:'POST', credentials:'same-origin', keepalive:true,
      headers:{'Content-Type':'application/json','X-Catch-CSRF':csrf},body:'{}'}).catch(() => {});
  });
})();`;
const html = `<!doctype html><html lang="en"><meta charset="utf-8"><title>Catch operator session</title>
<h1>Catch operator session</h1><p id="status">Open the protected launch file.</p>
<p>Selected source and runtime fingerprint:</p><pre id="binding"></pre>
<label for="config">Selected profile.json configuration. Do not enter tokens, passwords or secret payloads.</label><br>
<textarea id="config" rows="16" cols="80" autocomplete="off" spellcheck="false"></textarea><br>
<button id="confirm" disabled>Validate configuration</button>
<button id="open" disabled>Open Catch session handoff</button><button id="cancel" disabled>Cancel</button>
<p>This saves a short-lived session only. It creates no plan, approval or owner grant.</p><script>${script}</script></html>`;
const localPage = {html, scriptHash: createHash("sha256").update(script).digest("base64")};
const launchPage = (origin, capability) => `<!doctype html><html lang="en"><meta charset="utf-8"><meta name="referrer" content="no-referrer"><title>Catch protected launch</title><p>Opening your local protected session UI.</p><script>location.replace(${JSON.stringify(origin + "/#" + capability)});</script></html>`;
module.exports = {localPage, launchPage};
