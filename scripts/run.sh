#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Linux" || "$(uname -m)" != "x86_64" ]]; then
  echo '::error title=MemoGuard::The Action currently supports Linux x86_64 runners.'
  exit 2
fi
if [[ -z "${GH_TOKEN:-}" || -z "${INPUT_PATH:-}" ]]; then
  echo '::error title=MemoGuard::A GitHub token and an input path are required.'
  exit 2
fi

workdir="${RUNNER_TEMP:-/tmp}/memoguard-${GITHUB_RUN_ID:-local}-${GITHUB_RUN_ATTEMPT:-1}"
mkdir -p "$workdir"
gh release download "$CLI_VERSION" --repo Memoguard8876/memoguard-cli --pattern memoguard-linux-amd64 --pattern SHA256SUMS --dir "$workdir" --clobber
(cd "$workdir" && grep ' memoguard-linux-amd64$' SHA256SUMS | sha256sum --check --status)
chmod +x "$workdir/memoguard-linux-amd64"

args=(scan --format json)
case "${INPUT_KIND:-xdr}" in
  xdr) args+=(--xdr "$INPUT_PATH") ;;
  simulation) args+=(--simulation "$INPUT_PATH") ;;
  json) args+=(--json "$INPUT_PATH") ;;
  *) echo '::error title=MemoGuard::Unsupported input kind.'; exit 2 ;;
esac
if [[ -n "${INPUT_POLICY:-}" ]]; then args+=(--policy "$INPUT_POLICY"); fi

set +e
"$workdir/memoguard-linux-amd64" "${args[@]}" > "$workdir/report.json" 2> "$workdir/scan.err"
scan_status=$?
set -e
if [[ "$scan_status" -ge 2 ]]; then
  echo '::error title=MemoGuard::The scan could not complete. Check the input and policy.'
  exit "$scan_status"
fi

(cd "$GITHUB_ACTION_PATH" && go build -o "$workdir/annotate" ./cmd/annotate)
"$workdir/annotate" < "$workdir/report.json"
exit "$scan_status"
