# cave-copier

Copier template for uv-based Python projects. Generates five template types:
`oneoff`, `analysis`, `library`, `task`, `tabula-rasa`.

## Testing the Template Locally

**Critical:** Without `--vcs-ref HEAD`, copier defaults to the latest git tag and ignores
all uncommitted and staged changes. Always use `--vcs-ref HEAD` when testing local edits.

```bash
# Test a single type (e.g. library) against working tree
copier copy --vcs-ref HEAD --trust --defaults \
  -d template_type=library -d project_name="Test Library" \
  . /tmp/test-library

# Test all five types
for TYPE in oneoff analysis library task tabula-rasa; do
  rm -rf /tmp/test-$TYPE
  SLUG="${TYPE//-/_}"
  copier copy --vcs-ref HEAD --trust --defaults \
    -d template_type=$TYPE -d project_name="Test $TYPE" \
    . /tmp/test-$TYPE
  echo "=== $TYPE ===" && ls /tmp/test-$TYPE/test_${SLUG}/
done
```

The `--trust` flag is required because the template uses `jinja_extensions` and `tasks`.

## Template Structure

- `copier.yml` — questions, defaults, tasks, excludes
- `template/{{ directory_name }}/` — all generated files; Jinja filenames control
  which files appear per type (e.g. `{% if template_type == 'task' %}Dockerfile{% endif %}.jinja`)

## Making Changes

Edit files under `template/{{ directory_name }}/`, then test with the command above.
Commit and tag a release when ready (`git tag vX.Y.Z && git push --tags`).
