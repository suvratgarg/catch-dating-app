import {cp, mkdir} from "node:fs/promises";
import {fileURLToPath} from "node:url";
import {spawn} from "node:child_process";
import path from "node:path";
const root = fileURLToPath(new URL("../../", import.meta.url));
const runtime = path.join(root, ".next/standalone/website");
await mkdir(path.join(runtime, ".next"), {recursive: true});
await cp(path.join(root, "public"), path.join(runtime, "public"), {recursive: true});
await cp(path.join(root, ".next/static"), path.join(runtime, ".next/static"), {recursive: true});
const child = spawn(process.execPath, [path.join(runtime, "server.js")], {
  stdio: "inherit", env: {...process.env, HOSTNAME: "127.0.0.1", PORT: process.env.PORT ?? "3107"},
});
for (const signal of ["SIGTERM", "SIGINT"]) process.on(signal, () => child.kill(signal));
child.on("exit", code => {process.exitCode = code ?? 1;});
