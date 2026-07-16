interface CatchReactViteOptions {
  manifest?: boolean;
  plugins?: unknown[];
  publicDir?: string | false;
}

const publicSourcemapsEnabled =
  process.env.CATCH_WEB_PUBLIC_SOURCEMAPS === "true";

export function createCatchReactViteConfig({
  manifest = false,
  plugins = [],
  publicDir,
}: CatchReactViteOptions = {}): any {
  return {
    plugins,
    ...(publicDir === undefined ? {} : {publicDir}),
    build: {
      manifest,
      outDir: "dist",
      sourcemap: publicSourcemapsEnabled,
    },
    server: {
      fs: {
        allow: [".."],
      },
    },
  };
}
