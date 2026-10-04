#!/usr/bin/env bash
# Wrapper — canonical installer: ../../../scripts/install-skills.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
exec "${ROOT}/scripts/install-skills.sh" "$@"
