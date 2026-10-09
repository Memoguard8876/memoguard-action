<p align="center"><img src="assets/logo.svg" alt="MemoGuard logo" width="112"></p>

<h1 align="center">memoguard-action</h1>

<p align="center"><b>GitHub Action that scans Stellar transaction fixtures with a checksum-pinned MemoGuard CLI.</b></p>

<p align="center">
  <a href="https://github.com/Memoguard8876/memoguard-action/actions/workflows/ci.yml"><img src="https://github.com/Memoguard8876/memoguard-action/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/Memoguard8876/memoguard-action?color=blue" alt="License: MIT"></a>
  <a href="https://github.com/Memoguard8876/memoguard-action/tags"><img src="https://img.shields.io/github/v/tag/Memoguard8876/memoguard-action?label=release&color=brightgreen" alt="Latest release"></a>
  <img src="https://img.shields.io/github/go-mod/go-version/Memoguard8876/memoguard-action?color=00ADD8" alt="Go version">
  <a href="https://github.com/Memoguard8876/memoguard-action/issues"><img src="https://img.shields.io/github/issues/Memoguard8876/memoguard-action?color=orange" alt="Open issues"></a>
  <a href="https://github.com/Memoguard8876/memoguard-action/issues?q=is%3Aopen+label%3A%22help+wanted%22"><img src="https://img.shields.io/badge/help%20wanted-welcome-8A2BE2" alt="Help wanted"></a>
  <img src="https://img.shields.io/badge/built%20for-Stellar-black" alt="Built for Stellar">
</p>

<p align="center">
  <a href="https://cjay-1.gitbook.io/memoguard-docs/">Documentation</a> ·
  <a href="https://github.com/Memoguard8876/memoguard-action/releases">Releases</a> ·
  <a href="https://github.com/Memoguard8876/memoguard-action/issues">Issues</a> ·
  <a href="CONTRIBUTING.md">Contributing</a> ·
  <a href="SECURITY.md">Security</a>
</p>

---

## What it is

