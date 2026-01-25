---
paths:
  - "**/test_*.py"
  - "**/*_test.py"
  - "**/tests/**"
  - "**/*.test.js"
  - "**/*.test.ts"
  - "**/*.test.tsx"
  - "**/*.test.jsx"
  - "**/*.spec.js"
  - "**/*.spec.ts"
  - "**/*.spec.tsx"
  - "**/*.spec.jsx"
  - "**/__tests__/**"
---

# Testing Patterns

- Tests SHOULD pass consistently. Avoid flaky tests.
- When writing unit tests:
  - Keep them as simple as possible. It is ok to hard code strings, numbers, etc.
  - Each test SHOULD test one thing only. That does not equate to one assertion only. You can test one thing with multiple assertions.
  - Keep fixtures simple, up-to-date, and readable. Refactor them when tests evolve.
- Tests SHOULD NOT produce unexpected warnings or errors. Expected error messages SHOULD be explicitly asserted.
