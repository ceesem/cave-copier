# UV Project Templates (Copier)

A unified copier template for creating Python projects with `uv` and modern tooling.

## Overview

This template supports four project types:
- **oneoff**: Quick throwaway projects (no git, opinionated dependencies, Python 3.12)
- **analysis**: Structured analysis projects (git, profiling, customizable dependencies)
- **library**: Publishable Python libraries (full CI/CD, docs, testing, versioning)
- **task**: Distributed task queue projects (Kubernetes deployment, task-queue integration)

## Requirements

- [copier](https://copier.readthedocs.io/) >= 9.0.0
- [uv](https://docs.astral.sh/uv/) (for using the generated projects)
- [pipx](https://pipx.pypa.io/) (recommended for installing copier and poethepoet)

## Installation

```bash
# Install copier
pipx install copier

# Install uv (if not already installed)
pipx install uv

# Install poethepoet (for task running)
pipx install poethepoet
```

## Usage

### Creating a New Project

```bash
# From a local copy
copier copy path/to/copier_templates /path/to/new-project

# Or from a git repository (once published)
copier copy gh:your-username/cookiecutter_templates /path/to/new-project
```

You'll be prompted to choose:
1. **Template type** (oneoff/analysis/library/task)
2. **Project details** (name, description, author)
3. **Configuration** (Python version, GitHub username for non-oneoff projects)

### Updating an Existing Project

```bash
cd /path/to/existing-project
copier update
```

### Upgrading Template Type

You can "lift" a project to a more advanced template type:

```bash
cd /path/to/oneoff-project
copier recopy

# When prompted, change template_type from "oneoff" to "analysis"
# Copier will add: git, pre-commit, profiling tools, clear dependencies
```

Progressive upgrade path:
```
oneoff → analysis → library
         ↓
       task (specialized branch)
```

## Template Types

### oneoff
**Use case**: Quick experiments, throwaway analyses

**Features**:
- Opinionated data science dependencies (pandas, numpy, scipy, matplotlib, seaborn, scikit-learn, caveclient)
- No version control (no git init)
- No pre-commit hooks
- Minimal setup, maximum speed
- Includes notebook.ipynb
- Python 3.12+

**Example**:
```bash
copier copy copier_templates my-quick-analysis
cd my-quick-analysis
poe lab  # Launch Jupyter Lab
```

### analysis
**Use case**: Longer-term analysis projects

**Features**:
- Git version control
- Pre-commit hooks with ruff
- Empty dependencies (you choose what to add)
- Profiling tools (scalene, pyinstrument)
- Structured src/ package layout
- Python 3.9+

**Example**:
```bash
copier copy copier_templates my-analysis-project
cd my-analysis-project
# Add your dependencies to pyproject.toml
uv sync
poe lab  # Launch Jupyter Lab
poe profile  # Profile your code
```

### library
**Use case**: Publishable Python libraries

**Features**:
- Everything from analysis, plus:
- pytest with coverage
- mkdocs documentation with auto-API generation
- bump-my-version for semantic versioning
- GitHub Actions (testing on Python 3.9-3.12, docs publishing)
- Scratch environment for development
- CLAUDE.md development guide
- Python 3.9+

**Example**:
```bash
copier copy copier_templates my-library
cd my-library
# Implement your library in src/my_library/
poe test  # Run tests
poe doc-preview  # Preview docs
poe bump patch  # Version and release
```

### task
**Use case**: Distributed task queue systems

**Features**:
- Everything from analysis (git, profiling, src/), plus:
- task-queue and cloud-files dependencies
- Dockerfile for containerization
- Kubernetes deployment templates
- Scripts for cluster management
- Task queue management commands
- Python 3.9+

**Example**:
```bash
copier copy copier_templates my-task-project
cd my-task-project
# Configure config/task.env and config/cluster.env
# Implement your task in src/my_task_project/task.py
poe insert_tasks  # Add tasks to queue
poe deploy_task  # Deploy to Kubernetes
```

## Common Commands (poe tasks)

All template types:
- `poe lab` - Launch Jupyter Lab

analysis, library, task:
- `poe profile` - Profile CPU with pyinstrument
- `poe profile-all` - Profile CPU and memory with scalene

library only:
- `poe test` - Run tests with coverage
- `poe doc-preview` - Preview documentation
- `poe bump patch|minor|major` - Bump version
- `poe drybump patch|minor|major` - Dry run version bump
- `poe scratch-lab` - Launch Jupyter Lab in scratch environment

task only:
- `poe insert_tasks` - Insert tasks into queue
- `poe launch_worker` - Launch a worker
- `poe deploy_task` - Deploy to Kubernetes
- `poe check_filequeue` - Check queue status
- (many more - see pyproject.toml)

## Template Structure

### Shared Foundation (all types)
- `pyproject.toml` - Project configuration with uv
- `src/{{ project_slug }}/` - Package source code
- `.gitignore` - Python gitignore
- `.python-version` - Python version file
- `LICENSE` - MIT License
- `README.md` - Project README

### Type-Specific Additions

**oneoff adds**:
- `notebook.ipynb` - Empty notebook to start

**analysis/library/task add**:
- `.pre-commit-config.yaml` - Ruff pre-commit hooks
- Git initialization

**library adds**:
- `tests/` - Pytest tests directory
- `docs/` - MkDocs documentation
- `.github/workflows/` - GitHub Actions CI/CD
- `scratch/` - Development environment
- `CLAUDE.md` - Development guide
- `.bmv-post-commit.sh` - Version bump hook
- `mkdocs.yml` - Documentation config

**task adds**:
- `Dockerfile` - Container definition
- `config/` - Task and cluster configuration
- `templates/` - Kubernetes templates
- `scripts/` - Deployment scripts
- `*.sh` - Queue management scripts
- `insert_tasks.py`, `run.py` - Task queue Python scripts

## Development

### Testing the Template

Test each template type:

```bash
# Test oneoff
copier copy copier_templates /tmp/test-oneoff
cd /tmp/test-oneoff && uv sync && poe lab

# Test analysis
copier copy copier_templates /tmp/test-analysis
cd /tmp/test-analysis && uv sync

# Test library
copier copy copier_templates /tmp/test-library
cd /tmp/test-library && uv sync && poe test

# Test task
copier copy copier_templates /tmp/test-task
cd /tmp/test-task && uv sync
```

### Template Maintenance

The template uses:
- **Jinja2** for templating (`.jinja` suffix)
- **Conditional files/directories** (`{% if template_type == 'library' %}filename{% endif %}`)
- **Derived values** in `copier.yml` (e.g., `_python_requires`, `_version_number`)

When updating:
1. Test all four template types
2. Test upgrade path (oneoff → analysis → library)
3. Ensure copier.yml questions flow makes sense
4. Update this README

## Migration from Cookiecutter

If migrating from the old cookiecutter templates:
1. The four separate templates are now one unified template
2. Use `template_type` question to select project type
3. Variable names are similar but without `cookiecutter.` prefix
4. Post-generation hooks are defined in `copier.yml` `_tasks`

## License

MIT License - see LICENSE file for details.
