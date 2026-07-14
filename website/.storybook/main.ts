import type {StorybookConfig} from "@storybook/react-vite";

const config: StorybookConfig = {
  addons: ["@storybook/addon-a11y", "@storybook/addon-vitest"],
  framework: {
    name: "@storybook/react-vite",
    options: {},
  },
  staticDirs: ["../public"],
  stories: [
    "../src/**/*.stories.@(ts|tsx)",
    "../../packages/web-ui/src/**/*.stories.@(ts|tsx)",
  ],
};

export default config;
