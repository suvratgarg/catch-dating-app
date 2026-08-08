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
  async viteFinal(baseConfig) {
    return {
      ...baseConfig,
      // Storybook's staticDirs is the sole owner of the public-tree copy.
      // Letting Vite copy the same tree races on nested directories in CI.
      publicDir: false,
    };
  },
};

export default config;
