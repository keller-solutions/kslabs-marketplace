#!/usr/bin/env bash
# Regression test for lean-diff.py: noise detection and the before/after test run.
set -euo pipefail
script="$(cd "$(dirname "$0")" && pwd)/lean-diff.py"
repo=$(mktemp -d)
trap 'rm -rf "$repo"' EXIT
cd "$repo"
git init -q && git config user.email t@t && git config user.name t
mkdir test
printf 'export const add = (a, b) => a + b;\nexport const one = 1;\nexport const two = 2;\n' > math.mjs
git add . && git commit -qm init

# Reorder two lines, add trailing whitespace, and add one real and one passed-before test.
printf 'export const one = 1;\nexport const add = (a, b) => a + b;\nexport const two = 2; \nexport const sub = (a, b) => a - b;\n' > math.mjs
cat > test/math_test.mjs <<'JS'
import assert from "node:assert/strict";
import test from "node:test";
import * as m from "../math.mjs";
test("sub subtracts", () => assert.equal(m.sub(3, 1), 2));
test("add adds", () => assert.equal(m.add(1, 1), 2));
JS
git add .
out=$(python3 "$script" --staged || true)
fail=0
check() { grep -qF -- "$1" <<<"$out" || { echo "MISSING: $1"; fail=1; }; }
check "differ only in whitespace"
check "+5 test / +3 code"
check "1 line(s) removed and re-added unchanged"
check "sub subtracts - failed before"
check "add adds - **passed before: cut**"
[[ $fail == 0 ]] && echo "lean-diff: all checks passed" || { echo "$out"; exit 1; }
