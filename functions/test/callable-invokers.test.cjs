const assert = require("node:assert/strict");
const test = require("node:test");
const {
  cloudRunPolicyPath,
  ensurePublicInvoker,
  listCallableServices,
} = require("../scripts/set-callable-invokers-public.cjs");

test("discovers every live callable service across pages", async () => {
  const paths = [];
  const services = await listCallableServices({
    projectId: "demo-project",
    token: "token",
    request: async ({path}) => {
      paths.push(path);
      if (!path.includes("pageToken=")) {
        return {
          functions: [
            {
              labels: {"deployment-callable": "true"},
              serviceConfig: {
                service:
                  "projects/demo/locations/asia-south1/services/current-callable",
              },
            },
            {
              labels: {"deployment-callable": "false"},
              serviceConfig: {
                service: "projects/demo/locations/asia-south1/services/http",
              },
            },
          ],
          nextPageToken: "next page",
        };
      }
      return {
        functions: [{
          labels: {"deployment-callable": true},
          serviceConfig: {
            service:
              "projects/demo/locations/asia-south1/services/retained-legacy",
          },
        }],
      };
    },
  });

  assert.deepEqual(services, [
    "projects/demo/locations/asia-south1/services/current-callable",
    "projects/demo/locations/asia-south1/services/retained-legacy",
  ]);
  assert.equal(paths.length, 2);
  assert.match(paths[1], /pageToken=next\+page/);
});

test("uses the exact live service resource and is idempotent", async () => {
  const calls = [];
  const service =
    "projects/demo/locations/asia-south1/services/send-event-broadcast";
  const changed = await ensurePublicInvoker({
    service,
    token: "token",
    request: async (request) => {
      calls.push(request);
      if (request.method === "GET") return {bindings: []};
      return {};
    },
  });
  assert.equal(changed, true);
  assert.equal(
    calls[0].path,
    `/v2/${service}:getIamPolicy?options.requestedPolicyVersion=3`,
  );
  assert.equal(
    calls[1].body.policy.bindings[0].members.includes("allUsers"),
    true,
  );

  const noChange = await ensurePublicInvoker({
    service,
    token: "token",
    request: async (request) => {
      assert.equal(request.method, "GET");
      return {
        bindings: [{role: "roles/run.invoker", members: ["allUsers"]}],
      };
    },
  });
  assert.equal(noChange, false);
});

test("rejects noncanonical Cloud Run service names", () => {
  assert.throws(
    () => cloudRunPolicyPath("send-event-broadcast", "getIamPolicy"),
    /Invalid Cloud Run service resource/,
  );
});
