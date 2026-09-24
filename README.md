# UV-CAVE Project Templates

A unified [copier](https://copier.readthedocs.io/) template for creating Python projects with a focus on CAVE analysis, built on `uv` and reasonably modern tooling (Pre-commit hooks, profiling, docs, testing, versioning, task queues).

## Table of Contents

- [TLDR](#tldr)
- [Overview](#overview)
- [Before You Start](#before-you-start)
- [Usage](#usage)
- [Template Types](#template-types)
- [Python Versions](#python-versions)
- [Common Commands / Poe Tasks](#common-commands--poe-tasks)
- [Development](#development)
- [License](#license)

## TLDR

If you have already installed `uv`, `copier`, and `poethepoet` (see [Before You Start](#before-you-start)), you can create a new project with:

```bash
copier copy --trust gh:ceesem/cave-copier /path/to/new-project
```

## Overview

This template supports four project types:

* **oneoff** : This is designed for a one-off analysis or notebook that will not be checked into version control. It is designed to be run in a local environment and not shared with others. It does include a number of basic packages that I use for data analysis and visualization as well as interaction with CAVE. Profiling is not set up here.
* **analysis** : This is designed for a longer term analysis project where data, plots, and notebooks will be saved. It will be checked into version control, but actual pypi releases are not expected.
* **library** : Creating a python library that will be published to PyPI, with testing, documentation, and version management using all of the above tools. Stubs are created for documentation and testing, and the library is set up to be published to PyPI. GitHub actions will run testing against a matrix of python versions and publish the documentation to GitHub pages.
* **task** : This is designed for a queue/worker task deployed through `python-task-queue`. It is designed to help create, distribute, and deploy tasks and workers using Google Kubernetes Engine listening to an Amazon SQS queue.

The current toolset is:

0. Python application management: `uv tool`. This installs command-line tools like `copier` and `poe` into their own isolated environments and puts them on your path, so they're available across all projects.
1. Environment Management : `uv` This will be used to manage the virtual environment for all projects, as well as building, publishing, and testing libraries.
2. Code Formatting : `ruff`. This will be installed within a virtual environment and is managed by `uv`, although it is also useful to install the VSCode extension for it if you use that editor.
3. Testing : `pytest`. This will be installed within a virtual environment and is managed by `uv`.
4. Documentation : `mkdocs-material` and `mkdocstrings`. This will be installed within a virtual environment and is managed by `uv`.
5. Version Management : `bump-my-version`. This will be installed within a virtual environment and is managed by `uv`.
6. Pre-commit format checking : `pre-commit` used with `ruff`. Pre-commit is installed and initialized after project creation, and its hooks run the project's own `ruff` (via `uv run`), so the version always matches `uv.lock`.
7. Version control: `git`.  If this is not installed, follow instructions online.
8. Automated testing and documnentation : GitHub Actions. This is handled via files in the `.github/workflows` directory and needs no additional installation.
9. Profiling via [`pyinstrument`](https://pyinstrument.readthedocs.io/) (CPU) and [`memray`](https://bloomberg.github.io/memray/) (memory). These aren't project dependencies; the `poe` tasks fetch them on demand with `uv run --with`, so they stay out of `uv.lock`, the virtual environment, and Docker images. Use `poe profile` to profile CPU time and `poe profile-mem` / `poe profile-mem-view` to profile memory allocations.
10. Script-aliasing: [`poethepoet`](https://poethepoet.natn.io). This allows defining common commands in `pyproject.toml` and running them with `poe <taskname>`. This is optional but highly recommended.
11. Notesbooks via either vscode or jupyterlab. No installations necesary, this is managed through `uv`.
12. For large tasks only: `python-task-queue`. This adds a simple way to build queues that can be distributed across many workers in the cloud. This is managed by `uv` in the `task` template.

## Before You Start

There are three items that need to be installed by hand before you use these templates.
If you already have any of them installed, you can skip that step.

1. Install [uv](https://docs.astral.sh/uv/getting-started/installation/). This is the only manual installation and should be done first:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

2. Install [copier](https://copier.readthedocs.io/) >= 9.6.0 and the `jinja2-time` extension as a uv tool:

```bash
uv tool install copier --with jinja2-time
```

3. (Optional but highly recommended) Install [poethepoet](https://poethepoet.natn.io/) as a uv tool:

```bash
uv tool install poethepoet
```

Upgrade them later with `uv tool upgrade --all`.
If you previously installed any of these with `pipx`, uninstall that copy (e.g. `pipx uninstall copier`)
so you don't end up with two versions on your `PATH`.

## Usage

Copier has powerful templating capabilities like the older tool `cookiecutter`, with the additional important ability to update existing projects to use new versions of the template.
However, this introduces quirks that were not previously present.
It is highly recommended to read the [copier documentation](https://copier.readthedocs.io/) to understand how it works, especially the [update process](https://copier.readthedocs.io/en/stable/updating/).

### Creating a New Project

The recommended approach for creating new project templates for copier is to use github, to allows easier versioning and updating.

```bash
copier copy --trust gh:ceesem/cave-copier /path/to/new-project
```

The destination path *is* the project directory: copier creates it if it doesn't exist,
and the project name defaults to the directory name (`~/Work/Code/cell-pax` gives project name `cell-pax`
and package name `cell_pax`). The answers file `.copier-answers.yml` is written inside the project,
where it should be committed so that `copier update` works later.

You'll be prompted to choose:

1. **Template type** (`oneoff`/`analysis`/`library`/`task`): This will determine the features and structure of your new project. See the [Template Types](#template-types) section above for details on each type.
2. **Project details** (name, description, author, etc): Basic metadata for your project.

#### Copier Loves Git

The recommended approach for creating new project templates for `copier` is to use github, which is necessary for versioning and updating.
Whether you reference a git-managed local path or a github repo, `copier` will by default look at **tags** and not the latest commit on the default branch.
Assuming tags are versioned like `1.0.3`, the highest tag version will be used.
A specific tag version can be specified with `--vcs-ref <version tag>` if desired.

#### Tasks Need Trust

In order for `copier` to run post-generation tasks (like initializing git, installing pre-commit hooks, etc), the template source must be marked as trusted.
This is done explicitly with the `--trust` flag when running `copier copy` above.

#### Setting Default Username/Email and Trusted Sources

Copier has a global settings file that can be used to set default values for your username and email, as well templates that it will always trust.
Find the format and location of your global settings file for your system at the [copier documentation](https://copier.readthedocs.io/en/stable/settings/), which differs by platform.

If you want to avoid being prompted for your username and email every time you create a new project, you can set them in the global copier settings file as:

```yaml
defaults:
  user_name: "Your Name"
  user_email: "your.email@example.com" 
  github_user: "your-github-username"
```

You can also set a permanent trust for a source in this same file.
For this template, the easiest way is to add `gh:ceesem/cave-copier` to the list.
The item will look like:

```yaml
trust:
  - gh:ceesem/cave-copier
```

### Updating an Existing Project

**Note**: This will only work if your existing project is also managed with `git`. 

You can update an existing project after building out your project with.

```bash
cd /path/to/existing-project
copier update --trust
```

This will re-ask all of the questions from the initial generation, but will pre-fill them with your existing answers if the parameters are the same.
Add `--skip-answered` to only be asked new questions.
Tasks like `uv sync` only run on creation, so afterward review the changes with `git diff` and run `uv sync` yourself.

#### Migrating projects created before 2.0.0

Before 2.0.0, the template generated the project in a *subdirectory* of the copier destination
(`copier copy gh:ceesem/cave-copier ~/Work/Code` created `~/Work/Code/<directory_name>/`).
As a result, `.copier-answers.yml` was written to the parent directory, where each new project overwrote the last one,
and `copier update` run inside a project created a nested `<project>/<project>/` copy instead of updating it.

Copier can't merge across that layout change, so migrate each project once with `copier recopy`, which re-renders the
current template from your saved answers:

1. Make sure `.copier-answers.yml` is in the project directory. If it's in the parent directory instead,
   move it in (only if its `directory_name` matches this project), or write one by hand from another project's answers.
2. Commit or stash all changes, so the recopy is easy to review.
3. Run `copier recopy --trust --skip-answered --overwrite` in the project directory.
   This rewrites every template file from scratch, including ones you've since made your own.
4. Restore the files that are yours, e.g. `git checkout -- src tests docs README.md`,
   plus any files the recopy re-created that you had deleted on purpose (check `git status` for untracked files).
5. Review the rest with `git diff` (or `git add -p`): keep the template's updates and restore your own customizations,
   especially dependencies and settings in `pyproject.toml`. Then run `uv sync` and commit, including `.copier-answers.yml`.

After that, plain `copier update` works.

In principle, that also should allow some level of upgrading between template types, e.g. from `oneoff` to `analysis` to `library` or `task`.

More details on how updating projects works and additional options you have can be found in the [copier documentation](https://copier.readthedocs.io/en/stable/updating).

## Template Types

### 1. `oneoff`

#### Use case

Quick experiments, throwaway analyses. However, because it runs through uv-lock, it is still possible to save and reproduce the environment later.

#### Features

* Several common defaultpython dependencies (pandas, numpy, scipy, matplotlib, seaborn, scikit-learn, caveclient)
* No version control (no git init)
* No pre-commit hooks
* Includes notebook.ipynb
* Python 3.13 default

### 2. `analysis`

#### Use case

Longer-term analysis projects, such as for a paper

#### Features

* Git version control
* Pre-commit hooks with ruff for linting and formatting
* Empty default dependencies
* Profiling tasks (pyinstrument for CPU, memray for memory, fetched on demand)
* Structured src/ package layout
* Python 3.13 default

### 3. `library`

#### Use case

Publishable Python libraries with documentation and testing

#### Features

* Everything from analysis, plus:
* pytest with coverage
* mkdocs documentation with auto-API generation
* bump-my-version for semantic versioning
* GitHub Actions (testing on Python 3.12-3.14, docs publishing, PyPI publishing on release)
* Dependabot for monthly grouped updates of GitHub Actions and `uv.lock`
* Scratch environment for development
* Supports Python 3.12+ (`requires-python = ">=3.12"`, see [Python Versions](#python-versions))

#### Notes

**Library scratch environment**

The Library template has a `scratch/` directory with its own `pyproject.toml`.
The idea for this directory is that you might want a separate environment to install not only your package, but non-dependency packages that you intend to use with it.
For example, you might want to add `matplotlib` to visualize results to ensure the library is behaving well.
You can add those to `scratch/pyproject.toml` without them interfering with the strict library requirements.
The library `.venv` can be launched as a kernel from either the main directory or the scratch directory with `poe scratch-lab`.

**Releasing to PyPI**

Releasing is two steps:

1. `poe bump patch|minor|major` updates the version, commits, tags `vX.Y.Z` and pushes with `git push --follow-tags`.
   It refuses if the current version isn't on PyPI yet, because bumping would skip a version nobody can install.
   Set `BUMP_ALLOW_UNRELEASED=1` to override.
2. `gh release create vX.Y.Z --generate-notes` publishes it. Creating a GitHub Release runs `.github/workflows/publish.yml`,
   which checks that the tag matches the package version, runs the tests, builds, and uploads to PyPI.

The workflow uses [PyPI trusted publishing](https://docs.pypi.org/trusted-publishers/), so there's no API token to manage,
but each new library needs a one-time setup that the template can't do for you:

1. On PyPI, add a trusted publisher. If the project doesn't exist on PyPI yet, add it as a
   ["pending publisher"](https://docs.pypi.org/trusted-publishers/creating-a-project-through-oidc/) from your account's Publishing page.
   Use owner `<github_user>`, repository `<project_slug>`, workflow `publish.yml`, environment `pypi`.
2. On GitHub, create an environment named `pypi` (repo Settings → Environments).

In a brand-new project, `poe bump` refuses until the initial version is on PyPI, so start by publishing it:
`gh release create v<initial_version> --generate-notes`.

### 4. `task`

**Use case**: Distributed task queue systems

**Features**:

* Everything from analysis (git, profiling, src/), plus:
* task-queue and cloud-files dependencies
* Dockerfile for containerization
* Kubernetes deployment templates
* Scripts for cluster management
* Task queue management commands
* Python 3.13 default

#### Notes

**Task Queue System**

This is designed to work with the [python-task-queue](https://github.com/seung-lab/python-task-queue) in relatively easy to deploy manner, but for a very specific use case of SQS-managed task queues and GKE-based workers.
There is some support for local testing of the queue and workers via docker and FileQueues in task-queue, but the main focus is on cloud deployment.
More documentation is available in the `README.md` file that comes with the generated project.

## Python Versions

All templates default to Python 3.13 (the `python_version` question, written to `.python-version`).
The template refuses anything older than 3.12.

`requires-python` is set on purpose, because uv resolves the lockfile for *every* Python version it allows, not just the one you run:

* **`oneoff`, `analysis`, `task`, `tabula-rasa`, and the library's `scratch/`** use `requires-python = ">={python_version}"`.
  These projects run on one Python, so there's no reason to lock for older ones.
  A looser range (e.g. `>=3.10`) makes uv split the lockfile per Python version, and `uv add` fails for any
  package that has dropped the older versions (e.g. `numpy>=2.3` needs 3.11+).
* **`library`** uses `requires-python = ">=3.12"`, since a published package should install on more than one Python.
  The floor follows numpy, which requires 3.12+ as of numpy 2.5, in line with the scientific Python
  [SPEC 0](https://scientific-python.org/specs/spec-0000/) support window. Supporting older Pythons than numpy
  does would buy little for CAVE-ecosystem users. CI tests 3.12 through 3.14.

## Common Commands / Poe Tasks

The following `poe` commands are available depending on the template type chosen.
You can always list available poe tasks by simply typing `poe` in the project directory.

### All templates:

* `poe lab` - Launch Jupyter Lab

### `analysis`, `library`, `task`:

* `poe profile <your-script>` - Profile CPU with pyinstrument
* `poe profile-mem <your-script>` - Profile memory allocations with memray (`--native` to include C extensions)
* `poe profile-mem-view` - Open a flame graph of the last memray profile (`--leaks` for leaks)

### `library` only:

* `poe test` - Run tests with coverage
* `poe doc-preview` - Preview documentation
* `poe bump patch|minor|major` - Bump version
* `poe drybump patch|minor|major` - Dry run version bump
* `poe scratch-lab` - Launch Jupyter Lab in scratch environment

### `task` only:

* `poe insert_tasks` - Insert tasks into task-queue
* `poe launch_worker` - Launch a local worker
* `poe deploy_task` - Deploy to Kubernetes
* (many more - see pyproject.toml)

## Development

The `test-templates.sh` script can be used to test build all the templates subtypes locally.

## License

MIT License - see LICENSE file for details.
