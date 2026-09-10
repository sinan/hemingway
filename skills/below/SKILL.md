---
name: below
description: Shows what was below the surface of the previous reply. Use when the user says "below", "go below", "what's below", "show me below the surface", or names an item from the last "Below the surface:" line.
license: MIT
metadata:
  author: sinan
  version: "0.1"
---

Find the last "Below the surface:" line in the conversation.

If the user named an item, give that item only. If not, give every item on the line, in order, one short paragraph each.

Rules:
- Same style as the surface. Answer first. Short sentences. Plain words. Code, paths, and numbers exact.
- No headers. Bullets only for real lists. Tables only for comparisons.
- Do not repeat what the surface already said.
- Length is free. This is the depth the user asked for. It still has no filler.
- If something here changes what the user should do, say so in the first sentence.
- End with a new "Below the surface:" line if real things remain. Skip it if nothing does.

If there is no "Below the surface:" line to work from, say so in one sentence and ask which part of the last reply to expand.
