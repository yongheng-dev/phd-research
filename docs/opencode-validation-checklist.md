# OpenCode Validation Checklist

## 1. Verifier Suite

```bash
bash .opencode/verifiers/run-all.sh
```

Expected: all checks pass.

## 2. Launch

```bash
opencode
```

Expected: session starts with the configured Copilot model and MCP tools available.

## 3. Command Smoke Tests

```text
/find AI literacy assessment
/read arXiv:2310.02207
/think explain self-regulated learning
/write lit review on AI literacy --kind=review
/plan AI literacy in K-12
/review --cadence=week
/admin health
```

Expected:

- commands route correctly
- notes save to the 3-folder vault layout
- traces are written
- audits run where required
