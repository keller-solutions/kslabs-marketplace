#!/usr/bin/env python3
"""Measure a diff against the lean-diff standard.

Usage:
  lean-diff.py [BASE | A...B]    branch diff BASE...HEAD (default: origin's default branch), or any range
  lean-diff.py --staged          what is about to be committed (pre-change code = HEAD)
  lean-diff.py --commits [BASE]  one report per commit in BASE..HEAD (no test run)
  --no-tests                     skip the before/after test run

Reports per-file +/-, the totals and ratio, and the noise a reviewer should not have to
read: whitespace-only changes, moved (reordered) lines, EOF-newline churn, lockfile and
generated churn, added comments, and test lines against code lines.
Then the before/after check: added test cases run against the pre-change code (node --test,
jest, vitest, minitest, rspec, pytest), and any that pass there are flagged for cutting.
Exit code: 1 when noise or a passed-before test is found, else 0.
"""
import json, os, re, subprocess, sys, tempfile
from collections import Counter

TEST = re.compile(r"(^|/)(tests?|spec|__tests__|e2e)/|(_test|_spec|\.test|\.spec)\.[a-z]+$|^test_", re.I)
LOCK = re.compile(r"(package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Gemfile\.lock|composer\.lock|poetry\.lock|uv\.lock|Cargo\.lock|go\.sum)$")
GENERATED = re.compile(r"(\.min\.(js|css)$|(^|/)(dist|build|vendor)/|schema\.rb$|structure\.sql$|\.snap$)")
COMMENT = re.compile(r"^\s*(#(?!!)|//|/\*|\*(?!\*)|<!--|--\s|\"\"\"|''')")
CODE_EXT = re.compile(r"\.(rb|py|m?js|cjs|jsx|ts|tsx|php|go|rs|java|kt|swift|cs|c|cc|cpp|h|sh|sql|vue|svelte|ex|exs|dart)$")


def git(*args):
    return subprocess.run(["git", *args], capture_output=True, text=True, check=True).stdout


def default_base():
    try:
        ref = git("symbolic-ref", "--short", "refs/remotes/origin/HEAD").strip()
        return ref or "origin/main"
    except subprocess.CalledProcessError:
        return "origin/main"


def parse(diff_text):
    """file -> {'add': [lines], 'del': [lines], 'eof': bool}"""
    files, cur = {}, None
    for line in diff_text.splitlines():
        if line.startswith("diff --git"):
            cur = line.split(" b/", 1)[-1]
            files[cur] = {"add": [], "del": [], "eof": False}
        elif cur is None or line.startswith(("+++", "---")):
            continue
        elif line.startswith("+"):
            files[cur]["add"].append(line[1:])
        elif line.startswith("-"):
            files[cur]["del"].append(line[1:])
        elif line.startswith("\\ No newline"):
            files[cur]["eof"] = True
    return files


def counts(range_args, extra=()):
    out = {}
    for row in git("diff", "--numstat", *extra, *range_args).splitlines():
        a, d, f = row.split("\t", 2)
        out[f] = (0, 0) if a == "-" else (int(a), int(d))
    return out


