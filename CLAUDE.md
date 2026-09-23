# cave-copier

Copier template for uv-based Python projects. Generates five template types:
`oneoff`, `analysis`, `library`, `task`, `tabula-rasa`.

## Testing the Template Locally

**Critical:** Without `--vcs-ref HEAD`, copier defaults to the latest git tag and ignores
all uncommitted and staged changes. Always use `--vcs-ref HEAD` when testing local edits.

```bash
# Test a single type (e.g. library) against working tree
copier copy --vcs-ref HEAD --trust --defaults \
  -d template_type=library \
  . /tmp/test-library

# Test all five types
for TYPE in oneoff analysis library task tabula-rasa; do
  rm -rf /tmp/test-$TYPE
  copier copy --vcs-ref HEAD --trust --defaults \
    -d template_type=$TYPE \
    . /tmp/test-$TYPE
  echo "=== $TYPE ===" && ls -A /tmp/test-$TYPE/
done
```

The `--trust` flag is required because the template uses `jinja_extensions` and `tasks`.

## Template Structure

- `copier.yml` — questions, defaults, tasks, excludes
- `template/` — all generated files, rendered directly into the copier destination
  (the destination *is* the project directory); Jinja filenames control
  which files appear per type (e.g. `{% if template_type == 'task' %}Dockerfile{% endif %}.jinja`)

## Making Changes

Edit files under `template/`, then test with the command above.
Commit and tag a release when ready (`git tag X.Y.Z && git push --tags`; tags have no `v` prefix).
