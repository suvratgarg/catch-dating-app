#!/usr/bin/env node

const baseUrl = String(process.argv[2] ?? "").replace(/\/+$/u, "");
if (!/^https?:\/\//u.test(baseUrl)) {
  console.error("Usage: node website/scripts/verifyHosting404.mjs <base-url>");
  process.exit(64);
}

const probeUrl = `${baseUrl}/__catch_http_404_probe_${Date.now()}__/`;
const response = await fetch(probeUrl, {redirect: "manual"});
if (response.status !== 404) {
  console.error(
    `Marketing Hosting 404 probe failed: expected 404, received ${response.status} for ${probeUrl}`
  );
  process.exit(1);
}

console.log(`Marketing Hosting 404 probe passed: ${probeUrl} returned 404.`);
