#!/bin/bash
# Test script for copier templates
# Generates all four template types and runs basic validation

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

    # Generate project with copier
    copier copy --trust --defaults \
        --data "template_type=${template_type}" \
        --data "project_name=${project_name}" \
        --data "project_slug=${project_name//-/_}" \
        --data "directory_name=${project_name}" \
        --data "project_description=Test project for ${template_type}" \
        --data "user_name=Test User" \
        --data "user_email=test@example.com" \
        --data "github_username=testuser" \
        --data "initial_version=0.0.1" \
        --data "python_version=3.12" \
        --data "use_vim_jupyter=true" \
        "$SCRIPT_DIR" \
        .

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
    esac

    # Check pyproject.toml is valid
    echo "✓ Validating pyproject.toml..."
    uv run --python 3.12 python -c "import tomllib; f=open('pyproject.toml','rb'); tomllib.load(f)" || {
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

# Test all four template types
test_template "oneoff"
test_template "analysis"
test_template "library"
test_template "task"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ ALL TEMPLATES TESTED SUCCESSFULLY!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
