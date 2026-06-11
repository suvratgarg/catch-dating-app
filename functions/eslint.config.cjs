const js = require("@eslint/js");
const {FlatCompat} = require("@eslint/eslintrc");

const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
  allConfig: js.configs.all,
});

function withoutRemovedCoreRules(config) {
  const rules = {...config.rules};
  delete rules["require-jsdoc"];
  delete rules["valid-jsdoc"];

  return {
    ...config,
    rules,
  };
}

module.exports = [
  {
    ignores: [
      "lib/**",
      "generated/**",
      "src/shared/generated/**",
    ],
  },
  ...compat.env({
    es6: true,
    node: true,
  }),
  ...compat
    .extends(
      "eslint:recommended",
      "plugin:import/errors",
      "plugin:import/warnings",
      "plugin:import/typescript",
      "google",
      "plugin:@typescript-eslint/recommended",
    )
    .map(withoutRemovedCoreRules),
  {
    files: ["src/**/*.ts"],
    languageOptions: {
      parserOptions: {
        project: ["tsconfig.json"],
        tsconfigRootDir: __dirname,
        sourceType: "module",
      },
    },
    rules: {
      quotes: ["error", "double"],
      "import/no-unresolved": 0,
      indent: ["error", 2],
    },
  },
];
