# Python Patterns

Tooling:
- Use uv for dependency management and packaging (not pip, poetry, or easy_install)
- Use ruff for linting and formatting

Mock Patterns:
- Always prefer pytest fixtures over in-line patching or decorator-based patching
- Use pytest fixtures with patch() context managers instead of inline Mock() creation
- Create descriptive fixture names with clear documentation

Assertion Patterns:
- Always use call_args_list instead of call_count, call_args, or assert_called_once_with() methods
- Use call() objects for explicit call verification: assert mock.method.call_args_list == [call(args)]
- NEVER extract individual calls or kwargs: NO .call_args_list[0], NO .call_args_list[0].kwargs
- Check for no calls with: assert mock.method.call_args_list == []
- For dynamic values (datetime, UUIDs, etc), use deterministic mocking (freezegun, fixed values) instead of ANY matcher
- Prefer exact assertions: assert x == y over assert y in x
- For string prefix checks, use assert x.startswith('prefix') instead of assert 'prefix' in x
