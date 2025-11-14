export default {
  testEnvironment: "node",
  transform: {
    "^.+\\.js$": "babel-jest",
  },
  transformIgnorePatterns: ["/node_modules/(?!@prisma/client)", "\\.pnp\\.[^\\/]+$"],
  moduleNameMapper: {
    "^(\\.{1,2}/.*)\\.js$": "$1",
  },
  coverageDirectory: "coverage",
  collectCoverageFrom: ["src/**/*.js", "!src/server.js", "!**/node_modules/**"],
  testMatch: ["**/tests/**/*.test.js"],
  verbose: true,
  testTimeout: 30000,
  forceExit: true,
  detectOpenHandles: true,
  // global setup/teardown disabled to avoid require() vs ESM TLA conflicts
};
