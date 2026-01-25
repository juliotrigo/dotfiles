---
paths:
  - "**/test_*.py"
  - "**/*_test.py"
  - "**/tests/**/*.py"
---

# Python Testing

## Mock Patterns

- Prefer pytest fixtures over in-line patching or decorator-based patching
- Use pytest fixtures with patch() context managers instead of inline Mock() creation
- Create descriptive fixture names with clear documentation

## Assertion Patterns

- Use call_args_list instead of call_count, call_args, or assert_called_once_with() methods
- Use call() objects for explicit call verification: assert mock.method.call_args_list == [call(args)]
- Do not extract individual calls or kwargs: NO .call_args_list[0], NO .call_args_list[0].kwargs
- Check for no calls with: assert mock.method.call_args_list == []
- For dynamic values (datetime, UUIDs, etc), use deterministic mocking (freezegun, fixed values) instead of ANY matcher
- Prefer exact assertions: assert x == y over assert y in x
- For string prefix checks, use assert x.startswith('prefix') instead of assert 'prefix' in x
