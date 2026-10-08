<!--
  README template (CoreTrace style), derived from coretrace-concurrency-analyzer.

  How to use:
  - Replace every {{PLACEHOLDER}}. A quick check: grep -n '{{' README.md
  - Delete these HTML comments once the section is filled.
  - Drop any section that does not apply (for example "Use it as a library" or "In CI").
  - No emoji anywhere in the file.
  - Keep the README short: details go in docs/ and are linked from here.
-->

<div align="center">

# {{PROJECT_DISPLAY_NAME}}

**{{ONE_LINE_PITCH — the benefit for the reader, not how it works}}**

{{TWO_LINE_DESCRIPTION — what the tool is, what it analyses, and what it does not need
(e.g. no instrumentation, no test run)}}

[![{{CI_WORKFLOW_NAME}}](https://github.com/{{GITHUB_ORG}}/{{REPO_NAME}}/actions/workflows/{{CI_WORKFLOW_FILE}}/badge.svg)](https://github.com/{{GITHUB_ORG}}/{{REPO_NAME}}/actions/workflows/{{CI_WORKFLOW_FILE}})
[![Release](https://img.shields.io/github/v/release/{{GITHUB_ORG}}/{{REPO_NAME}}?sort=semver)](https://github.com/{{GITHUB_ORG}}/{{REPO_NAME}}/releases)
[![License: {{LICENSE_NAME}}](https://img.shields.io/badge/license-{{LICENSE_BADGE_TEXT}}-blue.svg)](LICENSE)
[![LLVM {{LLVM_VERSION}}](https://img.shields.io/badge/LLVM-{{LLVM_VERSION}}-262D3A?logo=llvm)](https://llvm.org)
[![GitHub Action](https://img.shields.io/badge/GitHub%20Action-ready-2088FF?logo=githubactions&logoColor=white)](docs/github-action.md)

[Quick start](#quick-start) · [{{FEATURES_SHORT_TITLE}}](#what-it-catches) · [CI](#in-ci) · [How it works](#how-it-works) · [Docs](#documentation)

</div>

---

## See it in action

<!-- The single most convincing section: a short buggy input and the real output of the tool.
     Keep the input under ~20 lines. Regenerate the output with the real binary. -->

```{{EXAMPLE_LANGUAGE}}
{{EXAMPLE_INPUT_CODE}}
```

```text
$ {{BINARY_NAME}} {{EXAMPLE_FILE}} {{EXAMPLE_FLAGS}}

{{EXAMPLE_OUTPUT}}
```

{{OUTPUT_FORMATS_SENTENCE — e.g. "The same report is available as **JSON** and **SARIF**, so it
lands directly in GitHub Code Scanning."}}

## Quick start

**With Docker** — nothing to install but a container runtime:

```bash
docker run --rm -v "$PWD:/work" \
  {{DOCKER_IMAGE}}:{{VERSION_TAG}} {{EXAMPLE_FILE}} {{EXAMPLE_FLAGS}}
```

**On a whole project** — {{PROJECT_MODE_SENTENCE}}:

```bash
{{BINARY_NAME}} {{PROJECT_MODE_FLAGS}}
```

**From source** ({{TOOLCHAIN_REQUIREMENTS}}) — see [Building](#building).

## What it catches

<!-- One row per rule/check. Keep the third column to one short line;
     the full semantics and limits belong in docs/rules.md. -->

| Rule | `{{RULE_FLAG}}` | Catches |
|---|---|---|
| {{RULE_1_NAME}} | `{{RULE_1_ID}}` | {{RULE_1_SUMMARY}} |
| {{RULE_2_NAME}} | `{{RULE_2_ID}}` | {{RULE_2_SUMMARY}} |
| {{RULE_3_NAME}} | `{{RULE_3_ID}}` | {{RULE_3_SUMMARY}} |
| {{...}} | `{{...}}` | {{...}} |

{{DEFAULT_RULES_SENTENCE — e.g. "All rules run by default."}} Each one documents what it proves
and what it deliberately does not in [docs/rules.md](docs/rules.md).

## In CI

```yaml
permissions:
  contents: read
  security-events: write   # for the Code Scanning upload

steps:
  - uses: actions/checkout@v4
  - uses: {{GITHUB_ORG}}/{{REPO_NAME}}@{{ACTION_MAJOR_TAG}}
    with:
      {{ACTION_INPUT_1}}: {{ACTION_VALUE_1}}
      fail-on: error
```

{{CI_PARAGRAPH — how the action runs, what it uploads, and the exit-code contract
(found something vs could not analyze).}}
Full guide: [docs/github-action.md](docs/github-action.md).

## How it works

```text
{{PIPELINE_ASCII_DIAGRAM — input ──▶ stage ──▶ stage ──▶ output}}
```

{{HOW_IT_WORKS_PARAGRAPH — one or two key design choices and why.}}

**Known limits** — {{KNOWN_LIMITS — the one or two gaps a user is most likely to hit.}}
Details in [docs/rules.md](docs/rules.md#limits).

## Use it as a library

```cpp
{{MINIMAL_API_EXAMPLE — 5 to 10 lines}}
```

Embed it with CMake `FetchContent` (tag `{{VERSION_TAG}}`); a complete consumer lives in
[`{{CONSUMER_EXAMPLE_DIR}}/`]({{CONSUMER_EXAMPLE_DIR}}/). API reference: [docs/api.md](docs/api.md).

## Building

```bash
{{BUILD_COMMANDS}}
{{TEST_COMMAND}}
```

## Documentation

| | |
|---|---|
| [Rules & limits](docs/rules.md) | {{DOC_RULES_SUMMARY}} |
| [CLI reference](docs/cli.md) | {{DOC_CLI_SUMMARY}} |
| [GitHub Action](docs/github-action.md) | {{DOC_ACTION_SUMMARY}} |
| [Architecture](docs/architecture.md) | {{DOC_ARCHITECTURE_SUMMARY}} |
| [{{EXTRA_DOC_TITLE}}](docs/{{EXTRA_DOC_FILE}}) | {{EXTRA_DOC_SUMMARY}} |

## Contributing

Issues and PRs welcome — see [CONTRIBUTING.md](CONTRIBUTING.md). Part of the
**CoreTrace** toolset, alongside
{{SIBLING_PROJECT_LINKS}}.

Licensed under [{{LICENSE_NAME}}](LICENSE).
