export default {
  testEnvironment: "node",
  transform: {},
  extensionsToTreatAsEsm: [".js"],
  moduleNameMapper: {
    "^(\\.{1,2}/.*)\\.js$": "$1",
  },
  coverageDirectory: "coverage",
  collectCoverageFrom: ["src/**/*.js", "!src/server.js", "!**/node_modules/**"],
  testMatch: ["**/tests/**/*.test.js"],
  verbose: true,
};
