# Role Generation Prompt

Use this prompt to generate all 6 role artifacts + meta.json in a single structured response. Fill the slots (lines starting with `>>>`) with the user's onboarding answers, then send the whole prompt.

---

## SLOTS

>>> ROLE: <e.g. "game developer">
>>> FLAVOR: <e.g. "indie Unity 2D, solo dev">
>>> DEPTH: <one of: dinner-party | week-one | month-one>
>>> PROJECT_CONTEXT: <user's current project in 1–3 sentences>
>>> SLUG: <kebab-case, derived from ROLE + FLAVOR, e.g. "game-dev-indie-unity-2d">
>>> DISPLAY_NAME: <human-readable, e.g. "Indie Unity 2D Game Developer">

---

## SYSTEM FRAME (required verbatim in the generation request)

You are writing a con artist's crash course, not a textbook. The reader has 48 hours to pass as a {ROLE} ({FLAVOR}) in front of real {ROLE}s. Every sentence must do exactly one of these:

- (a) teach a **shibboleth** — terminology a real one uses casually
- (b) install an **opinion** — a stance the reader can defend in a 5-minute argument
- (c) prevent a **tell** — a tourist mistake that outs them
- (d) trigger an **action** — something concrete to do, read, or ask Claude to do

Wikipedia-style overviews fail this bar. Definitions without usage examples fail. "It depends" fails. If a sentence would be true for any technical role, **delete it**. Specificity is the whole product.

## DEPTH CALIBRATION

- **dinner-party** — reader needs to hold a 10-minute conversation. Heavy on lexicon + signaling. Thin monday. Thin playbook.
- **week-one** — reader starts the job Monday. Balanced lexicon + signaling + monday. Decent playbook. *(default)*
- **month-one** — reader will make a small decision within a month. Lighter lexicon (assume they've read it). Heavy playbook, opinionated persona, detailed monday + decision rubrics.

Apply the calibration for DEPTH = **{DEPTH}**.

## PROJECT CONTEXT

`project-playbook.md` must be tailored to this project, not generic:
> {PROJECT_CONTEXT}

## OUTPUT FORMAT

Respond with **exactly** the following blocks, in order, separated by the delimiters shown. No preamble, no trailing prose, no code fences around the blocks.

```
===== BEGIN meta.json =====
{
  "slug": "{SLUG}",
  "display_name": "{DISPLAY_NAME}",
  "role": "{ROLE}",
  "flavor": "{FLAVOR}",
  "depth_level": "{DEPTH}",
  "project_summary": "<one-sentence summary of PROJECT_CONTEXT>",
  "generated_at": "<ISO-8601 timestamp>",
  "version": 1
}
===== END meta.json =====

===== BEGIN persona.md =====
# Persona — {DISPLAY_NAME}

## Voice
<2–3 bullets on how this role talks, what they default to, what they challenge. Concrete — "pushes back when asked to premature-optimize without profiling," not "values quality.">

## Defaults when advising
<4–6 bullets — the *first* thing this role reaches for in common situations. E.g., "When asked to debug perf, ask for a frame capture before suggesting code changes.">

## What I never suggest
<3–5 bullets — concrete anti-recommendations specific to this role/flavor.>

## How I disagree
<1 short paragraph — the polite-but-firm way this role pushes back on bad ideas.>
===== END persona.md =====

===== BEGIN lexicon.md =====
# Lexicon — {DISPLAY_NAME}

<Exactly 40–60 entries. Each entry is ONE line in this format:>
- **term** — one-line definition | heard in: "realistic sentence a real one would say" | tourist-tell: common misuse that outs a fake

<Include the ratio the user should expect:
- ~40% role-specific jargon
- ~30% tool/library names with specific opinions attached
- ~20% process/workflow terms
- ~10% cultural/in-joke terms>
===== END lexicon.md =====

===== BEGIN signaling.md =====
# Signaling — {DISPLAY_NAME}

## 3 opinions a real {ROLE} always has
<Three strong, defensible stances. Name the opposing school. Pick a side. No "both have merit.">

1. **<stance>** — <1–2 sentence defense. Name what the other side believes.>
2. ...
3. ...

## Tool preferences that signal "real one"
<5–8 concrete tool/library/workflow preferences with reasoning. E.g., "Rider over VS for Unity — because <specific reason>.">

## What they laugh at
<3–5 concrete things the community finds funny/cringe. Specific enough that using them correctly = signal of belonging.>

## How they read a new codebase / artifact / situation
<1 short paragraph — the *first* three things this role looks at when handed something new. This is a high-leverage signaling pattern.>
===== END signaling.md =====

===== BEGIN anti-patterns.md =====
# Anti-patterns — {DISPLAY_NAME}

## Instant tells
<5–8 things that out a fake in the first 60 seconds of a conversation. Be specific.>

## Things to never ask Claude to do
<5–8 prompts that a real {ROLE} would cringe at. E.g., "Don't ask Claude to 'optimize this code' without a profile.">

## Phrases that out you
<4–6 specific word choices. Format: "❌ <phrase> → ✅ <what a real one says instead>">

## Common misconceptions
<3–5 things beginners believe that real ones know are wrong. Name the belief, name the correction.>
===== END anti-patterns.md =====

===== BEGIN monday.md =====
# First Week — {DISPLAY_NAME}

<5 days. Each day has 4 sections. Be concrete — commands, file names, decisions, not vague advice.>

## Day 1
- **Commands I run:** <2–4 specific shell/editor commands>
- **Files I open:** <2–4 specific files or paths to look at>
- **People I message:** <who and what question — be specific about the Slack channel / role>
- **Decision I make:** <one concrete judgment call>

## Day 2
...

## Day 3
...

## Day 4
...

## Day 5
...

<Calibrate density to DEPTH: dinner-party = skeletal, week-one = full, month-one = full + "by end of week 1" summary.>
===== END monday.md =====

===== BEGIN project-playbook.md =====
# Playbook for this project — {DISPLAY_NAME}

> Project: {PROJECT_CONTEXT}

<At least 8 decision patterns. Each MUST be tied to *this specific project*, not a generic one. Format:>

## When <situation>
**A real {ROLE} does:** <action>
**Because:** <reason specific to {ROLE}'s priorities>
**Ask Claude for:** <the specific prompt a real one would send>

<Examples of situation categories to cover:>
- When Claude suggests X without data → <pushback pattern>
- When a feature is "almost working" → <what to verify before shipping>
- When stuck on a performance/quality/correctness issue → <diagnostic ladder>
- When choosing between two approaches → <the tiebreakers this role cares about>
- When the scope grows mid-task → <how to cut>

<Deeper DEPTH levels = more entries, more specific to project.>
===== END project-playbook.md =====
```

## QUALITY CHECKS (apply before emitting)

Before writing, silently verify:

1. Every lexicon entry has all three parts (def | heard in | tourist-tell).
2. Every signaling opinion names the opposing view.
3. Every monday entry has a concrete command/file/person — no "explore the codebase" vagueness.
4. Every playbook entry references *this specific project*, not generic patterns.
5. No sentence in the entire output would be equally true for a different technical role. If it would, rewrite or delete.

If any check fails, regenerate that section before emitting.
