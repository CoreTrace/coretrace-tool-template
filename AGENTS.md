# AGENTS.md

Instructions for coding agents. Humans: start with [CONTRIBUTING.md](CONTRIBUTING.md).

This file has two parts. **Part 1** describes the CoreTrace project as a whole and the rules
shared by its repositories; it is meant to be the same in each of them. **Part 2** describes
this repository. Where they disagree, Part 2 wins for this repository. Update this file in the
same pull request as the rule, command or architecture it describes.

# Part 1: the CoreTrace project

## What CoreTrace is

CoreTrace finds bugs in C, C++ and Python code by running several analyzers and merging what
they find into one report and one verdict that can gate a CI pipeline. It is split into
repositories of the [CoreTrace organization](https://github.com/CoreTrace), each versioned and
released on its own.

The open repositories are the open core of a hosted analysis service, the CoreTrace platform,
which is developed separately and is out of scope here: never move a feature out of an open
repository, and never add code that only the hosted service needs.

## How the repositories fit together

```
  clients                         the product
  ┌──────────────────────────┐    ┌──────────────────────────────────────────────┐
  │ coretrace-gui (desktop)  │    │ coretrace: ctrace                            │
  │ coretrace-vscode (editor)├───▶│ runs the tools, merges their findings,       │
  │ a CI pipeline            │    │ gives the verdict                            │
  └──────────────────────────┘    └───────┬──────────────────────────┬───────────┘
                                          │ links, in process        │ runs, as processes
                              ┌───────────┴──────────┐    ┌──────────┴──────────────┐
                              │ stack analyzer       │    │ runtime analyzer        │
                              │ concurrency analyzer │    │ python analyzer         │
                              └───────────┬──────────┘    │ cppcheck, flawfinder... │
                                          │ compile       └─────────────────────────┘
                                          ▼ through
                              ┌──────────────────────┐
                              │ coretrace-compiler   │
                              └──────────────────────┘
```

| Repository | Role | How it joins the product |
|---|---|---|
| `coretrace` | `ctrace`, the CLI and HTTP server: runs the tools, normalizes and merges their findings, returns the exit code | The entry point; the release archive is built here |
| `coretrace-stack-analyzer` | Stack, buffer, pointer-escape and initialization analysis on LLVM IR | Linked into `ctrace`, at a pinned tag |
| `coretrace-concurrency-analyzer` | Data races, missing joins, lock-order deadlocks | Linked into `ctrace`, at a pinned tag |
| `coretrace-runtime-analyzer` | Instrumented runs: bounds, allocations, vtables | Shipped next to `ctrace`, run as a separate process |
| `coretrace-python-analyzer` | Analysis of Python projects | Shipped next to `ctrace` as a standalone executable, run as a separate process |
| `coretrace-compiler` | Clang integration library | The analyzers compile their inputs through it; one `ctrace` build holds one version of it |
| `coretrace-log` | C++20 logging library | Fetched by `coretrace`, the stack analyzer and `coretrace-compiler` |
| `coretrace-gui` | Desktop interface (Tauri) | A client: it runs an installed `ctrace` |
| `coretrace-vscode` | VS Code extension | A client: it runs `ctrace` and shows its findings in the editor |
| `coretrace-tool-template` | Scaffold for a new tool | Where a convention shared by the tools starts |
| `coretrace-ci-consumer-demo` | Reference CI integration | Uses a release as an outside project would |

`ctrace` also runs third-party tools when they are installed: cppcheck, flawfinder, ikos, and
TscanCode (a fork kept in `coretrace-TscanCode`).

### What holds them together

These are the contracts between the repositories. Whoever changes one breaks the others, so
each change is proposed in an issue first and stays open for comments for 7 days, as
[GOVERNANCE.md](https://github.com/CoreTrace/coretrace/blob/main/GOVERNANCE.md) sets:

- **The finding model.** Every tool's output is normalized by `ctrace` to one model, written as
  text, JSON or SARIF. In SARIF, a finding is identified by its `coretrace/v1` fingerprint.
- **The verdict.** Exit code `0` clean, `1` usage error, `2` findings, `3` incomplete analysis.
  A tool that could not run, or could not be read, is never counted as clean.
- **The interfaces of `ctrace`**: its command-line options, its configuration schema, and the
  `coretrace-1.0` HTTP protocol of its server.
- **Pinned versions.** A repository takes another at a tag or a commit, never a branch. A fix
  in an analyzer reaches users in two steps: a release of the analyzer, then an update of the
  pin in `coretrace`.
- **One compiler library per build.** The analyzers linked into `ctrace` must pin the same
  `coretrace-compiler` commit; moving it means releasing them together.

### Where a problem is fixed

| Symptom | Repository |
|---|---|
| A wrong, missing or duplicated finding | The analyzer that produced it |
| An input that does not compile for the analyzers | `coretrace-compiler` |
| A finding lost or miscounted in the merged report, a wrong exit code, a tool not run | `coretrace` |
| A report shown wrongly | The client: `coretrace-gui` or `coretrace-vscode` |

Do not work around another repository's defect here: record it there, and take the fix by
updating the pin.

## How the project is organized

- **Decisions are made in the open**, in issues and pull requests, by the rules of
  [GOVERNANCE.md](https://github.com/CoreTrace/coretrace/blob/main/GOVERNANCE.md). The default
  branch takes pull requests whose required checks pass.
- **Not every repository is maintained the same way.** The product and its desktop interface
  welcome contributors; others are maintained without contribution calls, or published as is.
  The levels are in the
  [open-source scope](https://github.com/CoreTrace/coretrace/blob/main/docs/open-source-scope.md).
- **Licenses differ.** Most repositories are under Apache-2.0, some under MIT or GPL-3.0. Use
  the license and the file header of the repository you are in, and never copy code from one
  repository into another without checking that its license allows it.
- **Each repository is versioned on its own**, with semantic versioning; components in `0.x`
  may still change incompatibly between minor versions.

## Rules for every repository

### Development

- **Work from an issue.** A change no issue describes gets one first, to agree on the approach.
- **A change of behavior comes with its test, in the same pull request.** A bug fix comes with
  a test that fails without the fix. Write that test first.
- **Fix the cause where every caller passes**, not the symptom on the path the report names.
- **An intermittent test is a bug to fix**, not to retry. Retries are for network steps only.
- **Documentation follows the change** in the same pull request: README, `docs/`, help text,
  and the changelog when users see it.
- **Small pull requests, one subject each.** English Conventional Commit titles, such as
  `fix(cli): handle missing input`. Fill the pull request template where there is one: what
  and why, how it was tested.
- **Validate at the boundary**: arguments, configuration files, request bodies, the output of
  another tool.
- **Do not add what the task does not need**: no speculative option, abstraction or
  configuration shape.
- **Use the repository's scripts and tools** for formatting, license headers and other checks:
  run them and act on what they report, rather than checking by reading.

### Boundaries

- Never commit to the default branch, force-push, or merge. Commit, push or open an issue or
  a pull request only when the maintainer asks.
- A commit uses the git identity already configured, and holds a subject and a body only: no
  co-author and no other trailer.
- Never weaken a gate to make a change pass: a compiler warning, a test, a coverage floor, a
  dependency or license check. If a gate is wrong, say so and stop.
- Ask before a run that keeps most cores busy for more than about a minute: a full build, the
  whole test suite, a benchmark.
- A suspected vulnerability goes through the repository's `SECURITY.md`, never a public issue.
- When stuck (the build does not configure, a test fails before your change, a rule seems to
  block the task), report what you found instead of working around it.

### Technical debt

Debt is what makes each change slower or riskier than it should be. Each debt is an issue of
the repository it lies in; the issues are the source of truth.

**The rule for every change.** Leave no new debt: a pull request must not break an invariant
of its repository, lower the coverage of the files it touches, add an unpinned dependency, or
leave a `TODO` without an issue number. Repay only the debt that lies in the lines the task
already changes. Debt seen elsewhere is recorded, not fixed in passing: a drive-by fix hides
in an unrelated diff and escapes review.

**The cycle.** Run steps 1 to 3 whenever debt is noticed during a task. Run the whole cycle as
a debt review when the maintainer asks for one, and before each release.

1. **Observe.** Collect facts, not opinions: a broken invariant, a duplicated source of truth,
   dead code or a dead option, a `TODO`, an unpinned or duplicated dependency, a file under its
   coverage floor, a static analysis finding, documentation that contradicts the code, a test
   that depends on timing.
2. **Qualify against the architecture.** Name the invariant or the contract it harms, in this
   repository or between repositories, and what it costs: a wrong result for users, every
   change in an area, or one leftover. That gives the severity: `severity/critical` (blocks
   reliable use), `severity/major` (structural, costs every change), `severity/minor` (bug or
   leftover). Add `refactor` when the fix changes the architecture. If it harms nothing named,
   it is a preference, not debt: drop it.
3. **Record.** One debt, one issue, in the repository where the fix belongs: the problem with
   its evidence (file, line, command and output), the fix, and acceptance criteria that a test
   or a command can check. Draft the issue and give it to the maintainer; create it only when
   asked. Check first that no open issue already covers it.
4. **Repay.** One pull request per issue, separate from features. Pin the current behavior
   with a test first, then change the structure, then show the test still passes. A repayment
   changes no behavior; if it must, that is a separate, announced change.
5. **Verify.** The pull request closes the issue only when its acceptance criteria hold, the
   gates pass, and the coverage of the files touched is not lower than before.
6. **Update the register**, where the repository keeps one: move the item from open to repaid,
   with the issue and the pull request. At a review, also re-read every open item: still true,
   still the same severity, or obsolete.

One fifth of each iteration is reserved for repayment. Order: critical first, then major debt
in the area the next roadmap item touches, then minor debt in batches. Debt that nothing
planned will ever touch may stay open, with its reason written in the issue.

**Where the result shows**, in any repository:

```bash
gh issue list --label severity/critical --state open
gh issue list --label severity/major --state open
gh issue list --label severity/minor --state open
gh issue list --label refactor --state all --limit 100
```

Three indicators are measured the same way at each debt review: static analysis findings, debt
added and repaid in the period, and the time to fix a vulnerability.

# Part 2: this repository, `coretrace-tool-template`

## Scope

This repository is the scaffold a new CoreTrace tool starts from, under Apache-2.0. It is a
GitHub template: a new tool is created as a copy of it, not as a fork. It holds no analysis
of its own: a CMake project that builds a C++20 library and an optional CLI on LLVM and
`coretrace-compiler`, the formatting scripts and their CI job, a README to fill in, and the
governance files.

Two consequences:

- **A change here reaches future tools only.** Nothing propagates to a tool already created: a
  convention that must change everywhere is changed here and in each tool.
- **Every file is read twice**: as this repository's own, and as the first version of a new
  tool's. Write for the second reader.

## Commands

LLVM and Clang 19 or newer; LLVM 20 matches the CoreTrace analyzers. CMake 3.16 or newer.

```bash
cmake -S . -B build \
  -DLLVM_DIR=/path/to/llvm/lib/cmake/llvm \
  -DClang_DIR=/path/to/llvm/lib/cmake/clang \
  -DCLANG_EXECUTABLE=/path/to/llvm/bin/clang
cmake --build build
./scripts/format-check.sh        # ./scripts/format.sh applies the format
```

The build fetches and compiles `coretrace-compiler`: ask the maintainer before starting it.

### Scripts

| When | Script | What it does |
|---|---|---|
| After changing C or C++ | `./scripts/format.sh`, then `./scripts/format-check.sh` | Applies, then verifies, the `clang-format` style. Both require `clang-format` 20 exactly and stop on another version; `CLANG_FORMAT=/path/to/clang-format` selects the binary. `extern-project/` is not formatted |

There is no script for license headers or commit messages, and no test suite: nothing will
catch a mistake there. Write the commit subject as an English Conventional Commit yourself.

## Layout

| Path | Role |
|---|---|
| `CMakeLists.txt` | The whole build. Its `USER CONFIG` block is what a new tool edits; `coretrace_add_tool()` below it defines the targets |
| `include/your_tool_name.hpp`, `src/your_tool_name.cpp`, `main.cpp` | Placeholders for the tool's public header, its library and its CLI |
| `extern-project/` | Example of a project that consumes a tool through CMake `FetchContent` |
| `scripts/`, `.clang-format`, `.github/workflows/clang-format.yml` | The formatting convention and the CI job that enforces it |
| `README.md` | A README to fill in: every `{{PLACEHOLDER}}` is replaced in the new tool |
| `cmake/` | Empty: where a tool puts its CMake modules |

What `coretrace_add_tool()` produces, for a tool named `<name>`:

- a library `<name>_lib`, static unless `BUILD_SHARED_LIB=ON`, with its alias
  `<namespace>::<name>_lib` for projects that fetch the tool;
- an executable `<name>` built from `TOOL_CLI_SOURCE`, unless `BUILD_CLI=OFF`;
- both linked to `cc::compilerlib_static`, the target of `coretrace-compiler`, which is fetched
  only when no parent project already provides it.

`coretrace` links the concurrency analyzer this way: it turns `BUILD_CLI` off and takes the
library.

### Invariants

1. **A new tool edits only the `USER CONFIG` block.** Anything a tool needs to change belongs
   in that block as a variable, not further down in the file.
2. **The project builds alone and inside another one.** The `format` targets exist only at
   top level, and `coretrace-compiler` is fetched only if its target is missing. Do not add a
   global setting that would leak into a parent project.
3. **The target names are a contract**: `<name>_lib`, `<namespace>::<name>_lib`, `<name>`, and
   the options `BUILD_CLI` and `BUILD_SHARED_LIB`. `coretrace` and other consumers rely on them.
4. **Placeholders stay placeholders.** `your_tool_name` and the `{{...}}` of the README are not
   filled in here. `grep -n '{{' README.md` lists them.
5. **No machine-specific path** in a tracked file.
6. **One `clang-format` version**, 20, set together in `scripts/clang-format-common.sh` and in
   the CI job.

## What Part 1 assumes and this repository lacks

Part 1 describes the project's rules; this repository does not have all their supports yet.
Until it does:

- **No test suite.** A change is validated by configuring and building the template, and by
  building a tool created from it or a consumer; the pull request gives the commands and their
  result.
- **No `severity/*` or `refactor` label, and no debt register.** Steps 1 to 3 of the debt
  cycle still apply: draft the issue with the severity in its text, and give it to the
  maintainer.
- **The only CI job checks formatting.** Do not conclude from a green pull request that the
  template builds.

## In a tool created from this template

This file is copied with the rest. In the new repository:

1. Keep Part 1 as it is. It is the same in every CoreTrace repository; change it in
   `coretrace-tool-template` first, then copy it.
2. Replace Part 2 with the tool's own: its scope and what it does not do, its build and test
   commands, its scripts, its architecture (the stages from an input to a finding), its
   invariants, its test conventions, and where its debt shows.
3. Pin what the tool fetches. The template's default for `CORETRACE_COMPILER_GIT_TAG` follows a
   branch; a tool sets a tag or a commit, as Part 1 requires.
4. Delete this section.
