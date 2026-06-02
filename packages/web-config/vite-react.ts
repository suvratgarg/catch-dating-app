interface CatchReactViteOptions {
  plugins?: unknown[];
  publicDir?: string | false;
}

export function createCatchReactViteConfig({
  plugins = [],
  publicDir,
}: CatchReactViteOptions = {}): any {
  return {
    plugins,
    ...(publicDir === undefined ? {} : {publicDir}),
    build: {
      outDir: "dist",
      sourcemap: true,
    },
    server: {
      fs: {
        allow: [".."],
      },
    },
  };
}
