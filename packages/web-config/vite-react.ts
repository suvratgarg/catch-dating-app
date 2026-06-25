interface CatchReactViteOptions {
  plugins?: unknown[];
  publicDir?: string | false;
}

const publicSourcemapsEnabled =
  process.env.CATCH_WEB_PUBLIC_SOURCEMAPS === "true";

export function createCatchReactViteConfig({
  plugins = [],
  publicDir,
}: CatchReactViteOptions = {}): any {
  return {
    plugins,
    ...(publicDir === undefined ? {} : {publicDir}),
    build: {
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
