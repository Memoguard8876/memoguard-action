<p align="center"><img src="assets/logo.svg" alt="MemoGuard logo" width="112"></p>

# memoguard-action

GitHub Action packaging for MemoGuard. It installs a pinned `memoguard-cli` release and converts its safe findings into CI annotations.

## Owns

- `action.yml`, Action inputs, CLI version and checksum pinning.
- Reading the CLI report and writing GitHub annotations.
- Minimal workflow permissions and usage examples.

## Does not own

Scanning rules, Stellar parsing, or an independent detection engine.

## Use in a workflow

```yaml
- uses: Memoguard8876/memoguard-action@v0.1.0
  with:
    path: transaction.xdr
    kind: xdr
```

The action runs on Linux x86_64 GitHub-hosted runners. `kind` can be `xdr`, `simulation`, or `json`. It downloads the pinned CLI release, verifies its SHA-256 checksum, scans the file, and emits safe GitHub annotations. A blocking finding fails the job. No token is needed once `memoguard-cli` releases are public; set `cli-token` only if you mirror them privately. The default CLI version is `v0.1.2`; use `cli-version` to select another published tag.

Product PRD and architecture live in the parent `memguard/docs` folder in the local workspace.
