import {cp, mkdir, rm} from "node:fs/promises";
import path from "node:path";

/** Package only generated runtime assets; never write into the public source tree. */
export async function prepareStandalone(root) {
  const runtime = path.join(root, ".next/standalone/website");
  await mkdir(path.join(runtime, ".next"), {recursive: true});
  // Repeated packaging must not retain chunks from an earlier build.
  await rm(path.join(runtime, "public"), {recursive: true, force: true});
  await rm(path.join(runtime, ".next/static"), {recursive: true, force: true});
  await cp(path.join(root, "public"), path.join(runtime, "public"), {recursive: true,
    filter: source => source !== path.join(root, "public/_legacy")});
  await cp(path.join(root, ".next-legacy"), path.join(runtime, "public/_legacy"), {recursive: true});
  await cp(path.join(root, ".next/static"), path.join(runtime, ".next/static"), {recursive: true});
  return runtime;
}
