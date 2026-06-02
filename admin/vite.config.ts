import {defineConfig} from "vite";
import react from "@vitejs/plugin-react";
import {createCatchReactViteConfig} from "../packages/web-config/vite-react";

export default defineConfig(
  createCatchReactViteConfig({
    plugins: [react()],
  })
);