A composite GitHub Action that runs the [MemoGuard CLI](https://github.com/Memoguard8876/memoguard-cli) in your workflow and turns each finding into a GitHub annotation. It contains **no scanner of its own**. It downloads one pinned CLI release, verifies the binary against SHA-256 digests stored in this repository, runs the scan, and fails the job when a finding meets your threshold.

## Features

- No token or secret needed. The CLI release is public.
- Linux, macOS and Windows runners, x86_64 and arm64 where available.
- Binary checksum checked on every run.
- Annotations carry rule, field path and fix, **never the matched value**, and are escaped against workflow-command injection.
- `fail-on` threshold: `block`, `warning` or `none`.
- Needs only `contents: read`.

## Quick start

```yaml
name: MemoGuard
on: [push, pull_request]
permissions:
  contents: read
jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: Memoguard8876/memoguard-action@v0.2.1
        with:
          path: fixtures/transaction.xdr
          kind: xdr
```

The Action scans one file per step. Repeat the step for more files.

## Inputs

| Input | Required | Default | Meaning |
| --- | --- | --- | --- |
| `path` | yes | | File to scan |
| `kind` | no | `xdr` | `xdr`, `simulation` or `json` |
| `policy` | no | built-in | JSON policy path (replaces the built-in rules) |
| `fail-on` | no | `block` | `block`, `warning` or `none` |

| `fail-on` | Blocking finding | Warning only |
| --- | --- | --- |
| `block` | job fails | passes with a warning |
| `warning` | job fails | job fails |
| `none` | passes | passes |

## Supported runners

| Runner | Binary |
| --- | --- |
| Linux x86_64 / arm64 | `memoguard-linux-amd64` / `memoguard-linux-arm64` |
| macOS x86_64 / arm64 | `memoguard-darwin-amd64` / `memoguard-darwin-arm64` |
| Windows x86_64 | `memoguard-windows-amd64.exe` |

## What you see

```text
::error title=personal.email::transaction.memo.text: Email address in public transaction data. Use an opaque reference instead of an email address
```

A blocking finding is an `error` annotation. A warning is a `warning` annotation.

## How it works

1. Pick the binary for the runner.
2. Download it from the pinned CLI release.
3. Compare its SHA-256 with `checksums.sha256`. A mismatch stops the job.
4. Run `memoguard scan --format json` with your inputs.
5. If the scan could not finish (exit code 2 or more), fail with a generic message and no input content.
6. Otherwise print the annotations and exit with the scan's code.

## Pinning and upgrades

Each Action release pins exactly one CLI version. **Action v0.2.1 pins CLI v0.2.2.** There is no input to pick another version, so the digest list and the binary always match. Pin the Action to a tag, or to a full commit SHA for the strictest setup.

## Troubleshooting

| Message | Cause |
| --- | --- |
| `An input path is required.` | `path` is empty |
| `Unsupported input kind.` | `kind` is not `xdr`, `simulation` or `json` |
| `The scan could not complete. Check the input and policy.` | Bad XDR, JSON or policy, or input over a limit. Run the CLI locally on the same file |
| `CLI checksum mismatch.` | The download did not match the pinned digest. Do not bypass it |
| `Unsupported runner platform.` | A platform without a release binary |

## Develop

The [integration workflow](.github/workflows/integration.yml) runs clean, warning and blocked synthetic fixtures on Linux, macOS and Windows, including the `fail-on warning` case. Run the annotation tests:

```bash
go test ./...
go vet ./...
```

## Limits

The Action reports what the CLI finds in supported fields. A passing check is not proof that a transaction is free of private data. See [Limitations](https://cjay-1.gitbook.io/memoguard-docs/limitations). The Action does not upload SARIF yet; this is an [open issue](https://github.com/Memoguard8876/memoguard-action/issues/1).

## The MemoGuard family

MemoGuard is four independent Go repositories. Each builds from tagged releases of the one before it.

```text
memoguard-rules ──► memoguard-engine ──► memoguard-cli ──► memoguard-action
```

| Repository | Role | Latest |
| --- | --- | --- |
| [memoguard-rules](https://github.com/Memoguard8876/memoguard-rules) | Policy schema, validation, built-in rules, expiring exceptions | v0.1.1 |
| [memoguard-engine](https://github.com/Memoguard8876/memoguard-engine) | Stellar XDR decoding, field extraction, scanning, redacted findings | v0.2.1 |
| [memoguard-cli](https://github.com/Memoguard8876/memoguard-cli) | `memoguard scan` command, output formats, exit codes, release binaries | v0.2.2 |
| [memoguard-action](https://github.com/Memoguard8876/memoguard-action) | GitHub Action: pinned CLI, annotations, failure threshold | v0.2.1 |

Full guides, the field-path reference and walkthroughs are in **[MemoGuard Docs](https://cjay-1.gitbook.io/memoguard-docs/)**. Product requirements and architecture are versioned in [memoguard-cli/product/docs](https://github.com/Memoguard8876/memoguard-cli/tree/main/product/docs).

## Contributing

Contributions are welcome. Start with [CONTRIBUTING.md](CONTRIBUTING.md).

- Browse [open issues](https://github.com/Memoguard8876/memoguard-action/issues). Labels show the type (`enhancement`, `documentation`, `testing`), `help wanted`, and a `complexity` level.
- Comment on an issue and wait to be assigned before you start.
- Use **synthetic data only** in tests and fixtures. Never commit real customer data, keys, tokens or real transactions.
- Add tests for every behaviour change, including malformed input, and a line in [CHANGELOG.md](CHANGELOG.md).

## Security

A clean scan is not a guarantee, and there has been no formal security audit. Report vulnerabilities privately through GitHub's private vulnerability reporting for this repository. See [SECURITY.md](SECURITY.md). Do not post exploit details or real private data in a public issue.

## Maintainers

| Maintainer | Role | Contact |
| --- | --- | --- |
| [Memoguard8876](https://github.com/Memoguard8876) | Organization owner, releases | [GitHub issues](https://github.com/Memoguard8876/memoguard-action/issues) |

## Community

Ask questions and propose changes in [GitHub issues](https://github.com/Memoguard8876/memoguard-action/issues). Read the [documentation](https://cjay-1.gitbook.io/memoguard-docs/) first; the [FAQ](https://cjay-1.gitbook.io/memoguard-docs/faq) answers the common questions.

## Contributors

<a href="https://github.com/Memoguard8876/memoguard-action/graphs/contributors"><img src="https://contrib.rocks/image?repo=Memoguard8876/memoguard-action" alt="Contributors"></a>

## License

[MIT](LICENSE) © MemoGuard contributors.
