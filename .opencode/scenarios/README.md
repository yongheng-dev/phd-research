# E2E Scenarios

Canonical minimal end-to-end workflows used to guard the system's core research paths.

These are not full runtime tests. They are scenario contracts that ensure each critical path still has:

- a command entry point
- delegated agents
- required audits
- persistence target
- trace emission
- checkpoint behavior where applicable

The machine-readable source of truth is `e2e-scenarios.json`.

The evidence handoff contract lives alongside it in `evidence-chains.json`.

Runtime trace-to-note linkage is validated separately by the trace-note contract.
