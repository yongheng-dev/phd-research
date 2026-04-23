# Search Patterns — Wisdom Log

### 2026-04-23 — AI for Writing & Feedback
- **Effective queries**: venue-restricted Semantic Scholar searches with the approved whitelist (BJET, CAEAI, AETHE, Studies in Higher Ed, Assessing Writing) returned high-quality papers; pairing high-citation seed (Fan 2024, Nguyen 2024) with conceptual seed (Hawkins 2025) gave good D2/D4 coverage.
- **Ineffective queries**: generic "AI writing feedback" without venue filter returned heavy noise (vendor blogs, low-tier journals).
- **Best source for this topic**: Semantic Scholar (citation counts + venue filtering); arXiv weak for this field (mostly published in journals, not preprinted).
- **Venue gap**: *Assessing Writing* and *JSLW* under-surface via API — manual journal-site search recommended for AWE-specific papers.

### 2026-04-23 — AI for Language Learning & Speaking Practice
- **Effective queries**: Semantic Scholar venue-restricted search (LL&T, ReCALL, CALL, System, TESOL Q, Computers & Education) + meta-analysis seed (Bibauw 2022, Hou & Min 2025, Ngo 2023) gave fast triangulation across dialogue-CALL, ASR-CAPT, and GenAI-chatbot lines.
- **Effective query pattern**: pairing meta-analysis seeds with one technical/arXiv anchor per sub-area (Fu 2024 for assessment; Xu 2024 for situational dialogue) closed the journal-vs-preprint gap cleanly.
- **Ineffective queries**: generic "AI language learning" or "ChatGPT speaking" returned heavy noise from non-applied-linguistics venues (HCI, CS general); always co-restrict by venue + sub-area term ("WTC", "pronunciation", "oral assessment").
- **Best source for this topic**: Semantic Scholar primary (citation counts + Applied Linguistics venue coverage); arXiv secondary for the LLM-assessment frontier (Fu 2024, Parikh 2026, Xu 2024 are arXiv-only at search time).
- **Venue gap**: *Language Learning & Technology* (open-access DOI 10.64152) and *TESOL Quarterly* full-text behind Wiley paywall — abstract-only sourcing common; budget for `degraded_audit:true` flags on these venues.
- **Population gap pattern**: every venue-restricted query returned overwhelmingly English-EFL + university samples; supplementing with explicit "heritage" / "K-12" / "low-resource language" terms still returned <5% of corpus → genuine field-level gap, not search artefact.

### 2026-04-23 — Learning Analytics & EDM (2021–2026)
- **Effective queries**: Semantic Scholar venue-restricted searches against the LA/EDM whitelist (JLA, LAK, BJET, CHB, IEEE TLT) reliably returned high-quality D1/D2/D4/D6 papers; pairing landmark seeds (Saint 2021, Giannakos & Cukurova 2023, Deho 2022) with sub-area terms ("process mining", "fairness mitigation", "MMLA theory") gave fast triangulation.
- **Effective query pattern for D7 (GenAI-in-LA)**: combine GPT-4 / LLM term with a measurement-task term ("discourse classification", "challenge moment", "epistemic network") and venue restrict to LAK / JLA — yielded Garg 2024, Suraworachet 2024, Misiejuk 2025 cleanly.
- **Effective off-whitelist exception pattern**: when a landmark seed (Gardner/Brooks/Baker fairness transfer) is not indexed in the whitelist, accept the closest-lineage off-whitelist venue (FAccT 2023) and flag it explicitly in §9 Audit Flags rather than dropping the seed.
- **Ineffective queries**: arXiv MCP yielded **0 admitted papers** for any D-dimension in this deep-dive. LA/EDM is overwhelmingly journal/proceedings-published; arXiv is not the right preprint surface for this field. **Lesson**: skip arXiv pass for LA/EDM topics or budget it as a 0-yield cost.
- **Best source for this topic**: Semantic Scholar exclusively; arXiv adds ~0 value.
- **Rate-limit warning**: Semantic Scholar hit HTTP 429 during novelty-checker saturation queries after several rapid calls. **Lesson**: budget novelty-check queries (≤4 per direction); back off to verified-anchor reasoning if 429 appears, and flag saturation evidence as partial in the synthesis Audit Flags.
