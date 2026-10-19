import {prepareStandalone} from "./prepareStandalone.mjs";
import {fileURLToPath} from "node:url";
import {spawn} from "node:child_process";
import path from "node:path";
const root = fileURLToPath(new URL("../../", import.meta.url));
const runtime = path.join(root, ".next/standalone/website");
await prepareStandalone(root);
const child = spawn(process.execPath, [path.join(runtime, "server.js")], {
  stdio: "inherit", env: {...process.env, HOSTNAME: "127.0.0.1", PORT: process.env.PORT ?? "3107"},
});
for (const signal of ["SIGTERM", "SIGINT"]) process.on(signal, () => child.kill(signal));
child.on("exit", code => {process.exitCode = code ?? 1;});
