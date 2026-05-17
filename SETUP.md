# Environment Setup

Reproducible Python environment for the FieldOps Pro Databricks DQ /
Migration-QA project. **Python 3.12 only** — `databricks-connect` 17.3 LTS
targets 3.12, and the serverless server-side runtime is 3.12. A mismatched
client Python (3.13/3.14) breaks UDFs over Spark Connect.

## Files

| File | Purpose | When |
|---|---|---|
| `requirements.txt` | Core + Phase 1-6 stack, pinned | Always, first |
| `requirements-gx.txt` | Great Expectations (isolated) | Only at the optional GX step |
| `requirements-dev.txt` | Linter / kernel | Optional, for repo polish |
| `.python-version` | Pins interpreter to 3.12 | Read by pyenv / tooling |

## One-time setup (Windows / PowerShell, run from the repo root)

```powershell
# 1. Confirm Python 3.12 is available (install if missing)
py -3.12 --version
#   If "no suitable Python": winget install Python.Python.3.12  (then reopen shell)

# 2. Create + activate the venv (lives in repo root, git-ignored)
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
#   If activation is blocked:
#   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# 3. Confirm the venv Python
python --version          # must print Python 3.12.x

# 4. Install the pinned stack
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

# 5. Verify Databricks Connect reaches serverless
python -c "from databricks.connect import DatabricksSession; s=DatabricksSession.builder.serverless(True).getOrCreate(); print(s.sql('SELECT current_user(), current_timestamp()').collect())"
```

Step 5 success looks like:
`[Row(current_user()='you@example.com', current_timestamp()=datetime(...))]`
First call takes ~30s (serverless cold start).

## Databricks CLI auth (separate from the venv — machine-local)

`~/.databrickscfg` does NOT travel through git. On a new machine:

```powershell
databricks auth login --host https://dbc-f54e7c27-14cd.cloud.databricks.com
```

Browser OAuth flow. Verify: `databricks current-user me`

## Later, per-phase

```powershell
# Phase 6 (optional) — Great Expectations, only when you get there
python -m pip install -r requirements-gx.txt

# Repo polish (optional)
python -m pip install -r requirements-dev.txt
```

## Common failures

| Symptom | Cause | Fix |
|---|---|---|
| `python` is 3.13/3.14 in venv | venv built with wrong base | delete `.venv`, rebuild with `py -3.12 -m venv .venv` |
| `Cluster id or serverless are required` | `.serverless(True)` missing | use the exact verify command in step 5 |
| `AuthenticationError` | CLI not authed on this machine | run the `databricks auth login` above |
| GX install conflicts | GX pins vs databricks-connect | expected — GX is optional, see `requirements-gx.txt` |
| venv uploaded to Databricks | `databricks.yml` missing exclude | ensure `sync.exclude` has `.venv/**` and `**/.venv/**` |
