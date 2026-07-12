import {defineConfig} from "vite";
import react from "@vitejs/plugin-react";
import {fileURLToPath} from "node:url";
import {createCatchReactViteConfig} from "../packages/web-config/vite-react";

export default defineConfig({
  ...createCatchReactViteConfig({
    plugins: [react()],
    publicDir: "public",
  }),
  resolve: {
    alias: {
      "@content": fileURLToPath(new URL("./src/content", import.meta.url)),
    },
  },
});
