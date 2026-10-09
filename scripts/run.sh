#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)/$(uname -m)" in
  Linux/x86_64) asset=memoguard-linux-amd64 ;;
  Linux/aarch64) asset=memoguard-linux-arm64 ;;
  Darwin/x86_64) asset=memoguard-darwin-amd64 ;;
  Darwin/arm64) asset=memoguard-darwin-arm64 ;;
  MINGW*/x86_64|MSYS*/x86_64) asset=memoguard-windows-amd64.exe ;;
  *) echo '::error title=MemoGuard::Unsupported runner platform.'; exit 2 ;;
esac
if [[ -z "${INPUT_PATH:-}" ]]; then
  echo '::error title=MemoGuard::An input path is required.'
  exit 2
fi
workdir="$(mktemp -d)"
trap 'rm -rf -- "$workdir"' EXIT
action_path="$GITHUB_ACTION_PATH"
if command -v cygpath >/dev/null 2>&1; then action_path="$(cygpath -u "$action_path")"; fi
CLI_VERSION=v0.2.3
release_url="https://github.com/Memoguard8876/memoguard-cli/releases/download/${CLI_VERSION}"
curl --fail --location --retry 3 --silent --show-error "$release_url/$asset" --output "$workdir/$asset"
expected="$(awk -v name="$asset" '$2 == name {print $1}' "$action_path/checksums.sha256")"
if [[ ! "$expected" =~ ^[a-fA-F0-9]{64}$ ]]; then
  echo '::error title=MemoGuard::Missing or invalid release checksum.'
  exit 2
fi
if command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum "$workdir/$asset" | awk '{print $1}')"
else
  actual="$(shasum -a 256 "$workdir/$asset" | awk '{print $1}')"
fi
if [[ "$actual" != "$expected" ]]; then
  echo '::error title=MemoGuard::CLI checksum mismatch.'
  exit 2
fi
chmod +x "$workdir/$asset"

args=(scan --format json)
case "${INPUT_KIND:-xdr}" in
  xdr) args+=(--xdr "$INPUT_PATH") ;;
  simulation) args+=(--simulation "$INPUT_PATH") ;;
  json) args+=(--json "$INPUT_PATH") ;;
  *) echo '::error title=MemoGuard::Unsupported input kind.'; exit 2 ;;
esac
if [[ -n "${INPUT_POLICY:-}" ]]; then args+=(--policy "$INPUT_POLICY"); fi
args+=(--fail-on "${FAIL_ON:-block}")

set +e
"$workdir/$asset" "${args[@]}" > "$workdir/report.json" 2> "$workdir/scan.err"
scan_status=$?
set -e
if [[ "$scan_status" -ge 2 ]]; then
  echo '::error title=MemoGuard::The scan could not complete. Check the input and policy.'
  exit "$scan_status"
fi

annotate=annotate
if [[ "$asset" == *.exe ]]; then annotate=annotate.exe; fi
(cd "$action_path" && go build -o "$workdir/$annotate" ./cmd/annotate)
"$workdir/$annotate" < "$workdir/report.json"
exit "$scan_status"
