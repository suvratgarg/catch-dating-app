import type {Preview} from "@storybook/react-vite";
import {createElement} from "react";
import {WebsiteQueryProvider} from "../src/shared/query/queryClient";
import "../src/styles.css";

const preview: Preview = {
  decorators: [
    (Story) => createElement(WebsiteQueryProvider, null, createElement(Story)),
  ],
  parameters: {
    a11y: {
      test: "error",
    },
    layout: "fullscreen",
  },
};

export default preview;
