#!/bin/bash
# Test script for copier templates
# Generates all five template types from the working tree (HEAD plus uncommitted
# changes) and runs basic validation, then checks that `copier update` from the
# latest release tag to HEAD applies cleanly in place.

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR=$(mktemp -d)
echo "Testing templates in: $TEST_DIR"

# Cleanup function
cleanup() {
    echo "Cleaning up test directory..."
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

# Function to test a template type
test_template() {
    local template_type=$1
    local project_name="test-${template_type}"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Testing template: $template_type"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    cd "$TEST_DIR"

    # Generate project with copier. --vcs-ref HEAD tests the working tree, not the latest tag.
    copier copy --vcs-ref HEAD --trust --defaults \
        --data "template_type=${template_type}" \
        --data "project_name=${project_name}" \
        --data "project_slug=${project_name//-/_}" \
        --data "project_description=Test project for ${template_type}" \
        --data "user_name=Test User" \
        --data "user_email=test@example.com" \
        --data "github_user=testuser" \
        --data "initial_version=0.0.1" \
        --data "python_version=3.13" \
        --data "use_vim_jupyter=true" \
        "$SCRIPT_DIR" \
        "${project_name}"

    cd "${project_name}"

    # Basic file checks
    echo "✓ Checking essential files exist..."
    [ -f "pyproject.toml" ] || { echo "✗ pyproject.toml missing"; exit 1; }
    [ -f "README.md" ] || { echo "✗ README.md missing"; exit 1; }
    [ -f ".gitignore" ] || { echo "✗ .gitignore missing"; exit 1; }
    [ -f "LICENSE" ] || { echo "✗ LICENSE missing"; exit 1; }
    [ -f ".copier-answers.yml" ] || { echo "✗ .copier-answers.yml missing"; exit 1; }
    [ -d "src" ] || { echo "✗ src/ directory missing"; exit 1; }

    # Type-specific checks
    case $template_type in
        oneoff)
            echo "✓ Checking oneoff-specific files..."
            [ -f "notebook.ipynb" ] || { echo "✗ notebook.ipynb missing"; exit 1; }
            [ ! -f ".pre-commit-config.yaml" ] || { echo "✗ .pre-commit-config.yaml should not exist"; exit 1; }
            ;;
        analysis)
            echo "✓ Checking analysis-specific files..."
            [ -f ".pre-commit-config.yaml" ] || { echo "✗ .pre-commit-config.yaml missing"; exit 1; }
            [ ! -d "tests" ] || { echo "✗ tests/ should not exist in analysis"; exit 1; }
            ;;
        library)
            echo "✓ Checking library-specific files..."
            [ -f ".pre-commit-config.yaml" ] || { echo "✗ .pre-commit-config.yaml missing"; exit 1; }
            [ -d "tests" ] || { echo "✗ tests/ directory missing"; exit 1; }
            [ -d "docs" ] || { echo "✗ docs/ directory missing"; exit 1; }
            [ -f "mkdocs.yml" ] || { echo "✗ mkdocs.yml missing"; exit 1; }
            [ -d ".github/workflows" ] || { echo "✗ .github/workflows missing"; exit 1; }
            [ -d "scratch" ] || { echo "✗ scratch/ directory missing"; exit 1; }
            ;;
        task)
            echo "✓ Checking task-specific files..."
            [ -f ".pre-commit-config.yaml" ] || { echo "✗ .pre-commit-config.yaml missing"; exit 1; }
            [ -f "Dockerfile" ] || { echo "✗ Dockerfile missing"; exit 1; }
            [ -d "config" ] || { echo "✗ config/ directory missing"; exit 1; }
            [ -f "config/task.env" ] || { echo "✗ config/task.env missing"; exit 1; }
            [ -f "config/task.env.example" ] || { echo "✗ config/task.env.example missing"; exit 1; }
            [ -d "templates" ] || { echo "✗ templates/ directory missing"; exit 1; }
            ;;
        tabula-rasa)
            echo "✓ Checking tabula-rasa-specific files..."
            [ -f ".pre-commit-config.yaml" ] || { echo "✗ .pre-commit-config.yaml missing"; exit 1; }
            [ ! -d "tests" ] || { echo "✗ tests/ should not exist in tabula-rasa"; exit 1; }
            ;;
    esac

    # The project must be generated directly in the destination, not in a subdirectory
    [ ! -d "${project_name}" ] || { echo "✗ project was nested in ${project_name}/${project_name}"; exit 1; }

    # Check pyproject.toml is valid
    echo "✓ Validating pyproject.toml..."
    uv run --python 3.13 python -c "import tomllib; f=open('pyproject.toml','rb'); tomllib.load(f)" || {
        echo "✗ pyproject.toml is not valid TOML"
        exit 1
    }

    # Check that uv.lock was created during generation
    echo "✓ Checking uv.lock exists..."
    [ -f "uv.lock" ] || { echo "✗ uv.lock was not created"; exit 1; }

    # Try running uv sync again to verify it works
    echo "✓ Running uv sync..."
    uv sync > /dev/null 2>&1 || { echo "✗ uv sync failed"; exit 1; }

    echo "✓ Template $template_type: ALL CHECKS PASSED"
}

# Generate a project from the latest release tag, then update it to HEAD.
# An unmodified project must update in place with no conflicts.
test_update() {
    local template_type=$1
    local base_tag=$2
    local project_dir="$TEST_DIR/update-${template_type}"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Testing update from ${base_tag}: $template_type"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    copier copy --vcs-ref "$base_tag" --trust --defaults \
        --data "template_type=${template_type}" \
        --data "user_name=Test User" \
        --data "user_email=test@example.com" \
        --data "github_user=testuser" \
        "$SCRIPT_DIR" \
        "$project_dir"

    cd "$project_dir"
    [ -d .git ] || git init -q  # oneoff projects don't get a git repo
    git add -A
    git -c user.name=test -c user.email=test@example.com -c core.hooksPath=/dev/null \
        commit -q -m "generated from ${base_tag}"

    echo "✓ Running copier update..."
    copier update --vcs-ref HEAD --trust --defaults

    [ ! -d "update-${template_type}" ] || { echo "✗ update created a nested project directory"; exit 1; }
    [ -z "$(find . -name '*.rej' -not -path './.venv/*')" ] || { echo "✗ update left .rej files"; exit 1; }
    ! grep -rIl --exclude-dir=.git --exclude-dir=.venv '^<<<<<<< ' . || { echo "✗ update left conflict markers"; exit 1; }
    ! grep -q "^_commit: ${base_tag}$" .copier-answers.yml || { echo "✗ .copier-answers.yml still at ${base_tag}"; exit 1; }

    echo "✓ Template $template_type: UPDATE FROM ${base_tag} PASSED"
}

TEMPLATE_TYPES=("oneoff" "analysis" "library" "task" "tabula-rasa")

for template_type in "${TEMPLATE_TYPES[@]}"; do
    test_template "$template_type"
done

# Releases before 2.0.0 generated projects in a subdirectory and can't be updated in place.
BASE_TAG=$(git -C "$SCRIPT_DIR" tag --sort=-v:refname | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | head -1)
if [ -z "$BASE_TAG" ] || [ "${BASE_TAG%%.*}" -lt 2 ]; then
    echo ""
    echo "⚠ Skipping update tests: no release tag >= 2.0.0 found (need tags; in CI, checkout with fetch-depth: 0)"
else
    for template_type in "${TEMPLATE_TYPES[@]}"; do
        test_update "$template_type" "$BASE_TAG"
    done
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ ALL TEMPLATES TESTED SUCCESSFULLY!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
