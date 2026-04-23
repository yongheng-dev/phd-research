# PhD Research Doctrine — Hard Constraints

> **System-level methodological constraints** auto-injected into all research-class agents
> (research-ideator, novelty-checker, lit-review-builder, deep-dive, theory-mapper, plan).
>
> Source: distilled from advisor/peer discussions on doctoral-level contribution.

---

## Core Principle

> **A PhD is made by taking a small sub-branch within a mainstream topic that
> everyone is studying, producing a theoretical contribution, and answering "so what".**

Big-direction innovation is high-risk and rarely succeeds. Small-branch innovation
within active mainstream topics is the proven path.

---

## The 5-Step Research Path (S1–S5)

| Step | Action | Goal |
|------|--------|------|
| **S1 Deep Search** | Use AI to scan literature on `xx` from the last 5 years | Identify current hotspots and research gaps |
| **S2 Quick Survey** | Use AI to read recent (≤2 years) review papers | Acquire SOTA panorama cheaply |
| **S3 Theory Inventory** | Extract theoretical frameworks in use | Map theory genealogy and blank spots |
| **S4 Sub-Branch Positioning** | Choose a small cut within mainstream hotspots | Inherit visibility, claim novelty |
| **S5 So-What Argument** | State the **theoretical contribution** (not just a real-world fix) | Pass the doctoral bar |

This sequence is operationalized by the `/plan {topic}` command and by
`deep-dive`'s 5-stage orchestration.

---

## Hard Rules (enforced by So-What Gate)

Every research idea, brainstorm output, and `/plan` recommendation MUST carry
all four fields. Missing fields → automatic reject by `novelty-checker`.

| Field | Definition | Reject if |
|-------|------------|-----------|
| `mainstream_anchor` | The active hotspot the idea attaches to | "brand new direction" / no anchor |
| `sub_branch` | The specific small cut within that hotspot | duplicates an existing line of work |
| `theoretical_contribution` | What theory is extended, challenged, or integrated | only solves an engineering problem |
| `so_what` | "If this is true, who changes what behavior?" | nobody downstream changes anything |

---

## Anti-Patterns (must warn the user)

- ❌ "I want to open up a brand new direction." → big-direction innovation, low survival rate.
- ❌ "I solved a real problem." → engineering contribution only, not doctoral.
- ❌ "This gap is unexplored by anyone." → may mean low-value, not undiscovered.
- ❌ "I will not anchor to any existing theory." → no theoretical contribution possible.

When the user expresses any of the above, the agent MUST:
1. Acknowledge the intent.
2. Cite this doctrine.
3. Reframe toward a sub-branch + theoretical contribution.

---

## Operational Notes

- **Mainstream anchoring** is verified by `literature-searcher` (5-year hotspot list).
- **Theoretical inventory** is produced by `theory-mapper`.
- **So-what scoring** is a 0–10 score from `novelty-checker`; submission gate requires ≥ 8.
- This file is **immutable at runtime**. Edits require a human commit.
