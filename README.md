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
    cli-token: ${{ secrets.MEMOGUARD_CLI_READ_TOKEN }}
```

The action runs on Linux x86_64 GitHub-hosted runners. `kind` can be `xdr`, `simulation`, or `json`. It downloads the pinned private CLI release, verifies its SHA-256 checksum, scans the file, and emits safe GitHub annotations. A blocking finding fails the job. The caller must provide a token that can read the private `memoguard-cli` release. The default CLI version is `v0.1.2`; use `cli-version` to select another published tag.

Product PRD and architecture live in the parent `memguard/docs` folder in the local workspace.
