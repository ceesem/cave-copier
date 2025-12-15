# UV-CAVE Project Templates

A unified [copier](https://copier.readthedocs.io/) template for creating Python projects with a focus on CAVE analysis, built on `uv` and reasonably modern tooling (Pre-commit hooks, profiling, docs, testing, versioning, task queues).

## TLDR

If you have already set up your environment with `pipx`, `uv`, `copier`, and`poethepoet`, you can create a new project with:

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

0. Python application management: `pipx`. This is used to install various tools and is a variation of `pip` designed for command-line applications. Rather than installing in a specific environment, it installs in a separate environment and creates a symlink to the executable in the user's path. This is useful for tools that are used across multiple projects and need to be kept up to date. 
1. Environment Management : `uv` This will be used to manage the virtual environment for all projects, as well as building, publishing, and testing libraries.
2. Code Formatting : `ruff`. This will be installed within a virtual environment and is managed by `uv`, although it is also useful to install the VSCode extension for it if you use that editor.
3. Testing : `pytest`. This will be installed within a virtual environment and is managed by `uv`.
4. Documentation : `mkdocs-material` and `mkdocstrings`. This will be installed within a virtual environment and is managed by `uv`.
5. Version Management : `bump-my-version`. This will be installed within a virtual environment and is managed by `uv`.
6. Pre-commit format checking : `pre-commit` used with `ruff`. Pre-commit is run and/or installed and initialized by `uv` after cookiecutter creation. 
7. Version control: `git`.  If this is not installed, follow instructions online.
8. Automated testing and documnentation : GitHub Actions. This is handled via files in the `.github/workflows` directory and needs no additional installation.
9. Profiling via `scalene` and `pyinstrument`. These are installed and managed by `uv`. Use `poe profile-all` to profile cpu and memory with `scalene` and `poe profile` to profile cpu in an aesthetically nicer way with `pyinstrument`.
10. Script-aliasing: [`poethepoet`](https://poethepoet.natn.io). This allows defining common commands in `pyproject.toml` and running them with `poe <taskname>`. This is optional but highly recommended.
11. Notesbooks via either vscode or jupyterlab. No installations necesary, this is managed through `uv`.
12. For large tasks only: `python-task-queue`. This adds a simple way to build queues that can be distributed across many workers in the cloud. This is managed by `uv` in the `task` template.

## Before You Start

There are four items that need to be installed by hand before you use these templates.
If you already have any of them installed, you can skip that step.

1. Install [pipx](https://pipx.pypa.io/). You will only need to install `pipx` once on your computer. It is the most manual installation and should be done first. See [pipx documentation](https://pipx.pypa.io/stable/) for installation instructions.
2. Install [uv](https://docs.astral.sh/uv/). You can install with pipx via 

```bash
pipx install uv
```

2. Install [copier](https://copier.readthedocs.io/) >= 9.0.0 and the `jinja2-time` extension. Do this with pipx:
```bash
pipx install copier && pipx inject copier jinja2-time
```

3. (Optional but highly recommended) Install [poethepoet](https://poethepoet.natn.io/) via pipx:

```bash
pipx install poethepoet
```

## Usage

Copier has powerful templating capabilities like the older tool `cookiecutter`, with the additional important ability to update existing projects to use new versions of the template.
However, this introduces quirks that were not previously present.
It is highly recommended to read the [copier documentation](https://copier.readthedocs.io/) to understand how it works, especially the [update process](https://copier.readthedocs.io/en/stable/updating/).

### Creating a New Project

The recommended approach for creating new project templates for copier is to use github, to allows easier versioning and updating.

```bash
copier copy --trust gh:ceesem/cave-copier /path/to/new-project
```

You'll be prompted to choose:

1. **Template type** (`oneoff`/`analysis`/`library`/`task`): This will determine the features and structure of your new project. See the [Template Types](#template-types) section above for details on each type.
2. **Project details** (name, description, author, etc): Basic metadata for your project.

#### Copier Loves Git

The recommended approach for creating new project templates for `copier` is to use github, which is necessary for versioning and updating.
Whether you reference a git-managed local path or a github repo, `copier` will by default look at **tags** and not the latest commit on the default branch.
Assuming tags are versioned like `1.0.4`, the highest version will be used.
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
copier update
```

This will re-ask all of the questions from the initial generation, but will pre-fill them with your existing answers if the parameters are the same.

In principle, that also should allow some level of upgrading between template types, e.g. from `oneoff` to `analysis` to `library` or `task`.

More details on how updating projects works and additional options you have can be found in the [copier documentation](https://copier.readthedocs.io/en/stable/updating).

## Template Types

### `oneoff`

#### Use case

Quick experiments, throwaway analyses. However, because it runs through uv-lock, it is still possible to save and reproduce the environment later.

#### Features

* Several common defaultpython dependencies (pandas, numpy, scipy, matplotlib, seaborn, scikit-learn, caveclient)
* No version control (no git init)
* No pre-commit hooks
* Includes notebook.ipynb
* Python 3.12+

### `analysis`

#### Use case

Longer-term analysis projects, such as for a paper

#### Features

* Git version control
* Pre-commit hooks with ruff for linting and formatting
* Empty default dependencies
* Profiling tools (scalene, pyinstrument)
* Structured src/ package layout
* Python 3.10+

### `library`

#### Use case

Publishable Python libraries with documentation and testing

#### Features

* Everything from analysis, plus:
* pytest with coverage
* mkdocs documentation with auto-API generation
* bump-my-version for semantic versioning
* GitHub Actions (testing on Python 3.9-3.12, docs publishing)
* Scratch environment for development
* Python 3.10+

#### Notes

**Library scratch environment**

The Library template has a `scratch/` directory with its own `pyproject.toml`.
The idea for this directory is that you might want a separate environment to install not only your package, but non-dependency packages that you intend to use with it.
For example, you might want to add `matplotlib` to visualize results to ensure the library is behaving well.
You can add those to `scratch/pyproject.toml` without them interfering with the strict library requirements.
The library `.venv` can be launched as a kernel from either the main directory or the scratch directory with `poe scratch-lab`.

### `task`

**Use case**: Distributed task queue systems

**Features**:

* Everything from analysis (git, profiling, src/), plus:
* task-queue and cloud-files dependencies
* Dockerfile for containerization
* Kubernetes deployment templates
* Scripts for cluster management
* Task queue management commands
* Python 3.10+

#### Notes

**Task Queue System**

This is designed to work with the [python-task-queue](https://github.com/seung-lab/python-task-queue) in relatively easy to deploy manner, but for a very specific use case of SQS-managed task queues and GKE-based workers.
There is some support for local testing of the queue and workers via docker and FileQueues in task-queue, but the main focus is on cloud deployment.
More documentation is available in the `README.md` file that comes with the generated project.

## Common Commands / Poe Tasks

The following `poe` commands are available depending on the template type chosen.
You can always list available poe tasks by simply typing `poe` in the project directory.

### All templates:

* `poe lab` - Launch Jupyter Lab

### `analysis`, `library`, `task`:

* `poe profile <your-script>` - Profile CPU with pyinstrument
* `poe profile-all <your-script>` - Profile CPU and memory with scalene

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
