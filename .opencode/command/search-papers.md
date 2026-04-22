---
description: Multi-source academic literature search on a topic
agent: build
---

Search for academic papers on the topic: $ARGUMENTS

Delegate to the `literature-searcher` subagent via the `task` tool. Pass the topic and any constraints. The subagent follows a thorough multi-source workflow (Semantic Scholar + arXiv) and persists results.

If no topic is provided, ask what the user wants to search for.

Research field context: AI in Education (PhD level)
Focus areas: AI literacy, self-regulated learning, learning analytics, intelligent tutoring systems
