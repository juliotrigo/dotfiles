# Security Guidelines

## Mandatory Security Checks

- Never hardcode secrets (API keys, passwords, tokens) in code.
- Never stage or commit sensitive files (`.env`, `credentials.json`, `*.pem`). Warn Julio if staged.
- Never expose sensitive data in error messages, exceptions, or logs (including console output).

## Security Response Protocol

If security issue found:
1. STOP immediately
2. Alert Julio
3. Assess severity
4. Fix CRITICAL issues before continuing
5. Rotate any exposed secrets
