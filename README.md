<p align="center"><img src="assets/logo.svg" alt="MemoGuard logo" width="112"></p>

# memoguard-action

[![Action integration](https://github.com/Memoguard8876/memoguard-action/actions/workflows/integration.yml/badge.svg)](https://github.com/Memoguard8876/memoguard-action/actions/workflows/integration.yml)

GitHub Action packaging for MemoGuard. It installs a pinned `memoguard-cli` release and converts its safe findings into CI annotations.

## Owns

- `action.yml`, Action inputs, CLI version and checksum pinning.
- Reading the CLI report and writing GitHub annotations.
- Minimal workflow permissions and usage examples.

## Does not own

Scanning rules, Stellar parsing, or an independent detection engine.

## Use in a workflow

```yaml
- uses: Memoguard8876/memoguard-action@v0.2.1
  with:
    path: transaction.xdr
    kind: xdr
```

The action supports Linux x86_64 and arm64, macOS x86_64 and arm64, and Windows x86_64 runners. `kind` can be `xdr`, `simulation`, or `json`. It downloads the public CLI v0.2.2 release and compares the binary with SHA-256 digests pinned in this Action repository. No token input is required. A blocking finding fails the job by default; set `fail-on: warning` to fail on warnings too, or `fail-on: none` to report without failing. A new CLI version requires a new Action release with updated pinned digests.

The public [product requirements](https://github.com/Memoguard8876/memoguard-cli/blob/main/product/docs/PRD.md), [architecture](https://github.com/Memoguard8876/memoguard-cli/blob/main/product/docs/ARCHITECTURE.md), and [Wave plan](https://github.com/Memoguard8876/memoguard-cli/blob/main/product/docs/WAVE.md) live in `memoguard-cli`.

See [CONTRIBUTING.md](CONTRIBUTING.md) for changes, [SECURITY.md](SECURITY.md) for private vulnerability reports, and [LICENSE](LICENSE) for MIT terms.

Documentation: [MemoGuard Docs](https://cjay-1.gitbook.io/memoguard-docs/)

Maintainers: [Memoguard8876](https://github.com/Memoguard8876). Discuss public work in [issues](https://github.com/Memoguard8876/memoguard-action/issues); report vulnerabilities privately through SECURITY.md.
