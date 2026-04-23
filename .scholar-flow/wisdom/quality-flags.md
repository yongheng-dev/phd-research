# Quality Flags — Wisdom Log

### 2026-04-23 — AI for Writing & Feedback
- **Coverage gaps found**: Assessing Writing / JSLW underrepresented (API limitation, not topic gap); K-12 and non-Anglophone contexts thin across all D-dimensions; longitudinal designs absent; no validated instrument for metacognitive laziness.
- **Citation issues**: 0 fabricated. 15/15 papers verified in Semantic Scholar.
- **Summary revisions**:
  - MAJOR (1): Nguyen-2024 — process-mining methods misdescribed; full rewrite required (HMM + hierarchical sequence clustering + process mining).
  - MAJOR (1): Hawkins-2025 — full text + abstract inaccessible; collapsed to bibliographic stub. **Lesson**: when both abstract and PDF unavailable, do not synthesise from title alone.
  - MINOR (3): Pack, Fan, Weber — over-claimed beyond abstract; softened with hedged language.
- **Novelty surprises**: "AI vs human feedback comparison" direction far more saturated than expected (Direction 2 → 7/10, gate fail). "Metacognitive laziness instrument" wide-open (9/10).
- **Recurring pattern**: confounded experimental designs (specificity × delivery) are common in 2024 AI-feedback field experiments; readers should expect this and audit accordingly.

### 2026-04-23 — AI for Language Learning & Speaking Practice
- **Coverage gaps found**: SA-4 (GenAI vocabulary/grammar at top-tier venues) entirely empty; Sociocultural Theory / SDT / Translanguaging / Identity-Investment / critical-decolonial AIED all absent; heritage / refugee / K-12 / low-resource-language populations <5% of corpus; pre-registered RCTs and longitudinal (>12 wk) designs rare. Coverage-critic verdict: **SIGNIFICANT GAPS** — proceeded with user authorisation rather than supplementary search round.
- **Citation issues**: 0 fabricated. 12/12 papers verified in Semantic Scholar / arXiv. 4 minor title-completeness corrections applied (entries #3, #5, #8, #9 in brief).
- **Summary revisions**:
  - DEGRADED (1): Wang 2024 (*System*) — Elsevier paywall, abstract null on Semantic Scholar/OpenAlex/Unpaywall. RQs/instruments/effect sizes inferred from title; explicitly flagged `degraded_audit:true`. **Lesson**: Elsevier *System* paywall reliably blocks summarisation → trigger Zotero/ILL acquisition pre-summarisation for this venue.
  - DEGRADED (1): Hou & Min 2025 (*ReCALL*) — abstract-only sourcing; quantitative claims verified verbatim, but theoretical framing / publication-bias diagnostics unverified. Flagged `degraded_audit:true`.
  - PASS-WITH-CAVEAT (3): Bibauw 2022, Ngo 2023, Karatay & Xu 2025 — abstract-only but quantitative claims verbatim; specifics flagged.
- **Novelty surprises**: D4 (DIF audit + Dynamic Assessment counter-design) far less saturated than expected (HIGH novelty, 10/10 so-what) — fairness work alone exists but DA counter-design is empty. D2 (ASR feedback latency) more saturated than expected on initial framing (MEDIUM, REVISE) → revised to noticing-trace + multimodal-LLM-content-constancy → MEDIUM-HIGH, PROMOTE.
- **Meta-degraded audit**: novelty-checker's seed verification ran on shorthand citations rather than the verified DOIs from Phase 2, producing spurious "UNVERIFIED" flags on already-verified seeds. **Lesson**: pass full DOI list, not bibliographic shorthand, to novelty-checker.
- **Recurring pattern**: meta-analyses in this field converge tightly (dialogue-CALL *d* = .58 → *g* = .61 across 3 years; ASR-CAPT *g* = .69) — effect sizes are stable benchmarks against which to position new RCTs.

### 2026-04-23 — Learning Analytics & EDM (2021–2026)
- **Coverage gaps found**: cross-institutional fairness transfer, longitudinal MMLA, MOOC-EDM thin in initial Phase 1 → coverage-critic SUPPLEMENT NEEDED → resolved by +3 papers (Gupta 2022, Gardner 2023 [FAccT exception], Froehlich 2024). D7 arXiv pass yielded 0 admitted papers.
- **Citation issues**: 0 fabricated. 21/21 papers verified in Semantic Scholar.
- **Summary revisions**:
  - MAJOR (1): **Misiejuk-2025** (GenAI-LA review, JLA) — invented "Acknowledged Limitations" + inferred-method claims from abstract; full revision required to scope claims to author-stated content and split Stated vs Inferred limitations. **Lesson**: when summarising review papers from abstract only, never present inferred limitations as "Acknowledged"; explicitly label Stated / Inferred and trim methodological detail not present in the abstract.
  - MINOR (4): Giannakos-2023 (proxemics finding scoped to corpus; explicit-mention limitation added); Deho-2022 (universal-winner claim hedged; AIF360 attribution softened; Acknowledged→Stated/Inferred split; `degraded_audit:true`); Gardner-2023 (regularization claim scoped to tested range; biased-label limitation added; exploratory hedge on no-tradeoff); Suraworachet-2024 (few-shot/code-mixed unsupported claims removed; full 5 author-stated limitations split from inferred; `degraded_audit:true`).
- **Recurring pattern (cross-deep-dive)**: when only abstracts are accessible (BJET / FAccT / CHB / Wiley paywalls common in this corpus), summarisers consistently over-claim by inferring "Acknowledged" limitations that are not in the abstract. **Lesson**: enforce explicit Stated-vs-Inferred split in summary template and require `degraded_audit:true` whenever full text is unavailable.
- **Novelty surprises**: D1 (Longitudinal Fairness Drift as Measurement Construct) scored 9/9/9 — far less saturated than expected given the heat around fairness; the *drift-as-construct* framing is the differentiator. D3 (Synthesis-Role MMLA) under-performed relative to expectations — rejected for sub-branch under-specification.
- **Off-whitelist exception pattern**: FAccT 2023 (Gardner) accepted as a one-off lineage substitute when the seed paper was unindexed in the whitelist; flagged explicitly in synthesis §9. **Lesson**: off-whitelist exceptions are acceptable when (a) the seed is verified, (b) the venue is top-tier in an adjacent community, (c) the exception is logged transparently in Audit Flags.
- **Wiley paywall pattern (third confirmation)**: BJET / CHB consistently abstract-only on Semantic Scholar/OpenAlex/Unpaywall for this deep-dive — same pattern previously logged for *System* (writing) and *TESOL Q* (language). **Lesson**: route Wiley journal items through Zotero/ILL acquisition pre-summarisation, or budget `degraded_audit:true` flags upfront.
