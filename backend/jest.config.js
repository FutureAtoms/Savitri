module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: [
    '**/__tests__/**/*.[jt]s?(x)',
    '**/?(*.)+(spec|test).[jt]s?(x)',
    '**/persistence/__tests__/**/*.[jt]s?(x)',
  ],
  collectCoverageFrom: [
    "clinical/**/*.ts",
    "integrations/**/*.ts",
    "models/**/*.ts",
    "persistence/**/*.ts",
    "security/**/*.ts",
    "!**/*.d.ts",
    "!**/node_modules/**",
    "!**/__tests__/**"
  ],
  coverageThreshold: {
    "global": {
      "branches": 30,
      "functions": 45,
      "lines": 45,
      "statements": 45
    }
  },
  testPathIgnorePatterns: ["/node_modules/"],
}; 