def report(range_args, title):
    raw = counts(range_args)
    if not raw:
        print(f"## {title}\n\nNo changes.\n")
        return 0
    nows = counts(range_args, ("-w", "--ignore-blank-lines"))
    files = parse(git("diff", "--no-color", "-U0", *range_args))
    noise = []
    tot_a = tot_d = test_a = code_a = comment_a = 0
    rows = []
    for f, (a, d) in raw.items():
        tot_a += a
        tot_d += d
        info = files.get(f, {"add": [], "del": [], "eof": False})
        wa, wd = nows.get(f, (0, 0))
        ws = (a - wa) + (d - wd)
        if ws > 0:
            noise.append(f"{f}: {ws} line(s) differ only in whitespace or blank lines")
        # Exact matches only: a line that also changed whitespace is counted as whitespace above.
        dels = Counter(l for l in info["del"] if len(l.strip()) > 3)
        moved = sum(min(n, dels[l]) for l, n in Counter(l for l in info["add"] if len(l.strip()) > 3).items() if l in dels)
        if moved:
            noise.append(f"{f}: {moved} line(s) removed and re-added unchanged (reorder or move)")
        if info["eof"]:
            noise.append(f"{f}: end-of-file newline changed")
        if LOCK.search(f):
            noise.append(f"{f}: lockfile changed; confirm a dependency change requires it")
        elif GENERATED.search(f):
            noise.append(f"{f}: generated or vendored file changed")
        if TEST.search(f):
            test_a += a
        elif CODE_EXT.search(f):
            code_a += a
            c = sum(1 for l in info["add"] if COMMENT.match(l))
            comment_a += c
        rows.append((f, a, d))

    print(f"## {title}\n")
    print("| File | + | - |\n|---|---:|---:|")
    for f, a, d in sorted(rows, key=lambda r: -(r[1] + r[2])):
        print(f"| {f} | {a} | {d} |")
    ratio = f"{tot_a / tot_d:.1f} : 1" if tot_d else "all additions"
    print(f"\n**Total:** +{tot_a} / -{tot_d} across {len(rows)} file(s); additions to deletions {ratio}; net {tot_a - tot_d:+d}.")
    if code_a or test_a:
        tr = f"{test_a / code_a:.1f} test lines per code line" if code_a else "tests only"
        print(f"**Tests vs code:** +{test_a} test / +{code_a} code ({tr}).")
    if code_a:
        print(f"**Comments added in code:** {comment_a} of {code_a} added code lines.")
    print("\n### Noise\n")
    print("\n".join(f"- {n}" for n in noise) if noise else "None found.")
    print()
    return 1 if noise else 0


# --- Before/after: "If the test passed before the change, it wasn't important." ---------
# Added test cases run against the pre-change code. One that passes there does not test
# this change. Each runner: (files it owns, test-name patterns, command, result parser).
JS_NAME = [re.compile(r"""^\s*(?:test|it)(?:\.only)?\(\s*(['"`])(.+?)\1""")]
RB_NAME = [re.compile(r"""^\s*test\s+(['"])(.+?)\1"""), re.compile(r"^\s*def\s+(test_\w+)")]
SPEC_NAME = [re.compile(r"""^\s*it\s+(['"])(.+?)\1""")]
PY_NAME = [re.compile(r"^\s*(?:async\s+)?def\s+(test_\w+)")]


def tap(out):
    return {m[2].strip(): not m[1] for m in re.finditer(r"^\s*(not )?ok \d+ - (.+?)(?:\s+#.*)?$", out, re.M)}


def minitest(out):
    return {m[1]: {".": True, "E": "error"}.get(m[2], False) for m in re.finditer(r"#(test_.+?) = [\d.]+ s = ([.FES])", out)}


def pytest(out):
    return {m[1]: {"PASSED": True, "ERROR": "error"}.get(m[2], False) for m in re.finditer(r"::(test_\w+)(?:\[[^\]]*\])?\s+(PASSED|FAILED|ERROR)", out)}


def rspec(out):
    j = json.loads(out[out.index("{"):])
    return {e["description"]: e["status"] == "passed" for e in j.get("examples", [])}


def jestlike(out):
    j = json.loads(out[out.index("{"):])
    return {a["title"]: a["status"] == "passed" for r in j.get("testResults", []) for a in r.get("assertionResults", [])}


def js_runner(root):
    pkg = os.path.join(root, "package.json")
    script = json.load(open(pkg)).get("scripts", {}).get("test", "") if os.path.exists(pkg) else ""
    if "vitest" in script:
        return ["npx", "vitest", "run", "--reporter=json"], jestlike
    if "jest" in script:
        return ["npx", "jest", "--json"], jestlike
    return ["node", "--test", "--test-reporter=tap", "--test-timeout=30000"], tap


def runner_for(path, root):
    if re.search(r"\.(m?js|cjs|ts|tsx|jsx)$", path):
        cmd, parse_out = js_runner(root)
        return "js", JS_NAME, cmd, parse_out
    if path.endswith("_spec.rb"):
        return "rspec", SPEC_NAME, ["bundle", "exec", "rspec", "--format", "json"], rspec
    if path.endswith("_test.rb"):
        cmd = ["bin/rails", "test"] if os.path.exists(os.path.join(root, "bin/rails")) else ["bundle", "exec", "ruby", "-Itest", "-e", "ARGV.each { |f| require File.expand_path(f) }"]
        return "minitest", RB_NAME, cmd + ["-v"] if cmd[0] == "bin/rails" else cmd, minitest
    if path.endswith(".py"):
        py = os.path.join(root, ".venv/bin/python")
        return "pytest", PY_NAME, [py if os.path.exists(py) else "python3", "-m", "pytest", "-v", "-p", "no:cacheprovider"], pytest
    return None


def key(kind, name):
    return "test_" + re.sub(r"\s+", "_", name) if kind == "minitest" and not name.startswith("test_") else name


def before_after(pre, show, files):
    """pre: commit with the pre-change code; show(path) -> the changed test file's new text."""
    root = git("rev-parse", "--show-toplevel").strip()
    groups = {}
    for f, info in files.items():
        r = TEST.search(f) and runner_for(f, root)
        if not r:
            continue
        kind, pats, cmd, parse_out = r
        names = [m[m.lastindex] for l in info["add"] for p in pats if (m := p.match(l))]
        if names:
            groups.setdefault(kind, (cmd, parse_out, {}))[2][f] = names
    if not groups:
        return 0
    print("### Before/after\n\nAdded tests run against the code from before the change. A test that passes there does not test this change.\n")
    wt = tempfile.mkdtemp() + "/lean-diff"
    git("worktree", "add", "-q", "--detach", wt, pre)
    found = 0
    try:
        if os.path.isdir(os.path.join(root, "node_modules")):
            os.symlink(os.path.join(root, "node_modules"), os.path.join(wt, "node_modules"))
        for f in files:  # every changed test-dir file, so new helpers and fixtures come along
            if TEST.search(f) and (text := show(f)) is not None:
                os.makedirs(os.path.dirname(os.path.join(wt, f)) or wt, exist_ok=True)
                open(os.path.join(wt, f), "w").write(text)
        for kind, (cmd, parse_out, by_file) in groups.items():
            try:  # old code can leave a new test waiting forever; that is a fail, not a hang
                p = subprocess.run(cmd + list(by_file), cwd=wt, capture_output=True, text=True, timeout=600)
                results = parse_out(p.stdout + "\n" + p.stderr)
            except subprocess.TimeoutExpired as e:
                results = tap(e.stdout.decode() if e.stdout else "") if parse_out is tap else {}
            except (ValueError, KeyError):
                results = {}
            for f, names in by_file.items():
                for n in names:
                    r = results.get(key(kind, n))
                    verdict = {True: "**passed before: cut**", False: "failed before", "error": "errored before (confirm it is the change, not the environment)"}.get(r, "no result (did not run or name not matched)")
                    found += r is True
                    print(f"- {f}: {n} - {verdict}")
    finally:
        subprocess.run(["git", "worktree", "remove", "--force", wt], capture_output=True)
    print()
    return 1 if found else 0


def show_ref(ref):
    def show(path):
        p = subprocess.run(["git", "show", f"{ref}:{path}"], capture_output=True, text=True)
        return p.stdout if p.returncode == 0 else None
    return show


def main():
    sys.stdout.reconfigure(line_buffering=True)
    args = sys.argv[1:]
    tests = "--no-tests" not in args
    args = [a for a in args if a != "--no-tests"]
    if "--staged" in args:
        rc = report(["--cached"], "Staged changes")
        if tests:
            rc |= before_after("HEAD", show_ref(""), parse(git("diff", "--no-color", "-U0", "--cached")))
        sys.exit(rc)
    if "--commits" in args:
        rest = [a for a in args if a != "--commits"]
        base = rest[0] if rest else default_base()
        rc = 0
        for line in git("log", "--reverse", "--format=%h %s", f"{base}..HEAD").splitlines():
            sha, subject = line.split(" ", 1)
            rc |= report([f"{sha}^", sha], f"{sha} {subject}")
        sys.exit(rc)
    target = args[0] if args else default_base()
    rng = target if ".." in target else f"{target}...HEAD"
    rc = report([rng], rng)
    if tests:
        a, b = rng.split("...") if "..." in rng else rng.split("..")
        b = b or "HEAD"
        rc |= before_after(git("merge-base", a, b).strip(), show_ref(b), parse(git("diff", "--no-color", "-U0", rng)))
    sys.exit(rc)


if __name__ == "__main__":
    main()
